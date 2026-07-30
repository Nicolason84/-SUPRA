#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${SUPRA_ROOT:-$(cd "$(dirname "$0")/../../../.." && pwd)}"
MANIFEST="${ROOT}/SUPRA_RUNTIME/Services/provider/manifest.json"
LOG_DIR="${ROOT}/SUPRA_RUNTIME/Logs"
REPORT_DIR="${ROOT}/SUPRA_RUNTIME/Reports"

mkdir -p "$LOG_DIR" "$REPORT_DIR"

STAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="${LOG_DIR}/provider_service_${STAMP}.log"
REPORT_FILE="${REPORT_DIR}/provider_report_${STAMP}.md"

exec 3>&1 1>>"$LOG_FILE" 2>&1

log() { printf "[%s] %s\n" "$(date +%H:%M:%S)" "$*" | tee /dev/fd/3; }
pass() { log "PASS: $*"; }
fail() { log "FAIL: $*"; }
warn() { log "WARN: $*"; }

inventory_providers() {
    log "--- Provider Inventory ---"
    python3 -c "
import json
m = json.load(open('${MANIFEST}'))
for name, cfg in m.get('providers', {}).items():
    status = 'AVAILABLE' if cfg.get('available') else 'UNAVAILABLE'
    models = ', '.join(cfg.get('models', [])) or 'none'
    cost = cfg.get('cost', 'unknown')
    print(f'  {name:20s} [{status}] cost={cost} models={models}')
" 2>/dev/null | tee /dev/fd/3
}

check_fallback_chain() {
    log "--- Fallback Chain ---"
    python3 -c "
import json
m = json.load(open('${MANIFEST}'))
providers = sorted(m.get('providers', {}).items(), key=lambda x: x[1].get('fallback_priority', 99))
for i, (name, cfg) in enumerate(providers, 1):
    status = 'PASS' if cfg.get('available') else 'UNAVAILABLE'
    print(f'  {i}. [{status}] {name} (priority={cfg.get(\"fallback_priority\", i)})')
" 2>/dev/null | tee /dev/fd/3
}

select_provider() {
    local context="${1:-general}"
    log "--- Provider Selection for: ${context} ---"
    python3 -c "
import json
m = json.load(open('${MANIFEST}'))
available = [(n, c) for n, c in m.get('providers', {}).items() if c.get('available')]
if not available:
    print('  No available providers')
else:
    selected = sorted(available, key=lambda x: x[1].get('fallback_priority', 99))[0]
    print(f'  SELECTED: {selected[0]}')
    print(f'  Capabilities: {\", \".join(selected[1].get(\"capabilities\", []))}')
    print(f'  Cost: {selected[1].get(\"cost\", \"unknown\")}')
" 2>/dev/null | tee /dev/fd/3
}

main() {
    log "=== PROVIDER SERVICE START ==="
    inventory_providers
    echo
    check_fallback_chain
    echo
    select_provider "${1:-general}"
    log "=== PROVIDER SERVICE COMPLETE ==="
    echo
    echo "Report: ${REPORT_FILE}"
    echo "Log: ${LOG_FILE}"
    echo
}

main "$@"