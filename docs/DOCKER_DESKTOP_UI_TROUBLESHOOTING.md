# Docker Desktop MCP Toolkit UI Visibility Issue

## Issue

Your `vault-mcp` server is installed and working via CLI, but it's not appearing in the Docker Desktop MCP Toolkit UI.

## Root Cause

Docker Desktop's MCP Toolkit UI **only displays servers from the official `docker-mcp` catalog**. Custom catalogs are functional via CLI but are not shown in the GUI.

### Verification

Your server IS working:
```powershell
✓ Server is enabled: docker mcp server ls
✓ Catalog exists: docker mcp catalog ls
✓ Server in catalog: docker mcp catalog show vault-mcp
```

## Solutions

### Option 1: Use CLI Commands (Current Status)

Your server works perfectly via CLI:

```powershell
# Enable/disable server
docker mcp server enable vault-mcp
docker mcp server disable vault-mcp

# List enabled servers
docker mcp server ls

# Connect clients
docker mcp client connect claude-desktop --global
```

### Option 2: Check Docker Desktop Settings

1. **Restart Docker Desktop** - Sometimes the UI needs a refresh
   - Quit Docker Desktop completely
   - Restart it
   - Check the MCP Toolkit section again

2. **Verify MCP Toolkit is Enabled**
   - Settings → Beta features → Enable Docker MCP Toolkit
   - Click "Apply & Restart"

3. **Check MCP Toolkit Container**
   - Settings → Extensions → Show Docker Extensions system containers
   - Look for MCP Toolkit containers in the Containers tab

### Option 3: Add to Official Catalog (Advanced)

If you want the server to appear in the UI, you would need to:
1. Submit it to the official Docker MCP catalog (requires publishing to a registry)
2. Or manually add it to the `docker-mcp` catalog (may be overwritten on updates)

### Option 4: Use with MCP Clients Directly

You can use the server directly with MCP clients without needing the UI:

#### Claude Desktop Configuration

Edit: `%APPDATA%\Claude\claude_desktop_config.json`

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

## Current Status Summary

✅ **Server is installed and working**
✅ **Server is enabled in MCP Toolkit**
✅ **Catalog is properly configured**
❌ **Server does not appear in Docker Desktop UI** (expected behavior for custom catalogs)

## Why This Happens

Docker Desktop's MCP Toolkit UI is designed to show:
- Official catalog servers with rich metadata (icons, descriptions, etc.)
- Servers from the `docker-mcp` catalog that have been curated

Custom catalogs are a CLI feature and don't automatically appear in the UI. This is by design to:
- Keep the UI clean and focused on curated servers
- Allow CLI power users to add custom servers
- Maintain separation between official and custom servers

## Verification Commands

Run these to confirm everything is working:

```powershell
# Check server status
docker mcp server ls

# Check catalog
docker mcp catalog show vault-mcp

# Test server (if you have test scripts)
.\test-mcp-simple.ps1
```

## Conclusion

Your server is **fully functional** and ready to use. The lack of UI visibility is expected for custom catalogs and doesn't affect functionality. You can:

1. Continue using CLI commands to manage it
2. Connect MCP clients directly (Claude Desktop, etc.)
3. Use it programmatically via the MCP protocol

The server will work exactly the same whether it appears in the UI or not!

