#!/usr/bin/env bash
set -Eeuo pipefail

echo "=================================================="
echo "        SUPRA INSTALLER V1"
echo "=================================================="

ROOT="${HOME}/Desktop/NOVA_OS/SUPRA"
CFG="${HOME}/.config/opencode"
CFG_FILE="${CFG}/opencode.json"

mkdir -p "$CFG"

echo
echo "[1/10] Vérification Ollama"

command -v ollama >/dev/null || {
    echo "ERREUR : Ollama n'est pas installé."
    exit 1
}

if ! pgrep -x ollama >/dev/null 2>&1 ; then
    echo "→ Démarrage Ollama..."
    ollama serve >/dev/null 2>&1 &
    sleep 3
fi

echo
echo "[2/10] Vérification OpenCode"

command -v opencode >/dev/null || {
    echo "ERREUR : OpenCode n'est pas installé."
    exit 1
}

echo
echo "[3/10] Détection des modèles"

MODEL="$(ollama list | awk 'NR==2{print $1}')"

if [ -z "${MODEL:-}" ]; then
    echo "Aucun modèle trouvé."
    echo "Installation de qwen3:4b..."
    ollama pull qwen3:4b
    MODEL="qwen3:4b"
fi

echo "Modèle détecté : $MODEL"

echo
echo "[4/10] Génération configuration OpenCode"

cat > "$CFG_FILE" <<EOF
{
  "\$schema":"https://opencode.ai/config.json",
  "provider":{
    "OLLAMA_LOCAL":{
      "npm":"@ai-sdk/openai-compatible",
      "name":"Ollama Local",
      "options":{
        "baseURL":"http://127.0.0.1:11434/v1"
      },
      "models":{
        "$MODEL":{
          "name":"$MODEL"
        }
      }
    }
  },
  "model":"OLLAMA_LOCAL/$MODEL"
}
EOF

echo
echo "[5/10] Vérification configuration"

cat "$CFG_FILE"

echo
echo "[6/10] Vérification endpoint"

curl -fs http://127.0.0.1:11434/v1/models >/dev/null || {
    echo "Impossible de joindre Ollama."
    exit 1
}

echo
 echo "[8/10] Création arborescence"

mkdir -p "$ROOT"/Missions "$ROOT"/Reports "$ROOT"/Evidence "$ROOT"/Logs "$ROOT"/Freeze "$ROOT"/Inbox "$ROOT"/Outbox

echo
echo "[8/10] Test OpenCode"

opencode models >/dev/null 2>&1 || true

echo
echo "[9/10] Informations"

echo "Configuration : $CFG_FILE"
echo "Projet       : $ROOT"

echo
echo "[10/10] INSTALLATION OK"

echo
echo "Provider : OLLAMA_LOCAL"
echo "Model    : $MODEL"

echo
echo "Prochaine étape :"
echo "./GO_SUPRA.sh"

