#!/bin/bash
set -euo pipefail

ROOT="$HOME/NOVA_OS/SUPRA_CHATGPT_APP_BRIDGE_V1/ENGINE"
CUR="$ROOT/supra_chatgpt_app_bridge.py"
P3="$ROOT/supra_chatgpt_app_bridge.py.backup_p3_20260915_220443"

printf 'STATUS=COMPARE_BEGIN\n'
printf 'CURRENT=%s\nP3=%s\n' "$CUR" "$P3"
[ -f "$CUR" ] || { echo 'BLOCKER=CURRENT_NOT_FOUND'; exit 2; }
[ -f "$P3" ] || { echo 'BLOCKER=P3_NOT_FOUND'; exit 3; }

printf '\n=== HASHES ===\n'
shasum -a 256 "$CUR" "$P3"

printf '\n=== LOAD_JSON SYMBOLS ===\n'
grep -n '^def load_json\|^ *def load_json' "$CUR" "$P3" || true

extract_fn() {
  local file="$1" fn="$2"
  python3 - "$file" "$fn" <<'PY'
import ast,sys
p,fn=sys.argv[1],sys.argv[2]
s=open(p,encoding="utf-8").read()
t=ast.parse(s)
for n in ast.walk(t):
    if isinstance(n,(ast.FunctionDef,ast.AsyncFunctionDef)) and n.name==fn:
        lines=s.splitlines()
        print("\n".join(f"{i+1:6d}  {lines[i]}" for i in range(n.lineno-1,n.end_lineno)))
        break
PY
}

printf '\n=== CURRENT load_json ===\n'
extract_fn "$CUR" load_json
printf '\n=== P3 load_json ===\n'
extract_fn "$P3" load_json

printf '\n=== CURRENT process_file ===\n'
extract_fn "$CUR" process_file
printf '\n=== P3 process_file ===\n'
extract_fn "$P3" process_file

printf '\n=== UNIFIED DIFF: load_json/process_file neighborhoods ===\n'
A="$(mktemp)"; B="$(mktemp)"
trap 'rm -f "$A" "$B"' EXIT
{
  extract_fn "$CUR" load_json
  extract_fn "$CUR" process_file
} >"$A"
{
  extract_fn "$P3" load_json
  extract_fn "$P3" process_file
} >"$B"
diff -u "$B" "$A" || true

printf '\nSTATUS=COMPARE_COMPLETE\n'
