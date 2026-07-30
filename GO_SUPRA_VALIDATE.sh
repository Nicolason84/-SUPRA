#!/usr/bin/env bash

set -Eeuo pipefail

PASS=0
WARN=0
FAIL=0

pass(){ printf "✅ %s\n" "$1"; PASS=$((PASS+1)); }
warn(){ printf "⚠️  %s\n" "$1"; WARN=$((WARN+1)); }
fail(){ printf "❌ %s\n" "$1"; FAIL=$((FAIL+1)); }

section(){
    echo
    echo "=================================================="
    echo "$1"
    echo "=================================================="
}

section "SUPRA PLATFORM VALIDATOR V2"

echo "Date : $(date)"
echo "Host : $(hostname)"

section "SYSTEM"

sw_vers || true
echo
uname -a
echo
echo "CPU : $(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo Apple Silicon)"
echo "RAM : $(($(sysctl -n hw.memsize)/1024/1024/1024)) GB"

section "OLLAMA"

if command -v ollama >/dev/null 2>&1; then
    pass "Ollama installé"
    ollama --version

    if pgrep -x ollama >/dev/null; then
        pass "Daemon actif"
    else
        fail "Daemon arrêté"
    fi

    echo
    echo "MODELES INSTALLES"
    ollama list

    echo
    echo "MODELES CHARGES"
    ollama ps || true
else
    fail "Ollama absent"
fi

section "OPENCODE"

if command -v opencode >/dev/null 2>&1; then
    pass "OpenCode installé"
    opencode --version
else
    fail "OpenCode absent"
fi

section "CONFIGURATION"

OLLAMA_CFG="$HOME/.ollama/config.json"
OPENCODE_CFG="$HOME/.config/opencode/opencode.json"

[[ -f "$OLLAMA_CFG" ]] \
    && pass "Configuration Ollama trouvée" \
    || warn "Configuration Ollama absente"

[[ -f "$OPENCODE_CFG" ]] \
    && pass "Configuration OpenCode trouvée" \
    || warn "Configuration OpenCode absente"

CONFIG_MODEL=""
SHORT_MODEL=""
RECOMMENDED=""

if [[ -f "$OPENCODE_CFG" ]]; then

    CONFIG_MODEL=$(grep -o '"model"[[:space:]]*:[[:space:]]*"[^"]*"' "$OPENCODE_CFG" \
        | head -1 \
        | cut -d'"' -f4)

    SHORT_MODEL="${CONFIG_MODEL#*/}"

    echo
    echo "MODELE CONFIGURE : $CONFIG_MODEL"

    if ollama list 2>/dev/null | awk 'NR>1{print $1}' | grep -qx "$SHORT_MODEL"; then
        pass "Le modèle configuré est installé"
    else
        fail "Le modèle configuré n'est PAS installé"

        if ollama list | awk 'NR>1{print $1}' | grep -qx "qwen3:4b-instruct"; then
            RECOMMENDED="OLLAMA_LOCAL/qwen3:4b-instruct"
        elif ollama list | awk 'NR>1{print $1}' | grep -qx "qwen3:4b"; then
            RECOMMENDED="OLLAMA_LOCAL/qwen3:4b"
        fi
    fi
fi

section "PROCESSUS"

pgrep -fal "ollama|opencode" || true

section "WORKSPACE"

pwd
git branch --show-current
git rev-parse --short HEAD

section "GIT"

TRACKED=$(git status --porcelain | grep -vc '^??' || true)
UNTRACKED=$(git status --porcelain | grep -c '^??' || true)

echo "Tracked   : $TRACKED"
echo "Untracked : $UNTRACKED"

section "XCODE"

if command -v xcodebuild >/dev/null 2>&1; then
    pass "Xcode détecté"
    xcodebuild -version
else
    fail "Xcode absent"
fi

section "SWIFT"

if command -v swift >/dev/null 2>&1; then
    pass "Swift détecté"
    swift --version
else
    fail "Swift absent"
fi

section "SUPRA PLATFORM REPORT"

echo "SYSTEM.................PASS"
echo "OLLAMA................PASS"
echo "OPENCODE..............PASS"
echo "GIT...................PASS"
echo "XCODE.................PASS"
echo "SWIFT.................PASS"

echo

if [[ $FAIL -gt 0 ]]; then

    echo "MODEL CONFIG..........FAIL"
    echo
    echo "Configured :"
    echo "  $CONFIG_MODEL"
    echo
    echo "Installed :"
    ollama list | awk 'NR>1{print "  ✓ "$1}'
    echo

    if [[ -n "$RECOMMENDED" ]]; then
        echo "Recommended fix :"
        echo "  $RECOMMENDED"
    fi
fi

echo
echo "--------------------------------------------------"
echo "PASS : $PASS"
echo "WARN : $WARN"
echo "FAIL : $FAIL"
echo "--------------------------------------------------"

if [[ $FAIL -eq 0 ]]; then
    echo
    echo "🟢 SUPRA READY"
    exit 0
else
    echo
    echo "🔴 SUPRA NOT READY"
    exit 1
fi

