#!/bin/bash
set -Eeuo pipefail

ROOT="$(pwd)"
cd "$ROOT"

mkdir -p .supra_reports

echo "=============================================="
echo "SUPRA INSTANCE DISCOVERY"
echo "=============================================="

echo
echo "[1] Instanciations KnowledgeGraph"

grep -RIn \
"KnowledgeGraph(" . \
--include="*.swift" \
| grep -v ".build/" \
| grep -v ".supra_reports/" \
> .supra_reports/kg_instances.txt || true

cat .supra_reports/kg_instances.txt

echo
echo "[2] Instanciations DecisionStore"

grep -RIn \
"DecisionStore(" . \
--include="*.swift" \
| grep -v ".build/" \
| grep -v ".supra_reports/" \
> .supra_reports/decision_instances.txt || true

cat .supra_reports/decision_instances.txt

echo
echo "[3] Instanciations MissionStore"

grep -RIn \
"MissionStore(" . \
--include="*.swift" \
| grep -v ".build/" \
| grep -v ".supra_reports/" \
> .supra_reports/mission_instances.txt || true

cat .supra_reports/mission_instances.txt

echo
echo "[4] Variables stockant ces instances"

grep -RInE \
"let .*KnowledgeGraph|var .*KnowledgeGraph|let .*DecisionStore|var .*DecisionStore|let .*MissionStore|var .*MissionStore" \
. \
--include="*.swift" \
| grep -v ".build/" \
> .supra_reports/store_variables.txt || true

cat .supra_reports/store_variables.txt

echo
echo
echo "=============================================="
echo "DISCOVERY COMPLETE"
echo "=============================================="
