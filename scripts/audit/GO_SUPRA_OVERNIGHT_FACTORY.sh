#!/bin/bash

ROOT="$HOME/Desktop/NOVA_OS/SUPRA"
OUT="$ROOT/.overnight_audit/$(date +%Y%m%d_%H%M%S)"

mkdir -p "$OUT"

run_tab () {
osascript <<OSA
tell application "Terminal"
    activate
    do script "$1"
end tell
OSA
}

#############################################
# 1 BUILD WATCH
#############################################

run_tab "
cd '$ROOT'
echo BUILD > '$OUT/01_BUILD.log'
xcodebuild -list >> '$OUT/01_BUILD.log' 2>&1
xcodebuild build >> '$OUT/01_BUILD.log' 2>&1
"

#############################################
# 2 SWIFT INDEX
#############################################

run_tab "
echo INDEX > '$OUT/02_INDEX.log'
find '$ROOT' -name '*.swift' > '$OUT/swift_files.txt'
while read f
do
grep -Hn 'ollama\\|11434\\|URLSession\\|sendChat\\|runtime\\|Supra' \"\$f\" >> '$OUT/02_INDEX.log' 2>/dev/null
done < '$OUT/swift_files.txt'
"

#############################################
# 3 XCODE MAP
#############################################

run_tab "
echo XCODE > '$OUT/03_XCODE.log'
find '$ROOT' \\( -name '*.xcodeproj' -o -name '*.xcworkspace' \\) > '$OUT/projects.txt'
find '$ROOT' -name project.pbxproj >> '$OUT/03_XCODE.log'
"

#############################################
# 4 IMPORT GRAPH
#############################################

run_tab "
echo IMPORTS > '$OUT/04_IMPORTS.log'
find '$ROOT' -name '*.swift' -print0 |
while IFS= read -r -d '' f
do
echo ===== \$f >> '$OUT/04_IMPORTS.log'
grep '^import ' \"\$f\" >> '$OUT/04_IMPORTS.log'
done
"

#############################################
# 5 ERROR WATCH
#############################################

run_tab "
echo ERRORS > '$OUT/05_ERRORS.log'
while true
do
grep -R 'error:' '$ROOT' >> '$OUT/05_ERRORS.log' 2>/dev/null
sleep 300
done
"

#############################################
# 6 ARCHITECTURE INVENTORY
#############################################

run_tab "
echo INVENTORY > '$OUT/06_INVENTORY.log'
find '$ROOT' \
-type f \
\\( \
-name '*.swift' -o \
-name '*.json' -o \
-name '*.md' -o \
-name '*.sh' -o \
-name '*.plist' \
\\) \
> '$OUT/inventory.txt'
"

echo
echo "======================================"
echo "SUPRA NIGHT FACTORY LANCÉE"
echo "======================================"
echo
echo "Résultats :"
echo "$OUT"
echo
echo "6 TERMINAUX TRAVAILLENT EN PARALLÈLE."
echo "AUCUNE MODIFICATION DU CODE."
echo "LECTURE SEULE."
echo
