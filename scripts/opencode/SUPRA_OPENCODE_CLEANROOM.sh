#!/usr/bin/env bash
set -euo pipefail

echo "=========================================="
echo " SUPRA - OpenCode CLEAN ROOM"
echo "=========================================="

ROOT="$(mktemp -d /tmp/opencode-cleanroom.XXXXXX)"
CFG="$ROOT/config"
WS="$ROOT/workspace"

mkdir -p "$CFG"
mkdir -p "$WS"

cat > "$CFG/opencode.json" <<'JSON'
{
  "$schema":"https://opencode.ai/config.json",

  "permission":{
    "*":"allow"
  },

  "provider":{
    "OLLAMA_LOCAL":{
      "npm":"@ai-sdk/openai-compatible",
      "options":{
        "baseURL":"http://127.0.0.1:11434/v1"
      },
      "models":{
        "qwen3-coder":{
          "id":"qwen3-coder:latest",
          "options":{
            "reasoningEffort":"none"
          },
          "limit":{
            "context":8192,
            "output":1024
          }
        }
      }
    }
  },

  "model":"OLLAMA_LOCAL/qwen3-coder",
  "small_model":"OLLAMA_LOCAL/qwen3-coder",

  "snapshot":false,
  "plugin":[]
}
JSON

cat > "$WS/test.txt" <<'EOF'
OpenCode Clean Room
EOF

pkill -f opencode || true

export OPENCODE_CONFIG="$CFG/opencode.json"
export OPENCODE_CONFIG_DIR="$ROOT/empty-config"

mkdir -p "$ROOT/empty-config"

echo
echo "========== CONFIG =========="
opencode debug config

echo
echo "========== WORKSPACE =========="
cd "$WS"

echo
echo "Le workspace contient uniquement :"
ls -la

echo
echo "=========================================="
echo "TESTS A FAIRE"
echo "=========================================="
echo
echo "1)"
echo "hello"
echo
echo "2)"
echo "What is 2+2?"
echo
echo "3)"
echo "List the files in the current directory."
echo
echo "=========================================="

exec opencode --pure
