<#
.SYNOPSIS
  Lab 07 -- Multi-VM.
  Applies the second Terraform instance (cr465-lab-db), verifies both VMs
  are Running, and checks Terraform outputs for both IPs.
.USAGE
  PowerShell -ExecutionPolicy Bypass -File tests/07-multi-vm.ps1
#>
. "$PSScriptRoot/_common.ps1"

$tfDir   = Join-Path $Script:_RepoRoot 'terraform'
$vmName  = if ($VM_NAME) { $VM_NAME } else { 'cr465-lab' }
$dbName  = "$vmName-db"

Write-SectionHeader -Title 'Lab 07 -- Multi-VM'

# --- terraform apply (creates the DB VM) ---
Write-Host '  Applying Terraform (creates second VM -- may take a few minutes)...'
$applyOut = Invoke-LabCmd -ArgumentList @('terraform', 'apply', '-auto-approve', '-input=false') -WorkingDirectory $tfDir
Assert-Success 'terraform apply exits 0' -ExitCode $Script:_LastExitCode

# --- both VMs running ---
$listOut    = Invoke-LabCmd -ArgumentList @('multipass', 'list') -WorkingDirectory $Script:_RepoRoot
$listJoined = $listOut -join "`n"
Assert-OutputContains "Web VM '$vmName' is Running"   -Output $listOut -Pattern "$vmName\s+Running"
Assert-OutputContains "DB VM '$dbName' is Running"    -Output $listOut -Pattern "$dbName\s+Running"

# --- terraform output returns both IPs ---
$outputOut = Invoke-LabCmd -ArgumentList @('terraform', 'output', '-json') -WorkingDirectory $tfDir
Assert-Success 'terraform output exits 0' -ExitCode $Script:_LastExitCode
Assert-OutputContains 'output contains ipv4 (web)'   -Output $outputOut -Pattern '"ipv4"'
Assert-OutputContains 'output contains db_ipv4'      -Output $outputOut -Pattern '"db_ipv4"'
Assert-OutputContains 'output contains db_vm_name'   -Output $outputOut -Pattern '"db_vm_name"'

# --- verify depends_on: DB VM appears after web VM in state ---
$stateOut = Invoke-LabCmd -ArgumentList @('terraform', 'state', 'list') -WorkingDirectory $tfDir
Assert-Success 'terraform state list exits 0' -ExitCode $Script:_LastExitCode
Assert-OutputContains 'state contains lab instance'  -Output $stateOut -Pattern 'multipass_instance.lab'
Assert-OutputContains 'state contains db instance'   -Output $stateOut -Pattern 'multipass_instance.db'

Write-SectionFooter -Title 'Lab 07 -- Multi-VM'
Write-LabReport -StepName '07-multi-vm'

Invoke-LearnPause `
    -EN 'Both VMs are running. Use depends_on to control creation order in multi-tier architectures.' `
    -FR 'Les deux VMs sont en marche. Utilisez depends_on pour controler l ordre de creation en multi-tiers.'

Write-FinalSummary
