<#
.SYNOPSIS
  Lab 02 -- Cloud-init.
  Verifies that cloud-init ran correctly inside the running VM.
  Requires Lab 01 (VM must already be Running).
.USAGE
  PowerShell -ExecutionPolicy Bypass -File tests/02-cloud-init.ps1
#>
. "$PSScriptRoot/_common.ps1"

$vmName = if ($VM_NAME) { $VM_NAME } else { 'cr465-lab' }

Write-SectionHeader -Title 'Lab 02 -- Cloud-init'

# --- dependency: VM must be running ---
$listOut  = Invoke-LabCmd -ArgumentList @('multipass', 'list') -WorkingDirectory $Script:_RepoRoot
$listJoined = $listOut -join "`n"
if ($listJoined -notmatch "$vmName\s+Running") {
    Fail "VM '$vmName' must be Running (run 01-first-vm.ps1 first)"
    Write-SectionFooter -Title 'Lab 02 -- Cloud-init'
    Write-LabReport -StepName '02-cloud-init'
    Write-FinalSummary
    return
}
Pass "VM '$vmName' is Running"

# --- git installed ---
$gitOut = Invoke-LabCmd -ArgumentList @('multipass', 'exec', $vmName, '--', 'which', 'git') -WorkingDirectory $Script:_RepoRoot
Assert-Success 'git installed in VM' -ExitCode $Script:_LastExitCode
Assert-OutputNotEmpty 'which git returns a path' -Output $gitOut

# --- curl installed ---
$curlOut = Invoke-LabCmd -ArgumentList @('multipass', 'exec', $vmName, '--', 'which', 'curl') -WorkingDirectory $Script:_RepoRoot
Assert-Success 'curl installed in VM' -ExitCode $Script:_LastExitCode
Assert-OutputNotEmpty 'which curl returns a path' -Output $curlOut

# --- marker file present ---
$markerOut = Invoke-LabCmd -ArgumentList @('multipass', 'exec', $vmName, '--', 'cat', '/var/tmp/cr465-lab-ready.txt') -WorkingDirectory $Script:_RepoRoot
Assert-Success 'marker file exists in VM' -ExitCode $Script:_LastExitCode
Assert-OutputContains 'Marker file contains expected text' -Output $markerOut -Pattern 'lab ready'

# --- /etc/cr465-lab.txt contains hostname ---
$labTxtOut = Invoke-LabCmd -ArgumentList @('multipass', 'exec', $vmName, '--', 'cat', '/etc/cr465-lab.txt') -WorkingDirectory $Script:_RepoRoot
Assert-Success '/etc/cr465-lab.txt exists' -ExitCode $Script:_LastExitCode
Assert-OutputContains '/etc/cr465-lab.txt contains hostname' -Output $labTxtOut -Pattern "Hostname\s*:\s*$vmName"
Assert-OutputContains '/etc/cr465-lab.txt mentions lab stage' -Output $labTxtOut -Pattern 'Lab stage'

Write-SectionFooter -Title 'Lab 02 -- Cloud-init'
Write-LabReport -StepName '02-cloud-init'

Invoke-LearnPause `
    -EN 'Cloud-init provisioned the VM automatically. Inspect /etc/cr465-lab.txt inside the VM.' `
    -FR 'Cloud-init a provisionne la VM automatiquement. Inspectez /etc/cr465-lab.txt a l interieur de la VM.'

Write-FinalSummary
