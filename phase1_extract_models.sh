#!/usr/bin/env bash
set -Eeuo pipefail

echo "===================================================="
echo "SUPRA - PHASE 1 - MECHANICAL EXTRACT"
echo "===================================================="

git status --short
echo
echo "Branch : $(git branch --show-current)"
echo "Commit : $(git rev-parse --short HEAD)"
echo

mkdir -p SUPRA/Models

echo
echo "===================================================="
echo "ACTION MANUELLE"
echo "===================================================="
echo
echo "1. Créer :"
echo "   SUPRA/Models/SUPRASection.swift"
echo "   SUPRA/Models/SUPRARecord.swift"
echo "   SUPRA/Models/SUPRASource.swift"
echo
echo "2. Copier EXACTEMENT les trois types."
echo
echo "3. Les supprimer de ContentView.swift."
echo
read -p "Quand c'est terminé, appuie sur ENTREE..."

FAILED=0

for T in SUPRASection SUPRARecord SUPRASource
do
COUNT=$(grep -R \
--include="*.swift" \
--exclude-dir="_SUPRA_BACKUPS" \
--exclude-dir="_NON_RUNTIME_ARCHITECTURE" \
-E "\\b(struct|class|enum|actor|protocol)[[:space:]]+$T\\b" \
SUPRA | wc -l | tr -d ' ')

echo "$T : $COUNT"

[ "$COUNT" = "1" ] || FAILED=1
done

if [ "$FAILED" != "0" ]; then
echo
echo "❌ DUPLICATE DETECTED"
exit 1
fi

SCHEME=$(xcodebuild -list -json | python3 -c 'import json,sys;print(json.load(sys.stdin)["project"]["schemes"][0])')

echo
echo "Compilation..."
xcodebuild \
-project SUPRA.xcodeproj \
-scheme "$SCHEME" \
-destination 'platform=macOS' \
build

git add SUPRA/ContentView.swift SUPRA/Models SUPRA.xcodeproj

git commit -m "refactor(models): extract SUPRA models from ContentView"

echo
echo "===================================="
echo "PHASE 1 : PASS"
echo "===================================="
