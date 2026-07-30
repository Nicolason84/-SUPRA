#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${SUPRA_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}"
MANIFEST="${ROOT}/SUPRA_RUNTIME/Services/workspace/manifest.json"
LOG_DIR="${ROOT}/SUPRA_RUNTIME/Logs"
REPORT_DIR="${ROOT}/SUPRA_RUNTIME/Reports"

mkdir -p "$LOG_DIR" "$REPORT_DIR"

STAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${LOG_DIR}/workspace_service_${STAMP}.log"
REPORT_FILE="${REPORT_DIR}/workspace_report_${STAMP}.md"

exec 3>&1 1>>"$LOG_FILE" 2>&1

log() { printf "[%s] %s\n" "$(date +%H:%M:%S)" "$*" | tee /dev/fd/3; }
pass() { log "PASS: $*"; }
fail() { log "FAIL: $*"; }
warn() { log "WARN: $*"; }

list_official_paths() {
    log "--- Official Workspace Paths ---"
    python3 -c "
import json, os
m = json.load(open('${MANIFEST}'))
for name, path in sorted(m.get('paths', {}).items()):
    full = '${ROOT}/' + path
    exists = 'EXISTS' if os.path.exists(full) else 'ABSENT'
    print(f'  {name:20s} {path:40s} [{exists}]')
" 2>/dev/null | tee /dev/fd/3
}

check_governance_boundary() {
    local target_path="${1}"
    local in_boundary=0
    python3 -c "
import json, sys
m = json.load(open('${MANIFEST}'))
target = '${target_path}'
for zone, paths in m.get('zones', {}).items():
    for pt in paths:
        if pt in target:
            sys.exit(0)
sys.exit(1)
" 2>/dev/null
    if [ $? -eq 0 ]; then
        pass "Path within governance boundary: ${target_path}"
    else
        warn "Write outside governance boundary: ${target_path}"
    fi
}

organize_artifacts() {
    log "--- Organizing Artifacts ---"
    local organized=0
    shopt -s nullglob
    local files=()
    for f in "${ROOT}/Artifacts/"*.md; do
        files+=("$f")
    done
    for f in "${ROOT}/Artifacts/"*.json; do
        files+=("$f")
    done
    shopt -u nullglob
    for f in "${files[@]}"; do
        local bname
        bname=$(basename "$f")
        local category="uncategorized"
        case "${bname}" in
            *_PROOF*) category="proofs" ;;
            *_REPORT*) category="reports" ;;
            *_AUDIT*) category="audits" ;;
            *_BUILD*) category="builds" ;;
            *_FREEZE*) category="freezes" ;;
            *_DIAG*) category="diagnostics" ;;
            *_METRICS*) category="metrics" ;;
            *_TRACE*) category="traces" ;;
            *_LOG*) category="logs" ;;
            *_CERT*) category="certificates" ;;
        esac
        local category_dir="${ROOT}/Artifacts/${category}"
        mkdir -p "$category_dir"
        if [ "$(dirname "$f")" != "$category_dir" ]; then
            mv "$f" "${category_dir}/${bname}" 2>/dev/null && organized=1 || true
        fi
    done
    if [ "${organized}" -eq 0 ]; then
        pass "No artifacts requiring reorganization"
    else
        pass "Artifacts organized by category"
    fi
}

main() {
    log "=== WORKSPACE SERVICE START ==="
    list_official_paths
    echo
    check_governance_boundary "${ROOT}/Artifacts"
    check_governance_boundary "${ROOT}/Inbox"
    check_governance_boundary "${ROOT}/Outbox"
    echo
    organize_artifacts
    log "=== WORKSPACE SERVICE COMPLETE ==="
    echo
    echo "Report: ${REPORT_FILE}"
    echo "Log: ${LOG_FILE}"
    echo
}

main "$@"