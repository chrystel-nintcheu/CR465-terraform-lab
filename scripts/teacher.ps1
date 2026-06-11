. "$PSScriptRoot/common.ps1"

Write-LabHeader -Title 'Teacher validation runner'
& "$PSScriptRoot/check-prereqs.ps1"

Set-Location (Get-TerraformDir)
terraform validate

$json = terraform output -json 2>$null
if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($json)) {
  $out = $json | ConvertFrom-Json
  Write-Host "vm_name  : $($out.vm_name.value)"
  Write-Host "ipv4     : $($out.ipv4.value -join ', ')"
  Write-Host "lab_stage: $($out.lab_stage.value)"
} else {
  Write-Host 'No Terraform outputs yet - run apply first.'
}

Write-Host ''
Write-Host '--- multipass list ---'
multipass list
