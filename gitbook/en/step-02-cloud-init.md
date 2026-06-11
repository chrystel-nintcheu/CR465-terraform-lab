# Lab 02: Cloud-init

Cloud-init is the standard Linux VM initialisation system. When Terraform
applies your `multipass_instance`, it passes the `user-data.yaml.tftpl`
template to Multipass, which forwards it to cloud-init inside the VM.

## Objectives

- Understand what cloud-init does at first boot.
- Verify that packages were installed.
- Read the marker files left by cloud-init.

## Prerequisites

- Lab 01 (First VM) passed and the VM is Running.

## What cloud-init does in this lab

The `cloud-init/user-data.yaml.tftpl` template:

1. Updates the package list (`package_update: true`).
2. Installs `git` and `curl`.
3. Writes `/etc/cr465-lab.txt` with hostname and lab stage metadata.
4. Runs a `runcmd` that creates `/var/tmp/cr465-lab-ready.txt`.

## Steps

### 1. Inspect the template

Open `cloud-init/user-data.yaml.tftpl` in your editor.
Notice the `${hostname}` and `${lab_stage}` template variables — these are
filled in by Terraform's `templatefile()` function before the VM launches.

### 2. Verify packages inside the VM

```powershell
multipass exec cr465-lab -- which git
multipass exec cr465-lab -- which curl
```

Both commands should return a path like `/usr/bin/git`.

### 3. Read the marker file

```powershell
multipass exec cr465-lab -- cat /var/tmp/cr465-lab-ready.txt
```

Expected output: `CR465 lab ready` followed by a timestamp.

### 4. Read the lab metadata

```powershell
multipass exec cr465-lab -- cat /etc/cr465-lab.txt
```

You should see the hostname (`cr465-lab`) and the lab stage.

### 5. Run the automated test

```powershell
PowerShell -ExecutionPolicy Bypass -File tests/02-cloud-init.ps1
```

All checks must show `[PASS]`.

## Verification

`tests/02-cloud-init.ps1` exits 0 and prints `FAIL: 0`.

## Recovery

| Symptom | Fix |
|---------|-----|
| `git`/`curl` not found | cloud-init may not have finished. Wait and retry, or run `multipass exec cr465-lab -- cloud-init status`. |
| Marker file missing | Check `multipass exec cr465-lab -- cloud-init status --wait`. |
| Hostname is wrong | Destroy and reapply: `terraform destroy -auto-approve; terraform apply -auto-approve`. |
