#!/bin/bash
set -Eeuo pipefail

ROOT="$(pwd)"
cd "$ROOT"

mkdir -p .supra_reports

echo "=============================================="
echo "SUPRA RUNTIME BOOTSTRAP DISCOVERY"
echo "=============================================="

echo
echo "[1] Recherche des points de bootstrap..."

grep -RInE \
'@main|App[ ]*:|WindowGroup|ContentView\(|bootstrap|initialize|setup|configure|register|shared|static let shared|MultiMemoryStore.shared|KnowledgeGraph.shared|ConversationMemoryStore.shared' \
. \
--include="*.swift" \
| grep -v ".build/" \
| grep -v "_SUPRA_BACKUPS/" \
| grep -v ".mechanical_extract_backup_" \
> .supra_reports/runtime_bootstrap.txt || true

cat .supra_reports/runtime_bootstrap.txt

echo
echo "[2] Où est créé MultiMemoryStore ?"

grep -RIn "MultiMemoryStore(" . \
--include="*.swift" \
| grep -v ".build/" \
> .supra_reports/create_multimemory.txt || true

cat .supra_reports/create_multimemory.txt

echo
echo "[3] Où est créé ConversationMemoryStore ?"

grep -RIn "ConversationMemoryStore(" . \
--include="*.swift" \
| grep -v ".build/" \
> .supra_reports/create_conversation.txt || true

cat .supra_reports/create_conversation.txt

echo
echo "[4] Où est créé KnowledgeGraph ?"

grep -RIn "KnowledgeGraph(" . \
--include="*.swift" \
| grep -v ".build/" \
> .supra_reports/create_graph.txt || true

cat .supra_reports/create_graph.txt

echo
echo "=============================================="
echo "PROCHAINE ETAPE"
echo "=============================================="
echo "Identifier le fichier unique où les 3 objets"
echo "sont construits afin de les reconnecter."
echo "=============================================="

