#!/bin/bash
set -Eeuo pipefail

ROOT="$(pwd)"
OUT="$ROOT/.supra_reports/composition_root"

mkdir -p "$OUT"

echo "============================================================"
echo " SUPRA COMPOSITION ROOT EXTRACTOR"
echo "============================================================"

find_swift() {
find "$ROOT" \
-type f \
-name "*.swift" \
-not -path "*/.build/*" \
-not -path "*/DerivedData/*" \
-not -path "*/Pods/*" \
-not -path "*/Carthage/*"
}

extract() {

NAME="$1"

FILE="$(find_swift | while read -r f
do
    [ "$(basename "$f")" = "$NAME" ] && {
        echo "$f"
        break
    }
done)"

echo
echo "============================================================"
echo "$NAME"
echo "============================================================"

if [ -z "$FILE" ]; then
    echo "NOT FOUND"
    return
fi

echo "SOURCE : $FILE"
echo

awk '
BEGIN{
print "============================================================"
print "FILE : " FILENAME
print "============================================================"
}
{
printf("%5d | %s\n",NR,$0)
}
' "$FILE" | tee "$OUT/$NAME.txt"

}

extract "SUPRAOperationalCoreApp.swift"
extract "ConversationMemoryStore.swift"
extract "MissionStore.swift"
extract "DecisionStore.swift"
extract "KnowledgeGraph.swift"
extract "KnowledgeObject.swift"

echo
echo "============================================================"
echo "EXTRACTION configure(...)"
echo "============================================================"

CFG="$(find_swift | while read -r f
do
grep -q "func configure(" "$f" && {
echo "$f"
break
}
done)"

if [ -n "$CFG" ]; then

awk '
/func configure\(/{
capture=1
depth=0
}

capture{

print

depth+=gsub(/\{/,"{")
depth-=gsub(/\}/,"}")

if(depth==0 && /}/){
exit
}
}
' "$CFG" \
| tee "$OUT/ConversationMemoryStore.configure.swift"

else

echo "configure(...) NOT FOUND"

fi

echo
echo "============================================================"
echo "@main"
echo "============================================================"

grep -RIn "@main" . \
--include="*.swift" \
--exclude-dir=.build \
--exclude-dir=DerivedData \
| tee "$OUT/main_location.txt"

echo
echo "============================================================"
echo "MissionStore()"
echo "============================================================"

grep -RIn "MissionStore(" . \
--include="*.swift" \
--exclude-dir=.build \
--exclude-dir=DerivedData \
| tee "$OUT/missionstore_usages.txt"

echo
echo "============================================================"
echo "DecisionStore()"
echo "============================================================"

grep -RIn "DecisionStore(" . \
--include="*.swift" \
--exclude-dir=.build \
--exclude-dir=DerivedData \
| tee "$OUT/decisionstore_usages.txt"

echo
echo "============================================================"
echo "KnowledgeGraph"
echo "============================================================"

grep -RIn "KnowledgeGraph" . \
--include="*.swift" \
--exclude-dir=.build \
--exclude-dir=DerivedData \
| tee "$OUT/knowledgegraph_refs.txt"

echo
echo "============================================================"
echo "EXPORT READY"
echo "============================================================"
echo "$OUT"

