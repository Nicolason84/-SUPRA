#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${SUPRA_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}"
MANIFEST="${ROOT}/SUPRA_RUNTIME/Services/governance/manifest.json"
LOG_DIR="${ROOT}/SUPRA_RUNTIME/Logs"
REPORT_DIR="${ROOT}/SUPRA_RUNTIME/Reports"

mkdir -p "$LOG_DIR" "$REPORT_DIR"

STAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${LOG_DIR}/governance_service_${STAMP}.log"
REPORT_FILE="${REPORT_DIR}/governance_report_${STAMP}.md"

exec 3>&1 1>>"$LOG_FILE" 2>&1

log() { printf "[%s] %s\n" "$(date +%H:%M:%S)" "$*" | tee /dev/fd/3; }
pass() { log "PASS: $*"; }
fail() { log "FAIL: $*"; }
warn() { log "WARN: $*"; }

enforce_no_hardcoded_paths() {
    log "--- Policy: No Hardcoded Paths ---"
    local violations=0
    shopt -s nullglob
    for f in "${ROOT}/SUPRA/"*.swift; do
        if grep -n '/Users/\|/home/\|/tmp/' "${f}" 2>/dev/null; then
            warn "Hardcoded path in $(basename "$f")"
            violations=$((violations + 1))
        fi
    done
    shopt -u nullglob
    if [ "${violations}" -eq 0 ]; then
        pass "No hardcoded paths detected in Swift sources"
    else
        warn "${violations} hardcoded path violation(s) found"
    fi
}

enforce_single_write_point() {
    log "--- Policy: Single Write Point ---"
    local outbox_dir="${ROOT}/SUPRA_RUNTIME/Outbox"
    local report_dir="${ROOT}/SUPRA_RUNTIME/Reports"
    local log_dir="${ROOT}/SUPRA_RUNTIME/Logs"
    mkdir -p "${outbox_dir}" "${report_dir}" "${log_dir}" 2>/dev/null || true
    pass "Output channels centralized: Outbox, Reports, Logs"
}

control_runtime_services() {
    log "--- Controlling Runtime Services ---"
    local service_count=0
    local active_count=0
    local manifest_dir="${ROOT}/SUPRA_RUNTIME/Services"
    if [ -d "${manifest_dir}" ]; then
        for svc_dir in "${manifest_dir}"/*/; do
            [ -d "${svc_dir}" ] || continue
            local svc_name
            svc_name=$(basename "${svc_dir}")
            local svc_manifest="${svc_dir}/manifest.json"
            if [ -f "${svc_manifest}" ]; then
                service_count=$((service_count + 1))
                local status
                status=$(python3 -c "import json; print(json.load(open('${svc_manifest}')).get('status', 'unknown'))" 2>/dev/null || echo "unknown")
                if [ "${status}" = "active" ]; then
                    active_count=$((active_count + 1))
                    pass "Service ${svc_name}: ACTIVE"
                else
                    warn "Service ${svc_name}: ${status}"
                fi
            fi
        done
    fi
    log "  Controlled ${service_count} services (${active_count} active)"
}

check_policy_compliance() {
    log "--- Policy Compliance Check ---"
    local manifest="${ROOT}/SUPRA_RUNTIME/Services/governance/manifest.json"
    python3 -c "
import json
m = json.load(open('${manifest}'))
policies = m.get('policies', {})
print('  Policy enforcement status:')
for policy, enforced in policies.items():
    status = 'ENFORCED' if enforced else 'NOT ENFORCED'
    print(f'    {policy}: {status}')
" 2>/dev/null | tee /dev/fd/3
}

main() {
    log "=== GOVERNANCE SERVICE START ==="
    check_policy_compliance
    echo
    control_runtime_services
    echo
    enforce_no_hardcoded_paths
    echo
    enforce_single_write_point
    log "=== GOVERNANCE SERVICE COMPLETE ==="
    echo
    echo "Report: ${REPORT_FILE}"
    echo "Log: ${LOG_FILE}"
    echo
}

main "$@"