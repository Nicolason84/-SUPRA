#!/usr/bin/env bash
set -Eeuo pipefail

SUPRA_ROOT="${SUPRA_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
RUNTIME_DIR="${SUPRA_ROOT}/SUPRA_RUNTIME"
SERVICES_DIR="${RUNTIME_DIR}/Services"
REGISTRY="${RUNTIME_DIR}/services.json"
LOG_DIR="${RUNTIME_DIR}/Logs"
REPORT_DIR="${RUNTIME_DIR}/Reports"
RUNNING_DIR="${RUNTIME_DIR}/Running"
DONE_DIR="${RUNTIME_DIR}/Done"
BLOCKED_DIR="${RUNTIME_DIR}/Blocked"
INBOX_DIR="${RUNTIME_DIR}/Inbox"
OUTBOX_DIR="${RUNTIME_DIR}/Outbox"

mkdir -p "$LOG_DIR" "$REPORT_DIR" "$RUNNING_DIR" "$DONE_DIR" "$BLOCKED_DIR" "$INBOX_DIR" "$OUTBOX_DIR"

STAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${LOG_DIR}/orchestrator_${STAMP}.log"
REPORT_FILE="${REPORT_DIR}/orchestrator_report_${STAMP}.md"

exec 3>&1 1>>"$LOG_FILE" 2>&1

log() { printf "[%s] %s\n" "$(date +%H:%M:%S)" "$*" | tee /dev/fd/3; }
pass() { log "PASS: $*"; }
fail() { log "FAIL: $*"; }
warn() { log "WARN: $*"; }

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

run_service_dependency_order() {
    log "=== Running Services in Dependency Order ==="
    local order="workspace storage provider build diagnostics health snapshot recovery governance"
    for svc in ${order}; do
        run_service "${svc}"
        echo
    done
}

main() {
    log "=== SUPRA RUNTIME ORCHESTRATOR ==="
    log "  SUPRA Root: ${SUPRA_ROOT}"
    log "  Runtime Dir: ${RUNTIME_DIR}"
    log "  Registry: ${REGISTRY}"
    echo
    validate_registry
    echo
    list_services
    echo
    case "${1:-all}" in
        all)
            run_all_services
            ;;
        ordered)
            run_service_dependency_order
            ;;
        *)
            run_service "${1}"
            ;;
    esac
    log "=== ORCHESTRATOR COMPLETE ==="
    echo
    echo "Report: ${REPORT_FILE}" echo "Log: ${LOG_FILE}" echo
}

main "$@"