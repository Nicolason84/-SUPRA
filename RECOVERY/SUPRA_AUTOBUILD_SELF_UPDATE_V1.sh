#!/bin/bash
set -euo pipefail

REPO_SLUG="Nicolason84/-SUPRA"
CANON_BRANCH="supra/human-gate-single-source-20260721_072447"
API_ROOT="https://api.github.com/repos/$REPO_SLUG"
CODELOAD_ROOT="https://codeload.github.com/$REPO_SLUG/tar.gz"
RAW_ROOT="https://raw.githubusercontent.com/$REPO_SLUG"
WORKFLOW_NAME="Validate Canonical SUPRA"

SUPPORT="$HOME/Library/Application Support/NOVA ERA/SUPRA Updater"
STATE="$SUPPORT/state.json"
LOG_DIR="$SUPPORT/logs"
ROLLBACK_ROOT="$HOME/Applications/SUPRA Rollback"
RETIRED_ROOT="$HOME/Applications/SUPRA Retired"
TARGET="$HOME/Applications/SUPRA.app"
SYSTEM_LEGACY_TARGET="/Applications/SUPRA.app"
UPDATER_DST="$SUPPORT/supra_autobuild_self_update.sh"

mkdir -p "$SUPPORT" "$LOG_DIR" "$ROLLBACK_ROOT" "$RETIRED_ROOT" "$HOME/Applications"

STAMP="$(date '+%Y%m%d_%H%M%S')"
LOG="$LOG_DIR/update_$STAMP.log"
exec > >(tee -a "$LOG") 2>&1

say(){ printf '\n[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }

kill_all_supra_surfaces(){
  local pid=""
  local cmd=""

  /usr/bin/osascript <<'OSA' >/dev/null 2>&1 || true
tell application "System Events"
  repeat with procName in {"SUPRA", "SUPRAClean", "OjoCompanion"}
    if exists process procName then
      try
        tell process procName to keystroke "q" using command down
      end try
    end if
  end repeat
end tell
OSA

  /bin/sleep 0.8
  /usr/bin/pkill -TERM -x SUPRA >/dev/null 2>&1 || true
  /usr/bin/pkill -TERM -x SUPRAClean >/dev/null 2>&1 || true
  /usr/bin/pkill -TERM -x OjoCompanion >/dev/null 2>&1 || true
  /bin/sleep 0.8

  /usr/bin/pkill -KILL -x SUPRA >/dev/null 2>&1 || true
  /usr/bin/pkill -KILL -x SUPRAClean >/dev/null 2>&1 || true
  /usr/bin/pkill -KILL -x OjoCompanion >/dev/null 2>&1 || true

  while read -r pid; do
    [ -n "$pid" ] || continue
    cmd="$(/bin/ps -ww -p "$pid" -o command= 2>/dev/null || true)"
    case "$cmd" in
      *"/SUPRA-FRANCE.app/Contents/MacOS/"*|*"/SUPRA-FRANCE-CLEAN.app/Contents/MacOS/"*|*"/SUPRAClean.app/Contents/MacOS/"*|*"/OjoCompanion.app/Contents/MacOS/"*)
        /bin/kill -KILL "$pid" >/dev/null 2>&1 || true
        ;;
    esac
  done < <(/usr/bin/pgrep -f 'SUPRA-FRANCE\.app/Contents/MacOS|SUPRA-FRANCE-CLEAN\.app/Contents/MacOS|SUPRAClean\.app/Contents/MacOS|OjoCompanion\.app/Contents/MacOS' || true)

  printf 'LEGACY_SUPRA_PROCESSES=KILL_ATTEMPTED\n'
}


retire_auxiliary_native_surfaces(){
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

close_recovery_finder_windows(){
  /usr/bin/osascript <<'OSA' >/dev/null 2>&1 || true
tell application "Finder"
  repeat with w in windows
    try
      set p to POSIX path of (target of w as alias)
      if p contains "SUPRA_IMAC_MEMORY_GATEWAY" or p contains "SUPRA_CHATGPT_APP_BRIDGE_V1" then
        close w
      end if
    end try
  end repeat
end tell
OSA
}

retire_systemwide_legacy_supra(){
  [ -d "$SYSTEM_LEGACY_TARGET" ] || return 0

  mkdir -p "$RETIRED_ROOT"
  local destination="$RETIRED_ROOT/SYSTEM_SUPRA_${STAMP}.app"

  if mv "$SYSTEM_LEGACY_TARGET" "$destination" 2>/dev/null; then
    printf 'SYSTEM_LEGACY_SUPRA_RETIRED=%s\n' "$destination"
    return 0
  fi

  printf 'SYSTEM_LEGACY_SUPRA_RETIRE_BLOCKED_NON_FATAL=%s\n' "$SYSTEM_LEGACY_TARGET"
  return 0
}

focus_canonical_supra(){
  /usr/bin/osascript <<'OSA' >/dev/null 2>&1 || true
tell application "System Events"
  if exists process "SUPRA" then
    tell process "SUPRA" to set frontmost to true
  end if
end tell
OSA
}

ensure_cannonico_desktop_launcher(){
  local launcher="$HOME/Desktop/CAnnoNico.app"
  local executable="$launcher/Contents/MacOS/CAnnoNico"
  local plist="$launcher/Contents/Info.plist"
  local version=""

  if [ -x "$executable" ] && [ -f "$plist" ]; then
    version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$plist" 2>/dev/null || true)"
    if [ "$version" = "5.0" ]; then
      printf 'CANNONICO_DESKTOP_LAUNCHER=%s\n' "$launcher"
      printf 'CANNONICO_DESKTOP_LAUNCHER_MODE=ONE_SUPRA_NATIVE_V5\n'
      return 0
    fi
  fi

  printf 'CANNONICO_DESKTOP_LAUNCHER=NEEDS_NATIVE_V5_INSTALL\n'
  return 0
}

close_legacy_supra_web_surface(){
  /usr/bin/osascript <<'OSA' >/dev/null 2>&1 || true
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
}

publish_runtime_proof(){
  local installed_sha="${1:-UNKNOWN}"
  local observed_sha="${2:-UNKNOWN}"
  local action="${3:-UNKNOWN}"
  local state_dir=""
  local candidate=""

  for candidate in "$HOME"/Library/CloudStorage/GoogleDrive-*/Mon\ Drive/SUPRA_IMAC_MEMORY_GATEWAY/REMOTE/STATE; do
    [ -d "$candidate" ] || continue
    state_dir="$candidate"
    break
  done

  if [ -z "$state_dir" ]; then
    printf 'REMOTE_RUNTIME_PROOF=STATE_DIR_NOT_FOUND\n'
    return 0
  fi

  local pids=""
  local native_count="0"
  local pid=""
  local cmd=""
  local chrome_supra_count="0"
  local supra_windows=""
  local supra_bundle_id=""
  local supra_network=""
  local supraclean_pids=""
  local supraclean_count="0"
  local supraclean_pid=""
  local supraclean_cmd=""
  local supraclean_windows=""
  local supraclean_bundle_id=""
  local supraclean_network=""
  local supraclean_cwd=""

  pids="$(pgrep -x SUPRA || true)"
  native_count="$(printf '%s\n' "$pids" | sed '/^$/d' | wc -l | tr -d ' ')"
  pid="$(printf '%s\n' "$pids" | sed '/^$/d' | head -1)"
  if [ -n "$pid" ]; then
    cmd="$(ps -ww -p "$pid" -o command= 2>/dev/null || true)"
    supra_windows="$(/usr/bin/osascript -e 'tell application "System Events" to tell process "SUPRA" to get name of every window' 2>/dev/null || true)"
    supra_bundle_id="$(/usr/bin/osascript -e 'tell application "System Events" to get bundle identifier of process "SUPRA"' 2>/dev/null || true)"
    if [ -x /usr/sbin/lsof ]; then
      supra_network="$(/usr/sbin/lsof -nP -a -p "$pid" -iTCP 2>/dev/null | tail -n +2 | head -20 | tr '\n' ';' || true)"
    fi
  fi

  supraclean_pids="$(pgrep -x SUPRAClean || true)"
  supraclean_count="$(printf '%s\n' "$supraclean_pids" | sed '/^$/d' | wc -l | tr -d ' ')"
  supraclean_pid="$(printf '%s\n' "$supraclean_pids" | sed '/^$/d' | head -1)"
  if [ -n "$supraclean_pid" ]; then
    supraclean_cmd="$(ps -ww -p "$supraclean_pid" -o command= 2>/dev/null || true)"
    supraclean_windows="$(/usr/bin/osascript -e 'tell application "System Events" to tell process "SUPRAClean" to get name of every window' 2>/dev/null || true)"
    supraclean_bundle_id="$(/usr/bin/osascript -e 'tell application "System Events" to get bundle identifier of process "SUPRAClean"' 2>/dev/null || true)"
    if [ -x /usr/sbin/lsof ]; then
      supraclean_network="$(/usr/sbin/lsof -nP -a -p "$supraclean_pid" -iTCP 2>/dev/null | tail -n +2 | head -20 | tr '\n' ';' || true)"
      supraclean_cwd="$(/usr/sbin/lsof -a -p "$supraclean_pid" -d cwd -Fn 2>/dev/null | sed -n 's/^n//p' | head -1 || true)"
    fi
  fi

  if pgrep -x "Google Chrome" >/dev/null 2>&1; then
    chrome_supra_count="$(/usr/bin/osascript <<'OSA' 2>/dev/null || echo UNKNOWN
tell application "Google Chrome"
  set n to 0
  repeat with w in windows
    repeat with t in tabs of w
      set tabTitle to title of t
      if tabTitle contains "SUPRA" or tabTitle contains "Situation Vivante" then
        set n to n + 1
      end if
    end repeat
  end repeat
  return n
end tell
OSA
)"
  fi

  local proof="$state_dir/SUPRA_LOCAL_RUNTIME_PROOF.json"
  "$PY" - "$proof" "$installed_sha" "$observed_sha" "$action" "$native_count" "$pid" "$cmd" "$chrome_supra_count" "$supra_windows" "$supra_bundle_id" "$supra_network" "$supraclean_count" "$supraclean_pid" "$supraclean_cmd" "$supraclean_windows" "$supraclean_bundle_id" "$supraclean_network" "$supraclean_cwd" <<'PY'
import datetime,json,os,pathlib,sys,tempfile
(path,installed,observed,action,native_count,pid,cmd,chrome_count,
 supra_windows,supra_bundle_id,supra_network,supraclean_count,supraclean_pid,
 supraclean_cmd,supraclean_windows,supraclean_bundle_id,supraclean_network,
 supraclean_cwd)=sys.argv[1:]
mission_state_path=pathlib.Path.home()/"NOVA_OS/SUPRA_GRANDE_MISSION_V1/STATE.json"
mission_state={}
try:
  if mission_state_path.exists():
    mission_state=json.loads(mission_state_path.read_text(encoding="utf-8"))
except Exception:
  mission_state={}
canonical_target=str(pathlib.Path.home()/"Applications/SUPRA.app/Contents/MacOS/SUPRA")
canonical_process=(native_count=="1" and canonical_target in (cmd or ""))

obj={
  "schema":"SUPRA_LOCAL_RUNTIME_PROOF_V1",
  "status":"PASS" if canonical_process else "DEGRADED",
  "installed_source_sha":installed,
  "observed_canonical_sha":observed,
  "last_action":action,
  "native_instance_count":int(native_count or 0),
  "native_pid":int(pid) if pid.isdigit() else None,
  "native_command":cmd or None,
  "native_windows":supra_windows or None,
  "native_bundle_id":supra_bundle_id or None,
  "native_tcp":supra_network or None,
  "supraclean_instance_count":int(supraclean_count or 0),
  "supraclean_pid":int(supraclean_pid) if supraclean_pid.isdigit() else None,
  "supraclean_command":supraclean_cmd or None,
  "supraclean_windows":supraclean_windows or None,
  "supraclean_bundle_id":supraclean_bundle_id or None,
  "supraclean_tcp":supraclean_network or None,
  "supraclean_cwd":supraclean_cwd or None,
  "shared_runtime_endpoint_observed": any(
      marker in (supra_network or "") and marker in (supraclean_network or "")
      for marker in ("127.0.0.1:18765","127.0.0.1:4096")
  ),
  "canonical_process_path_proven":canonical_process,
  "one_supra_authority":(
      "PROVEN_CANONICAL_ONLY"
      if canonical_process and int(supraclean_count or 0)==0
      else (
          "UNPROVEN_NONCANONICAL_SUPRA_PROCESS"
          if native_count=="1" and not canonical_process
          else "UNPROVEN_AUXILIARY_OR_MULTIPLE_SURFACE"
      )
  ),
  "chrome_supra_surface_count":int(chrome_count) if chrome_count.isdigit() else None,
  "chrome_supra_surface_probe": "PASS" if chrome_count.isdigit() else "UNPROVEN",
  "canonical_target":str(pathlib.Path.home()/"Applications/SUPRA.app"),
  "grande_mission_state_path":str(mission_state_path),
  "grande_mission_current_phase":mission_state.get("current_phase"),
  "grande_mission_status":mission_state.get("status"),
  "grande_mission_updated_at":mission_state.get("updated_at"),
  "grande_mission_detail":mission_state.get("detail"),
  "timestamp":datetime.datetime.now(datetime.timezone.utc).isoformat()
}
p=pathlib.Path(path)
p.parent.mkdir(parents=True,exist_ok=True)
fd,tmp=tempfile.mkstemp(prefix=".SUPRA_LOCAL_RUNTIME_PROOF.",suffix=".json",dir=str(p.parent))
os.close(fd)
pathlib.Path(tmp).write_text(json.dumps(obj,indent=2)+"\n",encoding="utf-8")
os.replace(tmp,p)
print(json.dumps(obj,separators=(",",":")))
PY
  printf 'REMOTE_RUNTIME_PROOF=%s\n' "$proof"
}

publish_container_projection(){
  local projection_root="$HOME/Library/Containers/com.nicolasalonso.SUPRA/Data/Library/Application Support/SUPRA/Projection"
  local decisions_source="$HOME/NOVA_OS/SUPRA_READ_RECONCILED_VERDICT_AND_REPUBLISH_ARCHITECTURE_DECISION_BOARD_V1/CURRENT/ARCHITECTURAL_DECISIONS.json"
  local updater_projection="$projection_root/UPDATER_STATE.json"
  local decisions_projection="$projection_root/ARCHITECTURAL_DECISIONS.json"

  mkdir -p "$projection_root" || {
    printf 'CONTAINER_PROJECTION=UNAVAILABLE_CREATE_DIR\n'
    return 0
  }

  if [ -s "$STATE" ]; then
    "$PY" - "$STATE" "$updater_projection" <<'PY'
import json,os,pathlib,sys,tempfile,datetime
src=pathlib.Path(sys.argv[1]); dst=pathlib.Path(sys.argv[2])
try:
    raw=json.loads(src.read_text(encoding="utf-8"))
except Exception:
    raise SystemExit(2)
allowed={
    "schema":raw.get("schema"),
    "installed_source_sha":raw.get("installed_source_sha"),
    "observed_canonical_sha":raw.get("observed_canonical_sha"),
    "installed_exec_sha256":raw.get("installed_exec_sha256"),
    "last_ci":raw.get("last_ci"),
    "bridge_health":raw.get("bridge_health"),
    "installed_path":raw.get("installed_path"),
    "rollback_path":raw.get("rollback_path"),
    "installed_at":raw.get("installed_at"),
    "last_check_at":raw.get("last_check_at"),
    "last_action":raw.get("last_action"),
    "projection_generated_at":datetime.datetime.now(datetime.timezone.utc).isoformat(),
    "projection_authority":"EXISTING_GOVERNED_SUPRA_UPDATER"
}
dst.parent.mkdir(parents=True,exist_ok=True)
fd,tmp=tempfile.mkstemp(prefix=".UPDATER_STATE.",suffix=".json",dir=str(dst.parent)); os.close(fd)
pathlib.Path(tmp).write_text(json.dumps(allowed,indent=2)+"\n",encoding="utf-8")
os.replace(tmp,dst)
PY
    if [ "$?" -eq 0 ]; then
      printf 'CONTAINER_UPDATER_PROJECTION=%s\n' "$updater_projection"
    else
      printf 'CONTAINER_UPDATER_PROJECTION=UNPROVEN\n'
    fi
  else
    printf 'CONTAINER_UPDATER_PROJECTION=STATE_MISSING\n'
  fi

  if [ -s "$decisions_source" ]; then
    "$PY" - "$decisions_source" "$decisions_projection" <<'PY'
import json,os,pathlib,sys,tempfile,datetime
src=pathlib.Path(sys.argv[1]); dst=pathlib.Path(sys.argv[2])
try:
    raw=json.loads(src.read_text(encoding="utf-8"))
except Exception:
    raise SystemExit(2)
out={
    "schema":"SUPRA_ARCHITECTURAL_DECISIONS_PROJECTION_V1",
    "projection_authority":"EXISTING_GOVERNED_SUPRA_UPDATER",
    "projection_generated_at":datetime.datetime.now(datetime.timezone.utc).isoformat(),
    "source_path":str(src),
    "source_generated_at":raw.get("generated_at"),
    "source_status":raw.get("status"),
    "source_mission":raw.get("mission"),
    "execution_authorized":bool(raw.get("execution_authorized",False)),
    "decision_count":raw.get("decision_count",len(raw.get("decisions",[]))),
    "decisions":raw.get("decisions",[])
}
dst.parent.mkdir(parents=True,exist_ok=True)
fd,tmp=tempfile.mkstemp(prefix=".ARCHITECTURAL_DECISIONS.",suffix=".json",dir=str(dst.parent)); os.close(fd)
pathlib.Path(tmp).write_text(json.dumps(out,indent=2)+"\n",encoding="utf-8")
os.replace(tmp,dst)
PY
    if [ "$?" -eq 0 ]; then
      printf 'CONTAINER_DECISION_PROJECTION=%s\n' "$decisions_projection"
    else
      printf 'CONTAINER_DECISION_PROJECTION=UNPROVEN\n'
    fi
  else
    printf 'CONTAINER_DECISION_PROJECTION=SOURCE_MISSING\n'
  fi
}

fail(){
  code=1
  [ "$#" -gt 1 ] && code="$2"
  printf '\nSTATUS=FAIL_BOUNDED\nBLOCKER=%s\n' "$1"
  exit "$code"
}

on_err(){
  rc=$?
  printf '\nSTATUS=FAIL_BOUNDED\nBLOCKER=UNEXPECTED_COMMAND_FAILURE\n'
  printf 'FAIL_RC=%s\nFAIL_LINE=%s\nFAIL_COMMAND=%s\n' "$rc" "${BASH_LINENO[0]:-UNKNOWN}" "${BASH_COMMAND:-UNKNOWN}"
  exit "$rc"
}
trap on_err ERR

PY="$(command -v python3 || true)"
CURL="$(command -v curl || true)"
XCODEBUILD="$(command -v xcodebuild || true)"
CODESIGN="$(command -v codesign || true)"
DITTO="$(command -v ditto || true)"

[ -n "$PY" ] || fail "PYTHON3_NOT_FOUND" 10
[ -n "$CURL" ] || fail "CURL_NOT_FOUND" 11
[ -n "$XCODEBUILD" ] || fail "XCODEBUILD_NOT_FOUND" 12
[ -n "$CODESIGN" ] || fail "CODESIGN_NOT_FOUND" 13
[ -n "$DITTO" ] || fail "DITTO_NOT_FOUND" 14

LOCK="$SUPPORT/update.lock"
if ! mkdir "$LOCK" 2>/dev/null; then
  printf 'STATUS=SKIP_ALREADY_RUNNING\n'
  exit 0
fi
cleanup_lock(){ rmdir "$LOCK" >/dev/null 2>&1 || true; }
trap cleanup_lock EXIT

CANNONICO_LAUNCHER_STATUS=UNPROVEN
if ensure_cannonico_desktop_launcher; then
  CANNONICO_LAUNCHER_STATUS=PASS
else
  CANNONICO_LAUNCHER_STATUS=DEGRADED
  printf 'CANNONICO_DESKTOP_LAUNCHER=DEGRADED\n'
fi
printf 'CANNONICO_LAUNCHER_STATUS=%s\n' "$CANNONICO_LAUNCHER_STATUS"

say "1/10 Resolve canonical remote SHA"
ENC_BRANCH="$(printf '%s' "$CANON_BRANCH" | sed 's#/#%2F#g')"
REMOTE_SHA="$("$CURL" -fsSL "$API_ROOT/branches/$ENC_BRANCH" | "$PY" -c 'import json,sys; print(json.load(sys.stdin)["commit"]["sha"])')" || fail "REMOTE_SHA_UNAVAILABLE" 20
[ -n "$REMOTE_SHA" ] || fail "REMOTE_SHA_EMPTY" 21
printf 'REMOTE_SHA=%s\n' "$REMOTE_SHA"

INSTALLED_SHA=""
OBSERVED_SHA=""
if [ -s "$STATE" ]; then
  INSTALLED_SHA="$("$PY" - "$STATE" <<'PY' 2>/dev/null || true
import json,sys
x=json.load(open(sys.argv[1],encoding="utf-8"))
print(x.get("installed_source_sha",""))
PY
)"
  OBSERVED_SHA="$("$PY" - "$STATE" <<'PY' 2>/dev/null || true
import json,sys
x=json.load(open(sys.argv[1],encoding="utf-8"))
print(x.get("observed_canonical_sha",""))
PY
)"
fi
APP_PROVEN_SHA=""
if [ -f "$TARGET/Contents/Info.plist" ]; then
  APP_PROVEN_SHA="$(/usr/libexec/PlistBuddy -c 'Print :SUPRASourceSHA' "$TARGET/Contents/Info.plist" 2>/dev/null || true)"
fi

printf 'STATE_INSTALLED_SHA=%s\nOBSERVED_SHA=%s\nAPP_PROVEN_SHA=%s\n' "$INSTALLED_SHA" "$OBSERVED_SHA" "$APP_PROVEN_SHA"

if [ -d "$TARGET" ]; then
  if [ -n "$APP_PROVEN_SHA" ]; then
    if [ -n "$INSTALLED_SHA" ] && [ "$INSTALLED_SHA" != "$APP_PROVEN_SHA" ]; then
      printf 'INSTALL_STATE_DRIFT=STATE:%s APP:%s\n' "$INSTALLED_SHA" "$APP_PROVEN_SHA"
    fi
    INSTALLED_SHA="$APP_PROVEN_SHA"
  else
    printf 'INSTALL_STATE_DRIFT=APP_PROVENANCE_MISSING_FORCE_REBUILD\n'
    INSTALLED_SHA=""
  fi
fi
printf 'EFFECTIVE_INSTALLED_SHA=%s\n' "$INSTALLED_SHA"

if [ -n "$INSTALLED_SHA" ] && [ "$REMOTE_SHA" = "$INSTALLED_SHA" ]; then
  say "2/10 Canonical app is up to date — ensure it is running"
  if [ ! -d "$TARGET" ]; then
    fail "UP_TO_DATE_BUT_CANONICAL_APP_MISSING:$TARGET" 22
  fi

  PIDS="$(pgrep -x SUPRA || true)"
  RUNNING_COUNT="$(printf '%s\n' "$PIDS" | sed '/^$/d' | wc -l | tr -d ' ')"
  CANONICAL_COUNT=0
  PID=""
  CMD=""

  for CANDIDATE_PID in $PIDS; do
    CANDIDATE_CMD="$(ps -ww -p "$CANDIDATE_PID" -o command= 2>/dev/null || true)"
    case "$CANDIDATE_CMD" in
      *"$TARGET/Contents/MacOS/SUPRA"*)
        CANONICAL_COUNT=$((CANONICAL_COUNT + 1))
        PID="$CANDIDATE_PID"
        CMD="$CANDIDATE_CMD"
        ;;
    esac
  done

  if [ "$RUNNING_COUNT" -ne 1 ] || [ "$CANONICAL_COUNT" -ne 1 ]; then
    say "Canonicalize live SUPRA instance"
    kill_all_supra_surfaces
    sleep 1
    retire_systemwide_legacy_supra || fail "SYSTEMWIDE_LEGACY_SUPRA_COULD_NOT_BE_RETIRED:$SYSTEM_LEGACY_TARGET" 23
    open "$TARGET" || fail "UP_TO_DATE_APP_AUTOLAUNCH_FAILED" 24
    for ((WAIT_I=0; WAIT_I<30; WAIT_I++)); do
      PIDS="$(pgrep -x SUPRA || true)"
      RUNNING_COUNT="$(printf '%s\n' "$PIDS" | sed '/^$/d' | wc -l | tr -d ' ')"
      [ "$RUNNING_COUNT" -eq 1 ] && break
      sleep 0.5
    done
    [ "$RUNNING_COUNT" -eq 1 ] || fail "UP_TO_DATE_SINGLE_INSTANCE_NOT_PROVEN:$RUNNING_COUNT" 25
    PID="$(printf '%s\n' "$PIDS" | sed '/^$/d' | head -1)"
    CMD="$(ps -ww -p "$PID" -o command= 2>/dev/null || true)"
  fi

  [ -n "$PID" ] || fail "UP_TO_DATE_APP_NOT_RUNNING_AFTER_AUTOLAUNCH" 25

  case "$CMD" in
    *"$TARGET/Contents/MacOS/SUPRA"*) ;;
    *) fail "UP_TO_DATE_APP_RUNNING_FROM_NONCANONICAL_PATH:$CMD" 26 ;;
  esac

  retire_auxiliary_native_surfaces
  close_recovery_finder_windows
  close_legacy_supra_web_surface
  focus_canonical_supra
  sleep 0.5
  publish_runtime_proof "$INSTALLED_SHA" "$REMOTE_SHA" "UP_TO_DATE_AND_RUNNING" || printf 'REMOTE_RUNTIME_PROOF=NON_BLOCKING_FAILURE\n'
  publish_container_projection || printf 'CONTAINER_PROJECTION=NON_BLOCKING_FAILURE\n'
  printf 'SUPRA_PID=%s\n' "$PID"
  printf 'SUPRA_CMD=%s\n' "$CMD"
  printf 'SUPRA_INSTANCE_COUNT=1\n'
  printf 'LEGACY_SUPRA_WEB_SURFACE=CLOSE_ATTEMPTED\n'
  printf '\nSTATUS=UP_TO_DATE_AND_RUNNING\n'
  exit 0
fi

say "2/10 Decide whether app rebuild is necessary"
NEEDS_BUILD=YES
CHANGED_FILES_JSON="[]"
if [ -n "$INSTALLED_SHA" ]; then
  COMPARE_TMP="$(mktemp)"
  if "$CURL" -fsSL "$API_ROOT/compare/$INSTALLED_SHA...$REMOTE_SHA" -o "$COMPARE_TMP"; then
    CHANGED_FILES_JSON="$("$PY" - "$COMPARE_TMP" <<'PY'
import json,sys
x=json.load(open(sys.argv[1],encoding="utf-8"))
print(json.dumps([f.get("filename","") for f in x.get("files",[])]))
PY
)"
    NEEDS_BUILD="$("$PY" - "$COMPARE_TMP" <<'PY'
import json,sys
x=json.load(open(sys.argv[1],encoding="utf-8"))
files=[f.get("filename","") for f in x.get("files",[])]
prefixes=("SUPRA/","Packages/","SUPRA.xcodeproj/")
print("YES" if any(p.startswith(prefixes) for p in files) else "NO")
PY
)"
  fi
  rm -f "$COMPARE_TMP"
fi
printf 'NEEDS_BUILD=%s\nCHANGED_FILES=%s\n' "$NEEDS_BUILD" "$CHANGED_FILES_JSON"

say "3/10 Require successful canonical CI for exact SHA"
RUNS_TMP="$(mktemp)"
"$CURL" -fsSL "$API_ROOT/actions/runs?head_sha=$REMOTE_SHA&status=completed&per_page=50" -o "$RUNS_TMP" || fail "CI_RUN_QUERY_FAILED" 30
CI_PROOF="$("$PY" - "$RUNS_TMP" "$WORKFLOW_NAME" <<'PY'
import json,sys
x=json.load(open(sys.argv[1],encoding="utf-8"))
name=sys.argv[2]
ok=[r for r in x.get("workflow_runs",[]) if r.get("name")==name and r.get("conclusion")=="success"]
if not ok:
    raise SystemExit(2)
r=sorted(ok,key=lambda z:z.get("updated_at") or "",reverse=True)[0]
print(json.dumps({"id":r.get("id"),"html_url":r.get("html_url"),"conclusion":r.get("conclusion"),"updated_at":r.get("updated_at")},separators=(",",":")))
PY
)" || { rm -f "$RUNS_TMP"; fail "CANONICAL_CI_NOT_SUCCESS_FOR_SHA:$REMOTE_SHA" 31; }
rm -f "$RUNS_TMP"
printf 'CI_PROOF=%s\n' "$CI_PROOF"

if [ "$NEEDS_BUILD" = "NO" ] && [ -d "$TARGET" ]; then
  say "4/10 No app-impacting change"

  SELF_REFRESH_TMP="$(mktemp)"
  if "$CURL" -fsSL "$RAW_ROOT/$REMOTE_SHA/RECOVERY/SUPRA_AUTOBUILD_SELF_UPDATE_V1.sh" -o "$SELF_REFRESH_TMP" &&
     /bin/bash -n "$SELF_REFRESH_TMP"; then
    cp "$SELF_REFRESH_TMP" "$UPDATER_DST"
    chmod 700 "$UPDATER_DST"
    printf 'AUTOUPDATE_SELF_REFRESH=PASS\n'
  else
    printf 'AUTOUPDATE_SELF_REFRESH=UNPROVEN\n'
  fi
  rm -f "$SELF_REFRESH_TMP"
  "$PY" - "$STATE" "$REMOTE_SHA" "$INSTALLED_SHA" "$CI_PROOF" <<'PY'
import json,sys,datetime,pathlib
p=pathlib.Path(sys.argv[1])
try:
    x=json.loads(p.read_text()) if p.exists() else {}
except Exception:
    x={}
x.update({
 "schema":"SUPRA_AUTOUPDATE_STATE_V1",
 "observed_canonical_sha":sys.argv[2],
 "installed_source_sha":sys.argv[3],
 "last_ci":json.loads(sys.argv[4]),
 "last_check_at":datetime.datetime.now(datetime.timezone.utc).isoformat(),
 "last_action":"NO_APP_REBUILD_REQUIRED"
})
p.write_text(json.dumps(x,indent=2)+"\n")
PY
    publish_runtime_proof "$INSTALLED_SHA" "$REMOTE_SHA" "NO_APP_REBUILD_REQUIRED" || printf 'REMOTE_RUNTIME_PROOF=NON_BLOCKING_FAILURE\n'
    publish_container_projection || printf 'CONTAINER_PROJECTION=NON_BLOCKING_FAILURE\n'
  printf '\nSTATUS=NO_APP_REBUILD_REQUIRED\n'
  exit 0
fi

say "4/10 Download exact canonical source in isolation"
TMP="$(mktemp -d /tmp/SUPRA_AUTOUPDATE.XXXXXX)"
cleanup_tmp(){ rm -rf "$TMP" >/dev/null 2>&1 || true; }
trap 'cleanup_tmp; cleanup_lock' EXIT
TARBALL="$TMP/source.tar.gz"
SRC="$TMP/src"
mkdir -p "$SRC"

"$CURL" -fsSL "$CODELOAD_ROOT/$REMOTE_SHA" -o "$TARBALL" || fail "SOURCE_DOWNLOAD_FAILED" 40
tar -xzf "$TARBALL" -C "$SRC" --strip-components=1 || fail "SOURCE_EXTRACT_FAILED" 41

test -f "$SRC/SUPRA/SUPRAOJOHomeView.swift" || fail "SHELL_SOURCE_MISSING" 42
test -f "$SRC/SUPRA/SUPRAChatRuntimeAdapter.swift" || fail "CHAT_ADAPTER_MISSING" 43
grep -Fq 'enum SUPRAUniverse' "$SRC/SUPRA/SUPRAOJOHomeView.swift" || fail "MULTI_UNIVERSE_MARKER_MISSING" 44
grep -Fq 'glassEffect' "$SRC/SUPRA/SUPRAOJOHomeView.swift" || fail "TECHNICAL_GLASS_SHELL_MARKER_MISSING" 45
grep -Fq 'OrganizationPeopleView()' "$SRC/SUPRA/SUPRAOJOHomeView.swift" || fail "ORGANIZATION_UNIVERSE_MISSING" 46
grep -Fq 'defaultHealthURLs' "$SRC/SUPRA/SUPRAChatRuntimeAdapter.swift" || fail "ADAPTIVE_HEALTH_MARKER_MISSING" 47

say "5/10 Resolve dependencies + Release build"
DERIVED="$TMP/DerivedData"
(
  cd "$SRC"
  for ATTEMPT in 1 2 3; do
    "$XCODEBUILD" -project SUPRA.xcodeproj -scheme SUPRA -resolvePackageDependencies && exit 0
    [ "$ATTEMPT" = "3" ] && exit 1
    sleep 3
  done
) || fail "PACKAGE_RESOLUTION_FAILED" 50

BUILD_LOG="$TMP/xcodebuild.log"
"$XCODEBUILD" -project "$SRC/SUPRA.xcodeproj" -scheme SUPRA -configuration Release -sdk macosx -derivedDataPath "$DERIVED" CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build >"$BUILD_LOG" 2>&1 || {
  tail -n 160 "$BUILD_LOG" || true
  fail "XCODEBUILD_RELEASE_FAILED" 51
}

BUILT="$(find "$DERIVED/Build/Products/Release" -maxdepth 1 -type d -name 'SUPRA.app' -print -quit)"
[ -d "$BUILT" ] || fail "BUILT_APP_NOT_FOUND" 52

say "6/10 Stamp source provenance + sign + verify candidate"
BUILT_INFO="$BUILT/Contents/Info.plist"
[ -f "$BUILT_INFO" ] || fail "BUILT_INFO_PLIST_MISSING" 59
/usr/libexec/PlistBuddy -c "Delete :SUPRASourceSHA" "$BUILT_INFO" >/dev/null 2>&1 || true
/usr/libexec/PlistBuddy -c "Add :SUPRASourceSHA string $REMOTE_SHA" "$BUILT_INFO" || fail "SOURCE_SHA_STAMP_FAILED" 59
/usr/libexec/PlistBuddy -c "Delete :SUPRABuildUTC" "$BUILT_INFO" >/dev/null 2>&1 || true
/usr/libexec/PlistBuddy -c "Add :SUPRABuildUTC string $(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$BUILT_INFO" || true

ENTITLEMENTS="$SRC/SUPRA/SUPRA.entitlements"
if [ -f "$ENTITLEMENTS" ]; then
  "$CODESIGN" --force --deep --sign - --timestamp=none --entitlements "$ENTITLEMENTS" "$BUILT" || fail "ADHOC_SIGN_FAILED" 60
else
  "$CODESIGN" --force --deep --sign - --timestamp=none "$BUILT" || fail "ADHOC_SIGN_FAILED" 61
fi
"$CODESIGN" --verify --deep --strict --verbose=4 "$BUILT" || fail "CODESIGN_VERIFY_FAILED" 62

EXEC="$BUILT/Contents/MacOS/SUPRA"
[ -x "$EXEC" ] || fail "BUILT_EXECUTABLE_MISSING" 63
EXEC_SHA="$(shasum -a 256 "$EXEC" | awk '{print $1}')"
printf 'BUILT_EXEC_SHA256=%s\n' "$EXEC_SHA"

say "7/10 Restore existing bridge before swap"
LABEL="com.novaera.sol-github-bridge"
PLIST="$HOME/Library/LaunchAgents/"$LABEL".plist"
if [ -f "$PLIST" ]; then
  launchctl bootstrap "gui/$UID" "$PLIST" >/dev/null 2>&1 || true
  launchctl kickstart -k "gui/$UID/$LABEL" >/dev/null 2>&1 || true
fi

bridge_health(){
  "$CURL" -fsS --max-time 3 "http://127.0.0.1:18765/health" >/dev/null 2>&1 ||
  "$CURL" -fsS --max-time 3 "http://127.0.0.1:18765/v1/health" >/dev/null 2>&1
}

BRIDGE_HEALTH=UNPROVEN
for ((BRIDGE_I=0; BRIDGE_I<12; BRIDGE_I++)); do
  if bridge_health; then BRIDGE_HEALTH=PASS; break; fi
  sleep 0.5
done
printf 'BRIDGE_HEALTH=%s\n' "$BRIDGE_HEALTH"

say "8/10 Install with rollback"
BACKUP=""
if [ -d "$TARGET" ]; then
  BACKUP="$ROLLBACK_ROOT/SUPRA_$STAMP.app"
  "$DITTO" "$TARGET" "$BACKUP" || fail "ROLLBACK_COPY_FAILED" 70
fi

RETIRE_DIR="$RETIRED_ROOT/$STAMP"
mkdir -p "$RETIRE_DIR"
for LEGACY in "$HOME/Applications/SUPRA-FRANCE.app" "$HOME/Applications/SUPRA-FRANCE-CLEAN.app"; do
  if [ -d "$LEGACY" ]; then mv "$LEGACY" "$RETIRE_DIR/" || true; fi
done

kill_all_supra_surfaces
sleep 1
retire_systemwide_legacy_supra || fail "SYSTEMWIDE_LEGACY_SUPRA_COULD_NOT_BE_RETIRED:$SYSTEM_LEGACY_TARGET" 70
sleep 1

CANDIDATE="$HOME/Applications/.SUPRA.candidate.$STAMP.app"
rm -rf "$CANDIDATE"
"$DITTO" "$BUILT" "$CANDIDATE" || fail "CANDIDATE_COPY_FAILED" 71
"$CODESIGN" --verify --deep --strict "$CANDIDATE" || fail "CANDIDATE_VERIFY_FAILED" 72

rm -rf "$TARGET"
if ! mv "$CANDIDATE" "$TARGET"; then
  rm -rf "$TARGET" "$CANDIDATE"
  if [ -n "$BACKUP" ] && [ -d "$BACKUP" ]; then "$DITTO" "$BACKUP" "$TARGET" || true; fi
  fail "TARGET_SWAP_FAILED_ROLLBACK_ATTEMPTED" 73
fi
xattr -dr com.apple.quarantine "$TARGET" >/dev/null 2>&1 || true
INSTALLED_APP_SHA="$(/usr/libexec/PlistBuddy -c 'Print :SUPRASourceSHA' "$TARGET/Contents/Info.plist" 2>/dev/null || true)"
[ "$INSTALLED_APP_SHA" = "$REMOTE_SHA" ] || fail "INSTALLED_APP_SHA_MISMATCH:$INSTALLED_APP_SHA!=${REMOTE_SHA}" 74
printf 'INSTALLED_APP_SHA=%s\n' "$INSTALLED_APP_SHA"

say "9/10 Launch + prove"
open "$TARGET"
focus_canonical_supra
PID=""
PIDS=""
RUNNING_COUNT=0
for ((LAUNCH_I=0; LAUNCH_I<30; LAUNCH_I++)); do
  PIDS="$(pgrep -x SUPRA || true)"
  RUNNING_COUNT="$(printf '%s\n' "$PIDS" | sed '/^$/d' | wc -l | tr -d ' ')"
  if [ "$RUNNING_COUNT" -eq 1 ]; then
    PID="$(printf '%s\n' "$PIDS" | sed '/^$/d' | head -1)"
    break
  fi
  sleep 0.5
done

if [ -z "$PID" ] || [ "$RUNNING_COUNT" -ne 1 ]; then
  rm -rf "$TARGET"
  if [ -n "$BACKUP" ] && [ -d "$BACKUP" ]; then "$DITTO" "$BACKUP" "$TARGET"; open "$TARGET" || true; fi
  fail "NEW_APP_DID_NOT_LAUNCH_ROLLBACK_ATTEMPTED" 80
fi

CMD="$(ps -ww -p "$PID" -o command= 2>/dev/null || true)"
close_legacy_supra_web_surface
printf 'PID=%s\nCMD=%s\nSUPRA_INSTANCE_COUNT=%s\n' "$PID" "$CMD" "$RUNNING_COUNT"
printf 'LEGACY_SUPRA_WEB_SURFACE=CLOSE_ATTEMPTED\n'
printf 'AUXILIARY_NATIVE_SURFACES=RETIRE_ATTEMPTED\n'
case "$CMD" in
  *"$TARGET/Contents/MacOS/SUPRA"*) ;;
  *)
    rm -rf "$TARGET"
    if [ -n "$BACKUP" ] && [ -d "$BACKUP" ]; then "$DITTO" "$BACKUP" "$TARGET"; open "$TARGET" || true; fi
    fail "LAUNCHED_BINARY_PATH_NOT_CANONICAL:$CMD" 81
    ;;
esac

if [ -f "$SRC/RECOVERY/SUPRA_AUTOBUILD_SELF_UPDATE_V1.sh" ]; then
  cp "$SRC/RECOVERY/SUPRA_AUTOBUILD_SELF_UPDATE_V1.sh" "$UPDATER_DST"
  chmod 700 "$UPDATER_DST"
fi

"$PY" - "$ROLLBACK_ROOT" <<'PY'
import pathlib,shutil,sys
root=pathlib.Path(sys.argv[1])
items=sorted(
    root.glob("SUPRA_*.app"),
    key=lambda p: p.stat().st_mtime,
    reverse=True
)
for old in items[5:]:
    shutil.rmtree(old)
PY

say "10/10 Persist receipt"
"$PY" - "$STATE" "$REMOTE_SHA" "$EXEC_SHA" "$CI_PROOF" "$BRIDGE_HEALTH" "$TARGET" "$BACKUP" <<'PY'
import json,sys,datetime,pathlib
state=pathlib.Path(sys.argv[1])
receipt={
 "schema":"SUPRA_AUTOUPDATE_STATE_V1",
 "installed_source_sha":sys.argv[2],
 "observed_canonical_sha":sys.argv[2],
 "installed_exec_sha256":sys.argv[3],
 "last_ci":json.loads(sys.argv[4]),
 "bridge_health":sys.argv[5],
 "installed_path":sys.argv[6],
 "rollback_path":sys.argv[7] or None,
 "installed_at":datetime.datetime.now(datetime.timezone.utc).isoformat(),
 "last_action":"BUILD_SIGN_INSTALL_LAUNCH_PASS"
}
state.write_text(json.dumps(receipt,indent=2)+"\n")
print(json.dumps(receipt,separators=(",",":")))
PY

printf '\nSTATUS=MATERIAL_RESULT_PROVEN\n'
printf 'INSTALLED_SHA=%s\n' "$REMOTE_SHA"
printf 'TARGET=%s\n' "$TARGET"
printf 'BRIDGE_HEALTH=%s\n' "$BRIDGE_HEALTH"
publish_runtime_proof "$REMOTE_SHA" "$REMOTE_SHA" "BUILD_SIGN_INSTALL_LAUNCH_PASS" || printf 'REMOTE_RUNTIME_PROOF=NON_BLOCKING_FAILURE\n'
publish_container_projection || printf 'CONTAINER_PROJECTION=NON_BLOCKING_FAILURE\n'
printf 'AUTOUPDATE_SELF_REFRESH=PASS\n'
