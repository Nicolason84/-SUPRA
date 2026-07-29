#!/usr/bin/env bash
set -euo pipefail

REPORT="$HOME/Desktop/OPENCODE_PROVIDER_FORENSICS_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$REPORT"

echo "====================================================="
echo "   OPENCODE PROVIDER FORENSICS (READ ONLY)"
echo "====================================================="

exec > >(tee "$REPORT/REPORT.txt") 2>&1

echo
echo "### 1. Version"
opencode --version || true

echo
echo "### 2. Résolution de configuration"
opencode debug config || true

echo
echo "### 3. Debug v2 (catalogue/plugins intégrés)"
opencode debug v2 || true

echo
echo "### 4. Variables d'environnement"
env | grep -E '^(OPENCODE|OLLAMA|AI_|OPENAI)' | sort || true

echo
echo "### 5. Plugins globaux"
find "$HOME/.config/opencode" \
  \( -path "*/plugins/*" -o -path "*/plugin/*" \) \
  -type f 2>/dev/null || true

echo
echo "### 6. Plugins projet"
find . \
  \( -path "*/.opencode/plugins/*" -o -path "*/.opencode/plugin/*" \) \
  -type f 2>/dev/null || true

echo
echo "### 7. Recherche de OLLAMA_LOCAL"
find \
"$HOME/.config/opencode" \
"$HOME/.local/share/opencode" \
"$HOME/.cache/opencode" \
"$HOME/.opencode" \
. \
-type f \
\( \
-name "*.json" -o \
-name "*.jsonc" -o \
-name "*.ts" -o \
-name "*.js" -o \
-name "*.mjs" -o \
-name "*.cjs" -o \
-name "*.md" \
\) \
-print0 2>/dev/null \
| xargs -0 grep -Hn "OLLAMA_LOCAL" 2>/dev/null || true

echo
echo "### 8. Recherche de openai-compatible"
find \
"$HOME/.config/opencode" \
"$HOME/.local/share/opencode" \
"$HOME/.cache/opencode" \
"$HOME/.opencode" \
. \
-type f \
\( \
-name "*.json" -o \
-name "*.jsonc" -o \
-name "*.ts" -o \
-name "*.js" -o \
-name "*.mjs" -o \
-name "*.cjs" \
\) \
-print0 2>/dev/null \
| xargs -0 grep -Hn "@ai-sdk/openai-compatible" 2>/dev/null || true

echo
echo "### 9. Recherche de baseURL"
find \
"$HOME/.config/opencode" \
"$HOME/.local/share/opencode" \
"$HOME/.cache/opencode" \
"$HOME/.opencode" \
. \
-type f \
\( \
-name "*.json" -o \
-name "*.jsonc" -o \
-name "*.ts" -o \
-name "*.js" -o \
-name "*.mjs" -o \
-name "*.cjs" \
\) \
-print0 2>/dev/null \
| xargs -0 grep -Hn "baseURL" 2>/dev/null || true

echo
echo "====================================================="
echo "RAPPORT : $REPORT"
echo "====================================================="
