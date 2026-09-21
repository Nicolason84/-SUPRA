#!/bin/bash
set -euo pipefail

SOURCE_COMMIT="84e6fcb3feb28e5051e91aeddfd01ff56f87e2ca"
REPO_TARBALL="https://codeload.github.com/Nicolason84/-SUPRA/tar.gz/${SOURCE_COMMIT}"
STAMP="$(date '+%Y%m%d_%H%M%S')"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/SUPRA_CHAT_MEMORY.XXXXXX")"
LOG="$HOME/Library/Logs/SUPRA_CHAT_MEMORY_V1_${STAMP}.log"
DEST="$HOME/Applications/SUPRA-FRANCE-CLEAN.app"
RETIRED="$HOME/Library/Application Support/SUPRA_RETIRED/${STAMP}"

MEM_DB="$HOME/NOVA_OS/_CANNONICO_MEMORY_CORE_V1/cannonico_memory_core_v1.sqlite"
MEM_INDEX="$HOME/Desktop/SUPRA_MEMORY_LIVE/_SUPRA_MEMORY_INDEX/supra_memory_index.jsonl"

exec > >(tee "$LOG") 2>&1
trap 'rm -rf "$TMP"' EXIT

say(){ printf '\n[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }
die(){ say "FAIL: $1"; exit "${2:-1}"; }

say "SUPRA × ojO — CHAT MEMORY V1"

say "1/9 Fermeture de l’app actuelle"
osascript -e 'tell application "SUPRA" to quit' >/dev/null 2>&1 || true
sleep 2
pkill -x SUPRA >/dev/null 2>&1 || true

say "2/9 Rollback local"
mkdir -p "$HOME/Applications" "$RETIRED"
if [ -e "$DEST" ]; then
  mv "$DEST" "$RETIRED/SUPRA-FRANCE-CLEAN.app"
fi

say "3/9 Vérification mémoire patrimoniale"
MEMORY_SOURCE="CONVERSATION_ONLY"
if [ -f "$MEM_DB" ]; then
  MEMORY_SOURCE="CANNONICO_FTS5"
elif [ -f "$MEM_INDEX" ]; then
  MEMORY_SOURCE="SUPRA_MEMORY_INDEX"
fi
say "MEMORY_SOURCE=$MEMORY_SOURCE"

say "4/9 Source exacte"
TARBALL="$TMP/source.tgz"
curl -fL --retry 3 --connect-timeout 20 "$REPO_TARBALL" -o "$TARBALL" || die "Téléchargement source impossible" 30
tar -xzf "$TARBALL" -C "$TMP"
SRCROOT="$(find "$TMP" -maxdepth 1 -type d -name '*SUPRA-*' | head -1)"
[ -n "$SRCROOT" ] && [ -d "$SRCROOT" ] || die "Source introuvable" 31

say "5/9 Invariants mémoire"
grep -Fq 'SUPRA_CHAT_ARCHIVE_V1' "$SRCROOT/SUPRA/SUPRAChatMemory.swift" || die "Archive persistante absente" 40
grep -Fq 'SUPRA_CHAT_MEMORY_CONTEXT_V1' "$SRCROOT/SUPRA/SUPRAChatView.swift" || die "Injection mémoire absente" 41
grep -Fq 'CANNONICO_FTS5' "$SRCROOT/SUPRA/SUPRAChatMemory.swift" || die "CAnnoNico FTS absent" 42
grep -Fq 'SUPRA_MEMORY_INDEX' "$SRCROOT/SUPRA/SUPRAChatMemory.swift" || die "Fallback mémoire absent" 43

say "6/9 Dépendances"
(
  cd "$SRCROOT"
  for ATTEMPT in 1 2 3; do
    xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -resolvePackageDependencies && exit 0
    [ "$ATTEMPT" = "3" ] && exit 49
    sleep 3
  done
) || die "Dépendances non résolues" 49

say "7/9 Build Release local"
DERIVED="$TMP/DerivedData"
(
  cd "$SRCROOT"
  set -o pipefail
  xcodebuild     -project SUPRA.xcodeproj     -scheme SUPRA     -configuration Release     -sdk macosx     -derivedDataPath "$DERIVED"     CODE_SIGNING_ALLOWED=NO     CODE_SIGNING_REQUIRED=NO     build
) || die "BUILD FAILED — $LOG" 50

BUILT="$DERIVED/Build/Products/Release/SUPRA.app"
[ -d "$BUILT" ] || die "App non produite" 51

say "8/9 Signature + installation"
/usr/bin/codesign --force --deep --sign - --timestamp=none "$BUILT"
/usr/bin/codesign --verify --deep --strict --verbose=2 "$BUILT"
/usr/bin/ditto "$BUILT" "$DEST"
/usr/bin/xattr -dr com.apple.quarantine "$DEST" 2>/dev/null || true
/usr/bin/codesign --verify --deep --strict --verbose=2 "$DEST"

say "9/9 Runtime + lancement"
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

CHAT_ARCHIVE="$HOME/Library/Application Support/SUPRA/ChatMemory/current-thread-v1.json"

say "PASS — CHAT MEMORY V1"
say "APP=$DEST"
say "MEMORY_SOURCE=$MEMORY_SOURCE"
say "CHAT_ARCHIVE=$CHAT_ARCHIVE"
say "ROLLBACK=$RETIRED"
say "LOG=$LOG"
