#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${SUPRA_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}"
MANIFEST="${ROOT}/SUPRA_RUNTIME/Services/recovery/manifest.json"
LOG_DIR="${ROOT}/SUPRA_RUNTIME/Logs"
REPORT_DIR="${ROOT}/SUPRA_RUNTIME/Reports"

mkdir -p "$LOG_DIR" "$REPORT_DIR"

STAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${LOG_DIR}/recovery_service_${STAMP}.log"
REPORT_FILE="${REPORT_DIR}/recovery_report_${STAMP}.md"

exec 3>&1 1>>"$LOG_FILE" 2>&1

log() { printf "[%s] %s\n" "$(date +%H:%M:%S)" "$*" | tee /dev/fd/3; }
pass() { log "PASS: $*"; }
fail() { log "FAIL: $*"; }
warn() { log "WARN: $*"; }

assess_recovery_need() {
    log "--- Recovery Assessment ---"
    local healthy=0
    local total=4

    if [ -d "${ROOT}/SUPRA_RUNTIME/Services" ]; then
        hpass() { healthy=$((healthy+1)); pass "$*"; }
    else
        fail "Runtime services directory missing"
    fi

    if [ -f "${ROOT}/SUPRA.xcodeproj" ]; then
        hpass "Xcode project present"
    else
        warn "Xcode project not found"
    fi

    if [ -f "${ROOT}/workspace_governance.json" ]; then
        local issues
        issues=$(python3 -c "import json; print(len(json.load(open('${ROOT}/workspace_governance.json')).get('issues', [])))" 2>/dev/null || echo "0")
        if [ "${issues}" -eq 0 ]; then
            hpass "Workspace governance clean"
        else
            warn "Workspace governance has ${issues} issues"
        fi
    else
        warn "No workspace governance data"
    fi

    local provider_manifest="${ROOT}/SUPRA_RUNTIME/Services/provider/manifest.json"
    if [ -f "${provider_manifest}" ]; then
        hpass "Provider registry present"
    else
        warn "Provider manifest missing"
    fi

    log "--- Recovery Assessment Summary ---"
    log "  Overall score: ${healthy}/${total}"
    if [ "${healthy}" -ge 3 ]; then
        pass "System is recoverable -- level 1 recovery sufficient if needed"
    elif [ "${healthy}" -ge 2 ]; then
        warn "System partially degraded -- level 2 recovery may be required"
    else
        fail "System critically degraded -- level 3+ recovery required"
    fi
}

list_recovery_procedures() {
    log "--- Recovery Procedures ---"
    python3 -c "
import json
m = json.load(open('${MANIFEST}'))
for level, desc in m.get('recovery_levels', {}).items():
    print(f'  {level}: {desc}')
" 2>/dev/null | tee /dev/fd/3
}

check_snapshot_availability() {
    log "--- Snapshot Availability for Recovery ---"
    local snap_count
    snap_count=$(find "${ROOT}/Freeze" -maxdepth 1 -name "SUPRA_SNAPSHOT_*" -type d 2>/dev/null | wc -l | tr -d ' ')
    if [ "${snap_count}" -gt 0 ]; then
        pass "Snapshots available for recovery: ${snap_count}"
        local latest
        latest=$(find "${ROOT}/Freeze" -maxdepth 1 -name "SUPRA_SNAPSHOT_*" -type d 2>/dev/null | sort | tail -1)
        log "  Latest snapshot: $(basename "${latest}")"
    else
        warn "No snapshots available -- recovery must use rebuild approach"
    fi
}

main() {
    log "=== RECOVERY SERVICE START ==="
    assess_recovery_need
    echo
    list_recovery_procedures
    echo
    check_snapshot_availability
    log "=== RECOVERY SERVICE COMPLETE ==="
    echo
    echo "Report: ${REPORT_FILE}"
    echo "Log: ${LOG_FILE}"
    echo
}

main "$@"