#!/usr/bin/env bash
set -euo pipefail

ROOT="$(mktemp -d /tmp/opencode-home.XXXXXX)"

mkdir -p "$ROOT"/{home,tmp,workspace}

export HOME="$ROOT/home"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

mkdir -p \
"$XDG_CONFIG_HOME/opencode" \
"$XDG_DATA_HOME" \
"$XDG_CACHE_HOME"

cat > "$XDG_CONFIG_HOME/opencode/opencode.json" <<'JSON'
{
  "$schema":"https://opencode.ai/config.json",
  "permission":{"*":"allow"},
  "snapshot":false,
  "provider":{
    "OLLAMA_LOCAL":{
      "npm":"@ai-sdk/openai-compatible",
      "options":{
        "baseURL":"http://127.0.0.1:11434/v1"
      },
      "models":{
        "qwen3-coder":{
          "id":"qwen3-coder:latest"
        }
      }
    }
  },
  "model":"OLLAMA_LOCAL/qwen3-coder"
}
JSON

cd "$ROOT/workspace"

echo hello > hello.txt

echo
echo "HOME=$HOME"
echo

echo "===== CONFIG ====="
opencode debug config

echo
echo "===== START ====="

exec opencode
