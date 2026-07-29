#!/usr/bin/env bash
#
# GO_SUPRA_RESTORE_BUILD_V1.sh
#
# PHASE UNIQUE
# RESTORE BUILD
#
# OBJECTIF
# 1. Inventorier les erreurs de compilation
# 2. Détecter les Invalid redeclaration
# 3. Détecter les fichiers Swift dupliqués
# 4. Vérifier l'état réel du build
#
# AUCUNE MODIFICATION
# AUCUN PATCH
# AUCUN ROLLBACK
#

set -Eeuo pipefail
IFS=$'\n\t'

ROOT="/Users/nicolasalonso/Desktop/NOVA_OS/SUPRA"

STAMP="$(date +%Y%m%d_%H%M%S)"

RUN="$ROOT/.restore_build/$STAMP"

mkdir -p "$RUN"

BUILD_LOG="$RUN/xcodebuild.log"
SUMMARY="$RUN/BUILD_SUMMARY.txt"
DUPLICATE_FILES="$RUN/DUPLICATE_SWIFT_FILES.txt"
REDECLARATIONS="$RUN/INVALID_REDECLARATION.txt"

echo "==============================="
echo "SUPRA RESTORE BUILD"
echo "==============================="

WORKSPACE="$(find "$ROOT" -name "*.xcworkspace" | head -n1 || true)"
PROJECT="$(find "$ROOT" -name "*.xcodeproj" | head -n1 || true)"

if [[ -n "$WORKSPACE" ]]; then
    SCHEME="$(xcodebuild -workspace "$WORKSPACE" -list 2>/dev/null \
        | awk '/Schemes:/{flag=1;next} flag && NF{print;exit}')"

    xcodebuild \
        -workspace "$WORKSPACE" \
        -scheme "$SCHEME" \
        -configuration Debug \
        build \
        >"$BUILD_LOG" 2>&1 || true

elif [[ -n "$PROJECT" ]]; then
    SCHEME="$(xcodebuild -project "$PROJECT" -list 2>/dev/null \
        | awk '/Schemes:/{flag=1;next} flag && NF{print;exit}')"

    xcodebuild \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -configuration Debug \
        build \
        >"$BUILD_LOG" 2>&1 || true
else
    echo "Aucun projet Xcode trouvé."
    exit 1
fi

echo
echo "Recherche des Invalid redeclaration..."

grep -n "Invalid redeclaration" "$BUILD_LOG" \
    | tee "$REDECLARATIONS" || true

echo
echo "Recherche des erreurs..."

grep -E " error:|error:" "$BUILD_LOG" \
    | sort -u \
    > "$RUN/ERRORS.txt" || true

echo
echo "Recherche des warnings..."

grep -E " warning:|warning:" "$BUILD_LOG" \
    | sort -u \
    > "$RUN/WARNINGS.txt" || true

echo
echo "Recherche des fichiers Swift dupliqués..."

find "$ROOT" \
-name "*.swift" \
-exec basename {} \; \
| sort \
| uniq -d \
> "$DUPLICATE_FILES"

{
echo "======================================"
echo "SUPRA RESTORE BUILD"
echo "======================================"
echo
echo "SCHEME : $SCHEME"
echo
echo "ERRORS : $(wc -l < "$RUN/ERRORS.txt" | tr -d ' ')"
echo "WARNINGS : $(wc -l < "$RUN/WARNINGS.txt" | tr -d ' ')"
echo "INVALID REDECLARATION : $(wc -l < "$REDECLARATIONS" | tr -d ' ')"
echo "DUPLICATE FILENAMES : $(wc -l < "$DUPLICATE_FILES" | tr -d ' ')"
echo
echo "REPORT : $RUN"
} | tee "$SUMMARY"

echo
echo "======================================"
echo "RESTORE BUILD REPORT READY"
echo "======================================"
echo
echo "$SUMMARY"
