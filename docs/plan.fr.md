# Lab Terraform Multipass bilingue

Ce document est le contrat de référence en français pour le lab.

## Objectif

Construire un tutoriel bilingue, orienté Windows, qui enseigne Terraform et l’infrastructure as code au moyen d’un lab local de machines virtuelles avec Multipass. Le lab doit rester découpé en étapes, préserver le contexte, et pouvoir être rejoué depuis n’importe quel point de validation approuvé.

## Règles du lab

- Garder une parité structurelle entre l’anglais et le français.
- Limiter chaque étape pour qu’elle puisse être validée indépendamment.
- Exiger qu’à chaque étape un artefact de transfert compact soit produit avant de continuer.
- Bloquer la progression tant que la validation de l’étape courante n’est pas réussie.
- Préférer une reprise locale de l’étape plutôt qu’un arrêt complet, sauf si l’état est corrompu.

## Modèle de transfert

Chaque étape doit laisser une note de transfert avec les champs suivants :

- Objectif
- Entrées
- Sorties
- Décisions
- Statut de validation
- Points ouverts

L’étape suivante doit consommer uniquement le transfert approuvé, l’état courant du dépôt, et les critères d’acceptation de sa propre étape.

## Modèle de récupération

- Si une étape échoue, isoler l’échec à cette étape.
- Relancer l’étape après correction du problème local.
- Utiliser le reset ou le teardown seulement si l’état courant n’est plus fiable.

## Étapes phasées

1. Établir le contrat du tutoriel et les règles de structure bilingue.
2. Définir la cible Terraform minimale exécutable pour une VM Multipass.
3. Ajouter cloud-init comme couche isolée et la valider séparément.
4. Ajouter les wrappers d’exécution et le comportement de reset.
5. Étendre vers la séquence pédagogique complète du lab.
6. Écrire les pages du tutoriel bilingue et la source GitBook.
7. Exécuter la validation par paliers sur les dépendances, les étapes, puis de bout en bout.
8. Durcir le lab contre la dérive lors des exécutions répétées.

## Critères d’acceptation

- L’étape 1 est terminée lorsque le contrat, le modèle de transfert, et les règles de structure bilingue sont documentés et validés.
- L’étape 2 est terminée lorsque Terraform s’initialise et se valide pour une cible Multipass à une VM.
- L’étape 3 est terminée lorsque cloud-init se parse seul et que le plan Terraform intégré reste valide.
- L’étape 4 est terminée lorsque les scripts d’exécution et le flux de reset peuvent exercer le lab mono-VM sans intervention manuelle.
- L’étape 5 est terminée lorsque la séquence complète du tutoriel s’exécute dans l’ordre et que chaque étape peut être reprise depuis son propre transfert.
- L’étape 6 est terminée lorsque les documents bilingues et la source GitBook dédiée correspondent au comportement exécutable, que la parité structurelle est conservée, et que les chemins de récupération sont explicites.
- L’étape 7 est terminée lorsque les validations de dépendances, d’étape, et de bout en bout passent toutes.
- L’étape 8 est terminée lorsque les exécutions répétées n’introduisent ni dérive ni échec inexpliqué.

## Ordre de validation

1. Vérifier les prérequis du dépôt.
2. Valider les fichiers de contrat.
3. Valider Terraform et cloud-init séparément.
4. Valider le chemin intégré mono-VM.
5. Valider les wrappers et les tests.
6. Valider la parité de la documentation bilingue.
7. Valider l’exécution complète du tutoriel.
8. Valider deux fois le teardown et le reset.
