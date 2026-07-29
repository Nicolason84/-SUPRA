#!/usr/bin/env bash
set -euo pipefail

CONFIG="$HOME/.config/opencode/opencode.json"

echo "Sauvegarde..."
cp "$CONFIG" "$CONFIG.bak.$(date +%Y%m%d_%H%M%S)"

python3 <<'PY'
import json
from pathlib import Path

cfg = Path.home() / ".config/opencode" / "opencode.json"

with open(cfg) as f:
    data = json.load(f)

model = data["provider"]["OLLAMA_LOCAL"]["models"]["qwen3-coder"]

model.setdefault("limit", {})
model["limit"]["context"] = 16384
model["limit"]["output"] = 2048

with open(cfg, "w") as f:
    json.dump(data, f, indent=2)

print("Configuration mise à jour.")
PY

echo
echo "Arrêt d'Ollama..."
pkill -f ollama || true
sleep 2

echo
echo "Relance..."
ollama serve >/tmp/ollama.log 2>&1 &
sleep 5

echo
echo "Configuration :"
grep -A5 '"limit"' "$CONFIG"

echo
echo "Processus :"
ollama ps

echo
echo "OK."
