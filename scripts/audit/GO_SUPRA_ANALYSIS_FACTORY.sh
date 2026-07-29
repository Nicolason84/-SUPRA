#!/bin/bash
set -e

ROOT="$HOME/Desktop/NOVA_OS/SUPRA"
OUT="$ROOT/.analysis_$(date +%Y%m%d_%H%M%S)"

mkdir -p "$OUT"

echo "=================================="
echo "STOPPING OLD TERMINAL JOBS..."
echo "=================================="

pkill -f "sleep 300" 2>/dev/null || true
pkill -f "grep -R 'error:'" 2>/dev/null || true
pkill -f xcodebuild 2>/dev/null || true

osascript <<'OSA'
tell application "Terminal"
    repeat with w in windows
        repeat with t in tabs of w
            try
                if busy of t then
                    do script "exit" in t
                end if
            end try
        end repeat
    end repeat
end tell
OSA

echo
echo "=================================="
echo "START TARGETED ANALYSIS"
echo "=================================="

########################################
echo "[1/4] BUILD"
########################################

(
cd "$ROOT"

xcodebuild -list > "$OUT/build_list.txt" 2>&1 || true
xcodebuild build > "$OUT/build.log" 2>&1 || true

grep -n "error:" "$OUT/build.log" > "$OUT/errors.txt" || true
grep -n "warning:" "$OUT/build.log" > "$OUT/warnings.txt" || true
)&

########################################
echo "[2/4] DEPENDENCIES"
########################################

(
find "$ROOT" \
-name "*.swift" \
-exec grep -H "^import " {} \; \
> "$OUT/import_graph.txt"
)&

########################################
echo "[3/4] INVENTORY"
########################################

(
find "$ROOT" \
-type f \
> "$OUT/inventory.txt"

find "$ROOT" \
-name "*.xcodeproj" \
-o -name "*.xcworkspace" \
> "$OUT/projects.txt"
)&

########################################
echo "[4/4] OLLAMA"
########################################

(
grep -RIn \
-e Ollama \
-e ollama \
-e 11434 \
-e URLSession \
"$ROOT" \
> "$OUT/ollama_index.txt" 2>/dev/null || true
)&

wait

echo
echo "=================================="
echo "FINISHED"
echo "=================================="

echo "$OUT"

echo
echo "Generated:"
ls "$OUT"
