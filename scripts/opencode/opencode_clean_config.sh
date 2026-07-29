#!/usr/bin/env bash
set -euo pipefail

CFG="$HOME/.config/opencode"

echo "===== BACKUP ====="

mkdir -p "$CFG/backup"

[ -f "$CFG/opencode.jsonc" ] && \
mv "$CFG/opencode.jsonc" \
"$CFG/backup/opencode.jsonc.$(date +%Y%m%d_%H%M%S)"

echo
echo "===== ACTIVE CONFIG ====="

cat > "$CFG/opencode.json" <<'EOF'
{
  "$schema":"https://opencode.ai/config.json",

  "permission":"allow",

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
            "context":65536,
            "output":8192
          }
        }
      }
    }
  },

  "model":"OLLAMA_LOCAL/qwen3-coder",
  "small_model":"OLLAMA_LOCAL/qwen3-coder",

  "lsp":true
}
EOF

echo
echo "===== VERIFY FILES ====="

ls -la "$CFG"

echo
echo "===== DEBUG ====="

opencode debug config | grep -E '"model"|"small_model"'

echo
echo "===== EXPECTED ====="
echo 'model        : OLLAMA_LOCAL/qwen3-coder'
echo 'small_model  : OLLAMA_LOCAL/qwen3-coder'
