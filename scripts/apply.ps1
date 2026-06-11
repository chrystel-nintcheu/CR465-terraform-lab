. "$PSScriptRoot/common.ps1"

Write-LabHeader -Title 'Apply lab'
& "$PSScriptRoot/check-prereqs.ps1" -Quiet
Set-Location (Get-TerraformDir)
terraform init -input=false
# LAB-ONLY: -auto-approve skips the plan review prompt.
# In production, always run 'terraform plan' first and review before applying.
terraform apply -auto-approve
