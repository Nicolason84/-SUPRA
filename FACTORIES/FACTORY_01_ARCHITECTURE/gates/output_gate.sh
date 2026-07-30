#!/bin/bash
# FACTORY_01_ARCHITECTURE - OUTPUT Gate
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FACTORY_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_DIR="$FACTORY_DIR/outputs"

echo "[GATE] FACTORY_01_ARCHITECTURE - OUTPUT Gate"

# Check required outputs exist
REQUIRED_FILES=(
  "ARCHITECTURE_MAP.md"
  "SYSTEM_TOPOLOGY.md"
  "EXECUTION_GRAPH.md"
  "DEPENDENCY_GRAPH.md"
)

for file in "${REQUIRED_FILES[@]}"; do
  if [ ! -f "$OUTPUT_DIR/$file" ]; then
    echo "[FAIL] Missing required output: $file"
    exit 1
  fi
done

echo "[PASS] FACTORY_01_ARCHITECTURE - All required outputs present"
exit 0
