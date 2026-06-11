#!/usr/bin/env bash
# Thin bash wrapper: delegates all work to provision-multipass.ps1 via pwsh.
set -euo pipefail

if ! command -v pwsh &>/dev/null; then
  echo "ERROR: 'pwsh' (PowerShell Core) is not on PATH." >&2
  echo "Install it from: https://github.com/PowerShell/PowerShell/releases" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
exec pwsh "$SCRIPT_DIR/provision-multipass.ps1" "$@"
