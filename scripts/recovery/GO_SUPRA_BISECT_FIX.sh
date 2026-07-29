#!/bin/bash
set -e

REPO="$HOME/Desktop/NOVA_OS/SUPRA"
WORKTREE="$HOME/Desktop/NOVA_OS/SUPRA_BISECT"

cd "$REPO"

echo "== Nettoyage =="

git bisect reset >/dev/null 2>&1 || true

if git worktree list | grep -q "$WORKTREE"; then
    git worktree remove --force "$WORKTREE"
fi

rm -rf "$WORKTREE"

BRANCH="bisect-$(date +%Y%m%d-%H%M%S)"

echo "== Création branche temporaire : $BRANCH =="

git branch "$BRANCH" develop

git worktree add "$WORKTREE" "$BRANCH"

cd "$WORKTREE"

git bisect start
git bisect bad
git bisect good 5c1b8dd

echo
echo "=========================================="
echo "BISECT PRÊT"
echo "=========================================="
git log -1 --oneline
echo
echo "Ouvre maintenant :"
echo "$WORKTREE"
echo
echo "Compile dans Xcode."
echo
echo "Si BUILD OK  : git bisect good"
echo "Si BUILD FAIL: git bisect bad"
echo
echo "À la fin :"
echo "git bisect reset"
