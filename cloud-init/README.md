# cloud-init

This directory contains the isolated cloud-init template used by the lab.

The template is rendered inline by Terraform's `templatefile()` function and passed directly to the `multipass_instance` resource — no intermediate file is written to disk.

Validation target:

- The template must remain valid YAML.
- The rendered content must keep the same hostname and lab markers as the Terraform inputs.
