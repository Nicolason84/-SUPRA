#!/bin/bash
set -euo pipefail

ROOT="$HOME/NOVA_OS/SUPRA_CHATGPT_APP_BRIDGE_V1"
PY="$ROOT/ENGINE/supra_chatgpt_app_bridge.py"
HELPER="$ROOT/CURRENT/supra_fileprovider_coordinated_read"
LABEL="com.novaera.supra.bridge-watcher"
EXPECTED_PY_SHA="aede33098a30f36114d3d0682ab9057521fe14f4dd09e2e524bdbc0f3275197d"
EXPECTED_HELPER_SHA="8ee8ce5cbbfdf72d9065449437d954c7bcde525660dcdc171933c556a28e1962"

say(){ printf '\n[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }
die(){ printf '\nSTATUS=FAIL_BOUNDED\nBLOCKER=%s\n' "$1"; exit "${2:-1}"; }

say "1/4 Verify patched artifacts"
[ -f "$PY" ] || die "CONSUMER_NOT_FOUND" 10
[ -x "$HELPER" ] || die "COORDINATED_READ_HELPER_NOT_FOUND" 11
PY_SHA="$(shasum -a 256 "$PY" | awk '{print $1}')"
HELPER_SHA="$(shasum -a 256 "$HELPER" | awk '{print $1}')"
printf 'PY_SHA=%s\nHELPER_SHA=%s\n' "$PY_SHA" "$HELPER_SHA"
[ "$PY_SHA" = "$EXPECTED_PY_SHA" ] || die "PATCHED_SOURCE_SHA_DRIFT:$PY_SHA" 12
[ "$HELPER_SHA" = "$EXPECTED_HELPER_SHA" ] || die "HELPER_SHA_DRIFT:$HELPER_SHA" 13
/usr/bin/python3 -m py_compile "$PY" || die "PATCHED_SOURCE_COMPILE_FAIL" 14

say "2/4 Stop current Drive consumer"
OLD_PID="$(lsof -tiTCP:18765 -sTCP:LISTEN | head -1 || true)"
[ -n "$OLD_PID" ] || die "NO_CURRENT_C1_LISTENER" 15
printf 'OLD_PID=%s\n' "$OLD_PID"
printf 'OLD_CMD=%s\n' "$(ps -p "$OLD_PID" -o command= 2>/dev/null || true)"
kill "$OLD_PID"
for _ in $(seq 1 40); do
  if ! kill -0 "$OLD_PID" >/dev/null 2>&1; then break; fi
  sleep 0.25
done
if kill -0 "$OLD_PID" >/dev/null 2>&1; then die "OLD_CONSUMER_DID_NOT_EXIT" 16; fi

say "3/4 Restart existing adapter/consumer chain"
launchctl kickstart -k "gui/$UID/$LABEL"
NEW_PID=""
for _ in $(seq 1 60); do
  NEW_PID="$(lsof -tiTCP:18765 -sTCP:LISTEN | head -1 || true)"
  if [ -n "$NEW_PID" ] && [ "$NEW_PID" != "$OLD_PID" ]; then break; fi
  sleep 0.5
done
[ -n "$NEW_PID" ] || die "NEW_C1_LISTENER_NOT_STARTED" 17
[ "$NEW_PID" != "$OLD_PID" ] || die "CONSUMER_PID_DID_NOT_CHANGE" 18

say "4/4 Proof"
printf 'NEW_PID=%s\n' "$NEW_PID"
printf 'NEW_CMD=%s\n' "$(ps -p "$NEW_PID" -o command= 2>/dev/null || true)"
lsof -nP -iTCP:18765 -sTCP:LISTEN
lsof -nP -iTCP:4096 -sTCP:LISTEN || true
printf '\nSTATUS=PATCHED_DRIVE_CONSUMER_RELOADED\n'
printf 'ACTION_NICOLAS=NONE_AFTER_THIS_COMMAND\n'
