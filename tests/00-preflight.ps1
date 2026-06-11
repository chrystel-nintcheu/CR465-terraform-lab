<#
.SYNOPSIS
  Lab 00 -- Preflight checks.
  Verifies tools are installed and environment is ready before any VM work.
.USAGE
  PowerShell -File tests/00-preflight.ps1
#>
. "$PSScriptRoot/_common.ps1"

Write-SectionHeader -Title 'Lab 00 -- Preflight'

# --- terraform version >= 1.6 ---
$tfOut = Invoke-LabCmd -ArgumentList @('terraform', 'version') -WorkingDirectory $Script:_RepoRoot
Assert-Success  'terraform exits 0'  -ExitCode $Script:_LastExitCode
Assert-OutputContains 'terraform version >= 1.6' -Output $tfOut -Pattern 'Terraform v1\.[6-9]|Terraform v1\.\d{2,}|Terraform v[2-9]'

# --- multipass version present ---
$mpOut = Invoke-LabCmd -ArgumentList @('multipass', 'version') -WorkingDirectory $Script:_RepoRoot
Assert-Success  'multipass exits 0'  -ExitCode $Script:_LastExitCode
Assert-OutputNotEmpty 'multipass version output non-empty' -Output $mpOut

# --- PowerShell accessible ---
$psOut = Invoke-LabCmd -ArgumentList @('PowerShell.exe', '-Command', '$PSVersionTable.PSVersion.Major') -WorkingDirectory $Script:_RepoRoot
Assert-Success 'PowerShell accessible' -ExitCode $Script:_LastExitCode

# --- Free disk >= 5 GB ---
$drive  = Split-Path -Qualifier $Script:_RepoRoot
$disk   = Get-PSDrive ($drive.TrimEnd(':')) -ErrorAction SilentlyContinue
if ($disk) {
    $freeGB = [math]::Round($disk.Free / 1GB, 1)
    if ($freeGB -ge 5) { Pass "Free disk >= 5 GB (${freeGB} GB free)" }
    else               { Fail "Free disk < 5 GB (${freeGB} GB free)" }
} else {
    Skip 'Free disk check' -Reason 'Drive info unavailable'
}

# --- Network reachability (cloud-images.ubuntu.com) ---
$reachable = Test-NetConnection -ComputerName 'cloud-images.ubuntu.com' -Port 443 -InformationLevel Quiet -WarningAction SilentlyContinue 2>$null
if ($reachable) { Pass 'cloud-images.ubuntu.com reachable on port 443' }
else            { Fail 'cloud-images.ubuntu.com NOT reachable -- check network' }

Write-SectionFooter -Title 'Lab 00 -- Preflight'
Write-LabReport -StepName '00-preflight'

Invoke-LearnPause `
    -EN 'All tools verified. Your environment is ready for the lab.' `
    -FR 'Tous les outils sont verifies. Votre environnement est pret.'

Write-FinalSummary
