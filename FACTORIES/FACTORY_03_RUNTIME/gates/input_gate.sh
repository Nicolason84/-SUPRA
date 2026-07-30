#!/bin/bash
# FACTORY_03_RUNTIME - INPUT Gate
set -euo pipefail

echo "[GATE] FACTORY_03_RUNTIME - INPUT Gate"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../" && pwd)"

# Check FACTORY_01 outputs are certified
F01_OUTPUTS="$REPO_ROOT/FACTORIES/FACTORY_01_ARCHITECTURE/outputs"
if [ ! -f "$F01_OUTPUTS/ARCHITECTURE_MAP.md" ]; then
  echo "[WARN] FACTORY_01 outputs not available (will attempt build anyway)"
fi

# Check Xcode tools
if ! xcode-select -p &>/dev/null; then
  echo "[FAIL] Xcode command line tools not found"
  exit 1
fi

# Check Swift availability
if ! swift --version &>/dev/null; then
  echo "[FAIL] Swift not available"
  exit 1
fi

echo "[PASS] FACTORY_03_RUNTIME - INPUT Gate PASSED"
exit 0
