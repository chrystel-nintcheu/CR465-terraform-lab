. "$PSScriptRoot/common.ps1"

Write-LabHeader -Title 'Destroy lab'
Set-Location (Get-TerraformDir)
# LAB-ONLY: -auto-approve skips the confirmation prompt.
# In production, always confirm destructive operations manually.
terraform destroy -auto-approve
