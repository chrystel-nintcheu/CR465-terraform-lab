# Etape 05 : Transferts de fichiers

Les ressources Terraform `multipass_file_upload` et `multipass_file_download`
permettent de deplacer des fichiers entre l'hote et une VM en cours d'execution
via `multipass transfer`. C'est une alternative native a Terraform aux
provisionneurs `null_resource`.

## Objectifs

- Utiliser `multipass_file_upload` pour pousser un fichier hote dans la VM.
- Utiliser `multipass_file_download` pour recuperer un fichier de la VM sur l'hote.
- Verifier que les deux fichiers existent a leurs destinations.

## Prerequis

- Etape 01 (Premiere VM) reussie et la VM en etat Running.

## Ce qui a ete ajoute a main.tf

```hcl
resource "multipass_file_upload" "lab_file" {
  instance    = multipass_instance.lab.name
  destination = "/tmp/lab-file.yaml"
  source      = "${path.module}/../cloud-init/user-data-fresh.yaml"
}

resource "multipass_file_download" "lab_ready" {
  instance       = multipass_instance.lab.name
  source         = "/var/tmp/cr465-lab-ready.txt"
  destination    = "${path.module}/../results/cr465-lab-ready.txt"
  create_parents = true
  overwrite      = true
}
```

## Etapes

### 1. Appliquer les ressources de transfert de fichiers

```powershell
Set-Location terraform
terraform apply -auto-approve
```

### 2. Verifier le fichier uploade dans la VM

```powershell
multipass exec cr465-lab -- ls -la /tmp/lab-file.yaml
```

### 3. Verifier le fichier telecharge sur l'hote

```powershell
Get-Content results/cr465-lab-ready.txt
```

### 4. Executer le test automatise

```powershell
PowerShell -ExecutionPolicy Bypass -File tests/05-file-transfers.ps1
```

Toutes les verifications doivent afficher `[PASS]`.

## Verification

`tests/05-file-transfers.ps1` se termine avec le code 0 et affiche `FAIL: 0`.

## Recuperation

| Symptome | Correction |
|----------|-----------|
| Upload echoue | Verifiez que `cloud-init/user-data-fresh.yaml` existe sur l'hote. |
| Download echoue | Verifiez que `/var/tmp/cr465-lab-ready.txt` existe dans la VM (executez Etape 02 d'abord). |
| Contenu incorrect | Supprimez le fichier local et relancez `terraform apply`. |
