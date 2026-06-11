# Etape 02 : Cloud-init

Cloud-init est le systeme d'initialisation standard des VM Linux. Lorsque
Terraform applique votre `multipass_instance`, il transmet le gabarit
`user-data.yaml.tftpl` a Multipass, qui le transfère a cloud-init dans la VM.

## Objectifs

- Comprendre ce que fait cloud-init au premier demarrage.
- Verifier que les paquets ont ete installes.
- Lire les fichiers marqueurs laisses par cloud-init.

## Prerequis

- Etape 01 (Premiere VM) reussie et la VM en etat Running.

## Ce que fait cloud-init dans ce lab

Le gabarit `cloud-init/user-data.yaml.tftpl` :

1. Met a jour la liste des paquets (`package_update: true`).
2. Installe `git` et `curl`.
3. Ecrit `/etc/cr465-lab.txt` avec les metadonnees du hostname et de l'etape.
4. Cree `/var/tmp/cr465-lab-ready.txt` via une commande `runcmd`.

## Etapes

### 1. Inspecter le gabarit

Ouvrez `cloud-init/user-data.yaml.tftpl` dans votre editeur.
Notez les variables `${hostname}` et `${lab_stage}` -- elles sont remplies par
la fonction `templatefile()` de Terraform avant le lancement de la VM.

### 2. Verifier les paquets dans la VM

```powershell
multipass exec cr465-lab -- which git
multipass exec cr465-lab -- which curl
```

Les deux commandes doivent retourner un chemin comme `/usr/bin/git`.

### 3. Lire le fichier marqueur

```powershell
multipass exec cr465-lab -- cat /var/tmp/cr465-lab-ready.txt
```

Sortie attendue : `CR465 lab ready` suivi d'un horodatage.

### 4. Lire les metadonnees du lab

```powershell
multipass exec cr465-lab -- cat /etc/cr465-lab.txt
```

Vous devriez voir le hostname (`cr465-lab`) et l'etape du lab.

### 5. Executer le test automatise

```powershell
PowerShell -ExecutionPolicy Bypass -File tests/02-cloud-init.ps1
```

Toutes les verifications doivent afficher `[PASS]`.

## Verification

`tests/02-cloud-init.ps1` se termine avec le code 0 et affiche `FAIL: 0`.

## Recuperation

| Symptome | Correction |
|----------|-----------|
| `git`/`curl` introuvable | cloud-init n'a peut-etre pas fini. Attendez et reessayez, ou executez `multipass exec cr465-lab -- cloud-init status`. |
| Fichier marqueur absent | Verifiez `multipass exec cr465-lab -- cloud-init status --wait`. |
| Hostname incorrect | Detruisez et reapliquez : `terraform destroy -auto-approve; terraform apply -auto-approve`. |
