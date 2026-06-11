# Step 7: Staged validation

## Goal
Validate the lab in layers: prerequisites, contracts, integration, and end to end.

## Prerequisites
- Step 6 validation passed

## Why validate in stages?

A monolithic test that tries to do everything at once is hard to debug: if it fails, you don't know *where* it failed. Staged validation divides the test surface into layers, each gating the next:

```
Layer 1: Dependency check     → tools installed?
Layer 2: Contract check       → docs structurally correct?
Layer 3: Terraform validation → HCL valid, provider available?
Layer 4: End-to-end plan      → infrastructure declares cleanly?
```

When a layer fails, you stop there and fix it before running deeper layers. This is the same logic as a pre-flight checklist.

## What `tests/run.ps1` does

```powershell
# Layer 1: prerequisites
& "$PSScriptRoot/validate-contract.ps1"

# Layer 2: contract structure
& "$PSScriptRoot/validate-tutorial-order.ps1"

# Layer 3: tool availability
& "$PSScriptRoot/../scripts/check-prereqs.ps1"

# Layer 4: Terraform
Set-Location (Get-TerraformDir)
terraform init -input=false -upgrade
terraform validate
terraform plan -input=false -detailed-exitcode
$planExit = $LASTEXITCODE
if ($planExit -eq 1) { throw 'terraform plan returned an error.' }
```

Note: `terraform plan -detailed-exitcode` returns:
- **0** — no changes (VM already matches state)
- **1** — error
- **2** — changes pending (VM not yet created)

Exit code 2 is valid: it means the configuration is correct but the VM hasn't been applied yet. Both 0 and 2 indicate a healthy configuration.

## What `tests/validate-contract.ps1` checks

- Required files exist: `docs/plan.md`, `docs/plan.fr.md`, `docs/acceptance-criteria.yaml`
- `acceptance-criteria.yaml` contains exactly 8 step entries
- Both plan files have exactly 7 top-level `##` sections and 16 numbered list items

The numeric checks (7 sections, 16 numbered lines) are structural invariants of the contract. If you need to change the contract structure, update these checks in the validation script at the same time.

## What `tests/validate-tutorial-order.ps1` checks

- All runner scripts exist
- All Terraform files exist and contain required tokens
- All 18 GitBook pages exist
- Each page contains the required heading structure

## Expected output
- Dependency checks pass.
- Contract and order checks pass.
- Terraform validation passes.

## Verification
Run `powershell -File tests/run.ps1`.

## Recovery
Do not advance past a failing validation layer; repair the narrowest failure first. The error message from each check names the specific file or token that is missing or wrong.
