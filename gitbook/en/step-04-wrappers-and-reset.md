# Step 4: Wrappers and reset

## Goal
Add the student, teacher, apply, destroy, and reset runners.

## Prerequisites
- Step 3 validation passed

## The runner scripts

All scripts source `scripts/common.ps1` first. That module sets `Set-StrictMode -Version Latest` and `$ErrorActionPreference = 'Stop'`, which means any unhandled error throws immediately rather than silently continuing. This is intentional: **fail loudly, fail early**.

`common.ps1` also provides three shared utilities:

| Function | Purpose |
|---|---|
| `Write-LabHeader -Title '...'` | Prints a consistent banner line so output is easy to scan |
| `Get-RepoRoot` | Returns the absolute path of the repo root, independent of the caller's working directory |
| `Get-TerraformDir` | Returns the path of `terraform/` — used before every `terraform` command so the working directory is always correct |

### Student runner (`scripts/student.ps1`)

```powershell
. "$PSScriptRoot/common.ps1"
Write-LabHeader -Title 'Student runner'
& "$PSScriptRoot/apply.ps1"
```

The student's job is simple: **apply the lab**. The prerequisite check and `terraform init` are handled inside `apply.ps1`.

### Apply (`scripts/apply.ps1`)

```powershell
& "$PSScriptRoot/check-prereqs.ps1" -Quiet
Set-Location (Get-TerraformDir)
terraform init -input=false
# LAB-ONLY: -auto-approve skips the plan review prompt.
terraform apply -auto-approve
```

> **Production note:** `-auto-approve` is used here to avoid interactive prompts in a lab environment. In production, always run `terraform plan` first, review the diff, then run `terraform apply` without `-auto-approve` so you are forced to confirm.

### Teacher runner (`scripts/teacher.ps1`)

The teacher's job is to **validate the environment** and inspect the live outputs:

```powershell
terraform validate
$json = terraform output -json
$out = $json | ConvertFrom-Json
Write-Host "vm_name  : $($out.vm_name.value)"
Write-Host "ipv4     : $($out.ipv4.value -join ', ')"
Write-Host "lab_stage: $($out.lab_stage.value)"
```

`terraform output -json` returns a structured JSON object. The `ipv4` value is a **list** (a VM can have multiple network interfaces), which is why `-join ', '` is used. In practice, the Multipass VM will have one address.

### Reset (`scripts/reset.ps1`)

Reset = destroy + apply. This models a core SRE concept: **immutable infrastructure**. Instead of patching a live VM in place (which accumulates drift), you destroy and recreate it from the declared state. The new VM is always in a known, clean condition.

```powershell
& "$PSScriptRoot/destroy.ps1"
& "$PSScriptRoot/apply.ps1"
```

> **Production note:** `terraform destroy -auto-approve` is also lab-only. Destructive operations in production require manual confirmation and often a change-approval workflow (ITIL change request, PR review, etc.).

## Expected output
After `scripts/teacher.ps1`, the output includes a real IPv4 address:
```
vm_name  : cr465-lab
ipv4     : 172.x.x.x
lab_stage: step-2-single-vm
```

And `multipass list` shows the VM as `Running`.

## Verification
Run `powershell -File scripts/check-prereqs.ps1`, then apply the lab and run `powershell -File scripts/teacher.ps1`.

## Recovery
If a wrapper fails, fix the specific runner and keep the rest unchanged. The most common failure is a working-directory problem — check that `Get-TerraformDir` resolves correctly by running it in isolation:
```powershell
. scripts/common.ps1
Get-TerraformDir
```
