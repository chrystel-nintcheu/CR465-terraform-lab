# Etape 07 : Multi-VM

Jusqu'a present, le lab gerait une seule VM. Dans cette etape, vous ajoutez
une deuxieme instance (`cr465-lab-db`) qui depend de la premiere. Le
`depends_on` de Terraform garantit que la VM web est entierement creee avant
que la VM base de donnees ne demarre.

## Objectifs

- Ajouter une deuxieme `multipass_instance` avec `depends_on`.
- Verifier que les deux VMs sont en etat Running.
- Lire les deux adresses IPv4 depuis `terraform output`.

## Prerequis

- Etape 01 (Premiere VM) reussie.

## Ce qui a ete ajoute a main.tf

```hcl
resource "multipass_instance" "db" {
  name   = "${var.vm_name}-db"
  image  = var.image
  cpus   = 1
  memory = "1G"
  disk   = "5G"

  cloud_init = templatefile("${path.module}/../cloud-init/user-data.yaml.tftpl", {
    hostname  = "${var.vm_name}-db"
    lab_stage = "step-7-multi-vm-db"
  })

  depends_on = [multipass_instance.lab]
}
```

Et deux nouveaux outputs dans `outputs.tf` :

```hcl
output "db_vm_name" { value = multipass_instance.db.name }
output "db_ipv4"    { value = multipass_instance.db.ipv4 }
```

## Etapes

### 1. Appliquer (cree la VM DB)

```powershell
Set-Location terraform
terraform apply -auto-approve
```

Cela peut prendre 2 a 5 minutes.

### 2. Verifier que les deux VMs sont en marche

```powershell
multipass list
```

`cr465-lab` et `cr465-lab-db` doivent afficher `Running`.

### 3. Lire les deux IPs

```powershell
terraform output
```

Vous devriez voir `ipv4`, `db_ipv4`, `db_vm_name`, `vm_name` et `lab_stage`.

### 4. Executer le test automatise

```powershell
PowerShell -ExecutionPolicy Bypass -File tests/07-multi-vm.ps1
```

Toutes les verifications doivent afficher `[PASS]`.

## Verification

`tests/07-multi-vm.ps1` se termine avec le code 0 et affiche `FAIL: 0`.

## Recuperation

| Symptome | Correction |
|----------|-----------|
| VM DB bloquee en `Starting` | Attendez 3 minutes ; puis `multipass restart cr465-lab-db`. |
| Erreur `depends_on` | Assurez-vous que la VM web a ete appliquee correctement avant de relancer apply. |
| Une seule VM dans l'etat | Executez `terraform apply` a nouveau -- c'est idempotent. |
