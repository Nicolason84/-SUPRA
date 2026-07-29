#!/usr/bin/env bash
set -Eeuo pipefail

############################################
# SUPRA SAFE START
# Compatible avec Ollama.app (macOS)
############################################

PROJECT="${PROJECT:-$HOME/NOVA_OS/SUPRA_DEEPSEEK_EXIT_READINESS}"
MODEL="${MODEL:-OLLAMA_LOCAL/qwen3-coder}"

echo
echo "==========================================="
echo " SUPRA SAFE START"
echo "==========================================="
echo

############################################
# 1. Fermer toutes les anciennes sessions OpenCode
############################################

echo "[1/5] Nettoyage OpenCode..."

pkill -TERM -x opencode 2>/dev/null || true
sleep 2
pkill -KILL -x opencode 2>/dev/null || true

############################################
# 2. Détection Ollama.app
############################################

echo
echo "[2/5] Vérification Ollama..."

if pgrep -x "Ollama" >/dev/null ; then
    echo "✓ Ollama.app détecté."
    echo "  -> aucun 'ollama serve' manuel ne sera lancé."
else
    echo "⚠ Ollama.app non lancé."
    echo "Ouverture de l'application..."

    open -a Ollama

    for i in {1..30}; do
        if pgrep -x "Ollama" >/dev/null; then
            break
        fi
        sleep 1
    done

    if ! pgrep -x "Ollama" >/dev/null; then
        echo "ERREUR : impossible de lancer Ollama.app"
        exit 1
    fi
fi

############################################
# 3. Attendre l'API
############################################

echo
echo "[3/5] Attente API Ollama..."

for i in {1..60}; do
    if curl -fsS http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
        echo "✓ API disponible."
        break
    fi
    sleep 1
done

if ! curl -fsS http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    echo
    echo "ERREUR : API Ollama indisponible."
    exit 1
fi

############################################
# 4. Vérification runner
############################################

echo
echo "[4/5] Vérification des runners..."

ollama ps

RUNNERS=$(ollama ps | awk 'NR>1 && NF>0 {c++} END{print c+0}')

echo
echo "Runner(s) chargé(s) : $RUNNERS"

############################################
# 5. Lancer OpenCode
############################################

echo
echo "[5/5] Lancement OpenCode..."

cd "$PROJECT"

exec opencode . \
    --model "$MODEL" \
    --log-level INFO

