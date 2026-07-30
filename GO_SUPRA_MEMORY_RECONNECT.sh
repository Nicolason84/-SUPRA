#!/bin/bash
set -Eeuo pipefail

echo "========================================================"
echo "      GO_SUPRA_MEMORY_RECONNECT"
echo "========================================================"

ROOT="$(pwd)"
cd "$ROOT"

REPORT=".supra_reports"
mkdir -p "$REPORT"

echo
echo "[1/7] Recherche des composants mémoire..."

find . -type f $begin:math:text$ \-name \"\*\.swift\" \-o \-name \"\*\.json\" $end:math:text$ \
| grep -Ei \
"ConversationMemoryStore|MultiMemoryStore|KnowledgeGraph|ProjectMemoryStore|MissionMemoryStore|WorkspaceMemoryStore|RuntimeMemoryStore|MemoryStore" \
> "$REPORT/memory_components.txt" || true

cat "$REPORT/memory_components.txt"

echo
echo "[2/7] Vérification ConversationMemoryStore..."

grep -RIn \
"ConversationMemoryStore" . \
--include="*.swift" \
> "$REPORT/conversation_store_refs.txt" || true

cat "$REPORT/conversation_store_refs.txt"

echo
echo "[3/7] Vérification MultiMemoryStore..."

grep -RIn \
"MultiMemoryStore" . \
--include="*.swift" \
> "$REPORT/multi_store_refs.txt" || true

cat "$REPORT/multi_store_refs.txt"

echo
echo "[4/7] Vérification KnowledgeGraph..."

grep -RIn \
"KnowledgeGraph" . \
--include="*.swift" \
> "$REPORT/knowledge_graph_refs.txt" || true

cat "$REPORT/knowledge_graph_refs.txt"

echo
echo "[5/7] Recherche des enregistrements (register/add/connect)..."

grep -RInE \
"register|addStore|appendStore|attach|connect|bind|bootstrap|initialize|shared" . \
--include="*.swift" \
> "$REPORT/runtime_bindings.txt" || true

cat "$REPORT/runtime_bindings.txt"

echo
echo "[6/7] Recherche des points d'indexation..."

grep -RInE \
"index|indexAll|reindex|refresh|reload|scan|discover|bootstrap|loadAll|loadConversations|generateAllSummaries|connectToKnowledgeGraph" . \
--include="*.swift" \
> "$REPORT/indexers.txt" || true

cat "$REPORT/indexers.txt"

echo
echo "[7/7] Synthèse"

echo "ConversationMemoryStore : $(grep -c ConversationMemoryStore "$REPORT/conversation_store_refs.txt" 2>/dev/null || echo 0)"
echo "MultiMemoryStore        : $(grep -c MultiMemoryStore "$REPORT/multi_store_refs.txt" 2>/dev/null || echo 0)"
echo "KnowledgeGraph          : $(grep -c KnowledgeGraph "$REPORT/knowledge_graph_refs.txt" 2>/dev/null || echo 0)"
echo "Bindings Runtime        : $(wc -l < "$REPORT/runtime_bindings.txt" 2>/dev/null || echo 0)"
echo "Indexers                : $(wc -l < "$REPORT/indexers.txt" 2>/dev/null || echo 0)"

echo
echo "Rapports disponibles dans : $REPORT"

echo
echo "========================================================"
echo "MISSION SUIVANTE"
echo "========================================================"
echo "1. Rebrancher ConversationMemoryStore"
echo "2. Rattacher tous les stores au MultiMemoryStore"
echo "3. Reconnecter KnowledgeGraph"
echo "4. Relancer l'indexation"
echo "========================================================"
