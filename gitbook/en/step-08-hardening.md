# Step 8: Hardening

## Goal
Remove drift and make repeated execution deterministic.

## Prerequisites
- Step 7 validation passed

## Key concepts

### Idempotency

An operation is **idempotent** if running it once produces the same result as running it ten times. Idempotency is a foundational property of infrastructure automation: if your pipeline runs twice due to a retry, it must not break anything.

In Terraform terms: after `terraform apply`, running `terraform apply` again must produce **no changes**. If the second run modifies or recreates resources, your configuration is not idempotent.

### Configuration drift

**Drift** happens when the actual state of your infrastructure diverges from the state Terraform last recorded. Common causes:
- Someone ran `multipass stop cr465-lab` or deleted the VM manually (outside Terraform).
- A cloud provider updated an auto-managed attribute (OS patch, IP reassignment).
- The Terraform state file was deleted or corrupted.

When drift occurs, `terraform plan` shows unexpected changes. The correct response is to review the diff: either let Terraform converge back to the declared state (run `terraform apply`), or update the Terraform code to reflect an intentional change.

### What "hardening" means in IaC

Hardening an IaC codebase means making it **resilient to repeated runs, partial failures, and environmental variation**. For this lab, hardening means:

1. The `reset` flow (destroy + apply) completes successfully every time without manual intervention.
2. `terraform plan` after a successful `apply` shows zero changes.
3. `tests/run.ps1` passes on the first run and on every subsequent run.
4. State files are never committed to git (drift between local and team state is prevented).

## The two-run test

Running `tests/run.ps1` twice in a row is the minimum idempotency check:

```powershell
powershell -File tests/run.ps1   # First run: init, validate, plan — should pass
powershell -File tests/run.ps1   # Second run: same commands, same result
```

If the second run produces a different outcome (e.g., a new provider download, a changed plan), you have a non-deterministic element to fix. Common fixes:
- Pin provider versions precisely (use `= 1.7.x` instead of `~> 1.7`).
- Pin the Multipass image to a specific version (use `"24.04"` instead of `"lts"`).
- Ensure `terraform init -upgrade` does not pull a newer provider between runs.

## Reset idempotency

Test the full reset cycle:

```powershell
powershell -File scripts/reset.ps1   # destroy + apply — should complete cleanly
powershell -File scripts/reset.ps1   # second reset — must also succeed
```

After both resets, `multipass list` should show exactly one running instance named `cr465-lab`.

## Expected output
- The reset flow is repeatable.
- The validation script stays green on reruns.
- `terraform plan` after apply shows: `No changes. Your infrastructure matches the configuration.`

## Verification
Run `powershell -File tests/run.ps1` twice.

## Recovery
If a rerun fails, correct the smallest affected area and test again. Do not introduce workarounds that only fix the symptom — trace the failure to the source and fix the root cause. Non-deterministic infrastructure is a reliability risk.
