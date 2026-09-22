#!/bin/bash
set -euo pipefail

REPO_SLUG="Nicolason84/-SUPRA"
CANON_BRANCH="supra/human-gate-single-source-20260721_072447"
API_ROOT="https://api.github.com/repos/$REPO_SLUG"
CODELOAD_ROOT="https://codeload.github.com/$REPO_SLUG/tar.gz"

SUPPORT="$HOME/Library/Application Support/NOVA ERA/SUPRA Updater"
STATE="$SUPPORT/state.json"
UPDATER="$SUPPORT/supra_autobuild_self_update.sh"
TARGET="$HOME/Applications/SUPRA.app"
LABEL="com.novaera.supra-autoupdate"
BRIDGE_LABEL="com.novaera.sol-github-bridge"
BRIDGE_PLIST="$HOME/Library/LaunchAgents/$BRIDGE_LABEL.plist"

say(){ printf '\n[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }
fail(){ printf '\nSTATUS=FAIL_BOUNDED\nBLOCKER=%s\n' "$1"; exit "${2:-1}"; }

retire_auxiliary_surfaces(){
  /usr/bin/osascript <<'OSA' >/dev/null 2>&1 || true
tell application "System Events"
  repeat with procName in {"SUPRAClean", "OjoCompanion"}
    if exists process procName then
      try
        tell process procName to keystroke "q" using command down
      end try
    end if
  end repeat
end tell
OSA
  sleep 1
}

PY="$(command -v python3 || true)"
CURL="$(command -v curl || true)"
[ -n "$PY" ] || fail "PYTHON3_NOT_FOUND" 10
[ -n "$CURL" ] || fail "CURL_NOT_FOUND" 11

TMP="$(mktemp -d /tmp/SUPRA_SELF_HEAL.XXXXXX)"
cleanup(){ rm -rf "$TMP" >/dev/null 2>&1 || true; }
trap cleanup EXIT

say "1/8 Resolve exact canonical head"
ENC_BRANCH="$(printf '%s' "$CANON_BRANCH" | sed 's#/#%2F#g')"
REMOTE_SHA="$("$CURL" -fsSL "$API_ROOT/branches/$ENC_BRANCH" | "$PY" -c 'import json,sys; print(json.load(sys.stdin)["commit"]["sha"])')" || fail "REMOTE_SHA_UNAVAILABLE" 20
[ -n "$REMOTE_SHA" ] || fail "REMOTE_SHA_EMPTY" 21
printf 'REMOTE_SHA=%s\n' "$REMOTE_SHA"

say "2/8 Wait for exact canonical CI"
CI_OK=NO
for _ in $(seq 1 36); do
  RUNS="$("$CURL" -fsSL "$API_ROOT/actions/runs?head_sha=$REMOTE_SHA&status=completed&per_page=50" || true)"
  if printf '%s' "$RUNS" | "$PY" -c '
import json,sys
try: x=json.load(sys.stdin)
except Exception: raise SystemExit(1)
ok=any(r.get("name")=="Validate Canonical SUPRA" and r.get("conclusion")=="success" for r in x.get("workflow_runs",[]))
raise SystemExit(0 if ok else 1)
' >/dev/null 2>&1; then
    CI_OK=YES
    break
  fi
  sleep 5
done
[ "$CI_OK" = YES ] || fail "CANONICAL_CI_NOT_SUCCESS_FOR_SHA:$REMOTE_SHA" 22
printf 'CANONICAL_CI=PASS\n'

say "3/8 Download exact source"
mkdir -p "$TMP/src"
"$CURL" -fsSL "$CODELOAD_ROOT/$REMOTE_SHA" -o "$TMP/source.tar.gz" || fail "SOURCE_DOWNLOAD_FAILED" 30
tar -xzf "$TMP/source.tar.gz" -C "$TMP/src" --strip-components=1 || fail "SOURCE_EXTRACT_FAILED" 31

INSTALLER="$TMP/src/RECOVERY/INSTALL_SUPRA_AUTOUPDATE_LAUNCHAGENT_V1.sh"
SOURCE_UPDATER="$TMP/src/RECOVERY/SUPRA_AUTOBUILD_SELF_UPDATE_V1.sh"
[ -f "$INSTALLER" ] || fail "INSTALLER_MISSING" 32
[ -f "$SOURCE_UPDATER" ] || fail "UPDATER_SOURCE_MISSING" 33
/bin/bash -n "$INSTALLER" || fail "INSTALLER_SYNTAX_FAIL" 34
/bin/bash -n "$SOURCE_UPDATER" || fail "UPDATER_SYNTAX_FAIL" 35

say "4/8 Install/reload the existing self-update LaunchAgent"
(
  cd "$TMP/src/RECOVERY"
  /bin/bash "$INSTALLER"
) || fail "AUTOUPDATE_INSTALL_FAILED" 40

say "5/8 Let the first automatic update finish"
mkdir -p "$SUPPORT"
for _ in $(seq 1 180); do
  [ ! -d "$SUPPORT/update.lock" ] && break
  sleep 2
done

INSTALLED_SHA="$("$PY" - "$STATE" <<'PY' 2>/dev/null || true
import json,sys,pathlib
p=pathlib.Path(sys.argv[1])
if p.exists():
    try: print(json.loads(p.read_text()).get("installed_source_sha",""))
    except Exception: pass
PY
)"

if [ "$INSTALLED_SHA" != "$REMOTE_SHA" ]; then
  say "6/8 Run one bounded synchronous update now"
  [ -x "$UPDATER" ] || fail "INSTALLED_UPDATER_MISSING:$UPDATER" 50
  /bin/bash "$UPDATER" || fail "SYNCHRONOUS_UPDATE_FAILED" 51
else
  say "6/8 Canonical source already installed"
fi

say "7/8 Verify canonical app + updater + existing bridge"
INSTALLED_SHA="$("$PY" - "$STATE" <<'PY' 2>/dev/null || true
import json,sys,pathlib
p=pathlib.Path(sys.argv[1])
if p.exists():
    try: print(json.loads(p.read_text()).get("installed_source_sha",""))
    except Exception: pass
PY
)"
[ "$INSTALLED_SHA" = "$REMOTE_SHA" ] || fail "INSTALLED_SHA_MISMATCH:$INSTALLED_SHA!=${REMOTE_SHA}" 60
[ -d "$TARGET" ] || fail "CANONICAL_APP_MISSING:$TARGET" 61

retire_auxiliary_surfaces
osascript -e 'tell application id "com.nicolasalonso.SUPRA" to quit' >/dev/null 2>&1 || true
sleep 1
pkill -x SUPRA >/dev/null 2>&1 || true
sleep 1

open "$TARGET" >/dev/null 2>&1 || fail "CANONICAL_APP_LAUNCH_FAILED" 62

PIDS=""
COUNT=0
PID=""
for _ in $(seq 1 40); do
  PIDS="$(pgrep -x SUPRA || true)"
  COUNT="$(printf '%s\n' "$PIDS" | sed '/^$/d' | wc -l | tr -d ' ')"
  if [ "$COUNT" -eq 1 ]; then
    PID="$(printf '%s\n' "$PIDS" | sed '/^$/d' | head -1)"
    break
  fi
  sleep 0.5
done

[ "$COUNT" -eq 1 ] || fail "CANONICAL_APP_INSTANCE_COUNT_NOT_ONE:$COUNT" 63
[ -n "$PID" ] || fail "CANONICAL_APP_NOT_RUNNING" 64
CMD="$(ps -ww -p "$PID" -o command= 2>/dev/null || true)"
case "$CMD" in
  *"$TARGET/Contents/MacOS/SUPRA"*) ;;
  *) fail "NONCANONICAL_SUPRA_PROCESS:$CMD" 65 ;;
esac

launchctl print "gui/$UID/$LABEL" >/dev/null 2>&1 || fail "AUTOUPDATE_LAUNCHAGENT_NOT_ACTIVE" 65

if ! "$CURL" -fsS --max-time 2 "http://127.0.0.1:18765/health" >/dev/null 2>&1 &&
   ! "$CURL" -fsS --max-time 2 "http://127.0.0.1:18765/v1/health" >/dev/null 2>&1; then
  if [ -f "$BRIDGE_PLIST" ]; then
    launchctl bootstrap "gui/$UID" "$BRIDGE_PLIST" >/dev/null 2>&1 || true
    launchctl kickstart -k "gui/$UID/$BRIDGE_LABEL" >/dev/null 2>&1 || true
  fi
fi

BRIDGE_HEALTH=UNPROVEN
for _ in $(seq 1 20); do
  if "$CURL" -fsS --max-time 2 "http://127.0.0.1:18765/health" >/dev/null 2>&1 ||
     "$CURL" -fsS --max-time 2 "http://127.0.0.1:18765/v1/health" >/dev/null 2>&1; then
    BRIDGE_HEALTH=PASS
    break
  fi
  sleep 0.5
done

say "8/8 Read Grande Mission state"
MISSION_STATE="$HOME/NOVA_OS/SUPRA_GRANDE_MISSION_V1/STATE.json"
if [ -s "$MISSION_STATE" ]; then
  "$PY" - "$MISSION_STATE" <<'PY' || true
import json,sys
x=json.load(open(sys.argv[1],encoding="utf-8"))
print("GRANDE_MISSION_CURRENT_PHASE="+str(x.get("current_phase","UNKNOWN")))
print("GRANDE_MISSION_STATUS="+str(x.get("status","UNKNOWN")))
print("GRANDE_MISSION_UPDATED_AT="+str(x.get("updated_at","UNKNOWN")))
PY
else
  printf 'GRANDE_MISSION_CURRENT_PHASE=UNPROVEN\n'
  printf 'GRANDE_MISSION_STATUS=UNPROVEN\n'
fi

printf 'SUPRA_PID=%s\n' "$PID"
printf 'SUPRA_INSTANCE_COUNT=1\n'
printf 'SUPRA_CMD=%s\n' "$CMD"
printf 'AUXILIARY_SURFACES_RETIRE_ATTEMPTED=YES\n'
printf 'INSTALLED_SHA=%s\n' "$INSTALLED_SHA"
printf 'AUTOUPDATE_ACTIVE=PASS\n'
printf 'AUTOUPDATE_INTERVAL_SECONDS=600\n'
printf 'BRIDGE_HEALTH=%s\n' "$BRIDGE_HEALTH"
printf '\nSTATUS=SUPRA_SELF_HEAL_BOOTSTRAP_PASS\n'
printf 'ACTION_NICOLAS=NONE_AFTER_THIS_RUN\n'
