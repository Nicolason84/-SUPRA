#!/bin/bash
# SUPRA Executive Boot V1
# Single entry point for all SUPRA sessions.
set -euo pipefail

SUPRA_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REGISTRY="$SUPRA_ROOT/FACTORIES/FACTORY_REGISTRY.json"
NEXT_DECISION="$SUPRA_ROOT/FACTORIES/FACTORY_10_EXECUTIVE/outputs/NEXT_DECISION.md"
EXECUTIVE_REPORT="$SUPRA_ROOT/FACTORIES/FACTORY_10_EXECUTIVE/outputs/EXECUTIVE_REPORT.md"
AGENTS="$SUPRA_ROOT/AGENTS.md"
OPENCODE_JSON="$SUPRA_ROOT/opencode.json"

PASS=0
FAIL=0
WARN=0

check() {
  local name="$1" status="$2" detail="$3"
  case "$status" in
    PASS) PASS=$((PASS+1)); echo "  PASS  $name — $detail" ;;
    FAIL) FAIL=$((FAIL+1)); echo "  FAIL  $name — $detail" ;;
    WARN) WARN=$((WARN+1)); echo "  WARN  $name — $detail" ;;
  esac
}

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║          SUPRA EXECUTIVE BOOT V1                         ║"
echo "║          Autonomous Software Factory                     ║"
echo "╠══════════════════════════════════════════════════════════╣"
printf "║  %-57s ║\n" "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "╚══════════════════════════════════════════════════════════╝"

echo ""
echo "━━━ PHASE 1: GIT VERIFICATION ━━━"

if git -C "$SUPRA_ROOT" rev-parse --git-dir >/dev/null 2>&1; then
  BRANCH=$(git -C "$SUPRA_ROOT" branch --show-current 2>/dev/null || echo "detached")
  COMMIT=$(git -C "$SUPRA_ROOT" log --oneline -1 2>/dev/null || echo "unknown")
  DIRTY=$(git -C "$SUPRA_ROOT" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  check "Git Repository" PASS "branch=$BRANCH"
  if [ "$DIRTY" -gt 0 ]; then
    check "Git State" WARN "dirty ($DIRTY uncommitted files)"
  else
    check "Git State" PASS "clean"
  fi
  check "Current Commit" PASS "$COMMIT"
else
  check "Git Repository" FAIL "not a git repository"
fi

echo ""
echo "━━━ PHASE 2: FACTORY INTEGRITY ━━━"

if [ -f "$AGENTS" ]; then
  AGENTS_LINES=$(wc -l < "$AGENTS" | tr -d ' ')
  AGENTS_SIZE=$(wc -c < "$AGENTS" | tr -d ' ')
  if grep -q "Single Writer Rule" "$AGENTS" && grep -q "SUPRA-Builder" "$AGENTS"; then
    check "AGENTS.md" PASS "$AGENTS_LINES lines, $AGENTS_SIZE bytes"
  else
    check "AGENTS.md" FAIL "missing required sections"
  fi
else
  check "AGENTS.md" FAIL "not found"
fi

if [ -f "$OPENCODE_JSON" ]; then
  if python3 -c "import json; json.load(open('$OPENCODE_JSON'))" 2>/dev/null; then
    check "opencode.json" PASS "valid JSON"
  else
    check "opencode.json" FAIL "invalid JSON"
  fi
else
  check "opencode.json" FAIL "not found"
fi

if [ -f "$SUPRA_ROOT/FACTORIES/SUPRA_FACTORY_CONSTITUTION.md" ]; then
  check "Factory Constitution" PASS "present"
else
  check "Factory Constitution" FAIL "not found"
fi

echo ""
echo "━━━ PHASE 3: FACTORY REGISTRY ━━━"

if [ -f "$REGISTRY" ]; then
  if python3 -c "import json; d=json.load(open('$REGISTRY')); assert len(d['factories'])==10, 'expected 10 factories'" 2>/dev/null; then
    REG_VERSION=$(python3 -c "import json; print(json.load(open('$REGISTRY'))['registry']['version'])")
    check "Factory Registry" PASS "version=$REG_VERSION, 10 factories"
  else
    check "Factory Registry" FAIL "invalid or incomplete"
  fi
else
  check "Factory Registry" FAIL "not found"
fi

echo ""
echo "━━━ PHASE 4: FACTORY OUTPUTS ━━━"
for f in FACTORY_01_ARCHITECTURE FACTORY_02_DISCOVERY FACTORY_03_RUNTIME FACTORY_04_KNOWLEDGE FACTORY_05_MEMORY FACTORY_06_PROOF FACTORY_07_QUALITY FACTORY_08_DOCUMENTATION FACTORY_09_EXECUTION FACTORY_10_EXECUTIVE; do
  OUT_DIR="$SUPRA_ROOT/FACTORIES/$f/outputs"
  if [ -d "$OUT_DIR" ] && [ "$(ls -A "$OUT_DIR" 2>/dev/null)" ]; then
    COUNT=$(ls -1 "$OUT_DIR" 2>/dev/null | wc -l | tr -d ' ')
    check "$f outputs" PASS "$COUNT artefact(s)"
  else
    check "$f outputs" WARN "no outputs found"
  fi
done

echo ""
echo "━━━ PHASE 5: EXECUTIVE HEALTH ━━━"

if [ -f "$NEXT_DECISION" ]; then
  DECISION=$(grep "^## DECISION:" "$NEXT_DECISION" 2>/dev/null | sed 's/## DECISION: *//' || echo "unknown")
  CONFIDENCE=$(grep "Confidence" "$NEXT_DECISION" 2>/dev/null | grep -o '0\.[0-9]*' | head -1 || echo "unknown")
  if [ "$DECISION" = "CONTINUE" ]; then
    check "NEXT_DECISION.md" PASS "decision=$DECISION, confidence=$CONFIDENCE"
  else
    check "NEXT_DECISION.md" WARN "decision=$DECISION, confidence=$CONFIDENCE"
  fi
else
  check "NEXT_DECISION.md" FAIL "not found"
fi

if [ -f "$EXECUTIVE_REPORT" ]; then
  check "EXECUTIVE_REPORT.md" PASS "present"
else
  check "EXECUTIVE_REPORT.md" FAIL "not found"
fi

if [ -f "$REGISTRY" ]; then
  python3 -c "
import json
d = json.load(open('$REGISTRY'))
for f in d['factories']:
    h = f['health']
    status = 'PASS' if h['score'] >= 1.0 else ('WARN' if h['score'] >= 0.5 else 'FAIL')
    print(f\"{f['name']}|{status}|score={h['score']}|{f['status']}\")
" 2>/dev/null > /tmp/supra_factory_health.txt
  while IFS='|' read -r name status detail; do
    check "$name" "$status" "$detail"
  done < /tmp/supra_factory_health.txt
  rm -f /tmp/supra_factory_health.txt
fi

echo ""
echo "━━━ PHASE 6: WORKSPACE SELECTION ━━━"

if [ -d "$SUPRA_ROOT/SUPRA.xcodeproj" ]; then
  if [ -d "$SUPRA_ROOT/SUPRA.xcodeproj/project.xcworkspace" ]; then
    check "Xcode Workspace" PASS "SUPRA.xcodeproj/project.xcworkspace (canonical)"
  else
    check "Xcode Workspace" WARN "SUPRA.xcodeproj (no workspace)"
  fi
else
  check "Xcode Project" WARN "no .xcodeproj found"
fi

SWIFT_COUNT=$(find "$SUPRA_ROOT/SUPRA" -name "*.swift" -maxdepth 1 2>/dev/null | wc -l | tr -d ' ')
if [ "$SWIFT_COUNT" -gt 0 ]; then
  check "Swift Sources" PASS "$SWIFT_COUNT Swift files"
else
  check "Swift Sources" WARN "no Swift files in SUPRA/"
fi

if [ -d "$SUPRA_ROOT/DerivedData" ]; then
  check "Build Cache" PASS "DerivedData present"
else
  check "Build Cache" WARN "DerivedData not found (cold build)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  SUPRA EXECUTIVE DASHBOARD"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

BRANCH=$(git -C "$SUPRA_ROOT" branch --show-current 2>/dev/null || echo "detached")
COMMIT_SHORT=$(git -C "$SUPRA_ROOT" log --oneline -1 2>/dev/null || echo "unknown")
DECISION_VAL=$(grep "^## DECISION:" "$NEXT_DECISION" 2>/dev/null | sed 's/## DECISION: *//' || echo "UNKNOWN")
NEXT_MISSION_LINE=$(grep "^### Mission:" "$NEXT_DECISION" 2>/dev/null | sed 's/^### Mission: *//' || echo "unknown")

echo ""
printf "  %-25s %s\n" "Workspace:" "$SUPRA_ROOT"
printf "  %-25s %s\n" "Branch:" "$BRANCH"
printf "  %-25s %s\n" "Commit:" "$COMMIT_SHORT"
printf "  %-25s %s\n" "Executive Decision:" "$DECISION_VAL"
printf "  %-25s %s\n" "Next Mission:" "$NEXT_MISSION_LINE"

TOTAL_CHECKS=$((PASS + FAIL + WARN))
echo ""
printf "  %-25s %s\n" "Checks:" "$PASS/$TOTAL_CHECKS passed"

python3 -c "
import json
d = json.load(open('$REGISTRY'))
healthy = sum(1 for f in d['factories'] if f['health']['score'] >= 1.0)
degraded = sum(1 for f in d['factories'] if f['health']['score'] < 1.0 and f['health']['score'] >= 0.5)
failed = sum(1 for f in d['factories'] if f['health']['score'] < 0.5)
print(f'  {\"Factory Health:\":25} {healthy} healthy, {degraded} degraded, {failed} failed')
print(f'  {\"Certified:\":25} {d[\"system\"][\"certified\"]}/{d[\"system\"][\"total_factories\"]} factories')
"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "━━━ BUILD READINESS ━━━"

if [ "$FAIL" -gt 0 ]; then
  echo ""
  echo "  NOT READY — $FAIL check(s) failed"
  echo "  Resolve failures before building."
  echo ""
  exit 1
elif [ "$WARN" -gt 0 ]; then
  echo ""
  echo "  READY WITH WARNINGS — $WARN warning(s)"
  echo ""
else
  echo ""
  echo "  READY TO BUILD"
  echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Certified workspace: SUPRA.xcodeproj/project.xcworkspace"
echo "  Build command:"
echo "    xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -destination 'platform=macOS' build"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
