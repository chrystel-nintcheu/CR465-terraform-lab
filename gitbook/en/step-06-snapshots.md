# Lab 06: Snapshots

A snapshot captures the complete state of a stopped VM at a point in time.
You can restore to it later to undo changes or test a new configuration while
keeping a known-good baseline.

## Objectives

- Stop the VM before snapshotting.
- Take a named snapshot (`pre-teardown`).
- Verify the snapshot exists.
- Restore to the snapshot.
- Restart the VM and confirm it is Running.

## Prerequisites

- Lab 01 (First VM) passed and the VM is Running.

## Important: instances must be stopped

Multipass (and the `multipass_snapshot` Terraform resource) requires the
instance to be **stopped** before taking a snapshot.

## Steps

### 1. Stop the VM

```powershell
multipass stop cr465-lab
```

Verify it stopped:

```powershell
multipass list
```

State should show `Stopped`.

### 2. Take a snapshot

```powershell
multipass snapshot --name pre-teardown cr465-lab
```

### 3. Verify the snapshot

```powershell
multipass list --snapshots
```

You should see `cr465-lab    pre-teardown`.

### 4. Restore the snapshot

```powershell
multipass restore --destructive cr465-lab.pre-teardown
```

### 5. Start the VM

```powershell
multipass start cr465-lab
```

### 6. Run the automated test

```powershell
PowerShell -ExecutionPolicy Bypass -File tests/06-snapshots.ps1
```

The test handles stop/snapshot/restore/start automatically.

## Verification

`tests/06-snapshots.ps1` exits 0 and prints `FAIL: 0`.

## Recovery

| Symptom | Fix |
|---------|-----|
| Snapshot fails with "instance is running" | Stop the VM first: `multipass stop cr465-lab`. |
| Restore fails | Verify the snapshot name: `multipass list --snapshots`. |
| VM stuck after restore | Run `multipass start cr465-lab`. |
