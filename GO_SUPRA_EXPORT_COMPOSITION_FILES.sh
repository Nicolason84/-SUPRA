#!/bin/bash
set -Eeuo pipefail

ROOT="$(pwd)"
cd "$ROOT"

OUT=".supra_reports/composition_sources"
mkdir -p "$OUT"

echo "=========================================="
echo " SUPRA COMPOSITION SOURCE EXPORT"
echo "=========================================="

find_swift() {
find . \
-type f \
-name "*.swift" \
-not -path "*/.build/*" \
-not -path "*/DerivedData/*" \
-not -path "*/Pods/*" \
-not -path "*/Carthage/*"
}

export_file() {

PATTERN="$1"
LABEL="$2"

FILE="$(find_swift | while read F
do
grep -Eq "$PATTERN" "$F" && {
echo "$F"
break
}
done)"

echo
echo "------------------------------------------"
echo "$LABEL"
echo "------------------------------------------"

if [ -z "$FILE" ]; then
echo "NOT FOUND"
return
fi

echo "$FILE"

DEST="$OUT/$(basename "$FILE")"

cp "$FILE" "$DEST"

{
echo "// =================================================="
echo "// SOURCE : $FILE"
echo "// =================================================="
echo
cat "$FILE"
} > "$DEST"

echo "Export -> $DEST"
}

#########################################
# @main
#########################################

MAIN="$(grep -RIl "@main" . \
--include="*.swift" \
--exclude-dir=.build \
--exclude-dir=DerivedData \
| head -1 || true)"

if [ -n "$MAIN" ]; then
cp "$MAIN" "$OUT/$(basename "$MAIN")"
echo
echo "@main : $MAIN"
else
export_file "struct .*App: App" "@main App"
fi

#########################################

export_file "class MissionStore|actor MissionStore|struct MissionStore" "MissionStore"

export_file "class DecisionStore|actor DecisionStore|struct DecisionStore" "DecisionStore"

export_file "class KnowledgeGraph|actor KnowledgeGraph|struct KnowledgeGraph" "KnowledgeGraph"

export_file "class ConversationMemoryStore|actor ConversationMemoryStore|struct ConversationMemoryStore" "ConversationMemoryStore"

#########################################
# Configure()
#########################################

CFG="$(find_swift | while read F
do
grep -q "func configure(" "$F" && {
echo "$F"
break
}
done)"

if [ -n "$CFG" ]; then

echo
echo "------------------------------------------"
echo "configure(...)"
echo "------------------------------------------"

awk '
/func configure\(/ {capture=1}
capture{print}
capture && /^}/ {exit}
' "$CFG" \
> "$OUT/ConversationMemoryStore.configure.swift"

echo "Export -> $OUT/ConversationMemoryStore.configure.swift"

fi

#########################################

echo
echo "=========================================="
echo "FILES EXPORTED"
echo "=========================================="

find "$OUT" -maxdepth 1 -type f | sort

echo
echo "=========================================="
echo "READY"
echo "=========================================="

