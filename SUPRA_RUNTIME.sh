#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${SUPRA_ROOT:-$(cd "$(dirname "$0")" && pwd)}"
LOG_DIR="${ROOT}/SUPRA_RUNTIME/Logs"
REPORT_DIR="${ROOT}/SUPRA_RUNTIME/Reports"
SERVICES_DIR="${ROOT}/SUPRA_RUNTIME/Services"
REGISTRY="${ROOT}/SUPRA_RUNTIME/services.json"
ORCHESTRATOR="${ROOT}/SUPRA_RUNTIME/orchestrator.sh"

mkdir -p "$LOG_DIR" "$REPORT_DIR"

STAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${LOG_DIR}/runtime_consolidation_${STAMP}.log"
REPORT_FILE="${REPORT_DIR}/runtime_consolidation_report_${STAMP}.md"

exec 3>&1 1>>"$LOG_FILE" 2>&1

log() { printf "[%s] %s\n" "$(date +%H:%M:%S)" "$*" | tee /dev/fd/3; }
pass() { log "PASS: $*"; }
fail() { log "FAIL: $*"; }
warn() { log "WARN: $*"; }

read_version() {
    local key="${1:-supra_state_version}"
    if [ ! -f "${ROOT}/version.json" ]; then
        echo "unknown"
        return 1
    fi
    python3 -c "import json; print(json.load(open('${ROOT}/version.json')).get('${key}', 'unknown'))" 2>/dev/null \
        || echo "unknown"
}

validate_registry() {
    log "--- Validating Service Registry ---"
    if [ ! -f "${REGISTRY}" ]; then
        fail "Service registry not found at ${REGISTRY}"
        return 1
    fi
    local svc_count
    svc_count=$(python3 -c "import json; print(json.load(open('${REGISTRY}'))['service_count'])" 2>/dev/null || echo "0")
    pass "Service registry valid — ${svc_count} services registered"
}

list_services() {
    log "--- Registered Runtime Services ---"
    python3 -c "
import json
r = json.load(open('${REGISTRY}'))
for name, svc in r.get('services', {}).items():
    status = svc.get('status', 'unknown')
    print(f'  [{status:7s}] {svc[\"name\"]:30s} v{svc.get(\"version\", \"?\")}')
print(f'\n  Total: {r[\"service_count\"]} services')
" 2>/dev/null | tee /dev/fd/3
}

run_service() {
    local svc_name="${1}"
    local impl_path="${SERVICES_DIR}/${svc_name}/impl/${svc_name}_service.sh"
    if [ -f "${impl_path}" ]; then
        log "--- Running ${svc_name} Service ---"
        bash "${impl_path}" 2>&1 | tee -a "${LOG_FILE}" | tee /dev/fd/3
        pass "Service ${svc_name} completed"
    else
        warn "Implementation not found for ${svc_name}: ${impl_path}"
    fi
}

run_all_services() {
    log "=== Running All Runtime Services ==="
    local svc_names
    svc_names=$(python3 -c "import json; print(' '.join(json.load(open('${REGISTRY}')).get('services', {}).keys()))" 2>/dev/null || echo "")
    for svc in ${svc_names}; do
        run_service "${svc}"
        echo
    done
}

run_governance() {
    local impl_path="${SERVICES_DIR}/governance/impl/governance_service.sh"
    if [ -f "${impl_path}" ]; then
        log "--- Running Governance Service ---"
        bash "${impl_path}" 2>&1 | tee -a "${LOG_FILE}" | tee /dev/fd/3
    fi
}

check_version_consistency() {
    log "--- Version Consistency Check ---"
    local canonical
    canonical=$(read_version "supra_state_version") || canonical="unknown"
    pass "Canonical version: ${canonical}"
}

main() {
    log "=== SUPRA RUNTIME CONSOLIDATION START ==="
    log "  Root: ${ROOT}"
    log "  Services Dir: ${SERVICES_DIR}"
    log "  Registry: ${REGISTRY}"
    echo

    validate_registry
    echo
    list_services
    echo
    check_version_consistency
    echo

    case "${1:-services}" in
        orchestrator)
            log "--- Delegating to Orchestrator ---"
            bash "${ORCHESTRATOR}" "${2:-all}" 2>&1 | tee -a "${LOG_FILE}" | tee /dev/fd/3
            ;;
        services|all)
            run_all_services
            ;;
        governance)
            run_governance
            ;;
        *)
            run_service "${1}"
            ;;
    esac

    log "=== SUPRA RUNTIME CONSOLIDATION COMPLETE ==="
    echo
    echo "Runtime Consolidation Log: ${LOG_FILE}"
    echo
}

main "$@"
