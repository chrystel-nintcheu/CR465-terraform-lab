# Etape 04 : Alias

Un alias Multipass est un raccourci cote hote qui execute une commande dans une
instance nommee. Terraform le gere comme une ressource `multipass_alias`, donc
l'alias est cree avec la VM et detruit quand la VM est detruite.

## Objectifs

- Comprendre ce que `multipass_alias` cree.
- Lister les alias enregistres.
- Invoquer l'alias depuis n'importe quel repertoire sur l'hote.

## Prerequis

- Etape 01 (Premiere VM) reussie et la VM en etat Running.

## Etapes

### 1. Inspecter la definition de l'alias dans Terraform

Ouvrez `terraform/main.tf`. Trouvez le bloc `multipass_alias` :

```hcl
resource "multipass_alias" "shell" {
  name     = "${var.vm_name}-shell"
  instance = multipass_instance.lab.name
  command  = "bash"
}
```

Le nom de l'alias est `cr465-lab-shell`. Il execute `bash` dans `cr465-lab`.

### 2. Lister tous les alias

```powershell
multipass aliases
```

Vous devriez voir `cr465-lab-shell` associe a `bash` dans `cr465-lab`.

### 3. Utiliser l'alias

```powershell
multipass exec cr465-lab -- bash --login
```

Tapez `exit` pour quitter le terminal de la VM.

### 4. Executer le test automatise

```powershell
PowerShell -ExecutionPolicy Bypass -File tests/04-aliases.ps1
```

Toutes les verifications doivent afficher `[PASS]`.

## Verification

`tests/04-aliases.ps1` se termine avec le code 0 et affiche `FAIL: 0`.

## Recuperation

| Symptome | Correction |
|----------|-----------|
| Alias introuvable | Executez `terraform apply -auto-approve` pour recreer les ressources. |
| Alias pointe vers la mauvaise instance | Detruisez et reapliquez : `terraform destroy -auto-approve` puis `terraform apply -auto-approve`. |
