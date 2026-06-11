# Step 3: Isolated cloud-init

## Goal
Keep cloud-init independent so it can be checked before integration.

## Prerequisites
- Step 2 validation passed

## What is cloud-init?

[cloud-init](https://cloudinit.readthedocs.io/) is the industry-standard tool for bootstrapping VM instances. When Multipass launches a VM, it passes your cloud-init YAML to the Ubuntu image. The OS reads it on first boot and executes the declared actions: installing packages, writing files, running commands, creating users, etc.

Cloud-init runs exactly **once**, at first boot. It is not re-run on reboot. If you need to re-provision, you must destroy and recreate the VM.

## The template file

The lab's cloud-init source is `cloud-init/user-data.yaml.tftpl`. The `.tftpl` extension signals that this is a **Terraform template** — it uses `${ }` interpolation syntax and must be rendered by `templatefile()` before it can be used.

```yaml
#cloud-config
package_update: true
package_upgrade: false
packages:
  - git
  - curl
write_files:
  - path: /etc/cr465-lab.txt
    permissions: '0644'
    content: |
      CR465 Terraform Multipass Lab
      Hostname  : ${hostname}
      Lab stage : ${lab_stage}
      ...
runcmd:
  - echo 'CR465 lab ready' > /var/tmp/cr465-lab-ready.txt
```

### Template variables

| Variable | Where it comes from | Purpose |
|---|---|---|
| `${hostname}` | `var.vm_name` in `terraform/main.tf` | Written into the VM's identity file |
| `${lab_stage}` | `var.lab_stage` | Labels the provisioning stage |

In `terraform/main.tf`:
```hcl
cloud_init = templatefile("${path.module}/../cloud-init/user-data.yaml.tftpl", {
  hostname  = var.vm_name
  lab_stage = var.lab_stage
})
```

`templatefile()` renders the template at plan/apply time and passes the resulting YAML string to the provider. No intermediate file is written to disk — it stays in memory within the Terraform process.

### Why isolate cloud-init?

The template must be valid YAML *before* the `${...}` variables are substituted. Keeping cloud-init in its own directory makes it possible to lint and validate the template structure independently of Terraform. This is the SRE principle of **fail-fast at the smallest scope**: catch a YAML error before a 60-second VM boot cycle.

## Standalone YAML validation

To validate the template structure without Terraform (substitute dummy values manually):

```powershell
# Quick structural check: confirm the file parses as valid YAML
# (Python is available inside the Multipass VM, or install it on the host)
python -c "import yaml; yaml.safe_load(open('cloud-init/user-data.yaml.tftpl').read().replace('\${hostname}', 'test').replace('\${lab_stage}', 'test'))"
```

If no output is printed, the YAML is structurally valid.

## Verifying provisioning after apply

After `terraform apply`, confirm cloud-init ran successfully inside the VM:

```powershell
multipass shell cr465-lab
# Inside the VM:
cat /etc/cr465-lab.txt           # Should show hostname and lab_stage
cat /var/tmp/cr465-lab-ready.txt # Should show 'CR465 lab ready'
sudo cloud-init status           # Should show 'done'
```

## Verification
Run `powershell -File tests/validate-tutorial-order.ps1`.

## Recovery
Repair the cloud-init template first, then rerun the integration checks. If the YAML is invalid, `terraform apply` will fail before the VM is created — you will not need to destroy anything.
