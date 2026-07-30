#!/usr/bin/env bash

set -Eeuo pipefail

PASS=0
WARN=0
FAIL=0

pass(){ printf "✅ %s\n" "$1"; PASS=$((PASS+1)); }
warn(){ printf "⚠️  %s\n" "$1"; WARN=$((WARN+1)); }
fail(){ printf "❌ %s\n" "$1"; FAIL=$((FAIL+1)); }

section() {
    echo
    echo "=================================================="
    echo "$1"
    echo "=================================================="
}

section "SUPRA PLATFORM VALIDATOR V3"

echo "DATE : $(date)"
echo "HOST : $(hostname)"

###############################################################################
section "SYSTEM"
###############################################################################

sw_vers || true
uname -a

###############################################################################
section "OLLAMA"
###############################################################################

if command -v ollama >/dev/null 2>&1; then
    pass "Ollama installé"
    ollama --version

    if pgrep -x ollama >/dev/null; then
        pass "Daemon Ollama actif"
    else
        fail "Daemon Ollama inactif"
    fi

    echo
    echo "MODELES INSTALLES"
    ollama list

else
    fail "Ollama absent"
fi

###############################################################################
section "API OLLAMA"
###############################################################################

if curl -fs http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    pass "API Ollama accessible"
else
    fail "API Ollama inaccessible"
fi

###############################################################################
section "OPENCODE"
###############################################################################

if command -v opencode >/dev/null 2>&1; then
    pass "OpenCode installé"
    opencode --version

    if opencode --help >/dev/null 2>&1; then
        pass "CLI OpenCode opérationnelle"
    else
        fail "CLI OpenCode indisponible"
    fi
else
    fail "OpenCode absent"
fi

###############################################################################
section "CONFIGURATION"
###############################################################################

CFG="$HOME/.config/opencode/opencode.json"

if [[ -f "$CFG" ]]; then
    pass "Configuration OpenCode trouvée"

    MODEL=$(python3 - <<PY
import json
with open("$CFG") as f:
    print(json.load(f).get("model",""))
PY
)

    echo
    echo "MODELE CONFIGURE : $MODEL"

    SHORT="${MODEL#*/}"

    if ollama list | awk 'NR>1{print $1}' | grep -qx "$SHORT"; then
        pass "Le modèle configuré est installé"
    else
        fail "Le modèle configuré est absent"
    fi

else
    fail "Configuration OpenCode absente"
fi

###############################################################################
section "GIT"
###############################################################################

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then

    pass "Repository Git détecté"

    echo "Branch : $(git branch --show-current)"
    echo "HEAD   : $(git rev-parse --short HEAD)"

else

    fail "Pas de dépôt Git"

fi

###############################################################################
section "XCODE"
###############################################################################

if command -v xcodebuild >/dev/null; then
    pass "Xcode détecté"
else
    fail "Xcode absent"
fi

###############################################################################
section "SWIFT"
###############################################################################

if command -v swift >/dev/null; then
    pass "Swift détecté"
else
    fail "Swift absent"
fi

###############################################################################
section "MISSION TEST"
###############################################################################

TMPFILE="$(mktemp)"

if timeout 30 opencode run \
    --model "$MODEL" \
    "Reply ONLY with the word READY." >"$TMPFILE" 2>/dev/null; then

    if grep -qi READY "$TMPFILE"; then
        pass "Mission READ_ONLY réussie"
    else
        warn "Mission exécutée mais réponse inattendue"
    fi

else
    fail "Impossible d'exécuter une mission OpenCode"
fi

rm -f "$TMPFILE"

###############################################################################
section "SUPRA PLATFORM REPORT"
###############################################################################

echo "PASS : $PASS"
echo "WARN : $WARN"
echo "FAIL : $FAIL"

echo

if [[ $FAIL -eq 0 ]]; then
    echo "🟢 SUPRA READY"
    exit 0
else
    echo "🔴 SUPRA NOT READY"
    exit 1
fi

