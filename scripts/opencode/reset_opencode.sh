#!/usr/bin/env bash
set -euo pipefail

echo "SUPRA OpenCode Reset"

PROJECT="$HOME/Desktop/NOVA_OS/SUPRA_DEEPSEEK_EXIT_READINESS"

mkdir -p ~/.config/opencode

cat > ~/.config/opencode/opencode.json <<'EOF'
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

export OLLAMA_CONTEXT_LENGTH=65536

echo
echo "========== CONFIG =========="
opencode debug config || true

echo
echo "========== OLLAMA =========="
ollama ps
ollama list

echo
echo "========== TEST =========="
ollama run qwen3-coder:latest --think=false "READY"

echo
echo "========== START =========="
cd "$PROJECT"

exec opencode . \
  --model OLLAMA_LOCAL/qwen3-coder \
  --auto
