#!/bin/bash
# Bash script to install and test vault-mcp in Docker Desktop MCP Toolkit
# Usage: ./setup.sh

set -e

echo "=== Vault MCP Server Setup ==="
echo ""

# Step 1: Check if Docker image exists
echo "Step 1: Checking for Docker image..."
if ! docker images vault-mcp-vault-mcp:latest -q | grep -q .; then
    echo "Image not found. Building image..."
    docker-compose build vault-mcp
    if [ $? -ne 0 ]; then
        echo "Failed to build image. Exiting."
        exit 1
    fi
else
    echo "  [OK] Docker image exists"
fi

# Step 2: Ensure Vault is running
echo ""
echo "Step 2: Checking Vault..."
VAULT_RUNNING=$(docker ps --filter "name=vault" --format "{{.Names}}" 2>/dev/null)
if echo "$VAULT_RUNNING" | grep -q "vault"; then
    if docker exec vault vault status >/dev/null 2>&1; then
        echo "  [OK] Vault is running"
    else
        echo "  [WARN] Vault container exists but not responding"
        echo "         Starting Vault..."
        docker-compose up -d vault
        sleep 3
    fi
else
    echo "  [WARN] Vault not running, starting it..."
    docker-compose up -d vault
    sleep 5
    
    # Wait for Vault to be healthy
    MAX_RETRIES=10
    RETRY_COUNT=0
    VAULT_READY=false
    
    while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
        if docker exec vault vault status >/dev/null 2>&1; then
            VAULT_READY=true
            break
        fi
        sleep 1
        RETRY_COUNT=$((RETRY_COUNT + 1))
    done
    
    if [ "$VAULT_READY" = true ]; then
        echo "  [OK] Vault started and ready"
    else
        echo "  [FAIL] Vault did not start in time"
        echo "         Try manually: docker-compose up -d vault"
        exit 1
    fi
fi

# Step 3: Setup MCP Toolkit catalog
echo ""
echo "Step 3: Setting up MCP Toolkit catalog..."
if ! docker mcp catalog ls 2>/dev/null | grep -q "vault-mcp"; then
    echo "  Creating catalog 'vault-mcp'..."
    docker mcp catalog create vault-mcp
    if [ $? -ne 0 ]; then
        echo "  [FAIL] Failed to create catalog"
        exit 1
    fi
else
    echo "  [OK] Catalog 'vault-mcp' exists"
fi

# Step 4: Add server to catalog
echo ""
echo "Step 4: Adding server to catalog..."
docker mcp catalog add vault-mcp vault-mcp ./configs/vault-catalog.yaml --force
if [ $? -ne 0 ]; then
    echo "  [FAIL] Failed to add server to catalog"
    exit 1
fi
echo "  [OK] Server added to catalog"

# Step 5: Enable server
echo ""
echo "Step 5: Enabling server..."
docker mcp server enable vault-mcp
if [ $? -ne 0 ]; then
    echo "  [FAIL] Failed to enable server"
    exit 1
fi
echo "  [OK] Server enabled"

# Step 6: Verify installation
echo ""
echo "Step 6: Verifying installation..."
ENABLED_SERVERS=$(docker mcp server ls 2>&1)
if echo "$ENABLED_SERVERS" | grep -q "vault-mcp"; then
    echo "  [OK] vault-mcp is enabled in MCP Toolkit"
else
    echo "  [WARN] Server not found in enabled list"
fi

CATALOG_SHOW=$(docker mcp catalog show vault-mcp 2>&1)
if echo "$CATALOG_SHOW" | grep -q "vault-mcp"; then
    echo "  [OK] Server found in catalog"
else
    echo "  [WARN] Server not found in catalog"
fi

echo ""
echo "=== Setup Complete! ==="
echo ""
echo "The vault-mcp server is installed and enabled in Docker Desktop MCP Toolkit."
echo ""
echo "Next steps:"
echo "  1. Restart Docker Desktop to see server in 'My Servers' section"
echo "  2. Connect Cursor: see docs/TEST_CURSOR_MCP.md"
echo "  3. Connect Claude Desktop: docker mcp client connect claude-desktop --global"
echo ""
echo "Configuration used:"
echo "  - Catalog file: configs/vault-catalog.yaml"
echo "  - Vault address: http://host.docker.internal:8200"
echo "  - Vault token: myroot (dev mode)"

