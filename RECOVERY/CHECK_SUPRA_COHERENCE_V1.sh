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
check "Alonso full pyramid card exists" contains "SUPRA/SUPRAOJOHomeView.swift" 'private var alonsoPyramidCard: some View'
check "Alonso full pyramid is gated by global SUPRA selection" contains "SUPRA/SUPRAOJOHomeView.swift" 'if selection == .supra {'
check "Alonso uses canonical L1 foundation" contains "SUPRA/SUPRAOJOHomeView.swift" 'case 1: return "FOUNDATION"'
check "Alonso uses canonical L7 executive action" contains "SUPRA/SUPRAOJOHomeView.swift" 'case 7: return "EXECUTIVE ACTION"'
check "Alonso promotion floor 0.92 is explicit" contains "SUPRA/SUPRAOJOHomeView.swift" 'COHERENCE < 0.92 → REMEDIATION · NO AUTOMATIC PROMOTION'
check "Alonso fail descends one level" contains "SUPRA/SUPRAOJOHomeView.swift" 'FAIL → DESCEND_ONE_LEVEL'
check "Alonso old selection-tinted pseudo-status removed" not_contains "SUPRA/SUPRAOJOHomeView.swift" '.fill(levelTint(level))'
check "Missions map to executive action layer" contains "SUPRA/SUPRAOJOHomeView.swift" 'case .missions: return "L7 · EXECUTIVE ACTION / E2E"'
check "Alonso L4 anchors Puchero" contains "SUPRA/SUPRAOJOHomeView.swift" 'Puchero · CAnnoNico · SUPRA Memory V5'
check "Alonso L5 anchors Twin knowledge fabric" contains "SUPRA/SUPRAOJOHomeView.swift" 'Knowledge/Company/People/Market/Opportunity/Evidence Twins · Atlas'
check "Alonso L7 anchors Case and Decision Twins" contains "SUPRA/SUPRAOJOHomeView.swift" 'Case Twin · Decision Twin · Missions · Control · SUPRA'
check "CAnnoNico bridge reuses existing twin registry" contains "SUPRA/CAnnoNicoIntegrationBridge.swift" 'id: "twin.registry"'
check "CAnnoNico bridge reuses existing environment twin fabric" contains "SUPRA/CAnnoNicoIntegrationBridge.swift" 'id: "twin.environment.fabric"'
check "CAnnoNico bridge reuses existing Atlas" contains "SUPRA/CAnnoNicoIntegrationBridge.swift" 'id: "atlas.runtime"'
check "CAnnoNico bridge reuses total system file twin" contains "SUPRA/CAnnoNicoIntegrationBridge.swift" 'id: "twin.system.file"'
check "CAnnoNico source card uses live recovered counts" contains "SUPRA/ContentView.swift" 'cannonicoRecoveredReferences.count)/\(cannonicoIntegrationSnapshot.references.count) RECOVERED'
check "CAnnoNico source card has no hard-coded 3/3" not_contains "SUPRA/ContentView.swift" 'status: "3/3"'
check "Live Boards decision surface retained" contains "SUPRA/ContentView.swift" 'private struct SUPRADecisionInboxLiveView: View'
check "Live Boards system surface retained" contains "SUPRA/ContentView.swift" 'private struct SUPRASystemLiveView: View'
check "Live Boards shared action card retained" contains "SUPRA/ContentView.swift" 'private struct SUPRAActionCard: View'
check "SUPRA routes to executive control center" contains "SUPRA/SUPRAOJOHomeView.swift" 'case .supra:'
check "SUPRA route renders SupraControlCenterView" contains "SUPRA/SUPRAOJOHomeView.swift" 'SupraControlCenterView()'
check "Chat route renders SUPRAChatView" contains "SUPRA/SUPRAOJOHomeView.swift" 'SUPRAChatView()'
check "ojO route renders private authority surface" contains "SUPRA/SUPRAOJOHomeView.swift" 'OJOPrivateControlView()'
check "Runtime route renders process observatory" contains "SUPRA/SUPRAOJOHomeView.swift" 'SUPRAProcessObservatoryView()'
check "Missions route renders mission center" contains "SUPRA/SUPRAOJOHomeView.swift" 'MissionCenterView()'
check "Missions project latest executive objective receipt" contains "SUPRA/MissionStore.swift" 'loadLatestExecutiveObjective(from: runner)'
check "Executive objective precedes completed Grande Mission" contains "SUPRA/MissionStore.swift" 'missions = (executiveObjective.map { [$0] } ?? []) + [operational] + historical'
check "Mission Center auto-selects current mission" contains "SUPRA/MissionCenterView.swift" 'selectCurrentMissionIfNeeded()'
check "Grande Mission gate is scoped to system consolidation" contains "SUPRA/MissionDetailView.swift" 'mission.status == .blocked && mission.category == "System Consolidation"'
check "Control route renders decision inbox" contains "SUPRA/SUPRAOJOHomeView.swift" 'DecisionInboxView()'
check "SUPRA owns command semantics" contains "SUPRA/SupraControlCenterView.swift" 'dashboardSection("Command SUPRA"'
check "Chat is conversation workspace" contains "SUPRA/SUPRAChatView.swift" 'Text("Conversation workspace")'
check "ojO is authority surface" contains "SUPRA/OJOPrivateControlView.swift" 'Text("Private authority surface.")'
check "SUPRA uses shared workspace header" contains "SUPRA/SupraControlCenterView.swift" 'SUPRAWorkspaceHeader('
check "ojO uses shared card grammar" contains "SUPRA/OJOPrivateControlView.swift" '.supraCard('
check "no fake Evidence Explorer action" not_contains "SUPRA/SupraControlCenterView.swift" 'case evidenceExplorer'
check "no fake Capability Browser action" not_contains "SUPRA/SupraControlCenterView.swift" 'case capabilityBrowser'
check "SUPRA/Chat/ojO share canonical runtime route" bash -c 'grep -Fq "missionRunner.executeExecutiveObjective" SUPRA/SupraControlCenterView.swift && grep -Fq "private let runtime: SUPRAChatRuntimeAdapter" SUPRA/SUPRAGrandeMissionRunner.swift && grep -Fq "SUPRAChatRuntimeAdapter()" SUPRA/SUPRAChatView.swift && grep -Fq "SUPRAChatRuntimeAdapter()" SUPRA/OJOPrivateControlView.swift'
check "MacBook is canonical host" contains "SUPRA/SUPRAGrandeMissionRunner.swift" 'HOST_CANONICAL=MACBOOK'
check "channel recovery never uses open -n" not_contains "RECOVERY/RECOVER_EXISTING_SUPRA_CHANNEL_20260920.sh" 'open -n "$INSTALL"'
check "single-instance delegate enforced" contains "SUPRA/SUPRAApp.swift" '@NSApplicationDelegateAdaptor(SUPRASingleInstanceDelegate.self)'
check "Runtime uses shared live authority" contains "SUPRA/SUPRAProcessObservatoryView.swift" 'SUPRAProcessObservatoryStore.shared'
check "Executive uses shared live authority" contains "SUPRA/SupraControlCenterView.swift" 'SUPRAProcessObservatoryStore.shared'
check "Missions use shared live authority" contains "SUPRA/MissionStore.swift" 'SUPRAProcessObservatoryStore.shared'
check "ojO uses shared live authority" contains "SUPRA/OJOPrivateControlView.swift" 'SUPRAProcessObservatoryStore.shared'
check "Executive no longer derives runtime from legacy requiredCount" not_contains "SUPRA/SupraControlCenterView.swift" 'snapshot.availableCount == snapshot.requiredCount'


check "Runtime never hydrates dataless FileProvider receipts for observability" contains "SUPRA/SUPRAProcessObservatoryView.swift" "if file.isDataless {"
check "Runtime detects dataless receipts with metadata-only lstat" contains "SUPRA/SUPRAProcessObservatoryView.swift" 'lstat($0, &fileStat)'
check "Runtime prefers hydrated duplicate receipts" contains "SUPRA/SUPRAProcessObservatoryView.swift" "if candidateDataless != currentDataless"
check "Runtime labels metadata-only receipts truthfully" contains "SUPRA/SUPRAProcessObservatoryView.swift" "OUTBOX receipt present · cloud content not hydrated"
check "ojO exposes universal Media tab" contains "SUPRA/OJOPrivateControlView.swift" 'case media = "Media"'
check "ojO Media tab renders universal media surface" contains "SUPRA/OJOPrivateControlView.swift" 'SUPRAMediaUniversalView()'
check "Presence YouTube routes to ojO universal media" contains "SUPRA/PublicPresenceView.swift" 'Open ojO Universal Media'
check "Universal Media refuses silent canon writes" contains "SUPRA/SUPRAMediaUniversalView.swift" 'Do not write canon silently.'
check "Universal Media refuses invented media verification" contains "SUPRA/SUPRAMediaUniversalView.swift" 'Do not claim you watched, transcribed or verified media content unless runtime evidence proves it.'

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