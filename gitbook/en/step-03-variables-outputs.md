# Lab 03: Variables and Outputs

Terraform variables let you parameterise your infrastructure without touching
the HCL source. Outputs expose values from your deployed resources so you can
use them in scripts, CI pipelines, or other Terraform modules.

## Objectives

- Create a `terraform.tfvars` file to customise the lab deployment.
- Understand how `variables.tf` declares inputs and `outputs.tf` exposes results.
- Read all three outputs: `vm_name`, `ipv4`, `lab_stage`.

## Prerequisites

- Lab 01 (First VM) passed and the VM is Running.

## Steps

### 1. Create terraform.tfvars

```powershell
Copy-Item terraform/terraform.tfvars.example terraform/terraform.tfvars
```

Open `terraform/terraform.tfvars` and review the default values.
You can change `vm_name`, `cpus`, `memory`, `disk`, or `lab_stage`.

### 2. Re-apply (if you changed any values)

```powershell
Set-Location terraform
terraform apply -auto-approve
```

If you did not change any values, apply is a no-op (no changes).

### 3. List all outputs

```powershell
terraform output
```

You should see `vm_name`, `ipv4`, and `lab_stage`.

### 4. Read a single output

```powershell
terraform output -raw vm_name
terraform output -raw lab_stage
```

### 5. Read outputs as JSON (useful for scripting)

```powershell
terraform output -json
```

### 6. Run the automated test

```powershell
PowerShell -ExecutionPolicy Bypass -File tests/03-variables-outputs.ps1
```

All checks must show `[PASS]`.

## Verification

`tests/03-variables-outputs.ps1` exits 0 and prints `FAIL: 0`.

## Recovery

| Symptom | Fix |
|---------|-----|
| `terraform output` returns nothing | VM may not have been applied. Run `terraform apply`. |
| `terraform.tfvars` missing | Copy from `terraform.tfvars.example`. |
| `ipv4` is empty | Cloud-init networking may not be ready. Wait 30 seconds and retry. |
