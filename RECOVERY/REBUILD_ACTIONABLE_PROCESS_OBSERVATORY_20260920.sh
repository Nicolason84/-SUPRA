#!/bin/bash
set -euo pipefail

COMMIT="675ea4cba3a4948aca0f63925b9f2ec6c9ad0752"
BRANCH="supra/human-gate-single-source-20260721_072447"
INSTALL_ROOT="$HOME/Applications"
STAMP="$(date '+%Y%m%d_%H%M%S')"
INSTALL="$INSTALL_ROOT/SUPRA-Observatory-Actionable-$STAMP.app"

say(){ printf '\n[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }
die(){ printf '\nSTATUS=FAIL_BOUNDED\nBLOCKER=%s\n' "$1"; exit "${2:-1}"; }

say "1/5 Resolve canonical repo"
REPO=""
for r in "$HOME/Desktop/NOVA_OS/SUPRA" "$HOME/NOVA_DEV/SUPRA_ERA2_CERTIFIED"; do
  if [ -d "$r/.git" ]; then
    U="$(git -C "$r" remote get-url origin 2>/dev/null || true)"
    case "$U" in *Nicolason84/-SUPRA*) REPO="$r"; break;; esac
  fi
done
[ -n "$REPO" ] || die "LOCAL_SUPRA_GIT_CHECKOUT_NOT_FOUND" 10
printf 'REPO=%s\n' "$REPO"

say "2/5 Fetch exact actionable UI commit"
git -C "$REPO" fetch origin "$BRANCH"
git -C "$REPO" cat-file -e "$COMMIT^{commit}" 2>/dev/null || die "TARGET_COMMIT_NOT_FOUND" 11

BUILDROOT="$(mktemp -d /tmp/supra-observatory-actionable.XXXXXX)"
SRC="$BUILDROOT/src"
DERIVED="$BUILDROOT/DerivedData"
cleanup(){ git -C "$REPO" worktree remove --force "$SRC" >/dev/null 2>&1 || true; }
trap cleanup EXIT

git -C "$REPO" worktree add --detach "$SRC" "$COMMIT" >/dev/null

say "3/5 Build exact source"
xcodebuild   -project "$SRC/SUPRA.xcodeproj"   -scheme SUPRA   -configuration Release   -sdk macosx   -derivedDataPath "$DERIVED"   CODE_SIGNING_ALLOWED=NO   build >"$BUILDROOT/xcodebuild.log" 2>&1   || { tail -n 120 "$BUILDROOT/xcodebuild.log"; die "XCODEBUILD_RELEASE_FAILED" 12; }

BUILT="$(find "$DERIVED/Build/Products/Release" -maxdepth 1 -type d -name 'SUPRA.app' -print -quit)"
[ -d "$BUILT" ] || die "BUILT_SUPRA_APP_NOT_FOUND" 13
printf 'BUILD=PASS\n'

say "4/5 Sign/install side-by-side"
codesign --force --deep --sign -   --entitlements "$SRC/SUPRA/SUPRA.entitlements"   "$BUILT" >/dev/null 2>&1 || die "ADHOC_CODESIGN_FAILED" 14
codesign --verify --deep --strict "$BUILT" >/dev/null 2>&1 || die "CODESIGN_VERIFY_FAILED" 15

mkdir -p "$INSTALL_ROOT"
ditto "$BUILT" "$INSTALL"
printf 'APP=%s\n' "$INSTALL"

say "5/5 Launch actionable gate"
open -n "$INSTALL"
for _ in $(seq 1 30); do
  PID="$(pgrep -f "$INSTALL/Contents/MacOS/SUPRA" | head -1 || true)"
  [ -n "$PID" ] && break
  sleep 0.5
done
[ -n "${PID:-}" ] || die "ACTIONABLE_APP_LAUNCH_FAILED" 16

printf 'PID=%s\n' "$PID"
printf 'LAUNCH=PASS\n'
printf 'STATUS=ACTIONABLE_BRIDGE_GATE_LAUNCHED\n'
printf 'ACTION_NICOLAS=CLICK_BIG_BLUE_CONNECT_EXISTING_BRIDGE_BUTTON\n'
