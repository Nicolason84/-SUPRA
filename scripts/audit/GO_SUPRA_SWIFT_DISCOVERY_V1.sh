#!/usr/bin/env bash
#
# GO_SUPRA_SWIFT_DISCOVERY_V1.sh
#
# PHASE 1
# Découverte uniquement
# Aucune mutation
# Aucune sauvegarde
# Aucun patch
#

set -Eeuo pipefail
IFS=$'\n\t'

ROOT="/Users/nicolasalonso/Desktop/NOVA_OS/SUPRA"

STAMP="$(date +%Y%m%d_%H%M%S)"

RUN_ROOT="$ROOT/.supra_discovery/$STAMP"

mkdir -p "$RUN_ROOT"

REPORT="$RUN_ROOT/DISCOVERY.json"
TXT="$RUN_ROOT/SWIFT_FILES.txt"

require() {
    command -v "$1" >/dev/null || {
        echo "Commande manquante : $1"
        exit 1
    }
}

require python3
require find

echo "== SUPRA SWIFT DISCOVERY =="

[ -d "$ROOT" ] || {
    echo "ROOT introuvable : $ROOT"
    exit 1
}

find "$ROOT" \
-type f \
-name "*.swift" \
-not -path "*/DerivedData/*" \
-not -path "*/Pods/*" \
-not -path "*/.git/*" \
-not -path "*/Carthage/*" \
-not -path "*/.build/*" \
| sort > "$TXT"

COUNT=$(wc -l < "$TXT" | tr -d ' ')

python3 <<PY
import json
from pathlib import Path

txt=Path("$TXT")

files=[]

for p in txt.read_text().splitlines():
    try:
        t=Path(p).read_text(errors="ignore")
    except Exception:
        t=""

    files.append({
        "path":p,
        "hasOllama":"ollama" in t.lower(),
        "hasURLSession":"URLSession" in t,
        "has11434":"11434" in t,
        "hasChat":"chat" in t.lower(),
        "hasRuntime":"runtime" in t.lower(),
        "size":Path(p).stat().st_size
    })

(Path("$REPORT")).write_text(
    json.dumps(
        {
            "status":"PASS",
            "swiftCount":len(files),
            "files":files
        },
        indent=2,
        ensure_ascii=False
    )
)
PY

echo
echo "======================================="
echo "DISCOVERY PASS"
echo "======================================="
echo
echo "Swift files : $COUNT"
echo
echo "TXT  : $TXT"
echo "JSON : $REPORT"
echo
echo "AUCUNE MODIFICATION EFFECTUÉE"
echo "PRÊT POUR PHASE 2 (BACKUP)"
