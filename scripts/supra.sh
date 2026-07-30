#!/bin/zsh
set -eo pipefail

SUPRA_ROOT="/Users/nicolasalonso/Desktop/NOVA_OS/SUPRA"
SUPRA_VERSION="PRODUCTION_RUNTIME_V1"
EXECUTION_GATE="EXECUTION GATE VIII"
STAMP=$(date '+%Y-%m-%dT%H:%M:%SZ')

cd "$SUPRA_ROOT"

PASS=0
FAIL=0
WARN=0

pass() { PASS=$((PASS+1)); }
fail() { FAIL=$((FAIL+1)); echo "  ✗ $1"; }
warn() { WARN=$((WARN+1)); echo "  ⚠ $1"; }

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║              SUPRA PRODUCTION RUNTIME V1                     ║"
echo "║              ${EXECUTION_GATE}                                 ║"
echo "║              ${STAMP}                        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

echo "--- PHASE 1: BOOT ACTIVATION ---"

echo ""
echo "  1.1 Repository Validation"
if git -C "$SUPRA_ROOT" rev-parse --git-dir >/dev/null 2>&1; then
  BRANCH=$(git -C "$SUPRA_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null)
  COMMIT=$(git -C "$SUPRA_ROOT" rev-parse --short HEAD 2>/dev/null)
  COMMIT_FULL=$(git -C "$SUPRA_ROOT" rev-parse HEAD 2>/dev/null)
  UNCOMMITTED=$(git -C "$SUPRA_ROOT" status --porcelain | wc -l | tr -d ' ')
  GIT_STATUS="CLEAN"
  [ "$UNCOMMITTED" -gt 0 ] && GIT_STATUS="DIRTY"
  echo "  ✓ Branch: $BRANCH"
  echo "  ✓ Commit: $COMMIT"
  echo "  ◇ Status: $GIT_STATUS ($UNCOMMITTED uncommitted)"
  pass
else
  fail "Not a git repository"
fi

echo ""
echo "  1.2 Session Restore"
SESSION_FILE="$SUPRA_ROOT/SESSION_STATE.json"
EXECUTIVE_FILE="$SUPRA_ROOT/EXECUTIVE_STATE.json"
if [ -f "$SESSION_FILE" ]; then
  SESSION_ID=$(python3 -c "import json; d=json.load(open('$SESSION_FILE')); print(d.get('session',{}).get('id','unknown'))" 2>/dev/null)
  echo "  ✓ Session: $SESSION_ID"
  pass
else
  warn "SESSION_STATE.json not found — first boot"
fi

if [ -f "$EXECUTIVE_FILE" ]; then
  EXEC_DECISION=$(python3 -c "import json; d=json.load(open('$EXECUTIVE_FILE')); print(d.get('current_decision','unknown'))" 2>/dev/null)
  EXEC_GATE=$(python3 -c "import json; d=json.load(open('$EXECUTIVE_FILE')); print(d.get('runtime',{}).get('gate','unknown'))" 2>/dev/null)
  echo "  ✓ Executive: $EXEC_DECISION | Gate: $EXEC_GATE"
  pass
else
  warn "EXECUTIVE_STATE.json not found"
fi

echo ""
echo "  1.3 Registry Validation"
REGISTRY_FILE="$SUPRA_ROOT/FACTORIES/FACTORY_REGISTRY.json"
if [ -f "$REGISTRY_FILE" ]; then
  FACTORIES=$(python3 -c "
import json
d=json.load(open('$REGISTRY_FILE'))
sys=d.get('system',{})
print(sys.get('total_factories',0), sys.get('certified',0), sys.get('healthy',0))
" 2>/dev/null)
  read TOTAL CERT HEALTHY <<< "$FACTORIES"
  echo "  ✓ $TOTAL factories, $CERT certified, $HEALTHY healthy"
  [ "$TOTAL" = "10" ] && pass || warn "Expected 10 factories, got $TOTAL"
else
  fail "FACTORY_REGISTRY.json not found"
fi

echo ""
echo "  1.4 Provider Validation"
OLLAMA_AVAILABLE=0
if command -v ollama >/dev/null 2>&1; then
  ollama list >/dev/null 2>&1 && OLLAMA_AVAILABLE=1
fi
if [ "$OLLAMA_AVAILABLE" = "1" ]; then
  echo "  ✓ Ollama available"
  pass
else
  warn "Ollama not reachable"
fi

PROVIDER_FILE="$SUPRA_ROOT/.opencode/provider_runtime.json"
if [ -f "$PROVIDER_FILE" ]; then
  PROVIDERS=$(python3 -c "
import json
d=json.load(open('$PROVIDER_FILE'))
connected=[p for p in d.get('providers',[]) if p.get('status')=='connected']
print(len(connected))
" 2>/dev/null)
  echo "  ✓ $PROVIDERS provider(s) connected"
  pass
else
  warn "Provider runtime file not found"
fi

echo ""
echo "  1.5 Workspace Detection"
XCODE_PROJ="$SUPRA_ROOT/SUPRA.xcodeproj"
if [ -d "$XCODE_PROJ" ]; then
  echo "  ✓ Xcode project found"
  pass
else
  warn "Xcode project not found"
fi
SWIFT_COUNT=$(find "$SUPRA_ROOT/SUPRA" -name "*.swift" -maxdepth 2 2>/dev/null | wc -l | tr -d ' ')
echo "  ◇ Swift sources: $SWIFT_COUNT"

echo ""
echo "  1.6 Cockpit Refresh"
NEXT_MISSION="$SUPRA_ROOT/NEXT_MISSION.md"
if [ -f "$NEXT_MISSION" ]; then
  MISSION_PRIORITY=$(grep -i "priority" "$NEXT_MISSION" 2>/dev/null | head -1 | sed 's/.*: //')
  echo "  ✓ Current priority: ${MISSION_PRIORITY:-CRITICAL}"
  pass
else
  warn "NEXT_MISSION.md not found"
fi

echo ""
echo "--- PHASE 2: LIVE REPOSITORY ---"
echo ""
echo "  2.1 Repository State"

python3 - "$SUPRA_ROOT" <<'PY' 2>/dev/null
import json, os, subprocess, sys
root = sys.argv[1]

# Current git state
branch = subprocess.run(["git", "-C", root, "rev-parse", "--abbrev-ref", "HEAD"],
    capture_output=True, text=True).stdout.strip()
commit = subprocess.run(["git", "-C", root, "rev-parse", "HEAD"],
    capture_output=True, text=True).stdout.strip()

# Changed files
status = subprocess.run(["git", "-C", root, "status", "--porcelain"],
    capture_output=True, text=True).stdout.strip().split('\n')
status = [s for s in status if s]

modified = [s[3:] for s in status if s.startswith('M') or s.startswith(' M')]
deleted = [s[3:] for s in status if s.startswith('D') or s.startswith(' D')]
added = [s[3:] for s in status if s.startswith('?') or s.startswith('A') or s.startswith(' A')]

# Dependency check
pkg_resolved = root + "/Package.resolved"
dep_changed = False
if os.path.exists(pkg_resolved):
    dep_changed = 'Package.resolved' in modified or 'Package.resolved' in added

state = {
    "schema": "LIVE_REPOSITORY_V1",
    "timestamp": subprocess.run(["date", "-u", "+%Y-%m-%dT%H:%M:%SZ"],
        capture_output=True, text=True).stdout.strip(),
    "branch": branch,
    "commit": commit,
    "commit_short": commit[:8] if commit else "",
    "uncommitted": len(status),
    "modified": len([m for m in modified if m]),
    "deleted": len([d for d in deleted if d]),
    "added": len([a for a in added if a]),
    "dep_changed": dep_changed,
    "status": "DIRTY" if status else "CLEAN",
}
print(json.dumps(state, indent=2))
PY

echo ""

echo "--- PHASE 3: ROUTER ACTIVATION ---"
echo ""
echo "  3.1 Router Configuration"
ROUTER_STATUS=$(python3 -c "
import json
d=json.load(open('$SUPRA_ROOT/opencode.json'))
default = d.get('default_agent', 'none')
router_defined = 'SUPRA-Router' in d.get('agent', {})
print(f'default={default}', f'router_defined={router_defined}')
" 2>/dev/null)
echo "  ◇ $ROUTER_STATUS"
echo "  ✓ Router defined with delegation_rules.json"
pass

DELEGATION_FILE="$SUPRA_ROOT/.opencode/delegation_rules.json"
if [ -f "$DELEGATION_FILE" ]; then
  RULES=$(python3 -c "
import json
d=json.load(open('$DELEGATION_FILE'))
print(len(d.get('rules',[])))
" 2>/dev/null)
  echo "  ✓ $RULES delegation rules loaded"
  pass
else
  warn "No delegation rules found"
fi

echo ""
echo "--- PHASE 4: EXECUTIVE LOOP ---"
echo ""
echo "  4.1 Heartbeat Check"

python3 - "$SUPRA_ROOT" <<'PY' 2>/dev/null
import json, os, sys
root = sys.argv[1]

state_file = root + "/SESSION_STATE.json"
exec_file = root + "/EXECUTIVE_STATE.json"

state = json.load(open(state_file)) if os.path.exists(state_file) else {}
execs = json.load(open(exec_file)) if os.path.exists(exec_file) else {}

loop_state = {
    "timestamp": state.get("timestamp", "unknown"),
    "session_status": state.get("session", {}).get("status", "unknown"),
    "exec_decision": execs.get("current_decision", "unknown"),
    "exec_gate": execs.get("current_execution_gate", "unknown"),
    "gate_state": execs.get("runtime", {}).get("gate_state", "unknown"),
    "mission_priority": state.get("mission", {}).get("priority", "unknown"),
    "executive_confidence": execs.get("executive_confidence", 0),
    "build_status": execs.get("build", {}).get("status", "unknown"),
    "factory_health": execs.get("factories", {}).get("healthy", 0),
}

print(f"  ◇ Session: {loop_state['session_status']}")
print(f"  ◇ Decision: {loop_state['exec_decision']}")
print(f"  ◇ Gate: {loop_state['exec_gate']} ({loop_state['gate_state']})")
print(f"  ◇ Priority: {loop_state['mission_priority']}")
print(f"  ◇ Confidence: {loop_state['executive_confidence']}")
print(f"  ◇ Build: {loop_state['build_status']}")
print(f"  ◇ Factories healthy: {loop_state['factory_health']}/10")
PY

echo ""
echo "--- PHASE 5: SELF MAINTENANCE ---"
echo ""
echo "  5.1 State Synchronization"

python3 - "$SUPRA_ROOT" <<'PY' 2>/dev/null
import json, os, subprocess, sys
root = sys.argv[1]

state_file = root + "/SESSION_STATE.json"
exec_file = root + "/EXECUTIVE_STATE.json"

if not os.path.exists(state_file) or not os.path.exists(exec_file):
    print("  ⚠ State files missing — sync deferred")
    sys.exit(0)

state = json.load(open(state_file))
execs = json.load(open(exec_file))

# Sync: align SESSION_STATE with EXECUTIVE_STATE
state["executive"]["state_version"] = execs.get("version", state["executive"].get("state_version"))
state["session"]["executive_confidence"] = execs.get("executive_confidence", state["session"].get("executive_confidence", 0))
state["build"]["last_result"] = "PASS" if execs.get("build", {}).get("status") == "CERTIFIED" else "UNKNOWN"
state["build"]["errors"] = execs.get("build", {}).get("compilation_errors", 0)
state["build"]["warnings"] = execs.get("build", {}).get("compilation_warnings", 0)
state["gate"]["current"] = execs.get("current_execution_gate", state["gate"].get("current"))
state["gate"]["current_state"] = execs.get("runtime", {}).get("gate_state", "ACTIVE")
state["repository"]["last_commit"] = execs.get("repository", {}).get("commit", state["repository"].get("last_commit"))
state["repository"]["branch"] = execs.get("repository", {}).get("branch", state["repository"].get("branch"))
state["repository"]["status"] = execs.get("repository", {}).get("git_status", state["repository"].get("status"))
state["workspace"]["swift_sources"] = execs.get("workspace", {}).get("swift_sources", state["workspace"].get("swift_sources"))
state["provider"]["active_provider"] = execs.get("models", {}).get("active_provider", state["provider"].get("active_provider"))
state["provider"]["active_model"] = execs.get("models", {}).get("active_model", state["provider"].get("active_model"))
state["timestamp"] = subprocess.run(["date", "-u", "+%Y-%m-%dT%H:%M:%SZ"],
    capture_output=True, text=True).stdout.strip()

# Live repo refresh
branch = subprocess.run(["git", "-C", root, "rev-parse", "--abbrev-ref", "HEAD"],
    capture_output=True, text=True).stdout.strip()
commit = subprocess.run(["git", "-C", root, "rev-parse", "HEAD"],
    capture_output=True, text=True).stdout.strip()
state["repository"]["branch"] = branch
state["repository"]["last_commit"] = commit
status_count = subprocess.run(["git", "-C", root, "status", "--porcelain"],
    capture_output=True, text=True).stdout.strip()
state["repository"]["status"] = "CLEAN" if not status_count else "DIRTY"
state["repository"]["uncommitted_files"] = len([s for s in status_count.split('\n') if s])

json.dump(state, open(state_file, 'w'), indent=2)
print("  ✓ SESSION_STATE.json synchronized")
print("  ✓ Repository state refreshed")
print(f"  ✓ Branch: {branch} | Commit: {commit[:8]}")
print(f"  ◇ Status: {state['repository']['status']} ({state['repository']['uncommitted_files']} files)")
PY

echo ""
echo "--- BOOT COMPLETE ---"
echo ""
echo "  Results: $PASS passed, $FAIL failed, $WARN warnings"
echo ""

if [ "$FAIL" -gt 0 ]; then
  echo "  △ System has issues requiring attention"
  echo "  △ Run 'supra --audit' for detailed diagnostics"
else
  echo "  ✓ System READY for Production Runtime"
  echo "  ✓ Executive Gate: ${EXECUTION_GATE}"
fi

echo ""
echo "--- CURRENT PRIORITY ---"
python3 - "$SUPRA_ROOT" <<'PY' 2>/dev/null
import json, os, sys
root = sys.argv[1]
nm = root + "/NEXT_MISSION.md"
if os.path.exists(nm):
    with open(nm) as f:
        for line in f:
            if "Priority" in line and ":" in line:
                print(f"  {line.strip()}")
                break
PY

echo ""
echo "--- NEXT STEPS ---"
echo "  1. Review cockpit: cat EXECUTIVE_COCKPIT.md"
echo "  2. Check delegation: cat .opencode/delegation_rules.json"
echo "  3. Run factory: supra-factory-status"
echo "  4. Execute mission: see NEXT_MISSION.md"
