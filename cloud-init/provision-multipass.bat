@echo off
REM Thin CMD wrapper: delegates all work to provision-multipass.ps1 via pwsh.
pwsh -File "%~dp0provision-multipass.ps1" %*
