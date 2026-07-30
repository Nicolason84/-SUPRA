#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${SUPRA_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}"
MANIFEST="${ROOT}/SUPRA_RUNTIME/Services/storage/manifest.json"
LOG_DIR="${ROOT}/SUPRA_RUNTIME/Logs"
REPORT_DIR="${ROOT}/SUPRA_RUNTIME/Reports"

mkdir -p "$LOG_DIR" "$REPORT_DIR"

STAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${LOG_DIR}/storage_service_${STAMP}.log"
REPORT_FILE="${REPORT_DIR}/storage_report_${STAMP}.md"

exec 3>&1 1>>"$LOG_FILE" 2>&1

log() { printf "[%s] %s\n" "$(date +%H:%M:%S)" "$*" | tee /dev/fd/3; }
pass() { log "PASS: $*"; }
fail() { log "FAIL: $*"; }
warn() { log "WARN: $*"; }

check_disk_space() {
    log "--- Disk Space ---"
    local avail_gb
    avail_gb=$(df -k / | awk 'NR==2 {print int($4/1024/1024)}')
    local threshold_warn
    threshold_warn=$(python3 -c "import json; print(json.load(open('${MANIFEST}'))['thresholds']['disk_warning_gb'])" 2>/dev/null || echo 10)
    local threshold_crit
    threshold_crit=$(python3 -c "import json; print(json.load(open('${MANIFEST}'))['thresholds']['disk_critical_gb'])" 2>/dev/null || echo 5)
    if [ "${avail_gb}" -lt "${threshold_crit}" ]; then
        fail "Disk space critical: ${avail_gb}GB available (threshold: ${threshold_crit}GB)"
    elif [ "${avail_gb}" -lt "${threshold_warn}" ]; then
        warn "Disk space low: ${avail_gb}GB available (threshold: ${threshold_warn}GB)"
    else
        pass "Disk space OK: ${avail_gb}GB available"
    fi
}

detect_duplicates() {
    log "--- Duplicate Detection ---"
    local size_threshold_mb
    size_threshold_mb=$(python3 -c "import json; print(json.load(open('${MANIFEST}'))['thresholds']['duplicate_size_threshold_mb'])" 2>/dev/null || echo 10)
    local dup_count
    dup_count=$(find "${ROOT}" -type f -size +"${size_threshold_mb}"m -not -path "*/.git/*" -not -path "*/DerivedData/*" -not -path "*/node_modules/*" -not -path "*/.build/*" -not -path "*/SUPRA_RUNTIME/*" 2>/dev/null | xargs -I{} md5 "{}" 2>/dev/null | sort | uniq -d -w32 2>/dev/null | wc -l | tr -d ' ')
    if [ "${dup_count}" -gt 0 ]; then
        warn "${dup_count} duplicate(s) detected above ${size_threshold_mb}MB"
    else
        pass "No duplicate files above ${size_threshold_mb}MB detected"
    fi
}

identify_regenerable_caches() {
    log "--- Regenerable Caches ---"
    local cache_dirs=(
        "${ROOT}/Artifacts/exports"
        "${ROOT}/Artifacts/diagnostics"
        "${ROOT}/.analysis"
    )
    local found=0
    for cache in "${cache_dirs[@]}"; do
        if [ -d "${cache}" ]; then
            local size
            size=$(du -sh "${cache}" 2>/dev/null | cut -f1 || echo "unknown")
            local file_count
            file_count=$(find "${cache}" -type f 2>/dev/null | wc -l | tr -d ' ')
            log "  Cache: ${cache} (${size}, ${file_count} files)"
            found=1
        fi
    done
    if [ "${found}" -eq 0 ]; then
        pass "No regenerable caches found"
    fi
}

check_log_sizes() {
    log "--- Log Size Check ---"
    local max_log_mb
    max_log_mb=$(python3 -c "import json; print(json.load(open('${MANIFEST}'))['thresholds']['max_log_size_mb'])" 2>/dev/null || echo 100)
    local oversized=0
    while IFS= read -r -d '' logfile; do
        local size_mb
        size_mb=$(du -m "${logfile}" 2>/dev/null | cut -f1 || echo 0)
        if [ "${size_mb}" -gt "${max_log_mb}" ]; then
            warn "Oversized log: ${logfile} (${size_mb}MB > ${max_log_mb}MB)"
            oversized=$((oversized + 1))
        fi
    done < <(find "${ROOT}/SUPRA_RUNTIME/Logs" -type f -name "*.log" -print0 2>/dev/null)
    if [ "${oversized}" -eq 0 ]; then
        pass "All logs within size threshold"
    fi
}

main() {
    log "=== STORAGE SERVICE START ==="
    check_disk_space
    echo
    detect_duplicates
    echo
    identify_regenerable_caches
    echo
    check_log_sizes
    log "=== STORAGE SERVICE COMPLETE ==="
    echo
    echo "Report: ${REPORT_FILE}"
    echo "Log: ${LOG_FILE}"
    echo
}

main "$@"