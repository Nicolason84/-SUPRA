#!/bin/bash
set -Eeuo pipefail

echo "===================================================="
echo "      SUPRA XCODE AUTO RECOVERY"
echo "===================================================="

ROOT="$(pwd)"
cd "$ROOT"

WORKSPACE=$(find . -maxdepth 2 -name "*.xcworkspace" | head -1)
PROJECT=$(find . -maxdepth 2 -name "*.xcodeproj" | head -1)

if [[ -n "$WORKSPACE" ]]; then
    MODE="-workspace"
    TARGET="$WORKSPACE"
elif [[ -n "$PROJECT" ]]; then
    MODE="-project"
    TARGET="$PROJECT"
else
    echo "❌ Aucun .xcworkspace ou .xcodeproj trouvé."
    exit 1
fi

mkdir -p .supra_reports

echo
echo "▶ Fermeture Xcode..."
killall Xcode >/dev/null 2>&1 || true

echo
echo "▶ Nettoyage caches..."

rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf ~/Library/Developer/Xcode/ModuleCache.noindex
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf ~/.swiftpm
rm -rf .build

echo
echo "▶ Résolution SwiftPM..."

xcodebuild $MODE "$TARGET" -resolvePackageDependencies || true

echo
echo "▶ Sauvegarde Build Settings..."

xcodebuild \
$MODE "$TARGET" \
-showBuildSettings \
> .supra_reports/buildsettings.txt 2>/dev/null || true

grep -E \
"TARGET_NAME|PRODUCT_NAME|SWIFT_VERSION|SWIFT_ENABLE_EXPLICIT_MODULES|OTHER_SWIFT_FLAGS|HEADER_SEARCH_PATHS|FRAMEWORK_SEARCH_PATHS|LIBRARY_SEARCH_PATHS|SWIFT_INCLUDE_PATHS|GCC_PREPROCESSOR_DEFINITIONS" \
.supra_reports/buildsettings.txt \
> .supra_reports/buildsettings_filtered.txt || true

echo
echo "▶ Recherche du Scheme..."

SCHEME=$(xcodebuild $MODE "$TARGET" -list 2>/dev/null \
| awk '/Schemes:/{getline;gsub(/^[ \t]+/,"");print;exit}')

if [[ -z "$SCHEME" ]]; then
    echo "❌ Aucun Scheme détecté."
    exit 1
fi

echo "Scheme : $SCHEME"

echo
echo "===================================================="
echo " BUILD NORMAL"
echo "===================================================="

set +e

xcodebuild \
$MODE "$TARGET" \
-scheme "$SCHEME" \
build \
2>&1 | tee .supra_reports/build.log

STATUS=$?

set -e

if grep -q "unexpected variant during dependency scanning" .supra_reports/build.log; then

    echo
    echo "⚠ Explicit Modules détecté."
    echo "▶ Test Recovery..."

    xcodebuild \
    $MODE "$TARGET" \
    -scheme "$SCHEME" \
    SWIFT_ENABLE_EXPLICIT_MODULES=NO \
    build \
    > .supra_reports/build_recovery.log 2>&1 || true

    echo
    echo "Recovery terminé."
fi

echo
echo "===================================================="
echo " ERREURS"
echo "===================================================="

grep -n "error:" .supra_reports/build.log || true

echo
echo "===================================================="
echo " BUILD SETTINGS"
echo "===================================================="

cat .supra_reports/buildsettings_filtered.txt

echo
echo "===================================================="
echo " FIN"
echo "===================================================="
