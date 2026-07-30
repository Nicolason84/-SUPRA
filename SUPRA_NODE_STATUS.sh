#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${SUPRA_ROOT:-$(cd "$(dirname "$0")" && pwd)}"
NODE_ID="${SUPRA_NODE_ID:-supra-node-$(hostname | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9-')}"

echo "╔══════════════════════════════════════════╗"
echo "║  SUPRA NODE STATUS — ${NODE_ID}"
echo "╚══════════════════════════════════════════╝"
echo

# Node identity
if [ -f "${ROOT}/.kernel/runtime/node_identity.json" ]; then
    echo "[✓] Identité du nœud"
else
    echo "[!] Identité du nœud manquante"
fi

# Manifest
if [ -f "${ROOT}/.supra_node_manifest.json" ]; then
    local boot_version
    boot_version=$(grep -o '"bootstrap_version": "[^"]*"' "${ROOT}/.supra_node_manifest.json" | cut -d'"' -f4)
    echo "[✓] Manifest v${boot_version}"
fi

# Ollama
if command -v ollama >/dev/null 2>&1; then
    if pgrep -x ollama >/dev/null 2>&1; then
        local model_count
        model_count=$(ollama list 2>/dev/null | tail -n +2 | wc -l | tr -d ' ')
        echo "[✓] Ollama : ${model_count} modèle(s)"
    else
        echo "[!] Ollama : arrêté"
    fi
else
    echo "[!] Ollama : non installé"
fi

# OpenCode
if command -v opencode >/dev/null 2>&1; then
    echo "[✓] OpenCode : $(opencode --version 2>/dev/null || echo 'installé')"
else
    echo "[!] OpenCode : non installé"
fi

# Config
if [ -f "$HOME/.config/opencode/opencode.json" ]; then
    echo "[✓] Configuration OpenCode"
else
    echo "[!] Configuration OpenCode manquante"
fi

# Workspace
local dir_count
dir_count=$(find "$ROOT" -type d -not -path '*/\.*' -not -path '*/_SUPRA_BACKUPS/*' -not -path '*/node_modules/*' 2>/dev/null | wc -l | tr -d ' ')
echo "[✓] Workspace : ${dir_count} répertoires"

# Kernel
if [ -d "${ROOT}/.kernel" ]; then
    local kernel_dirs
    kernel_dirs=$(find "${ROOT}/.kernel" -type d | wc -l | tr -d ' ')
    echo "[✓] Kernel : ${kernel_dirs} répertoires"
else
    echo "[!] Kernel non initialisé"
fi

# Récents logs
if [ -d "${ROOT}/Logs" ]; then
    local log_count
    log_count=$(find "${ROOT}/Logs" -name 'bootstrap_*.log' | wc -l | tr -d ' ')
    echo "[✓] Logs : ${log_count} fichier(s)"
fi

echo
echo "╔══════════════════════════════════════════╗"
echo "║  Pour lancer SUPRA : ./GO_SUPRA.sh        "
echo "╚══════════════════════════════════════════╝"
