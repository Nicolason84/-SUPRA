#!/bin/bash
set -euo pipefail

ENGINE="${SUPRA_BRIDGE_ENGINE:-$HOME/NOVA_OS/SUPRA_CHATGPT_APP_BRIDGE_V1/ENGINE/supra_chatgpt_app_bridge.py}"
PATCH_FILE="$(cd "$(dirname "$0")" && pwd)/HARD_NO_TOOLS_ENFORCEMENT_V1.patch"
LABEL="${SUPRA_BRIDGE_LABEL:-com.novaera.supra.bridge-watcher}"
PRE_SHA="f4644ceda2a4ca586bd182351f9a90bf6cb3d1749a6482fdac0deeadb9098adf"
POST_SHA="e24ad6b39cc341fb0113044208c079948ddd3de802efff7f4e270eb762fd48f9"
STAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP="$ENGINE.pre_hard_no_tools_apply_$STAMP.bak"
sha(){ shasum -a 256 "$1" | awk '{print $1}'; }

CURRENT="$(sha "$ENGINE")"
if [[ "$CURRENT" == "$POST_SHA" ]]; then
  python3 -m py_compile "$ENGINE"
  echo "STATUS=ALREADY_PATCHED"
  echo "SHA=$CURRENT"
  exit 0
fi
[[ "$CURRENT" == "$PRE_SHA" ]] || { echo "STATUS=BLOCKED_SHA_MISMATCH"; echo "SHA=$CURRENT"; exit 42; }

cp "$ENGINE" "$BACKUP"
rollback(){ cp "$BACKUP" "$ENGINE"; python3 -m py_compile "$ENGINE"; echo "STATUS=ROLLED_BACK"; exit 43; }
trap rollback ERR

/usr/bin/patch "$ENGINE" < "$PATCH_FILE"
python3 -m py_compile "$ENGINE"
[[ "$(sha "$ENGINE")" == "$POST_SHA" ]]

if [[ "${SUPRA_BRIDGE_RESTART:-YES}" == "YES" ]]; then
  launchctl kickstart -k "gui/$(id -u)/$LABEL"
  sleep 1
  curl -fsS "${SUPRA_BRIDGE_HEALTH_URL:-http://127.0.0.1:18765/health}" >/dev/null
fi

trap - ERR
echo "STATUS=PASS"
echo "BACKUP=$BACKUP"
echo "SHA=$(sha "$ENGINE")"