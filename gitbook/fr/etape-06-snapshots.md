# Etape 06 : Snapshots

Un snapshot capture l'etat complet d'une VM arretee a un instant donne.
Vous pouvez y revenir pour annuler des modifications ou tester une nouvelle
configuration tout en conservant une base connue comme bonne.

## Objectifs

- Arreter la VM avant de prendre le snapshot.
- Prendre un snapshot nomme (`pre-teardown`).
- Verifier que le snapshot existe.
- Restaurer a partir du snapshot.
- Redemarrer la VM et confirmer qu'elle est en etat Running.

## Prerequis

- Etape 01 (Premiere VM) reussie et la VM en etat Running.

## Important : les instances doivent etre arretees

Multipass (et la ressource Terraform `multipass_snapshot`) exige que l'instance
soit **arretee** avant de prendre un snapshot.

## Etapes

### 1. Arreter la VM

```powershell
multipass stop cr465-lab
```

Verifiez l'arret :

```powershell
multipass list
```

L'etat doit indiquer `Stopped`.

### 2. Prendre un snapshot

```powershell
multipass snapshot --name pre-teardown cr465-lab
```

### 3. Verifier le snapshot

```powershell
multipass list --snapshots
```

Vous devriez voir `cr465-lab    pre-teardown`.

### 4. Restaurer le snapshot

```powershell
multipass restore --destructive cr465-lab.pre-teardown
```

### 5. Demarrer la VM

```powershell
multipass start cr465-lab
```

### 6. Executer le test automatise

```powershell
PowerShell -ExecutionPolicy Bypass -File tests/06-snapshots.ps1
```

Le test gere automatiquement l'arret, le snapshot, la restauration et le demarrage.

## Verification

`tests/06-snapshots.ps1` se termine avec le code 0 et affiche `FAIL: 0`.

## Recuperation

| Symptome | Correction |
|----------|-----------|
| Snapshot echoue avec "instance is running" | Arretez la VM d'abord : `multipass stop cr465-lab`. |
| Restauration echoue | Verifiez le nom du snapshot : `multipass list --snapshots`. |
| VM bloquee apres restauration | Executez `multipass start cr465-lab`. |
