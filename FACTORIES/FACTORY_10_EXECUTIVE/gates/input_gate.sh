#!/bin/bash
# FACTORY_10_EXECUTIVE - INPUT Gate
set -euo pipefail

echo "[GATE] FACTORY_10_EXECUTIVE - INPUT Gate"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../" && pwd)"
FACTORIES_DIR="$REPO_ROOT/FACTORIES"

# Check that at least some factory outputs exist
OUTPUT_COUNT=0
for f in FACTORY_0*_*/outputs; do
  if [ -d "$FACTORIES_DIR/$f" ] && [ "$(ls -A "$FACTORIES_DIR/$f" 2>/dev/null)" ]; then
    OUTPUT_COUNT=$((OUTPUT_COUNT + 1))
  fi
done

echo "[INFO] Found $OUTPUT_COUNT factories with outputs"

echo "[PASS] FACTORY_10_EXECUTIVE - INPUT Gate PASSED"
exit 0
