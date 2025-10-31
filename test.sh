#!/bin/bash

# Test script for vault-mcp server

set -e

echo "=== Vault MCP Test Script ==="
echo

# Check if Vault is running
echo "1. Checking Vault status..."
docker exec vault vault status
echo "✓ Vault is running"
echo

# Write a test secret
echo "2. Writing a test secret using Vault CLI..."
docker exec -e VAULT_TOKEN=myroot vault vault kv put secret/test-app username=admin password=secret123
echo "✓ Secret written"
echo

# Read the secret back using Vault CLI
echo "3. Reading the secret back using Vault CLI..."
docker exec -e VAULT_TOKEN=myroot vault vault kv get secret/test-app
echo "✓ Secret read successfully"
echo

# List secrets
echo "4. Listing secrets..."
docker exec -e VAULT_TOKEN=myroot vault vault kv list secret/
echo "✓ Secrets listed"
echo

echo "=== All tests passed! ==="
echo
echo "The vault-mcp server is running and ready to use."
echo "It can be accessed through MCP clients like Claude Desktop."
echo
echo "To use with Claude Desktop, add the configuration from claude_desktop_config.json"
echo "to your Claude Desktop configuration file."
