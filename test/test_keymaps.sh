#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
NVIMHOME="$T/.config/nvim"
mkdir -p "$NVIMHOME/lua"
cp -r "$ROOT/templates/lua/." "$NVIMHOME/lua/"
cat > "$NVIMHOME/init.lua" <<'EOF'
require("config.options")
require("config.keymaps")
EOF
XDG_CONFIG_HOME="$T/.config" XDG_DATA_HOME="$T/.data" XDG_STATE_HOME="$T/.state" \
nvim -u "$NVIMHOME/init.lua" --headless \
  '+lua local m = vim.fn.maparg("<leader>?h", "n"); io.write("cheat="..(m == "" and "missing" or "ok").."\n")' \
  +qa >"$T/out" 2>&1
cat "$T/out"
grep -q 'cheat=ok' "$T/out" || { echo "keymap missing"; exit 1; }
echo "OK"
