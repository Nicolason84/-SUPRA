#!/usr/bin/env bash
set -euo pipefail

echo "========== OpenCode =========="
which opencode || true
opencode --version || true

echo
echo "========== Derniers logs =========="

LOGDIR="$HOME/.local/share/opencode/log"

if [ ! -d "$LOGDIR" ]; then
    echo "Dossier de logs introuvable : $LOGDIR"
    exit 1
fi

LATEST="$(ls -1t "$LOGDIR" | head -1)"

echo
echo "Fichier :"
echo "$LOGDIR/$LATEST"

echo
echo "---------- 300 dernières lignes ----------"
tail -300 "$LOGDIR/$LATEST"

echo
echo "========== Configuration =========="
opencode debug config || true
