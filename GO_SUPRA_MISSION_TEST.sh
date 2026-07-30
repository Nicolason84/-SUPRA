#!/usr/bin/env bash

set -Eeuo pipefail

MODEL="OLLAMA_LOCAL/qwen3:4b-instruct"

echo "=========================================="
echo "SUPRA MISSION TEST"
echo "=========================================="

TMP="$(mktemp)"

if opencode run \
    --auto \
    --model "$MODEL" \
    "Reply ONLY with the word READY." \
    >"$TMP" 2>&1
then
    if grep -qi "^READY" "$TMP"; then
        echo
        echo "✅ OpenCode répond correctement."
        echo
        cat "$TMP"
        rm -f "$TMP"
        exit 0
    else
        echo
        echo "⚠️ Mission exécutée mais réponse inattendue :"
        echo
        cat "$TMP"
        rm -f "$TMP"
        exit 2
    fi
else
    RC=$?

    echo
    echo "❌ Échec OpenCode (code $RC)"
    echo
    cat "$TMP"

    rm -f "$TMP"

    exit $RC
fi

