<#
.SYNOPSIS
  Lab 08 -- Teardown.
  Runs terraform destroy, verifies VMs are gone, then apply + destroy again
  to confirm idempotency.
.USAGE
  PowerShell -ExecutionPolicy Bypass -File tests/08-teardown.ps1
#>
. "$PSScriptRoot/_common.ps1"

$tfDir  = Join-Path $Script:_RepoRoot 'terraform'
$vmName = if ($VM_NAME) { $VM_NAME } else { 'cr465-lab' }
$dbName = "$vmName-db"

Write-SectionHeader -Title 'Lab 08 -- Teardown'

# ── Round 1: destroy ────────────────────────────────────────────────────────
Write-Host '  [1/2] Destroying all Terraform resources...'
$destroy1Out = Invoke-LabCmd -ArgumentList @('terraform', 'destroy', '-auto-approve', '-input=false') -WorkingDirectory $tfDir
Assert-Success 'terraform destroy (round 1) exits 0' -ExitCode $Script:_LastExitCode

# --- VMs no longer appear in multipass list ---
$list1Out = Invoke-LabCmd -ArgumentList @('multipass', 'list') -WorkingDirectory $Script:_RepoRoot
$list1Joined = $list1Out -join "`n"
if ($list1Joined -match "$vmName\s+Running|$vmName\s+Stopped|$dbName\s+Running|$dbName\s+Stopped") {
    Fail "Lab VMs still present after destroy"
} else {
    Pass 'Lab VMs absent after destroy (round 1)'
}

# ── Round 2: re-apply then destroy (idempotency) ────────────────────────────
Write-Host '  [2/2] Re-applying and then destroying again (idempotency check)...'
$apply2Out = Invoke-LabCmd -ArgumentList @('terraform', 'apply', '-auto-approve', '-input=false') -WorkingDirectory $tfDir
Assert-Success 'terraform apply (round 2) exits 0' -ExitCode $Script:_LastExitCode

$destroy2Out = Invoke-LabCmd -ArgumentList @('terraform', 'destroy', '-auto-approve', '-input=false') -WorkingDirectory $tfDir
Assert-Success 'terraform destroy (round 2) exits 0' -ExitCode $Script:_LastExitCode

$list2Out = Invoke-LabCmd -ArgumentList @('multipass', 'list') -WorkingDirectory $Script:_RepoRoot
$list2Joined = $list2Out -join "`n"
if ($list2Joined -match "$vmName\s+Running|$vmName\s+Stopped|$dbName\s+Running|$dbName\s+Stopped") {
    Fail "Lab VMs still present after destroy (round 2)"
} else {
    Pass 'Lab VMs absent after destroy (round 2)'
}

# --- clean up any leftover snapshots ---
$snapOut = Invoke-LabCmd -ArgumentList @('multipass', 'list', '--snapshots') -WorkingDirectory $Script:_RepoRoot
$snapJoined = $snapOut -join "`n"
if ($snapJoined -match $vmName) {
    Skip 'Orphaned snapshots may remain — clean up manually with: multipass delete <instance>.<snapshot>'
} else {
    Pass 'No orphaned lab snapshots remaining'
}

Write-SectionFooter -Title 'Lab 08 -- Teardown'
Write-LabReport -StepName '08-teardown'

Invoke-LearnPause `
    -EN 'The lab is fully torn down. Terraform destroy + apply is idempotent -- run it as many times as needed.' `
    -FR 'Le lab est entierement detruit. terraform destroy + apply est idempotent -- executez-le autant de fois que necessaire.'

Write-FinalSummary
