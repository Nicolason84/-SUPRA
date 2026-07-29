#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="/Users/nicolasalonso/Desktop/NOVA_OS/SUPRA"

STAMP=$(date +"%Y%m%d_%H%M%S")
OUT="$HOME/Desktop/SUPRA_MEMORY_DISCOVERY_$STAMP"

mkdir -p "$OUT"

echo "== SUPRA MEMORY DISCOVERY =="
echo "ROOT=$ROOT"

find "$ROOT" \
-type f \
\( \
-name "*.swift" -o \
-name "*.json" -o \
-name "*.plist" -o \
-name "*.md" \
\) \
-not -path "*/DerivedData/*" \
-not -path "*/.git/*" \
-not -path "*/Pods/*" \
-not -path "*/build/*" \
-not -path "*/.build/*" \
> "$OUT/ALL_FILES.txt"

echo
echo "[1/6] Recherche des fichiers principaux..."

grep -Ei \
'SUPRAExecutiveStore\.swift|SUPRAApp\.swift|ContentView\.swift' \
"$OUT/ALL_FILES.txt" \
> "$OUT/CORE_FILES.txt" || true

echo
echo "[2/6] Recherche des composants mémoire..."

grep -Ei \
'Memory|Registry|Loader|Context|Runtime|Evidence|Atlas|Knowledge|Canonical' \
"$OUT/ALL_FILES.txt" \
| sort -u \
> "$OUT/MEMORY_FILES.txt"

echo
echo "[3/6] Recherche des classes Swift..."

: > "$OUT/SWIFT_SYMBOLS.txt"

while IFS= read -r f
do
    [ -f "$f" ] || continue

    grep -En \
'^(class|struct|enum|actor|protocol)[[:space:]]+' \
"$f" \
>> "$OUT/SWIFT_SYMBOLS.txt" || true

done < <(grep '\.swift$' "$OUT/ALL_FILES.txt")

echo
echo "[4/6] Recherche des références SUPRAMemory..."

grep -RIn \
"SUPRAMemory" \
"$ROOT" \
--include="*.swift" \
> "$OUT/SUPRAMEMORY_REFERENCES.txt" || true

echo
echo "[5/6] Recherche des ExecutiveStore..."

grep -RIn \
"SUPRAExecutiveStore" \
"$ROOT" \
--include="*.swift" \
> "$OUT/EXECUTIVESTORE_REFERENCES.txt" || true

echo
echo "[6/6] Rapport..."

{
echo "===== CORE FILES ====="
wc -l < "$OUT/CORE_FILES.txt"

echo
echo "===== MEMORY FILES ====="
wc -l < "$OUT/MEMORY_FILES.txt"

echo
echo "===== SWIFT SYMBOLS ====="
wc -l < "$OUT/SWIFT_SYMBOLS.txt"

echo
echo "===== SUPRAMEMORY REFERENCES ====="
wc -l < "$OUT/SUPRAMEMORY_REFERENCES.txt"

echo
echo "===== EXECUTIVESTORE REFERENCES ====="
wc -l < "$OUT/EXECUTIVESTORE_REFERENCES.txt"
} | tee "$OUT/SUMMARY.txt"

echo
echo "=================================="
echo "DISCOVERY TERMINÉ"
echo "$OUT"
echo "=================================="

open "$OUT"
