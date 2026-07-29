#!/bin/bash

set -euo pipefail

REPO="$HOME/Desktop/NOVA_OS/SUPRA"
WORKTREE="$HOME/Desktop/NOVA_OS/SUPRA_BISECT"

GOOD="5c1b8dd"
BAD="develop"

echo "========================================================"
echo "        SUPRA GIT BISECT PREPARATION"
echo "========================================================"

cd "$REPO"

echo
echo "[1/6] Vérification du dépôt..."
git status --short

echo
echo "[2/6] Suppression ancien worktree (si présent)..."
if git worktree list | grep -q "$WORKTREE"; then
    git worktree remove --force "$WORKTREE"
fi

rm -rf "$WORKTREE"

echo
echo "[3/6] Création du worktree..."
git worktree add "$WORKTREE" "$BAD"

cd "$WORKTREE"

echo
echo "[4/6] Initialisation du bisect..."
git bisect reset >/dev/null 2>&1 || true
git bisect start
git bisect bad
git bisect good "$GOOD"

echo
echo "========================================================"
echo "Le dépôt est maintenant positionné sur le premier commit"
echo "à tester."
echo "========================================================"

echo
echo "Commit actuel :"
git log -1 --oneline --decorate

echo
echo "Fichiers modifiés dans ce commit :"
git show --stat --oneline --name-only --format=medium HEAD

echo
echo "========================================================"
echo "ETAPE SUIVANTE"
echo "========================================================"
echo
echo "1. Ouvre :"
echo "   $WORKTREE"
echo
echo "2. Compile dans Xcode."
echo
echo "3. Si BUILD OK :"
echo "      git bisect good"
echo
echo "4. Si BUILD FAIL :"
echo "      git bisect bad"
echo
echo "5. Répète jusqu'à ce que Git affiche :"
echo
echo "      '<commit> is the first bad commit'"
echo
echo "6. Termine par :"
echo
echo "      git bisect reset"
echo
echo "========================================================"
