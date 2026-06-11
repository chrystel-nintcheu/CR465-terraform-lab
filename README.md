# CR465-terraform-lab

Tutoriel bilingue Terraform et Multipass, orienté Windows.
Provider: [`todoroff/multipass`](https://registry.terraform.io/providers/todoroff/multipass/latest) — `multipass_instance`, `multipass_alias`

Execution order:

1. Read the contract in [docs/plan.md](docs/plan.md) and [docs/plan.fr.md](docs/plan.fr.md).
2. Check the machine-readable contract in [docs/acceptance-criteria.yaml](docs/acceptance-criteria.yaml).
3. Run the lab checks with [tests/run.ps1](tests/run.ps1).
4. Use [scripts/reset.ps1](scripts/reset.ps1) when you need a clean Multipass VM state.

Start here:

- [English contract](docs/plan.md)
- [Contrat français](docs/plan.fr.md)
- [Acceptance criteria](docs/acceptance-criteria.yaml)

Runnable assets:

- [Terraform root](terraform)
- [Cloud-init template](cloud-init)
- [PowerShell runners](scripts)
- [Validation tests](tests)
- [GitBook source](gitbook)


