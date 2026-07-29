#!/usr/bin/env bash
set -euo pipefail

CONFIG="$HOME/.config/opencode/opencode.json"
BACKUP="$HOME/.config/opencode/opencode.backup.$(date +%Y%m%d_%H%M%S).json"

echo "======================================"
echo " SUPRA - OpenCode SAFE MODE"
echo "======================================"

if [ ! -f "$CONFIG" ]; then
    echo "Configuration introuvable : $CONFIG"
    exit 1
fi

cp "$CONFIG" "$BACKUP"

echo
echo "Backup :"
echo "$BACKUP"

python3 <<'PY'
import json
from pathlib import Path

cfg = Path.home()/".config/opencode"/"opencode.json"

with open(cfg) as f:
    data=json.load(f)

# Sauvegarde interne
if "SUPRA_BACKUP" not in data:
    data["SUPRA_BACKUP"]={
        "agent":data.get("agent",{}),
        "command":data.get("command",{})
    }

# Désactivation temporaire
data["agent"]={}
data["command"]={}

# Utiliser explicitement l'agent intégré
data["default_agent"]="build"

with open(cfg,"w") as f:
    json.dump(data,f,indent=2)

print("SAFE MODE ACTIVÉ")
PY

echo
echo "Arrêt OpenCode..."
pkill -f opencode || true

sleep 2

echo
echo "Configuration active :"
opencode debug config

echo
echo "======================================"
echo "TEST"
echo "======================================"
echo
echo "Quand OpenCode démarre tape UNIQUEMENT :"
echo
echo "hello"
echo
echo "Si hello répond immédiatement,"
echo "le problème provient de la configuration"
echo "agent/command."
echo

cd ~/Desktop/NOVA_OS/SUPRA_DEEPSEEK_EXIT_READINESS

exec opencode
