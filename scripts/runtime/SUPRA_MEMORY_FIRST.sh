#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$HOME/Desktop/NOVA_OS"

OUT="$HOME/Desktop/SUPRA_CANONICAL_SELECTION_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUT"

echo "Recherche des fichiers candidats..."

find "$ROOT" \
-type f \
\( \
-name "*.swift" -o \
-name "*.json" -o \
-name "*.md" -o \
-name "*.txt" -o \
-name "*.yaml" -o \
-name "*.yml" \
\) \
-not -path "*/DerivedData/*" \
-not -path "*/.git/*" \
-not -path "*/Pods/*" \
-not -path "*/build/*" \
-not -path "*/.build/*" \
> "$OUT/ALL_FILES.txt"

echo "Sélection des fichiers canoniques..."

grep -Ei \
'ContentView\.swift|SUPRAApp\.swift|ExecutiveStore|Registry|Memory|Atlas|Manifest|Freeze|Authority|Decision|Evidence|Knowledge|Compiler|Canonical|Runtime|Bridge|Context|Project|Capability|Product|Conversation|MemoryRecovery|EnvironmentTwin|KnowledgeTwin' \
"$OUT/ALL_FILES.txt" \
| sort -u \
> "$OUT/CANONICAL_FILES.txt"

echo "Calcul des empreintes..."

while read -r f
do
    shasum -a 256 "$f"
done < "$OUT/CANONICAL_FILES.txt" \
> "$OUT/CANONICAL_SHA256.txt"

echo "Résumé"

echo "Total fichiers analysés : $(wc -l < "$OUT/ALL_FILES.txt")"
echo "Fichiers canoniques : $(wc -l < "$OUT/CANONICAL_FILES.txt")"

cat > "$OUT/README.md" <<EOF
SUPRA MEMORY FIRST

Ce dossier contient uniquement la sélection des fichiers
qui serviront de base à la mémoire canonique.

Aucun fichier n'a été modifié.

Aucun fichier n'a été déplacé.

Aucun fichier n'a été supprimé.
EOF

open "$OUT"

echo
echo "TERMINE"
echo "$OUT"
