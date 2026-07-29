#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="/Users/nicolasalonso/NOVA_OS"
OUT="$ROOT/SUPRA_INDEX"

mkdir -p "$OUT/schema"

cat > "$OUT/schema/INDEX_SCHEMA.json" <<'EOF'
{
  "version":"1.0",
  "authority":"SUPRA",
  "objects":[
    "Project",
    "Module",
    "Capability",
    "Product",
    "Evidence",
    "Decision",
    "Mission",
    "Memory",
    "Knowledge",
    "Atlas",
    "Registry"
  ],
  "mandatoryFields":[
    "id",
    "type",
    "canonicalName",
    "authority",
    "source",
    "path",
    "hash",
    "createdAt",
    "updatedAt",
    "status"
  ],
  "relations":[
    "DEPENDS_ON",
    "IMPLEMENTS",
    "USES",
    "PRODUCES",
    "REFERENCES",
    "SUPERSEDES",
    "BELONGS_TO"
  ]
}
EOF

cat > "$OUT/schema/INDEX_CONTRACT.md" <<'EOF'
RULE_001
Filesystem accessible uniquement par INDEX_BUILDER.

RULE_002
Runtime lit uniquement INDEX.

RULE_003
Mission Center lit uniquement INDEX.

RULE_004
Megabus lit uniquement INDEX.

RULE_005
Knowledge Compiler lit uniquement INDEX.

RULE_006
Executive UI lit uniquement INDEX.

RULE_007
Aucun scan disque hors INDEX_BUILDER.

RULE_008
Toute recherche passe par INDEX.
EOF

echo
echo "=================================="
echo "PHASE 0 : INDEX SCHEMA"
echo "STATUS : PASS"
echo "=================================="
echo
echo "$OUT/schema/INDEX_SCHEMA.json"
echo "$OUT/schema/INDEX_CONTRACT.md"
