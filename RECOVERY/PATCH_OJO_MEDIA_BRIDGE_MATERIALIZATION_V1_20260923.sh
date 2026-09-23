#!/bin/bash
set -euo pipefail

ENGINE="${SUPRA_BRIDGE_ENGINE:-$HOME/NOVA_OS/SUPRA_CHATGPT_APP_BRIDGE_V1/ENGINE/supra_chatgpt_app_bridge.py}"
PATCH_FILE="$(cd "$(dirname "$0")" && pwd)/OJO_MEDIA_BRIDGE_MATERIALIZATION_V1.patch"
LABEL="com.novaera.supra.bridge-watcher"
STAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP="$HOME/NOVA_OS/SUPRA_CHATGPT_APP_BRIDGE_V1/BACKUPS/MEDIA_MATERIALIZATION_PATCH_$STAMP"

say(){ printf "[%s] %s\n" "$(date +%H:%M:%S)" "$*"; }
fail(){ say "FAIL: $1"; exit "${2:-1}"; }

[ -f "$ENGINE" ] || fail "BRIDGE_ENGINE_MISSING:$ENGINE" 20
[ -s "$PATCH_FILE" ] || fail "PATCH_MISSING:$PATCH_FILE" 21

if grep -Fq "def begin_media_materialization" "$ENGINE" \
   && grep -Fq "def finish_media_materialization" "$ENGINE" \
   && grep -Fq 'OJO_UNIVERSAL_MEDIA_REQUEST_V1' "$ENGINE"; then
  say "Media materialization patch already present"
else
  mkdir -p "$BACKUP"
  cp "$ENGINE" "$BACKUP/supra_chatgpt_app_bridge.py"
  (
    cd "$(dirname "$ENGINE")"
    /usr/bin/patch --forward -p1 < "$PATCH_FILE"
  ) || {
    cp "$BACKUP/supra_chatgpt_app_bridge.py" "$ENGINE"
    fail "PATCH_APPLY_FAILED_ROLLED_BACK" 30
  }
  say "Patch applied; backup=$BACKUP"
fi

python3 -m py_compile "$ENGINE" || fail "PY_COMPILE_FAILED" 40
grep -Fq "def begin_media_materialization" "$ENGINE" || fail "BEGIN_MARKER_MISSING" 41
grep -Fq "def finish_media_materialization" "$ENGINE" || fail "FINISH_MARKER_MISSING" 42
grep -Fq 'pending.get("schema") == "OJO_UNIVERSAL_MEDIA_REQUEST_V1"' "$ENGINE" \
  || fail "MAILBOX_SKIP_MARKER_MISSING" 43

launchctl kickstart -k "gui/$UID/$LABEL" || fail "BRIDGE_RESTART_FAILED" 50
sleep 2
curl -fsS --max-time 4 http://127.0.0.1:18765/health \
  | grep -q '"status": "PASS"' || fail "BRIDGE_HEALTH_FAILED" 51

say "PASS"
echo "ENGINE=$ENGINE"
echo "LABEL=$LABEL"
echo "MODE=EXISTING_BRIDGE_MEDIA_MATERIALIZATION"
