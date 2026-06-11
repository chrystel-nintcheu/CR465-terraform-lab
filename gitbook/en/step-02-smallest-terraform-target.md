# Step 2: Smallest Terraform target

## Goal
Define one `multipass_instance` resource using the `todoroff/multipass` provider.
Terraform must own the full VM lifecycle — create, update, destroy — and expose
a real `ipv4` output that can be referenced by other resources.

## Prerequisites
- Step 1 validation passed
- Terraform ≥ 1.6 and Multipass are installed (see Step 1)

## Key source files
- `terraform/versions.tf` — declares `todoroff/multipass ~> 1.7`
- `terraform/main.tf` — `provider "multipass"`, `resource "multipass_instance" "lab"`, `resource "multipass_alias" "shell"`
- `terraform/variables.tf` — `vm_name`, `image`, `cpus`, `memory` (e.g. `"2G"`), `disk` (e.g. `"10G"`), `lab_stage`
- `terraform/outputs.tf` — `vm_name`, `ipv4` (from `multipass_instance.lab.ipv4`), `lab_stage`
- `cloud-init/user-data.yaml.tftpl` — rendered via `templatefile()` inside the resource block

## Concepts

### About the provider

The `todoroff/multipass` provider is a **community provider**, not published by HashiCorp. It is available on the [Terraform Registry](https://registry.terraform.io/providers/todoroff/multipass/latest) but has no official support contract. In production, prefer HashiCorp-verified providers (marked with a blue tick on the registry) and audit community providers before use.

`terraform init` downloads the provider from the registry into `.terraform/`. That directory is excluded from git by `.gitignore` — never commit it.

### The `multipass_instance` resource

This is the core resource: it maps directly to a Multipass VM. Terraform calls `multipass launch` under the hood when you apply, `multipass info` to read state, and `multipass delete` when you destroy. The provider translates HCL declarations into Multipass CLI calls.

### `(known after apply)`

When you run `terraform plan`, some attribute values cannot be computed until the resource actually exists. The VM's IP address is assigned by the OS at boot — Terraform cannot predict it. The plan shows:

```
+ ipv4 = (known after apply)
```

This is fundamental Terraform behavior: the **schema** is known at plan time (what attributes exist, what types they have), but **dynamic values** are deferred until apply. After `terraform apply`, `terraform output ipv4` will show the real address.

### The `multipass_alias` resource

A Multipass alias creates a shortcut command on the host. After apply, `multipass alias cr465-lab-shell` is registered — but the important thing here is the **implicit dependency**: the alias references `multipass_instance.lab.name`. Terraform's dependency graph ensures the instance is created *before* the alias, and destroyed *after* it. You get ordered lifecycle management without writing a single `depends_on`.

### Customizing variables

Default values are set in `terraform/variables.tf`. To override them without editing source files, copy the example:

```powershell
Copy-Item terraform/terraform.tfvars.example terraform/terraform.tfvars
```

Edit `terraform/terraform.tfvars` with your preferred values. This file is gitignored — your local overrides stay local.

## Expected output
After `terraform plan`, Terraform shows:
```
# multipass_instance.lab will be created
+ resource "multipass_instance" "lab" {
    + cpus           = 2
    + disk           = "10G"
    + ipv4           = (known after apply)
    + memory         = "2G"
    + name           = "cr465-lab"
    ...
  }
```

## Verification
From the repo root:
```powershell
cd terraform
terraform init
terraform validate   # Success! The configuration is valid.
terraform plan       # Shows multipass_instance.lab + multipass_alias.shell
```
Or run the full suite: `powershell -File tests/run.ps1`

## Recovery
If `terraform validate` fails, fix only the HCL files in `terraform/`, then
rerun `terraform init` followed by `terraform validate`. Do not modify provider
files inside `.terraform/` — those are managed by Terraform itself.
