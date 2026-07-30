#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(pwd)"
REPORT="$ROOT/SUPRA_GLOBAL_AUDIT.md"

exec > >(tee "$REPORT") 2>&1

section() {
    echo
    echo "============================================================"
    echo "$1"
    echo "============================================================"
}

echo "# SUPRA GLOBAL AUDIT"
echo
echo "DATE : $(date)"
echo "HOST : $(hostname)"
echo "USER : $(whoami)"
echo "PWD  : $ROOT"

##############################################################################

section "SYSTEM"

sw_vers || true
uname -a || true
sysctl -n machdep.cpu.brand_string 2>/dev/null || true
uptime || true

##############################################################################

section "DISK"

df -h
echo
diskutil info / 2>/dev/null || true

##############################################################################

section "MEMORY"

vm_stat
echo
memory_pressure 2>/dev/null || true

##############################################################################

section "TOP CPU"

ps aux | sort -nrk3 | head -30

##############################################################################

section "TOP MEMORY"

ps aux | sort -nrk4 | head -30

##############################################################################

section "ACTIVE PROCESSES"

ps -axo pid,ppid,%cpu,%mem,state,start,command

##############################################################################

section "BACKGROUND JOBS"

jobs -l || true

##############################################################################

section "OPEN PORTS"

lsof -nP -iTCP -sTCP:LISTEN || true

##############################################################################

section "OLLAMA"

command -v ollama || true
echo

pgrep -af ollama || true
echo

curl -fs http://127.0.0.1:11434/api/tags || true

##############################################################################

section "OPENCODE"

command -v opencode || true
echo

pgrep -af opencode || true
echo

opencode models 2>/dev/null || true
echo

opencode agent list 2>/dev/null || true
echo

opencode session list 2>/dev/null || true
echo

opencode stats 2>/dev/null || true

##############################################################################

section "XCODE"

xcode-select -p || true
echo

xcodebuild -version || true
echo

pgrep -af xcode || true
pgrep -af xcodebuild || true
pgrep -af swift || true

##############################################################################

section "GIT"

git rev-parse --show-toplevel 2>/dev/null || true
echo

git branch --show-current 2>/dev/null || true
echo

git status --short 2>/dev/null || true
echo

git log --oneline -10 2>/dev/null || true

##############################################################################

section "SUPRA TREE"

find . -maxdepth 2 | sort

##############################################################################

section "RUNTIME"

for d in \
SUPRA_RUNTIME \
SUPRA_RUNTIME/Inbox \
SUPRA_RUNTIME/Running \
SUPRA_RUNTIME/Done \
SUPRA_RUNTIME/Reports \
SUPRA_RUNTIME/Logs
do
    echo
    echo "----- $d -----"
    if [ -d "$d" ]; then
        find "$d" -maxdepth 2 | sort
    else
        echo "ABSENT"
    fi
done

##############################################################################

section "OPEN FILES"

lsof -p $$ || true

##############################################################################

section "NETWORK"

netstat -an | head -200 || true

##############################################################################

section "LAUNCH AGENTS"

launchctl list | head -300 || true

##############################################################################

section "ENVIRONMENT"

env | sort

##############################################################################

section "SHELL"

echo "$SHELL"
echo
echo "$PATH"

##############################################################################

section "HOME"

du -sh "$HOME/Desktop" 2>/dev/null || true
du -sh "$HOME/Downloads" 2>/dev/null || true
du -sh "$HOME/Documents" 2>/dev/null || true

##############################################################################

section "SUMMARY"

echo "Ollama running : $(pgrep -x ollama >/dev/null && echo YES || echo NO)"
echo "OpenCode running : $(pgrep -x opencode >/dev/null && echo YES || echo NO)"
echo "Port 11434 : $(lsof -i:11434 >/dev/null 2>&1 && echo OPEN || echo CLOSED)"
echo "Port 4096 : $(lsof -i:4096 >/dev/null 2>&1 && echo OPEN || echo CLOSED)"

echo
echo "AUDIT COMPLETE"

echo
echo "REPORT : $REPORT"

