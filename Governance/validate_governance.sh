#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

REPORT_DIR="Governance/reports"
REPORT="$REPORT_DIR/LOT0_GOVERNANCE_REPORT.md"
mkdir -p "$REPORT_DIR"

pass=0
warn=0
fail=0
pass_check() { printf 'PASS  %s\n' "$1"; pass=$((pass + 1)); }
warn_check() { printf 'WARN  %s\n' "$1"; warn=$((warn + 1)); }
fail_check() { printf 'FAIL  %s\n' "$1"; fail=$((fail + 1)); }

require_file() {
    if [[ -f "$1" ]]; then pass_check "file present: $1"; else fail_check "file missing: $1"; fi
}

require_json() {
    if jq empty "$1" >/dev/null 2>&1; then pass_check "valid JSON: $1"; else fail_check "invalid JSON: $1"; fi
}

require_file "docs/SUPRA_EXECUTIVE_OS_CONSTITUTION_V1.md"
require_file "docs/SUPRA_EXECUTIVE_OS_GOVERNANCE.md"
require_file "CONTINUITY.md"
require_file "FREEZE_V1.md"

for registry in \
    Governance/constitution_registry.json \
    Governance/authority_registry.json \
    Governance/capability_registry.json \
    Governance/adr_registry.json \
    Governance/fitness_functions.json \
    Governance/quality_gates.json
do
    require_json "$registry"
done

root_declarations="$(rg -n '^(@MainActor[[:space:]]+)?(final[[:space:]]+)?class[[:space:]]+SUPRACompositionRoot\b' SUPRA --glob '*.swift' || true)"
root_count="$(printf '%s\n' "$root_declarations" | sed '/^$/d' | wc -l | tr -d ' ')"
if [[ "$root_count" == "1" ]]; then pass_check "single CompositionRoot declaration"; else fail_check "expected one CompositionRoot declaration, found $root_count"; fi

active_main_count="$(rg -n '^\s*@main\b' SUPRA --glob '*.swift' | wc -l | tr -d ' ')"
if [[ "$active_main_count" == "1" ]]; then pass_check "single active @main entry point"; else fail_check "expected one active @main, found $active_main_count"; fi

for expression in \
    'MissionStore\(\)' \
    'DecisionStore\(\)' \
    '(^|[^[:alnum:]_])RuntimeMonitor[[:space:]]*\(' \
    '(^|[^[:alnum:]_])RuntimeDataService[[:space:]]*\(' \
    '(^|[^[:alnum:]_])SUPRACompositionRoot[[:space:]]*\('
do
    matches="$(rg -n "$expression" SUPRA --glob '*.swift' || true)"
    invalid="$(printf '%s\n' "$matches" | rg -v 'SUPRACompositionRoot.swift|RuntimeDataService.swift:6:' || true)"
    if [[ -z "$invalid" ]]; then pass_check "canonical construction: $expression"; else fail_check "non-canonical construction: $invalid"; fi
done

prohibited='(WorkerDispatcher|BuildManager|TestManager|MemoryManager|ResourceManager|CapabilityGraph|EnvironmentTwin)'
parallel="$(rg -n "(class|struct|actor|enum)[[:space:]]+$prohibited\b" SUPRA Governance --glob '*.swift' --glob '*.json' || true)"
if [[ -z "$parallel" ]]; then pass_check "no prohibited parallel governance/runtime declarations"; else fail_check "prohibited declaration detected: $parallel"; fi

authority_sources="$(jq -r '.authorities[].source' Governance/authority_registry.json)"
while IFS= read -r source; do
    [[ -z "$source" ]] && continue
    require_file "$source"
done <<< "$authority_sources"

adr_docs="$(jq -r '.records[].document' Governance/adr_registry.json)"
while IFS= read -r document; do
    [[ -z "$document" ]] && continue
    require_file "$document"
done <<< "$adr_docs"

{
    echo "# SUPRA Governance Foundation — LOT 0 Report"
    echo
    echo "Date: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    echo "Mode: READ-ONLY STATIC GOVERNANCE VALIDATION"
    echo
    echo "## Constitution"
    echo
    echo "- Registry: Governance/constitution_registry.json"
    echo "- Version: $(jq -r '.version' Governance/constitution_registry.json)"
    echo "- Status: $(jq -r '.status' Governance/constitution_registry.json)"
    echo
    echo "## Fitness functions"
    echo
    jq -r '.functions[] | "- \(.id) — \(.name) [\(.severity)]"' Governance/fitness_functions.json
    echo
    echo "## Gate results"
    echo
    echo "- PASS: $pass"
    echo "- WARN: $warn"
    echo "- FAIL: $fail"
    echo
    if [[ "$fail" == "0" ]]; then
        echo "## Verdict"
        echo
        echo "GOVERNANCE FOUNDATION PASS — no blocking constitutional violation detected."
        echo "Runtime, build, test, smoke and freeze execution gates remain deferred for LOT 0."
    else
        echo "## Verdict"
        echo
        echo "GOVERNANCE FOUNDATION REFUSED — blocking violation(s) detected."
    fi
    echo
    echo "## Governance inventory"
    echo
    echo "- Authorities assessed: $(jq '.authorities | length' Governance/authority_registry.json)"
    echo "- Capabilities catalogued: $(jq '.capabilities | length' Governance/capability_registry.json)"
    echo "- ADR records linked: $(jq '.records | length' Governance/adr_registry.json)"
    echo "- Fitness functions evaluated: $(jq '.functions | length' Governance/fitness_functions.json)"
    echo
    echo "## Violations and risks"
    echo
    if [[ "$fail" == "0" ]]; then
        echo "- Violations: none detected by the static LOT 0 engine."
    else
        echo "- Violations: see FAIL lines above."
    fi
    echo "- Residual risk: runtime execution gates are intentionally deferred because LOT 0 is governance-only."
    echo
    echo "## Decisions and impact"
    echo
    echo "- Decision: reuse existing constitutional documents and canonical registries."
    echo "- Decision: expose a read-only validation command before future implementation lots."
    echo "- Impact: no business component, runtime pipeline, scheduler, store, or protected freeze was modified."
    echo "- Technical debt: existing registry fragmentation remains recorded for later consolidation."
    echo
    echo "## Traceability"
    echo
    echo "- ADR registry: Governance/adr_registry.json"
    echo "- Authorities: Governance/authority_registry.json"
    echo "- Capabilities: Governance/capability_registry.json"
    echo "- Recommendations: run this validator as the first gate of every future LOT."
} > "$REPORT"

cat "$REPORT"
if [[ "$fail" != "0" ]]; then exit 1; fi
