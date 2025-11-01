# Building Chat Systems with vault-mcp MCP Server

This guide shows you how to integrate the vault-mcp server into various chat applications and build custom chat interfaces.

## Overview

The vault-mcp server exposes Vault operations as MCP tools that can be used by AI assistants in chat applications. When integrated with a chat system, users can interact with Vault using natural language.

## Integration Options

### Option 1: Claude Desktop (Simplest)

Claude Desktop is the easiest way to get started - it's a ready-made chat interface that supports MCP servers.

#### Setup

1. **Connect via Docker Desktop MCP Toolkit:**
   ```powershell
   docker mcp client connect claude-desktop --global
   ```

2. **Or configure manually** - Edit `%APPDATA%\Claude\claude_desktop_config.json`:
   ```json
   {
     "mcpServers": {
       "vault": {
         "command": "docker",
         "args": [
           "run",
           "-i",
           "--rm",
           "-e", "VAULT_ADDR=http://host.docker.internal:8200",
           "-e", "VAULT_TOKEN=myroot",
           "vault-mcp-vault-mcp:latest"
         ]
       }
     }
   }
   ```

3. **Restart Claude Desktop**

4. **Chat Examples:**
   - "Read the secret at path secret/data/myapp"
   - "Store a new API key: secret/data/production with key=api_key_12345"
   - "List all secrets in the secret store"
   - "Delete the secret at secret/data/old-key"

### Option 2: Custom Web Chat Application

Build your own chat interface using the MCP SDK client.

#### Architecture

```
┌─────────────┐      MCP Protocol      ┌──────────────┐      HTTP      ┌──────┐
│  Web Chat  │ ←───────────────────→   │  MCP Client  │ ←──────────→    │ Vault│
│  (React)   │     (JSON-RPC/stdio)   │  (Node.js)   │                │      │
└─────────────┘                          └──────────────┘                └──────┘
```

#### Implementation Steps

1. **Backend MCP Client** - Connects to vault-mcp server via stdio
2. **Web API** - REST/WebSocket API that wraps MCP operations
3. **Frontend Chat UI** - React/Vue/HTML chat interface
4. **AI Integration** - Use OpenAI/Anthropic APIs to process chat messages

See `examples/chat-app/` for full implementation.

### Option 3: CLI Chat Interface

A simple command-line chat that uses the MCP server directly.

See `examples/cli-chat.js` for implementation.

### Option 4: Slack/Discord Bot

Integrate vault-mcp into Slack or Discord bots.

See `examples/slack-bot.js` for Slack integration example.

## Chat System Architecture

### Basic Flow

```
User Message
    ↓
Chat Interface
    ↓
AI Model (Claude/GPT)
    ↓
MCP Client
    ↓
vault-mcp Server (Docker)
    ↓
Vault API
    ↓
Response
```

### Key Components

1. **Chat Interface**: Where users type messages
2. **AI Model**: Interprets user intent and decides which MCP tools to call
3. **MCP Client**: Connects to MCP servers and invokes tools
4. **vault-mcp Server**: Your MCP server running in Docker
5. **Vault**: The secrets management backend

## Example Use Cases

### 1. Secrets Management Chatbot

Users can ask:
- "What API keys do we have stored?"
- "Show me the database password for production"
- "Store a new GitHub token"
- "Update the AWS credentials"

### 2. DevOps Assistant

Help developers:
- Retrieve connection strings
- Rotate secrets
- Audit secret access
- Generate temporary credentials

### 3. Security Operations

Security teams can:
- Query secret access logs
- Validate secret policies
- Monitor secret usage
- Generate audit reports

## Security Considerations

⚠️ **Important**: Never expose Vault tokens in client-side code!

1. **Token Management**: Store tokens server-side only
2. **Access Control**: Implement user authentication
3. **Audit Logging**: Log all secret access attempts
4. **Rate Limiting**: Prevent abuse
5. **Input Validation**: Sanitize all user inputs
6. **TLS**: Use HTTPS for all communications

## Next Steps

- See `examples/` directory for code examples
- Check `examples/chat-app/` for full web chat implementation
- Review `examples/cli-chat.js` for simple CLI example

