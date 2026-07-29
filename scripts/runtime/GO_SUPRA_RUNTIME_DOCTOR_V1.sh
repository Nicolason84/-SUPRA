#!/bin/bash
set +e

ROOT="$HOME/Desktop/NOVA_OS"
[ -d "$ROOT" ] || ROOT="$HOME/NOVA_OS"

STAMP=$(date +"%Y%m%d_%H%M%S")
REPORT="$ROOT/SUPRA_RUNTIME_DOCTOR_${STAMP}.md"

GREEN="🟢"
YELLOW="🟡"
RED="🔴"

score=0
total=0

pass() { score=$((score+1)); total=$((total+1)); echo "$GREEN PASS - $1"; }
warn() { total=$((total+1)); echo "$YELLOW WARN - $1"; }
fail() { total=$((total+1)); echo "$RED FAIL - $1"; }

exec > >(tee "$REPORT") 2>&1

echo "# SUPRA Runtime Doctor V1"
echo
echo "Date : $(date)"
echo "Root : $ROOT"
echo

echo "=================================================="
echo "1. PROCESSUS"
echo "=================================================="

check_proc () {
    if pgrep -af "$1" >/dev/null 2>&1; then
        pass "$2"
        pgrep -af "$1"
    else
        fail "$2"
    fi
    echo
}

check_proc "ollama" "Ollama"
check_proc "xcodebuild" "Xcode Build"
check_proc "swift" "Swift Runtime"
check_proc "supra" "SUPRA Runtime"
check_proc "watch" "Watchers"

echo
echo "=================================================="
echo "2. launchd"
echo "=================================================="

if launchctl list >/dev/null 2>&1; then
    pass "launchd disponible"
    launchctl list | grep -Ei "supra|ollama|bridge|watch|mission|runtime" || true
else
    fail "launchd inaccessible"
fi

echo
echo "=================================================="
echo "3. PORTS"
echo "=================================================="

PORTS="11434 8080 8000 3000 5000 7000 9000"

for p in $PORTS
do
    if lsof -nP -iTCP:$p -sTCP:LISTEN >/dev/null 2>&1
    then
        pass "Port $p"
        lsof -nP -iTCP:$p -sTCP:LISTEN
    else
        warn "Port $p fermé"
    fi
done

echo
echo "=================================================="
echo "4. DOSSIERS"
echo "=================================================="

for d in \
INBOX \
OUTBOX \
Artifacts \
Reports \
Proofs \
Logs \
Runtime \
Bridge
do
    if find "$ROOT" -type d -iname "$d" | head -1 | grep . >/dev/null
    then
        pass "$d"
        find "$ROOT" -type d -iname "$d" | head -3
    else
        warn "$d absent"
    fi
done

echo
echo "=================================================="
echo "5. LOGS"
echo "=================================================="

find "$ROOT" \
-type f \
\( -name "*.log" -o -name "build.log" \) \
-print | head -20

echo
echo "=================================================="
echo "6. JSON RUNTIME"
echo "=================================================="

find "$ROOT" \
-type f \
\( \
-name "*runtime*.json" -o \
-name "*trace*.json" -o \
-name "*metrics*.json" -o \
-name "*graph*.json" \
\) | head -40

echo
echo "=================================================="
echo "7. GIT"
echo "=================================================="

find "$ROOT" -name ".git" | while read g
do
repo=$(dirname "$g")
echo
echo "$repo"
git -C "$repo" rev-parse --abbrev-ref HEAD
git -C "$repo" status --short | head -20
done

echo
echo "=================================================="
echo "8. BUILD"
echo "=================================================="

find "$ROOT" -name build.log | while read f
do
echo
echo "$f"
grep -Ei "error|warning|fail|passed|success" "$f" | tail -20
done

echo
echo "=================================================="
echo "9. HEALTH SCORE"
echo "=================================================="

PERCENT=$((score*100/total))

echo
echo "Score : $score / $total"
echo "Health : ${PERCENT}%"

if [ "$PERCENT" -ge 90 ]
then
echo
echo "SYSTEM STATUS : HEALTHY"
elif [ "$PERCENT" -ge 70 ]
then
echo
echo "SYSTEM STATUS : DEGRADED"
else
echo
echo "SYSTEM STATUS : CRITICAL"
fi

echo
echo "Rapport :"
echo "$REPORT"

