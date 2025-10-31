#!/usr/bin/env node

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
  Tool,
} from "@modelcontextprotocol/sdk/types.js";
import vault from "node-vault";

// Environment configuration
const VAULT_ADDR = process.env.VAULT_ADDR || "http://127.0.0.1:8200";
const VAULT_TOKEN = process.env.VAULT_TOKEN;

// Validate required environment variables
if (!VAULT_TOKEN) {
  console.error("Error: VAULT_TOKEN environment variable is required");
  process.exit(1);
}

// Initialize Vault client
const vaultClient = vault({
  apiVersion: "v1",
  endpoint: VAULT_ADDR,
  token: VAULT_TOKEN,
});

// Define available tools
const TOOLS: Tool[] = [
  {
    name: "vault_read",
    description: "Read a secret from Vault at the specified path",
    inputSchema: {
      type: "object",
      properties: {
        path: {
          type: "string",
          description: "The path to read the secret from (e.g., 'secret/data/myapp')",
        },
      },
      required: ["path"],
    },
  },
  {
    name: "vault_write",
    description: "Write a secret to Vault at the specified path",
    inputSchema: {
      type: "object",
      properties: {
        path: {
          type: "string",
          description: "The path to write the secret to (e.g., 'secret/data/myapp')",
        },
        data: {
          type: "object",
          description: "The secret data to write as a JSON object",
        },
      },
      required: ["path", "data"],
    },
  },
  {
    name: "vault_list",
    description: "List secrets at the specified path in Vault",
    inputSchema: {
      type: "object",
      properties: {
        path: {
          type: "string",
          description: "The path to list secrets from (e.g., 'secret/metadata')",
        },
      },
      required: ["path"],
    },
  },
  {
    name: "vault_delete",
    description: "Delete a secret from Vault at the specified path",
    inputSchema: {
      type: "object",
      properties: {
        path: {
          type: "string",
          description: "The path to delete the secret from (e.g., 'secret/data/myapp')",
        },
      },
      required: ["path"],
    },
  },
];

// Create MCP server
const server = new Server(
  {
    name: "vault-mcp",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Handle tool listing
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: TOOLS,
  };
});

// Handle tool execution
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case "vault_read": {
        const { path } = args as { path: string };
        const result = await vaultClient.read(path);
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(result.data, null, 2),
            },
          ],
        };
      }

      case "vault_write": {
        const { path, data } = args as { path: string; data: Record<string, any> };
        // For KV v2, wrap data in a data object
        const result = await vaultClient.write(path, { data });
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(result, null, 2),
            },
          ],
        };
      }

      case "vault_list": {
        const { path } = args as { path: string };
        const result = await vaultClient.list(path);
        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(result.data, null, 2),
            },
          ],
        };
      }

      case "vault_delete": {
        const { path } = args as { path: string };
        await vaultClient.delete(path);
        return {
          content: [
            {
              type: "text",
              text: `Successfully deleted secret at path: ${path}`,
            },
          ],
        };
      }

      default:
        throw new Error(`Unknown tool: ${name}`);
    }
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : String(error);
    return {
      content: [
        {
          type: "text",
          text: `Error executing ${name}: ${errorMessage}`,
        },
      ],
      isError: true,
    };
  }
});

// Start the server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("Vault MCP Server running on stdio");
}

main().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(1);
});
