#!/usr/bin/env bash
set -euo pipefail

CONFIG="$HOME/.config/opencode/opencode.json"

python3 <<'PY'
import json
from pathlib import Path

cfg = Path.home()/".config/opencode"/"opencode.json"

with open(cfg) as f:
    data=json.load(f)

# Supprime la clé invalide
data.pop("SUPRA_BACKUP", None)

# Désactive temporairement les personnalisations
data["agent"] = {}
data["command"] = {}

# N'ajoute AUCUNE clé personnalisée

with open(cfg,"w") as f:
    json.dump(data,f,indent=2)

print("Configuration réparée.")
PY

echo
echo "Validation..."
opencode debug config

echo
echo "Relance OpenCode..."
pkill -f opencode || true
sleep 2

cd ~/Desktop/NOVA_OS/SUPRA_DEEPSEEK_EXIT_READINESS
exec opencode
