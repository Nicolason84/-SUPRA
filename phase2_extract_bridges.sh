#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================================"
echo "SUPRA"
echo "PHASE 2 - BRIDGES EXTRACTION"
echo "========================================================"
echo

git status --short
echo
echo "Branch : $(git branch --show-current)"
echo "HEAD   : $(git rev-parse --short HEAD)"
echo

mkdir -p SUPRA/Bridges

echo
echo "========================================================"
echo "A EXTRAIRE (COPIER A L'IDENTIQUE)"
echo "========================================================"
echo
echo "SUPRATerminalMegabusBridge"
echo "SUPRAMissionEvidenceLoader"
echo "SUPRASystemIntegrityLoader"
echo
echo "Créer :"
echo "  SUPRA/Bridges/SUPRATerminalMegabusBridge.swift"
echo "  SUPRA/Bridges/SUPRAMissionEvidenceLoader.swift"
echo "  SUPRA/Bridges/SUPRASystemIntegrityLoader.swift"
echo
echo "NE RIEN MODIFIER"
echo "NE RIEN RENOMMER"
echo "DEPLACEMENT MECANIQUE UNIQUEMENT"
echo

read -p "Extraction terminée ? [ENTER]"

echo
echo "========================================================"
echo "VERIFICATION"
echo "========================================================"

FAILED=0

for T in \
SUPRATerminalMegabusBridge \
SUPRAMissionEvidenceLoader \
SUPRASystemIntegrityLoader
do
COUNT=$(grep -R \
--include="*.swift" \
--exclude-dir="_SUPRA_BACKUPS" \
--exclude-dir="_NON_RUNTIME_ARCHITECTURE" \
-E "\\b(enum|struct|class|actor)[[:space:]]+$T\\b" \
SUPRA | wc -l | tr -d ' ')

echo "$T : $COUNT"

[ "$COUNT" = "1" ] || FAILED=1
done

[ "$FAILED" = "0" ] || {
echo
echo "❌ DUPLICATE DETECTED"
exit 1
}

echo
echo "========================================================"
echo "BUILD"
echo "========================================================"

SCHEME=$(xcodebuild -list -json | python3 -c 'import json,sys;print(json.load(sys.stdin)["project"]["schemes"][0])')

xcodebuild \
-project SUPRA.xcodeproj \
-scheme "$SCHEME" \
-destination 'platform=macOS' \
build

echo
echo "========================================================"
echo "COMMIT"
echo "========================================================"

git add SUPRA/ContentView.swift SUPRA/Bridges SUPRA.xcodeproj

git commit -m "refactor(bridges): extract runtime bridges from ContentView"

echo
echo "========================================================"
echo "PHASE 2 PASS"
echo "========================================================"

git log --oneline -1
