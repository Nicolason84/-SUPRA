#!/bin/bash
set -euo pipefail

SOURCE_COMMIT="1ba76a4f99240a75572661def6bdac1a24e6da46"
REPO_TARBALL="https://codeload.github.com/Nicolason84/-SUPRA/tar.gz/${SOURCE_COMMIT}"
STAMP="$(date '+%Y%m%d_%H%M%S')"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/SUPRA_OJO_FUSION.XXXXXX")"
LOG="$HOME/Library/Logs/SUPRA_OJO_FUSION_V1_${STAMP}.log"
DEST="$HOME/Applications/SUPRA-FRANCE-CLEAN.app"
RETIRED="$HOME/Library/Application Support/SUPRA_RETIRED/${STAMP}"

exec > >(tee "$LOG") 2>&1
trap 'rm -rf "$TMP"' EXIT

say(){ printf '\n[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }
die(){ say "FAIL: $1"; exit "${2:-1}"; }

say "SUPRA × ojO — FUSION V1"

say "1/8 Fermeture app actuelle"
osascript -e 'tell application "SUPRA" to quit' >/dev/null 2>&1 || true
sleep 2
pkill -x SUPRA >/dev/null 2>&1 || true

say "2/8 Rollback local"
mkdir -p "$HOME/Applications" "$RETIRED"
if [ -e "$DEST" ]; then
  mv "$DEST" "$RETIRED/SUPRA-FRANCE-CLEAN.app"
fi

say "3/8 Source exacte"
TARBALL="$TMP/source.tgz"
curl -fL --retry 3 --connect-timeout 20 "$REPO_TARBALL" -o "$TARBALL" || die "Téléchargement source impossible" 30
tar -xzf "$TARBALL" -C "$TMP"
SRCROOT="$(find "$TMP" -maxdepth 1 -type d -name '*SUPRA-*' | head -1)"
[ -n "$SRCROOT" ] && [ -d "$SRCROOT" ] || die "Source introuvable" 31

say "4/8 Invariants fusion"
grep -Fq 'OJOWorkspaceView()' "$SRCROOT/SUPRA/SUPRAOJOHomeView.swift" || die "ojO Workspace absent" 40
grep -Fq 'DecisionInboxView()' "$SRCROOT/SUPRA/OJOWorkspaceView.swift" || die "Décisions non fusionnées" 41
grep -Fq 'MissionCenterView()' "$SRCROOT/SUPRA/OJOWorkspaceView.swift" || die "Missions non fusionnées" 42
grep -Fq 'SUPRAProcessObservatoryView()' "$SRCROOT/SUPRA/OJOWorkspaceView.swift" || die "Preuves non fusionnées" 43
grep -Fq 'OJOOrganismNativeView()' "$SRCROOT/SUPRA/OJOWorkspaceView.swift" || die "Vivant absent" 44
if grep -Fq 'case supra' "$SRCROOT/SUPRA/SUPRAOJOHomeView.swift"; then
  die "Ancien onglet SUPRA encore exposé" 45
fi

say "5/8 Dépendances"
(
  cd "$SRCROOT"
  for ATTEMPT in 1 2 3; do
    xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -resolvePackageDependencies && exit 0
    [ "$ATTEMPT" = "3" ] && exit 49
    sleep 3
  done
) || die "Dépendances non résolues" 49

say "6/8 Build Release"
DERIVED="$TMP/DerivedData"
(
  cd "$SRCROOT"
  set -o pipefail
  xcodebuild     -project SUPRA.xcodeproj     -scheme SUPRA     -configuration Release     -sdk macosx     -derivedDataPath "$DERIVED"     CODE_SIGNING_ALLOWED=NO     CODE_SIGNING_REQUIRED=NO     build
) || die "BUILD FAILED — $LOG" 50

BUILT="$DERIVED/Build/Products/Release/SUPRA.app"
[ -d "$BUILT" ] || die "App non produite" 51

say "7/8 Signature + installation"
/usr/bin/codesign --force --deep --sign - --timestamp=none "$BUILT"
/usr/bin/codesign --verify --deep --strict --verbose=2 "$BUILT"
/usr/bin/ditto "$BUILT" "$DEST"
/usr/bin/xattr -dr com.apple.quarantine "$DEST" 2>/dev/null || true
/usr/bin/codesign --verify --deep --strict --verbose=2 "$DEST"

say "8/8 Runtime + lancement"
LABEL="com.novaera.sol-github-bridge"
if [ -f "$HOME/Library/LaunchAgents/${LABEL}.plist" ]; then
  /bin/launchctl kickstart -k "gui/$(id -u)/$LABEL" >/dev/null 2>&1 || true
  sleep 2
fi

open -n "$DEST"
sleep 5
PID="$(pgrep -nx SUPRA || true)"
[ -n "$PID" ] || die "SUPRA non lancé" 70
CMD="$(ps -p "$PID" -o command= || true)"
case "$CMD" in
  "$DEST"/Contents/MacOS/SUPRA*) ;;
  *) die "Mauvaise copie lancée: $CMD" 71 ;;
esac

say "PASS — OJO FUSION V1"
say "APP=$DEST"
say "ROLLBACK=$RETIRED"
say "LOG=$LOG"
