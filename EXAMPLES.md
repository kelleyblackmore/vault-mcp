# Vault MCP Examples

This document provides examples of using the vault-mcp server with various MCP clients.

## Prerequisites

Make sure the Vault dev server and vault-mcp server are running:

```bash
docker compose up -d
```

## Example 1: Writing a Secret

Use the `vault_write` tool to store a secret:

**Input:**
```json
{
  "name": "vault_write",
  "arguments": {
    "path": "secret/data/myapp",
    "data": {
      "api_key": "sk-1234567890",
      "database_url": "postgresql://localhost:5432/mydb"
    }
  }
}
```

**Expected Output:**
```json
{
  "request_id": "...",
  "lease_id": "",
  "renewable": false,
  "lease_duration": 0,
  "data": {
    "created_time": "2025-10-31T00:00:00Z",
    "custom_metadata": null,
    "deletion_time": "",
    "destroyed": false,
    "version": 1
  }
}
```

## Example 2: Reading a Secret

Use the `vault_read` tool to retrieve a secret:

**Input:**
```json
{
  "name": "vault_read",
  "arguments": {
    "path": "secret/data/myapp"
  }
}
```

**Expected Output:**
```json
{
  "data": {
    "api_key": "sk-1234567890",
    "database_url": "postgresql://localhost:5432/mydb"
  },
  "metadata": {
    "created_time": "2025-10-31T00:00:00Z",
    "version": 1
  }
}
```

## Example 3: Listing Secrets

Use the `vault_list` tool to list secrets at a path:

**Input:**
```json
{
  "name": "vault_list",
  "arguments": {
    "path": "secret/metadata"
  }
}
```

**Expected Output:**
```json
{
  "keys": [
    "myapp",
    "test-app"
  ]
}
```

## Example 4: Deleting a Secret

Use the `vault_delete` tool to delete a secret:

**Input:**
```json
{
  "name": "vault_delete",
  "arguments": {
    "path": "secret/data/myapp"
  }
}
```

**Expected Output:**
```
Successfully deleted secret at path: secret/data/myapp
```

## Using with Claude Desktop

1. Build the Docker image:
   ```bash
   docker build -t vault-mcp .
   ```

2. Add the following to your Claude Desktop configuration file:
   - **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
   - **Windows**: `%APPDATA%/Claude/claude_desktop_config.json`

   ```json
   {
     "mcpServers": {
       "vault": {
         "command": "docker",
         "args": [
           "run",
           "-i",
           "--rm",
           "--network",
           "host",
           "-e",
           "VAULT_ADDR=http://localhost:8200",
           "-e",
           "VAULT_TOKEN=your-vault-token",
           "vault-mcp"
         ]
       }
     }
   }
   ```

3. Restart Claude Desktop

4. You can now ask Claude to interact with your Vault instance. For example:
   - "Read the secret at path secret/data/myapp"
   - "Write a new API key to secret/data/production"
   - "List all secrets in the secret store"

## Command Line Testing

You can also test the MCP server directly using stdio:

```bash
# Start the server
docker run -i --rm \
  -e VAULT_ADDR=http://host.docker.internal:8200 \
  -e VAULT_TOKEN=myroot \
  vault-mcp

# In another terminal, send MCP requests via stdin
# (This requires implementing the MCP JSON-RPC protocol)
```

## Production Considerations

1. **Never use dev mode Vault in production**
   - Configure a proper Vault server with TLS
   - Use appropriate authentication methods (AppRole, Kubernetes auth, etc.)

2. **Secure token management**
   - Don't hardcode tokens in configuration files
   - Use environment variables or secrets management
   - Rotate tokens regularly

3. **Network security**
   - Use TLS for Vault communication
   - Implement proper firewall rules
   - Consider using Vault namespaces for multi-tenancy

4. **Access control**
   - Create specific Vault policies for the MCP server
   - Follow the principle of least privilege
   - Audit access logs regularly
