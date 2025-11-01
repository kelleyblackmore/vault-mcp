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
- Docker Desktop 4.42.0+ with MCP Toolkit enabled (for Docker Desktop integration)
- HashiCorp Vault instance (can use the included dev server)
- Vault token for authentication

## Quick Start

### Option 1: Docker Desktop MCP Toolkit (Recommended)

Run the setup script to install and configure the server:

**Windows (PowerShell):**
```powershell
.\setup.ps1
```

**macOS/Linux (Bash):**
```bash
./setup.sh
```

**What the setup script does:**
- Builds the Docker image if needed
- Starts Vault dev server
- Creates the MCP catalog in Docker Desktop
- Adds and enables the vault-mcp server

**Configuration used:**
- Catalog file: `configs/vault-catalog.yaml`
- Vault address: `http://host.docker.internal:8200`
- Vault token: `myroot` (dev mode)

After running the setup script, restart Docker Desktop to see the server in the "My Servers" section.

See `docs/INSTALL_DOCKER_DESKTOP.md` for detailed installation instructions.

### Option 2: Docker Compose

Start both Vault and the MCP server:

```bash
# Build and start services
docker-compose up -d

# Check logs
docker-compose logs -f vault-mcp
```

This will start:
- A Vault dev server at `http://localhost:8200` with root token `myroot`
- The vault-mcp server connected to the Vault instance

## MCP Client Setup

### Cursor IDE

**Step 1: Copy the configuration**

Copy `configs/mcp_config.json` to your Cursor MCP configuration file:

**Windows:**
```powershell
# Create directory if it doesn't exist
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.cursor"

# Copy the config file
Copy-Item -Path "configs\mcp_config.json" -Destination "$env:USERPROFILE\.cursor\mcp.json"
```

**macOS/Linux:**
```bash
# Create directory if it doesn't exist
mkdir -p ~/.cursor

# Copy the config file
cp configs/mcp_config.json ~/.cursor/mcp.json
```

**Step 2: Update the configuration** (if needed)

Edit `~/.cursor/mcp.json` (or `%USERPROFILE%\.cursor\mcp.json` on Windows) and update:
- `VAULT_ADDR`: Your Vault server address
- `VAULT_TOKEN`: Your Vault token
- Image name: Use `vault-mcp-vault-mcp:latest` if built locally

**Step 3: Restart Cursor**

Completely quit and restart Cursor for the changes to take effect.

**Step 4: Test**

In Cursor, try asking:
```
Use vault_read to read the secret at path secret/data/test
```

See `docs/TEST_CURSOR_MCP.md` for more testing instructions.

### Claude Desktop

Copy the configuration from `configs/mcp_config.json` to your Claude Desktop configuration:

**Windows:**
```powershell
# Location: %APPDATA%\Claude\claude_desktop_config.json
Copy-Item -Path "configs\mcp_config.json" -Destination "$env:APPDATA\Claude\claude_desktop_config.json"
```

**macOS:**
```bash
# Location: ~/Library/Application Support/Claude/claude_desktop_config.json
cp configs/mcp_config.json ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

**Linux:**
```bash
# Location: ~/.config/claude-desktop/claude_desktop_config.json
cp configs/mcp_config.json ~/.config/claude-desktop/claude_desktop_config.json
```

Then restart Claude Desktop.

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
docker-compose build vault-mcp
# Or
docker build -t vault-mcp-vault-mcp:latest .
```

## Running the Container

### With Docker Run

```bash
docker run -it --rm \
  -e VAULT_ADDR=http://host.docker.internal:8200 \
  -e VAULT_TOKEN=myroot \
  vault-mcp-vault-mcp:latest
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

Configuration files are located in the `configs/` directory:
- `configs/vault-catalog.yaml` - Docker Desktop MCP Toolkit catalog configuration
- `configs/mcp_config.json` - MCP client configuration (Cursor, Claude Desktop)

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
├── configs/              # MCP configuration files
│   ├── mcp_config.json   # MCP client configuration (Cursor, Claude Desktop)
│   └── vault-catalog.yaml # Docker Desktop MCP Toolkit catalog
├── docs/                 # Documentation files
├── src/
│   └── index.ts          # Main MCP server implementation
├── dist/                 # Compiled JavaScript (generated)
├── Dockerfile           # Container definition
├── docker-compose.yml   # Docker Compose configuration
├── package.json         # Node.js dependencies
├── setup.ps1            # Setup script for Windows (PowerShell)
├── setup.sh             # Setup script for macOS/Linux (Bash)
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