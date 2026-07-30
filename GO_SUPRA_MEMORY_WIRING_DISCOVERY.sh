#!/bin/bash
set -Eeuo pipefail

ROOT="$(pwd)"
cd "$ROOT"

mkdir -p .supra_reports

echo "========================================"
echo "SUPRA MEMORY WIRING DISCOVERY"
echo "========================================"

echo
echo "[1] MultiMemoryStore API"

grep -nE \
'func |register|add|append|attach|bind|connect|provider|graph|store|memory' \
SUPRA/MultiMemoryStore.swift \
> .supra_reports/multimemory_api.txt || true

cat .supra_reports/multimemory_api.txt

echo
echo "[2] ConversationMemoryStore API"

grep -nE \
'func |startAutoRefresh|connectToKnowledgeGraph|generateAllSummaries|load|refresh|index' \
SUPRA/ConversationMemoryStore.swift \
> .supra_reports/conversation_api.txt || true

cat .supra_reports/conversation_api.txt

echo
echo "[3] KnowledgeGraph API"

grep -nE \
'func |register|provider|connect|bind|graph|memory|store' \
SUPRA/KnowledgeGraph.swift \
> .supra_reports/knowledge_api.txt || true

cat .supra_reports/knowledge_api.txt

echo
echo "[4] App bootstrap"

sed -n '1,220p' SUPRA/SUPRAOperationalCoreApp.swift \
> .supra_reports/app_bootstrap.txt

cat .supra_reports/app_bootstrap.txt

echo
echo "========================================"
echo "READY FOR PATCH"
echo "========================================"

