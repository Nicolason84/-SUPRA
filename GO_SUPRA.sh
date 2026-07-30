#!/usr/bin/env bash
set -Eeuo pipefail

echo "====================================="
echo "        GO SUPRA"
echo "====================================="

ROOT="$HOME/Desktop/NOVA_OS/SUPRA"

cd "$ROOT"

echo "[1] Git"
git status --short || true

echo "[2] Ollama"

if ! pgrep -x ollama >/dev/null 2>&1; then
    echo "→ démarrage Ollama"
    ollama serve >/dev/null 2>&1 &
    sleep 3
fi

echo "[3] OpenCode"

opencode run \
    --dir "$ROOT" \
    --model ollama/qwen3:4b \
    --auto \
    "Analyse ce projet puis attends la prochaine mission."

echo
echo "SUPRA READY."
