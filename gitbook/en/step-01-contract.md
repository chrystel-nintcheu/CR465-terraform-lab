# Step 1: Contract

## Goal
Establish the bilingual lab contract, the handoff format, and the validation gates.

## Context

This lab teaches **Infrastructure as Code (IaC)** using [Terraform](https://developer.hashicorp.com/terraform) and [Multipass](https://multipass.run/).

**Multipass** is a lightweight VM manager from Canonical that spins up Ubuntu VMs on Windows, macOS, or Linux in seconds — no cloud account required. It is the local "cloud" for this lab.

**Terraform** is a declarative tool: you describe the desired state of your infrastructure in HCL (HashiCorp Configuration Language) and Terraform figures out what API calls to make to reach that state. The key insight is that you describe *what* you want, not *how* to build it.

**Why bilingual?** This lab is designed for bilingual classrooms. Every tutorial page exists in English and French with identical structure. The validation scripts enforce parity so the two versions never drift apart.

## Prerequisites

Install these tools before running any lab command.

### Terraform ≥ 1.6

```powershell
# Verify after install
terraform version
```

Download from: https://developer.hashicorp.com/terraform/install

On Windows, the recommended approach is to use [Chocolatey](https://chocolatey.org/):
```powershell
choco install terraform
```

### Multipass

```powershell
multipass version
```

Download from: https://multipass.run/install

### PowerShell

The scripts use PowerShell. Both Windows PowerShell 5.1 (`powershell.exe`) and PowerShell Core (`pwsh.exe`) work. Verify with:

```powershell
$PSVersionTable.PSVersion
```

## What the contract documents

- `docs/plan.md` — the English contract: lab purpose, rules, handoff template, phased steps, and acceptance criteria in human-readable form.
- `docs/plan.fr.md` — the French version, structurally identical.
- `docs/acceptance-criteria.yaml` — machine-readable gate definitions, one entry per step. The validation scripts read this file directly.

### The handoff template

Every step must produce a handoff note before the next step starts:

| Field | Purpose |
|---|---|
| Goal | What this step was trying to achieve |
| Inputs | Files or state consumed at the start |
| Outputs | Artifacts produced |
| Decisions | Choices made and why |
| Validation status | Did the acceptance check pass? |
| Open issues | Anything left unresolved |

This discipline is borrowed from SRE incident management: each change window has a clear scope, a clear outcome, and a clear handoff to the next team or next phase.

## Expected output
- The English and French contracts match structurally.
- The machine-readable acceptance criteria lists eight steps.

## Verification

Run only the contract validation at this step (not the full suite, which requires Terraform and a working VM):

```powershell
powershell -File tests/validate-contract.ps1
```

Expected output:
```
Contract validation passed.
```

## Recovery
If the contract drifts, repair the English and French docs together and rerun the validation. The two plan files must always have the same number of `##` headings and numbered list items.
