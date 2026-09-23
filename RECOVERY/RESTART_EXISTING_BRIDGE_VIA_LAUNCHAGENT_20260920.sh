#!/bin/bash
set -euo pipefail

LABEL="com.novaera.supra.bridge-watcher"
PLIST="$HOME/Library/LaunchAgents/${LABEL}.plist"

say(){ printf '\n[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }
die(){ printf '\nSTATUS=FAIL_BOUNDED\nBLOCKER=%s\n' "$1"; exit "${2:-1}"; }

say "1/4 Verify existing LaunchAgent"
[ -f "$PLIST" ] || die "LAUNCHAGENT_PLIST_NOT_FOUND:$PLIST" 10
plutil -lint "$PLIST" >/dev/null || die "LAUNCHAGENT_PLIST_INVALID" 11
printf 'PLIST=%s\n' "$PLIST"

say "2/4 Stop SSH-owned listener if present"
PID="$(lsof -tiTCP:18765 -sTCP:LISTEN | head -1 || true)"
if [ -n "$PID" ]; then
  CMD="$(ps -p "$PID" -o command= 2>/dev/null || true)"
  printf 'OLD_PID=%s\nOLD_CMD=%s\n' "$PID" "$CMD"
  kill "$PID" >/dev/null 2>&1 || true
  for _ in $(seq 1 20); do
    kill -0 "$PID" >/dev/null 2>&1 || break
    sleep 0.25
  done
fi

say "3/4 Bootstrap/kickstart existing LaunchAgent"
launchctl bootout "gui/$UID/$LABEL" >/dev/null 2>&1 || true
launchctl bootstrap "gui/$UID" "$PLIST" >/dev/null 2>&1 || true
launchctl kickstart -k "gui/$UID/$LABEL"

for _ in $(seq 1 40); do
  if lsof -nP -iTCP:18765 -sTCP:LISTEN >/dev/null 2>&1; then break; fi
  sleep 0.5
done

if ! lsof -nP -iTCP:18765 -sTCP:LISTEN >/dev/null 2>&1; then
  launchctl print "gui/$UID/$LABEL" 2>/dev/null || true
  die "LAUNCHAGENT_DID_NOT_RESTORE_C1_18765" 12
fi

say "4/4 Proof"
launchctl print "gui/$UID/$LABEL" 2>/dev/null | sed -n '1,80p' || true
lsof -nP -iTCP:18765 -sTCP:LISTEN
lsof -nP -iTCP:4096 -sTCP:LISTEN || true

NEWPID="$(lsof -tiTCP:18765 -sTCP:LISTEN | head -1)"
printf 'NEW_PID=%s\n' "$NEWPID"
printf 'NEW_CMD=%s\n' "$(ps -p "$NEWPID" -o command= 2>/dev/null || true)"
printf '\nSTATUS=LAUNCHAGENT_BRIDGE_RESTORED\n'
printf 'ACTION_NICOLAS=NONE_AFTER_THIS_COMMAND\n'
