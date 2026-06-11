. "$PSScriptRoot/../scripts/common.ps1"

Set-Location (Get-RepoRoot)

foreach ($path in @('docs/plan.md', 'docs/plan.fr.md', 'docs/acceptance-criteria.yaml')) {
  if (-not (Test-Path $path)) {
    throw "Missing required file: $path"
  }
}

$acceptance = Get-Content 'docs/acceptance-criteria.yaml'
if ((($acceptance | Where-Object { $_ -match '^\s+- id: ' }).Count) -ne 8) {
  throw 'Acceptance criteria must contain eight steps.'
}

$english = Get-Content 'docs/plan.md'
$french = Get-Content 'docs/plan.fr.md'

if ((($english | Where-Object { $_ -match '^## ' }).Count) -ne 7) {
  throw 'English plan must contain seven top-level sections.'
}

if ((($french | Where-Object { $_ -match '^## ' }).Count) -ne 7) {
  throw 'French plan must contain seven top-level sections.'
}

if ((($english | Where-Object { $_ -match '^[0-9]+\. ' }).Count) -ne 16) {
  throw 'English plan must contain sixteen numbered lines.'
}

if ((($french | Where-Object { $_ -match '^[0-9]+\. ' }).Count) -ne 16) {
  throw 'French plan must contain sixteen numbered lines.'
}

Write-Host 'Contract validation passed.'
