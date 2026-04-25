#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
out=$(HOME="$T" bash "$ROOT/install.sh" --dry-run 2>&1) || true
for kw in "detect distro" "system packages" "Nerd Font" "backup" "clone LazyVim" "Lazy! sync"; do
  echo "$out" | grep -qi "$kw" || { echo "missing: $kw"; echo "--- output ---"; echo "$out"; exit 1; }
done
test ! -d "$T/.config/nvim" || { echo "dry-run leaked into HOME"; exit 1; }
echo "OK"
