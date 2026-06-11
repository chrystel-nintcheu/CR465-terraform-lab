# Étape 3 : cloud-init isolé

## Objectif
Garder cloud-init indépendant pour pouvoir le contrôler avant l’intégration.

## Prérequis
- La validation de l’étape 2 est passée

## Qu'est-ce que cloud-init ?

[cloud-init](https://cloudinit.readthedocs.io/) est l'outil standard pour initialiser des instances de VM. Quand Multipass crée une VM, il passe votre YAML cloud-init à l'image Ubuntu. L'OS le lit au premier démarrage et exécute les actions déclarées : installer des paquets, écrire des fichiers, exécuter des commandes, créer des utilisateurs, etc.

Cloud-init s'exécute exactement **une fois**, au premier démarrage. Il ne se relance pas au redémarrage. Pour re-provisionner, il faut détruire et recréer la VM.

## Le fichier modèle

La source cloud-init du lab est `cloud-init/user-data.yaml.tftpl`. L'extension `.tftpl` signale que c'est un **modèle Terraform** — il utilise la syntaxe d'interpolation `${ }` et doit être rendu par `templatefile()` avant utilisation.

```yaml
#cloud-config
package_update: true
package_upgrade: false
packages:
  - git
  - curl
write_files:
  - path: /etc/cr465-lab.txt
    permissions: '0644'
    content: |
      CR465 Terraform Multipass Lab
      Hostname  : ${hostname}
      Lab stage : ${lab_stage}
      ...
runcmd:
  - echo 'CR465 lab ready' > /var/tmp/cr465-lab-ready.txt
```

### Variables du modèle

| Variable | Origine | Rôle |
|---|---|---|
| `${hostname}` | `var.vm_name` dans `terraform/main.tf` | Écrit dans le fichier d'identité de la VM |
| `${lab_stage}` | `var.lab_stage` | Étiquette l'étape de provisionnement |

Dans `terraform/main.tf` :
```hcl
cloud_init = templatefile("${path.module}/../cloud-init/user-data.yaml.tftpl", {
  hostname  = var.vm_name
  lab_stage = var.lab_stage
})
```

`templatefile()` rend le modèle à la planification/application et passe la chaîne YAML résultante au provider. Aucun fichier intermédiaire n'est écrit sur le disque — tout reste en mémoire dans le processus Terraform.

### Pourquoi isoler cloud-init ?

Le modèle doit être un YAML valide *avant* la substitution des variables `${...}`. Garder cloud-init dans son propre répertoire permet de valider la structure du modèle indépendamment de Terraform. C'est le principe SRE de **détection au plus tôt** : repérer une erreur YAML avant un cycle de démarrage de VM de 60 secondes.

## Validation YAML autonome

Pour valider la structure du modèle sans Terraform (substituer manuellement des valeurs fictives) :

```powershell
# Contrôle structurel rapide : confirmer que le fichier se parse en YAML valide
python -c "import yaml; yaml.safe_load(open('cloud-init/user-data.yaml.tftpl').read().replace('\${hostname}', 'test').replace('\${lab_stage}', 'test'))"
```

Si aucune sortie n'est affichée, le YAML est structurellement valide.

## Vérification du provisionnement après apply

Après `terraform apply`, confirmer que cloud-init s'est exécuté correctement dans la VM :

```powershell
multipass shell cr465-lab
# Dans la VM :
cat /etc/cr465-lab.txt           # Doit afficher le hostname et lab_stage
cat /var/tmp/cr465-lab-ready.txt # Doit afficher 'CR465 lab ready'
sudo cloud-init status           # Doit afficher 'done'
```

## Vérification
Exécuter `powershell -File tests/validate-tutorial-order.ps1`.

## Récupération
Corriger d'abord le modèle cloud-init, puis relancer les contrôles d'intégration. Si le YAML est invalide, `terraform apply` échouera avant la création de la VM — aucune destruction ne sera nécessaire.
