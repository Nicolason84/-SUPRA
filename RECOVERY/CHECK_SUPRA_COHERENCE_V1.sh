#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PASS=0
TOTAL=0
FAILURES=()

check() {
  local name="$1"
  shift
  TOTAL=$((TOTAL + 1))
  if "$@" >/dev/null 2>&1; then
    PASS=$((PASS + 1))
    printf 'PASS %02d %s\n' "$TOTAL" "$name"
  else
    FAILURES+=("$name")
    printf 'FAIL %02d %s\n' "$TOTAL" "$name"
  fi
}

contains(){ grep -Fq "$2" "$1"; }
not_contains(){ ! grep -Fq "$2" "$1"; }
exists(){ test -f "$1"; }

check "shared UI primitives exist" exists "SUPRA/SUPRAUI.swift"
check "default universe is SUPRA" contains "SUPRA/SUPRAOJOHomeView.swift" '@State private var selection: SUPRAUniverse = .supra'
check "SUPRA routes to executive control center" contains "SUPRA/SUPRAOJOHomeView.swift" 'case .supra:'
check "SUPRA route renders SupraControlCenterView" contains "SUPRA/SUPRAOJOHomeView.swift" 'SupraControlCenterView()'
check "Chat route renders SUPRAChatView" contains "SUPRA/SUPRAOJOHomeView.swift" 'SUPRAChatView()'
check "ojO route renders private authority surface" contains "SUPRA/SUPRAOJOHomeView.swift" 'OJOPrivateControlView()'
check "Runtime route renders process observatory" contains "SUPRA/SUPRAOJOHomeView.swift" 'SUPRAProcessObservatoryView()'
check "Missions route renders mission center" contains "SUPRA/SUPRAOJOHomeView.swift" 'MissionCenterView()'
check "Control route renders decision inbox" contains "SUPRA/SUPRAOJOHomeView.swift" 'DecisionInboxView()'
check "SUPRA owns command semantics" contains "SUPRA/SupraControlCenterView.swift" 'dashboardSection("Command SUPRA"'
check "Chat is conversation workspace" contains "SUPRA/SUPRAChatView.swift" 'Text("Conversation workspace")'
check "ojO is authority surface" contains "SUPRA/OJOPrivateControlView.swift" 'Text("Private authority surface.")'
check "SUPRA uses shared workspace header" contains "SUPRA/SupraControlCenterView.swift" 'SUPRAWorkspaceHeader('
check "ojO uses shared card grammar" contains "SUPRA/OJOPrivateControlView.swift" '.supraCard('
check "no fake Evidence Explorer action" not_contains "SUPRA/SupraControlCenterView.swift" 'case evidenceExplorer'
check "no fake Capability Browser action" not_contains "SUPRA/SupraControlCenterView.swift" 'case capabilityBrowser'
check "SUPRA/Chat/ojO share runtime adapter" bash -c 'grep -Fq "SUPRAChatRuntimeAdapter()" SUPRA/SupraControlCenterView.swift && grep -Fq "SUPRAChatRuntimeAdapter()" SUPRA/SUPRAChatView.swift && grep -Fq "SUPRAChatRuntimeAdapter()" SUPRA/OJOPrivateControlView.swift'
check "MacBook is canonical host" contains "SUPRA/SUPRAGrandeMissionRunner.swift" 'HOST_CANONICAL=MACBOOK'
check "channel recovery never uses open -n" not_contains "RECOVERY/RECOVER_EXISTING_SUPRA_CHANNEL_20260920.sh" 'open -n "$INSTALL"'
check "single-instance delegate enforced" contains "SUPRA/SUPRAApp.swift" '@NSApplicationDelegateAdaptor(SUPRASingleInstanceDelegate.self)'

SCORE="$(python3 - "$PASS" "$TOTAL" <<'PY'
import sys
p,t=map(int,sys.argv[1:])
print(f"{p/t:.4f}")
PY
)"

printf '\nCOHERENCE_PASS=%s\n' "$PASS"
printf 'COHERENCE_TOTAL=%s\n' "$TOTAL"
printf 'COHERENCE_SCORE=%s\n' "$SCORE"
printf 'COHERENCE_TARGET=0.9500\n'

python3 - "$SCORE" <<'PY'
import sys
score=float(sys.argv[1])
raise SystemExit(0 if score >= 0.95 else 1)
PY

if [ "${#FAILURES[@]}" -gt 0 ]; then
  printf 'COHERENCE_GAPS=%s\n' "$(IFS=' | '; echo "${FAILURES[*]}")"
else
  printf 'COHERENCE_GAPS=NONE\n'
fi

printf 'STATUS=COHERENCE_GATE_PASS\n'
