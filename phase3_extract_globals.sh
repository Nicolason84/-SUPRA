#!/usr/bin/env bash
set -Eeuo pipefail

echo "======================================================================"
echo "SUPRA"
echo "PHASE 3 — GLOBAL TYPES EXTRACTION"
echo "======================================================================"
echo

git status --short
echo
echo "HEAD : $(git rev-parse --short HEAD)"
echo "BRANCH : $(git branch --show-current)"
echo

mkdir -p SUPRA/UI
mkdir -p SUPRA/Models

cat <<'TXT'

EXTRAIRE SANS AUCUNE MODIFICATION :

UI
────────────────────────────────────────
SUPRAStructureMode
SUPRAHumanStage

MODELS
────────────────────────────────────────
SUPRATerminalMegabusEnvelope
SUPRAMissionEvidencePayload
SUPRASystemIntegritySnapshot

Créer :

SUPRA/UI/SUPRAStructureMode.swift
SUPRA/UI/SUPRAHumanStage.swift

SUPRA/Models/SUPRATerminalMegabusEnvelope.swift
SUPRA/Models/SUPRAMissionEvidencePayload.swift
SUPRA/Models/SUPRASystemIntegritySnapshot.swift

RÈGLES

✓ copier/coller IDENTIQUE
✓ aucune ligne modifiée
✓ aucun renommage
✓ aucune logique changée
✓ supprimer ensuite uniquement les définitions de ContentView.swift

TXT

read -p "Extraction terminée ? [ENTER] "

echo
echo "======================================================================"
echo "VÉRIFICATION DES TYPES"
echo "======================================================================"

FAILED=0

for TYPE in \
SUPRAStructureMode \
SUPRAHumanStage \
SUPRATerminalMegabusEnvelope \
SUPRAMissionEvidencePayload \
SUPRASystemIntegritySnapshot
do
COUNT=$(grep -R \
--include="*.swift" \
-E "\\b(enum|struct|class|actor)[[:space:]]+$TYPE\\b" \
SUPRA | wc -l | tr -d ' ')

printf "%-36s %s\n" "$TYPE" "$COUNT"

[[ "$COUNT" == "1" ]] || FAILED=1
done

if [[ "$FAILED" != "0" ]]; then
    echo
    echo "❌ DUPLICATE / TYPE MISSING"
    exit 1
fi

echo
echo "======================================================================"
echo "BUILD"
echo "======================================================================"

SCHEME=$(xcodebuild -list -json | python3 -c '
import json,sys
data=json.load(sys.stdin)
print(data["project"]["schemes"][0])
')

xcodebuild \
-project SUPRA.xcodeproj \
-scheme "$SCHEME" \
-destination 'platform=macOS' \
build

echo
echo "======================================================================"
echo "GIT"
echo "======================================================================"

git add \
SUPRA/ContentView.swift \
SUPRA/UI \
SUPRA/Models \
SUPRA.xcodeproj

if git diff --cached --quiet; then
    echo "AUCUN CHANGEMENT À COMMIT"
else
    git commit -m "refactor(types): extract global enums and infrastructure models"
fi

echo
echo "======================================================================"
echo "PHASE 3 PASS"
echo "======================================================================"

git log --oneline -1
