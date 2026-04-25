#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BASH_BIN="$(command -v bash)"
out=$(env -i HOME="$HOME" PATH=/nonexistent "$BASH_BIN" "$ROOT/healthcheck.sh" 2>&1) || true
echo "$out" | grep -q "FAIL" || { echo "expected FAIL lines"; exit 1; }
echo "$out" | grep -q "Neovim" || { echo "missing nvim check"; exit 1; }
out2=$(bash "$ROOT/healthcheck.sh" 2>&1 || true)
echo "$out2" | grep -q "Summary:" || { echo "missing summary"; exit 1; }
echo "OK"
