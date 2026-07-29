#!/usr/bin/env bash
set -euo pipefail

echo "========== VERSION =========="
opencode --version

echo
echo "========== DEBUG PATHS =========="
opencode debug paths || true

echo
echo "========== LOG DIRECTORY =========="
ls -lt ~/.local/share/opencode/log 2>/dev/null || echo "Aucun log"

echo
echo "========== ENV =========="
env | grep OPENCODE || true

echo
echo "========== START =========="
cd "$HOME/Desktop/NOVA_OS/SUPRA_DEEPSEEK_EXIT_READINESS"

opencode \
  --log-level DEBUG \
  --print-logs \
  --model OLLAMA_LOCAL/qwen3-coder
