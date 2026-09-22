#!/bin/bash
set -euo pipefail

REPO_SLUG="Nicolason84/-SUPRA"
CANON_BRANCH="supra/human-gate-single-source-20260721_072447"
API_ROOT="https://api.github.com/repos/$REPO_SLUG"
CODELOAD_ROOT="https://codeload.github.com/$REPO_SLUG/tar.gz"
WORKFLOW_NAME="Validate Canonical SUPRA"

SUPPORT="$HOME/Library/Application Support/NOVA ERA/SUPRA Updater"
STATE="$SUPPORT/state.json"
LOG_DIR="$SUPPORT/logs"
ROLLBACK_ROOT="$HOME/Applications/SUPRA Rollback"
RETIRED_ROOT="$HOME/Applications/SUPRA Retired"
TARGET="$HOME/Applications/SUPRA.app"
UPDATER_DST="$SUPPORT/supra_autobuild_self_update.sh"

mkdir -p "$SUPPORT" "$LOG_DIR" "$ROLLBACK_ROOT" "$RETIRED_ROOT" "$HOME/Applications"

STAMP="$(date '+%Y%m%d_%H%M%S')"
LOG="$LOG_DIR/update_$STAMP.log"
exec > >(tee -a "$LOG") 2>&1

say(){ printf '\n[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }
fail(){
  code=1
  [ "$#" -gt 1 ] && code="$2"
  printf '\nSTATUS=FAIL_BOUNDED\nBLOCKER=%s\n' "$1"
  exit "$code"
}

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
printf 'INSTALLED_SHA=%s\nOBSERVED_SHA=%s\n' "$INSTALLED_SHA" "$OBSERVED_SHA"

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
    osascript -e 'tell application id "com.nicolasalonso.SUPRA" to quit' >/dev/null 2>&1 || true
    sleep 1
    pkill -x SUPRA >/dev/null 2>&1 || true
    sleep 1
    open "$TARGET" || fail "UP_TO_DATE_APP_AUTOLAUNCH_FAILED" 23
    for _ in $(seq 1 30); do
      PIDS="$(pgrep -x SUPRA || true)"
      RUNNING_COUNT="$(printf '%s\n' "$PIDS" | sed '/^$/d' | wc -l | tr -d ' ')"
      [ "$RUNNING_COUNT" -eq 1 ] && break
      sleep 0.5
    done
    [ "$RUNNING_COUNT" -eq 1 ] || fail "UP_TO_DATE_SINGLE_INSTANCE_NOT_PROVEN:$RUNNING_COUNT" 24
    PID="$(printf '%s\n' "$PIDS" | sed '/^$/d' | head -1)"
    CMD="$(ps -ww -p "$PID" -o command= 2>/dev/null || true)"
  fi

  [ -n "$PID" ] || fail "UP_TO_DATE_APP_NOT_RUNNING_AFTER_AUTOLAUNCH" 24

  case "$CMD" in
    *"$TARGET/Contents/MacOS/SUPRA"*) ;;
    *) fail "UP_TO_DATE_APP_RUNNING_FROM_NONCANONICAL_PATH:$CMD" 25 ;;
  esac

  printf 'SUPRA_PID=%s\n' "$PID"
  printf 'SUPRA_CMD=%s\n' "$CMD"
  printf 'SUPRA_INSTANCE_COUNT=1\n'
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
prefixes=("SUPRA/","Packages/","SUPRA.xcodeproj/","RECOVERY/SUPRA_AUTOBUILD_SELF_UPDATE_V1.sh","RECOVERY/INSTALL_SUPRA_AUTOUPDATE_LAUNCHAGENT_V1.sh")
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

say "6/10 Sign + verify candidate"
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
for _ in $(seq 1 12); do
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

osascript -e 'tell application id "com.nicolasalonso.SUPRA" to quit' >/dev/null 2>&1 || true
sleep 1
pkill -x SUPRA >/dev/null 2>&1 || true
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

say "9/10 Launch + prove"
open "$TARGET"
PID=""
PIDS=""
RUNNING_COUNT=0
for _ in $(seq 1 30); do
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
printf 'PID=%s\nCMD=%s\nSUPRA_INSTANCE_COUNT=%s\n' "$PID" "$CMD" "$RUNNING_COUNT"
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
printf 'AUTOUPDATE_SELF_REFRESH=PASS\n'
