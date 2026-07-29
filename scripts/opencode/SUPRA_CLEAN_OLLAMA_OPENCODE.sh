#!/usr/bin/env bash
set -euo pipefail

PROJECT="$HOME/Desktop/NOVA_OS/SUPRA_DEEPSEEK_EXIT_READINESS"
MODEL="OLLAMA_LOCAL/qwen3-coder"
OLLAMA_MODEL="qwen3-coder:latest"
LOG_DIR="$HOME/Desktop/SUPRA_RUNTIME_CLEANUP_$(date +%Y%m%d_%H%M%S)"

mkdir -p "$LOG_DIR"

echo "=================================================="
echo "SUPRA — CLEAN OLLAMA + OPENCODE RUNTIME"
echo "=================================================="

echo
echo "[1/6] ARRÊT DE TOUS LES PROCESSUS OPENCODE"

pkill -TERM -x opencode 2>/dev/null || true
sleep 3
pkill -KILL -x opencode 2>/dev/null || true

echo
echo "[2/6] ARRÊT DE TOUS LES SERVEURS OLLAMA ET RUNNERS"

ollama stop "$OLLAMA_MODEL" 2>/dev/null || true
ollama stop "qwen3:4b-instruct" 2>/dev/null || true
ollama stop "qwen3:4b" 2>/dev/null || true

pkill -TERM -f '/Applications/Ollama.app/Contents/Resources/ollama serve' 2>/dev/null || true
pkill -TERM -f '/Applications/Ollama.app/Contents/Resources/llama-server' 2>/dev/null || true
pkill -TERM -f 'ollama serve' 2>/dev/null || true

sleep 5

pkill -KILL -f '/Applications/Ollama.app/Contents/Resources/ollama serve' 2>/dev/null || true
pkill -KILL -f '/Applications/Ollama.app/Contents/Resources/llama-server' 2>/dev/null || true
pkill -KILL -f 'ollama serve' 2>/dev/null || true

echo
echo "[3/6] VÉRIFICATION DE L'ÉTAT PROPRE"

{
  echo "===== OPENCODE ====="
  pgrep -af opencode || true

  echo
  echo "===== OLLAMA SERVE ====="
  pgrep -af 'ollama serve' || true

  echo
  echo "===== LLAMA SERVER ====="
  pgrep -af llama-server || true
} | tee "$LOG_DIR/processes_after_stop.txt"

if pgrep -x opencode >/dev/null 2>&1; then
  echo "ERREUR: un processus OpenCode est encore actif."
  exit 1
fi

if pgrep -f 'ollama serve' >/dev/null 2>&1; then
  echo "ERREUR: un processus ollama serve est encore actif."
  exit 1
fi

if pgrep -f llama-server >/dev/null 2>&1; then
  echo "ERREUR: un llama-server est encore actif."
  exit 1
fi

echo "ÉTAT PROPRE VALIDÉ"

echo
echo "[4/6] RELANCE D'UN SEUL SERVEUR OLLAMA"

export OLLAMA_HOST="127.0.0.1:11434"
export OLLAMA_CONTEXT_LENGTH="65536"

nohup ollama serve \
  >"$LOG_DIR/ollama_server.stdout.log" \
  2>"$LOG_DIR/ollama_server.stderr.log" &

OLLAMA_PID=$!
echo "$OLLAMA_PID" > "$LOG_DIR/ollama_server.pid"

for i in $(seq 1 30); do
  if curl -fsS http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

if ! curl -fsS http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
  echo "ERREUR: Ollama ne répond pas sur le port 11434."
  tail -100 "$LOG_DIR/ollama_server.stderr.log" || true
  exit 1
fi

SERVE_COUNT="$(pgrep -af 'ollama serve' | grep -v grep | wc -l | tr -d ' ')"

echo "OLLAMA_SERVE_COUNT=$SERVE_COUNT"

if [ "$SERVE_COUNT" -ne 1 ]; then
  echo "ERREUR: $SERVE_COUNT processus ollama serve détecté(s), attendu: 1."
  pgrep -af 'ollama serve' || true
  exit 1
fi

echo
echo "[5/6] CHARGEMENT ET VÉRIFICATION DU RUNNER UNIQUE"

curl --max-time 300 -fsS \
  http://127.0.0.1:11434/api/generate \
  -H 'Content-Type: application/json' \
  -d "{
    \"model\":\"$OLLAMA_MODEL\",
    \"prompt\":\"Reply ONLY with READY\",
    \"stream\":false,
    \"keep_alive\":\"10m\",
    \"options\":{
      \"num_ctx\":65536
    }
  }" | tee "$LOG_DIR/ollama_model_test.json"

echo
echo
ollama ps | tee "$LOG_DIR/ollama_ps.txt"

RUNNER_COUNT="$(ollama ps 2>/dev/null | tail -n +2 | grep -c '[^[:space:]]' || true)"

if [ "$RUNNER_COUNT" -ne 1 ]; then
  echo "ERREUR: $RUNNER_COUNT runner(s) détecté(s), attendu: 1."
  exit 1
fi

echo "RUNNER UNIQUE VALIDÉ"

echo
echo "[6/6] LANCEMENT D'UNE SEULE INSTANCE OPENCODE"

if [ ! -d "$PROJECT" ]; then
  echo "ERREUR: projet introuvable:"
  echo "$PROJECT"
  exit 1
fi

cd "$PROJECT"

echo
echo "CONFIGURATION EFFECTIVE:"
opencode debug config |
  grep -E '"model"|"small_model"' |
  tee "$LOG_DIR/opencode_effective_model.txt" || true

echo
echo "LANCEMENT:"
echo "opencode . --model $MODEL"
echo
echo "LOGS DE CETTE OPÉRATION:"
echo "$LOG_DIR"
echo

exec opencode . \
  --model "$MODEL" \
  --log-level INFO
