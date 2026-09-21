#!/bin/bash
set -euo pipefail

SOURCE_COMMIT="ce3faaf923580c1514ddeb63b879a12b148dc0d1"
REPO_TARBALL="https://codeload.github.com/Nicolason84/-SUPRA/tar.gz/${SOURCE_COMMIT}"
STAMP="$(date '+%Y%m%d_%H%M%S')"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/SUPRA_PANDORA_PREFLIGHT.XXXXXX")"
LOG="$HOME/Library/Logs/SUPRA_PANDORA_PREFLIGHT_V1_${STAMP}.log"
DEST="$HOME/Applications/SUPRA-FRANCE-CLEAN.app"
RETIRED="$HOME/Library/Application Support/SUPRA_RETIRED/${STAMP}"

exec > >(tee "$LOG") 2>&1
trap 'rm -rf "$TMP"' EXIT

say(){ printf '\n[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }
die(){ say "FAIL: $1"; exit "${2:-1}"; }

say "SUPRA × ojO — PANDORA PREFLIGHT V1"

say "1/10 Fermeture app actuelle"
osascript -e 'tell application "SUPRA" to quit' >/dev/null 2>&1 || true
sleep 2
pkill -x SUPRA >/dev/null 2>&1 || true

say "2/10 Rollback"
mkdir -p "$HOME/Applications" "$RETIRED"
if [ -e "$DEST" ]; then
  mv "$DEST" "$RETIRED/SUPRA-FRANCE-CLEAN.app"
fi

say "3/10 Source"
TARBALL="$TMP/source.tgz"
curl -fL --retry 3 --connect-timeout 20 "$REPO_TARBALL" -o "$TARBALL" || die "Téléchargement source impossible" 30
tar -xzf "$TARBALL" -C "$TMP"
SRCROOT="$(find "$TMP" -maxdepth 1 -type d -name '*SUPRA-*' | head -1)"
[ -n "$SRCROOT" ] && [ -d "$SRCROOT" ] || die "Source introuvable" 31

say "4/10 Invariants pré-vol"
grep -Fq 'SUPRAGabrielConductorRuntime.load()' "$SRCROOT/SUPRA/MissionStore.swift" || die "Mission Center non relié à Gabriel" 40
grep -Fq 'DECISION_BOARD_AUTHORITY_FINAL.json' "$SRCROOT/SUPRA/DecisionStore.swift" || die "Decision Inbox non relié aux boards" 41
grep -Fq 'Liveness contract' "$SRCROOT/SUPRA/SUPRAChatRuntimeAdapter.swift" || die "Health Chat ancien contrat" 42
grep -Fq 'OJOWorkspaceView()' "$SRCROOT/SUPRA/SUPRAOJOHomeView.swift" || die "ojO fusion absent" 43

say "5/10 Dépendances"
(
  cd "$SRCROOT"
  for ATTEMPT in 1 2 3; do
    xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -resolvePackageDependencies && exit 0
    [ "$ATTEMPT" = "3" ] && exit 49
    sleep 3
  done
) || die "Dépendances non résolues" 49

say "6/10 Build Release"
DERIVED="$TMP/DerivedData"
(
  cd "$SRCROOT"
  set -o pipefail
  xcodebuild     -project SUPRA.xcodeproj     -scheme SUPRA     -configuration Release     -sdk macosx     -derivedDataPath "$DERIVED"     CODE_SIGNING_ALLOWED=NO     CODE_SIGNING_REQUIRED=NO     build
) || die "BUILD FAILED — $LOG" 50

BUILT="$DERIVED/Build/Products/Release/SUPRA.app"
[ -d "$BUILT" ] || die "App non produite" 51

say "7/10 Signature + installation"
/usr/bin/codesign --force --deep --sign - --timestamp=none "$BUILT"
/usr/bin/codesign --verify --deep --strict --verbose=2 "$BUILT"
/usr/bin/ditto "$BUILT" "$DEST"
/usr/bin/xattr -dr com.apple.quarantine "$DEST" 2>/dev/null || true
/usr/bin/codesign --verify --deep --strict --verbose=2 "$DEST"

say "8/10 Réveil des composants existants"
LABEL="com.novaera.sol-github-bridge"
if [ -f "$HOME/Library/LaunchAgents/${LABEL}.plist" ]; then
  /bin/launchctl kickstart -k "gui/$(id -u)/$LABEL" >/dev/null 2>&1 || true
fi

BRIDGE_ROOT="$HOME/NOVA_OS/SUPRA_CHATGPT_APP_BRIDGE_V1"
BRIDGE_SH="$BRIDGE_ROOT/bridge.sh"
if ! lsof -nP -iTCP:18765 -sTCP:LISTEN >/dev/null 2>&1; then
  if [ -f "$BRIDGE_SH" ]; then
    nohup /bin/bash "$BRIDGE_SH" watch >/tmp/supra_bridge_runtime_health.log 2>&1 </dev/null &
  fi
fi

for _ in $(seq 1 15); do
  lsof -nP -iTCP:18765 -sTCP:LISTEN >/dev/null 2>&1 && break
  sleep 1
done

say "9/10 Lancement exact"
open -n "$DEST"
sleep 5
PID="$(pgrep -nx SUPRA || true)"
[ -n "$PID" ] || die "SUPRA non lancé" 70
CMD="$(ps -p "$PID" -o command= || true)"
case "$CMD" in
  "$DEST"/Contents/MacOS/SUPRA*) ;;
  *) die "Mauvaise copie lancée: $CMD" 71 ;;
esac

say "10/10 Checks avionique locale"
CHAT="NO"
if curl -fsS --max-time 4 http://127.0.0.1:18765/v1/health >/dev/null 2>&1; then
  CHAT="YES"
fi

GABRIEL="$HOME/NOVA_OS/GABRIEL_PARALLEL_MISSION_CONDUCTOR_V1/CURRENT/OUTPUTS/GABRIEL_CONSOLIDATION.json"
GABRIEL_STATE="ABSENT"
if [ -s "$GABRIEL" ]; then
  if /usr/bin/python3 -m json.tool "$GABRIEL" >/dev/null 2>&1; then
    GABRIEL_STATE="READY"
  else
    GABRIEL_STATE="MALFORMED"
  fi
fi

BOARDS=0
for B in   "$HOME/NOVA_OS/SUPRA_READ_RECONCILED_VERDICT_AND_REPUBLISH_ARCHITECTURE_DECISION_BOARD_V1/CURRENT/DECISION_BOARD.json"   "$HOME/NOVA_OS/SUPRA_RESOLVE_AUTHORITY_FIELD_LINEAGE_AND_CLOSE_SINGLE_HUMAN_GATE_V1/CURRENT/DECISION_BOARD_AUTHORITY_FINAL.json"   "$HOME/NOVA_OS/SUPRA_EXECUTE_APPROVED_DERIVED_DATA_BATCH_AND_BUILD_REVIEW_BOARD_FOR_26_70_GB_V1/CURRENT/STORAGE_DECISION_BOARD_AFTER_DERIVED_DATA.json"
do
  [ -s "$B" ] && BOARDS=$((BOARDS+1))
done

say "PANDORA_PREFLIGHT_RESULT"
printf 'APP=PASS\n'
printf 'CHAT_BRIDGE=%s\n' "$CHAT"
printf 'GABRIEL=%s\n' "$GABRIEL_STATE"
printf 'DECISION_BOARDS=%s/3\n' "$BOARDS"
printf 'MISSION_PROVIDER=GABRIEL\n'
printf 'DECISION_PROVIDER=LOCAL_BOARDS\n'
printf 'SOURCE_COMMIT=%s\n' "$SOURCE_COMMIT"
printf 'ROLLBACK=%s\n' "$RETIRED"
printf 'LOG=%s\n' "$LOG"

if [ "$CHAT" = "YES" ] && [ "$GABRIEL_STATE" = "READY" ] && [ "$BOARDS" -ge 1 ]; then
  say "STATUS=GO_CONTROLLED"
else
  say "STATUS=NO_GO_BOUNDED"
fi
