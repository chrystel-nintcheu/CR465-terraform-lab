# Étape 2 : Cible Terraform minimale

## Objectif
Définir une ressource `multipass_instance` avec le provider `todoroff/multipass`.
Terraform doit gérer le cycle de vie complet de la VM — création, mise à jour,
destruction — et exposer un output `ipv4` réel référençable par d'autres ressources.

## Prérequis
- La validation de l'étape 1 est passée
- Terraform ≥ 1.6 et Multipass sont installés sur le poste

## Fichiers sources concernés
- `terraform/versions.tf` — déclare `todoroff/multipass ~> 1.7`
- `terraform/main.tf` — `provider "multipass"`, `resource "multipass_instance" "lab"`, `resource "multipass_alias" "shell"`
- `terraform/variables.tf` — `vm_name`, `image`, `cpus`, `memory` (ex. `"2G"`), `disk` (ex. `"10G"`), `lab_stage`
- `terraform/outputs.tf` — `vm_name`, `ipv4` (depuis `multipass_instance.lab.ipv4`), `lab_stage`
- `cloud-init/user-data.yaml.tftpl` — rendu via `templatefile()` dans le bloc ressource

## Sortie attendue
Après `terraform plan`, Terraform affiche :
```
# multipass_instance.lab will be created
+ resource "multipass_instance" "lab" {
    + cpus           = 2
    + disk           = "10G"
    + ipv4           = (known after apply)
    + memory         = "2G"
    + name           = "cr465-lab"
    ...
  }
```
L'attribut `ipv4` est `(known after apply)` : Terraform connaît le schéma mais
la valeur n'existe qu'après le démarrage de la VM. C'est le concept central :
le provider gère le cycle de vie complet de la ressource.

## Concepts

### À propos du provider

Le provider `todoroff/multipass` est un **provider communautaire**, non publié par HashiCorp. Il est disponible sur le [Terraform Registry](https://registry.terraform.io/providers/todoroff/multipass/latest) mais sans contrat de support officiel. En production, préférer les providers vérifiés par HashiCorp (marqués d'un badge bleu sur le registre) et auditer les providers communautaires avant usage.

`terraform init` télécharge le provider depuis le registre dans `.terraform/`. Ce répertoire est exclu de git par `.gitignore` — ne jamais le committer.

### La ressource `multipass_instance`

C'est la ressource centrale : elle correspond directement à une VM Multipass. Terraform appelle `multipass launch` lors d'un apply, `multipass info` pour lire l'état, et `multipass delete` lors d'un destroy. Le provider traduit les déclarations HCL en appels CLI Multipass.

### `(known after apply)`

Lors d'un `terraform plan`, certaines valeurs d'attributs ne peuvent être calculées que lorsque la ressource existe réellement. L'adresse IP de la VM est assignée par l'OS au démarrage — Terraform ne peut pas la prédire. Le plan affiche :

```
+ ipv4 = (known after apply)
```

C'est le comportement fondamental de Terraform : le **schéma** est connu à la planification (quels attributs existent, quels types ils ont), mais les **valeurs dynamiques** sont différées jusqu'à l'apply. Après `terraform apply`, `terraform output ipv4` affichera l'adresse réelle.

### La ressource `multipass_alias`

Un alias Multipass crée un raccourci de commande sur l'hôte. Après l'apply, `multipass alias cr465-lab-shell` est enregistré. L'important ici est la **dépendance implicite** : l'alias référence `multipass_instance.lab.name`. Le graphe de dépendances de Terraform garantit que l'instance est créée *avant* l'alias et détruite *après*. On obtient une gestion ordonnée du cycle de vie sans écrire un seul `depends_on`.

### Personnaliser les variables

Les valeurs par défaut sont définies dans `terraform/variables.tf`. Pour les surcharger sans modifier les fichiers sources, copier l'exemple :

```powershell
Copy-Item terraform/terraform.tfvars.example terraform/terraform.tfvars
```

Modifier `terraform/terraform.tfvars` avec vos valeurs. Ce fichier est gitignore — vos personnalisations restent locales.

## Vérification
Depuis la racine du dépôt :
```powershell
cd terraform
terraform init
terraform validate   # Success! The configuration is valid.
terraform plan       # Affiche multipass_instance.lab + multipass_alias.shell
```
Ou lancer la suite complète : `powershell -File tests/run.ps1`

## Récupération
Si `terraform validate` échoue, corriger uniquement les fichiers HCL dans `terraform/`,
puis relancer `terraform init` suivi de `terraform validate`. Ne pas modifier les fichiers du provider dans `.terraform/` — ils sont gérés par Terraform lui-même.
