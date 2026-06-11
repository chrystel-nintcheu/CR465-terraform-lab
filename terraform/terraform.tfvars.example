# Example variable overrides for the CR465 lab.
# Copy this file to terraform.tfvars to customize your environment.
# terraform.tfvars is gitignored — your local values stay local.

# Name of the Multipass VM. Must be unique on the host.
vm_name = "cr465-lab"

# Ubuntu image to launch. "lts" always resolves to the current LTS release.
# Other options: "24.04", "22.04", "jammy", "noble"
image = "lts"

# vCPUs assigned to the VM.
cpus = 2

# Memory as a Multipass size string.
memory = "2G"

# Disk size as a Multipass size string.
disk = "10G"

# Tutorial stage label embedded into cloud-init at provisioning time.
lab_stage = "step-2-single-vm"
