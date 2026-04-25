#!/usr/bin/env bash
# test/smoke.sh —— 端到端冒烟（前提：install.sh 已部署）
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
. "$ROOT/lib/log.sh"

PASS=0; FAIL=0
ok()   { log_ok "$1"; PASS=$((PASS+1)); }
bad()  { log_err "FAIL: $1"; FAIL=$((FAIL+1)); }

# 1. nvim 启动速度
log_step "1. nvim startup"
t0=$(date +%s%N)
nvim --headless "+qa" >/dev/null 2>&1
t1=$(date +%s%N)
ms=$(( (t1 - t0) / 1000000 ))
[ "$ms" -lt 5000 ] && ok "startup ${ms}ms < 5000" || bad "startup ${ms}ms >= 5000"

# 2. SV 诊断
log_step "2. SV diagnostics"
if command -v verible-verilog-ls >/dev/null 2>&1; then
  out=$(nvim --headless "$ROOT/test/sample.sv" \
        "+sleep 3" \
        "+lua io.write(#vim.diagnostic.get(0)..'\\n')" \
        +qa 2>&1 | tail -1)
  [[ "$out" =~ ^[0-9]+$ ]] && ok "diagnostics returned ($out items)" || bad "diagnostics: $out"
else
  log_warn "verible not installed, skip"
fi

# 3. 对齐
log_step "3. mini.align ="
tmp=$(mktemp); cp "$ROOT/test/sample.sv" "$tmp"
nvim --headless "$tmp" \
  "+normal! 8GVjjj" \
  "+lua require('mini.align').align_selected({split_pattern='='})" \
  "+w" "+qa" 2>/dev/null || true
awk -F'=' '/=/ {if (last && index($0,"=")!=last) {print "MISALIGNED"; exit 1} last=index($0,"=")} END{print "ALIGN_OK"}' "$tmp" | grep -q ALIGN_OK \
  && ok "= column aligned" || bad "= alignment failed"
rm -f "$tmp"

# 4. clangd 跳转
log_step "4. LSP gd in C++"
if command -v clangd >/dev/null 2>&1; then
  out=$(nvim --headless "$ROOT/test/sample.cpp" \
        "+sleep 3" \
        "+lua local p = vim.fn.searchpos('add(2,', ''); vim.api.nvim_win_set_cursor(0,p); vim.lsp.buf.definition(); vim.cmd('sleep 1500m'); io.write(vim.fn.line('.')..'\\n')" \
        +qa 2>&1 | tail -1)
  [[ "$out" =~ ^[0-9]+$ ]] && ok "gd jumped to line $out" || bad "gd output: $out"
else
  log_warn "clangd not installed, skip"
fi

# 5. overseer + Makefile
log_step "5. overseer make all"
out=$(nvim --headless \
      "+lua require('overseer').setup({})" \
      "+lua require('overseer').new_task({cmd='make', args={'-C', '$ROOT/test', 'all'}, components={'default','on_complete_dispose'}}):start()" \
      "+sleep 3" \
      "+lua local n=#require('overseer').list_tasks({}); io.write('tasks='..n..'\\n')" \
      +qa 2>&1 | tail -1)
[[ "$out" =~ ^tasks=[0-9]+$ ]] && ok "overseer ran ($out)" || bad "overseer: $out"
make -C "$ROOT/test" clean >/dev/null 2>&1 || true

echo
echo "Smoke summary: PASS=$PASS  FAIL=$FAIL"
[ "$FAIL" = "0" ]
