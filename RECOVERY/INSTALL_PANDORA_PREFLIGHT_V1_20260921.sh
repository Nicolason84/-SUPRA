#!/bin/bash
set -euo pipefail

SOURCE_COMMIT="dcf6cdf66cd886b803edc8e60014363f804f0f59"
REPO_TARBALL="https://codeload.github.com/Nicolason84/-SUPRA/tar.gz/${SOURCE_COMMIT}"
STAMP="$(date '+%Y%m%d_%H%M%S')"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/SUPRA_PANDORA_PREFLIGHT.XXXXXX")"
LOG="$HOME/Library/Logs/SUPRA_PANDORA_PREFLIGHT_${STAMP}.log"
DEST="$HOME/Applications/SUPRA-FRANCE-CLEAN.app"
RETIRED="$HOME/Library/Application Support/SUPRA_RETIRED/${STAMP}"

exec > >(tee "$LOG") 2>&1
trap 'rm -rf "$TMP"' EXIT

say(){ printf '\n[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }
die(){ say "FAIL: $1"; exit "${2:-1}"; }

say "SUPRA × ojO — PANDORA PREFLIGHT V1"

say "1/9 Close current app"
osascript -e 'tell application "SUPRA" to quit' >/dev/null 2>&1 || true
sleep 2
pkill -x SUPRA >/dev/null 2>&1 || true

say "2/9 Rollback"
mkdir -p "$HOME/Applications" "$RETIRED"
if [ -e "$DEST" ]; then
  mv "$DEST" "$RETIRED/SUPRA-FRANCE-CLEAN.app"
fi

say "3/9 Fetch exact source"
TARBALL="$TMP/source.tgz"
curl -fL --retry 3 --connect-timeout 20 "$REPO_TARBALL" -o "$TARBALL" || die "SOURCE_DOWNLOAD_FAILED" 30
tar -xzf "$TARBALL" -C "$TMP"
SRCROOT="$(find "$TMP" -maxdepth 1 -type d -name '*SUPRA-*' | head -1)"
[ -n "$SRCROOT" ] && [ -d "$SRCROOT" ] || die "SOURCE_NOT_FOUND" 31

say "4/9 Preflight source invariants"
grep -Fq 'OJOWorkspaceView()' "$SRCROOT/SUPRA/SUPRAOJOHomeView.swift" || die "OJO_WORKSPACE_MISSING" 40
grep -Fq 'SUPRAGabrielConductorRuntime.load()' "$SRCROOT/SUPRA/MissionStore.swift" || die "GABRIEL_BINDING_MISSING" 41
grep -Fq 'DECISION_BOARD_AUTHORITY_FINAL.json' "$SRCROOT/SUPRA/DecisionStore.swift" || die "DECISION_BINDING_MISSING" 42
grep -Fq 'Liveness contract' "$SRCROOT/SUPRA/SUPRAChatRuntimeAdapter.swift" || die "CHAT_HEALTH_FIX_MISSING" 43
grep -Fq '10M+ VALUE-AT-STAKE' "$SRCROOT/docs/PANDORA_MISSION_DOCTRINE_V1.md" || die "PANDORA_DOCTRINE_MISSING" 44

say "5/9 Resolve packages"
(
  cd "$SRCROOT"
  for ATTEMPT in 1 2 3; do
    xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -resolvePackageDependencies && exit 0
    [ "$ATTEMPT" = "3" ] && exit 49
    sleep 3
  done
) || die "PACKAGE_RESOLUTION_FAILED" 49

say "6/9 Build Release"
DERIVED="$TMP/DerivedData"
(
  cd "$SRCROOT"
  set -o pipefail
  xcodebuild     -project SUPRA.xcodeproj     -scheme SUPRA     -configuration Release     -sdk macosx     -derivedDataPath "$DERIVED"     CODE_SIGNING_ALLOWED=NO     CODE_SIGNING_REQUIRED=NO     build
) || die "BUILD_FAILED:$LOG" 50

BUILT="$DERIVED/Build/Products/Release/SUPRA.app"
[ -d "$BUILT" ] || die "APP_NOT_PRODUCED" 51

say "7/9 Sign and install"
/usr/bin/codesign --force --deep --sign - --timestamp=none "$BUILT"
/usr/bin/codesign --verify --deep --strict --verbose=2 "$BUILT" || die "BUILT_CODESIGN_FAILED" 60
/usr/bin/ditto "$BUILT" "$DEST"
/usr/bin/xattr -dr com.apple.quarantine "$DEST" 2>/dev/null || true
/usr/bin/codesign --verify --deep --strict --verbose=2 "$DEST" || die "INSTALLED_CODESIGN_FAILED" 61

say "8/9 Wake existing local bridge"
LABEL="com.novaera.sol-github-bridge"
PLIST="$HOME/Library/LaunchAgents/${LABEL}.plist"
if [ -f "$PLIST" ]; then
  /bin/launchctl kickstart -k "gui/$(id -u)/$LABEL" >/dev/null 2>&1 || true
fi
sleep 2

say "9/9 Launch and material preflight"
open -n "$DEST"
sleep 5
PID="$(pgrep -nx SUPRA || true)"
[ -n "$PID" ] || die "APP_LAUNCH_FAILED" 70
CMD="$(ps -p "$PID" -o command= || true)"
case "$CMD" in
  "$DEST"/Contents/MacOS/SUPRA*) ;;
  *) die "WRONG_APP_LAUNCHED:$CMD" 71 ;;
esac

CHAT="UNAVAILABLE"
if curl -fsS --max-time 4 http://127.0.0.1:18765/v1/health >/dev/null 2>&1; then
  CHAT="REACHABLE"
fi

GABRIEL_PATH="$HOME/NOVA_OS/GABRIEL_PARALLEL_MISSION_CONDUCTOR_V1/CURRENT/OUTPUTS/GABRIEL_CONSOLIDATION.json"
GABRIEL="NOT_MATERIALIZED"
if [ -s "$GABRIEL_PATH" ]; then
  GABRIEL="MATERIALIZED"
fi

BOARDS=0
for BOARD in  "$HOME/NOVA_OS/SUPRA_READ_RECONCILED_VERDICT_AND_REPUBLISH_ARCHITECTURE_DECISION_BOARD_V1/CURRENT/DECISION_BOARD.json"  "$HOME/NOVA_OS/SUPRA_RESOLVE_AUTHORITY_FIELD_LINEAGE_AND_CLOSE_SINGLE_HUMAN_GATE_V1/CURRENT/DECISION_BOARD_AUTHORITY_FINAL.json"  "$HOME/NOVA_OS/SUPRA_EXECUTE_APPROVED_DERIVED_DATA_BATCH_AND_BUILD_REVIEW_BOARD_FOR_26_70_GB_V1/CURRENT/STORAGE_DECISION_BOARD_AFTER_DERIVED_DATA.json"
do
  [ -s "$BOARD" ] && BOARDS=$((BOARDS+1))
done

TAKEOFF="HOLD"
if [ "$CHAT" = "REACHABLE" ] && [ "$BOARDS" -ge 1 ]; then
  TAKEOFF="GO_FOR_CONTROLLED_MISSIONS"
fi

say "PREFLIGHT_RESULT"
printf 'APP=PASS\n'
printf 'CHAT_BRIDGE=%s\n' "$CHAT"
printf 'GABRIEL=%s\n' "$GABRIEL"
printf 'DECISION_BOARDS=%s/3\n' "$BOARDS"
printf 'TAKEOFF=%s\n' "$TAKEOFF"
printf 'ROLLBACK=%s\n' "$RETIRED"
printf 'LOG=%s\n' "$LOG"
