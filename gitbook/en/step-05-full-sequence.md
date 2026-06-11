# Step 5: Full sequence

## Goal
Turn the single-VM proof into the full step-by-step tutorial flow.

## Prerequisites
- Step 4 validation passed

## What this step means

Steps 1–4 built the mechanical foundation: contracts, a working Terraform resource, cloud-init provisioning, and runner scripts. Step 5 is about **composing those pieces into a reproducible learning sequence**.

The key discipline is the **handoff**: each step must leave a documented artifact before the next begins. This mirrors real SRE handoffs during incident response or deployment pipelines — the next engineer (or next automated stage) consumes only the approved outputs, not tribal knowledge.

## The handoff artifact

After completing each step, record a brief handoff note. Use the template from `docs/plan.md`:

```markdown
## Handoff: Step N

- **Goal**: What this step was trying to achieve
- **Inputs**: Files or state consumed at the start
- **Outputs**: Artifacts produced
- **Decisions**: Choices made and why
- **Validation status**: PASSED / FAILED
- **Open issues**: Anything left unresolved
```

This is not bureaucracy — it is the mechanism that lets any lab participant **resume from any checkpoint** without re-reading the entire history.

## The full sequence

| Step | Core concept | Validation gate |
|---|---|---|
| 1 | Contract and bilingual structure | `tests/validate-contract.ps1` |
| 2 | Terraform resource lifecycle | `terraform validate && terraform plan` |
| 3 | cloud-init as an isolated layer | `tests/validate-tutorial-order.ps1` |
| 4 | Wrappers and reset behavior | `scripts/teacher.ps1` after apply |
| 5 | Full ordered sequence with handoffs | `tests/run.ps1` |
| 6 | Docs and GitBook alignment | `tests/run.ps1` + manual inspection |
| 7 | Staged validation | `tests/run.ps1` (all layers) |
| 8 | Hardening and idempotency | `tests/run.ps1` twice |

## Resuming from a handoff

If you need to restart from Step 3, for example:
1. Read the Step 3 handoff note to know what state was left.
2. Run `tests/validate-contract.ps1` — if it passes, Steps 1–2 are intact.
3. Run `tests/validate-tutorial-order.ps1` — if it passes, Step 3 is intact.
4. Run `scripts/teacher.ps1` — if it prints an IP, Step 4 is intact.
5. Continue from Step 5 forward.

You do not need to destroy and recreate everything. Only reset to the last valid checkpoint.

## Expected output
- The sequence runs in order from prerequisites to hardening.
- Each step can be resumed from its handoff.

## Verification
Run `powershell -File tests/run.ps1`.

## Recovery
If the sequence breaks, return to the last valid handoff instead of restarting from the beginning. Use `scripts/reset.ps1` only when the Terraform state cannot be trusted (e.g., the VM was deleted manually outside Terraform).
