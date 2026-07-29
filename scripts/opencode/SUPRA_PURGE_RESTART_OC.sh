#!/usr/bin/env bash
set -euo pipefail

echo "===== SUPRA OpenCode Clean Restart ====="

echo
echo "[1/7] Arrêt OpenCode..."
pkill -f opencode || true

echo "[2/7] Arrêt Ollama..."
pkill -f ollama || true

sleep 2

echo "[3/7] Purge cache OpenCode..."
rm -rf ~/.cache/opencode

echo "[4/7] Purge sessions temporaires..."
rm -rf ~/.local/share/opencode/project/*/storage/tmp 2>/dev/null || true

echo "[5/7] Redémarrage Ollama..."
nohup ollama serve >/tmp/ollama.log 2>&1 &
sleep 5

echo "[6/7] Vérification API..."
curl -fs http://127.0.0.1:11434/api/tags >/dev/null

echo "[7/7] Lancement OpenCode..."
cd ~/Desktop/NOVA_OS/SUPRA_DEEPSEEK_EXIT_READINESS

exec opencode
