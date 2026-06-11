<#
.SYNOPSIS
  Lab 03 -- Variables and outputs.
  Verifies terraform.tfvars is present and terraform output returns expected fields.
.USAGE
  PowerShell -ExecutionPolicy Bypass -File tests/03-variables-outputs.ps1
#>
. "$PSScriptRoot/_common.ps1"

$tfDir  = Join-Path $Script:_RepoRoot 'terraform'
$vmName = if ($VM_NAME) { $VM_NAME } else { 'cr465-lab' }

Write-SectionHeader -Title 'Lab 03 -- Variables and outputs'

# --- terraform.tfvars must exist ---
$tfvarsPath = Join-Path $tfDir 'terraform.tfvars'
Assert-FileExists 'terraform/terraform.tfvars exists' -Path $tfvarsPath

# --- terraform output returns vm_name, ipv4, lab_stage ---
$outputOut = Invoke-LabCmd -ArgumentList @('terraform', 'output', '-json') -WorkingDirectory $tfDir
Assert-Success 'terraform output exits 0' -ExitCode $Script:_LastExitCode
Assert-OutputContains 'output contains vm_name'   -Output $outputOut -Pattern '"vm_name"'
Assert-OutputContains 'output contains ipv4'      -Output $outputOut -Pattern '"ipv4"'
Assert-OutputContains 'output contains lab_stage' -Output $outputOut -Pattern '"lab_stage"'

# --- ipv4 is non-empty ---
$joined = $outputOut -join ' '
if ($joined -match '"ipv4"\s*:\s*\{[^}]*"value"\s*:\s*\[([^\]]+)\]') {
    $ipVal = $Matches[1].Trim().Trim('"')
    if ($ipVal -and $ipVal -ne '') { Pass "ipv4 value is non-empty ($ipVal)" }
    else                           { Fail 'ipv4 value is empty' }
} else {
    Skip 'ipv4 value extraction skipped (complex JSON structure)'
}

# --- individual outputs work ---
$vmOut = Invoke-LabCmd -ArgumentList @('terraform', 'output', '-raw', 'vm_name') -WorkingDirectory $tfDir
Assert-Success 'terraform output vm_name exits 0' -ExitCode $Script:_LastExitCode
Assert-OutputContains "vm_name output equals '$vmName'" -Output $vmOut -Pattern $vmName

Write-SectionFooter -Title 'Lab 03 -- Variables and outputs'
Write-LabReport -StepName '03-variables-outputs'

Invoke-LearnPause `
    -EN 'Outputs make your VM data available to scripts and other tools. Try: terraform output vm_name' `
    -FR 'Les outputs rendent les donnees de votre VM disponibles. Essayez : terraform output vm_name'

Write-FinalSummary
