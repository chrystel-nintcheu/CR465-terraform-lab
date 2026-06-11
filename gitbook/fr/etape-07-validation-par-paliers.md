# Étape 7 : Validation par paliers

## Objectif
Valider le lab par couches : prérequis, contrats, intégration, puis fin à fin.

## Prérequis
- La validation de l’étape 6 est passée

## Pourquoi valider par paliers ?

Un test monolithique qui essaie de tout faire d'un coup est difficile à déboguer : en cas d'échec, on ne sait pas *où* il a échoué. La validation par paliers divise la surface de test en couches, chacune conditionnant la suivante :

```
Couche 1 : Vérification des dépendances  → outils installés ?
Couche 2 : Vérification du contrat       → docs structurellement corrects ?
Couche 3 : Validation Terraform          → HCL valide, provider disponible ?
Couche 4 : Plan de bout en bout          → infrastructure déclarée proprement ?
```

Quand une couche échoue, on s'arrête là et on corrige avant de lancer les couches plus profondes. C'est la même logique qu'une liste de contrôle pré-vol.

## Ce que fait `tests/run.ps1`

```powershell
# Couche 1 : contrat
& "$PSScriptRoot/validate-contract.ps1"

# Couche 2 : structure des tutoriels
& "$PSScriptRoot/validate-tutorial-order.ps1"

# Couche 3 : disponibilité des outils
& "$PSScriptRoot/../scripts/check-prereqs.ps1"

# Couche 4 : Terraform
Set-Location (Get-TerraformDir)
terraform init -input=false -upgrade
terraform validate
terraform plan -input=false -detailed-exitcode
$planExit = $LASTEXITCODE
if ($planExit -eq 1) { throw 'terraform plan returned an error.' }
```

Note : `terraform plan -detailed-exitcode` retourne :
- **0** — aucun changement (la VM correspond déjà à l'état)
- **1** — erreur
- **2** — changements en attente (VM pas encore créée)

Le code de sortie 2 est valide : il signifie que la configuration est correcte mais que la VM n'a pas encore été appliquée. Les codes 0 et 2 indiquent tous les deux une configuration saine.

## Ce que vérifie `tests/validate-contract.ps1`

- Les fichiers requis existent : `docs/plan.md`, `docs/plan.fr.md`, `docs/acceptance-criteria.yaml`
- `acceptance-criteria.yaml` contient exactement 8 entrées d'étapes
- Les deux fichiers plan ont exactement 7 sections `##` de haut niveau et 16 lignes numérotées

Les contrôles numériques (7 sections, 16 lignes) sont des invariants structurels du contrat. Si vous devez modifier la structure du contrat, mettez à jour ces contrôles dans le script de validation en même temps.

## Ce que vérifie `tests/validate-tutorial-order.ps1`

- Tous les scripts runners existent
- Tous les fichiers Terraform existent et contiennent les tokens requis
- Les 18 pages GitBook existent
- Chaque page contient la structure d'en-têtes requise

## Sortie attendue
- Les contrôles de dépendances passent.
- Les contrôles de contrat et d'ordre passent.
- La validation Terraform passe.

## Vérification
Exécuter `powershell -File tests/run.ps1`.

## Récupération
Ne pas avancer au-delà d'une couche en échec ; corriger d'abord la panne la plus étroite. Le message d'erreur de chaque contrôle nomme le fichier ou le token spécifique qui est manquant ou incorrect.
