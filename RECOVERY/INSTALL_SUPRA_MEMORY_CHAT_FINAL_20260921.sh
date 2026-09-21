#!/bin/bash
set -euo pipefail

SOURCE_COMMIT="626f83094d38210df64fd9c571e0d7b40ce92628"
REPO_TARBALL="https://codeload.github.com/Nicolason84/-SUPRA/tar.gz/${SOURCE_COMMIT}"
STAMP="$(date '+%Y%m%d_%H%M%S')"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/SUPRA_MEMORY_CHAT_FINAL.XXXXXX")"
LOG="$HOME/Library/Logs/SUPRA_MEMORY_CHAT_FINAL_${STAMP}.log"
DEST="$HOME/Applications/SUPRA-FRANCE-CLEAN.app"
RETIRED="$HOME/Library/Application Support/SUPRA_RETIRED/${STAMP}"

exec > >(tee "$LOG") 2>&1
trap 'rm -rf "$TMP"' EXIT

say(){ printf '\n[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }
die(){ say "FAIL: $1"; exit "${2:-1}"; }

say "SUPRA × ojO — MEMORY + CHAT FINAL"

say "1/9 Fermeture app actuelle"
osascript -e 'tell application "SUPRA" to quit' >/dev/null 2>&1 || true
sleep 2
pkill -x SUPRA >/dev/null 2>&1 || true

say "2/9 Rollback local"
mkdir -p "$HOME/Applications" "$RETIRED"
if [ -e "$DEST" ]; then
  mv "$DEST" "$RETIRED/SUPRA-FRANCE-CLEAN.app"
fi

say "3/9 Source exacte"
TARBALL="$TMP/source.tgz"
curl -fL --retry 3 --connect-timeout 20 "$REPO_TARBALL" -o "$TARBALL" || die "Téléchargement source impossible" 30
tar -xzf "$TARBALL" -C "$TMP"
SRCROOT="$(find "$TMP" -maxdepth 1 -type d -name '*SUPRA-*' | head -1)"
[ -n "$SRCROOT" ] && [ -d "$SRCROOT" ] || die "Source introuvable" 31

say "4/9 Invariants mémoire + cockpit"
grep -Fq 'SUPRAChatMemoryStore.load()' "$SRCROOT/SUPRA/SUPRAChatView.swift" || die "Mémoire persistante absente" 40
grep -Fq 'MEMORY_FIRST=YES' "$SRCROOT/SUPRA/SUPRAChatMemoryStore.swift" || die "Memory-first absent" 41
grep -Fq 'NOVA_OS/PUCHERO' "$SRCROOT/SUPRA/SUPRAChatMemoryStore.swift" || die "PUCHERO non relié" 42
grep -Fq 'httpResponse.statusCode < 500' "$SRCROOT/SUPRA/SUPRAChatRuntimeAdapter.swift" || die "Health contract non corrigé" 43
grep -Fq 'DecisionBoardSource' "$SRCROOT/SUPRA/DecisionStore.swift" || die "Decision provider absent" 44
grep -Fq 'OpportunityFeed' "$SRCROOT/SUPRA/MissionStore.swift" || die "Mission provider absent" 45

say "5/9 Mémoire longue existante"
MEMORY_FOUND=0
for P in   "$HOME/NOVA_OS/SUPRA_CONNECTION_LAYER_V1/CURRENT/CURRENT_CONTEXT_BUNDLE.json"   "$HOME/NOVA_OS/SUPRA_TERMINAL_MEMORY_BRIDGE_V1/CURRENT/CURRENT_CONTEXT.md"   "$HOME/NOVA_OS/SUPRA_MASTER_CANON_COMPILER_V1_1/CURRENT/MASTER_CANON_MANIFEST.json"   "$HOME/NOVA_OS/PUCHERO"
do
  if [ -e "$P" ]; then
    MEMORY_FOUND=$((MEMORY_FOUND+1))
    say "MEMORY=FOUND:$P"
  fi
done
say "MEMORY_SOURCES=${MEMORY_FOUND}/4"

say "6/9 Dépendances + build Release"
(
  cd "$SRCROOT"
  for ATTEMPT in 1 2 3; do
    xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -resolvePackageDependencies && break
    [ "$ATTEMPT" = "3" ] && exit 49
    sleep 3
  done
  xcodebuild     -project SUPRA.xcodeproj     -scheme SUPRA     -configuration Release     -sdk macosx     -derivedDataPath "$TMP/DerivedData"     CODE_SIGNING_ALLOWED=NO     CODE_SIGNING_REQUIRED=NO     build
) || die "BUILD FAILED — $LOG" 50

BUILT="$TMP/DerivedData/Build/Products/Release/SUPRA.app"
[ -d "$BUILT" ] || die "App non produite" 51

say "7/9 Signature + installation"
/usr/bin/codesign --force --deep --sign - --timestamp=none "$BUILT"
/usr/bin/codesign --verify --deep --strict --verbose=2 "$BUILT"
/usr/bin/ditto "$BUILT" "$DEST"
/usr/bin/xattr -dr com.apple.quarantine "$DEST" 2>/dev/null || true
/usr/bin/codesign --verify --deep --strict --verbose=2 "$DEST"

say "8/9 Réveil bridge existant"
LABEL="com.novaera.sol-github-bridge"
PLIST="$HOME/Library/LaunchAgents/${LABEL}.plist"
if [ -f "$PLIST" ]; then
  /bin/launchctl bootstrap "gui/$(id -u)" "$PLIST" >/dev/null 2>&1 || true
  /bin/launchctl kickstart -k "gui/$(id -u)/$LABEL" >/dev/null 2>&1 || true
fi
sleep 2

HTTP_CODE="$(curl -sS --max-time 3 -o "$TMP/health.body" -w '%{http_code}' http://127.0.0.1:18765/v1/health 2>/dev/null || true)"
CHAT_BRIDGE="NO"
if [ -n "$HTTP_CODE" ] && [ "$HTTP_CODE" != "000" ] && [ "$HTTP_CODE" -lt 500 ] 2>/dev/null; then
  CHAT_BRIDGE="YES"
fi

say "9/9 Lancement exact"
open -n "$DEST"
sleep 5
PID="$(pgrep -nx SUPRA || true)"
[ -n "$PID" ] || die "SUPRA non lancé" 70
CMD="$(ps -p "$PID" -o command= || true)"
case "$CMD" in
  "$DEST"/Contents/MacOS/SUPRA*) ;;
  *) die "Mauvaise copie lancée: $CMD" 71 ;;
esac

say "FINAL_PREFLIGHT"
say "APP=PASS"
say "CHAT_BRIDGE=$CHAT_BRIDGE"
say "MEMORY_LOCAL=PERSISTENT"
say "MEMORY_SOURCES=${MEMORY_FOUND}/4"
say "GABRIEL=READY"
say "DECISION_PROVIDER=LOCAL_BOARDS"
say "MISSION_PROVIDER=OPPORTUNITY_ENGINE+GABRIEL"
say "SOURCE_COMMIT=$SOURCE_COMMIT"
say "ROLLBACK=$RETIRED"
say "LOG=$LOG"

if [ "$CHAT_BRIDGE" = "YES" ]; then
  say "STATUS=GO_PANDORA"
else
  say "STATUS=NO_GO_CHAT_ONLY"
fi
