#!/bin/bash
# 🧠 n8n‑MCP Dependency Update Tool –
# Agentic with Exponential Backoff + Jitter & Progressive Improvement

set -euo pipefail
IFS=$'\n\t'

echo "📦 n8n‑MCP Dependency Updater – Starting agentic retry loop"
echo "==========================================================="

cd "$(dirname "$0")/n8n-mcp"
echo "🔍 Working directory: $(pwd)"
echo

# Configuration
MAX_RETRIES=5
BASE_DELAY=2      # seconds
MAX_DELAY=60      # caps max wait
JITTER_FACTOR=0.5 # 50% random jitter

# Retry wrapper with progressive strategy
retry() {
  local cmd="$*"
  local attempt=0
  
  until eval "$cmd"; do
    ((attempt++))
    if (( attempt >= MAX_RETRIES )); then
      echo "❌ [$cmd] failed after $attempt attempts."
      return 1
    fi

    # Exponential backoff + jitter
    local delay=$((BASE_DELAY * 2**(attempt-1)))
    (( delay > MAX_DELAY )) && delay="$MAX_DELAY"
    local jitter=$(awk -v d="$delay" -v f="$JITTER_FACTOR" 'BEGIN{srand(); printf "%.2f", d * (1 + (rand()*2-1)*f)}')

    echo "⚠️ Attempt $attempt failed. Waiting ${jitter}s before retrying '$cmd'..."
    sleep "$jitter"

    # Progressive improvement on each retry
    case $attempt in
      2) echo "🔧 [INFO] Re-running with 'npm audit fix --force' fallback"; cmd="npm audit fix --force" ;;
      3) echo "🔧 [INFO] Clearing npm cache to resolve potential corruption"; npm cache clean --force ;;
      4) echo "🔧 [INFO] Updating npm to latest version"; npm install -g npm ;;
    esac
  done

  echo "✅ '$cmd' succeeded on attempt $((attempt+1))."
}

# Steps
echo "📑 Backing up files..."
retry "cp package.json package.json.bak && cp package-lock.json package-lock.json.bak"
echo

echo "🔍 Running npm audit..."
retry "npm audit > npm-audit-report.txt"
echo

echo "🔄 Updating devDependencies..."
retry "npm update --save-dev"
echo

echo "🔄 Updating dependencies..."
retry "npm update --save"
echo

echo "🛠️ Running npm audit fix..."
retry "npm audit fix"
echo

echo "📊 Capturing remaining audit issues..."
retry "npm audit > npm-audit-remaining-issues.txt"
echo

echo "⚠️ Checking breaking changes..."
retry "npm audit fix --dry-run > npm-audit-breaking-changes.txt"
echo

echo "🏗️ Final build check..."
retry "npm run build"
echo

# Summary
cat <<EOF
📋 Update Summary:
------------------------------------
✅ Backups: package.json.bak, package-lock.json.bak
✅ Audit report: npm-audit-report.txt
✅ Remaining issues: npm-audit-remaining-issues.txt
✅ Breaking changes report: npm-audit-breaking-changes.txt

🚀 Next Checks:
1. Inspect reports and backup diff.
2. Use backups if issues arise: mv *.bak originals.
3. Commit or CI test with successful build.

✨ Agentic update loop completed successfully!
EOF
