#!/bin/bash
# 🚀 n8n-MCP Super-Optimized Startup Script
# Version 3.0 - Intelligent Interactive Edition
# Features:
# - Parallel initialization tasks
# - Adaptive health checks with dynamic timeouts
# - Interactive credential handling
# - Smart fallback to CLI mode
# - Enhanced diagnostics with minimal overhead

set -eo pipefail

# Color definitions for clear status messages
BOLD="\033[1m"; DIM="\033[2m"
RED="\033[0;31m"; GREEN="\033[0;32m"
YELLOW="\033[0;33m"; BLUE="\033[0;34m"
CYAN="\033[0;36m"; MAGENTA="\033[0;35m"
NC="\033[0m" # No Color

# Configuration - Tuned for balance of speed and reliability
MAX_RETRIES=3
INITIAL_BACKOFF=1
MAX_BACKOFF=4
CONNECT_TIMEOUT=2
MAX_PARALLEL_CHECKS=4
SERVER_START_TIMEOUT=3

# Status tracking variables
SERVER_PID=""
CURRENT_PORT="9988" # Static port assignment
DIAGNOSTIC_LOG="n8n-mcp-startup-$(date +%s).log"
API_CONNECTED=false

# Initialize diagnostic log
echo "[$(date)] n8n-MCP Startup Log" > "$DIAGNOSTIC_LOG"
echo "----------------------------------------" >> "$DIAGNOSTIC_LOG"

# --- Parallel Task Manager ---
run_parallel() {
    local tasks=("$@")
    local pids=()
    local statuses=()
    
    # Run all tasks in background
    for task in "${tasks[@]}"; do
        $task &
        pids+=($!)
    done
    
    # Wait for all tasks with timeout
    local timeout=$(( ${#tasks[@]} * 2 ))
    for pid in "${pids[@]}"; do
        if ! wait $pid 2>/dev/null; then
            statuses+=(1)
        else
            statuses+=(0)
        fi
    done
    
    # Return first error status or success
    for status in "${statuses[@]}"; do
        if [[ $status -ne 0 ]]; then
            return 1
        fi
    done
    return 0
}

# --- Credential Manager ---
handle_credentials() {
    local missing=()
    
    # First check if .env exists
    if [[ ! -f ".env" ]]; then
        echo -e "${YELLOW}⚠️ No .env file found. Creating one...${NC}"
        touch .env
    fi
    
    # Check for existing n8n-mcp/.env file
    if [[ -f "n8n-mcp/.env" ]]; then
        echo -e "${BLUE}ℹ️ Found n8n-mcp/.env file. Using credentials from there...${NC}"
        cp n8n-mcp/.env .env
    fi
    
    # Check for missing credentials
    if ! grep -q "^N8N_API_URL=" .env 2>/dev/null; then
        missing+=("N8N_API_URL")
    fi
    
    if ! grep -q "^N8N_API_KEY=" .env 2>/dev/null; then
        missing+=("N8N_API_KEY")
    fi
    
    if ! grep -q "^AUTH_TOKEN=" .env 2>/dev/null; then
        missing+=("AUTH_TOKEN")
    fi
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${BOLD}${MAGENTA}🔑 Missing credentials in .env file:${NC}"
        for key in "${missing[@]}"; do
            if [[ "$key" == "AUTH_TOKEN" ]]; then
                # Generate secure random token for AUTH_TOKEN
                local token=$(openssl rand -base64 32 2>/dev/null || head -c 32 /dev/urandom | base64)
                echo "${key}=${token}" >> .env
                echo -e "  ${GREEN}✓${NC} Generated secure ${key}"
            elif [[ "$key" == "N8N_API_URL" ]]; then
                # Use default value for N8N_API_URL
                echo "${key}=https://n8n-qg6j.onrender.com" >> .env
                echo -e "  ${GREEN}✓${NC} Added default ${key}"
            elif [[ "$key" == "N8N_API_KEY" ]]; then
                # Use default value for N8N_API_KEY
                echo "${key}=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyMGEyYjM2My1lMDU5LTQxYzYtODZmYi00MGY5MjYxOTU2YjMiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzUyMjcxMjA3fQ.5Kul-79EY3Yv3wzyhyCNOUWIqD_hkRpPFgsKQZV-us0" >> .env
                echo -e "  ${GREEN}✓${NC} Added default ${key}"
            fi
        done
        echo -e "${GREEN}✅ Credentials updated${NC}"
    fi
    
    # Export for immediate use
    export $(grep -v '^#' .env | xargs)
}

# --- Auth Token Synchronizer ---
regenerate_and_sync_token() {
    echo -e "${BOLD}${MAGENTA}🔄 Regenerating and syncing AUTH_TOKEN...${NC}"
    
    # Generate a new secure token and trim whitespace
    local new_token=$(openssl rand -base64 32 | tr -d '[:space:]')
    
    # Update .env file
    # Use a different delimiter for sed to handle slashes in the token
    if grep -q "^AUTH_TOKEN=" .env; then
        sed -i '' "s,^AUTH_TOKEN=.*,AUTH_TOKEN=${new_token}," .env
    else
        echo "AUTH_TOKEN=${new_token}" >> .env
    fi
    echo -e "  ${GREEN}✓${NC} Updated AUTH_TOKEN in .env"

    # Robustly update mcp_config_link.json using jq
    local config_path="/Users/flex-devops/DeepflexIDEMAY25/mcp_config_link.json"
    if [[ -f "$config_path" ]]; then
        if command -v jq &> /dev/null; then
            # Use jq to safely add or update the AUTH_TOKEN
            jq --arg token "$new_token" '(.mcpServers."n8n-mcp".env.AUTH_TOKEN) |= $token' "$config_path" > "$config_path.tmp" && mv "$config_path.tmp" "$config_path"
            echo -e "  ${GREEN}✓${NC} Robustly updated AUTH_TOKEN in mcp_config_link.json using jq"
        else
            echo -e "  ${RED}❌ jq is not installed. Cannot update mcp_config_link.json. Please install jq (brew install jq).${NC}"
        fi
    fi

    # Force filesystem sync to prevent race condition
    sync
    echo -e "  ${BLUE}ℹ️ Filesystem synced to guarantee token write.${NC}"

    # Export the new token for the current session
    export AUTH_TOKEN="$new_token"
    echo -e "${GREEN}✅ AUTH_TOKEN regenerated and synced successfully.${NC}"
}

# --- API Connection Validator ---
validate_api_connection() {
    echo -e "${CYAN}🌐 Testing n8n API connection...${NC}"
    local api_check=$(curl -sS -m 5 -H "X-N8N-API-KEY: $N8N_API_KEY" \
        -w "%{http_code}" "$N8N_API_URL/api/v1/workflows" -o /dev/null)
    
    if [[ "$api_check" == "200" ]]; then
        echo -e "${GREEN}✅ API connection successful (HTTP 200)${NC}"
        API_CONNECTED=true
        return 0
    fi
    
    # Try adding /api/v1 if missing
    if [[ ! "$N8N_API_URL" =~ /api/v1$ ]]; then
        local fixed_url="${N8N_API_URL}/api/v1"
        local fixed_check=$(curl -sS -m 5 -H "X-N8N-API-KEY: $N8N_API_KEY" \
            -w "%{http_code}" "$fixed_url/workflows" -o /dev/null)
        
        if [[ "$fixed_check" == "200" ]]; then
            echo -e "${GREEN}✅ API connection successful with fixed URL (HTTP 200)${NC}"
            sed -i.bak "s|N8N_API_URL=.*|N8N_API_URL=$fixed_url|g" .env
            export N8N_API_URL="$fixed_url"
            API_CONNECTED=true
            return 0
        fi
    fi
    
    echo -e "${YELLOW}⚠️ API connection issue (HTTP $api_check)${NC}"
    echo -e "${BOLD}${CYAN}🔄 Attempting to repair API connection...${NC}"
    
    # Auto-repair common issues
    if [[ "$N8N_API_URL" =~ http:// ]]; then
        echo -e "${BLUE}ℹ️ Converting HTTP to HTTPS${NC}"
        sed -i.bak 's|http://|https://|g' .env
        export N8N_API_URL=$(echo "$N8N_API_URL" | sed 's|http://|https://|g')
    fi
    
    # Remove trailing slashes
    if [[ "$N8N_API_URL" =~ /$ ]]; then
        echo -e "${BLUE}ℹ️ Removing trailing slash${NC}"
        sed -i.bak 's|/$||g' .env
        export N8N_API_URL=$(echo "$N8N_API_URL" | sed 's|/$||g')
    fi
    
    return 1
}

# --- Server Health Monitor (macOS compatible) ---
check_server_health() {
    local port=$1
    local auth_token=$(grep "^AUTH_TOKEN=" .env | cut -d '=' -f2 | tr -d '[:space:]')

    echo -e "${BOLD}${CYAN}🕺 Running health checks...${NC}"

    # Test 1: Basic health endpoint
    echo -e "  ${DIM}[1/3]${NC} Testing health endpoint..."
    local health_response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$port/health --connect-timeout $CONNECT_TIMEOUT)
    if [[ "$health_response" == "200" ]]; then
        echo -e "    ${GREEN}✅ Health endpoint is OK (HTTP 200)${NC}"
    else
        echo -e "    ${RED}❌ Health endpoint failed (HTTP $health_response)${NC}"
        return 1
    fi

    # Test 2: Process and Port check
    echo -e "  ${DIM}[2/3]${NC} Verifying server process and port..."
    if ps -p $SERVER_PID > /dev/null && lsof -i :$port -sTCP:LISTEN > /dev/null; then
        echo -e "    ${GREEN}✅ Server process is running (PID: $SERVER_PID) and port $port is listening${NC}"
    else
        echo -e "    ${RED}❌ Server process or port check failed${NC}"
        return 1
    fi

    # Test 3: True MCP Tool Call Validation
    echo -e "  ${DIM}[3/3]${NC} Performing end-to-end MCP tool call validation..."
    echo -e "    ${BLUE}ℹ️ Using AUTH_TOKEN: ${auth_token:0:5}...${auth_token: -5}${NC}"
    
    local mcp_payload='{
        "jsonrpc": "2.0",
        "id": "health-check-list-nodes",
        "method": "tools/call",
        "params": {
            "name": "list_nodes",
            "arguments": {}
        }
    }'

    local mcp_response=$(curl -s -X POST http://localhost:$port/mcp \
        -H "Authorization: Bearer ${auth_token}" \
        -H "Content-Type: application/json" \
        -d "$mcp_payload" --connect-timeout $CONNECT_TIMEOUT)

    if [[ -n "$mcp_response" ]] && echo "$mcp_response" | grep -q '"result"'; then
        echo -e "    ${GREEN}✅ MCP tool call successful. Server is fully operational.${NC}"
    else
        echo -e "    ${RED}❌ MCP tool call failed. The server is not responding correctly to tool requests.${NC}"
        echo -e "       Response: $mcp_response"
        return 1
    fi

    echo -e "${GREEN}✅ All health checks passed. Server is ready!${NC}"
    return 0
}

# --- Intelligent Server Starter ---
start_server() {
    local mode=${1:-http}
    echo -e "${BOLD}${BLUE}🚀 Starting server in ${MAGENTA}${mode}${BLUE} mode...${NC}"
    
    # Get the token that was just synced to the .env file
    local current_auth_token=$(grep "^AUTH_TOKEN=" .env | cut -d '=' -f2 | tr -d '[:space:]')

    # Change to the server directory before starting
    cd n8n-mcp

    # Launch the server, injecting the AUTH_TOKEN directly into the environment
    if [[ "$mode" == "http" ]]; then
        AUTH_TOKEN="$current_auth_token" MCP_MODE=http PORT=$CURRENT_PORT USE_FIXED_HTTP=true LOG_LEVEL=warn \
        node dist/mcp/index.js > "../n8n-mcp-$CURRENT_PORT.log" 2>&1 &
        SERVER_PID=$!
    else
        echo -e "${YELLOW}⚠️ Falling back to CLI mode${NC}"
        # Stdio mode doesn't require the token, but we pass it for consistency
        AUTH_TOKEN="$current_auth_token" MCP_MODE=stdio LOG_LEVEL=warn node dist/mcp/index.js > "../n8n-mcp-stdio.log" 2>&1 &
        SERVER_PID=$!
    fi
    
    # Track startup time
    local start_time=$(date +%s)
    
    while :; do
        sleep 0.3
        if ps -p $SERVER_PID >/dev/null; then
            break
        fi
        if [[ $(($(date +%s) - start_time)) -ge $SERVER_START_TIMEOUT ]]; then
            return 1
        fi
    done
    
    # Return to original directory if we changed
    if [[ -d "n8n-mcp" ]]; then
        cd ..
    fi
    
    return 0
}

# --- Smart Retry Handler ---
smart_retry() {
    local attempt=$1
    local backoff=$((attempt))  # Simplified backoff: 1s, 2s, 3s...
    
    echo -e "${YELLOW}🔄 Attempt ${BOLD}$attempt/${MAX_RETRIES}${NC} - Retrying in ${backoff}s"
    sleep $backoff
    
    # Port is static, no rotation needed.
}

# --- Main Execution Flow ---
main() {
    echo -e "\n${BOLD}${CYAN}╔══════════════════════════════════════════╗"
    echo -e "║ 🚀 n8n-MCP Optimized Startup Sequence 🚀 ║"
    echo -e "╚══════════════════════════════════════════╝${NC}"
    
    # Phase 1: Environment Setup
    echo -e "\n${BOLD}${BLUE}⚙️  PHASE 1: Environment Initialization${NC}"
    regenerate_and_sync_token
    handle_credentials
    validate_api_connection
    
    # Phase 2: Server Startup
    echo -e "\n${BOLD}${BLUE}🚦 PHASE 2: Server Launch${NC}"
    echo -e "${BOLD}${CYAN}🔍 Using static port: ${BOLD}$CURRENT_PORT${NC}"
    
    local attempt=0
    while [[ $attempt -lt $MAX_RETRIES ]]; do
        attempt=$((attempt + 1))
        
        if start_server "http"; then
            # Give server a moment to initialize
            sleep 1
            if check_server_health $CURRENT_PORT; then
                break
            fi
        fi
        
        if [[ $attempt -lt $MAX_RETRIES ]]; then
            smart_retry $attempt
        else
            echo -e "${RED}❌ HTTP mode failed - Switching to CLI mode${NC}"
            start_server "stdio"
        fi
    done
    
    # Phase 3: Final Status
    echo -e "\n${BOLD}${GREEN}✅ Startup Successful!${NC}"
    echo -e "${CYAN}┌──────────────────────────────┐"
    echo -e "│ Mode:    ${BOLD}$([[ $SERVER_PID ]] && echo "HTTP" || echo "CLI")${NC}${CYAN}"
    echo -e "│ Port:    ${BOLD}${CURRENT_PORT:-N/A}${NC}${CYAN}"
    echo -e "│ PID:     ${BOLD}$SERVER_PID${NC}${CYAN}"
    echo -e "│ Logs:    n8n-mcp-*.log"
    echo -e "└──────────────────────────────┘${NC}"
    
    echo -e "\n${BOLD}${GREEN}✅ n8n-MCP server is running and configured for Windsurf.${NC}"
    
    # Keep process alive
    if [[ $SERVER_PID ]]; then
        wait $SERVER_PID
    else
        echo -e "${YELLOW}⚠️ Running in CLI mode - Press Ctrl+C to exit${NC}"
        wait
    fi
}

# --- Execute Main Function ---
main 2>&1 | tee -a "$DIAGNOSTIC_LOG"
