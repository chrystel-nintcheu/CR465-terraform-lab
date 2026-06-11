# Lab 05: File Transfers

The `multipass_file_upload` and `multipass_file_download` Terraform resources
let you move files between the host and a running VM using `multipass transfer`.
This is a Terraform-native alternative to `null_resource` provisioners.

## Objectives

- Use `multipass_file_upload` to push a host file into the VM.
- Use `multipass_file_download` to pull a VM file onto the host.
- Verify both files exist in their destination locations.

## Prerequisites

- Lab 01 (First VM) passed and the VM is Running.

## What was added to main.tf

```hcl
resource "multipass_file_upload" "lab_file" {
  instance    = multipass_instance.lab.name
  destination = "/tmp/lab-file.yaml"
  source      = "${path.module}/../cloud-init/user-data-fresh.yaml"
}

resource "multipass_file_download" "lab_ready" {
  instance       = multipass_instance.lab.name
  source         = "/var/tmp/cr465-lab-ready.txt"
  destination    = "${path.module}/../results/cr465-lab-ready.txt"
  create_parents = true
  overwrite      = true
}
```

## Steps

### 1. Apply the file transfer resources

```powershell
Set-Location terraform
terraform apply -auto-approve
```

### 2. Verify the uploaded file inside the VM

```powershell
multipass exec cr465-lab -- ls -la /tmp/lab-file.yaml
```

### 3. Verify the downloaded file on the host

```powershell
Get-Content results/cr465-lab-ready.txt
```

### 4. Run the automated test

```powershell
PowerShell -ExecutionPolicy Bypass -File tests/05-file-transfers.ps1
```

All checks must show `[PASS]`.

## Verification

`tests/05-file-transfers.ps1` exits 0 and prints `FAIL: 0`.

## Recovery

| Symptom | Fix |
|---------|-----|
| Upload fails | Verify `cloud-init/user-data-fresh.yaml` exists on the host. |
| Download fails | Verify `/var/tmp/cr465-lab-ready.txt` exists inside the VM (run Lab 02 first). |
| File content mismatch | Delete local file and re-run `terraform apply`. |
