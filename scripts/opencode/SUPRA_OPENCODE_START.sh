#!/usr/bin/env bash
set -Eeuo pipefail

MODEL="OLLAMA_LOCAL/qwen3-coder"

echo
echo "======================================================"
echo "        SUPRA • OPENCODE START"
echo "======================================================"

########################################
# Trouver la racine du dépôt courant
########################################

if git rev-parse --show-toplevel >/dev/null 2>&1; then
    PROJECT="$(git rev-parse --show-toplevel)"
else
    PROJECT="$(pwd)"
fi

echo
echo "Projet :"
echo "  $PROJECT"

########################################
# Vérifier Ollama
########################################

echo
echo "Attente API Ollama..."

until curl -fsS http://127.0.0.1:11434/api/tags >/dev/null 2>&1
do
    sleep 1
done

echo "✓ API disponible"

echo
echo "Configuration :"
opencode debug config | grep -E '"model"|"small_model"' || true

echo
echo "Lancement OpenCode..."
echo

cd "$PROJECT"

exec opencode . \
    --model "$MODEL" \
    --log-level DEBUG \
    --print-logs

