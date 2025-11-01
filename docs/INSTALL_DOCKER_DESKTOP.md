# Installing vault-mcp into Docker Desktop MCP Toolkit

This guide explains how to install the vault-mcp server into Docker Desktop's MCP Toolkit catalog.

## Prerequisites

1. Docker Desktop 4.42.0 or later
2. MCP Toolkit enabled in Docker Desktop (Settings > Beta features > Enable Docker MCP Toolkit)
3. Docker image built: `vault-mcp-vault-mcp:latest`

## Installation Steps

### Step 1: Build the Docker Image

First, ensure your Docker image is built. You can use either:

**Option A: Using Docker Compose** (builds both Vault and vault-mcp):
```powershell
docker-compose build
```

**Option B: Using Docker directly**:
```powershell
docker build -t vault-mcp-vault-mcp:latest .
```

### Step 2: Create the Catalog

Create an empty catalog:
```powershell
docker mcp catalog create vault-mcp
```

### Step 3: Add the Server to the Catalog

Add the server definition to your catalog:
```powershell
docker mcp catalog add vault-mcp vault-mcp ./vault-catalog.yaml
```

### Step 4: Enable the Server

Enable the server in the MCP Toolkit:
```powershell
docker mcp server enable vault-mcp
```

### Step 5: Verify Installation

Check that the server is enabled:
```powershell
docker mcp server ls
```

You should see `vault-mcp` in the list.

## Configuration

The server is configured with:
- `VAULT_ADDR`: `http://host.docker.internal:8200` (connects to Vault on your host)
- `VAULT_TOKEN`: `myroot` (default dev token)

To change these values, edit `vault-catalog.yaml` before adding it to the catalog, or update the server configuration in Docker Desktop.

## Troubleshooting

### Server not found in catalog
- Make sure you've created the catalog: `docker mcp catalog create vault-mcp`
- Verify the server was added: `docker mcp catalog show vault-mcp`

### Image not found
- Ensure the image is built: `docker images vault-mcp-vault-mcp`
- If using docker-compose, the image name will be `vault-mcp-vault-mcp:latest`

### Connection issues
- Ensure Vault is running (if using docker-compose: `docker-compose up -d vault`)
- Check that `VAULT_ADDR` in the catalog matches your Vault instance
- Verify the network configuration if using docker-compose networks

## Alternative: Using docker-compose network

If you want the MCP server to use the docker-compose network (so it can access Vault via service name), use `source-catalog.yaml` instead:

```powershell
docker mcp catalog add vault-mcp vault-mcp ./source-catalog.yaml
```

This configuration uses:
- `VAULT_ADDR`: `http://vault:8200` (connects to Vault service in docker-compose)
- Docker network: `vault-mcp_default`

Note: For this to work, both containers must be running in the same Docker network.

