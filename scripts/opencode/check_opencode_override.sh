#!/usr/bin/env bash
set -e

echo "===== OPENCODE CONFIG FILES ====="

find "$HOME/Desktop/NOVA_OS/SUPRA_DEEPSEEK_EXIT_READINESS" \
     "$HOME/.config/opencode" \
     "$HOME" \
     -type f \
     \( \
       -name "opencode.json" -o \
       -name "opencode.jsonc" -o \
       -path "*/.opencode/*" \
     \) 2>/dev/null

echo
echo "===== MODEL REFERENCES ====="

grep -RIn '"model"' \
"$HOME/Desktop/NOVA_OS/SUPRA_DEEPSEEK_EXIT_READINESS" \
"$HOME/.config/opencode" \
2>/dev/null

echo
echo "===== QWEN3:4B-INSTRUCT ====="

grep -RIn 'qwen3:4b-instruct' \
"$HOME/Desktop/NOVA_OS/SUPRA_DEEPSEEK_EXIT_READINESS" \
"$HOME/.config/opencode" \
2>/dev/null

echo
echo "===== ENV ====="

env | grep OPENCODE || true
