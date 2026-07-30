#!/bin/bash
set -Eeuo pipefail

ROOT="$(pwd)"
cd "$ROOT"

mkdir -p .supra_reports

echo "============================================="
echo "SUPRA SINGLETON DISCOVERY"
echo "============================================="

echo
echo "[1] KnowledgeGraph"

grep -RIn \
"static let shared" . \
--include="*.swift" \
| grep "KnowledgeGraph" \
> .supra_reports/kg_singleton.txt || true

cat .supra_reports/kg_singleton.txt

echo
echo "[2] DecisionStore"

grep -RIn \
"static let shared" . \
--include="*.swift" \
| grep "DecisionStore" \
> .supra_reports/decision_singleton.txt || true

cat .supra_reports/decision_singleton.txt

echo
echo "[3] MissionStore"

grep -RIn \
"static let shared" . \
--include="*.swift" \
| grep "MissionStore" \
> .supra_reports/mission_singleton.txt || true

cat .supra_reports/mission_singleton.txt

echo
echo "[4] Constructeurs"

grep -RInE \
"class KnowledgeGraph|class DecisionStore|class MissionStore|actor KnowledgeGraph|actor DecisionStore|actor MissionStore|struct KnowledgeGraph|struct DecisionStore|struct MissionStore" \
. \
--include="*.swift" \
> .supra_reports/store_definitions.txt || true

cat .supra_reports/store_definitions.txt

echo
echo "[5] Configure()"

grep -RIn \
"configure(knowledgeGraph" . \
--include="*.swift" \
> .supra_reports/configure_calls.txt || true

cat .supra_reports/configure_calls.txt

echo
echo "============================================="
echo "READY FOR FINAL PATCH"
echo "============================================="

