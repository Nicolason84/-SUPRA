#!/usr/bin/env bash
set -e

ROOT="$HOME/Desktop/NOVA_OS/SUPRA_DEEPSEEK_EXIT_READINESS"

echo "===== CONFIG FILES ====="

find "$HOME/.config/opencode" "$ROOT" \
\( \
-name "opencode.json" -o \
-name "opencode.jsonc" \
\) \
-not -path "*/node_modules/*"

echo
echo "===== MODEL KEYS ====="

grep -RIn \
--include="opencode.json" \
--include="opencode.jsonc" \
'"model"' \
"$HOME/.config/opencode" \
"$ROOT" \
--exclude-dir=node_modules

echo
echo "===== QWEN REFERENCES ====="

grep -RIn \
--include="opencode.json" \
--include="opencode.jsonc" \
'qwen' \
"$HOME/.config/opencode" \
"$ROOT" \
--exclude-dir=node_modules

echo
echo "===== ENV ====="

env | grep OPENCODE || true

echo
echo "===== DEBUG CONFIG ====="

opencode debug config | grep -E "model|small_model"
