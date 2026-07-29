#!/usr/bin/env bash
set -Eeuo pipefail

OUT="$HOME/Desktop/SUPRA_ACTIVE_PROJECT_DISCOVERY"
mkdir -p "$OUT"

echo "===================================================="
echo " SUPRA ACTIVE PROJECT DISCOVERY"
echo " READ ONLY"
echo "===================================================="

SEARCH_ROOTS=(
"$HOME/Desktop"
"$HOME/Documents"
"$HOME/Downloads"
"$HOME/Developer"
"$HOME/Development"
"$HOME/Projects"
"$HOME"
)

echo
echo "[1/7] Recherche des projets..."

find "${SEARCH_ROOTS[@]}" \
-type d \
\( \
-name "*.xcodeproj" -o \
-name "*.xcworkspace" \
\) \
2>/dev/null | sort -u > "$OUT/projects.txt"

echo
echo "[2/7] Recherche Package.swift..."

find "${SEARCH_ROOTS[@]}" \
-name Package.swift \
2>/dev/null | sort -u > "$OUT/swift_packages.txt"

echo
echo "[3/7] Recherche apps compilées..."

find "${SEARCH_ROOTS[@]}" \
-name "*.app" \
2>/dev/null | sort -u > "$OUT/apps.txt"

echo
echo "[4/7] Recherche mots clés..."

grep -Ei \
"SUPRA|NOVA|RUNTIME|EXECUTIVE|WORKSPACE|MISSION|DECISION" \
"$OUT/projects.txt" \
> "$OUT/priorities.txt" || true

echo
echo "[5/7] Extraction des schemes..."

> "$OUT/schemes.txt"

while IFS= read -r P
do

EXT="${P##*.}"

if [[ "$EXT" == "xcworkspace" ]]; then

DIR="$(dirname "$P")"

(
cd "$DIR"

xcodebuild \
-list \
-workspace "$(basename "$P")" \
2>/dev/null

) >> "$OUT/schemes.txt" || true

else

DIR="$(dirname "$P")"

(
cd "$DIR"

xcodebuild \
-list \
-project "$(basename "$P")" \
2>/dev/null

) >> "$OUT/schemes.txt" || true

fi

done < "$OUT/projects.txt"

echo
echo "[6/7] Classement..."

python3 <<'PY'
from pathlib import Path

root=Path.home()/ "Desktop"/"SUPRA_ACTIVE_PROJECT_DISCOVERY"

projects=(root/"projects.txt").read_text(errors="ignore").splitlines()

scores=[]

KEYWORDS=[
"SUPRA",
"NOVA",
"RUNTIME",
"EXECUTIVE",
"WORKSPACE",
"MISSION",
"DECISION"
]

for p in projects:

    s=0
    u=p.upper()

    for k in KEYWORDS:
        if k in u:
            s+=10

    depth=len(Path(p).parts)

    s-=depth

    scores.append((s,p))

scores.sort(reverse=True)

with open(root/"TOP_PROJECTS.txt","w") as f:

    for score,path in scores[:30]:
        f.write(f"{score:4d}  {path}\n")
PY

echo
echo "[7/7] Rapport..."

cat > "$OUT/README.txt" <<EOF

TOP_PROJECTS.txt
→ meilleurs candidats

projects.txt
→ tous les xcodeproj / xcworkspace

schemes.txt
→ tous les schemes trouvés

swift_packages.txt
→ Package.swift

apps.txt
→ applications compilées

priorities.txt
→ chemins contenant SUPRA/NOVA

EOF

echo
echo "=============================================="
echo "TERMINÉ"
echo
echo "Résultats :"
echo "$OUT"
echo
echo "Ouvre d'abord :"
echo "TOP_PROJECTS.txt"
echo "=============================================="

