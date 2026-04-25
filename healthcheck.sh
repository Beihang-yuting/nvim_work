#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/lib/log.sh"

PASS=0; FAIL=0; WARN=0

check() {
  local name="$1"; shift
  if eval "$*" >/dev/null 2>&1; then
    log_ok "$name"; PASS=$((PASS+1))
  else
    log_err "FAIL: $name"; FAIL=$((FAIL+1))
  fi
}

soft() {
  local name="$1"; shift
  if eval "$*" >/dev/null 2>&1; then
    log_ok "$name"; PASS=$((PASS+1))
  else
    log_warn "WARN: $name (optional)"; WARN=$((WARN+1))
  fi
}

log_step "system"
check "Neovim ≥ 0.10"            "command -v nvim && nvim --version | head -1 | grep -E 'v0\\.(1[0-9]|[2-9][0-9])|v[1-9]'"
check "ripgrep present"          "command -v rg"
check "fd present"               "command -v fd || command -v fdfind"
soft  "Nerd Font installed"      "fc-list 2>/dev/null | grep -qi 'JetBrainsMono.*Nerd'"

log_step "nvim runtime"
check "Lazy.nvim cloned"         "test -d ~/.local/share/nvim/lazy/lazy.nvim"
check "Mason data dir"           "test -d ~/.local/share/nvim/mason"

log_step "LSP binaries"
for b in verible-verilog-ls clangd pyright-langserver lua-language-server; do
  soft "  $b" "test -x ~/.local/share/nvim/mason/bin/$b || command -v $b"
done

log_step "formatters"
for b in verible-verilog-format clang-format ruff black stylua; do
  soft "  $b" "test -x ~/.local/share/nvim/mason/bin/$b || command -v $b"
done

log_step "linters"
for b in verible-verilog-lint verilator cppcheck shellcheck markdownlint; do
  soft "  $b" "test -x ~/.local/share/nvim/mason/bin/$b || command -v $b"
done

log_step "treesitter parsers"
for p in systemverilog verilog tcl cpp python lua; do
  soft "  parser $p" "ls ~/.local/share/nvim/lazy/nvim-treesitter/parser/$p.so 2>/dev/null"
done

log_step "EDA tools (optional)"
soft "VCS in PATH"               "command -v vcs"
soft "Verdi in PATH"             "command -v verdi"
soft "UVM_HOME set"              "test -n \"\${UVM_HOME:-}\""

log_step "config files"
check "CHEATSHEET.md present"    "test -f ~/.config/nvim/CHEATSHEET.md"
check "init.lua present"         "test -f ~/.config/nvim/init.lua"
check "templates/lua dir"        "test -d $SCRIPT_DIR/templates/lua"

echo
echo "Summary: PASS=$PASS  FAIL=$FAIL  WARN=$WARN"
[ "$FAIL" = "0" ]
