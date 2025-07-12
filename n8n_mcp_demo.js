/**
 * n8n-MCP Creative Demonstration
 * 
 * This script demonstrates how to use n8n-MCP tools for efficient workflow creation,
 * validation, and deployment. It showcases the power of n8n-MCP for AI-assisted
 * workflow automation.
 */

// Sample responses from n8n-MCP tools
const toolResponses = {
  // 1. Search for nodes related to HTTP requests
  search_nodes: {
    query: "http",
    results: [
      {
        name: "HTTP Request",
        type: "n8n-nodes-base.httpRequest",
        description: "Makes an HTTP request and returns the response data",
        displayName: "HTTP Request",
        group: ["input"],
        version: 1,
        defaults: {
          name: "HTTP Request",
          color: "#2200DD"
        },
        inputs: ["main"],
        outputs: ["main"],
        properties: [
          // Properties would be listed here (truncated for brevity)
        ]
      },
      {
        name: "Webhook",
        type: "n8n-nodes-base.webhook",
        description: "Creates a webhook that can receive data",
        displayName: "Webhook",
        group: ["trigger"],
        version: 1,
        defaults: {
          name: "Webhook",
          color: "#885577"
        },
        inputs: [],
        outputs: ["main"],
        webhooks: [
          {
            name: "default",
            httpMethod: "POST",
            responseMode: "onReceived",
            path: "={{$parameter[\"path\"]}}"
          }
        ],
        properties: [
          // Properties would be listed here (truncated for brevity)
        ]
      }
    ]
  },
  
  // 2. Get essential properties for HTTP Request node
  get_node_essentials: {
    nodeType: "n8n-nodes-base.httpRequest",
    displayName: "HTTP Request",
    description: "Makes an HTTP request and returns the response data",
    essentialProperties: [
      {
        name: "method",
        displayName: "Method",
        type: "options",
        options: [
          { name: "GET", value: "GET" },
          { name: "POST", value: "POST" },
          { name: "PUT", value: "PUT" },
          { name: "DELETE", value: "DELETE" },
          { name: "HEAD", value: "HEAD" },
          { name: "OPTIONS", value: "OPTIONS" },
          { name: "PATCH", value: "PATCH" }
        ],
        default: "GET",
        required: true,
        description: "The request method to use"
      },
      {
        name: "url",
        displayName: "URL",
        type: "string",
        default: "",
        required: true,
        description: "The URL to make the request to"
      },
      {
        name: "authentication",
        displayName: "Authentication",
        type: "options",
        options: [
          { name: "None", value: "none" },
          { name: "Basic Auth", value: "basicAuth" },
          { name: "Header Auth", value: "headerAuth" },
          { name: "OAuth2", value: "oAuth2" },
          { name: "Digest Auth", value: "digestAuth" }
        ],
        default: "none",
        description: "The authentication to use"
      },
      {
        name: "responseFormat",
        displayName: "Response Format",
        type: "options",
        options: [
          { name: "Auto-detect (recommended)", value: "autodetect" },
          { name: "String", value: "string" },
          { name: "JSON", value: "json" },
          { name: "Binary", value: "file" }
        ],
        default: "autodetect",
        description: "The format in which the response should be returned"
      }
    ],
    examples: [
      {
        name: "Simple GET Request",
        description: "Make a GET request to fetch data from an API",
        config: {
          method: "GET",
          url: "https://api.example.com/data",
          authentication: "none",
          responseFormat: "json"
        }
      },
      {
        name: "POST with JSON Body",
        description: "Send JSON data to an API endpoint",
        config: {
          method: "POST",
          url: "https://api.example.com/create",
          authentication: "none",
          headers: {
            "Content-Type": "application/json"
          },
          body: {
            mode: "json",
            json: { 
              name: "Example",
              value: "Test Data"
            }
          },
          responseFormat: "json"
        }
      }
    ],
    tips: [
      "Use expressions like {{$json.url}} to make the URL dynamic",
      "For JSON responses, you can access data with $json.property",
      "Set 'Split Into Items' to true to process array responses as individual items"
    ]
  },
  
  // 3. Validate a node configuration
  validate_node_minimal: {
    nodeType: "n8n-nodes-base.httpRequest",
    config: {
      method: "GET",
      url: "https://api.example.com/data"
    },
    valid: true,
    requiredProperties: ["method", "url"],
    missingRequired: [],
    warnings: []
  },
  
  // 4. Validate a more complex node operation
  validate_node_operation: {
    nodeType: "n8n-nodes-base.httpRequest",
    config: {
      method: "POST",
      url: "https://api.example.com/data",
      headers: {
        "Content-Type": "application/json"
      },
      body: {
        mode: "json",
        json: {
          name: "Test",
          value: 123
        }
      }
    },
    profile: "runtime",
    valid: true,
    warnings: [],
    tips: [
      "Consider adding error handling for non-200 responses",
      "You might want to validate the response format"
    ],
    examples: [
      {
        name: "Similar configuration",
        config: {
          method: "POST",
          url: "https://api.example.com/data",
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer {{$json.token}}"
          },
          body: {
            mode: "json",
            json: {
              name: "{{$json.name}}",
              value: "{{$json.value}}"
            }
          },
          responseFormat: "json"
        }
      }
    ]
  },
  
  // 5. Validate a complete workflow
  validate_workflow: {
    workflow: {
      nodes: [
        {
          id: "1",
          name: "Start",
          type: "n8n-nodes-base.scheduleTrigger",
          position: [100, 100],
          parameters: {
            interval: [
              {
                field: "hours",
                value: 1
              }
            ]
          }
        },
        {
          id: "2",
          name: "HTTP Request",
          type: "n8n-nodes-base.httpRequest",
          position: [300, 100],
          parameters: {
            method: "GET",
            url: "https://api.example.com/data",
            authentication: "none",
            responseFormat: "json"
          }
        },
        {
          id: "3",
          name: "Set",
          type: "n8n-nodes-base.set",
          position: [500, 100],
          parameters: {
            keepOnlySet: true,
            values: [
              {
                name: "processedData",
                value: "={{ $json.data }}"
              }
            ]
          }
        }
      ],
      connections: {
        Start: {
          main: [
            [
              {
                node: "HTTP Request",
                type: "main",
                index: 0
              }
            ]
          ]
        },
        "HTTP Request": {
          main: [
            [
              {
                node: "Set",
                type: "main",
                index: 0
              }
            ]
          ]
        }
      }
    },
    valid: true,
    nodeValidations: {
      "Start": { valid: true },
      "HTTP Request": { valid: true },
      "Set": { valid: true }
    },
    connectionValidations: {
      valid: true
    },
    warnings: [],
    suggestions: [
      "Consider adding error handling for the HTTP Request node",
      "You might want to add a node to handle rate limiting"
    ]
  },
  
  // 6. Update a workflow with partial changes
  update_partial_workflow: {
    workflowId: "123",
    operations: [
      {
        type: "updateNode",
        nodeId: "2",
        changes: {
          position: [350, 120],
          parameters: {
            url: "https://api.example.com/v2/data"
          }
        }
      },
      {
        type: "addNode",
        node: {
          id: "4",
          name: "Error Handler",
          type: "n8n-nodes-base.if",
          position: [500, 250],
          parameters: {
            conditions: [
              {
                value1: "={{ $json.statusCode }}",
                operation: "notEqual",
                value2: 200
              }
            ]
          }
        }
      },
      {
        type: "addConnection",
        source: {
          node: "HTTP Request",
          type: "main",
          index: 0
        },
        target: {
          node: "Error Handler",
          type: "main",
          index: 0
        }
      }
    ],
    applied: true,
    changes: 3,
    newWorkflowId: "123",
    warnings: []
  }
};

// Example of a workflow creation process using n8n-MCP
function createWorkflowWithMCP() {
  console.log("=== n8n-MCP Workflow Creation Process ===");
  
  // Step 1: Discovery - Search for nodes
  console.log("\n1. DISCOVERY PHASE");
  console.log("Searching for HTTP-related nodes...");
  console.log(`Found ${toolResponses.search_nodes.results.length} nodes matching "http"`);
  console.log(`- ${toolResponses.search_nodes.results[0].displayName}: ${toolResponses.search_nodes.results[0].description}`);
  console.log(`- ${toolResponses.search_nodes.results[1].displayName}: ${toolResponses.search_nodes.results[1].description}`);
  
  // Step 2: Configuration - Get essential properties
  console.log("\n2. CONFIGURATION PHASE");
  console.log(`Getting essential properties for ${toolResponses.get_node_essentials.displayName}...`);
  console.log(`Found ${toolResponses.get_node_essentials.essentialProperties.length} essential properties`);
  console.log("Essential properties include:");
  toolResponses.get_node_essentials.essentialProperties.forEach(prop => {
    console.log(`- ${prop.displayName} (${prop.name}): ${prop.description}`);
  });
  
  // Step 3: Pre-Validation - Validate node configuration
  console.log("\n3. PRE-VALIDATION PHASE");
  console.log("Validating HTTP Request node configuration...");
  if (toolResponses.validate_node_minimal.valid) {
    console.log("✅ Basic configuration is valid");
  } else {
    console.log("❌ Configuration is invalid");
    console.log(`Missing required properties: ${toolResponses.validate_node_minimal.missingRequired.join(", ")}`);
  }
  
  // Step 4: Advanced Validation - Validate operation
  console.log("\n4. ADVANCED VALIDATION PHASE");
  console.log("Validating HTTP Request operation with runtime profile...");
  if (toolResponses.validate_node_operation.valid) {
    console.log("✅ Operation configuration is valid");
    if (toolResponses.validate_node_operation.tips.length > 0) {
      console.log("Tips for improvement:");
      toolResponses.validate_node_operation.tips.forEach(tip => {
        console.log(`- ${tip}`);
      });
    }
  } else {
    console.log("❌ Operation configuration is invalid");
  }
  
  // Step 5: Workflow Validation - Validate complete workflow
  console.log("\n5. WORKFLOW VALIDATION PHASE");
  console.log("Validating complete workflow...");
  if (toolResponses.validate_workflow.valid) {
    console.log("✅ Workflow is valid");
    console.log(`Validated ${Object.keys(toolResponses.validate_workflow.nodeValidations).length} nodes`);
    console.log(`Suggestions for improvement: ${toolResponses.validate_workflow.suggestions.length}`);
    toolResponses.validate_workflow.suggestions.forEach(suggestion => {
      console.log(`- ${suggestion}`);
    });
  } else {
    console.log("❌ Workflow is invalid");
  }
  
  // Step 6: Workflow Updates - Make partial updates
  console.log("\n6. WORKFLOW UPDATE PHASE");
  console.log("Making partial updates to workflow...");
  console.log(`Applied ${toolResponses.update_partial_workflow.changes} changes to workflow`);
  console.log("Changes made:");
  console.log("- Updated HTTP Request URL to v2 endpoint");
  console.log("- Added Error Handler node");
  console.log("- Connected HTTP Request to Error Handler");
  
  console.log("\n=== Workflow Creation Process Complete ===");
}

// Execute the demonstration
createWorkflowWithMCP();
