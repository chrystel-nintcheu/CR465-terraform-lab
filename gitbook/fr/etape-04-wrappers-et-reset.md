# Étape 4 : Wrappers et reset

## Objectif
Ajouter les scripts student, teacher, apply, destroy, et reset.

## Prérequis
- La validation de l'étape 3 est passée

## Les scripts runners

Tous les scripts chargent `scripts/common.ps1` en premier. Ce module définit `Set-StrictMode -Version Latest` et `$ErrorActionPreference = 'Stop'`, ce qui signifie que toute erreur non gérée lève une exception immédiatement plutôt que de continuer silencieusement. C'est intentionnel : **échouer bruyamment, échouer tôt**.

`common.ps1` fournit également trois utilitaires partagés :

| Fonction | Rôle |
|---|---|
| `Write-LabHeader -Title '...'` | Affiche une bannière cohérente pour faciliter la lecture des sorties |
| `Get-RepoRoot` | Retourne le chemin absolu de la racine du dépôt, indépendamment du répertoire de l'appelant |
| `Get-TerraformDir` | Retourne le chemin de `terraform/` — utilisé avant chaque commande `terraform` |

### Script étudiant (`scripts/student.ps1`)

```powershell
. "$PSScriptRoot/common.ps1"
Write-LabHeader -Title 'Student runner'
& "$PSScriptRoot/apply.ps1"
```

Le rôle de l'étudiant est simple : **appliquer le lab**. La vérification des prérequis et `terraform init` sont gérés dans `apply.ps1`.

### Apply (`scripts/apply.ps1`)

```powershell
& "$PSScriptRoot/check-prereqs.ps1" -Quiet
Set-Location (Get-TerraformDir)
terraform init -input=false
# LAB UNIQUEMENT : -auto-approve supprime la demande de confirmation.
terraform apply -auto-approve
```

> **Note production :** `-auto-approve` est utilisé ici pour éviter les invites interactives en environnement de lab. En production, toujours exécuter `terraform plan` d'abord, examiner le diff, puis lancer `terraform apply` sans `-auto-approve` pour être forcé à confirmer.

### Script enseignant (`scripts/teacher.ps1`)

Le rôle de l'enseignant est de **valider l'environnement** et d'inspecter les sorties en direct :

```powershell
terraform validate
$json = terraform output -json
$out = $json | ConvertFrom-Json
Write-Host "vm_name  : $($out.vm_name.value)"
Write-Host "ipv4     : $($out.ipv4.value -join ', ')"
Write-Host "lab_stage: $($out.lab_stage.value)"
```

`terraform output -json` retourne un objet JSON structuré. La valeur `ipv4` est une **liste** (une VM peut avoir plusieurs interfaces réseau), d'où l'utilisation de `-join ', '`. En pratique, la VM Multipass aura une seule adresse.

### Reset (`scripts/reset.ps1`)

Reset = destroy + apply. Cela modélise un concept SRE fondamental : l'**infrastructure immuable**. Au lieu de patcher une VM en production (ce qui accumule de la dérive), on la détruit et on la recrée à partir de l'état déclaré. La nouvelle VM est toujours dans un état propre et connu.

```powershell
& "$PSScriptRoot/destroy.ps1"
& "$PSScriptRoot/apply.ps1"
```

> **Note production :** `terraform destroy -auto-approve` est également réservé au lab. Les opérations destructives en production nécessitent une confirmation manuelle et souvent un processus d'approbation de changement.

## Sortie attendue
Après `scripts/teacher.ps1`, la sortie contient une adresse IPv4 réelle :
```
vm_name  : cr465-lab
ipv4     : 172.x.x.x
lab_stage: step-2-single-vm
```

Et `multipass list` affiche la VM en état `Running`.

## Vérification
Exécuter `powershell -File scripts/check-prereqs.ps1`, appliquer le lab, puis `powershell -File scripts/teacher.ps1`.

## Récupération
Si un wrapper échoue, corriger le script concerné sans toucher aux autres. La panne la plus fréquente est un problème de répertoire de travail — vérifier que `Get-TerraformDir` se résout correctement en l'exécutant en isolation :
```powershell
. scripts/common.ps1
Get-TerraformDir
```
