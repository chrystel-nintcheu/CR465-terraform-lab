# Etape 00 : Verification prealable

Avant de lancer une machine virtuelle, verifiez que chaque outil requis est
installe et que votre environnement repond aux exigences minimales.

## Objectifs

- Confirmer que Terraform >= 1.6 est dans le PATH.
- Confirmer que Multipass est installe et accessible.
- Confirmer au moins 5 Go d'espace disque libre.
- Confirmer l'acces reseau a `cloud-images.ubuntu.com`.

## Prerequis

| Outil | Version minimale | Installation |
|-------|-----------------|--------------|
| [Terraform](https://developer.hashicorp.com/terraform/install) | 1.6 | `choco install terraform` |
| [Multipass](https://multipass.run) | toute | telecharger sur multipass.run |
| PowerShell | 5.1 (integre Windows) | -- |

## Etapes

### 1. Verifier Terraform

```powershell
terraform version
```

La sortie doit commencer par `Terraform v1.6` ou superieur.

### 2. Verifier Multipass

```powershell
multipass version
```

La sortie doit afficher `multipass X.Y.Z`.

### 3. Verifier l'espace disque

```powershell
(Get-PSDrive C).Free / 1GB
```

La valeur doit etre au moins `5`.

### 4. Verifier le reseau

```powershell
Test-NetConnection -ComputerName cloud-images.ubuntu.com -Port 443
```

`TcpTestSucceeded` doit etre `True`.

### 5. Executer la verification automatique

```powershell
PowerShell -ExecutionPolicy Bypass -File tests/00-preflight.ps1
```

Toutes les verifications doivent afficher `[PASS]`.

## Verification

Executez `tests/00-preflight.ps1`. Le script se termine avec le code 0 et affiche `FAIL: 0`.

## Recuperation

| Symptome | Correction |
|----------|-----------|
| `terraform: command not found` | Ajoutez Terraform au PATH et rouvrez le terminal. |
| `multipass: command not found` | Installez Multipass et redemarrez le terminal. |
| Disque < 5 Go | Liberez de l'espace ou utilisez un autre lecteur. |
| Echec du test reseau | Verifiez le pare-feu / proxy pour `cloud-images.ubuntu.com:443`. |
