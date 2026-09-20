#!/bin/bash
set -euo pipefail

SOURCE_COMMIT="85b4e7312cc9f99caad58f6a4d1a7539c6fd217a"
BRIDGE="$HOME/Library/CloudStorage/GoogleDrive-nicolas.alonsof84@gmail.com/Mon Drive/SUPRA_IMAC_MEMORY_GATEWAY/REMOTE"
BOOKMARK_KEY="SUPRAProcessObservatory.bridgeRootBookmark.v1"

say(){ printf '\n[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }
die(){ printf '\nSTATUS=FAIL_BOUNDED\nBLOCKER=%s\n' "$1"; exit "${2:-1}"; }

say "1/5 Preflight"
[ -d "$BRIDGE/INBOX" ] && [ -d "$BRIDGE/OUTBOX" ] || die "BRIDGE_ROOT_NOT_READY" 10
command -v xcodebuild >/dev/null || die "XCODEBUILD_NOT_FOUND" 11

say "2/5 Exact source"
TMP="$(mktemp -d /tmp/supra-observatory-safe.XXXXXX)"
TGZ="$TMP/source.tgz"
curl -fsSL "https://github.com/Nicolason84/-SUPRA/archive/$SOURCE_COMMIT.tar.gz" -o "$TGZ"
tar -xzf "$TGZ" -C "$TMP"
SRC="$(find "$TMP" -maxdepth 2 -type d -name '*.xcodeproj' -print -quit | sed 's#/SUPRA.xcodeproj$##')"
[ -n "$SRC" ] && [ -d "$SRC/SUPRA.xcodeproj" ] || die "SOURCE_EXTRACTION_FAILED" 12
grep -q 'SUPRAProcessObservatoryView()' "$SRC/SUPRA/SupraControlCenterView.swift" || die "OBSERVATORY_ROUTE_MISSING" 13
grep -q 'securityScopeAllowOnlyReadAccess' "$SRC/SUPRA/SUPRAProcessObservatoryView.swift" || die "READ_ONLY_CONTRACT_MISSING" 14

say "3/5 Build"
DERIVED="$TMP/DerivedData"
xcodebuild -project "$SRC/SUPRA.xcodeproj" -scheme SUPRA -configuration Release -sdk macosx -derivedDataPath "$DERIVED" CODE_SIGNING_ALLOWED=NO build >"$TMP/xcodebuild.log" 2>&1 || {
  tail -n 120 "$TMP/xcodebuild.log"
  die "XCODEBUILD_FAILED" 15
}
BUILT="$(find "$DERIVED/Build/Products/Release" -maxdepth 1 -type d -name 'SUPRA.app' -print -quit)"
[ -d "$BUILT" ] || die "BUILT_APP_NOT_FOUND" 16
codesign --force --deep --sign - --entitlements "$SRC/SUPRA/SUPRA.entitlements" "$BUILT" >/dev/null 2>&1 || die "SIGN_FAILED" 17
codesign --verify --deep --strict "$BUILT" >/dev/null 2>&1 || die "SIGN_VERIFY_FAILED" 18

say "4/5 Install side-by-side and launch"
mkdir -p "$HOME/Applications"
DEST="$HOME/Applications/SUPRA-Observatory-$(date '+%Y%m%d_%H%M%S').app"
ditto "$BUILT" "$DEST"
open -n "$DEST"
for _ in $(seq 1 30); do
  PID="$(pgrep -x SUPRA | tail -1 || true)"
  [ -n "$PID" ] && break
  sleep 1
done
[ -n "${PID:-}" ] || die "APP_LAUNCH_FAILED" 19
open "$BRIDGE" >/dev/null 2>&1 || true
printf 'BUILD=PASS\nLAUNCH=PASS\nAPP=%s\nPID=%s\n' "$DEST" "$PID"

say "5/5 Human gate"
printf 'ACTION_NICOLAS=SUPRA -> Runtime Monitor -> Select Bridge… -> dossier REMOTE déjà ouvert -> Use Bridge\n'
printf 'STATUS=APP_LAUNCHED_AWAITING_READ_ONLY_BRIDGE_SELECTION\n'
