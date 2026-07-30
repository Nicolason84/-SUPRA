#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_VERSION="2.0.0"

PASS=0
FAIL=0

pass() {
    printf "✅ %s\n" "$1"
    PASS=$((PASS+1))
}

fail() {
    printf "❌ %s\n" "$1"
    FAIL=$((FAIL+1))
}

section() {
    echo
    echo "=================================================="
    echo "$1"
    echo "=================================================="
}

ROOT="$HOME/Desktop/NOVA_OS/SUPRA"
CONFIG_DIR="$HOME/.config/opencode"
CONFIG_FILE="$CONFIG_DIR/opencode.json"
REPORT="$HOME/Desktop/SUPRA_INSTALL_REPORT.md"

mkdir -p "$CONFIG_DIR"

section "SUPRA INSTALLER V2"

echo "Version : $SCRIPT_VERSION"

############################################

section "PRECHECK"

command -v bash >/dev/null && pass "bash" || fail "bash"

command -v git >/dev/null && pass "git" || fail "git"

command -v curl >/dev/null && pass "curl" || fail "curl"

command -v ollama >/dev/null && pass "ollama" || fail "ollama"

command -v opencode >/dev/null && pass "opencode" || fail "opencode"

############################################

section "OLLAMA"

if ! pgrep -x ollama >/dev/null 2>&1
then
    ollama serve >/dev/null 2>&1 &
    sleep 3
fi

if curl -fs http://127.0.0.1:11434/api/tags >/dev/null
then
    pass "API Ollama"
else
    fail "API Ollama"
fi

############################################

section "MODEL"

MODEL="$(ollama list 2>/dev/null | awk 'NR==2{print $1}')"

if [ -z "${MODEL:-}" ]
then
    MODEL="qwen3:4b"
    echo "Installation de $MODEL"
    ollama pull "$MODEL"
fi

echo "MODEL=$MODEL"

pass "Modèle détecté"

############################################

section "CONFIG"

mkdir -p "$CONFIG_DIR"

cat > "$CONFIG_FILE" <<EOF
{
  "\$schema":"https://opencode.ai/config.json",
  "provider":{
    "OLLAMA_LOCAL":{
      "npm":"@ai-sdk/openai-compatible",
      "options":{
        "baseURL":"http://127.0.0.1:11434/v1"
      },
      "models":{
        "$MODEL":{
          "name":"$MODEL"
        }
      }
    }
  },
  "model":"OLLAMA_LOCAL/$MODEL"
}
EOF

[ -f "$CONFIG_FILE" ] \
&& pass "Configuration OpenCode" \
|| fail "Configuration OpenCode"

############################################

section "WORKSPACE"

for d in \
Missions \
Reports \
Evidence \
Logs \
Freeze \
Inbox \
Outbox
do
    mkdir -p "$ROOT/$d"
done

pass "Arborescence"

############################################

section "TEST"

if opencode --help >/dev/null 2>&1
then
    pass "CLI OpenCode"
else
    fail "CLI OpenCode"
fi

############################################

section "REPORT"

{
echo "# SUPRA INSTALL REPORT"
echo
echo "Version : $SCRIPT_VERSION"
echo
echo "PASS : $PASS"
echo
echo "FAIL : $FAIL"
echo
if [ "$FAIL" -eq 0 ]
then
echo "GLOBAL RESULT : PASS"
else
echo "GLOBAL RESULT : FAIL"
fi
} > "$REPORT"

############################################

section "RESULT"

echo

echo "PASS : $PASS"

echo "FAIL : $FAIL"

echo

if [ "$FAIL" -eq 0 ]
then
    echo "==============================="
    echo "SUPRA READY"
    echo "GO_SUPRA.sh PEUT ÊTRE CRÉÉ"
    echo "==============================="
    exit 0
else
    echo "==============================="
    echo "INSTALLATION INCOMPLÈTE"
    echo "==============================="
    exit 1
fi
