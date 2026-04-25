#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fail=0
check() { test -e "$ROOT/$1" || { echo "MISSING: $1"; fail=1; }; }
check README.md
check .gitignore
check LICENSE
check docs/superpowers/specs/2026-04-25-gvim-setup-design.md
check docs/superpowers/plans/2026-04-25-gvim-setup.md
[ "$fail" = "0" ] && echo "OK" || exit 1
