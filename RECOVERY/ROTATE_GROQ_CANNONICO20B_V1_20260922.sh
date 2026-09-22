#!/bin/bash
set -euo pipefail

SERVICE="com.nicolasalonso.SUPRA.external"
ACCOUNT="groq.cannonico20b"
MODEL="openai/gpt-oss-20b"
ENDPOINT="https://api.groq.com/openai/v1/chat/completions"
ROOT="$HOME/NOVA_OS/SUPRA_GROQ_CANNONICO20B_V1"
RECEIPT="$ROOT/ROTATION_RECEIPT.json"
APP="$HOME/Applications/SUPRA.app"

mkdir -p "$ROOT"
umask 077

has_key() {
  /usr/bin/security find-generic-password -s "$SERVICE" -a "$ACCOUNT" >/dev/null 2>&1
}

status() {
  if has_key; then
    printf 'GROQ_KEYCHAIN=CONFIGURED\n'
  else
    printf 'GROQ_KEYCHAIN=MISSING\n'
  fi
  [ -s "$RECEIPT" ] && /bin/cat "$RECEIPT" || true
}

case "${1:-install}" in
  status)
    status
    exit 0
    ;;
  install)
    ;;
  *)
    printf 'USAGE: %s [install|status]\n' "$0" >&2
    exit 2
    ;;
esac

KEY=""
printf 'Paste CANNONICO-20B-LIVE Groq key (input hidden): ' >/dev/tty
IFS= read -r -s KEY </dev/tty
printf '\n' >/dev/tty

case "$KEY" in
  gsk_*) ;;
  *)
    unset KEY
    printf 'STATUS=INVALID_KEY_FORMAT\n' >&2
    exit 10
    ;;
esac

/usr/bin/security add-generic-password -U -s "$SERVICE" -a "$ACCOUNT" -w "$KEY" >/dev/null

BODY="$(/usr/bin/mktemp)"
trap 'rm -f "$BODY"; unset KEY' EXIT

HTTP="$(
  /usr/bin/curl -sS     --connect-timeout 8     --max-time 30     -o "$BODY"     -w '%{http_code}'     -X POST "$ENDPOINT"     -H 'Content-Type: application/json'     -H "Authorization: Bearer $KEY"     --data-binary '{"model":"openai/gpt-oss-20b","messages":[{"role":"user","content":"Reply exactly: CANNONICO20B_OK"}],"max_completion_tokens":32,"reasoning_effort":"low","include_reasoning":false,"stream":false}'
)"

VERIFY="$(
  /usr/bin/python3 - "$BODY" "$HTTP" "$MODEL" <<'PY'
import json,sys
path,http,expected=sys.argv[1:]
try:
    data=json.load(open(path,encoding="utf-8"))
except Exception:
    print("PARSE_FAIL|false|false|UNKNOWN")
    raise SystemExit
model=data.get("model")
choices=data.get("choices") or []
msg=(choices[0].get("message") if choices else {}) or {}
content=msg.get("content")
ok=(http=="200" and model==expected and isinstance(content,str) and bool(content.strip()))
print(f'{"PASS" if ok else "FAIL"}|{str(model==expected).lower()}|{str(bool(content and str(content).strip())).lower()}|{model or "UNKNOWN"}')
PY
)"

IFS='|' read -r VERDICT MODEL_MATCH CONTENT_NON_NULL RETURNED_MODEL <<<"$VERIFY"

if [ "$VERDICT" != "PASS" ]; then
  /usr/bin/python3 - "$RECEIPT" "$HTTP" "$RETURNED_MODEL" <<'PY'
import json,sys,datetime,os
path,http,model=sys.argv[1:]
obj={
  "schema":"SUPRA_GROQ_ROTATION_RECEIPT_V1",
  "status":"FAIL",
  "provider":"groq",
  "credential_name":"CANNONICO-20B-LIVE-20260922",
  "model":model,
  "http_status":http,
  "secret_persisted_in_repo":False,
  "timestamp":datetime.datetime.now(datetime.timezone.utc).isoformat()
}
os.makedirs(os.path.dirname(path),exist_ok=True)
json.dump(obj,open(path,"w",encoding="utf-8"),indent=2,sort_keys=True)
PY
  unset KEY
  printf 'STATUS=GROQ_LIVE_PROOF_FAIL HTTP=%s MODEL=%s\n' "$HTTP" "$RETURNED_MODEL" >&2
  exit 20
fi

/bin/launchctl setenv GROQ_API_KEY "$KEY"

if [ -d "$APP" ]; then
  /usr/bin/osascript -e 'tell application "SUPRA" to quit' >/dev/null 2>&1 || true
  /bin/sleep 1
  /usr/bin/open "$APP"
  /bin/sleep 3
fi

/bin/launchctl unsetenv GROQ_API_KEY || true

/usr/bin/python3 - "$RECEIPT" "$HTTP" "$RETURNED_MODEL" "$MODEL_MATCH" "$CONTENT_NON_NULL" <<'PY'
import json,sys,datetime,os
path,http,model,model_match,content_non_null=sys.argv[1:]
obj={
  "schema":"SUPRA_GROQ_ROTATION_RECEIPT_V1",
  "status":"PASS",
  "provider":"groq",
  "credential_name":"CANNONICO-20B-LIVE-20260922",
  "model":model,
  "http_status":http,
  "model_match":model_match=="true",
  "content_non_null":content_non_null=="true",
  "keychain_service":"com.nicolasalonso.SUPRA.external",
  "keychain_account":"groq.cannonico20b",
  "secret_persisted_in_repo":False,
  "secret_persisted_in_receipt":False,
  "supra_restart_attempted":True,
  "timestamp":datetime.datetime.now(datetime.timezone.utc).isoformat()
}
os.makedirs(os.path.dirname(path),exist_ok=True)
json.dump(obj,open(path,"w",encoding="utf-8"),indent=2,sort_keys=True)
PY

unset KEY
printf 'STATUS=GROQ_CANNONICO20B_ROTATED_AND_LIVE_PROVEN\n'
printf 'RECEIPT=%s\n' "$RECEIPT"
