#!/bin/bash
set -euo pipefail

ROOT="$HOME/NOVA_OS/SUPRA_CHATGPT_APP_BRIDGE_V1"
PY="$ROOT/ENGINE/supra_chatgpt_app_bridge.py"
BRIDGE_SH="$ROOT/bridge.sh"
EXPECTED_SHA="291336f2529d68c40d49a2653361e2247a56c81a81c27e8b51f636af45ce4f72"
STAMP="$(date '+%Y%m%d_%H%M%S')"
BACKUP="$PY.pre_load_json_retry_$STAMP"

say(){ printf '\n[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }
die(){ printf '\nSTATUS=FAIL_BOUNDED\nBLOCKER=%s\n' "$1"; exit "${2:-1}"; }

say "1/5 Verify exact current consumer"
[ -f "$PY" ] || die "CONSUMER_SOURCE_NOT_FOUND" 10
CUR_SHA="$(shasum -a 256 "$PY" | awk '{print $1}')"
printf 'CURRENT_SHA=%s\n' "$CUR_SHA"
[ "$CUR_SHA" = "$EXPECTED_SHA" ] || die "SOURCE_SHA_DRIFT:$CUR_SHA" 11
cp -p "$PY" "$BACKUP"
printf 'BACKUP=%s\n' "$BACKUP"

say "2/5 Patch only load_json"
TARGET="$PY" /usr/bin/python3 <<'PY'
from pathlib import Path
import os

p=Path(os.environ["TARGET"])
s=p.read_text(encoding="utf-8")
old='''def load_json(path, default=None):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return default
'''
new='''def load_json(path, default=None):
    last_exc = None
    attempts = 6
    for attempt in range(attempts):
        try:
            return json.loads(path.read_text(encoding="utf-8"))
        except Exception as exc:
            last_exc = exc
            if attempt < attempts - 1:
                time.sleep(0.25 * (2 ** attempt))
    try:
        stat_payload = None
        stat_error = None
        try:
            st = path.stat()
            stat_payload = {
                "size": st.st_size,
                "mode": st.st_mode,
                "mtime_ns": st.st_mtime_ns,
            }
        except Exception as stat_exc:
            stat_error = {
                "type": type(stat_exc).__name__,
                "message": str(stat_exc),
                "errno": getattr(stat_exc, "errno", None),
            }
        record = {
            "event": "SUPRA_BRIDGE_LOAD_JSON_FAIL_V1",
            "timestamp": time.time(),
            "path": str(path),
            "attempts": attempts,
            "error_type": type(last_exc).__name__ if last_exc else None,
            "error": str(last_exc) if last_exc else None,
            "errno": getattr(last_exc, "errno", None) if last_exc else None,
            "stat": stat_payload,
            "stat_error": stat_error,
        }
        with open("/tmp/SUPRA_BRIDGE_LOAD_JSON_ERRORS.jsonl", "a", encoding="utf-8") as handle:
            handle.write(json.dumps(record, ensure_ascii=False) + "\\n")
    except Exception:
        pass
    return default
'''
if old not in s:
    raise SystemExit("LOAD_JSON_ANCHOR_NOT_FOUND")
p.write_text(s.replace(old,new,1),encoding="utf-8")
PY

say "3/5 Syntax and scope verification"
/usr/bin/python3 -m py_compile "$PY" || {
  cp -p "$BACKUP" "$PY"
  die "PY_COMPILE_FAILED_ROLLED_BACK" 12
}
NEW_SHA="$(shasum -a 256 "$PY" | awk '{print $1}')"
printf 'PATCHED_SHA=%s\n' "$NEW_SHA"
grep -n 'SUPRA_BRIDGE_LOAD_JSON_FAIL_V1\|def load_json' "$PY"

say "4/5 Restart same existing consumer"
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

rm -f /tmp/SUPRA_BRIDGE_LOAD_JSON_ERRORS.jsonl
nohup /bin/bash "$BRIDGE_SH" watch >/tmp/supra_bridge_runtime_health.log 2>&1 </dev/null &

for _ in $(seq 1 40); do
  if lsof -nP -iTCP:18765 -sTCP:LISTEN >/dev/null 2>&1; then break; fi
  sleep 0.5
done

if ! lsof -nP -iTCP:18765 -sTCP:LISTEN >/dev/null 2>&1; then
  tail -n 100 /tmp/supra_bridge_runtime_health.log 2>/dev/null || true
  cp -p "$BACKUP" "$PY"
  die "C1_RESTART_FAILED_SOURCE_ROLLED_BACK" 13
fi

say "5/5 Live services"
lsof -nP -iTCP:18765 -sTCP:LISTEN
lsof -nP -iTCP:4096 -sTCP:LISTEN || true
printf '\nSTATUS=LOAD_JSON_RETRY_PATCH_ACTIVE\n'
printf 'LOG=/tmp/SUPRA_BRIDGE_LOAD_JSON_ERRORS.jsonl\n'
printf 'ACTION_NICOLAS=NONE_AFTER_THIS_COMMAND\n'
