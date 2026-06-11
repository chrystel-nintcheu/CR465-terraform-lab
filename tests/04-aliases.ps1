<#
.SYNOPSIS
  Lab 04 -- Aliases.
  Verifies the Terraform-managed multipass alias is registered on the host.
.USAGE
  PowerShell -ExecutionPolicy Bypass -File tests/04-aliases.ps1
#>
. "$PSScriptRoot/_common.ps1"

$vmName   = if ($VM_NAME) { $VM_NAME } else { 'cr465-lab' }
$aliasName = "$vmName-shell"

Write-SectionHeader -Title 'Lab 04 -- Aliases'

# --- VM must be running ---
$listOut    = Invoke-LabCmd -ArgumentList @('multipass', 'list') -WorkingDirectory $Script:_RepoRoot
$listJoined = $listOut -join "`n"
if ($listJoined -notmatch "$vmName\s+Running") {
    Fail "VM '$vmName' must be Running (run 01-first-vm.ps1 first)"
    Write-SectionFooter -Title 'Lab 04 -- Aliases'
    Write-LabReport -StepName '04-aliases'
    Write-FinalSummary
    return
}
Pass "VM '$vmName' is Running"

# --- alias exists in multipass aliases list ---
$aliasOut    = Invoke-LabCmd -ArgumentList @('multipass', 'aliases') -WorkingDirectory $Script:_RepoRoot
$aliasJoined = $aliasOut -join "`n"
Assert-OutputContains "Alias '$aliasName' is registered" -Output $aliasOut -Pattern $aliasName

# --- alias instance is our VM ---
Assert-OutputContains "Alias '$aliasName' points to correct instance" -Output $aliasOut -Pattern "$vmName"

Write-SectionFooter -Title 'Lab 04 -- Aliases'
Write-LabReport -StepName '04-aliases'

Invoke-LearnPause `
    -EN "The alias '$aliasName' lets you run bash in the VM directly. Try it from any directory." `
    -FR "L'alias '$aliasName' permet d'executer bash dans la VM directement."

Write-FinalSummary
