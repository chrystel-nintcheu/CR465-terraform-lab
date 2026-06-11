# Bilingual Terraform Multipass Lab

This document is the authoritative English contract for the lab.

## Purpose

Build a Windows-first, bilingual tutorial that teaches Terraform and infrastructure as code through a local VM lab using Multipass. The lab must stay step-gated, context-preserving, and safe to rerun from any validated checkpoint.

## Lab Rules

- Keep the tutorial bilingual with structural parity between English and French.
- Keep each step small enough to validate independently.
- Require every step to produce a compact handoff artifact before the next step starts.
- Block progression until the current step validation passes.
- Prefer recovery at the current step over a full teardown unless state is corrupted.

## Handoff Template

Every step must leave a handoff note with these fields:

- Goal
- Inputs
- Outputs
- Decisions
- Validation status
- Open issues

The next step must consume only the approved handoff, the current repository state, and the next step acceptance criteria.

## Recovery Model

- If a step fails, isolate the failure to that step.
- Re-run the step after correcting the local issue.
- Use reset or teardown only when the current state cannot be trusted.

## Phased Steps

1. Establish the tutorial contract and the bilingual structure rules.
2. Define the smallest runnable Terraform target for one Multipass VM.
3. Add cloud-init as an isolated layer and validate it independently.
4. Add execution wrappers and reset behavior.
5. Expand to the full pedagogical lab sequence.
6. Write the bilingual tutorial pages and GitBook source.
7. Run staged validation across dependency, step-level, and end-to-end checks.
8. Harden the lab against repeated execution drift.

## Acceptance Criteria

- Step 1 is done when the contract, handoff template, and bilingual structure rules are documented and agreed.
- Step 2 is done when Terraform initializes and validates for a one-VM Multipass target.
- Step 3 is done when cloud-init parses on its own and the integrated Terraform plan still validates.
- Step 4 is done when the runner scripts and reset flow can exercise the single-VM lab without manual intervention.
- Step 5 is done when the full tutorial sequence runs in order and each step can be resumed from its own handoff.
- Step 6 is done when bilingual docs and the dedicated GitBook source both match executable behavior, structural parity is preserved, and recovery paths are explicit.
- Step 7 is done when dependency, step-level, and end-to-end validation all pass.
- Step 8 is done when repeated execution does not introduce drift or unexplained failures.

## Validation Order

1. Check repository prerequisites.
2. Validate contract files.
3. Validate Terraform and cloud-init independently.
4. Validate the integrated single-VM path.
5. Validate runners and tests.
6. Validate bilingual documentation parity.
7. Validate the full tutorial execution.
8. Validate teardown and reset twice.
