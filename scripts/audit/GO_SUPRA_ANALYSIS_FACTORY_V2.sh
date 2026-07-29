#!/usr/bin/env bash

set -Eeuo pipefail
IFS=$'\n\t'

START_TIME=$(date +%s)

ROOT="$HOME/Desktop/NOVA_OS/SUPRA"

if [ ! -d "$ROOT" ]; then
    echo "ERROR: ROOT NOT FOUND: $ROOT"
    exit 1
fi

STAMP=$(date +"%Y%m%d_%H%M%S")
OUT="$ROOT/.analysis/$STAMP"

mkdir -p "$OUT"

LOG="$OUT/runtime.log"
touch "$LOG"

log() {
    printf "[%s] %s\n" "$(date +"%H:%M:%S")" "$1" | tee -a "$LOG"
}

section() {
    {
        echo
        echo "=================================================="
        echo "$1"
        echo "=================================================="
    } | tee -a "$LOG"
}

run_job() {
    local NAME="$1"
    shift

    (
        section "$NAME"
        "$@"
    ) > "$OUT/${NAME}.log" 2>&1
}

touch "$OUT/errors.txt"
touch "$OUT/warnings.txt"
touch "$OUT/report.md"

section "SUPRA ANALYSIS FACTORY V2"

log "ROOT   : $ROOT"
log "OUTPUT : $OUT"
log "HOST   : $(hostname)"
log "USER   : $(whoami)"
log "DATE   : $(date)"

SWIFT_VERSION="$(swift --version 2>/dev/null | head -1 || true)"
XCODE_VERSION="$(xcodebuild -version 2>/dev/null | tr '\n' ' ' || true)"

log "SWIFT  : $SWIFT_VERSION"
log "XCODE  : $XCODE_VERSION"

log "FRAMEWORK READY"

###############################################################################
# END OF BLOCK 1
###############################################################################
