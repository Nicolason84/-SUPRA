#!/usr/bin/env bash
set -euo pipefail

CONFIG="$HOME/.config/opencode/opencode.json"

if [ ! -f "$CONFIG" ]; then
    echo "Configuration introuvable : $CONFIG"
    exit 1
fi

cp "$CONFIG" "$CONFIG.bak.$(date +%Y%m%d_%H%M%S)"

python3 <<'PY'
import json
from pathlib import Path

cfg = Path.home()/".config/opencode/opencode.json"

with open(cfg,"r") as f:
    data=json.load(f)

data["snapshot"]=False

data["watcher"]={
    "ignore":[
        ".git/**",
        ".build/**",
        "build/**",
        "DerivedData/**",
        ".swiftpm/**",
        "Packages/**/.build/**",
        ".opencode/node_modules/**",
        "node_modules/**",
        "Pods/**",
        "Carthage/**",
        ".cache/**",
        "Artifacts/**",
        "Reports/**",
        "Logs/**"
    ]
}

data["compaction"]={
    "auto":True,
    "prune":True,
    "reserved":4096
}

prov=data.get("provider",{}).get("OLLAMA_LOCAL",{})
mods=prov.get("models",{})

if "qwen3-coder" in mods:
    mods["qwen3-coder"].setdefault("limit",{})
    mods["qwen3-coder"]["limit"]["context"]=16384
    mods["qwen3-coder"]["limit"]["output"]=2048

with open(cfg,"w") as f:
    json.dump(data,f,indent=2)

print("Configuration optimisée.")
PY

echo
echo "===== Nettoyage ====="

pkill -f opencode || true
sleep 1

rm -rf ~/.cache/opencode 2>/dev/null || true

find ~/.local/share/opencode \
-type d \
\( \
-name snapshots -o \
-name snapshot -o \
-name tmp -o \
-name cache \
\) \
-exec rm -rf {} + 2>/dev/null || true

echo
echo "===== Redémarrage Ollama ====="

pkill -f ollama || true
sleep 2

nohup ollama serve >/tmp/ollama.log 2>&1 &
sleep 5

curl -fs http://127.0.0.1:11434/api/tags >/dev/null

echo
echo "===== Vérification ====="

opencode debug config

echo
echo "===== Lancement ====="

cd ~/Desktop/NOVA_OS/SUPRA_DEEPSEEK_EXIT_READINESS

exec opencode
