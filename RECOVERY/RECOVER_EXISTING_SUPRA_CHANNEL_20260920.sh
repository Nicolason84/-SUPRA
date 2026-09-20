#!/bin/bash
set -euo pipefail

say(){ printf '\n[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }
die(){ printf '\nSTATUS=FAIL_BOUNDED\nBLOCKER=%s\n' "$1"; exit "${2:-1}"; }

LABEL="com.novaera.sol-github-bridge"
PLIST="$HOME/Library/LaunchAgents/${LABEL}.plist"
BRIDGE_ROOT="$HOME/NOVA_OS/SUPRA_CHATGPT_APP_BRIDGE_V1"
BRIDGE_SH="$BRIDGE_ROOT/bridge.sh"
BRIDGE_PY="$BRIDGE_ROOT/ENGINE/supra_chatgpt_app_bridge.py"
WORKSPACE="$HOME/NOVA_DEV/SUPRA_ERA2_CERTIFIED"
CANON_BRANCH="supra/human-gate-single-source-20260721_072447"
REQUIRED_MERGE="d091b19ff81d73772aac39c2531ceff545e5e63d"
INSTALL="$HOME/Applications/SUPRA.app"
C1_LOG="/tmp/supra_bridge_runtime_health.log"
OC_LOG="/tmp/supra_opencode_runtime_health.log"

say "0/7 Preflight"
printf 'HOST=%s\nUSER=%s\n' "$(scutil --get ComputerName 2>/dev/null || hostname)" "$USER"
[ -d "$BRIDGE_ROOT" ] || die "EXISTING_BRIDGE_ROOT_NOT_FOUND:$BRIDGE_ROOT" 10
[ -f "$BRIDGE_PY" ] || die "EXISTING_CONSUMER_NOT_FOUND:$BRIDGE_PY" 11

say "1/7 Resolve existing Drive mailbox"
REMOTE=""
for c in   "$HOME/Library/CloudStorage/GoogleDrive-nicolas.alonsof84@gmail.com/Mon Drive/SUPRA_IMAC_MEMORY_GATEWAY/REMOTE"   "$HOME/Library/CloudStorage/GoogleDrive-nicolas.alonsof84@gmail.com/My Drive/SUPRA_IMAC_MEMORY_GATEWAY/REMOTE"   "$HOME/Library/CloudStorage/Google Drive/Mon Drive/SUPRA_IMAC_MEMORY_GATEWAY/REMOTE"   "$HOME/Library/CloudStorage/Google Drive/My Drive/SUPRA_IMAC_MEMORY_GATEWAY/REMOTE"
do
  if [ -d "$c/INBOX" ] && [ -d "$c/OUTBOX" ]; then
    REMOTE="$c"
    break
  fi
done

if [ -z "$REMOTE" ]; then
  REMOTE="$(find "$HOME/Library/CloudStorage" -maxdepth 8 -type d -path '*/SUPRA_IMAC_MEMORY_GATEWAY/REMOTE' -print -quit 2>/dev/null || true)"
fi

[ -n "$REMOTE" ] || die "DRIVE_REMOTE_MAILBOX_NOT_FOUND" 12
[ -d "$REMOTE/INBOX" ] || die "DRIVE_INBOX_NOT_FOUND:$REMOTE" 13
[ -d "$REMOTE/OUTBOX" ] || die "DRIVE_OUTBOX_NOT_FOUND:$REMOTE" 14
printf 'REMOTE=%s\n' "$REMOTE"

say "2/7 Restore existing consumer/C1"
if [ -f "$PLIST" ]; then
  launchctl bootstrap "gui/$UID" "$PLIST" >/dev/null 2>&1 || true
  launchctl kickstart -k "gui/$UID/$LABEL" >/dev/null 2>&1 || true
fi

sleep 2

if ! lsof -nP -iTCP:18765 -sTCP:LISTEN >/dev/null 2>&1; then
  [ -x "$BRIDGE_SH" ] || [ -f "$BRIDGE_SH" ] || die "EXISTING_BRIDGE_WRAPPER_NOT_FOUND:$BRIDGE_SH" 15
  nohup /bin/bash "$BRIDGE_SH" watch >"$C1_LOG" 2>&1 </dev/null &
fi

for _ in $(seq 1 30); do
  if lsof -nP -iTCP:18765 -sTCP:LISTEN >/dev/null 2>&1; then break; fi
  sleep 1
done

if ! lsof -nP -iTCP:18765 -sTCP:LISTEN >/dev/null 2>&1; then
  printf '\n--- C1 LOG ---\n'
  tail -n 100 "$C1_LOG" 2>/dev/null || true
  die "C1_18765_NOT_LISTENING" 16
fi
lsof -nP -iTCP:18765 -sTCP:LISTEN

say "3/7 Restore existing OpenCode"
if ! lsof -nP -iTCP:4096 -sTCP:LISTEN >/dev/null 2>&1; then
  OPENCODE="$(command -v opencode || true)"
  [ -n "$OPENCODE" ] || die "OPENCODE_BINARY_NOT_FOUND" 17
  [ -d "$WORKSPACE" ] || die "WORKSPACE_NOT_FOUND:$WORKSPACE" 18

  nohup "$OPENCODE" "$WORKSPACE" --agent "SUPRA-Router" >"$OC_LOG" 2>&1 </dev/null &
fi

for _ in $(seq 1 30); do
  if lsof -nP -iTCP:4096 -sTCP:LISTEN >/dev/null 2>&1; then break; fi
  sleep 1
done

if ! lsof -nP -iTCP:4096 -sTCP:LISTEN >/dev/null 2>&1; then
  printf '\n--- OPENCODE LOG ---\n'
  tail -n 100 "$OC_LOG" 2>/dev/null || true
  die "OPENCODE_4096_NOT_LISTENING" 19
fi
lsof -nP -iTCP:4096 -sTCP:LISTEN

say "4/7 Real Drive PING -> OUTBOX"
PAIR=""
for p in "$REMOTE/PAIRING.json" "$REMOTE/STATE/PAIRING.json" "$(dirname "$REMOTE")/PAIRING.json"; do
  if [ -f "$p" ]; then PAIR="$p"; break; fi
done
if [ -z "$PAIR" ]; then
  PAIR="$(find "$REMOTE" -maxdepth 3 -type f -name 'PAIRING.json' -print -quit 2>/dev/null || true)"
fi
[ -n "$PAIR" ] || die "PAIRING_JSON_NOT_FOUND" 20

PY="$(command -v python3 || true)"
[ -n "$PY" ] || die "PYTHON3_NOT_FOUND" 21

MID="SOL_COCKPIT_UNLOCK_$(date '+%Y%m%d_%H%M%S')"

PAIR_PATH="$PAIR" REMOTE_ROOT="$REMOTE" MISSION_ID="$MID" "$PY" <<'PY'
import json, os
from pathlib import Path

pair=json.loads(Path(os.environ["PAIR_PATH"]).read_text())

def deep(obj,key):
    if isinstance(obj,dict):
        if obj.get(key):
            return obj[key]
        for v in obj.values():
            r=deep(v,key)
            if r is not None:
                return r
    elif isinstance(obj,list):
        for v in obj:
            r=deep(v,key)
            if r is not None:
                return r
    return None

pid=deep(pair,"pairing_id")
tok=deep(pair,"pairing_token")
if not pid or not tok:
    raise SystemExit("PAIRING_FIELDS_MISSING")

mission={
    "schema":"SUPRA_REMOTE_MISSION_V1",
    "pairing_id":pid,
    "pairing_token":tok,
    "type":"PING",
    "mission_id":os.environ["MISSION_ID"]
}

target=Path(os.environ["REMOTE_ROOT"])/"INBOX"/f'{os.environ["MISSION_ID"]}.json'
tmp=target.with_suffix(".pending")
tmp.write_text(json.dumps(mission,separators=(",",":")),encoding="utf-8")
os.replace(tmp,target)
print("MISSION="+str(target))
PY

OUT="$REMOTE/OUTBOX/${MID}.result.json"
for _ in $(seq 1 60); do
  if [ -s "$OUT" ]; then break; fi
  sleep 1
done
[ -s "$OUT" ] || die "REAL_OUTBOX_NOT_MATERIALIZED:$MID" 22

OUT_PATH="$OUT" "$PY" <<'PY'
import json, os
x=json.load(open(os.environ["OUT_PATH"],encoding="utf-8"))
r=x.get("result") if isinstance(x.get("result"),dict) else {}
status=str(x.get("status","")).upper()
pong=(x.get("pong") is True) or (r.get("pong") is True)
if status!="PASS" or not pong:
    raise SystemExit(f"OUTBOX_NOT_PASS status={status} pong={pong}")
print("REAL_OUTBOX_PASS=YES")
print("OUTBOX_FILE="+os.environ["OUT_PATH"])
PY

say "5/7 Resolve canonical Git checkout"
REPO=""
for r in "$HOME/Desktop/NOVA_OS/SUPRA" "$HOME/NOVA_DEV/SUPRA_ERA2_CERTIFIED"; do
  if [ -d "$r/.git" ]; then
    U="$(git -C "$r" remote get-url origin 2>/dev/null || true)"
    case "$U" in *Nicolason84/-SUPRA*) REPO="$r"; break;; esac
  fi
done
[ -n "$REPO" ] || die "LOCAL_SUPRA_GIT_CHECKOUT_NOT_FOUND" 23
printf 'REPO=%s\n' "$REPO"

git -C "$REPO" fetch origin "$CANON_BRANCH"
git -C "$REPO" merge-base --is-ancestor "$REQUIRED_MERGE" "origin/$CANON_BRANCH"   || die "CANONICAL_BRANCH_MISSING_VALIDATED_MERGE" 24

say "6/7 Build/install/launch validated SUPRA"
BUILDROOT="$(mktemp -d /tmp/supra-cockpit-activate.XXXXXX)"
SRC="$BUILDROOT/src"
DERIVED="$BUILDROOT/DerivedData"
cleanup(){ git -C "$REPO" worktree remove --force "$SRC" >/dev/null 2>&1 || true; }
trap cleanup EXIT

git -C "$REPO" worktree add --detach "$SRC" "origin/$CANON_BRANCH" >/dev/null
xcodebuild -project "$SRC/SUPRA.xcodeproj" -scheme SUPRA -configuration Release -sdk macosx   -derivedDataPath "$DERIVED" CODE_SIGNING_ALLOWED=NO build >"$BUILDROOT/xcodebuild.log" 2>&1   || { tail -n 120 "$BUILDROOT/xcodebuild.log"; die "XCODEBUILD_RELEASE_FAILED" 25; }

BUILT="$(find "$DERIVED/Build/Products/Release" -maxdepth 1 -type d -name 'SUPRA.app' -print -quit)"
[ -d "$BUILT" ] || die "BUILT_SUPRA_APP_NOT_FOUND" 26

codesign --force --deep --sign - --entitlements "$SRC/SUPRA/SUPRA.entitlements" "$BUILT" >/dev/null 2>&1   || die "ADHOC_CODESIGN_FAILED" 27
codesign --verify --deep --strict "$BUILT" >/dev/null 2>&1   || die "CODESIGN_VERIFY_FAILED" 28

mkdir -p "$HOME/Applications"
STAMP="$(date '+%Y%m%d_%H%M%S')"
BACKUP="$HOME/Applications/SUPRA.app.rollback.$STAMP"

if [ -d "$INSTALL" ]; then ditto "$INSTALL" "$BACKUP"; fi
osascript -e 'tell application id "com.nicolasalonso.SUPRA" to quit' >/dev/null 2>&1 || true
sleep 2
rm -rf "$INSTALL"

if ! ditto "$BUILT" "$INSTALL"; then
  rm -rf "$INSTALL"
  [ -d "$BACKUP" ] && ditto "$BACKUP" "$INSTALL" || true
  die "INSTALL_COPY_FAILED_ROLLBACK_ATTEMPTED" 29
fi

open -n "$INSTALL"
for _ in $(seq 1 20); do
  if pgrep -x SUPRA >/dev/null 2>&1; then break; fi
  sleep 1
done
if ! pgrep -x SUPRA >/dev/null 2>&1; then
  rm -rf "$INSTALL"
  [ -d "$BACKUP" ] && { ditto "$BACKUP" "$INSTALL"; open -n "$INSTALL"; } || true
  die "SUPRA_LAUNCH_FAILED_ROLLBACK_ATTEMPTED" 30
fi

printf 'SUPRA_PID=%s\n' "$(pgrep -x SUPRA | head -1)"
printf 'INSTALLED_APP=%s\n' "$INSTALL"

say "7/7 One-time sandbox folder gate"
open "$REMOTE"
osascript -e 'tell application id "com.nicolasalonso.SUPRA" to activate' >/dev/null 2>&1 || true
printf '\nSTATUS=CHANNEL_OUTBOX_BUILD_INSTALL_LAUNCH_PASS\n'
printf 'NEXT=SUPRA_RUNTIME_MONITOR_SELECT_BRIDGE\n'
printf 'BRIDGE_FOLDER=%s\n' "$REMOTE"
