#!/bin/bash
set -Eeuo pipefail

ROOT="$(pwd)"
cd "$ROOT"

REPORT_DIR=".supra_reports/composition_root"
REPORT="$REPORT_DIR/COMPOSITION_ROOT_REPORT.md"

mkdir -p "$REPORT_DIR"

echo "=================================================="
echo " SUPRA COMPOSITION ROOT AUDIT"
echo "=================================================="

find_swift() {
    find . \
        -type f \
        -name "*.swift" \
        -not -path "*/.build/*" \
        -not -path "*/DerivedData/*" \
        -not -path "*/Pods/*" \
        -not -path "*/Carthage/*"
}

SWIFT_FILES="$(find_swift)"

APP_FILE="$(grep -RIl "@main" . \
    --include="*.swift" \
    --exclude-dir=.build \
    --exclude-dir=DerivedData \
    | head -1 || true)"

if [ -z "$APP_FILE" ]; then
    APP_FILE="$(grep -RIl "struct .*App: App" . \
        --include="*.swift" \
        --exclude-dir=.build \
        --exclude-dir=DerivedData \
        | head -1 || true)"
fi

{
echo "# SUPRA COMPOSITION ROOT REPORT"
echo
date
echo
echo "========================================"
echo "1. COMPOSITION ROOT"
echo "========================================"
echo

if [ -n "$APP_FILE" ]; then
    echo "Entry point : $APP_FILE"
    echo
    sed -n '1,260p' "$APP_FILE"
else
    echo "Aucun @main trouvé."
fi

echo
echo "========================================"
echo "2. INSTANCES CREES"
echo "========================================"
echo

for TYPE in \
MissionStore \
DecisionStore \
KnowledgeGraph \
ConversationMemoryStore
do
    echo
    echo "## $TYPE"
    echo

    grep -RIn \
    "${TYPE}(" . \
    --include="*.swift" \
    --exclude-dir=.build \
    --exclude-dir=DerivedData \
    || true
done

echo
echo "========================================"
echo "3. SINGLETONS"
echo "========================================"
echo

grep -RIn \
"static let shared" . \
--include="*.swift" \
--exclude-dir=.build \
--exclude-dir=DerivedData \
|| true

echo
echo "========================================"
echo "4. CONFIGURE / REGISTER / BIND"
echo "========================================"
echo

grep -RInE \
'configure\(|register|bind|attach|connect|inject|environmentObject|environment\(' \
. \
--include="*.swift" \
--exclude-dir=.build \
--exclude-dir=DerivedData \
|| true

echo
echo "========================================"
echo "5. DEPENDANCES ENTRE STORES"
echo "========================================"
echo

for TYPE in \
MissionStore \
DecisionStore \
KnowledgeGraph \
ConversationMemoryStore
do
    FILE="$(grep -RIl "class $TYPE\|actor $TYPE\|struct $TYPE" . \
        --include="*.swift" \
        --exclude-dir=.build \
        --exclude-dir=DerivedData \
        | head -1 || true)"

    if [ -n "$FILE" ]; then
        echo
        echo "### $TYPE ($FILE)"
        echo

        grep -nE \
'MissionStore|DecisionStore|KnowledgeGraph|ConversationMemoryStore' \
"$FILE" || true
    fi
done

echo
echo "========================================"
echo "6. ENVIRONMENT OBJECTS"
echo "========================================"
echo

grep -RInE \
'@EnvironmentObject|environmentObject\(' \
. \
--include="*.swift" \
--exclude-dir=.build \
--exclude-dir=DerivedData \
|| true

echo
echo "========================================"
echo "7. GRAPHVIZ"
echo "========================================"
echo

echo "digraph SUPRA {"

for TYPE in MissionStore DecisionStore KnowledgeGraph ConversationMemoryStore
do
grep -RIl "$TYPE" . \
--include="*.swift" \
--exclude-dir=.build \
--exclude-dir=DerivedData \
| while read FILE
do
BASE=$(basename "$FILE")

grep -q "MissionStore" "$FILE" && [ "$TYPE" != "MissionStore" ] && \
echo "\"$BASE\" -> \"MissionStore\";"

grep -q "DecisionStore" "$FILE" && [ "$TYPE" != "DecisionStore" ] && \
echo "\"$BASE\" -> \"DecisionStore\";"

grep -q "KnowledgeGraph" "$FILE" && [ "$TYPE" != "KnowledgeGraph" ] && \
echo "\"$BASE\" -> \"KnowledgeGraph\";"

grep -q "ConversationMemoryStore" "$FILE" && [ "$TYPE" != "ConversationMemoryStore" ] && \
echo "\"$BASE\" -> \"ConversationMemoryStore\";"
done
done

echo "}"

echo
echo "========================================"
echo "8. VERDICT"
echo "========================================"
echo

M=$(grep -R "MissionStore(" . --include="*.swift" --exclude-dir=.build --exclude-dir=DerivedData | wc -l | tr -d ' ')
D=$(grep -R "DecisionStore(" . --include="*.swift" --exclude-dir=.build --exclude-dir=DerivedData | wc -l | tr -d ' ')
K=$(grep -R "KnowledgeGraph(" . --include="*.swift" --exclude-dir=.build --exclude-dir=DerivedData | wc -l | tr -d ' ')
C=$(grep -R "ConversationMemoryStore(" . --include="*.swift" --exclude-dir=.build --exclude-dir=DerivedData | wc -l | tr -d ' ')

echo "MissionStore instances        : $M"
echo "DecisionStore instances       : $D"
echo "KnowledgeGraph instances      : $K"
echo "ConversationMemory instances  : $C"

echo

if [ "$M" -gt 1 ] || [ "$D" -gt 1 ] || [ "$K" -gt 1 ]; then
    echo "RESULTAT : DUPLICATION D'INSTANCES DETECTEE"
else
    echo "RESULTAT : COMPOSITION ROOT POTENTIELLEMENT UNIQUE"
fi

echo
echo "PROCHAINE ETAPE :"
echo "Créer un Composition Root unique dans @main App et injecter les dépendances au démarrage."
echo

} > "$REPORT"

echo
echo "=================================================="
echo "Rapport : $REPORT"
echo "=================================================="

cat "$REPORT"

