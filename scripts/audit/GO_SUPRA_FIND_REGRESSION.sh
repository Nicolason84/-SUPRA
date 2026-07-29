#!/bin/bash

set -euo pipefail

REPO="$HOME/Desktop/NOVA_OS/SUPRA"
GOOD="5c1b8dd"
BAD="HEAD"

cd "$REPO"

REPORT="$HOME/Desktop/SUPRA_REGRESSION_$(date +%Y%m%d_%H%M%S).txt"

exec > >(tee "$REPORT") 2>&1

echo "========================================================="
echo "        SUPRA REGRESSION ANALYZER"
echo "========================================================="
echo
echo "Repository : $(pwd)"
echo "GOOD COMMIT : $GOOD"
echo "BAD COMMIT  : $(git rev-parse --short $BAD)"
echo

echo "========================================================="
echo "COMMITS ENTRE GOOD ET HEAD"
echo "========================================================="
git log --graph --decorate --oneline ${GOOD}..${BAD}

echo
echo "========================================================="
echo "STATISTIQUES"
echo "========================================================="
git diff --stat ${GOOD} ${BAD}

echo
echo "========================================================="
echo "FICHIERS MODIFIES"
echo "========================================================="
git diff --name-status ${GOOD} ${BAD}

echo
echo "========================================================="
echo "SWIFT UNIQUEMENT"
echo "========================================================="
git diff --name-status ${GOOD} ${BAD} -- '*.swift'

echo
echo "========================================================="
echo "FICHIERS AJOUTES"
echo "========================================================="
git diff --diff-filter=A --name-only ${GOOD} ${BAD}

echo
echo "========================================================="
echo "FICHIERS SUPPRIMES"
echo "========================================================="
git diff --diff-filter=D --name-only ${GOOD} ${BAD}

echo
echo "========================================================="
echo "RENOMMAGES"
echo "========================================================="
git diff --summary ${GOOD} ${BAD} | grep rename || true

echo
echo "========================================================="
echo "PACKAGES"
echo "========================================================="
git diff --name-status ${GOOD} ${BAD} \
| grep -Ei 'Package|Packages|Package.swift|project.pbxproj|xcworkspace|xcodeproj' || true

echo
echo "========================================================="
echo "ADAPTERS"
echo "========================================================="
git diff --name-status ${GOOD} ${BAD} \
| grep -Ei 'Adapter|Bridge|Runtime|Gateway|VideoSwap|CAnnoNico' || true

echo
echo "========================================================="
echo "20 PLUS GROS FICHIERS MODIFIES"
echo "========================================================="
git diff --numstat ${GOOD} ${BAD} \
| sort -nr \
| head -20

echo
echo "========================================================="
echo "FIN"
echo "Rapport : $REPORT"
echo "========================================================="
