#!/usr/bin/env bash
set -euo pipefail

export OLLAMA_CONTEXT_LENGTH=65536
export OPENCODE_DEV_DEBUG=true

PROJECT="$HOME/Desktop/NOVA_OS/SUPRA_DEEPSEEK_EXIT_READINESS"

cd "$PROJECT"

rm -f .opencode/debug.log

echo "=============================="
echo "MODEL"
echo "=============================="

opencode debug config | grep -E '"model"|"small_model"'

echo
echo "=============================="
echo "START"
echo "=============================="

opencode . \
  --model OLLAMA_LOCAL/qwen3-coder \
  --auto

echo
echo "=============================="
echo "DEBUG LOG"
echo "=============================="

[ -f .opencode/debug.log ] && tail -200 .opencode/debug.log || echo "Pas de debug.log"
