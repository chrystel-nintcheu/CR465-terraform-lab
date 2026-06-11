# Étape 5 : Séquence complète

## Objectif
Transformer la preuve mono-VM en parcours pédagogique complet.

## Prérequis
- La validation de l’étape 4 est passée

## Ce que représente cette étape

Les étapes 1 à 4 ont construit la fondation mécanique : contrats, ressource Terraform fonctionnelle, provisionnement cloud-init, et scripts runners. L'étape 5 concerne la **composition de ces éléments en une séquence d'apprentissage reproductible**.

La discipline clé est le **transfert** : chaque étape doit laisser un artefact documenté avant que la suivante commence. Cela reflète les transferts SRE réels lors de la gestion d'incidents ou des pipelines de déploiement — l'ingénieur suivant (ou l'étape automatisée suivante) consomme uniquement les sorties approuvées, pas la connaissance implicite.

## L'artefact de transfert

Après chaque étape, enregistrer une note de transfert. Utiliser le modèle de `docs/plan.fr.md` :

```markdown
## Transfert : Étape N

- **Objectif** : Ce que cette étape cherchait à accomplir
- **Entrées** : Fichiers ou état consommés au départ
- **Sorties** : Artefacts produits
- **Décisions** : Choix effectués et justification
- **Statut de validation** : PASSÉ / ÉCHOUÉ
- **Points ouverts** : Éléments non résolus
```

Ce n'est pas de la bureaucratie — c'est le mécanisme qui permet à tout participant du lab de **reprendre depuis n'importe quel point de contrôle** sans relire l'historique complet.

## La séquence complète

| Étape | Concept central | Porte de validation |
|---|---|---|
| 1 | Contrat et structure bilingue | `tests/validate-contract.ps1` |
| 2 | Cycle de vie des ressources Terraform | `terraform validate && terraform plan` |
| 3 | cloud-init comme couche isolée | `tests/validate-tutorial-order.ps1` |
| 4 | Wrappers et comportement de reset | `scripts/teacher.ps1` après apply |
| 5 | Séquence ordonnée avec transferts | `tests/run.ps1` |
| 6 | Alignement docs et GitBook | `tests/run.ps1` + inspection manuelle |
| 7 | Validation par paliers | `tests/run.ps1` (toutes les couches) |
| 8 | Durcissement et idempotence | `tests/run.ps1` deux fois |

## Reprendre depuis un transfert

Si vous devez repartir de l'étape 3, par exemple :
1. Lire la note de transfert de l'étape 3 pour connaître l'état laissé.
2. Exécuter `tests/validate-contract.ps1` — si ça passe, les étapes 1 et 2 sont intactes.
3. Exécuter `tests/validate-tutorial-order.ps1` — si ça passe, l'étape 3 est intacte.
4. Exécuter `scripts/teacher.ps1` — si ça affiche une IP, l'étape 4 est intacte.
5. Continuer à partir de l'étape 5.

Il n'est pas nécessaire de tout détruire et recréer. Revenir uniquement au dernier point de contrôle valide.

## Sortie attendue
- La séquence s'exécute de bout en bout.
- Chaque étape peut être reprise depuis son transfert.

## Vérification
Exécuter `powershell -File tests/run.ps1`.

## Récupération
Si la séquence casse, revenir au dernier transfert valide au lieu de repartir du début. Utiliser `scripts/reset.ps1` uniquement lorsque l'état Terraform ne peut plus être fiable (ex. : la VM a été supprimée manuellement hors de Terraform).
