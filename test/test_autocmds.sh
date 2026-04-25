#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
NVIMHOME="$T/.config/nvim"
mkdir -p "$NVIMHOME/lua" "$T/proj"
cp -r "$ROOT/templates/lua/." "$NVIMHOME/lua/"
cat > "$NVIMHOME/init.lua" <<'EOF'
require("config.options")
require("config.autocmds")
EOF
echo "module x; endmodule" > "$T/proj/x.sv"
XDG_CONFIG_HOME="$T/.config" XDG_DATA_HOME="$T/.data" XDG_STATE_HOME="$T/.state" \
nvim -u "$NVIMHOME/init.lua" --headless "$T/proj/x.sv" \
  '+lua io.write("filelist="..(vim.b.verible_filelist or "nil").."\n")' \
  +qa >"$T/out" 2>&1
cat "$T/out"
grep -q 'filelist=' "$T/out" && ! grep -q 'filelist=nil' "$T/out" || { echo "autocmd not firing"; exit 1; }
echo "OK"
