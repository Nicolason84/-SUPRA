#!/bin/bash
set -euo pipefail

TARGET="$HOME/Applications/SUPRA.app"
ROOT="$HOME/NOVA_OS/SUPRA_SURFACE_CONSOLIDATION_V1"
STAMP="$(date '+%Y%m%d_%H%M%S')"
RECEIPT="$ROOT/CURRENT.json"
mkdir -p "$ROOT"

say(){ printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }
fail(){ printf 'STATUS=FAIL_BOUNDED\nBLOCKER=%s\n' "$1" >&2; exit "${2:-1}"; }

[ -d "$TARGET" ] || fail "CANONICAL_SUPRA_APP_MISSING:$TARGET" 10

say "1/6 Snapshot visible SUPRA surfaces"
WINDOWS_BEFORE="$(/usr/bin/osascript <<'OSA' 2>/dev/null || true
tell application "System Events"
  set out to {}
  repeat with p in application processes
    set pn to name of p
    if pn is "SUPRA" or pn is "Google Chrome" or pn is "Chrome" then
      repeat with w in windows of p
        set end of out to pn & "|" & (name of w)
      end repeat
    end if
  end repeat
  return out as text
end tell
OSA
)"
printf 'WINDOWS_BEFORE=%s\n' "${WINDOWS_BEFORE:-UNAVAILABLE}"

say "2/6 Close only stale Chrome SUPRA Chat surface"
CHROME_CLOSED=0
/usr/bin/osascript <<'OSA' >/tmp/supra_surface_chrome_cleanup.out 2>/tmp/supra_surface_chrome_cleanup.err || true
tell application "Google Chrome"
  repeat with w in windows
    set tabCount to count of tabs of w
    repeat with i from tabCount to 1 by -1
      set t to tab i of w
      set tabTitle to title of t
      if tabTitle is "SUPRA Chat" or tabTitle contains "SUPRA — Situation Vivante" or tabTitle contains "SUPRA - Situation Vivante" then
        close t
      end if
    end repeat
  end repeat
end tell
OSA
if [ -s /tmp/supra_surface_chrome_cleanup.out ] || [ ! -s /tmp/supra_surface_chrome_cleanup.err ]; then
  CHROME_CLOSED=1
fi

say "3/6 Retire known legacy native bundles reversibly"
RETIRED="$HOME/Applications/SUPRA Retired/SURFACE_$STAMP"
mkdir -p "$RETIRED"
for LEGACY in "$HOME/Applications/SUPRA-FRANCE.app" "$HOME/Applications/SUPRA-FRANCE-CLEAN.app"; do
  if [ -d "$LEGACY" ]; then
    mv "$LEGACY" "$RETIRED/"
  fi
done

say "4/6 Collapse native SUPRA processes"
osascript -e 'tell application id "com.nicolasalonso.SUPRA" to quit' >/dev/null 2>&1 || true
sleep 1
pkill -x SUPRA >/dev/null 2>&1 || true
for _ in $(seq 1 20); do
  [ -z "$(pgrep -x SUPRA || true)" ] && break
  sleep 0.25
done
[ -z "$(pgrep -x SUPRA || true)" ] || fail "SUPRA_PROCESS_STOP_FAILED" 20

say "5/6 Launch canonical app exactly once"
open "$TARGET"
PID=""
COUNT=0
for _ in $(seq 1 40); do
  PIDS="$(pgrep -x SUPRA || true)"
  COUNT="$(printf '%s\n' "$PIDS" | sed '/^$/d' | wc -l | tr -d ' ')"
  if [ "$COUNT" -eq 1 ]; then
    PID="$(printf '%s\n' "$PIDS" | sed '/^$/d' | head -1)"
    break
  fi
  sleep 0.25
done
[ "$COUNT" -eq 1 ] || fail "NATIVE_SINGLE_INSTANCE_NOT_PROVEN:$COUNT" 30
CMD="$(ps -ww -p "$PID" -o command= 2>/dev/null || true)"
case "$CMD" in
  *"$TARGET/Contents/MacOS/SUPRA"*) ;;
  *) fail "NONCANONICAL_NATIVE_SUPRA:$CMD" 31 ;;
esac

say "6/6 Proof visible surfaces after consolidation"
WINDOWS_AFTER="$(/usr/bin/osascript <<'OSA' 2>/dev/null || true
tell application "System Events"
  set out to {}
  repeat with p in application processes
    set pn to name of p
    if pn is "SUPRA" or pn is "Google Chrome" or pn is "Chrome" then
      repeat with w in windows of p
        set wn to name of w
        if wn contains "SUPRA" or wn contains "Situation Vivante" then
          set end of out to pn & "|" & wn
        end if
      end repeat
    end if
  end repeat
  return out as text
end tell
OSA
)"
printf 'WINDOWS_AFTER=%s\n' "${WINDOWS_AFTER:-UNAVAILABLE}"

python3 - "$RECEIPT" "$PID" "$CMD" "$WINDOWS_BEFORE" "$WINDOWS_AFTER" "$CHROME_CLOSED" <<'PY'
import json,sys,datetime,pathlib
path,pid,cmd,before,after,chrome_closed=sys.argv[1:]
obj={
 "schema":"SUPRA_SURFACE_CONSOLIDATION_RECEIPT_V1",
 "status":"PASS",
 "native_instance_count":1,
 "native_pid":int(pid),
 "canonical_command":cmd,
 "windows_before":before,
 "windows_after":after,
 "chrome_supra_chat_close_attempted":chrome_closed=="1",
 "timestamp":datetime.datetime.now(datetime.timezone.utc).isoformat()
}
p=pathlib.Path(path); p.parent.mkdir(parents=True,exist_ok=True)
p.write_text(json.dumps(obj,indent=2)+"\n")
print(json.dumps(obj,separators=(",",":")))
PY

printf 'STATUS=SUPRA_SURFACES_CONSOLIDATED\n'
printf 'NATIVE_INSTANCE_COUNT=1\n'
printf 'ACTION_NICOLAS=NONE\n'
