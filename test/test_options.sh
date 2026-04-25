#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
NVIMHOME="$T/.config/nvim"
mkdir -p "$NVIMHOME/lua"
cp -r "$ROOT/templates/lua/." "$NVIMHOME/lua/"
cat > "$NVIMHOME/init.lua" <<'EOF'
require("config.options")
EOF
XDG_CONFIG_HOME="$T/.config" XDG_DATA_HOME="$T/.data" XDG_STATE_HOME="$T/.state" \
nvim -u "$NVIMHOME/init.lua" --headless \
  '+lua io.write(string.format("ts=%d sw=%d et=%s nu=%s rnu=%s\n", vim.opt.tabstop:get(), vim.opt.shiftwidth:get(), tostring(vim.opt.expandtab:get()), tostring(vim.opt.number:get()), tostring(vim.opt.relativenumber:get())))' \
  +qa >"$T/out" 2>&1
cat "$T/out"
grep -q 'ts=2 sw=2 et=true nu=true rnu=true' "$T/out" || { echo "options not applied"; exit 1; }
echo "OK"
