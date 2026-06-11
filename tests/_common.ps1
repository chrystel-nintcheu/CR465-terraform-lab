<#
.SYNOPSIS
  Shared test framework for CR465 lab tests.
  Dot-source this file from every per-step test script.
  Compatible with PowerShell 5.1+ and PowerShell Core 7+.
.USAGE
  . "$PSScriptRoot/_common.ps1"
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Counters (global so orchestrator can accumulate across steps)
# ---------------------------------------------------------------------------
if (-not (Get-Variable -Name TOTAL_PASS  -Scope Global -ErrorAction SilentlyContinue)) { $Global:TOTAL_PASS  = 0 }
if (-not (Get-Variable -Name TOTAL_FAIL  -Scope Global -ErrorAction SilentlyContinue)) { $Global:TOTAL_FAIL  = 0 }
if (-not (Get-Variable -Name TOTAL_SKIP  -Scope Global -ErrorAction SilentlyContinue)) { $Global:TOTAL_SKIP  = 0 }
$Script:PASS = 0
$Script:FAIL = 0
$Script:SKIP = 0

# ---------------------------------------------------------------------------
# Resolve repo root and config
# ---------------------------------------------------------------------------
$Script:_RepoRoot  = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$Script:_ConfigPs1 = Join-Path $Script:_RepoRoot 'config.ps1'
if (Test-Path $Script:_ConfigPs1) { . $Script:_ConfigPs1 }

# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------
$_ts        = Get-Date -Format 'yyyyMMdd-HHmmss'
$_logDir    = Join-Path $Script:_RepoRoot 'logs'
$_resultDir = Join-Path $Script:_RepoRoot 'results'
if (-not (Test-Path $_logDir))    { New-Item -ItemType Directory -Path $_logDir    | Out-Null }
if (-not (Test-Path $_resultDir)) { New-Item -ItemType Directory -Path $_resultDir | Out-Null }
$Script:_LogFile    = Join-Path $_logDir    "$_ts.log"
$Script:_ReportFile = Join-Path $_resultDir "report-$_ts.json"

function _Log {
    param([string]$Message)
    $line = "[$(Get-Date -Format 'HH:mm:ss')] $Message"
    Add-Content -Path $Script:_LogFile -Value $line -Encoding UTF8
    if ($env:LAB_VERBOSE -eq '1') { Write-Host $line }
}

# ---------------------------------------------------------------------------
# Section header / footer
# ---------------------------------------------------------------------------
function Write-SectionHeader {
    param([string]$Title)
    $bar = '-' * 60
    Write-Host ''
    Write-Host $bar
    Write-Host "  $Title"
    Write-Host $bar
    _Log "=== $Title ==="
}

function Write-SectionFooter {
    param([string]$Title)
    Write-Host "  PASS: $($Script:PASS)  FAIL: $($Script:FAIL)  SKIP: $($Script:SKIP)"
    _Log "--- $Title done: PASS=$($Script:PASS) FAIL=$($Script:FAIL) SKIP=$($Script:SKIP)"
}

# ---------------------------------------------------------------------------
# Assertion helpers
# ---------------------------------------------------------------------------
function Pass {
    param([string]$Label)
    $Script:PASS++
    $Global:TOTAL_PASS++
    Write-Host "    [PASS] $Label" -ForegroundColor Green
    _Log "[PASS] $Label"
}

function Fail {
    param([string]$Label, [string]$Detail = '')
    $Script:FAIL++
    $Global:TOTAL_FAIL++
    Write-Host "    [FAIL] $Label" -ForegroundColor Red
    if ($Detail) { Write-Host "           $Detail" -ForegroundColor Red }
    _Log "[FAIL] $Label $Detail"
}

function Skip {
    param([string]$Label, [string]$Reason = '')
    $Script:SKIP++
    $Global:TOTAL_SKIP++
    Write-Host "    [SKIP] $Label" -ForegroundColor Yellow
    if ($Reason) { Write-Host "           $Reason" -ForegroundColor Yellow }
    _Log "[SKIP] $Label $Reason"
}

function Assert-Success {
    param([string]$Label, [int]$ExitCode)
    if ($ExitCode -eq 0) { Pass $Label } else { Fail $Label "exit code $ExitCode" }
}

function Assert-Failure {
    param([string]$Label, [int]$ExitCode)
    if ($ExitCode -ne 0) { Pass $Label } else { Fail $Label "expected non-zero exit, got 0" }
}

function Assert-OutputContains {
    param([string]$Label, [string[]]$Output, [string]$Pattern)
    $joined = $Output -join "`n"
    if ($joined -match $Pattern) { Pass $Label } else { Fail $Label "pattern '$Pattern' not found" }
}

function Assert-OutputNotEmpty {
    param([string]$Label, [string[]]$Output)
    if ($Output -and ($Output -join '').Trim()) { Pass $Label } else { Fail $Label "output was empty" }
}

function Assert-FileExists {
    param([string]$Label, [string]$Path)
    if (Test-Path $Path) { Pass $Label } else { Fail $Label "file not found: $Path" }
}

# ---------------------------------------------------------------------------
# Command runner
# ---------------------------------------------------------------------------
function Invoke-LabCmd {
    <#
    .SYNOPSIS
      Runs an external command, captures stdout+stderr combined, returns output lines.
      Sets $Script:_LastExitCode for the caller to inspect.
    #>
    param(
        [string[]]$ArgumentList,
        [string]$WorkingDirectory = $Script:_RepoRoot
    )
    $prev    = Get-Location
    $prevEap = $ErrorActionPreference
    try {
        Set-Location $WorkingDirectory
        $exe  = $ArgumentList[0]
        # Select-Object -Skip 1 always returns an array in PS5, avoiding scalar-splat issues
        $rest = @($ArgumentList | Select-Object -Skip 1)
        # Set Continue so PS5 does not convert stderr lines into terminating errors via 2>&1
        $ErrorActionPreference = 'Continue'
        $output = @(& $exe @rest 2>&1 | ForEach-Object { "$_" })
        $Script:_LastExitCode = if (Test-Path Variable:\LASTEXITCODE) { $LASTEXITCODE } else { 0 }
    } catch {
        $Script:_LastExitCode = 99
        $output = @("ERROR: $_")
    } finally {
        $ErrorActionPreference = $prevEap
        Set-Location $prev
    }
    _Log "CMD $($ArgumentList -join ' ')  => $($Script:_LastExitCode)"
    return $output
}

# ---------------------------------------------------------------------------
# Learn-mode pause (bilingual)
# ---------------------------------------------------------------------------
function Invoke-LearnPause {
    param([string]$EN, [string]$FR = '')
    if ($env:LAB_MODE -ne 'learn') { return }
    Write-Host ''
    Write-Host "  [LEARN] $EN" -ForegroundColor Cyan
    if ($FR) { Write-Host "  [LEARN] $FR" -ForegroundColor Cyan }
    Write-Host '  Press ENTER to continue...' -ForegroundColor DarkCyan
    $null = Read-Host
}

# ---------------------------------------------------------------------------
# Step dependency check (reads last JSON report)
# ---------------------------------------------------------------------------
function Test-LabDependency {
    param([string]$RequiredStep)
    $reportDir = Join-Path $Script:_RepoRoot 'results'
    $reports = Get-ChildItem $reportDir -Filter 'report-*.json' -ErrorAction SilentlyContinue |
               Sort-Object Name -Descending
    if (-not $reports) {
        Write-Host "    [SKIP] Dependency '$RequiredStep' -- no prior report found" -ForegroundColor Yellow
        return $false
    }
    $last = Get-Content $reports[0].FullName -Raw | ConvertFrom-Json
    $stepResult = $last.steps | Where-Object { $_.step -eq $RequiredStep }
    if (-not $stepResult -or $stepResult.status -ne 'pass') {
        Write-Host "    [SKIP] Dependency '$RequiredStep' not green in last report" -ForegroundColor Yellow
        return $false
    }
    return $true
}

# ---------------------------------------------------------------------------
# Report writer (JSON)
# ---------------------------------------------------------------------------
$Script:_StepResults = New-Object 'System.Collections.Generic.List[hashtable]'

function Add-StepResult {
    param([string]$Step, [int]$Pass, [int]$Fail, [int]$Skip)
    $status = if ($Fail -gt 0) { 'fail' } elseif ($Pass -gt 0) { 'pass' } else { 'skip' }
    $Script:_StepResults.Add(@{ step = $Step; status = $status; pass = $Pass; fail = $Fail; skip = $Skip })
}

function Write-LabReport {
    param([string]$StepName)
    Add-StepResult -Step $StepName -Pass $Script:PASS -Fail $Script:FAIL -Skip $Script:SKIP
    $report = @{
        timestamp  = (Get-Date -Format 'o')
        steps      = $Script:_StepResults.ToArray()
        total_pass = $Global:TOTAL_PASS
        total_fail = $Global:TOTAL_FAIL
        total_skip = $Global:TOTAL_SKIP
    }
    $report | ConvertTo-Json -Depth 5 | Set-Content -Path $Script:_ReportFile -Encoding UTF8
    _Log "Report written: $($Script:_ReportFile)"
}

# ---------------------------------------------------------------------------
# Final summary
# ---------------------------------------------------------------------------
function Write-FinalSummary {
    $bar = '=' * 60
    Write-Host ''
    Write-Host $bar
    Write-Host '  LAB SUMMARY'
    Write-Host $bar
    Write-Host "  TOTAL PASS : $Global:TOTAL_PASS" -ForegroundColor Green
    $failColor = if ($Global:TOTAL_FAIL -gt 0) { 'Red' } else { 'Green' }
    Write-Host "  TOTAL FAIL : $Global:TOTAL_FAIL" -ForegroundColor $failColor
    Write-Host "  TOTAL SKIP : $Global:TOTAL_SKIP" -ForegroundColor Yellow
    Write-Host $bar
    _Log "=== FINAL: PASS=$Global:TOTAL_PASS FAIL=$Global:TOTAL_FAIL SKIP=$Global:TOTAL_SKIP ==="
    if ($Global:TOTAL_FAIL -gt 0) { exit 1 }
}
