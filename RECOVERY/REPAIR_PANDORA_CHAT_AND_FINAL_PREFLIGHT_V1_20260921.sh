#!/bin/bash
set -euo pipefail

SOURCE_COMMIT="f1ec2cf6924b932219aa6c235a8473be8ae69ef3"
REPO_TARBALL="https://codeload.github.com/Nicolason84/-SUPRA/tar.gz/${SOURCE_COMMIT}"
STAMP="$(date '+%Y%m%d_%H%M%S')"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/SUPRA_PANDORA_FINAL.XXXXXX")"
LOG="$HOME/Library/Logs/SUPRA_PANDORA_FINAL_PREFLIGHT_${STAMP}.log"
DEST="$HOME/Applications/SUPRA-FRANCE-CLEAN.app"
RETIRED="$HOME/Library/Application Support/SUPRA_RETIRED/${STAMP}"

exec > >(tee "$LOG") 2>&1
trap 'rm -rf "$TMP"' EXIT

say(){ printf '\n[%s] %s\n' "$(date '+%H:%M:%S')" "$*"; }
die(){ say "FAIL: $1"; exit "${2:-1}"; }

say "SUPRA × ojO — PANDORA FINAL PREFLIGHT"

say "1/11 Source exacte"
TARBALL="$TMP/source.tgz"
curl -fL --retry 3 --connect-timeout 20 "$REPO_TARBALL" -o "$TARBALL" || die "Téléchargement source impossible" 30
tar -xzf "$TARBALL" -C "$TMP"
SRCROOT="$(find "$TMP" -maxdepth 1 -type d -name '*SUPRA-*' | head -1)"
[ -n "$SRCROOT" ] && [ -d "$SRCROOT" ] || die "Source introuvable" 31

say "2/11 Invariants avion"
grep -Fq 'Historical C1 builds did not always expose /v1/health' "$SRCROOT/SUPRA/SUPRAChatRuntimeAdapter.swift" || die "Compatibilité health absente" 40
grep -Fq 'SUPRAGabrielConductorRuntime.load()' "$SRCROOT/SUPRA/MissionStore.swift" || die "Gabriel non relié" 41
grep -Fq 'capability_opportunities' "$SRCROOT/SUPRA/MissionStore.swift" || die "Opportunités non reliées" 42
grep -Fq 'DECISION_BOARD_AUTHORITY_FINAL.json' "$SRCROOT/SUPRA/DecisionStore.swift" || die "Decision boards non reliés" 43
grep -Fq 'OJOWorkspaceView()' "$SRCROOT/SUPRA/SUPRAOJOHomeView.swift" || die "ojO fusion absent" 44

say "3/11 Dépendances"
(
  cd "$SRCROOT"
  for ATTEMPT in 1 2 3; do
    xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -resolvePackageDependencies && exit 0
    [ "$ATTEMPT" = "3" ] && exit 49
    sleep 3
  done
) || die "Dépendances non résolues" 49

say "4/11 Build Release"
DERIVED="$TMP/DerivedData"
(
  cd "$SRCROOT"
  set -o pipefail
  xcodebuild     -project SUPRA.xcodeproj     -scheme SUPRA     -configuration Release     -sdk macosx     -derivedDataPath "$DERIVED"     CODE_SIGNING_ALLOWED=NO     CODE_SIGNING_REQUIRED=NO     build
) || die "BUILD FAILED — $LOG" 50

BUILT="$DERIVED/Build/Products/Release/SUPRA.app"
[ -d "$BUILT" ] || die "App non produite" 51

say "5/11 Installation avec rollback"
osascript -e 'tell application "SUPRA" to quit' >/dev/null 2>&1 || true
sleep 2
pkill -x SUPRA >/dev/null 2>&1 || true
mkdir -p "$HOME/Applications" "$RETIRED"
if [ -e "$DEST" ]; then
  mv "$DEST" "$RETIRED/SUPRA-FRANCE-CLEAN.app"
fi

/usr/bin/codesign --force --deep --sign - --timestamp=none "$BUILT"
/usr/bin/codesign --verify --deep --strict --verbose=2 "$BUILT" || die "Signature build invalide" 60
/usr/bin/ditto "$BUILT" "$DEST"
/usr/bin/xattr -dr com.apple.quarantine "$DEST" 2>/dev/null || true
/usr/bin/codesign --verify --deep --strict --verbose=2 "$DEST" || die "Signature installée invalide" 61

say "6/11 Réveil OpenCode existant"
if ! lsof -nP -iTCP:4096 -sTCP:LISTEN >/dev/null 2>&1; then
  OPENCODE="$(command -v opencode || true)"
  WORKSPACE="$HOME/NOVA_DEV/SUPRA_ERA2_CERTIFIED"
  if [ -n "$OPENCODE" ] && [ -d "$WORKSPACE" ]; then
    (
      cd "$WORKSPACE"
      nohup "$OPENCODE" serve --hostname 127.0.0.1 --port 4096 >/tmp/supra_opencode_runtime_health.log 2>&1 </dev/null &
    )
  fi
fi

for _ in $(seq 1 20); do
  lsof -nP -iTCP:4096 -sTCP:LISTEN >/dev/null 2>&1 && break
  sleep 1
done

say "7/11 Réveil bridge Chat existant"
LABEL="com.novaera.sol-github-bridge"
PLIST="$HOME/Library/LaunchAgents/${LABEL}.plist"
BRIDGE_ROOT="$HOME/NOVA_OS/SUPRA_CHATGPT_APP_BRIDGE_V1"
BRIDGE_SH="$BRIDGE_ROOT/bridge.sh"

if [ -f "$PLIST" ]; then
  /bin/launchctl bootstrap "gui/$(id -u)" "$PLIST" >/dev/null 2>&1 || true
  /bin/launchctl kickstart -k "gui/$(id -u)/$LABEL" >/dev/null 2>&1 || true
fi

sleep 2

if ! lsof -nP -iTCP:18765 -sTCP:LISTEN >/dev/null 2>&1; then
  if [ -f "$BRIDGE_SH" ]; then
    nohup /bin/bash "$BRIDGE_SH" watch >/tmp/supra_bridge_runtime_health.log 2>&1 </dev/null &
  fi
fi

for _ in $(seq 1 30); do
  lsof -nP -iTCP:18765 -sTCP:LISTEN >/dev/null 2>&1 && break
  sleep 1
done

PORT_18765="NO"
lsof -nP -iTCP:18765 -sTCP:LISTEN >/dev/null 2>&1 && PORT_18765="YES"

say "8/11 Contrat HTTP Chat"
HEALTH_BODY="$TMP/health.body"
HEALTH_CODE="$(curl -sS --max-time 5 -o "$HEALTH_BODY" -w '%{http_code}' http://127.0.0.1:18765/v1/health 2>/dev/null || true)"
[ -n "$HEALTH_CODE" ] || HEALTH_CODE="000"

HTTP_REACHABLE="NO"
case "$HEALTH_CODE" in
  2??|404|405) HTTP_REACHABLE="YES" ;;
esac

say "PORT_18765=$PORT_18765"
say "HEALTH_HTTP=$HEALTH_CODE"
say "HTTP_REACHABLE=$HTTP_REACHABLE"

say "9/11 Preuve fonctionnelle /v1/chat"
CHAT_REQUEST="$TMP/chat.request.json"
CHAT_RESPONSE="$TMP/chat.response.json"
EVIDENCE_META="$TMP/evidence.meta"

CHAT_REQUEST="$CHAT_REQUEST" EVIDENCE_META="$EVIDENCE_META" /usr/bin/python3 <<'PY'
import json, os
from pathlib import Path

home=Path.home()
MAX=262_144

def latest(root, exts, name_parts, path_parts=()):
    if not root.exists():
        return None
    best=None
    best_m=-1
    for p in root.rglob("*"):
        try:
            if not p.is_file(): continue
            if p.suffix.lower().lstrip(".") not in exts: continue
            name=p.name.upper()
            if not all(x.upper() in name for x in name_parts): continue
            low=str(p).lower()
            if not all(x.lower() in low for x in path_parts): continue
            m=p.stat().st_mtime
            if m > best_m:
                best,best_m=p,m
        except Exception:
            pass
    return best

probe_root=home/"NOVA_OS/SUPRA_STREAM_RECONCILIATION_V1/PROBES"
action_root=home/"NOVA_OS/SUPRA_ACTION_CENTER_V1/ACTION_RUNS"
recon_root=home/"NOVA_OS/SUPRA_STREAM_RECONCILIATION_V1/RUNS"

graph=latest(probe_root, {"json","txt","tsv"}, ["GRAPH","SCHEMA"])
status=latest(action_root, {"json","txt"}, ["STATUS"], ["probe-project-graph"])
if status is None:
    status=latest(recon_root, {"json","txt"}, ["STATUS"])

items=[]
for eid,p in [("GRAPH_SCHEMA_PROBE",graph),("STATUS",status)]:
    if p is None: continue
    try:
        raw=p.read_bytes()[:MAX]
        if not raw: continue
        ext=p.suffix.lower()
        ctype="application/json" if ext==".json" else "text/tab-separated-values" if ext==".tsv" else "text/plain"
        items.append({
            "evidence_id":eid,
            "source_path":str(p),
            "content_type":ctype,
            "content":raw.decode("utf-8","replace")
        })
    except Exception:
        pass

payload={
    "message":"SUPRA_PANDORA_PREFLIGHT_PING_V1. Réponds brièvement PONG si le canal conversationnel fonctionne.",
    "mission_evidence":items
}
Path(os.environ["CHAT_REQUEST"]).write_text(json.dumps(payload,ensure_ascii=False),encoding="utf-8")
Path(os.environ["EVIDENCE_META"]).write_text(
    json.dumps({"count":len(items),"ids":[x["evidence_id"] for x in items]},ensure_ascii=False),
    encoding="utf-8"
)
print("EVIDENCE_COUNT="+str(len(items)))
print("EVIDENCE_IDS="+",".join(x["evidence_id"] for x in items))
PY

EVIDENCE_COUNT="$(/usr/bin/python3 -c 'import json,sys;print(json.load(open(sys.argv[1]))["count"])' "$EVIDENCE_META" 2>/dev/null || echo 0)"

CHAT_HTTP="000"
if [ "$PORT_18765" = "YES" ]; then
  CHAT_HTTP="$(curl -sS --max-time 90 -o "$CHAT_RESPONSE" -w '%{http_code}'     -H 'Content-Type: application/json'     --data-binary @"$CHAT_REQUEST"     http://127.0.0.1:18765/v1/chat 2>/dev/null || true)"
fi
[ -n "$CHAT_HTTP" ] || CHAT_HTTP="000"

CHAT_FUNCTIONAL="NO"
CHAT_STATUS="NONE"
CHAT_REPLY_NONEMPTY="NO"
if [ -s "$CHAT_RESPONSE" ]; then
  read -r CHAT_STATUS CHAT_REPLY_NONEMPTY <<EOF
$(CHAT_RESPONSE="$CHAT_RESPONSE" /usr/bin/python3 <<'PY'
import json, os
try:
    x=json.load(open(os.environ["CHAT_RESPONSE"],encoding="utf-8"))
    status=str(x.get("status") or "NONE").upper()
    reply=x.get("reply")
    print(status, "YES" if isinstance(reply,str) and bool(reply.strip()) else "NO")
except Exception:
    print("MALFORMED NO")
PY
)
EOF
fi

case "$CHAT_HTTP" in
  2??)
    if [ "$CHAT_STATUS" = "PASS" ] && [ "$CHAT_REPLY_NONEMPTY" = "YES" ]; then
      CHAT_FUNCTIONAL="YES"
    fi
    ;;
esac

say "EVIDENCE_COUNT=$EVIDENCE_COUNT"
say "CHAT_HTTP=$CHAT_HTTP"
say "CHAT_STATUS=$CHAT_STATUS"
say "CHAT_REPLY_NONEMPTY=$CHAT_REPLY_NONEMPTY"
say "CHAT_FUNCTIONAL=$CHAT_FUNCTIONAL"

say "10/11 Checks économiques et avionique"
GABRIEL="$HOME/NOVA_OS/GABRIEL_PARALLEL_MISSION_CONDUCTOR_V1/CURRENT/OUTPUTS/GABRIEL_CONSOLIDATION.json"
GABRIEL_STATE="ABSENT"
if [ -s "$GABRIEL" ] && /usr/bin/python3 -m json.tool "$GABRIEL" >/dev/null 2>&1; then
  GABRIEL_STATE="READY"
fi

BOARDS=0
for B in   "$HOME/NOVA_OS/SUPRA_READ_RECONCILED_VERDICT_AND_REPUBLISH_ARCHITECTURE_DECISION_BOARD_V1/CURRENT/DECISION_BOARD.json"   "$HOME/NOVA_OS/SUPRA_RESOLVE_AUTHORITY_FIELD_LINEAGE_AND_CLOSE_SINGLE_HUMAN_GATE_V1/CURRENT/DECISION_BOARD_AUTHORITY_FINAL.json"   "$HOME/NOVA_OS/SUPRA_EXECUTE_APPROVED_DERIVED_DATA_BATCH_AND_BUILD_REVIEW_BOARD_FOR_26_70_GB_V1/CURRENT/STORAGE_DECISION_BOARD_AFTER_DERIVED_DATA.json"
do
  [ -s "$B" ] && BOARDS=$((BOARDS+1))
done

OPPORTUNITY_FILE="$HOME/NOVA_OS/SUPRA_STREAM_RECONCILIATION_V1/CURRENT/04_PRODUCTS_SEMANTIC_V4.json"
OPPORTUNITIES=0
if [ -s "$OPPORTUNITY_FILE" ]; then
  OPPORTUNITIES="$(OPPORTUNITY_FILE="$OPPORTUNITY_FILE" /usr/bin/python3 <<'PY'
import json, os
try:
    x=json.load(open(os.environ["OPPORTUNITY_FILE"],encoding="utf-8"))
    print(len(x.get("capability_opportunities") or []))
except Exception:
    print(0)
PY
)"
fi

ACTION_ALLOWLIST="$HOME/NOVA_OS/SUPRA_ACTION_CENTER_V1/ALLOWLIST.json"
ACTIONS="ABSENT"
if [ -s "$ACTION_ALLOWLIST" ] && /usr/bin/python3 -m json.tool "$ACTION_ALLOWLIST" >/dev/null 2>&1; then
  ACTIONS="READY"
fi

OPENCODE="NO"
lsof -nP -iTCP:4096 -sTCP:LISTEN >/dev/null 2>&1 && OPENCODE="YES"

say "11/11 Lancement exact"
open -n "$DEST"
sleep 5
PID="$(pgrep -nx SUPRA || true)"
[ -n "$PID" ] || die "SUPRA non lancé" 70
CMD="$(ps -p "$PID" -o command= || true)"
case "$CMD" in
  "$DEST"/Contents/MacOS/SUPRA*) ;;
  *) die "Mauvaise copie lancée: $CMD" 71 ;;
esac

say "PANDORA_FINAL_PREFLIGHT_RESULT"
printf 'APP=PASS\n'
printf 'PORT_18765=%s\n' "$PORT_18765"
printf 'HEALTH_HTTP=%s\n' "$HEALTH_CODE"
printf 'CHAT_FUNCTIONAL=%s\n' "$CHAT_FUNCTIONAL"
printf 'CHAT_HTTP=%s\n' "$CHAT_HTTP"
printf 'CHAT_STATUS=%s\n' "$CHAT_STATUS"
printf 'EVIDENCE=%s/2\n' "$EVIDENCE_COUNT"
printf 'GABRIEL=%s\n' "$GABRIEL_STATE"
printf 'DECISION_BOARDS=%s/3\n' "$BOARDS"
printf 'OPPORTUNITIES=%s/20\n' "$OPPORTUNITIES"
printf 'ACTION_CENTER=%s\n' "$ACTIONS"
printf 'OPENCODE_4096=%s\n' "$OPENCODE"
printf 'SOURCE_COMMIT=%s\n' "$SOURCE_COMMIT"
printf 'ROLLBACK=%s\n' "$RETIRED"
printf 'LOG=%s\n' "$LOG"

if [ "$CHAT_FUNCTIONAL" = "YES" ]    && [ "$OPPORTUNITIES" = "20" ]    && [ "$BOARDS" -ge 1 ]    && [ "$ACTIONS" = "READY" ]; then
  if [ "$GABRIEL_STATE" = "READY" ] && [ "$OPENCODE" = "YES" ]; then
    say "STATUS=GO_PARALLEL_3_CONTROLLED"
  else
    say "STATUS=GO_SINGLE_BRANCH_CONTROLLED"
  fi
else
  say "STATUS=NO_GO_BOUNDED"
  if [ "$CHAT_FUNCTIONAL" != "YES" ]; then
    say "BLOCKER=CHAT_FUNCTIONAL"
    if [ -f /tmp/supra_bridge_runtime_health.log ]; then
      printf '\n--- BRIDGE LOG TAIL ---\n'
      tail -n 80 /tmp/supra_bridge_runtime_health.log || true
    fi
    if [ -s "$CHAT_RESPONSE" ]; then
      printf '\n--- CHAT RESPONSE (MAX 2000 BYTES) ---\n'
      head -c 2000 "$CHAT_RESPONSE" || true
      printf '\n'
    fi
  fi
fi
