# Lab 04: Aliases

A Multipass alias is a host-side shortcut that executes a command inside a
named instance. Terraform manages it as a `multipass_alias` resource, so the
alias is created alongside the VM and destroyed when the VM is destroyed.

## Objectives

- Understand what `multipass_alias` creates.
- List registered aliases.
- Invoke the alias from any directory on the host.

## Prerequisites

- Lab 01 (First VM) passed and the VM is Running.

## Steps

### 1. Inspect the alias definition in Terraform

Open `terraform/main.tf`. Find the `multipass_alias` block:

```hcl
resource "multipass_alias" "shell" {
  name     = "${var.vm_name}-shell"
  instance = multipass_instance.lab.name
  command  = "bash"
}
```

The alias name is `cr465-lab-shell`. It runs `bash` inside `cr465-lab`.

### 2. List all aliases

```powershell
multipass aliases
```

You should see `cr465-lab-shell` mapped to `bash` in `cr465-lab`.

### 3. Use the alias

Because the alias is registered in the Multipass alias store, Multipass
provides it as a command on the system PATH (after the alias is created).

```powershell
multipass exec cr465-lab -- bash --login
```

Type `exit` to leave the VM shell.

### 4. Run the automated test

```powershell
PowerShell -ExecutionPolicy Bypass -File tests/04-aliases.ps1
```

All checks must show `[PASS]`.

## Verification

`tests/04-aliases.ps1` exits 0 and prints `FAIL: 0`.

## Recovery

| Symptom | Fix |
|---------|-----|
| Alias not found | Run `terraform apply -auto-approve` to re-create resources. |
| Alias points to wrong instance | Destroy and reapply: `terraform destroy -auto-approve && terraform apply -auto-approve`. |
