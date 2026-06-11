<#
.SYNOPSIS
  Lab 01 -- First VM.
  Runs terraform init/apply, verifies the VM is Running, and checks the
  cloud-init marker file inside the VM.
.USAGE
  PowerShell -ExecutionPolicy Bypass -File tests/01-first-vm.ps1
#>
. "$PSScriptRoot/_common.ps1"

$tfDir  = Join-Path $Script:_RepoRoot 'terraform'
$vmName = if ($VM_NAME) { $VM_NAME } else { 'cr465-lab' }

Write-SectionHeader -Title 'Lab 01 -- First VM'

# --- terraform init ---
$initOut = Invoke-LabCmd -ArgumentList @('terraform', 'init', '-input=false', '-upgrade') -WorkingDirectory $tfDir
Assert-Success 'terraform init exits 0' -ExitCode $Script:_LastExitCode

# --- terraform validate ---
$valOut = Invoke-LabCmd -ArgumentList @('terraform', 'validate') -WorkingDirectory $tfDir
Assert-Success 'terraform validate exits 0' -ExitCode $Script:_LastExitCode

# --- terraform apply ---
Write-Host '  Applying Terraform (this may take a few minutes)...'
$applyOut = Invoke-LabCmd -ArgumentList @('terraform', 'apply', '-auto-approve', '-input=false') -WorkingDirectory $tfDir
Assert-Success 'terraform apply exits 0' -ExitCode $Script:_LastExitCode

# --- VM is Running ---
$listOut    = Invoke-LabCmd -ArgumentList @('multipass', 'list') -WorkingDirectory $Script:_RepoRoot
$listJoined = $listOut -join "`n"
# multipass list may exit 1 on some Windows installs even when successful — check output only
Assert-OutputContains "VM '$vmName' appears in multipass list" -Output $listOut -Pattern $vmName
Assert-OutputContains "VM '$vmName' is in Running state" -Output $listOut -Pattern "$vmName\s+Running"

# --- cloud-init marker file inside VM ---
Write-Host '  Checking cloud-init marker file...'
$markerOut = Invoke-LabCmd -ArgumentList @('multipass', 'exec', $vmName, '--', 'cat', '/var/tmp/cr465-lab-ready.txt') -WorkingDirectory $Script:_RepoRoot
Assert-Success 'multipass exec exits 0' -ExitCode $Script:_LastExitCode
Assert-OutputContains 'Marker file contains expected text' -Output $markerOut -Pattern 'lab ready'

Write-SectionFooter -Title 'Lab 01 -- First VM'
Write-LabReport -StepName '01-first-vm'

Invoke-LearnPause `
    -EN 'Your first VM is running. Try: multipass shell cr465-lab' `
    -FR 'Votre premiere VM est en marche. Essayez : multipass shell cr465-lab'

Write-FinalSummary
