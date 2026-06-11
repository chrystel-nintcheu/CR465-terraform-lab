# Lab 08: Teardown

The final step verifies that `terraform destroy` cleanly removes all resources
and that the cycle can be repeated without drift or leftover state.

## Objectives

- Run `terraform destroy` and confirm all lab VMs are gone.
- Re-apply and destroy a second time to confirm idempotency.
- Verify no orphaned Multipass instances remain.

## Prerequisites

- Labs 01-07 completed (all VMs may be running).

## Why teardown matters

A lab that cannot be cleanly destroyed is not production-ready. Terraform's
declarative model guarantees that destroy + apply produces the same result
every time — this test proves it.

## Steps

### 1. Destroy all resources

```powershell
Set-Location terraform
terraform destroy -auto-approve
```

This removes both VMs (`cr465-lab` and `cr465-lab-db`), the alias, and all
file transfer resources.

### 2. Verify the VMs are gone

```powershell
multipass list
```

No lab VMs should appear.

### 3. Re-apply

```powershell
terraform apply -auto-approve
```

Both VMs are created fresh again.

### 4. Destroy again

```powershell
terraform destroy -auto-approve
```

Both apply and destroy must succeed with exit code 0.

### 5. Run the automated test

```powershell
PowerShell -ExecutionPolicy Bypass -File tests/08-teardown.ps1
```

The test performs both destroy cycles automatically. All checks must show `[PASS]`.

## Verification

`tests/08-teardown.ps1` exits 0 and prints `FAIL: 0`.

## Recovery

| Symptom | Fix |
|---------|-----|
| `terraform destroy` fails | Run `multipass delete --all --purge`, then `terraform destroy -auto-approve`. |
| VM remains after destroy | `multipass delete <name> --purge`, then run `terraform apply` to resync state. |
| State inconsistency | Run `terraform refresh` then retry destroy. |
