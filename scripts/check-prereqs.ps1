param(
  [switch]$Quiet
)

. "$PSScriptRoot/common.ps1"

if (-not $Quiet) {
  Write-LabHeader -Title 'Prerequisite check'
}

$required = @('terraform', 'multipass')
$missing = @()

foreach ($tool in $required) {
  if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
    $missing += $tool
  }
}

if ($missing.Count -gt 0) {
  throw "Missing tools: $($missing -join ', ')"
}

if (-not $Quiet) {
  Write-Host 'Terraform and Multipass are available.'
}
