#!/bin/bash
# SUPRA Factory Orchestrator V1
# Usage: ./supra-factory.sh [command] [factory_id]
# Commands: status, execute, validate, certify, queue

set -euo pipefail

SUPRA_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FACTORIES_DIR="$SUPRA_ROOT/FACTORIES"

# Factory states file (portable across bash versions)
STATES_FILE="$FACTORIES_DIR/.factory_states"
init_states() {
  if [ ! -f "$STATES_FILE" ]; then
    cat > "$STATES_FILE" << 'EOF'
FACTORY_01_ARCHITECTURE:IDLE
FACTORY_02_DISCOVERY:IDLE
FACTORY_03_RUNTIME:IDLE
FACTORY_04_KNOWLEDGE:IDLE
FACTORY_05_MEMORY:IDLE
FACTORY_06_PROOF:IDLE
FACTORY_07_QUALITY:IDLE
FACTORY_08_DOCUMENTATION:IDLE
FACTORY_09_EXECUTION:IDLE
FACTORY_10_EXECUTIVE:IDLE
EOF
  fi
}

get_state() {
  grep "^$1:" "$STATES_FILE" 2>/dev/null | cut -d: -f2
}

set_state() {
  local id="$1"
  local state="$2"
  if [ -f "$STATES_FILE" ]; then
    sed -i '' "s/^$id:.*/$id:$state/" "$STATES_FILE" 2>/dev/null || \
      sed -i "s/^$id:.*/$id:$state/" "$STATES_FILE"
  fi
}

factory_status() {
  init_states
  echo "╔══════════════════════════════════════════════════════════╗"
  echo "║           SUPRA FACTORY STATUS REPORT                   ║"
  echo "╠══════════════════════════════════════════════════════════╣"
  while IFS=: read -r id state; do
    name="${id#FACTORY_*_}"
    printf "║ %-30s %-25s ║\n" "$id ($name)" "[$state]"
  done < "$STATES_FILE"
  echo "╚══════════════════════════════════════════════════════════╝"
}

factory_execute() {
  local factory_id="$1"
  local factory_dir="$FACTORIES_DIR/$factory_id"
  local gate_dir="$factory_dir/gates"
  local outputs_dir="$factory_dir/outputs"
  local state=""

  init_states

  if [ ! -d "$factory_dir" ]; then
    echo "ERROR: Factory $factory_id not found at $factory_dir"
    exit 1
  fi

  echo "=== Executing $factory_id ==="

  # Phase 1: LOAD
  echo "[LOAD] Validating inputs for $factory_id..."
  if [ -f "$gate_dir/input_gate.sh" ]; then
    if bash "$gate_dir/input_gate.sh" "$factory_id"; then
      set_state "$factory_id" "LOADED"
      echo "[LOAD] INPUT gate PASSED"
    else
      set_state "$factory_id" "BLOCKED"
      echo "[LOAD] INPUT gate BLOCKED"
      return 1
    fi
  else
    echo "[LOAD] No input gate script, assuming PASSED"
    set_state "$factory_id" "LOADED"
  fi

  # Phase 2: EXECUTE
  echo "[EXECUTE] Producing output for $factory_id..."
  if [ -f "$gate_dir/execute.sh" ]; then
    if bash "$gate_dir/execute.sh" "$factory_id"; then
      set_state "$factory_id" "ACTIVE"
      echo "[EXECUTE] Execution PASSED"
    else
      set_state "$factory_id" "FAILED"
      echo "[EXECUTE] Execution FAILED"
      return 1
    fi
  else
    echo "[EXECUTE] No execute script, assuming PASSED"
    set_state "$factory_id" "ACTIVE"
  fi

  # Phase 3: VALIDATE
  echo "[VALIDATE] Validating output of $factory_id..."
  if [ -f "$gate_dir/output_gate.sh" ]; then
    if bash "$gate_dir/output_gate.sh" "$factory_id"; then
      set_state "$factory_id" "VALIDATING"
      echo "[VALIDATE] OUTPUT gate PASSED"
    else
      set_state "$factory_id" "FAILED"
      echo "[VALIDATE] OUTPUT gate FAILED"
      return 1
    fi
  else
    echo "[VALIDATE] No output gate script, assuming PASSED"
    set_state "$factory_id" "VALIDATING"
  fi

  # Phase 4: CERTIFY
  echo "[CERTIFY] Certifying output of $factory_id..."
  set_state "$factory_id" "CERTIFIED"
  echo "[CERTIFY] $factory_id CERTIFIED"
}

factory_queue() {
  echo "=== FACTORY QUEUE ==="
  local queue_file="$FACTORIES_DIR/FACTORY_09_EXECUTION/outputs/FACTORY_QUEUE.md"
  if [ -f "$queue_file" ]; then
    cat "$queue_file"
  else
    echo "No queue file found. Factories are IDLE."
  fi
}

case "${1:-status}" in
  status)
    factory_status
    ;;
  execute)
    if [ -z "${2:-}" ]; then
      echo "Usage: $0 execute <factory_id>"
      echo "Available: FACTORY_01_ARCHITECTURE FACTORY_02_DISCOVERY FACTORY_03_RUNTIME FACTORY_04_KNOWLEDGE FACTORY_05_MEMORY FACTORY_06_PROOF FACTORY_07_QUALITY FACTORY_08_DOCUMENTATION FACTORY_09_EXECUTION FACTORY_10_EXECUTIVE"
      exit 1
    fi
    factory_execute "$2"
    ;;
  queue)
    factory_queue
    ;;
  *)
    echo "Usage: $0 {status|execute <factory_id>|queue}"
    exit 1
    ;;
esac
