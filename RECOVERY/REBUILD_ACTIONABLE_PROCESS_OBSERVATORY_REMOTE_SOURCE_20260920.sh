#!/bin/bash
set -euo pipefail

COMMIT="675ea4cba3a4948aca0f63925b9f2ec6c9ad0752"
INSTALL_ROOT="$HOME/Applications"
STAMP="$(date '+%Y%m%d_%H%M%S')"
INSTALL="$INSTALL_ROOT/SUPRA-Observatory-Actionable-$STAMP.app"
BUILDROOT="$(mktemp -d /tmp/supra-observatory-actionable-remote.XXXXXX)"
TARBALL="$BUILDROOT/source.tar.gz"
SRCROOT="$BUILDROOT/src"
DERIVED="$BUILDROOT/DerivedData"

say(){ printf '\n[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }
die(){ printf '\nSTATUS=FAIL_BOUNDED\nBLOCKER=%s\n' "$1"; exit "${2:-1}"; }
cleanup(){ rm -rf "$BUILDROOT"; }
trap cleanup EXIT

say "1/6 Fetch exact actionable source"
mkdir -p "$SRCROOT"
curl -fL --retry 3 --connect-timeout 20   "https://codeload.github.com/Nicolason84/-SUPRA/tar.gz/$COMMIT"   -o "$TARBALL" || die "SOURCE_DOWNLOAD_FAILED" 10

tar -xzf "$TARBALL" -C "$SRCROOT" --strip-components=1   || die "SOURCE_EXTRACT_FAILED" 11

[ -f "$SRCROOT/SUPRA/SUPRAProcessObservatoryView.swift" ]   || die "OBSERVATORY_SOURCE_NOT_FOUND" 12

say "2/6 Prove actionable UI is in exact source"
grep -q 'Button("Select Bridge…"' "$SRCROOT/SUPRA/SUPRAProcessObservatoryView.swift"   || die "TOOLBAR_SELECT_BRIDGE_BUTTON_MISSING" 13
grep -q 'Connect existing bridge' "$SRCROOT/SUPRA/SUPRAProcessObservatoryView.swift"   || die "PROMINENT_CONNECT_BUTTON_MISSING" 14
grep -q 'process-observatory-select-bridge' "$SRCROOT/SUPRA/SUPRAProcessObservatoryView.swift"   || die "ACTIONABLE_ACCESSIBILITY_ID_MISSING" 15
printf 'ACTIONABLE_SOURCE=PASS\n'

say "3/6 Build"
xcodebuild   -project "$SRCROOT/SUPRA.xcodeproj"   -scheme SUPRA   -configuration Release   -sdk macosx   -derivedDataPath "$DERIVED"   CODE_SIGNING_ALLOWED=NO   build >"$BUILDROOT/xcodebuild.log" 2>&1   || { tail -n 120 "$BUILDROOT/xcodebuild.log"; die "XCODEBUILD_RELEASE_FAILED" 16; }

BUILT="$(find "$DERIVED/Build/Products/Release" -maxdepth 1 -type d -name 'SUPRA.app' -print -quit)"
[ -d "$BUILT" ] || die "BUILT_SUPRA_APP_NOT_FOUND" 17
printf 'BUILD=PASS\n'

say "4/6 Sign/install side-by-side"
codesign --force --deep --sign -   --entitlements "$SRCROOT/SUPRA/SUPRA.entitlements"   "$BUILT" >/dev/null 2>&1 || die "ADHOC_CODESIGN_FAILED" 18

codesign --verify --deep --strict "$BUILT" >/dev/null 2>&1   || die "CODESIGN_VERIFY_FAILED" 19

mkdir -p "$INSTALL_ROOT"
ditto "$BUILT" "$INSTALL" || die "INSTALL_COPY_FAILED" 20
printf 'APP=%s\n' "$INSTALL"

say "5/6 Close stale Observatory windows and launch actionable build"
osascript <<'OSA' >/dev/null 2>&1 || true
tell application "System Events"
    repeat with p in application processes
        try
            if name of p is "SUPRA" then
                set frontmost of p to false
            end if
        end try
    end repeat
end tell
OSA

open -n "$INSTALL" || die "OPEN_FAILED" 21

PID=""
for _ in $(seq 1 40); do
  PID="$(pgrep -f "$INSTALL/Contents/MacOS/SUPRA" | head -1 || true)"
  [ -n "$PID" ] && break
  sleep 0.5
done
[ -n "$PID" ] || die "ACTIONABLE_APP_LAUNCH_FAILED" 22

osascript -e 'tell application id "com.nicolasalonso.SUPRA" to activate' >/dev/null 2>&1 || true

say "6/6 Proof"
printf 'PID=%s\n' "$PID"
printf 'LAUNCH=PASS\n'
printf 'SOURCE_COMMIT=%s\n' "$COMMIT"
printf 'STATUS=ACTIONABLE_BRIDGE_GATE_LAUNCHED\n'
printf 'ACTION_NICOLAS=CLICK_BLUE_CONNECT_EXISTING_BRIDGE_OR_TOOLBAR_SELECT_BRIDGE\n'
