#!/bin/bash
set -euo pipefail

REPO_URL="https://github.com/Nicolason84/-SUPRA.git"
BRANCH="supra/human-gate-single-source-20260721_072447"
EXPECTED_UI="process-observatory-select-bridge"
EXPECTED_TEXT="Connect existing bridge"
STAMP="$(date '+%Y%m%d_%H%M%S')"
ROOT="$(mktemp -d /tmp/supra-observatory-v2.XXXXXX)"
SRC="$ROOT/src"
DERIVED="$ROOT/DerivedData"
DEST="$HOME/Applications/SUPRA-Observatory-Actionable-$STAMP.app"

say(){ printf '\n[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }
die(){ printf '\nSTATUS=FAIL_BOUNDED\nBLOCKER=%s\n' "$1"; exit "${2:-1}"; }
cleanup(){ rm -rf "$ROOT" >/dev/null 2>&1 || true; }
trap cleanup EXIT

say "1/5 Fetch canonical source into temp"
git clone --depth 1 --single-branch --branch "$BRANCH" "$REPO_URL" "$SRC" >/tmp/supra_observatory_clone.log 2>&1   || { tail -n 80 /tmp/supra_observatory_clone.log; die "TEMP_CANONICAL_CLONE_FAILED" 10; }

HEAD="$(git -C "$SRC" rev-parse HEAD)"
printf 'SOURCE_HEAD=%s\n' "$HEAD"

VIEW="$SRC/SUPRA/SUPRAProcessObservatoryView.swift"
[ -f "$VIEW" ] || die "PROCESS_OBSERVATORY_SOURCE_MISSING" 11
grep -Fq "$EXPECTED_UI" "$VIEW" || die "ACTIONABLE_BUTTON_IDENTIFIER_NOT_IN_SOURCE" 12
grep -Fq "$EXPECTED_TEXT" "$VIEW" || die "ACTIONABLE_BUTTON_TEXT_NOT_IN_SOURCE" 13
printf 'ACTIONABLE_SOURCE=PASS\n'

say "2/5 Build Release"
xcodebuild   -project "$SRC/SUPRA.xcodeproj"   -scheme SUPRA   -configuration Release   -sdk macosx   -derivedDataPath "$DERIVED"   CODE_SIGNING_ALLOWED=NO   build >"$ROOT/xcodebuild.log" 2>&1   || { tail -n 120 "$ROOT/xcodebuild.log"; die "XCODEBUILD_RELEASE_FAILED" 14; }

BUILT="$(find "$DERIVED/Build/Products/Release" -maxdepth 1 -type d -name 'SUPRA.app' -print -quit)"
[ -d "$BUILT" ] || die "BUILT_APP_NOT_FOUND" 15

say "3/5 Sign with existing read-only entitlements"
ENT="$SRC/SUPRA/SUPRA.entitlements"
[ -f "$ENT" ] || die "ENTITLEMENTS_MISSING" 16
codesign --force --deep --sign - --entitlements "$ENT" "$BUILT" >/dev/null 2>&1   || die "ADHOC_CODESIGN_FAILED" 17
codesign --verify --deep --strict "$BUILT" >/dev/null 2>&1   || die "CODESIGN_VERIFY_FAILED" 18

say "4/5 Install side-by-side"
mkdir -p "$HOME/Applications"
ditto "$BUILT" "$DEST" || die "INSTALL_COPY_FAILED" 19
printf 'APP=%s\n' "$DEST"

# Close only older side-by-side Process Observatory instances; do not touch unrelated SUPRA copies.
while IFS= read -r pid; do
  [ -n "$pid" ] || continue
  cmd="$(ps -p "$pid" -o command= 2>/dev/null || true)"
  case "$cmd" in
    *"/Applications/SUPRA-Observatory-"*"/Contents/MacOS/SUPRA"*)
      kill "$pid" >/dev/null 2>&1 || true
      ;;
  esac
done < <(pgrep -x SUPRA || true)

open -n "$DEST"

PID=""
for _ in $(seq 1 30); do
  PID="$(pgrep -f "$DEST/Contents/MacOS/SUPRA" 2>/dev/null | head -1 || true)"
  [ -n "$PID" ] && break
  sleep 0.5
done
[ -n "$PID" ] || die "ACTIONABLE_APP_LAUNCH_NOT_PROVEN" 20

say "5/5 Actionable gate proof"
printf 'BUILD=PASS\n'
printf 'LAUNCH=PASS\n'
printf 'PID=%s\n' "$PID"
printf 'SOURCE_HEAD=%s\n' "$HEAD"
printf 'UI_IDENTIFIER=%s\n' "$EXPECTED_UI"
printf 'UI_TEXT=%s\n' "$EXPECTED_TEXT"
printf 'STATUS=ACTIONABLE_PROCESS_OBSERVATORY_LAUNCHED\n'
printf 'ACTION_NICOLAS=CLICK_CONNECT_EXISTING_BRIDGE_OR_SELECT_BRIDGE\n'
