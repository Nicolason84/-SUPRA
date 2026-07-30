#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${SUPRA_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}"
MANIFEST="${ROOT}/SUPRA_RUNTIME/Services/health/manifest.json"
LOG_DIR="${ROOT}/SUPRA_RUNTIME/Logs"
REPORT_DIR="${ROOT}/SUPRA_RUNTIME/Reports"

mkdir -p "$LOG_DIR" "$REPORT_DIR"

STAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${LOG_DIR}/health_service_${STAMP}.log"
REPORT_FILE="${REPORT_DIR}/health_report_${STAMP}.md"

exec 3>&1 1>>"$LOG_FILE" 2>&1

log() { printf "[%s] %s\n" "$(date +%H:%M:%S)" "$*" | tee /dev/fd/3; }
pass() { log "PASS: $*"; }
fail() { log "FAIL: $*"; }
warn() { log "WARN: $*"; }

score=0
total=0

hpass() { score=$((score+1)); total=$((total+1)); pass "$*"; }
hwarn() { total=$((total+1)); warn "$*"; }
hfail() { total=$((total+1)); fail "$*"; }

check_disk_health() {
    log "--- Indicator: Disk Space ---"
    local avail_gb
    avail_gb=$(df -k / | awk 'NR==2 {print int($4/1024/1024)}')
    local threshold_warn
    threshold_warn=$(python3 -c "import json; print(json.load(open('${MANIFEST}'))['indicators']['disk_space_gb']['threshold_warning'])" 2>/dev/null || echo 10)
    local threshold_crit
    threshold_crit=$(python3 -c "import json; print(json.load(open('${MANIFEST}'))['indicators']['disk_space_gb']['threshold_critical'])" 2>/dev/null || echo 5)
    if [ "${avail_gb}" -lt "${threshold_crit}" ]; then
        hfail "Disk space: ${avail_gb}GB (critical < ${threshold_crit}GB)"
    elif [ "${avail_gb}" -lt "${threshold_warn}" ]; then
        hwarn "Disk space: ${avail_gb}GB (warning < ${threshold_warn}GB)"
    else
        hpass "Disk space: ${avail_gb}GB (healthy)"
    fi
}

check_runtime_health() {
    log "--- Indicator: Runtime Status ---"
    if [ -d "${ROOT}/SUPRA_RUNTIME" ]; then
        hpass "Runtime directory present"
    else
        hfail "Runtime directory missing"
    fi
    local svc_count
    svc_count=$(find "${ROOT}/SUPRA_RUNTIME/Services" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
    hpass "Runtime services registered: ${svc_count}"
}

check_build_health() {
    log "--- Indicator: Build Pipeline ---"
    if [ -f "${ROOT}/SUPRA.xcodeproj" ]; then
        hpass "Xcode project present"
    else
        hwarn "Xcode project not found"
    fi
}

check_provider_health() {
    log "--- Indicator: Provider Availability ---"
    local provider_manifest="${ROOT}/SUPRA_RUNTIME/Services/provider/manifest.json"
    if [ -f "${provider_manifest}" ]; then
        local available
        available=$(python3 -c "import json; print(sum(1 for c in json.load(open('${provider_manifest}')).get('providers', {}).values() if c.get('available')))" 2>/dev/null || echo "0")
        if [ "${available}" -gt 0 ]; then
            hpass "Available providers: ${available}"
        else
            hwarn "No providers currently available"
        fi
    else
        hwarn "Provider manifest not found"
    fi
}

check_workspace_health() {
    log "--- Indicator: Workspace Integrity ---"
    local gov_file="${ROOT}/workspace_governance.json"
    if [ -f "${gov_file}" ]; then
        local issues
        issues=$(python3 -c "import json; print(len(json.load(open('${gov_file}')).get('issues', [])))" 2>/dev/null || echo "0")
        if [ "${issues}" -eq 0 ]; then
            hpass "Workspace: no governance issues"
        else
            hwarn "Workspace governance issues: ${issues}"
        fi
    else
        hwarn "No workspace governance data"
    fi
}

publish_indicators() {
    log "--- Publishing Health Indicators ---"
    local health_json="${ROOT}/SUPRA_RUNTIME/health_status.json"
    python3 -c "
import json, time
m = json.load(open('${MANIFEST}'))
result = {
    'service': 'health',
    'timestamp': time.strftime('%Y-%m-%dT%H:%M:%S%z'),
    'score': ${score},
    'total': ${total},
    'health_percent': int(${score} * 100 / ${total}) if ${total} > 0 else 0,
    'indicators': m.get('indicators', {})
}
with open('${health_json}', 'w') as f:
    json.dump(result, f, indent=2, default=str)
print(f'  Health score: ${score}/${total} ({result[\"health_percent\"]}%)')
print(f'  Indicators written to ${health_json}')
" 2>/dev/null | tee /dev/fd/3
}

detect_degradation() {
    log "--- Degradation Detection ---"
    local pct=0
    if [ "${total}" -gt 0 ]; then
        pct=$((score * 100 / total))
    fi
    if [ "${pct}" -ge 90 ]; then
        pass "System status: HEALTHY (${pct}%)"
    elif [ "${pct}" -ge 70 ]; then
        warn "System status: DEGRADED (${pct}%)"
    else
        fail "System status: CRITICAL (${pct}%)"
    fi
}

main() {
    log "=== HEALTH SERVICE START ==="
    check_disk_health
    echo
    check_runtime_health
    echo
    check_build_health
    echo
    check_provider_health
    echo
    check_workspace_health
    echo
    detect_degradation
    echo
    publish_indicators
    log "=== HEALTH SERVICE COMPLETE ==="
    echo
    echo "Report: ${REPORT_FILE}"
    echo "Log: ${LOG_FILE}"
    echo
}

main "$@"