# vault-mcp

A containerized Model Context Protocol (MCP) server for interacting with HashiCorp Vault. This server provides MCP tools for reading, writing, listing, and deleting secrets in Vault.

<a href="https://glama.ai/mcp/servers/@kelleyblackmore/vault-mcp">
  <img width="380" height="200" src="https://glama.ai/mcp/servers/@kelleyblackmore/vault-mcp/badge" alt="Vault Server MCP server" />
</a>

## Features

- **vault_read**: Read secrets from Vault at a specified path
- **vault_write**: Write secrets to Vault at a specified path
- **vault_list**: List secrets at a specified path in Vault
- **vault_delete**: Delete secrets from Vault at a specified path

## Prerequisites

- Docker and Docker Compose
- HashiCorp Vault instance (can use the included dev server)
- Vault token for authentication

## Quick Start with Docker Compose

The easiest way to get started is using the included `docker-compose.yml` which sets up both Vault (in dev mode) and the MCP server:

```bash
# Build and start services
docker-compose up -d

# Check logs
docker-compose logs -f vault-mcp
```

This will start:
- A Vault dev server at `http://localhost:8200` with root token `myroot`
- The vault-mcp server connected to the Vault instance

## Building the Docker Image

### Using Pre-built Images from GitHub Container Registry

Pre-built container images are automatically published to GitHub Container Registry:

```bash
# Pull the latest image
docker pull ghcr.io/kelleyblackmore/vault-mcp:latest

# Pull a specific version
docker pull ghcr.io/kelleyblackmore/vault-mcp:v1.0.0
```

The images are automatically built for multiple platforms:
- `linux/amd64` (x86_64)
- `linux/arm64` (ARM64/aarch64)

### Building Locally

```bash
docker build -t vault-mcp .
```

## Running the Container

### With Docker Run

```bash
docker run -it \
  -e VAULT_ADDR=http://your-vault:8200 \
  -e VAULT_TOKEN=your-vault-token \
  vault-mcp
```

### With Docker Compose

Edit the `docker-compose.yml` file to configure your Vault connection:

```yaml
environment:
  VAULT_ADDR: http://vault:8200
  VAULT_TOKEN: your-token
```

Then run:

```bash
docker-compose up vault-mcp
```

## Configuration

The server is configured via environment variables:

- `VAULT_ADDR`: The Vault server address (default: `http://127.0.0.1:8200`)
- `VAULT_TOKEN`: The Vault authentication token (required)

## Using with MCP Clients

### Claude Desktop Configuration

Add to your Claude Desktop configuration file:

**macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
**Windows**: `%APPDATA%/Claude/claude_desktop_config.json`

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
        "VAULT_ADDR=http://your-vault:8200",
        "-e",
        "VAULT_TOKEN=your-vault-token",
        "ghcr.io/kelleyblackmore/vault-mcp:latest"
      ]
    }
  }
}
```

> **Note**: 
> - Replace `your-vault:8200` with your Vault server address
> - Replace `your-vault-token` with your Vault authentication token
> 
> **Migrating from local builds**: If you previously built the image locally as `vault-mcp`, you can:
> - Use pre-built images by updating the image name to `ghcr.io/kelleyblackmore/vault-mcp:latest`, or
> - Continue using your local image by keeping the image name as `vault-mcp`

## Available Tools

### vault_read

Read a secret from Vault.

**Parameters:**
- `path` (string, required): The path to read the secret from (e.g., `secret/data/myapp`)

**Example:**
```json
{
  "path": "secret/data/myapp"
}
```

### vault_write

Write a secret to Vault.

**Parameters:**
- `path` (string, required): The path to write the secret to (e.g., `secret/data/myapp`)
- `data` (object, required): The secret data to write as a JSON object

**Example:**
```json
{
  "path": "secret/data/myapp",
  "data": {
    "username": "admin",
    "password": "secret123"
  }
}
```

### vault_list

List secrets at a path in Vault.

**Parameters:**
- `path` (string, required): The path to list secrets from (e.g., `secret/metadata`)

**Example:**
```json
{
  "path": "secret/metadata"
}
```

### vault_delete

Delete a secret from Vault.

**Parameters:**
- `path` (string, required): The path to delete the secret from (e.g., `secret/data/myapp`)

**Example:**
```json
{
  "path": "secret/data/myapp"
}
```

## Development

### Local Development Setup

```bash
# Install dependencies
npm install

# Build the project
npm run build

# Run locally (requires Vault server)
VAULT_ADDR=http://localhost:8200 VAULT_TOKEN=myroot npm start
```

### Project Structure

```
vault-mcp/
├── .github/
│   └── workflows/
│       └── docker-build-publish.yml  # CI/CD workflow for container builds
├── src/
│   └── index.ts          # Main MCP server implementation
├── dist/                 # Compiled JavaScript (generated)
├── Dockerfile           # Container definition
├── docker-compose.yml   # Docker Compose configuration
├── package.json         # Node.js dependencies
├── tsconfig.json        # TypeScript configuration
└── README.md           # This file
```

### CI/CD

The project uses GitHub Actions to automatically build and publish Docker images:

- **On push to main**: Builds and publishes the `latest` tag and a SHA-based tag
- **On pull request**: Builds the image to verify it compiles (does not publish)
- **On version tags** (e.g., `v1.0.0`): Builds and publishes version-specific tags (e.g., `v1.0.0`, `v1.0`, `v1`)

Images are published to GitHub Container Registry at `ghcr.io/kelleyblackmore/vault-mcp`.

## Security Considerations

- Never hardcode Vault tokens in configuration files
- Use appropriate Vault policies to limit MCP server permissions
- For production use, replace the dev Vault server with a properly configured production instance
- Consider using Vault AppRole or Kubernetes auth instead of token-based auth
- Use secrets management tools to inject `VAULT_TOKEN` at runtime

## License

MIT