# Central lab configuration
# Source this file to get shared variables used by all lab scripts and provisioners.
# Usage: . "$PSScriptRoot/config.ps1"  (or from repo root: . ./config.ps1)

$VM_NAME         = 'cr465-lab'
$IMAGE           = 'lts'
$CPUS            = 2
$MEMORY          = '2G'
$DISK            = '10G'
$TIMEOUT_DEFAULT = 120   # seconds — general command timeout
$TIMEOUT_APPLY   = 600   # seconds — terraform apply / multipass launch timeout

# Print when invoked directly so callers can verify values
if ($MyInvocation.InvocationName -eq $MyInvocation.MyCommand.Path -or
    $MyInvocation.InvocationName -eq '.\config.ps1' -or
    $MyInvocation.InvocationName -eq './config.ps1') {
    Write-Host "VM_NAME         = $VM_NAME"
    Write-Host "IMAGE           = $IMAGE"
    Write-Host "CPUS            = $CPUS"
    Write-Host "MEMORY          = $MEMORY"
    Write-Host "DISK            = $DISK"
    Write-Host "TIMEOUT_DEFAULT = $TIMEOUT_DEFAULT"
    Write-Host "TIMEOUT_APPLY   = $TIMEOUT_APPLY"
}
