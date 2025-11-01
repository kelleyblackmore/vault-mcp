# Using vault-mcp with Cursor IDE

This guide shows you how to configure and use the vault-mcp server with Cursor IDE.

## Quick Setup

1. **Run the setup script** (installs to Docker Desktop MCP Toolkit):
   ```bash
   # Windows
   .\setup.ps1
   
   # Or use docker-compose to build the image
   docker-compose build vault-mcp
   ```

2. **Configure Cursor** - Add to your Cursor MCP configuration file:

   **Windows**: `%USERPROFILE%\.cursor\mcp.json`  
   **macOS/Linux**: `~/.cursor/mcp.json`

   ```json
   {
     "mcpServers": {
       "vault": {
         "command": "docker",
         "args": [
           "run",
           "-i",
           "--rm",
           "-e",
           "VAULT_ADDR=http://host.docker.internal:8200",
           "-e",
           "VAULT_TOKEN=myroot",
           "vault-mcp-vault-mcp:latest"
         ]
       }
     }
   }
   ```

3. **Restart Cursor** completely (quit and restart)

## Prerequisites

- Vault running (can use `docker-compose up -d vault`)
- Docker image built: `vault-mcp-vault-mcp:latest`
- Docker Desktop with MCP Toolkit enabled (optional, for Docker Desktop integration)

## Testing in Cursor

### Method 1: Check Cursor MCP Status

1. **Open Cursor Settings:**
   - Press `Ctrl+,` (or `Cmd+,` on Mac)
   - Search for "MCP" or "Model Context Protocol"

2. **Verify Server is Connected:**
   - Look for the "vault" server in the list
   - Status should show "Connected" or "Active"
   - Available tools should be listed:
     - `vault_read`
     - `vault_write`
     - `vault_list`
     - `vault_delete`

### Method 2: Test with Prompts

Ask Cursor to use Vault tools with these example prompts:

**Read a secret:**
```
Use vault_read to read the secret at path secret/data/mcp-test-20251031015831
```

**List secrets:**
```
List all secrets using vault_list at path secret/metadata
```

**Write a secret:**
```
Use vault_write to create a secret at secret/data/cursor-test with data: message="test from cursor", timestamp="now"
```

**Full workflow:**
```
Write a secret to vault at path secret/data/cursor-demo with username=cursor-user and api_key=test-key-123. Then read it back to verify it was stored correctly.
```

### Method 3: Check Docker Containers

When Cursor uses a Vault tool, it starts a Docker container. Verify:

```bash
# See if container is running
docker ps --filter ancestor=vault-mcp-vault-mcp:latest

# View logs
docker logs $(docker ps -q --filter ancestor=vault-mcp-vault-mcp:latest)
```

## Configuration Details

**Current Configuration:**
- **Image**: `vault-mcp-vault-mcp:latest` (built via docker-compose)
- **Vault Address**: `http://host.docker.internal:8200` (connects to Vault on host)
- **Vault Token**: `myroot` (dev mode token)
- **Transport**: stdio (MCP protocol over stdin/stdout)

**File Locations:**
- Windows: `C:\Users\<YourUsername>\.cursor\mcp.json`
- macOS/Linux: `~/.cursor/mcp.json`

## Troubleshooting

### Server Not Appearing in Cursor

1. **Verify configuration file exists and is valid:**
   ```bash
   # Windows
   type %USERPROFILE%\.cursor\mcp.json
   
   # macOS/Linux
   cat ~/.cursor/mcp.json
   ```

2. **Check JSON syntax** - ensure proper formatting

3. **Restart Cursor completely** - quit entirely, don't just close the window

### Connection Errors

1. **Ensure Vault is running:**
   ```bash
   docker ps --filter name=vault
   docker exec vault vault status
   ```

2. **Test Docker image:**
   ```bash
   docker run --rm -e VAULT_ADDR=http://host.docker.internal:8200 -e VAULT_TOKEN=myroot vault-mcp-vault-mcp:latest echo "test"
   ```

3. **Check network connectivity:**
   - `host.docker.internal` should resolve to your host machine
   - On Linux, you may need to use `localhost` or add `--network host`

### Tools Not Working

1. **Check Vault accessibility:**
   ```bash
   docker exec -e VAULT_TOKEN=myroot vault vault kv list secret/
   ```

2. **Verify image exists:**
   ```bash
   docker images vault-mcp-vault-mcp:latest
   ```

3. **Check Cursor console** (`Ctrl+Shift+I` or `Cmd+Option+I`) for MCP errors

## Expected Behavior

When working correctly:
- ✅ Cursor shows "vault" server as connected in MCP settings
- ✅ You can ask Cursor to use Vault tools naturally
- ✅ Cursor responds with actual Vault data
- ✅ Docker container starts automatically when tools are used
- ✅ Container stops automatically after use

## Example Usage

Once configured, you can interact with Vault through natural language in Cursor:

```
User: "What secrets do we have stored in Vault?"
Cursor: [Uses vault_list to query and shows results]

User: "Read the API key from secret/data/myapp"
Cursor: [Uses vault_read to retrieve and display the secret]

User: "Store a new database password for production"
Cursor: [Uses vault_write to create the secret]
```

## Quick Test

```bash
# 1. Ensure everything is set up
docker-compose up -d vault
docker-compose build vault-mcp

# 2. Create a test secret
docker exec -e VAULT_TOKEN=myroot vault vault kv put secret/data/cursor-test message="Hello from Cursor"

# 3. In Cursor, ask:
# "Read the secret at path secret/data/cursor-test using vault_read"

# 4. You should see the secret data in Cursor's response
```

## Success Indicators

- ✅ Cursor mentions using "vault_read", "vault_write", etc. in responses
- ✅ You receive actual data from Vault (not errors)
- ✅ Multiple tools work (read, write, list, delete)
- ✅ Docker containers start and stop automatically
- ✅ No errors in Cursor console
