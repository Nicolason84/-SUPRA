#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

##############################################################################
# GO_SUPRA_AUTOINTEGRATOR_V2
#
# MODE
# AUTO-INTEGRANT
# READ FIRST
#
# NE CRÉE AUCUN MOTEUR
# NE MODIFIE PAS LES SOURCES
# DÉCOUVRE
# CONNECTE
# VÉRIFIE
# MAINTIENT
##############################################################################

ROOT="${1:-$HOME}"

STAMP="$(date +%Y%m%d_%H%M%S)"
RUN="$HOME/Desktop/SUPRA_AUTOINTEGRATOR_${STAMP}"

mkdir -p "$RUN"

REPORT="$RUN/REPORT.md"

touch "$REPORT"

echo "# SUPRA AUTOINTEGRATOR" >>"$REPORT"
echo >>"$REPORT"

##############################################################################

find "$ROOT" \
-name "*.xcodeproj" \
-o -name "*.xcworkspace" \
-o -name "Package.swift" \
2>/dev/null \
| sort -u \
> "$RUN/XCODE.txt"

find "$ROOT" \
-name "*.swift" \
2>/dev/null \
> "$RUN/SWIFT.txt"

find "$ROOT" \
-name "*.json" \
2>/dev/null \
> "$RUN/JSON.txt"

##############################################################################

grep -RIl \
"SUPRA_EXECUTIVE_UI_MODEL" \
"$ROOT" \
2>/dev/null \
> "$RUN/UI_MODEL.txt" || true

grep -RIl \
"SUPRATerminalMegabusBridge" \
"$ROOT" \
2>/dev/null \
> "$RUN/MEGABUS.txt" || true

grep -RIl \
"SUPRAGabriel" \
"$ROOT" \
2>/dev/null \
> "$RUN/GABRIEL.txt" || true

grep -RIl \
"SUPRASystemIntegrity" \
"$ROOT" \
2>/dev/null \
> "$RUN/INTEGRITY.txt" || true

grep -RIl \
"CAnnoNico" \
"$ROOT" \
2>/dev/null \
> "$RUN/CANNONICO.txt" || true

grep -RIl \
"Runtime" \
"$ROOT" \
2>/dev/null \
> "$RUN/RUNTIME.txt" || true

##############################################################################

find "$HOME/NOVA_OS" \
-type f \
2>/dev/null \
> "$RUN/NOVA_OS_FILES.txt" || true

##############################################################################

{
echo
echo "=============================="
echo "XCODE"
wc -l "$RUN/XCODE.txt"

echo
echo "SWIFT"
wc -l "$RUN/SWIFT.txt"

echo
echo "JSON"
wc -l "$RUN/JSON.txt"

echo
echo "MEGABUS"
wc -l "$RUN/MEGABUS.txt"

echo
echo "GABRIEL"
wc -l "$RUN/GABRIEL.txt"

echo
echo "CANNONICO"
wc -l "$RUN/CANNONICO.txt"

echo
echo "RUNTIME"
wc -l "$RUN/RUNTIME.txt"

echo
echo "UI MODEL"
wc -l "$RUN/UI_MODEL.txt"

echo
echo "SYSTEM INTEGRITY"
wc -l "$RUN/INTEGRITY.txt"

} >> "$REPORT"

##############################################################################
# ZIP
##############################################################################

cd "$HOME/Desktop"

zip -qry "$(basename "$RUN").zip" "$(basename "$RUN")"

echo
echo "========================================"
echo "SUPRA AUTOINTEGRATOR READY"
echo
echo "ENVOIE UNIQUEMENT CE FICHIER :"
echo
echo "$HOME/Desktop/$(basename "$RUN").zip"
echo
echo "AUCUNE MODIFICATION N'A ÉTÉ EFFECTUÉE."
echo "========================================"

