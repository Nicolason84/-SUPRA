#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$HOME/Desktop/NOVA_OS/SUPRA"
RUNTIME="$ROOT/SUPRA_RUNTIME"

mkdir -p \
"$RUNTIME"/{Inbox,Running,Done,Blocked,Reports,Logs}

cd "$ROOT"

echo "========================================"
echo " SUPRA PARALLEL V1"
echo "========================================"

###########################################
# OLLAMA
###########################################

if ! pgrep -x ollama >/dev/null 2>&1
then
    echo "Starting Ollama..."
    ollama serve >/dev/null 2>&1 &
    sleep 3
fi

###########################################
# OPENCODE SERVER
###########################################

if ! lsof -i:4096 >/dev/null 2>&1
then
    echo "Starting OpenCode server..."
    nohup opencode serve --port 4096 \
        >"$RUNTIME/Logs/opencode_server.log" \
        2>&1 &
    sleep 5
fi

###########################################
# FIND MISSION
###########################################

MISSION="$(ls -t "$RUNTIME"/Inbox/* 2>/dev/null | head -1 || true)"

if [ -z "$MISSION" ]
then
    echo "No mission found."
    exit 0
fi

cp "$MISSION" "$RUNTIME/Running/"

###########################################
# ARCHITECT
###########################################

(
opencode run \
--attach http://localhost:4096 \
--file "$MISSION" \
--title Architect \
"Analyse la mission. Produit uniquement un plan." \
> "$RUNTIME/Reports/architect.md"
) &

###########################################
# BUILDER
###########################################

(
opencode run \
--attach http://localhost:4096 \
--file "$MISSION" \
--title Builder \
"Implémente les modifications demandées." \
> "$RUNTIME/Reports/builder.md"
) &

###########################################
# AUDITOR
###########################################

(
opencode run \
--attach http://localhost:4096 \
--file "$MISSION" \
--title Auditor \
"Compile, vérifie les risques et les régressions." \
> "$RUNTIME/Reports/auditor.md"
) &

wait

###########################################
# INTEGRATOR
###########################################

opencode run \
--attach http://localhost:4096 \
--title Integrator \
--file "$RUNTIME/Reports/architect.md" \
--file "$RUNTIME/Reports/builder.md" \
--file "$RUNTIME/Reports/auditor.md" \
"Fusionne les rapports. Produit un verdict PASS FAIL ou BLOCKED." \
> "$RUNTIME/Reports/final_report.md"

###########################################
# RESULT
###########################################

cp "$MISSION" "$RUNTIME/Done/" || true

echo
echo "========================================"
echo "MISSION COMPLETE"
echo
echo "Reports :"
echo "$RUNTIME/Reports"
echo
echo "Final :"
echo "$RUNTIME/Reports/final_report.md"
echo "========================================"

