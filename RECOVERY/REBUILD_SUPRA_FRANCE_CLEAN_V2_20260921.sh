#!/bin/bash
set -euo pipefail

SOURCE_COMMIT="75f29865941a6d4d224c20040ae129db4b01ceee"
REPO_TARBALL="https://codeload.github.com/Nicolason84/-SUPRA/tar.gz/${SOURCE_COMMIT}"
STAMP="$(date '+%Y%m%d_%H%M%S')"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/SUPRA_FRANCE_CLEAN.XXXXXX")"
LOG="$HOME/Library/Logs/SUPRA_FRANCE_CLEAN_REBUILD_${STAMP}.log"
DEST_DIR="$HOME/Applications"
DEST="$DEST_DIR/SUPRA-FRANCE-CLEAN.app"
RETIRED="$HOME/Library/Application Support/SUPRA_RETIRED/${STAMP}"

exec > >(tee "$LOG") 2>&1
trap 'rm -rf "$TMP"' EXIT

say(){ printf '\n[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }
die(){ say "FAIL: $1"; exit "${2:-1}"; }

say "SUPRA FRANCE — CLEAN REBUILD V2"
say "Source gelé: $SOURCE_COMMIT"

say "1/8 Fermeture des anciennes instances"
osascript -e 'tell application "SUPRA" to quit' >/dev/null 2>&1 || true
sleep 2
pkill -x SUPRA >/dev/null 2>&1 || true
sleep 1

say "2/8 Retrait des anciennes versions locales"
mkdir -p "$DEST_DIR" "$RETIRED"
for APP in   "$HOME/Applications/SUPRA.app"   "$HOME/Applications/SUPRA-FRANCE.app"   "$HOME/Applications/SUPRA-FRANCE-CLEAN.app"
do
  if [ -e "$APP" ]; then
    BASENAME="$(basename "$APP")"
    mv "$APP" "$RETIRED/$BASENAME"
    say "Retiré: $APP"
  fi
done

if [ -d "/Applications/SUPRA.app" ] || [ -d "/Applications/SUPRA-FRANCE.app" ]; then
  say "INFO: une ancienne copie système existe dans /Applications; elle ne sera pas lancée."
fi

say "3/8 Vérification Xcode/macOS SDK"
command -v xcodebuild >/dev/null || die "Xcode/xcodebuild introuvable" 20
SDK="$(xcrun --sdk macosx --show-sdk-version 2>/dev/null || true)"
say "SDK macOS: ${SDK:-UNKNOWN}"
[ -n "$SDK" ] || die "SDK macOS introuvable" 21

say "4/8 Téléchargement du source exact"
TARBALL="$TMP/source.tgz"
curl -fL --retry 3 --connect-timeout 20 "$REPO_TARBALL" -o "$TARBALL" || die "Téléchargement source impossible" 30
tar -xzf "$TARBALL" -C "$TMP"
SRCROOT="$(find "$TMP" -maxdepth 1 -type d -name '*SUPRA-*' | head -1)"
[ -n "$SRCROOT" ] && [ -d "$SRCROOT" ] || die "Source extraite introuvable" 31

say "5/8 Preuve de source France V1"
test -f "$SRCROOT/SUPRA/FranceOrganismNativeView.swift" || die "FranceOrganismNativeView absent" 40
grep -Fq 'SUPRA × ojO · FRANCE V1' "$SRCROOT/SUPRA/SUPRAOJOHomeView.swift" || die "Marqueur FRANCE V1 absent" 41
grep -Fq '@State private var selection: SUPRAOJORoute? = .france' "$SRCROOT/SUPRA/SUPRAOJOHomeView.swift" || die "France non définie comme accueil" 42
grep -Fq 'FranceOrganismNativeView()' "$SRCROOT/SUPRA/SUPRAOJOHomeView.swift" || die "Route France absente" 43

say "6/8 Compilation Release locale"
DERIVED="$TMP/DerivedData"
(
  cd "$SRCROOT"
  set -o pipefail
  xcodebuild     -project SUPRA.xcodeproj     -scheme SUPRA     -configuration Release     -sdk macosx     -derivedDataPath "$DERIVED"     CODE_SIGNING_ALLOWED=NO     CODE_SIGNING_REQUIRED=NO     build
) || die "BUILD FAILED — voir $LOG" 50

BUILT="$DERIVED/Build/Products/Release/SUPRA.app"
[ -d "$BUILT" ] || die "SUPRA.app non produite" 51

say "7/8 Signature et installation locale"
/usr/bin/codesign --force --deep --sign - --timestamp=none "$BUILT"
/usr/bin/codesign --verify --deep --strict --verbose=2 "$BUILT" || die "Signature build invalide" 60
/usr/bin/ditto "$BUILT" "$DEST"
/usr/bin/xattr -dr com.apple.quarantine "$DEST" 2>/dev/null || true
/usr/bin/codesign --verify --deep --strict --verbose=2 "$DEST" || die "Signature installée invalide" 61

say "8/8 Lancement exact"
open -n "$DEST"
sleep 5
PID="$(pgrep -nx SUPRA || true)"
[ -n "$PID" ] || die "Processus SUPRA non lancé" 70
CMD="$(ps -p "$PID" -o command= || true)"
say "PID=$PID"
say "COMMAND=$CMD"

case "$CMD" in
  "$DEST"/Contents/MacOS/SUPRA*) ;;
  *) die "Une autre copie SUPRA a été lancée: $CMD" 71 ;;
esac

say "PASS — SUPRA FRANCE V1 reconstruite localement"
say "APP=$DEST"
say "ANCIENNES_VERSIONS=$RETIRED"
say "LOG=$LOG"
/usr/bin/open -R "$DEST" >/dev/null 2>&1 || true
