#!/bin/bash
set -euo pipefail

TARGET="$HOME/Applications/SUPRA.app"
STAMP="$(date '+%Y%m%d_%H%M%S')"
RETIRED="$HOME/Applications/SUPRA Retired/DUPLICATE_CLEANUP_$STAMP"
RECEIPT_DIR="$HOME/NOVA_OS/SUPRA_SINGLE_INSTANCE_V1"
RECEIPT="$RECEIPT_DIR/CURRENT.json"

say(){ printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }
fail(){ printf 'STATUS=FAIL_BOUNDED\nBLOCKER=%s\n' "$1" >&2; exit "${2:-1}"; }

[ -d "$TARGET" ] || fail "CANONICAL_SUPRA_APP_MISSING:$TARGET" 10
mkdir -p "$RETIRED" "$RECEIPT_DIR"

say "1/5 Capture current SUPRA processes"
BEFORE="$(pgrep -x SUPRA || true)"
printf 'BEFORE_PIDS=%s\n' "${BEFORE:-NONE}"
for PID in $BEFORE; do
  ps -ww -p "$PID" -o pid=,command= || true
done

say "2/5 Retire known user-space duplicate app bundles (reversible)"
for LEGACY in \
  "$HOME/Applications/SUPRA-FRANCE.app" \
  "$HOME/Applications/SUPRA-FRANCE-CLEAN.app"
do
  if [ -d "$LEGACY" ]; then
    mv "$LEGACY" "$RETIRED/"
    printf 'RETIRED=%s\n' "$LEGACY"
  fi
done

say "3/5 Stop every live SUPRA process"
osascript -e 'tell application id "com.nicolasalonso.SUPRA" to quit' >/dev/null 2>&1 || true
sleep 1
pkill -x SUPRA >/dev/null 2>&1 || true
for _ in $(seq 1 20); do
  [ -z "$(pgrep -x SUPRA || true)" ] && break
  sleep 0.25
done
[ -z "$(pgrep -x SUPRA || true)" ] || fail "SUPRA_PROCESSES_REFUSED_TO_STOP" 20

say "4/5 Launch canonical SUPRA exactly once"
open "$TARGET"
PIDS=""
COUNT=0
for _ in $(seq 1 40); do
  PIDS="$(pgrep -x SUPRA || true)"
  COUNT="$(printf '%s\n' "$PIDS" | sed '/^$/d' | wc -l | tr -d ' ')"
  [ "$COUNT" -eq 1 ] && break
  sleep 0.25
done
[ "$COUNT" -eq 1 ] || fail "SINGLE_INSTANCE_NOT_PROVEN:$COUNT" 30

PID="$(printf '%s\n' "$PIDS" | sed '/^$/d' | head -1)"
CMD="$(ps -ww -p "$PID" -o command= 2>/dev/null || true)"
case "$CMD" in
  *"$TARGET/Contents/MacOS/SUPRA"*) ;;
  *) fail "RUNNING_SUPRA_IS_NOT_CANONICAL:$CMD" 31 ;;
esac

say "5/5 Write proof receipt"
python3 - "$RECEIPT" "$PID" "$CMD" "$TARGET" "$RETIRED" <<'PY'
import json,sys,datetime,pathlib
path,pid,cmd,target,retired=sys.argv[1:]
obj={
  "schema":"SUPRA_SINGLE_INSTANCE_RECEIPT_V1",
  "status":"PASS",
  "instance_count":1,
  "pid":int(pid),
  "command":cmd,
  "canonical_app":target,
  "retired_root":retired,
  "timestamp":datetime.datetime.now(datetime.timezone.utc).isoformat()
}
p=pathlib.Path(path); p.parent.mkdir(parents=True,exist_ok=True)
p.write_text(json.dumps(obj,indent=2)+"\n")
print(json.dumps(obj,separators=(",",":")))
PY

printf 'STATUS=SUPRA_SINGLE_INSTANCE_PASS\n'
printf 'SUPRA_INSTANCE_COUNT=1\n'
printf 'PID=%s\n' "$PID"
printf 'CMD=%s\n' "$CMD"
printf 'ACTION_NICOLAS=NONE\n'
