#!/bin/bash
# FACTORY_01_ARCHITECTURE - INPUT Gate
set -euo pipefail

echo "[GATE] FACTORY_01_ARCHITECTURE - INPUT Gate"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../" && pwd)"

# Check repository is accessible
if [ ! -d "$REPO_ROOT/SUPRA" ]; then
  echo "[FAIL] SUPRA source directory not found at $REPO_ROOT/SUPRA"
  exit 1
fi

# Check Xcode project exists
if [ ! -f "$REPO_ROOT/SUPRA.xcodeproj/project.pbxproj" ]; then
  echo "[WARN] Xcode project not found (non-critical)"
fi

# Check Package.swift exists
if [ ! -f "$REPO_ROOT/SUPRA_AST_PLATFORM/Package.swift" ]; then
  echo "[WARN] AST Platform Package.swift not found (non-critical)"
fi

echo "[PASS] FACTORY_01_ARCHITECTURE - INPUT Gate PASSED"
exit 0
