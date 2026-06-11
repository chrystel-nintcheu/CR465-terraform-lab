# Lab 01: First VM

In this step you use Terraform to declare, initialize, and apply a single
Multipass virtual machine.  You will not write shell scripts or click through
a GUI — Terraform drives the entire lifecycle.

## Objectives

- Run `terraform init` to download the Multipass provider.
- Run `terraform apply` to create the VM.
- Confirm the VM appears in `multipass list`.
- Open a shell into the running VM.

## Prerequisites

- Lab 00 (Preflight) passed.
- A `terraform/terraform.tfvars` file (copy from `terraform.tfvars.example`).

## Steps

### 1. Copy the example variables file

```powershell
Copy-Item terraform/terraform.tfvars.example terraform/terraform.tfvars
```

Edit `terraform.tfvars` if you want a different VM name or size.

### 2. Initialise Terraform

```powershell
Set-Location terraform
terraform init
```

Expected: `Terraform has been successfully initialized!`

### 3. Preview the plan

```powershell
terraform plan
```

Review the resources Terraform will create.

### 4. Apply

```powershell
terraform apply
```

Type `yes` when prompted (or use `-auto-approve` for scripted runs).
This downloads the Ubuntu LTS image and launches the VM — expect 2-5 minutes.

### 5. Verify the VM is running

```powershell
multipass list
```

You should see `cr465-lab` in state `Running`.

### 6. Open a shell

```powershell
multipass shell cr465-lab
```

Type `exit` to leave the VM shell.

### 7. Run the automated test

```powershell
PowerShell -ExecutionPolicy Bypass -File tests/01-first-vm.ps1
```

All checks must show `[PASS]`.

## Verification

`tests/01-first-vm.ps1` exits 0 and prints `FAIL: 0`.

## Recovery

| Symptom | Fix |
|---------|-----|
| `terraform apply` fails | Run `terraform destroy -auto-approve`, then retry apply. |
| VM stuck in `Starting` | Wait 2 minutes; if still stuck run `multipass restart cr465-lab`. |
| Provider not found | Delete `terraform/.terraform` and re-run `terraform init`. |
