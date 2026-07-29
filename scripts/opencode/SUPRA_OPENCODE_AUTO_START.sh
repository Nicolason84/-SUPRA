#!/usr/bin/env bash
set -Eeuo pipefail

MODEL="${MODEL:-OLLAMA_LOCAL/qwen3-coder}"

echo
echo "============================================================"
echo "          SUPRA • OPENCODE AUTO START"
echo "============================================================"
echo

############################################################
# 1. Fermer OpenCode
############################################################

echo "[1/6] Nettoyage OpenCode..."

pkill -TERM -x opencode 2>/dev/null || true
sleep 2
pkill -KILL -x opencode 2>/dev/null || true

############################################################
# 2. Vérifier Ollama.app
############################################################

echo
echo "[2/6] Vérification Ollama..."

if ! pgrep -x Ollama >/dev/null ; then
    echo "→ Lancement Ollama.app..."
    open -a Ollama

    for i in {1..30}; do
        pgrep -x Ollama >/dev/null && break
        sleep 1
    done
fi

pgrep -x Ollama >/dev/null || {
    echo "ERREUR : Ollama.app indisponible."
    exit 1
}

echo "✓ Ollama.app actif"

############################################################
# 3. Attendre l'API
############################################################

echo
echo "[3/6] Attente API Ollama..."

for i in {1..60}; do
    if curl -fsS http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
        echo "✓ API disponible"
        break
    fi
    sleep 1
done

curl -fsS http://127.0.0.1:11434/api/tags >/dev/null || {
    echo "ERREUR : API Ollama indisponible."
    exit 1
}

############################################################
# 4. Déterminer automatiquement le projet
############################################################

echo
echo "[4/6] Détection du projet..."

if git rev-parse --show-toplevel >/dev/null 2>&1; then
    PROJECT="$(git rev-parse --show-toplevel)"
else
    PROJECT="$(pwd)"
fi

echo "Projet :"
echo "  $PROJECT"

############################################################
# 5. Vérifications
############################################################

echo
echo "[5/6] Vérifications..."

command -v opencode >/dev/null || {
    echo "ERREUR : opencode introuvable."
    exit 1
}

echo
echo "Version OpenCode :"
opencode --version || true

echo
echo "Configuration active :"
opencode debug config | grep -E '"model"|"small_model"' || true

echo
echo "Runner(s) :"
ollama ps || true

############################################################
# 6. Lancement
############################################################

echo
echo "[6/6] Démarrage..."

echo
echo "Commande :"
echo "opencode --cwd \"$PROJECT\" --model \"$MODEL\""
echo

exec opencode \
    --cwd "$PROJECT" \
    --model "$MODEL" \
    --log-level DEBUG \
    --print-logs
