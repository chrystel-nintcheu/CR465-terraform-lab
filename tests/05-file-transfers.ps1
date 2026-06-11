<#
.SYNOPSIS
  Lab 05 -- File transfers.
  Verifies file upload (host->VM) and file download (VM->host) via Terraform.
.USAGE
  PowerShell -ExecutionPolicy Bypass -File tests/05-file-transfers.ps1
#>
. "$PSScriptRoot/_common.ps1"

$tfDir   = Join-Path $Script:_RepoRoot 'terraform'
$vmName  = if ($VM_NAME) { $VM_NAME } else { 'cr465-lab' }

Write-SectionHeader -Title 'Lab 05 -- File transfers'

# --- VM must be running ---
$listOut    = Invoke-LabCmd -ArgumentList @('multipass', 'list') -WorkingDirectory $Script:_RepoRoot
$listJoined = $listOut -join "`n"
if ($listJoined -notmatch "$vmName\s+Running") {
    Fail "VM '$vmName' must be Running (run 01-first-vm.ps1 first)"
    Write-SectionFooter -Title 'Lab 05 -- File transfers'
    Write-LabReport -StepName '05-file-transfers'
    Write-FinalSummary
    return
}
Pass "VM '$vmName' is Running"

# --- terraform apply (incremental) ---
Write-Host '  Applying Terraform (file transfer resources)...'
$applyOut = Invoke-LabCmd -ArgumentList @('terraform', 'apply', '-auto-approve', '-input=false') -WorkingDirectory $tfDir
Assert-Success 'terraform apply (file resources) exits 0' -ExitCode $Script:_LastExitCode

# --- uploaded file exists inside VM ---
$remoteOut = Invoke-LabCmd -ArgumentList @('multipass', 'exec', $vmName, '--', 'test', '-f', '/tmp/lab-file.yaml') -WorkingDirectory $Script:_RepoRoot
Assert-Success 'Uploaded file /tmp/lab-file.yaml exists inside VM' -ExitCode $Script:_LastExitCode

# --- downloaded file exists on host ---
$downloadedPath = Join-Path (Join-Path $Script:_RepoRoot 'results') 'cr465-lab-ready.txt'
Assert-FileExists 'Downloaded file cr465-lab-ready.txt exists on host' -Path $downloadedPath

# --- downloaded file has expected content ---
if (Test-Path $downloadedPath) {
    $content = Get-Content $downloadedPath -Raw
    if ($content -match 'lab ready') { Pass 'Downloaded file contains expected text' }
    else                             { Fail 'Downloaded file content unexpected' 'Expected "lab ready"' }
}

Write-SectionFooter -Title 'Lab 05 -- File transfers'
Write-LabReport -StepName '05-file-transfers'

Invoke-LearnPause `
    -EN 'File transfers let you provision config files into VMs and retrieve artifacts without SSH.' `
    -FR 'Les transferts de fichiers permettent de provisionner des configs dans les VMs et recuperer des artefacts.'

Write-FinalSummary
