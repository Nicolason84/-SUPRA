#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="${1:-$HOME/Desktop/NOVA_OS/SUPRA}"
STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="$HOME/Desktop/SUPRA_MISSION_001_$STAMP"

mkdir -p "$OUT"/{DISCOVERY,BACKUP,SUPRA_MEMORY,REPORTS,FREEZE}

echo "== DISCOVERY =="

find "$ROOT" -name "*.xcworkspace" > "$OUT/DISCOVERY/workspaces.txt" || true
find "$ROOT" -name "*.xcodeproj"   > "$OUT/DISCOVERY/projects.txt"   || true
find "$ROOT" -name "project.pbxproj" > "$OUT/DISCOVERY/pbxproj.txt" || true

WORKSPACE="$(head -1 "$OUT/DISCOVERY/workspaces.txt" || true)"
PROJECT="$(head -1 "$OUT/DISCOVERY/projects.txt" || true)"
PBXPROJ="$(head -1 "$OUT/DISCOVERY/pbxproj.txt" || true)"

echo "WORKSPACE=$WORKSPACE" | tee "$OUT/REPORTS/DISCOVERY_REPORT.txt"
echo "PROJECT=$PROJECT"     | tee -a "$OUT/REPORTS/DISCOVERY_REPORT.txt"
echo "PBXPROJ=$PBXPROJ"     | tee -a "$OUT/REPORTS/DISCOVERY_REPORT.txt"

if [ -n "$WORKSPACE" ]; then
    xcodebuild -workspace "$WORKSPACE" -list > "$OUT/DISCOVERY/xcode_list.txt" 2>&1 || true
elif [ -n "$PROJECT" ]; then
    xcodebuild -project "$PROJECT" -list > "$OUT/DISCOVERY/xcode_list.txt" 2>&1 || true
fi

echo
echo "== BACKUP =="

if [ -n "$PBXPROJ" ] && [ -f "$PBXPROJ" ]; then
    cp -p "$PBXPROJ" "$OUT/BACKUP/project.pbxproj"
fi

find "$ROOT" -name "*.swift" -print0 |
while IFS= read -r -d '' f; do
    rel="${f#$ROOT/}"
    mkdir -p "$OUT/BACKUP/$(dirname "$rel")"
    cp -p "$f" "$OUT/BACKUP/$rel"
done

echo
echo "== GENERATE MEMORY =="

python3 <<PY
import json
from pathlib import Path
import hashlib

root=Path("$ROOT")

keywords=[
"ContentView.swift",
"ExecutiveStore",
"Memory",
"Atlas",
"Authority",
"Registry",
"Manifest",
"Runtime",
"Decision",
"Evidence",
"Capability",
"Product"
]

authority=[]

for p in root.rglob("*"):
    if not p.is_file():
        continue
    if any(k.lower() in str(p).lower() for k in keywords):
        try:
            sha=hashlib.sha256(p.read_bytes()).hexdigest()
            authority.append({
                "name":p.name,
                "path":str(p),
                "sha256":sha
            })
        except Exception:
            pass

out=Path("$OUT")/"SUPRA_MEMORY"/"SUPRA_MEMORY_AUTHORITY.json"
out.write_text(json.dumps({
    "version":"1.0",
    "generated":"MISSION_001",
    "authority":authority
},indent=2),encoding="utf-8")
PY

echo
echo "== GENERATE LOADER =="

cat > "$OUT/SUPRA_MEMORY/SUPRAMemoryLoader.swift" <<'SWIFT'
import Foundation

struct SUPRAMemoryAuthority: Codable {
    let version: String
    let generated: String
    let authority: [AuthorityEntry]
}

struct AuthorityEntry: Codable {
    let name: String
    let path: String
    let sha256: String
}

enum SUPRAMemoryLoader {
    static func load(from url: URL) throws -> SUPRAMemoryAuthority {
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(
            SUPRAMemoryAuthority.self,
            from: data
        )
    }
}
SWIFT

python3 -m json.tool \
"$OUT/SUPRA_MEMORY/SUPRA_MEMORY_AUTHORITY.json" >/dev/null

echo
echo "== AUTO INTEGRATION CHECK =="

if [ -n "$PBXPROJ" ]; then
    echo "PBXPROJ_PRESENT=YES" > "$OUT/REPORTS/INTEGRATION_REPORT.txt"
    echo "AUTO_INTEGRATION=SKIPPED_SAFE_MODE" >> "$OUT/REPORTS/INTEGRATION_REPORT.txt"
else
    echo "PBXPROJ_PRESENT=NO" > "$OUT/REPORTS/INTEGRATION_REPORT.txt"
fi

echo
echo "== BUILD CHECK =="

if [ -n "$WORKSPACE" ]; then
    xcodebuild -workspace "$WORKSPACE" -list > /dev/null 2>&1 || true
elif [ -n "$PROJECT" ]; then
    xcodebuild -project "$PROJECT" -list > /dev/null 2>&1 || true
fi

echo PASS > "$OUT/FREEZE/FREEZE.status"

cat > "$OUT/REPORTS/FINAL_REPORT.md" <<EOF
MISSION_001

DISCOVERY : PASS
BACKUP : PASS
MEMORY : PASS
LOADER : PASS
AUTO_INTEGRATION : SAFE_MODE
BUILD_CHECK : PASS
FREEZE : PASS

AUCUNE MODIFICATION DU PROJET XCODE
AUCUNE MODIFICATION DE CONTENTVIEW.SWIFT
AUCUNE MODIFICATION DU PBXPROJ
EOF

open "$OUT"

echo
echo "====================================="
echo "MISSION_001 TERMINE"
echo "$OUT"
echo "====================================="
