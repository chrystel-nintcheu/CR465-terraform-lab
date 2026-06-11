# Étape 1 : Contrat

## Objectif
Établir le contrat bilingue, le format de transfert, et les points de contrôle de validation.

## Contexte

Ce lab enseigne l'**Infrastructure as Code (IaC)** avec [Terraform](https://developer.hashicorp.com/terraform) et [Multipass](https://multipass.run/).

**Multipass** est un gestionnaire de VMs léger de Canonical qui crée des VMs Ubuntu sur Windows, macOS ou Linux en quelques secondes — sans compte cloud. C'est le « cloud local » de ce lab.

**Terraform** est un outil déclaratif : vous décrivez l'état souhaité de votre infrastructure en HCL (HashiCorp Configuration Language) et Terraform détermine les appels API nécessaires pour l'atteindre. Le concept clé : vous décrivez *ce que* vous voulez, pas *comment* le construire.

**Pourquoi bilingue ?** Ce lab est conçu pour des salles de classe bilingues. Chaque page de tutoriel existe en anglais et en français avec une structure identique. Les scripts de validation imposent la parité pour que les deux versions ne divergent jamais.

## Prérequis

Installez ces outils avant d'exécuter toute commande du lab.

### Terraform ≥ 1.6

```powershell
# Vérifier après installation
terraform version
```

Téléchargement : https://developer.hashicorp.com/terraform/install

Sur Windows, l'approche recommandée est [Chocolatey](https://chocolatey.org/) :
```powershell
choco install terraform
```

### Multipass

```powershell
multipass version
```

Téléchargement : https://multipass.run/install

### PowerShell

Les scripts utilisent PowerShell. Windows PowerShell 5.1 (`powershell.exe`) et PowerShell Core (`pwsh.exe`) fonctionnent tous les deux. Vérifier avec :

```powershell
$PSVersionTable.PSVersion
```

## Ce que le contrat documente

- `docs/plan.fr.md` — le contrat français : objectif, règles, modèle de transfert, étapes et critères d'acceptation.
- `docs/plan.md` — la version anglaise, structurellement identique.
- `docs/acceptance-criteria.yaml` — définitions de portes lisibles par machine, une entrée par étape. Les scripts de validation lisent ce fichier directement.

### Le modèle de transfert

Chaque étape doit produire une note de transfert avant que la suivante commence :

| Champ | Rôle |
|---|---|
| Objectif | Ce que cette étape cherchait à accomplir |
| Entrées | Fichiers ou état consommés au départ |
| Sorties | Artefacts produits |
| Décisions | Choix effectués et justification |
| Statut de validation | PASSÉ / ÉCHOUÉ |
| Points ouverts | Éléments non résolus |

Cette discipline est empruntée à la gestion d'incidents SRE : chaque fenêtre de changement a un périmètre clair, un résultat clair, et un transfert clair vers l'équipe ou la phase suivante.

## Sortie attendue
- Les contrats anglais et français restent structurellement identiques.
- Le fichier de critères d'acceptation contient huit étapes.

## Vérification

À cette étape, exécuter uniquement la validation du contrat (pas la suite complète, qui nécessite Terraform et une VM) :

```powershell
powershell -File tests/validate-contract.ps1
```

Sortie attendue :
```
Contract validation passed.
```

## Récupération
Si le contrat dérive, corriger ensemble les deux documents puis relancer la validation. Les deux fichiers plan doivent toujours avoir le même nombre de sections `##` et de lignes numérotées.
