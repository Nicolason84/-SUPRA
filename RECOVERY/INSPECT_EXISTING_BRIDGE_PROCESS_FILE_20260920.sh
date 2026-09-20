#!/bin/bash
set -euo pipefail

ROOT="$HOME/NOVA_OS/SUPRA_CHATGPT_APP_BRIDGE_V1"
PY="$ROOT/ENGINE/supra_chatgpt_app_bridge.py"

printf 'STATUS=READ_ONLY_INSPECTION_BEGIN\n'
printf 'HOST=%s\n' "$(scutil --get ComputerName 2>/dev/null || hostname)"
printf 'PY=%s\n' "$PY"

[ -f "$PY" ] || { printf 'BLOCKER=BRIDGE_SOURCE_NOT_FOUND\n'; exit 2; }

printf '\n=== CURRENT FILE ===\n'
stat -f 'mtime=%Sm size=%z inode=%i' -t '%Y-%m-%dT%H:%M:%S%z' "$PY"
shasum -a 256 "$PY"

printf '\n=== process_file SYMBOL ===\n'
grep -n '^ *def process_file\|process_file(' "$PY" | head -20 || true

printf '\n=== LINES 2248-2302 ===\n'
nl -ba "$PY" | sed -n '2248,2302p'

printf '\n=== LOCAL CANDIDATES / BACKUPS (BOUNDED TO EXISTING BRIDGE ROOT) ===\n'
find "$ROOT" -maxdepth 5 -type f \(   -name 'supra_chatgpt_app_bridge.py' -o   -name 'supra_chatgpt_app_bridge.py.*' -o   -name '*supra_chatgpt_app_bridge*.bak*' -o   -name '*supra_chatgpt_app_bridge*backup*' \) -print0 2>/dev/null | while IFS= read -r -d '' f; do
  printf '%s\t' "$f"
  stat -f '%Sm\t%z bytes\t' -t '%Y-%m-%dT%H:%M:%S%z' "$f" 2>/dev/null || true
  shasum -a 256 "$f" | awk '{print $1}'
done | sort -k2,2r | head -50

printf '\n=== GIT LINEAGE IF PRESENT ===\n'
if git -C "$ROOT" rev-parse --show-toplevel >/dev/null 2>&1; then
  TOP="$(git -C "$ROOT" rev-parse --show-toplevel)"
  printf 'GIT_TOP=%s\n' "$TOP"
  git -C "$ROOT" status --short -- "$PY" 2>/dev/null || true
  git -C "$ROOT" log --oneline --all --follow -- "$PY" 2>/dev/null | head -30 || true
else
  printf 'GIT_TOP=NONE\n'
fi

printf '\n=== LIVE SERVICES ===\n'
lsof -nP -iTCP:18765 -sTCP:LISTEN || true
lsof -nP -iTCP:4096 -sTCP:LISTEN || true

printf '\nSTATUS=READ_ONLY_INSPECTION_COMPLETE\n'
