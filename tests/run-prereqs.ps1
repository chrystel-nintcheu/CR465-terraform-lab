<#
.SYNOPSIS
  Repository-structure gate: runs validate-contract.ps1 and
  validate-tutorial-order.ps1 as a blocking prerequisite check.
  Exits non-zero if either validator fails.
.USAGE
  PowerShell -File tests/run-prereqs.ps1
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot   = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$contractV  = Join-Path $PSScriptRoot 'validate-contract.ps1'
$tutorialV  = Join-Path $PSScriptRoot 'validate-tutorial-order.ps1'

Write-Host ''
Write-Host '== Repository prerequisites =='

$failed = $false

# --- validate-contract.ps1 ---
Write-Host ''
Write-Host '[1/2] Running validate-contract.ps1 ...'
try {
    & $contractV
    $ec = if (Test-Path Variable:\LASTEXITCODE) { $LASTEXITCODE } else { 0 }
    if ($ec -ne 0) { throw "validate-contract.ps1 exited $ec" }
    Write-Host '      [PASS] validate-contract.ps1' -ForegroundColor Green
} catch {
    Write-Host "      [FAIL] validate-contract.ps1: $_" -ForegroundColor Red
    $failed = $true
}

# --- validate-tutorial-order.ps1 ---
Write-Host ''
Write-Host '[2/2] Running validate-tutorial-order.ps1 ...'
try {
    & $tutorialV
    $ec = if (Test-Path Variable:\LASTEXITCODE) { $LASTEXITCODE } else { 0 }
    if ($ec -ne 0) { throw "validate-tutorial-order.ps1 exited $ec" }
    Write-Host '      [PASS] validate-tutorial-order.ps1' -ForegroundColor Green
} catch {
    Write-Host "      [FAIL] validate-tutorial-order.ps1: $_" -ForegroundColor Red
    $failed = $true
}

Write-Host ''
if ($failed) {
    Write-Host '[FAIL] Repository prerequisites NOT met. Fix the issues above before running the lab.' -ForegroundColor Red
    exit 1
} else {
    Write-Host '[PASS] Repository prerequisites met.' -ForegroundColor Green
    exit 0
}
