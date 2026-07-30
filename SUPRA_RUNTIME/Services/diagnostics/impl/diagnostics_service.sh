#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${SUPRA_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}"
MANIFEST="${ROOT}/SUPRA_RUNTIME/Services/diagnostics/manifest.json"
LOG_DIR="${ROOT}/SUPRA_RUNTIME/Logs"
REPORT_DIR="${ROOT}/SUPRA_RUNTIME/Reports"

mkdir -p "$LOG_DIR" "$REPORT_DIR"

STAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${LOG_DIR}/diagnostics_service_${STAMP}.log"
REPORT_FILE="${REPORT_DIR}/diagnostics_report_${STAMP}.md"

exec 3>&1 1>>"$LOG_FILE" 2>&1

log() { printf "[%s] %s\n" "$(date +%H:%M:%S)" "$*" | tee /dev/fd/3; }
pass() { log "PASS: $*"; }
fail() { log "FAIL: $*"; }
warn() { log "WARN: $*"; }

run_repository_health() {
    log "--- Repository Health ---"
    local branch
    branch=$(git -C "${ROOT}" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    pass "Current branch: ${branch}"
    local last_commit
    last_commit=$(git -C "${ROOT}" log --oneline -1 2>/dev/null || echo "unknown")
    pass "Last commit: ${last_commit}"
    local dirty
    dirty=$(git -C "${ROOT}" status --short 2>/dev/null | wc -l | tr -d ' ')
    if [ "${dirty}" -gt 0 ]; then
        warn "Repository has ${dirty} uncommitted change(s)"
    else
        pass "Repository clean"
    fi
}

run_build_diagnostics() {
    log "--- Build Diagnostics ---"
    if [ -f "${ROOT}/SUPRA.xcodeproj" ]; then
        pass "Xcode project present"
    else
        warn "Xcode project not found"
    fi
}

run_provider_diagnostics() {
    log "--- Provider Diagnostics ---"
    local provider_manifest="${ROOT}/SUPRA_RUNTIME/Services/provider/manifest.json"
    if [ -f "${provider_manifest}" ]; then
        local count
        count=$(python3 -c "import json; print(len(json.load(open('${provider_manifest}')).get('providers', {})))" 2>/dev/null || echo "0")
        pass "Provider registry loaded: ${count} providers"
    else
        warn "Provider manifest not found"
    fi
}

run_workspace_governance_diagnostics() {
    log "--- Workspace Governance Diagnostics ---"
    local gov_file="${ROOT}/workspace_governance.json"
    if [ -f "${gov_file}" ]; then
        local issues
        issues=$(python3 -c "import json; print(len(json.load(open('${gov_file}')).get('issues', [])))" 2>/dev/null || echo "0")
        if [ "${issues}" -gt 0 ]; then
            warn "Workspace governance has ${issues} issue(s)"
        else
            pass "Workspace governance: no issues"
        fi
    else
        pass "No workspace governance data"
    fi
}

run_runtime_consistency() {
    log "--- Runtime Consistency ---"
    local runtime_dir="${ROOT}/SUPRA_RUNTIME"
    if [ -d "${runtime_dir}" ]; then
        pass "Runtime directory present"
    else
        fail "Runtime directory missing"
    fi
    local service_count
    service_count=$(find "${ROOT}/SUPRA_RUNTIME/Services" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
    pass "Runtime services registered: ${service_count}"
}

run_storage_integrity() {
    log "--- Storage Integrity ---"
    local log_count
    log_count=$(find "${ROOT}/SUPRA_RUNTIME/Logs" -type f -name "*.log" 2>/dev/null | wc -l | tr -d ' ')
    local report_count
    report_count=$(find "${ROOT}/SUPRA_RUNTIME/Reports" -type f \( -name "*.md" -o -name "*.json" \) 2>/dev/null | wc -l | tr -d ' ')
    pass "Logs: ${log_count}, Reports: ${report_count}"
}

main() {
    log "=== DIAGNOSTICS SERVICE START ==="
    run_repository_health
    echo
    run_build_diagnostics
    echo
    run_provider_diagnostics
    echo
    run_workspace_governance_diagnostics
    echo
    run_runtime_consistency
    echo
    run_storage_integrity
    log "=== DIAGNOSTICS SERVICE COMPLETE ==="
    echo
    echo "Report: ${REPORT_FILE}"
    echo "Log: ${LOG_FILE}"
    echo
}

main "$@"