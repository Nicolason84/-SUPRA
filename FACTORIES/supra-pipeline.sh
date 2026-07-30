#!/bin/bash
# SUPRA Full Pipeline Orchestrator V1
# Executes the complete factory pipeline from Mission to Executive Decision
# Usage: ./supra-pipeline.sh [--mission "mission description"]

set -euo pipefail

SUPRA_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FACTORY_BIN="$SUPRA_ROOT/FACTORIES/supra-factory.sh"
MISSION="${1:-"SUPRA ULTIMATE CONSOLIDATED V1 — Standard Execution Cycle"}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "╔══════════════════════════════════════════════════════════╗"
echo "║        SUPRA AUTONOMOUS SOFTWARE FACTORY - PIPELINE     ║"
echo "╠══════════════════════════════════════════════════════════╣"
echo "║ Mission: $MISSION"
echo "║ Started: $TIMESTAMP"
echo "╚══════════════════════════════════════════════════════════╝"

# Step 1: Executive Decision
echo ""
echo "=== STEP 1: FACTORY_10_EXECUTIVE (Initial Decision) ==="
bash "$FACTORY_BIN" execute FACTORY_10_EXECUTIVE

# Step 2: Execution Plan
echo ""
echo "=== STEP 2: FACTORY_09_EXECUTION (Plan) ==="
bash "$FACTORY_BIN" execute FACTORY_09_EXECUTION

# Step 3: Architecture + Discovery (parallel)
echo ""
echo "=== STEP 3: FACTORY_01_ARCHITECTURE + FACTORY_02_DISCOVERY ==="
bash "$FACTORY_BIN" execute FACTORY_01_ARCHITECTURE &
ARCH_PID=$!
bash "$FACTORY_BIN" execute FACTORY_02_DISCOVERY &
DISC_PID=$!
wait $ARCH_PID
wait $DISC_PID

# Step 4: Knowledge + Runtime (parallel, after arch+disc)
echo ""
echo "=== STEP 4: FACTORY_03_RUNTIME + FACTORY_04_KNOWLEDGE ==="
bash "$FACTORY_BIN" execute FACTORY_03_RUNTIME &
RUNTIME_PID=$!
bash "$FACTORY_BIN" execute FACTORY_04_KNOWLEDGE &
KNOW_PID=$!
wait $RUNTIME_PID
wait $KNOW_PID

# Step 5: Memory + Proof (parallel)
echo ""
echo "=== STEP 5: FACTORY_05_MEMORY + FACTORY_06_PROOF ==="
bash "$FACTORY_BIN" execute FACTORY_05_MEMORY &
MEM_PID=$!
bash "$FACTORY_BIN" execute FACTORY_06_PROOF &
PROOF_PID=$!
wait $MEM_PID
wait $PROOF_PID

# Step 6: Quality
echo ""
echo "=== STEP 6: FACTORY_07_QUALITY ==="
bash "$FACTORY_BIN" execute FACTORY_07_QUALITY

# Step 7: Documentation
echo ""
echo "=== STEP 7: FACTORY_08_DOCUMENTATION ==="
bash "$FACTORY_BIN" execute FACTORY_08_DOCUMENTATION

# Step 8: Final Executive Decision
echo ""
echo "=== STEP 8: FACTORY_10_EXECUTIVE (Final Decision) ==="
bash "$FACTORY_BIN" execute FACTORY_10_EXECUTIVE

# Done
echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║           PIPELINE COMPLETE                              ║"
echo "║           $TIMESTAMP"
echo "╚══════════════════════════════════════════════════════════╝"

bash "$FACTORY_BIN" status
