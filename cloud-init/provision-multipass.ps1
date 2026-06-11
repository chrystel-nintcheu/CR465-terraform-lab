<#
.SYNOPSIS
  Standalone Multipass VM provisioner using cloud-init (no Terraform).
  Reads shared settings from config.ps1 at the repository root.
.USAGE
  pwsh cloud-init/provision-multipass.ps1
  pwsh cloud-init/provision-multipass.ps1 -Force
#>
param(
    [switch]$Force
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Locate repo root relative to this script
$repoRoot  = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$configPs1 = Join-Path $repoRoot 'config.ps1'

if (-not (Test-Path $configPs1)) {
    throw "config.ps1 not found at: $configPs1"
}
. $configPs1

$cloudInitFile = Join-Path $PSScriptRoot 'user-data-fresh.yaml'
$instanceName  = 'cr465-fresh'

# Remove existing instance if -Force
if ($Force) {
    Write-Host "[-] Purging existing '$instanceName' instance..."
    multipass delete $instanceName 2>$null
    multipass purge
}

# Check whether already running
$existing = multipass list 2>&1 | Select-String $instanceName
if ($existing) {
    Write-Host "[!] Instance '$instanceName' already exists. Use -Force to recreate."
    exit 0
}

Write-Host "[+] Launching '$instanceName' with cloud-init..."
multipass launch `
    --name   $instanceName `
    --cpus   $CPUS `
    --memory $MEMORY `
    --disk   $DISK `
    --cloud-init $cloudInitFile `
    $IMAGE

if ($LASTEXITCODE -ne 0) { throw "multipass launch failed (exit $LASTEXITCODE)." }

Write-Host "[+] Waiting for cloud-init to finish..."
$deadline = (Get-Date).AddSeconds($TIMEOUT_APPLY)
do {
    Start-Sleep -Seconds 5
    $result = multipass exec $instanceName -- cat /var/tmp/cr465-lab-ready.txt 2>&1
} until ($result -match 'standalone lab ready' -or (Get-Date) -gt $deadline)

if ($result -notmatch 'standalone lab ready') {
    throw "Timed out waiting for cloud-init marker file."
}

Write-Host "[✓] '$instanceName' is ready."
Write-Host "    $result"
Write-Host ""
Write-Host "To clean up:  multipass delete --purge $instanceName"
