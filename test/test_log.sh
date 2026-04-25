#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
. "$ROOT/lib/log.sh"

out=$(log_info "hello" 2>&1)
[[ "$out" == *"[INFO]"* && "$out" == *"hello"* ]] || { echo "log_info FAIL: $out"; exit 1; }
out=$(log_warn "warn" 2>&1)
[[ "$out" == *"[WARN]"* ]] || { echo "log_warn FAIL"; exit 1; }
out=$(log_err "err" 2>&1)
[[ "$out" == *"[ERR"* ]] || { echo "log_err FAIL"; exit 1; }
out=$(log_ok "ok" 2>&1)
[[ "$out" == *"[OK"* ]] || { echo "log_ok FAIL"; exit 1; }
echo "OK"
