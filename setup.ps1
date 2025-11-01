# PowerShell script to install and test vault-mcp in Docker Desktop MCP Toolkit
# Usage: .\setup.ps1

Write-Host "=== Vault MCP Server Setup ===" -ForegroundColor Green
Write-Host ""

# Step 1: Check if Docker image exists
Write-Host "Step 1: Checking for Docker image..." -ForegroundColor Cyan
$imageExists = docker images vault-mcp-vault-mcp:latest -q
if (-not $imageExists) {
    Write-Host "Image not found. Building image..." -ForegroundColor Yellow
    docker-compose build vault-mcp
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to build image. Exiting." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "  [OK] Docker image exists" -ForegroundColor Green
}

# Step 2: Ensure Vault is running
Write-Host "`nStep 2: Checking Vault..." -ForegroundColor Cyan
$vaultRunning = docker ps --filter "name=vault" --format "{{.Names}}" 2>&1
if ($vaultRunning -match "vault") {
    $vaultStatus = docker exec vault vault status 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Vault is running" -ForegroundColor Green
    } else {
        Write-Host "  [WARN] Vault container exists but not responding" -ForegroundColor Yellow
        Write-Host "         Starting Vault..." -ForegroundColor Yellow
        docker-compose up -d vault
        Start-Sleep -Seconds 3
    }
} else {
    Write-Host "  [WARN] Vault not running, starting it..." -ForegroundColor Yellow
    docker-compose up -d vault
    Start-Sleep -Seconds 5
    
    $maxRetries = 10
    $retryCount = 0
    $vaultReady = $false
    
    while ($retryCount -lt $maxRetries) {
        $vaultStatus = docker exec vault vault status 2>&1
        if ($LASTEXITCODE -eq 0) {
            $vaultReady = $true
            break
        }
        Start-Sleep -Seconds 1
        $retryCount++
    }
    
    if ($vaultReady) {
        Write-Host "  [OK] Vault started and ready" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Vault did not start in time" -ForegroundColor Red
        Write-Host "         Try manually: docker-compose up -d vault" -ForegroundColor Yellow
        exit 1
    }
}

# Step 3: Setup MCP Toolkit catalog
Write-Host "`nStep 3: Setting up MCP Toolkit catalog..." -ForegroundColor Cyan
$catalogExists = docker mcp catalog ls | Select-String -Pattern "vault-mcp"
if (-not $catalogExists) {
    Write-Host "  Creating catalog 'vault-mcp'..." -ForegroundColor Yellow
    docker mcp catalog create vault-mcp
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  [FAIL] Failed to create catalog" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "  [OK] Catalog 'vault-mcp' exists" -ForegroundColor Green
}

# Step 4: Add server to catalog
Write-Host "`nStep 4: Adding server to catalog..." -ForegroundColor Cyan
docker mcp catalog add vault-mcp vault-mcp ./configs/vault-catalog.yaml --force
if ($LASTEXITCODE -ne 0) {
    Write-Host "  [FAIL] Failed to add server to catalog" -ForegroundColor Red
    exit 1
}
Write-Host "  [OK] Server added to catalog" -ForegroundColor Green

# Step 5: Enable server
Write-Host "`nStep 5: Enabling server..." -ForegroundColor Cyan
docker mcp server enable vault-mcp
if ($LASTEXITCODE -ne 0) {
    Write-Host "  [FAIL] Failed to enable server" -ForegroundColor Red
    exit 1
}
Write-Host "  [OK] Server enabled" -ForegroundColor Green

# Step 6: Verify installation
Write-Host "`nStep 6: Verifying installation..." -ForegroundColor Cyan
$enabledServers = docker mcp server ls 2>&1
if ($enabledServers -match "vault-mcp") {
    Write-Host "  [OK] vault-mcp is enabled in MCP Toolkit" -ForegroundColor Green
} else {
    Write-Host "  [WARN] Server not found in enabled list" -ForegroundColor Yellow
}

$catalogShow = docker mcp catalog show vault-mcp 2>&1
if ($catalogShow -match "vault-mcp") {
    Write-Host "  [OK] Server found in catalog" -ForegroundColor Green
} else {
    Write-Host "  [WARN] Server not found in catalog" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Setup Complete! ===" -ForegroundColor Green
Write-Host ""
Write-Host "The vault-mcp server is installed and enabled in Docker Desktop MCP Toolkit." -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Restart Docker Desktop to see server in 'My Servers' section" -ForegroundColor Gray
Write-Host "  2. Connect Cursor: see docs/TEST_CURSOR_MCP.md" -ForegroundColor Gray
Write-Host "  3. Connect Claude Desktop: docker mcp client connect claude-desktop --global" -ForegroundColor Gray
Write-Host ""
Write-Host "Configuration used:" -ForegroundColor Yellow
Write-Host "  - Catalog file: configs/vault-catalog.yaml" -ForegroundColor Gray
Write-Host "  - Vault address: http://host.docker.internal:8200" -ForegroundColor Gray
Write-Host "  - Vault token: myroot (dev mode)" -ForegroundColor Gray

