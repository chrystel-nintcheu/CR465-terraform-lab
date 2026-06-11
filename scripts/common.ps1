Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-LabHeader {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Title
  )

  Write-Host ''
  Write-Host "== $Title =="
}

function Get-RepoRoot {
  return (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
}

function Get-TerraformDir {
  return (Join-Path (Get-RepoRoot) 'terraform')
}
