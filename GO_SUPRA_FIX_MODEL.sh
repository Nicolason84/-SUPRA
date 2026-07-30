#!/usr/bin/env bash

set -Eeuo pipefail

CFG="$HOME/.config/opencode/opencode.json"

echo
echo "=========================================="
echo "SUPRA MODEL REPAIR"
echo "=========================================="

if [[ ! -f "$CFG" ]]; then
    echo "Configuration OpenCode introuvable :"
    echo "$CFG"
    exit 1
fi

cp "$CFG" "$CFG.bak.$(date +%Y%m%d_%H%M%S)"

echo
echo "Recherche du meilleur modèle installé..."

if ollama list | awk 'NR>1{print $1}' | grep -qx "qwen3:4b-instruct"; then
    TARGET="OLLAMA_LOCAL/qwen3:4b-instruct"
elif ollama list | awk 'NR>1{print $1}' | grep -qx "qwen3:4b"; then
    TARGET="OLLAMA_LOCAL/qwen3:4b"
else
    echo "Aucun modèle compatible trouvé."
    exit 1
fi

echo
echo "Modèle retenu : $TARGET"

python3 - "$CFG" "$TARGET" <<'PY'
import json
import sys

cfg=sys.argv[1]
target=sys.argv[2]

with open(cfg,"r") as f:
    data=json.load(f)

data["model"]=target

with open(cfg,"w") as f:
    json.dump(data,f,indent=2)

print("Configuration mise à jour.")
PY

echo
echo "Nouvelle configuration :"
grep '"model"' "$CFG"

echo
echo "Validation..."

bash GO_SUPRA_VALIDATE.sh

echo
echo "=========================================="
echo "SUPRA MODEL REPAIR COMPLETE"
echo "=========================================="

