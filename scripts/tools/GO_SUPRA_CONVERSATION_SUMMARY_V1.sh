#!/usr/bin/env bash
set -Eeuo pipefail

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="$HOME/Desktop/SUPRA_CONVERSATION_SUMMARY_${STAMP}.md"

INPUT=""

# Si un fichier .txt est actuellement ouvert dans less, on le récupère
LESS_CMD="$(ps -axo command | grep 'less -R' | grep 'SUPRA_CONVERSATION_SUMMARY_' | grep -v grep | head -n1 || true)"

if [ -n "$LESS_CMD" ]; then
    INPUT="$(printf "%s\n" "$LESS_CMD" | sed -E "s/.*'([^']+)'.*/\1/")"
fi

# Sinon on prend le plus récent sur le Bureau
if [ -z "$INPUT" ] || [ ! -f "$INPUT" ]; then
    INPUT="$(ls -t "$HOME"/Desktop/SUPRA_CONVERSATION_SUMMARY_*.txt 2>/dev/null | head -n1 || true)"
fi

if [ -z "$INPUT" ] || [ ! -f "$INPUT" ]; then
    echo "Aucun résumé SUPRA trouvé."
    exit 1
fi

{
echo "# SUPRA — Résumé de conversation"
echo
echo "**Date :** $(date)"
echo
echo "**Source :** $INPUT"
echo
echo "---"
echo
cat "$INPUT"
} > "$OUT"

echo
echo "Résumé généré :"
echo "$OUT"

osascript <<APPLESCRIPT
tell application "Terminal"
    activate
    do script "clear; printf '\\033]0;SUPRA — Résumé Conversation\\007'; less -R \"$OUT\""
end tell
APPLESCRIPT

echo
echo "OK"
