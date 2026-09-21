#!/bin/bash
set -euo pipefail

SOURCE_COMMIT="941dd8cf7f27930604bc7abd70e78c2740443177"
REPO_TARBALL="https://codeload.github.com/Nicolason84/-SUPRA/tar.gz/${SOURCE_COMMIT}"
STAMP="$(date '+%Y%m%d_%H%M%S')"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/SUPRA_POLISH_V1.XXXXXX")"
LOG="$HOME/Library/Logs/SUPRA_PRODUCT_POLISH_V1_${STAMP}.log"
DEST_DIR="$HOME/Applications"
DEST="$DEST_DIR/SUPRA-FRANCE-CLEAN.app"
RETIRED="$HOME/Library/Application Support/SUPRA_RETIRED/${STAMP}"

exec > >(tee "$LOG") 2>&1
trap 'rm -rf "$TMP"' EXIT

say(){ printf '\n[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }
die(){ say "FAIL: $1"; exit "${2:-1}"; }

say "SUPRA × ojO — PRODUCT POLISH V1"
say "Source: $SOURCE_COMMIT"

say "1/9 Fermeture de la copie actuelle"
osascript -e 'tell application "SUPRA" to quit' >/dev/null 2>&1 || true
sleep 2
pkill -x SUPRA >/dev/null 2>&1 || true
sleep 1

say "2/9 Rollback de la version actuellement installée"
mkdir -p "$DEST_DIR" "$RETIRED"
if [ -e "$DEST" ]; then
  mv "$DEST" "$RETIRED/SUPRA-FRANCE-CLEAN.app"
  say "Rollback: $RETIRED/SUPRA-FRANCE-CLEAN.app"
fi

say "3/9 Vérification du toolchain"
command -v xcodebuild >/dev/null || die "Xcode/xcodebuild introuvable" 20
SDK="$(xcrun --sdk macosx --show-sdk-version 2>/dev/null || true)"
[ -n "$SDK" ] || die "SDK macOS introuvable" 21
say "SDK macOS: $SDK"

say "4/9 Téléchargement source exact"
TARBALL="$TMP/source.tgz"
curl -fL --retry 3 --connect-timeout 20 "$REPO_TARBALL" -o "$TARBALL" || die "Téléchargement source impossible" 30
tar -xzf "$TARBALL" -C "$TMP"
SRCROOT="$(find "$TMP" -maxdepth 1 -type d -name '*SUPRA-*' | head -1)"
[ -n "$SRCROOT" ] && [ -d "$SRCROOT" ] || die "Source extraite introuvable" 31

say "5/9 Invariants produit"
grep -Fq 'private var storedRoute = SUPRAOJORoute.chat.rawValue' "$SRCROOT/SUPRA/SUPRAOJOHomeView.swift" || die "Chat non défini comme accueil" 40
grep -Fq 'SUPRAChatView()' "$SRCROOT/SUPRA/SUPRAOJOHomeView.swift" || die "Chat absent de la maison" 41
grep -Fq 'FranceOrganismNativeView()' "$SRCROOT/SUPRA/SUPRAOJOHomeView.swift" || die "France absente" 42
grep -Fq 'OJOOrganismNativeView()' "$SRCROOT/SUPRA/SUPRAOJOHomeView.swift" || die "ojO absent" 43
grep -Fq '.preferredColorScheme(.dark)' "$SRCROOT/SUPRA/SUPRAOJOHomeView.swift" || die "Design system sombre absent" 44
grep -Fq 'com.novaera.sol-github-bridge' "$SRCROOT/SUPRA/SUPRAChatRuntimeAdapter.swift" || die "Auto-réveil du bridge absent" 45

say "6/9 Résolution dépendances"
(
  cd "$SRCROOT"
  for ATTEMPT in 1 2 3; do
    xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -resolvePackageDependencies && exit 0
    [ "$ATTEMPT" = "3" ] && exit 49
    sleep 3
  done
) || die "Dépendances non résolues" 49

say "7/9 Compilation Release locale"
DERIVED="$TMP/DerivedData"
(
  cd "$SRCROOT"
  set -o pipefail
  xcodebuild     -project SUPRA.xcodeproj     -scheme SUPRA     -configuration Release     -sdk macosx     -derivedDataPath "$DERIVED"     CODE_SIGNING_ALLOWED=NO     CODE_SIGNING_REQUIRED=NO     build
) || die "BUILD FAILED — voir $LOG" 50

BUILT="$DERIVED/Build/Products/Release/SUPRA.app"
[ -d "$BUILT" ] || die "SUPRA.app non produite" 51

say "8/9 Signature et installation"
/usr/bin/codesign --force --deep --sign - --timestamp=none "$BUILT"
/usr/bin/codesign --verify --deep --strict --verbose=2 "$BUILT" || die "Signature build invalide" 60
/usr/bin/ditto "$BUILT" "$DEST"
/usr/bin/xattr -dr com.apple.quarantine "$DEST" 2>/dev/null || true
/usr/bin/codesign --verify --deep --strict --verbose=2 "$DEST" || die "Signature installée invalide" 61

say "9/9 Réveil runtime + lancement"
LABEL="com.novaera.sol-github-bridge"
PLIST="$HOME/Library/LaunchAgents/${LABEL}.plist"
if [ -f "$PLIST" ]; then
  /bin/launchctl kickstart -k "gui/$(id -u)/$LABEL" >/dev/null 2>&1 || true
  sleep 2
fi

open -n "$DEST"
sleep 5
PID="$(pgrep -nx SUPRA || true)"
[ -n "$PID" ] || die "Processus SUPRA non lancé" 70
CMD="$(ps -p "$PID" -o command= || true)"
case "$CMD" in
  "$DEST"/Contents/MacOS/SUPRA*) ;;
  *) die "Une autre copie SUPRA a été lancée: $CMD" 71 ;;
esac

HEALTH="UNAVAILABLE"
if curl -fsS --max-time 3 http://127.0.0.1:18765/v1/health >/dev/null 2>&1; then
  HEALTH="CONNECTED"
fi

say "PASS — PRODUCT POLISH V1"
say "APP=$DEST"
say "CHAT_RUNTIME=$HEALTH"
say "ROLLBACK=$RETIRED"
say "LOG=$LOG"
