#!/usr/bin/env bash
set -euo pipefail

echo
echo "========================================"
echo " GO OPENCODE FIX STAGE 0"
echo "========================================"
echo

echo "[1] Version"
command -v opencode || true
opencode --version || true

echo
echo "[2] Debug disponible"
opencode debug --help || true

echo
echo "[3] Providers / modèles"
opencode models || true

echo
echo "[4] Configuration résolue"
opencode debug config || true

echo
echo "[5] Chemins"
opencode debug paths || true

echo
echo "[6] Skills"
opencode debug skill || true

echo
echo "[7] Base de données"
opencode db path || true

echo
echo "========================================"
echo "STAGE 0 TERMINÉ"
echo "========================================"
