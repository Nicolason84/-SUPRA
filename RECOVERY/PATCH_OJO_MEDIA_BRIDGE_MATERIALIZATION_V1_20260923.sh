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
   && grep -Fq 'OJO_UNIVERSAL_MEDIA_REQUEST_V1' "$ENGINE" \
   && grep -Fq '"SOURCE_PROVIDER", "PROVIDER_GUARDRAIL"' "$ENGINE" \
   && [ "$(grep -Fc '"source_provider": contract["source_provider"]' "$ENGINE")" -ge 2 ]; then
  say "Provider-aware media materialization patch already present"
elif grep -Fq "def begin_media_materialization" "$ENGINE" \
   && grep -Fq "def finish_media_materialization" "$ENGINE" \
   && grep -Fq 'OJO_UNIVERSAL_MEDIA_REQUEST_V1' "$ENGINE"; then
  mkdir -p "$BACKUP"
  cp "$ENGINE" "$BACKUP/supra_chatgpt_app_bridge.py"
  python3 - "$ENGINE" <<'PY' || {
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
text = path.read_text()

def replace_once(old, new, label):
    global text
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"{label}:EXPECTED_1_FOUND_{count}")
    text = text.replace(old, new, 1)

if '"SOURCE_PROVIDER", "PROVIDER_GUARDRAIL"' not in text:
    replace_once(
        '                "MEDIA_OBJECTIVE_ID", "ACTION", "SOURCE", "SOURCE_KIND",\n'
        '                "OJO_OBJECT_ID", "OJO_OBJECT_TYPE", "OJO_OBJECT_TITLE",',
        '                "MEDIA_OBJECTIVE_ID", "ACTION", "SOURCE", "SOURCE_KIND",\n'
        '                "SOURCE_PROVIDER", "PROVIDER_GUARDRAIL",\n'
        '                "OJO_OBJECT_ID", "OJO_OBJECT_TYPE", "OJO_OBJECT_TITLE",',
        "MEDIA_PROVIDER_KEYS",
    )

if '"source_provider": fields.get("SOURCE_PROVIDER", "UNKNOWN")' not in text:
    replace_once(
        '            "source_kind": fields.get("SOURCE_KIND", "UNKNOWN"),\n'
        '            "ojo_object_id": fields.get("OJO_OBJECT_ID", "UNSCOPED"),',
        '            "source_kind": fields.get("SOURCE_KIND", "UNKNOWN"),\n'
        '            "source_provider": fields.get("SOURCE_PROVIDER", "UNKNOWN"),\n'
        '            "provider_guardrail": fields.get("PROVIDER_GUARDRAIL", ""),\n'
        '            "ojo_object_id": fields.get("OJO_OBJECT_ID", "UNSCOPED"),',
        "MEDIA_PROVIDER_CONTRACT",
    )

persist_marker = '"source_provider": contract["source_provider"]'
if text.count(persist_marker) < 2:
    old = (
        '            "source": contract["source"],\n'
        '            "source_kind": contract["source_kind"],\n'
        '            "ojo_object_id": contract["ojo_object_id"],'
    )
    count = text.count(old)
    if count != 2:
        raise SystemExit(f"MEDIA_PROVIDER_PERSISTENCE:EXPECTED_2_FOUND_{count}")
    new = (
        '            "source": contract["source"],\n'
        '            "source_kind": contract["source_kind"],\n'
        '            "source_provider": contract["source_provider"],\n'
        '            "provider_guardrail": contract["provider_guardrail"],\n'
        '            "ojo_object_id": contract["ojo_object_id"],'
    )
    text = text.replace(old, new)

tmp = path.with_suffix(path.suffix + ".provider-upgrade.tmp")
tmp.write_text(text)
tmp.replace(path)
PY
    cp "$BACKUP/supra_chatgpt_app_bridge.py" "$ENGINE"
    fail "PROVIDER_UPGRADE_FAILED_ROLLED_BACK" 31
  }
  say "Provider-aware media materialization upgrade applied; backup=$BACKUP"
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
  say "Provider-aware media materialization patch applied; backup=$BACKUP"
fi

python3 -m py_compile "$ENGINE" || fail "PY_COMPILE_FAILED" 40
grep -Fq "def begin_media_materialization" "$ENGINE" || fail "BEGIN_MARKER_MISSING" 41
grep -Fq "def finish_media_materialization" "$ENGINE" || fail "FINISH_MARKER_MISSING" 42
grep -Fq 'pending.get("schema") == "OJO_UNIVERSAL_MEDIA_REQUEST_V1"' "$ENGINE" \
  || fail "MAILBOX_SKIP_MARKER_MISSING" 43
grep -Fq '"SOURCE_PROVIDER", "PROVIDER_GUARDRAIL"' "$ENGINE" \
  || fail "MEDIA_PROVIDER_KEYS_MISSING" 44
grep -Fq '"source_provider": fields.get("SOURCE_PROVIDER", "UNKNOWN")' "$ENGINE" \
  || fail "MEDIA_PROVIDER_CONTRACT_MISSING" 45
[ "$(grep -Fc '"source_provider": contract["source_provider"]' "$ENGINE")" -ge 2 ] \
  || fail "MEDIA_PROVIDER_PERSISTENCE_MISSING" 46
[ "$(grep -Fc '"provider_guardrail": contract["provider_guardrail"]' "$ENGINE")" -ge 2 ] \
  || fail "MEDIA_PROVIDER_GUARDRAIL_PERSISTENCE_MISSING" 47

launchctl kickstart -k "gui/$UID/$LABEL" || fail "BRIDGE_RESTART_FAILED" 50
sleep 2
curl -fsS --max-time 4 http://127.0.0.1:18765/health \
  | grep -q '"status": "PASS"' || fail "BRIDGE_HEALTH_FAILED" 51

say "PASS"
echo "ENGINE=$ENGINE"
echo "LABEL=$LABEL"
echo "MODE=EXISTING_BRIDGE_MEDIA_MATERIALIZATION"
