# Étape 8 : Durcissement

## Objectif
Supprimer la dérive et rendre les exécutions répétées déterministes.

## Prérequis
- La validation de l’étape 7 est passée

## Concepts clés

### Idempotence

Une opération est **idempotente** si l'exécuter une fois produit le même résultat que l'exécuter dix fois. L'idempotence est une propriété fondamentale de l'automatisation d'infrastructure : si votre pipeline s'exécute deux fois à cause d'une reprise, il ne doit rien casser.

En termes Terraform : après `terraform apply`, relancer `terraform apply` doit produire **aucun changement**. Si la deuxième exécution modifie ou recrée des ressources, votre configuration n'est pas idempotente.

### Dérive de configuration

La **dérive** survient lorsque l'état réel de votre infrastructure diverge de l'état que Terraform a enregistré. Causes courantes :
- Quelqu'un a exécuté `multipass stop cr465-lab` ou supprimé la VM manuellement (hors Terraform).
- Un fournisseur cloud a mis à jour un attribut géré automatiquement (patch OS, réassignation IP).
- Le fichier d'état Terraform a été supprimé ou corrompu.

Quand une dérive survient, `terraform plan` montre des changements inattendus. La bonne réponse est d'examiner le diff : soit laisser Terraform converger vers l'état déclaré (exécuter `terraform apply`), soit mettre à jour le code Terraform pour refléter un changement intentionnel.

### Ce que « durcissement » signifie en IaC

Durcir une base de code IaC signifie la rendre **résistante aux exécutions répétées, aux échecs partiels et aux variations d'environnement**. Pour ce lab, le durcissement signifie :

1. Le flux `reset` (destroy + apply) se termine avec succès à chaque fois sans intervention manuelle.
2. `terraform plan` après un `apply` réussi affiche zéro changement.
3. `tests/run.ps1` passe à la première exécution et à chaque exécution suivante.
4. Les fichiers d'état ne sont jamais commités dans git (la dérive entre état local et d'équipe est prévenue).

## Le test à deux exécutions

Exécuter `tests/run.ps1` deux fois de suite est la vérification minimale d'idempotence :

```powershell
powershell -File tests/run.ps1   # Première exécution : init, validate, plan — doit passer
powershell -File tests/run.ps1   # Deuxième exécution : mêmes commandes, même résultat
```

Si la deuxième exécution produit un résultat différent (ex. : nouveau téléchargement de provider, plan modifié), vous avez un élément non déterministe à corriger. Corrections courantes :
- Épingler les versions de provider précisément (utiliser `= 1.7.x` plutôt que `~> 1.7`).
- Épingler l'image Multipass à une version spécifique (utiliser `"24.04"` plutôt que `"lts"`).
- S'assurer que `terraform init -upgrade` ne télécharge pas un provider plus récent entre les exécutions.

## Idempotence du reset

Tester le cycle de reset complet :

```powershell
powershell -File scripts/reset.ps1   # destroy + apply — doit se terminer proprement
powershell -File scripts/reset.ps1   # deuxième reset — doit aussi réussir
```

Après les deux resets, `multipass list` doit afficher exactement une instance en cours d'exécution nommée `cr465-lab`.

## Sortie attendue
- Le flux de reset est reproductible.
- Le script de validation reste vert au rerun.
- `terraform plan` après apply affiche : `No changes. Your infrastructure matches the configuration.`

## Vérification
Exécuter `powershell -File tests/run.ps1` deux fois.

## Récupération
Si un rerun échoue, corriger la plus petite zone affectée et retester. Ne pas introduire de contournements qui ne traitent que le symptôme — remonter jusqu'à la cause racine et la corriger. Une infrastructure non déterministe est un risque de fiabilité.

## Vérification
Exécuter `powershell -File tests/run.ps1` deux fois.

## Récupération
Si un rerun échoue, corriger la plus petite zone affectée puis retester.
