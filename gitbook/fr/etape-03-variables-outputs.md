# Etape 03 : Variables et outputs

Les variables Terraform permettent de parametriser votre infrastructure sans
toucher le code HCL. Les outputs exposent les valeurs de vos ressources
deployees pour les utiliser dans des scripts, des pipelines CI, ou d'autres
modules Terraform.

## Objectifs

- Creer un fichier `terraform.tfvars` pour personnaliser le deploiement.
- Comprendre comment `variables.tf` declare les entrees et `outputs.tf` expose les resultats.
- Lire les trois outputs : `vm_name`, `ipv4`, `lab_stage`.

## Prerequis

- Etape 01 (Premiere VM) reussie et la VM en etat Running.

## Etapes

### 1. Creer terraform.tfvars

```powershell
Copy-Item terraform/terraform.tfvars.example terraform/terraform.tfvars
```

Ouvrez `terraform/terraform.tfvars` et passez en revue les valeurs par defaut.
Vous pouvez modifier `vm_name`, `cpus`, `memory`, `disk` ou `lab_stage`.

### 2. Reappliquer (si vous avez modifie des valeurs)

```powershell
Set-Location terraform
terraform apply -auto-approve
```

Si vous n'avez rien modifie, l'application n'effectue aucun changement.

### 3. Lister tous les outputs

```powershell
terraform output
```

Vous devriez voir `vm_name`, `ipv4` et `lab_stage`.

### 4. Lire un seul output

```powershell
terraform output -raw vm_name
terraform output -raw lab_stage
```

### 5. Lire les outputs en JSON (utile pour les scripts)

```powershell
terraform output -json
```

### 6. Executer le test automatise

```powershell
PowerShell -ExecutionPolicy Bypass -File tests/03-variables-outputs.ps1
```

Toutes les verifications doivent afficher `[PASS]`.

## Verification

`tests/03-variables-outputs.ps1` se termine avec le code 0 et affiche `FAIL: 0`.

## Recuperation

| Symptome | Correction |
|----------|-----------|
| `terraform output` ne retourne rien | La VM n'a peut-etre pas ete appliquee. Executez `terraform apply`. |
| `terraform.tfvars` manquant | Copiez depuis `terraform.tfvars.example`. |
| `ipv4` est vide | Le reseau cloud-init n'est peut-etre pas pret. Attendez 30 secondes et reessayez. |
