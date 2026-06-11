. "$PSScriptRoot/common.ps1"

Write-LabHeader -Title 'Reset lab'
& "$PSScriptRoot/destroy.ps1"
& "$PSScriptRoot/apply.ps1"
