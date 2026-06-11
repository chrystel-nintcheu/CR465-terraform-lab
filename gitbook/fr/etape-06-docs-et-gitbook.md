# Étape 6 : Docs et GitBook

## Objectif
Garder les pages du tutoriel et la source GitBook alignées avec le lab exécutable.

## Prérequis
- La validation de l’étape 5 est passée

## Qu'est-ce que GitBook ?

[GitBook](https://www.gitbook.com/) est une plateforme de documentation qui transforme des fichiers Markdown en un livre web lisible. Le répertoire `gitbook/` de ce dépôt est la source — il suit la structure attendue par GitBook :

- `gitbook/SUMMARY.md` — la table des matières. Chaque page doit y être listée.
- `gitbook/README.md` — la page d'accueil du livre.
- `gitbook/en/` — pages de tutoriel en anglais, un fichier par étape.
- `gitbook/fr/` — pages de tutoriel en français, un fichier par étape (structurellement identiques à `en/`).

### Rendu local

Pour prévisualiser le livre localement, installer le CLI GitBook :

```powershell
npm install -g gitbook-cli
cd gitbook
gitbook serve
```

Puis ouvrir `http://localhost:4000` dans un navigateur. Alternativement, publier sur gitbook.com en connectant le dépôt.

## Parité structurelle

La « parité structurelle » signifie que les deux versions linguistiques ont les mêmes sections dans le même ordre. Le script `tests/validate-tutorial-order.ps1` l'impose en vérifiant que chaque page anglaise a un équivalent français et que les deux contiennent les en-têtes requis (`## Objectif`, `## Vérification`, `## Récupération`).

### À quoi ressemble la « dérive »

La dérive documentaire survient quand le code change mais pas la doc. Exemples :
- Une nouvelle variable est ajoutée à `variables.tf` mais n'est mentionnée dans aucune page de tutoriel.
- La traduction française de l'étape 4 référence encore l'ancien nom de script après un renommage.
- `SUMMARY.md` liste une page qui n'existe plus.

La règle de correction est simple : **réparer la paire de pages divergente avant de changer autre chose**. Ne jamais laisser une langue prendre de l'avance sur l'autre.

## Contrôles effectués par la validation

`tests/validate-tutorial-order.ps1` vérifie :
1. Tous les scripts runners existent (`scripts/apply.ps1`, etc.)
2. Tous les fichiers Terraform existent (`terraform/main.tf`, etc.)
3. `versions.tf` utilise `todoroff/multipass`
4. `main.tf` contient les tokens requis et aucun motif interdit
5. Les 18 pages GitBook existent (9 anglaises + 9 françaises — incluant README et SUMMARY)
6. `SUMMARY.md` contient les tokens de navigation requis
7. Chaque page d'étape contient `## `, `Vérification` et `Récupération` (français)

## Sortie attendue
- Les pages anglaises et françaises restent alignées structurellement.
- Le sommaire GitBook reflète la progression du tutoriel.

## Vérification
Inspecter `gitbook/SUMMARY.md` et les pages, puis exécuter `powershell -File tests/run.ps1`.

## Récupération
En cas de dérive, corriger d'abord la paire de pages qui a divergé. Exécuter `tests/validate-tutorial-order.ps1` après chaque correction pour confirmer la résolution du problème avant de continuer.
