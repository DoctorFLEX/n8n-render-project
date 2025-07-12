// Test script for n8n-MCP tools
const fetch = require('node-fetch');

async function testMcpTools() {
  console.log('Testing n8n-MCP tools...');
  
  // Get current port from mcp_config_link.json
  const fs = require('fs');
  const configPath = '/Users/flex-devops/DeepflexIDEMAY25/mcp_config_link.json';
  const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
  const port = config.mcpServers['n8n-mcp'].env.PORT;
  const authToken = config.mcpServers['n8n-mcp'].env.AUTH_TOKEN;
  
  console.log(`Using MCP server at http://localhost:${port} with AUTH_TOKEN: ${authToken.substring(0, 5)}...`);
  
  // First, let's test with a simple health check to verify basic connectivity
  console.log('\n0. Testing basic connectivity with health check...');
  try {
    const healthResponse = await fetch(`http://localhost:${port}/health`, {
      method: 'GET'
    });
    
    const healthText = await healthResponse.text();
    console.log(`Health check status: ${healthResponse.status}`);
    console.log(`Health check response: ${healthText}`);
    
    // Now test with a valid method name from the documented MCP tools
    console.log('\n0b. Testing MCP endpoint with valid method...');
    const validMethodResponse = await fetch(`http://localhost:${port}/mcp`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${authToken}`
      },
      body: JSON.stringify({
        jsonrpc: '2.0',
        id: 'test-valid-method',
        method: 'list_nodes',
        params: {
          category: 'trigger'
        }
      })
    });
    
    const validMethodText = await validMethodResponse.text();
    console.log(`Valid method response status: ${validMethodResponse.status}`);
    try {
      // Try to parse as JSON to display nicely
      const validMethodJson = JSON.parse(validMethodText);
      console.log(`Valid method response: ${JSON.stringify(validMethodJson, null, 2).substring(0, 500)}...`);
    } catch (e) {
      // If not valid JSON, show as text
      console.log(`Valid method response: ${validMethodText.substring(0, 500)}...`);
    }
  } catch (error) {
    console.error('Error testing connectivity:', error);
  }
  
  try {
    // Test the search_nodes tool
    console.log('\n1. Testing search_nodes...');
    const searchNodesResponse = await fetch(`http://localhost:${port}/mcp`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${authToken}`
      },
      body: JSON.stringify({
        jsonrpc: '2.0',
        id: 'test-search-nodes',
        method: 'search_nodes',
        params: {
          query: 'openai'
        }
      })
    });
    
    const searchNodesResult = await searchNodesResponse.json();
    console.log('search_nodes result:', JSON.stringify(searchNodesResult, null, 2));
    
    // Test the list_nodes tool
    console.log('\n2. Testing list_nodes...');
    const listNodesResponse = await fetch(`http://localhost:${port}/mcp`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${authToken}`
      },
      body: JSON.stringify({
        jsonrpc: '2.0',
        id: 'test-list-nodes',
        method: 'list_nodes',
        params: {
          category: 'ai'
        }
      })
    });
    
    const listNodesResult = await listNodesResponse.json();
    console.log('list_nodes result:', JSON.stringify(listNodesResult, null, 2));
    
    // Test the n8n_diagnostic tool
    console.log('\n3. Testing n8n_diagnostic...');
    const n8nDiagnosticResponse = await fetch(`http://localhost:${port}/mcp`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${authToken}`
      },
      body: JSON.stringify({
        jsonrpc: '2.0',
        id: 'test-diagnostic',
        method: 'n8n_diagnostic',
        params: {
          verbose: true
        }
      })
    });
    
    const diagnosticResult = await n8nDiagnosticResponse.json();
    console.log('n8n_diagnostic result:', JSON.stringify(diagnosticResult, null, 2));
    
    // Test the list_ai_tools tool
    console.log('\n4. Testing list_ai_tools...');
    const listAiToolsResponse = await fetch(`http://localhost:${port}/mcp`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${authToken}`
      },
      body: JSON.stringify({
        jsonrpc: '2.0',
        id: 'test-ai-tools',
        method: 'list_ai_tools',
        params: {}
      })
    });
    
    const aiToolsResult = await listAiToolsResponse.json();
    console.log('list_ai_tools result:', JSON.stringify(aiToolsResult, null, 2));
    
  } catch (error) {
    console.error('Error testing MCP tools:', error);
  }
}

testMcpTools();
