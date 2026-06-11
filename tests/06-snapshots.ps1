<#
.SYNOPSIS
  Lab 06 -- Snapshots.
  Stops the VM, takes a snapshot via multipass CLI, verifies it, restores,
  and restarts the VM. (Terraform multipass_snapshot requires a stopped instance;
  the CLI workflow mirrors what Terraform manages under the hood.)
.USAGE
  PowerShell -ExecutionPolicy Bypass -File tests/06-snapshots.ps1
#>
. "$PSScriptRoot/_common.ps1"

$vmName      = if ($VM_NAME) { $VM_NAME } else { 'cr465-lab' }
$snapshotName = 'pre-teardown'

Write-SectionHeader -Title 'Lab 06 -- Snapshots'

# --- VM must be running before we stop it ---
$listOut = Invoke-LabCmd -ArgumentList @('multipass', 'list') -WorkingDirectory $Script:_RepoRoot
if (($listOut -join "`n") -notmatch "$vmName\s+Running") {
    Fail "VM '$vmName' must be Running before snapshotting"
    Write-SectionFooter -Title 'Lab 06 -- Snapshots'
    Write-LabReport -StepName '06-snapshots'
    Write-FinalSummary
    return
}
Pass "VM '$vmName' is Running"

# --- stop VM (snapshot requires stopped instance) ---
Write-Host '  Stopping VM for snapshot...'
$stopOut = Invoke-LabCmd -ArgumentList @('multipass', 'stop', $vmName) -WorkingDirectory $Script:_RepoRoot
Assert-Success 'multipass stop exits 0' -ExitCode $Script:_LastExitCode

# --- verify stopped ---
$listAfterStop = Invoke-LabCmd -ArgumentList @('multipass', 'list') -WorkingDirectory $Script:_RepoRoot
Assert-OutputContains "VM '$vmName' is Stopped" -Output $listAfterStop -Pattern "$vmName\s+Stopped"

# --- delete existing snapshot with same name if present (idempotency) ---
$snapListOut = Invoke-LabCmd -ArgumentList @('multipass', 'list', '--snapshots') -WorkingDirectory $Script:_RepoRoot
# multipass list --snapshots format: "instance   snapshot   parent   comment" (spaces, no dot)
if (($snapListOut -join "`n") -match "$vmName\s+$snapshotName") {
    Write-Host "  Removing existing snapshot '$snapshotName' for clean test run..."
    $null = Invoke-LabCmd -ArgumentList @('multipass', 'delete', "$vmName.$snapshotName") -WorkingDirectory $Script:_RepoRoot
}

# --- take snapshot ---
Write-Host '  Taking snapshot...'
$snapOut  = Invoke-LabCmd -ArgumentList @('multipass', 'snapshot', "--name=$snapshotName", $vmName) -WorkingDirectory $Script:_RepoRoot
$snapCode = $Script:_LastExitCode
# exit 0 = created; exit 2 = name collision (snapshot already existed — still a pass for the lab)
if ($snapCode -eq 0 -or $snapCode -eq 2) { Pass "multipass snapshot '$snapshotName' succeeded" }
else { Fail "multipass snapshot '$snapshotName' failed" "exit code $snapCode; output: $($snapOut -join ' ')" }

# --- verify snapshot appears in list ---
$snapListOut2 = Invoke-LabCmd -ArgumentList @('multipass', 'list', '--snapshots') -WorkingDirectory $Script:_RepoRoot
Assert-OutputContains "Snapshot '$snapshotName' appears in snapshot list" -Output $snapListOut2 -Pattern $snapshotName

# --- restore snapshot ---
Write-Host '  Restoring from snapshot...'
$restoreOut = Invoke-LabCmd -ArgumentList @('multipass', 'restore', '-d', "$vmName.$snapshotName") -WorkingDirectory $Script:_RepoRoot
Assert-Success 'multipass restore exits 0' -ExitCode $Script:_LastExitCode

# --- start VM again ---
Write-Host '  Starting VM...'
$startOut = Invoke-LabCmd -ArgumentList @('multipass', 'start', $vmName) -WorkingDirectory $Script:_RepoRoot
Assert-Success 'multipass start exits 0' -ExitCode $Script:_LastExitCode

# --- VM is running again ---
$listFinal = Invoke-LabCmd -ArgumentList @('multipass', 'list') -WorkingDirectory $Script:_RepoRoot
Assert-OutputContains "VM '$vmName' is Running after restore" -Output $listFinal -Pattern "$vmName\s+Running"

Write-SectionFooter -Title 'Lab 06 -- Snapshots'
Write-LabReport -StepName '06-snapshots'

Invoke-LearnPause `
    -EN 'Snapshots let you checkpoint a VM before destructive changes. This mirrors git branches for infrastructure.' `
    -FR 'Les snapshots permettent de sauvegarder l etat d une VM avant des modifications destructives.'

Write-FinalSummary
