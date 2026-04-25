#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fail=0
for f in "$ROOT"/templates/snippets/*.json; do
  python3 -c "import json,sys; json.load(open('$f'))" || { echo "BAD JSON: $f"; fail=1; }
done
must() { grep -qE "\"prefix\"\\s*:\\s*\"$1\"" "$2" || { echo "missing prefix '$1' in $2"; fail=1; }; }
must "uvm_test"  "$ROOT/templates/snippets/systemverilog.json"
must "uvm_seq"   "$ROOT/templates/snippets/systemverilog.json"
must "runp"      "$ROOT/templates/snippets/systemverilog.json"
must "uvi"       "$ROOT/templates/snippets/systemverilog.json"
must "fsm3"      "$ROOT/templates/snippets/verilog.json"
must "proc"      "$ROOT/templates/snippets/tcl.json"
must "pyclass"   "$ROOT/templates/snippets/python.json"
must "cls"       "$ROOT/templates/snippets/cpp.json"
[ "$fail" = "0" ] && echo "OK" || exit 1
