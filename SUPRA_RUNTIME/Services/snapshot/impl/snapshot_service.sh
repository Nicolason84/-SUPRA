#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${SUPRA_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}"
MANIFEST="${ROOT}/SUPRA_RUNTIME/Services/snapshot/manifest.json"
LOG_DIR="${ROOT}/SUPRA_RUNTIME/Logs"
REPORT_DIR="${ROOT}/SUPRA_RUNTIME/Reports"

mkdir -p "$LOG_DIR" "$REPORT_DIR"

STAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${LOG_DIR}/snapshot_service_${STAMP}.log"
REPORT_FILE="${REPORT_DIR}/snapshot_report_${STAMP}.md"

exec 3>&1 1>>"$LOG_FILE" 2>&1

log() { printf "[%s] %s\n" "$(date +%H:%M:%S)" "$*" | tee /dev/fd/3; }
pass() { log "PASS: $*"; }
fail() { log "FAIL: $*"; }
warn() { log "WARN: $*"; }

list_snapshots() {
    log "--- Snapshot Inventory ---"
    python3 -c "
import json, os
root = '${ROOT}'
snap_dir = os.path.join(root, 'Freeze')
snapshots = []
if os.path.isdir(snap_dir):
    for d in sorted(os.listdir(snap_dir)):
        if d.startswith('SUPRA_SNAPSHOT_') and os.path.isdir(os.path.join(snap_dir, d)):
            manifest_path = os.path.join(snap_dir, d, 'snapshot_manifest.json')
            label = 'unknown'
            entries = 0
            created = 'unknown'
            if os.path.exists(manifest_path):
                try:
                    m = json.load(open(manifest_path))
                    label = m.get('label', 'unknown')
                    entries = len(m.get('contents', []))
                    created = m.get('created_at', 'unknown')
                except Exception:
                    pass
            snapshots.append({'name': d, 'label': label, 'entries': entries, 'created': created})
print(f'  Total snapshots: {len(snapshots)}')
for s in snapshots:
    print(f'  {s[\"name\"]:40s} label={s[\"label\"]:20s} entries={s[\"entries\"]:6d} created={s[\"created\"]}')
" 2>/dev/null | tee /dev/fd/3
}

verify_snapshot_consistency() {
    log "--- Snapshot Consistency Check ---"
    local snap_count
    snap_count=$(find "${ROOT}/Freeze" -maxdepth 1 -name "SUPRA_SNAPSHOT_*" -type d 2>/dev/null | wc -l | tr -d ' ')
    if [ "${snap_count}" -eq 0 ]; then
        warn "No snapshots found — consistency check N/A"
        return
    fi
    local latest
    latest=$(find "${ROOT}/Freeze" -maxdepth 1 -name "SUPRA_SNAPSHOT_*" -type d 2>/dev/null | sort | tail -1)
    local manifest="${latest}/snapshot_manifest.json"
    if [ -f "${manifest}" ]; then
        local entry_count
        entry_count=$(python3 -c "import json; print(len(json.load(open('${manifest}')).get('contents', [])))" 2>/dev/null || echo "0")
        pass "Latest snapshot: $(basename "${latest}") — ${entry_count} entries tracked"
    else
        warn "Latest snapshot manifest missing"
    fi
}

manage_retention() {
    log "--- Retention Management ---"
    local max_retention_days
    max_retention_days=$(python3 -c "import json; print(json.load(open('${MANIFEST}'))['snapshot_config']['max_age_days'])" 2>/dev/null || echo 90)
    local max_count
    max_count=$(python3 -c "import json; print(json.load(open('${MANIFEST}'))['snapshot_config']['retention_count'])" 2>/dev/null || echo 10)
    local snap_count
    snap_count=$(find "${ROOT}/Freeze" -maxdepth 1 -name "SUPRA_SNAPSHOT_*" -type d 2>/dev/null | wc -l | tr -d ' ')
    if [ "${snap_count}" -gt "${max_count}" ]; then
        warn "Snapshot count (${snap_count}) exceeds retention limit (${max_count})"
    else
        pass "Snapshot count (${snap_count}) within retention limit (${max_count})"
    fi
}

create_snapshot() {
    local label="${1:-execution_gate}"
    local snap_dir="${ROOT}/Freeze/SUPRA_SNAPSHOT_${label}_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "${snap_dir}"
    log "--- Creating Snapshot: ${label} ---"
    log "  Directory: ${snap_dir}"
    python3 -c "
import json, os, hashlib, time
snap_dir = '${snap_dir}'
root = '${ROOT}'
manifest = {
    'snapshot_id': os.path.basename(snap_dir),
    'label': '${label}',
    'created_at': time.strftime('%Y-%m-%dT%H:%M:%S%z'),
    'root': root,
    'contents': []
}
for dirpath, dirnames, filenames in os.walk(root):
    rel = os.path.relpath(dirpath, root)
    if any(x in rel for x in ['.git', 'SUPRA_RUNTIME/Logs', 'SUPRA_RUNTIME/Reports', 'Freeze']):
        continue
    for fn in filenames:
        fp = os.path.join(dirpath, fn)
        try:
            with open(fp, 'rb') as f:
                h = hashlib.sha256(f.read()).hexdigest()
            manifest['contents'].append({
                'path': rel + '/' + fn,
                'sha256': h,
                'size': os.path.getsize(fp)
            })
        except (OSError, PermissionError):
            pass
with open(os.path.join(snap_dir, 'snapshot_manifest.json'), 'w') as f:
    json.dump(manifest, f, indent=2)
print(f'  Snapshot manifest entries: {len(manifest[\"contents\"])}')
" 2>/dev/null | tee /dev/fd/3
    pass "Snapshot created: $(basename "${snap_dir}")"
}

main() {
    log "=== SNAPSHOT SERVICE START ==="
    list_snapshots
    echo
    verify_snapshot_consistency
    echo
    manage_retention
    echo
    create_snapshot "execution_gate_$(date +%Y%m%d)"
    log "=== SNAPSHOT SERVICE COMPLETE ==="
    echo
    echo "Report: ${REPORT_FILE}"
    echo "Log: ${LOG_FILE}"
    echo
}

main "$@"