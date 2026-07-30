#!/bin/bash
set -Eeuo pipefail

ROOT="$(pwd)"
cd "$ROOT"

mkdir -p .supra_reports

echo "=============================================="
echo "SUPRA INSTANCE AUDIT"
echo "=============================================="

echo
echo "[1] Toutes les créations de MissionStore"
grep -RIn "MissionStore()" . \
  --include="*.swift" \
  | grep -v ".build/" \
  | tee .supra_reports/mission_instances.txt

echo
echo "[2] Toutes les créations de DecisionStore"
grep -RIn "DecisionStore()" . \
  --include="*.swift" \
  | grep -v ".build/" \
  | tee .supra_reports/decision_instances.txt

echo
echo "[3] Toutes les créations de KnowledgeGraph"
grep -RIn "KnowledgeGraph()" . \
  --include="*.swift" \
  | grep -v ".build/" \
  | tee .supra_reports/kg_instances.txt

echo
echo "[4] Toutes les injections configure(...)"
grep -RIn "configure(knowledgeGraph:" . \
  --include="*.swift" \
  | tee .supra_reports/configure.txt

echo
echo "[5] Résumé"

echo "MissionStore  : $(wc -l < .supra_reports/mission_instances.txt)"
echo "DecisionStore : $(wc -l < .supra_reports/decision_instances.txt)"
echo "KnowledgeGraph: $(wc -l < .supra_reports/kg_instances.txt)"
echo "Configure()   : $(wc -l < .supra_reports/configure.txt)"

echo
echo "=============================================="
echo "SI MissionStore > 1 OU DecisionStore > 1"
echo "=> DUPLICATION D'INSTANCES"
echo "=============================================="
