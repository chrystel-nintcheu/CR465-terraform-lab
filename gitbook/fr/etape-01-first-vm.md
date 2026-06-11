# Etape 01 : Premiere VM

Dans cette etape, vous utilisez Terraform pour declarer, initialiser et
appliquer une machine virtuelle Multipass. Terraform gere l'ensemble du
cycle de vie.

## Objectifs

- Executer `terraform init` pour telecharger le fournisseur Multipass.
- Executer `terraform apply` pour creer la VM.
- Confirmer que la VM apparait dans `multipass list`.
- Ouvrir un terminal dans la VM en cours d'execution.

## Prerequis

- Etape 00 (verification prealable) reussie.
- Un fichier `terraform/terraform.tfvars` (copie depuis `terraform.tfvars.example`).

## Etapes

### 1. Copier le fichier d'exemple

```powershell
Copy-Item terraform/terraform.tfvars.example terraform/terraform.tfvars
```

Modifiez `terraform.tfvars` si vous souhaitez un nom ou une taille differente.

### 2. Initialiser Terraform

```powershell
Set-Location terraform
terraform init
```

Attendu : `Terraform has been successfully initialized!`

### 3. Previsualiser le plan

```powershell
terraform plan
```

Examinez les ressources que Terraform va creer.

### 4. Appliquer

```powershell
terraform apply
```

Tapez `yes` a l'invite (ou utilisez `-auto-approve` pour les executions scriptees).
Le telechargement de l'image Ubuntu LTS et le lancement de la VM prennent 2 a 5 minutes.

### 5. Verifier que la VM est en marche

```powershell
multipass list
```

Vous devriez voir `cr465-lab` dans l'etat `Running`.

### 6. Ouvrir un terminal

```powershell
multipass shell cr465-lab
```

Tapez `exit` pour quitter le terminal de la VM.

### 7. Executer le test automatise

```powershell
PowerShell -ExecutionPolicy Bypass -File tests/01-first-vm.ps1
```

Toutes les verifications doivent afficher `[PASS]`.

## Verification

`tests/01-first-vm.ps1` se termine avec le code 0 et affiche `FAIL: 0`.

## Recuperation

| Symptome | Correction |
|----------|-----------|
| `terraform apply` echoue | Executez `terraform destroy -auto-approve`, puis relancez apply. |
| VM bloquee en `Starting` | Attendez 2 minutes ; si toujours bloquee, executez `multipass restart cr465-lab`. |
| Fournisseur introuvable | Supprimez `terraform/.terraform` et relancez `terraform init`. |
