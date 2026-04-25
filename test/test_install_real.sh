#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
mkdir -p "$T/.config"

mkdir -p "$ROOT/templates/lua/config" "$ROOT/templates/lua/plugins"
[ -f "$ROOT/templates/CHEATSHEET.md" ] || echo "# placeholder" > "$ROOT/templates/CHEATSHEET.md"

HOME="$T" GVIM_SKIP_SYSTEM_PKG=1 GVIM_SKIP_NERD_FONT=1 \
  bash "$ROOT/install.sh" --no-mason --minimal 2>&1 | tail -40

test -f "$T/.config/nvim/init.lua"        || { echo "init.lua missing"; exit 1; }
test -f "$T/.config/nvim/CHEATSHEET.md"   || { echo "CHEATSHEET missing"; exit 1; }

# 幂等：重跑不报错
HOME="$T" GVIM_SKIP_SYSTEM_PKG=1 GVIM_SKIP_NERD_FONT=1 \
  bash "$ROOT/install.sh" --no-mason --minimal 2>&1 | tail -10
test -f "$T/.config/nvim/init.lua"

echo "OK"
