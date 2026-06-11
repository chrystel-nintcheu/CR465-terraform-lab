# Etape 08 : Demontage

La derniere etape verifie que `terraform destroy` supprime proprement toutes
les ressources et que le cycle peut etre repete sans derive ni etat residuel.

## Objectifs

- Executer `terraform destroy` et confirmer que toutes les VMs de lab ont disparu.
- Reappliquer et detruire une deuxieme fois pour confirmer l'idempotence.
- Verifier qu'aucune instance Multipass orpheline ne subsiste.

## Prerequis

- Etapes 01 a 07 terminees (les VMs peuvent etre en cours d'execution).

## Pourquoi le demontage est important

Un lab qui ne peut pas etre proprement detruit n'est pas pret pour la
production. Le modele declaratif de Terraform garantit que destroy + apply
produit le meme resultat a chaque fois -- ce test le prouve.

## Etapes

### 1. Detruire toutes les ressources

```powershell
Set-Location terraform
terraform destroy -auto-approve
```

Cela supprime les deux VMs (`cr465-lab` et `cr465-lab-db`), l'alias et toutes
les ressources de transfert de fichiers.

### 2. Verifier que les VMs ont disparu

```powershell
multipass list
```

Aucune VM de lab ne devrait apparaitre.

### 3. Reappliquer

```powershell
terraform apply -auto-approve
```

Les deux VMs sont recreees depuis zero.

### 4. Detruire a nouveau

```powershell
terraform destroy -auto-approve
```

Apply et destroy doivent reussir avec le code de sortie 0.

### 5. Executer le test automatise

```powershell
PowerShell -ExecutionPolicy Bypass -File tests/08-teardown.ps1
```

Le test effectue les deux cycles de destruction automatiquement.
Toutes les verifications doivent afficher `[PASS]`.

## Verification

`tests/08-teardown.ps1` se termine avec le code 0 et affiche `FAIL: 0`.

## Recuperation

| Symptome | Correction |
|----------|-----------|
| `terraform destroy` echoue | Executez `multipass delete --all --purge`, puis `terraform destroy -auto-approve`. |
| VM subsiste apres destroy | `multipass delete <nom> --purge`, puis `terraform apply` pour resynchroniser l'etat. |
| Incoherence d'etat | Executez `terraform refresh` puis relancez destroy. |
