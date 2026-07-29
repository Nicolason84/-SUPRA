#!/bin/bash

set -u

ROOT="$HOME/Desktop/NOVA_OS/SUPRA_RECOVERY"
REPORT="$HOME/Desktop/SUPRA_BUILD_MATRIX_$(date +%Y%m%d_%H%M%S).txt"

exec > >(tee "$REPORT") 2>&1

echo "======================================================="
echo "        SUPRA BUILD MATRIX (READ ONLY)"
echo "======================================================="
echo
date
echo

WORKTREES=("BASELINE" "CHAT" "BRIDGE" "HEALTH")

printf "%-12s | %-8s\n" "WORKTREE" "RESULTAT"
printf "%-12s-+-%-8s\n" "------------" "--------"

for WT in "${WORKTREES[@]}"
do
    DIR="$ROOT/$WT"

    if [ ! -d "$DIR" ]; then
        printf "%-12s | ABSENT\n" "$WT"
        continue
    fi

    cd "$DIR" || continue

    WORKSPACE=$(find . -maxdepth 2 -name "*.xcworkspace" | head -1)
    PROJECT=$(find . -maxdepth 2 -name "*.xcodeproj" | head -1)

    if [ -n "$WORKSPACE" ]; then

        SCHEME=$(xcodebuild \
            -workspace "$WORKSPACE" \
            -list 2>/dev/null \
            | awk '/Schemes:/{getline;gsub(/^[ \t]+/,"");print;exit}')

        xcodebuild \
            -workspace "$WORKSPACE" \
            -scheme "$SCHEME" \
            -configuration Debug \
            build \
            > build.log 2>&1

    elif [ -n "$PROJECT" ]; then

        SCHEME=$(xcodebuild \
            -project "$PROJECT" \
            -list 2>/dev/null \
            | awk '/Schemes:/{getline;gsub(/^[ \t]+/,"");print;exit}')

        xcodebuild \
            -project "$PROJECT" \
            -scheme "$SCHEME" \
            -configuration Debug \
            build \
            > build.log 2>&1

    else
        printf "%-12s | NO PROJECT\n" "$WT"
        continue
    fi

    if grep -q "BUILD SUCCEEDED" build.log; then

        printf "%-12s | PASS\n" "$WT"

    else

        printf "%-12s | FAIL\n" "$WT"

        echo
        echo "Première erreur ($WT) :"

        grep -m1 -E \
        "error:|Cannot resolve|No such module|Undefined symbol|Swift Compiler Error" \
        build.log || echo "Erreur non détectée"

        echo
    fi

done

echo
echo "======================================================="
echo "Rapport : $REPORT"
echo "======================================================="
