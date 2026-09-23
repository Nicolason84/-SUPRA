#!/bin/bash
set -euo pipefail

ROOT="$HOME/NOVA_OS/SUPRA_CHATGPT_APP_BRIDGE_V1"
PY="$ROOT/ENGINE/supra_chatgpt_app_bridge.py"
CURRENT="$ROOT/CURRENT"
HELPER_SRC="$CURRENT/supra_fileprovider_coordinated_read.swift"
HELPER_BIN="$CURRENT/supra_fileprovider_coordinated_read"
EXPECTED_SHA="d1ffabf3b3de768a2394bf7e2bf47a711713a98a50eb95a7e41542291f90e3ac"
LABEL="com.novaera.supra.bridge-watcher"
PLIST="$HOME/Library/LaunchAgents/${LABEL}.plist"
STAMP="$(date '+%Y%m%d_%H%M%S')"
BACKUP="$PY.pre_fileprovider_coord_$STAMP"

say(){ printf '\n[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }
die(){ printf '\nSTATUS=FAIL_BOUNDED\nBLOCKER=%s\n' "$1"; exit "${2:-1}"; }

say "1/6 Verify exact patched consumer"
[ -f "$PY" ] || die "CONSUMER_SOURCE_NOT_FOUND" 10
CUR_SHA="$(shasum -a 256 "$PY" | awk '{print $1}')"
printf 'CURRENT_SHA=%s\n' "$CUR_SHA"
[ "$CUR_SHA" = "$EXPECTED_SHA" ] || die "SOURCE_SHA_DRIFT:$CUR_SHA" 11
mkdir -p "$CURRENT"
cp -p "$PY" "$BACKUP"
printf 'BACKUP=%s\n' "$BACKUP"

say "2/6 Build NSFileCoordinator helper"
cat >"$HELPER_SRC" <<'SWIFT'
import Foundation

guard CommandLine.arguments.count == 2 else {
    fputs("usage: supra_fileprovider_coordinated_read <path>\n", stderr)
    exit(64)
}

let originalURL = URL(fileURLWithPath: CommandLine.arguments[1])
let coordinator = NSFileCoordinator(filePresenter: nil)
var coordinationError: NSError?
var readError: Error?
var payload: Data?

coordinator.coordinate(readingItemAt: originalURL, options: [], error: &coordinationError) { coordinatedURL in
    do {
        payload = try Data(contentsOf: coordinatedURL, options: [])
    } catch {
        readError = error
    }
}

if let error = coordinationError {
    fputs("COORDINATION_ERROR domain=\(error.domain) code=\(error.code) message=\(error.localizedDescription)\n", stderr)
    exit(2)
}
if let error = readError as NSError? {
    fputs("READ_ERROR domain=\(error.domain) code=\(error.code) message=\(error.localizedDescription)\n", stderr)
    exit(3)
}
guard let data = payload else {
    fputs("READ_ERROR no_payload\n", stderr)
    exit(4)
}
FileHandle.standardOutput.write(data)
SWIFT

SWIFTC="$(xcrun --find swiftc 2>/dev/null || true)"
[ -n "$SWIFTC" ] || { cp -p "$BACKUP" "$PY"; die "SWIFTC_NOT_FOUND" 12; }
xcrun swiftc -O "$HELPER_SRC" -o "$HELPER_BIN" || {
  cp -p "$BACKUP" "$PY"
  die "SWIFT_HELPER_BUILD_FAILED" 13
}
chmod 755 "$HELPER_BIN"
printf 'HELPER_SHA=%s\n' "$(shasum -a 256 "$HELPER_BIN" | awk '{print $1}')"

say "3/6 Patch only EDEADLK fallback"
TARGET="$PY" HELPER_PATH="$HELPER_BIN" /usr/bin/python3 <<'PY'
from pathlib import Path
import os

p=Path(os.environ["TARGET"])
helper=os.environ["HELPER_PATH"]
s=p.read_text(encoding="utf-8")

if "import subprocess" not in s:
    anchor="import shutil\n"
    if anchor not in s:
        raise SystemExit("IMPORT_ANCHOR_NOT_FOUND")
    s=s.replace(anchor, anchor+"import subprocess\n", 1)

start=s.index("def load_json(path, default=None):")
end=s.index("\n\ndef ", start)

new=f'''def load_json(path, default=None):
    last_exc = None
    attempts = 3
    for attempt in range(attempts):
        try:
            return json.loads(path.read_text(encoding="utf-8"))
        except OSError as exc:
            last_exc = exc
            if getattr(exc, "errno", None) != 11:
                break
            if attempt < attempts - 1:
                time.sleep(0.25 * (2 ** attempt))
        except Exception as exc:
            last_exc = exc
            break

    if isinstance(last_exc, OSError) and getattr(last_exc, "errno", None) == 11:
        try:
            completed = subprocess.run(
                [{helper!r}, str(path)],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                timeout=30,
                check=False,
            )
            if completed.returncode == 0:
                return json.loads(completed.stdout.decode("utf-8"))
            coordinated_error = completed.stderr.decode("utf-8", errors="replace")[-2000:]
        except Exception as coordinated_exc:
            coordinated_error = f"{{type(coordinated_exc).__name__}}: {{coordinated_exc}}"
    else:
        coordinated_error = None

    try:
        stat_payload = None
        stat_error = None
        try:
            st = path.stat()
            stat_payload = {{
                "size": st.st_size,
                "mode": st.st_mode,
                "mtime_ns": st.st_mtime_ns,
            }}
        except Exception as stat_exc:
            stat_error = {{
                "type": type(stat_exc).__name__,
                "message": str(stat_exc),
                "errno": getattr(stat_exc, "errno", None),
            }}
        record = {{
            "event": "SUPRA_BRIDGE_LOAD_JSON_FAIL_V2",
            "timestamp": time.time(),
            "path": str(path),
            "attempts": attempts,
            "error_type": type(last_exc).__name__ if last_exc else None,
            "error": str(last_exc) if last_exc else None,
            "errno": getattr(last_exc, "errno", None) if last_exc else None,
            "coordinated_error": coordinated_error,
            "stat": stat_payload,
            "stat_error": stat_error,
        }}
        with open("/tmp/SUPRA_BRIDGE_LOAD_JSON_ERRORS.jsonl", "a", encoding="utf-8") as handle:
            handle.write(json.dumps(record, ensure_ascii=False) + "\\n")
    except Exception:
        pass
    return default
'''

s=s[:start]+new+s[end:]
p.write_text(s,encoding="utf-8")
PY

say "4/6 Compile/scope verification"
/usr/bin/python3 -m py_compile "$PY" || {
  cp -p "$BACKUP" "$PY"
  die "PY_COMPILE_FAILED_ROLLED_BACK" 14
}
NEW_SHA="$(shasum -a 256 "$PY" | awk '{print $1}')"
printf 'PATCHED_SHA=%s\n' "$NEW_SHA"
grep -n 'SUPRA_BRIDGE_LOAD_JSON_FAIL_V2\|supra_fileprovider_coordinated_read\|def load_json' "$PY"

say "5/6 Restart existing LaunchAgent context"
[ -f "$PLIST" ] || {
  cp -p "$BACKUP" "$PY"
  die "LAUNCHAGENT_PLIST_NOT_FOUND" 15
}
launchctl kickstart -k "gui/$UID/$LABEL"

for _ in $(seq 1 40); do
  if lsof -nP -iTCP:18765 -sTCP:LISTEN >/dev/null 2>&1; then break; fi
  sleep 0.5
done
if ! lsof -nP -iTCP:18765 -sTCP:LISTEN >/dev/null 2>&1; then
  cp -p "$BACKUP" "$PY"
  launchctl kickstart -k "gui/$UID/$LABEL" >/dev/null 2>&1 || true
  die "C1_RESTART_FAILED_SOURCE_ROLLED_BACK" 16
fi

say "6/6 Proof local services"
launchctl print "gui/$UID/$LABEL" 2>/dev/null | sed -n '1,35p' || true
lsof -nP -iTCP:18765 -sTCP:LISTEN
lsof -nP -iTCP:4096 -sTCP:LISTEN || true
printf '\nSTATUS=FILEPROVIDER_COORDINATED_READ_PATCH_ACTIVE\n'
printf 'HELPER=%s\n' "$HELPER_BIN"
printf 'ERROR_LOG=/tmp/SUPRA_BRIDGE_LOAD_JSON_ERRORS.jsonl\n'
printf 'ACTION_NICOLAS=NONE_AFTER_THIS_COMMAND\n'
