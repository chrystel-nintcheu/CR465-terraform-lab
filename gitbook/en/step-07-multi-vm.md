# Lab 07: Multi-VM

So far the lab managed a single VM. In this step you add a second instance
(`cr465-lab-db`) that depends on the first. Terraform's `depends_on` ensures
the web VM is fully created before the database VM starts.

## Objectives

- Add a second `multipass_instance` with `depends_on`.
- Verify both VMs are Running.
- Read both IPv4 addresses from `terraform output`.

## Prerequisites

- Lab 01 (First VM) passed.

## What was added to main.tf

```hcl
resource "multipass_instance" "db" {
  name   = "${var.vm_name}-db"
  image  = var.image
  cpus   = 1
  memory = "1G"
  disk   = "5G"

  cloud_init = templatefile("${path.module}/../cloud-init/user-data.yaml.tftpl", {
    hostname  = "${var.vm_name}-db"
    lab_stage = "step-7-multi-vm-db"
  })

  depends_on = [multipass_instance.lab]
}
```

And two new outputs in `outputs.tf`:

```hcl
output "db_vm_name" { value = multipass_instance.db.name }
output "db_ipv4"    { value = multipass_instance.db.ipv4 }
```

## Steps

### 1. Apply (creates the DB VM)

```powershell
Set-Location terraform
terraform apply -auto-approve
```

This may take 2-5 minutes as the second image is downloaded and cloud-init runs.

### 2. Verify both VMs are Running

```powershell
multipass list
```

Both `cr465-lab` and `cr465-lab-db` should show `Running`.

### 3. Read both IPs

```powershell
terraform output
```

You should see `ipv4`, `db_ipv4`, `db_vm_name`, `vm_name`, and `lab_stage`.

### 4. Run the automated test

```powershell
PowerShell -ExecutionPolicy Bypass -File tests/07-multi-vm.ps1
```

All checks must show `[PASS]`.

## Verification

`tests/07-multi-vm.ps1` exits 0 and prints `FAIL: 0`.

## Recovery

| Symptom | Fix |
|---------|-----|
| DB VM stuck in `Starting` | Wait 3 minutes; then `multipass restart cr465-lab-db`. |
| `depends_on` error | Ensure the web VM applied cleanly before running apply again. |
| Only one VM in state | Run `terraform apply` again — it is idempotent. |
