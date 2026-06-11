# Lab 00: Preflight

Before you launch any virtual machine, verify that every required tool is
installed and that your environment meets the minimum resource requirements.

## Objectives

- Confirm Terraform >= 1.6 is on the PATH.
- Confirm Multipass is installed and reachable.
- Confirm at least 5 GB of free disk space.
- Confirm network access to `cloud-images.ubuntu.com`.

## Prerequisites

| Tool | Minimum version | Install |
|------|----------------|---------|
| [Terraform](https://developer.hashicorp.com/terraform/install) | 1.6 | `choco install terraform` |
| [Multipass](https://multipass.run) | any | download from multipass.run |
| PowerShell | 5.1 (Windows built-in) | — |

## Steps

### 1. Check Terraform

```powershell
terraform version
```

Expected output starts with `Terraform v1.6` or higher.

### 2. Check Multipass

```powershell
multipass version
```

Expected output shows `multipass X.Y.Z`.

### 3. Check free disk

```powershell
(Get-PSDrive C).Free / 1GB
```

Must be at least `5`.

### 4. Check network

```powershell
Test-NetConnection -ComputerName cloud-images.ubuntu.com -Port 443
```

`TcpTestSucceeded` must be `True`.

### 5. Run the automated preflight

```powershell
PowerShell -ExecutionPolicy Bypass -File tests/00-preflight.ps1
```

All checks must show `[PASS]`.

## Verification

Run `tests/00-preflight.ps1`. The script exits 0 and prints `FAIL: 0`.

## Recovery

| Symptom | Fix |
|---------|-----|
| `terraform: command not found` | Add Terraform to PATH; reopen terminal. |
| `multipass: command not found` | Install Multipass and restart the terminal. |
| Disk < 5 GB | Free space or use a different drive. |
| Network check fails | Check firewall / proxy settings for `cloud-images.ubuntu.com:443`. |
