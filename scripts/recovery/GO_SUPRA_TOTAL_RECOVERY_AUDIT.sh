#!/bin/bash

##############################################################################
# SUPRA TOTAL RECOVERY AUDIT (READ ONLY)
##############################################################################

ROOT="/"
REPORT="$HOME/Desktop/SUPRA_TOTAL_RECOVERY_$(date +%Y%m%d_%H%M%S).txt"

exec > >(tee "$REPORT") 2>&1

echo "========================================================"
echo " SUPRA TOTAL RECOVERY AUDIT"
echo " READ ONLY"
echo "========================================================"
echo
date
echo

##############################################################################
echo "1. RECHERCHE DES DEPOTS GIT"
##############################################################################

find /Users -type d -name ".git" 2>/dev/null | while read G
do
    echo
    echo "--------------------------------------------------"
    echo "REPOSITORY : ${G%/.git}"
    echo "--------------------------------------------------"

    cd "${G%/.git}" || continue

    echo
    echo "[REMOTE]"
    git remote -v 2>/dev/null || true

    echo
    echo "[CURRENT BRANCH]"
    git branch --show-current 2>/dev/null || true

    echo
    echo "[LOCAL BRANCHES]"
    git branch -a 2>/dev/null || true

    echo
    echo "[TAGS]"
    git tag 2>/dev/null || true

    echo
    echo "[LAST 20 COMMITS]"
    git log --oneline --decorate -20 2>/dev/null || true

    echo
    echo "[STASH]"
    git stash list 2>/dev/null || true

    echo
    echo "[REFLOG]"
    git reflog --date=local -30 2>/dev/null || true
done

##############################################################################
echo
echo "2. RECHERCHE DES DOSSIERS SUPRA / NOVA"
##############################################################################

find /Users \
\( \
-iname "*SUPRA*" -o \
-iname "*NOVA*" -o \
-iname "*ORIAM*" \
\) \
2>/dev/null

##############################################################################
echo
echo "3. RECHERCHE DES CLONES"
##############################################################################

find /Users \
-type d \
\( \
-name "SUPRA" -o \
-name "SUPRA_*" -o \
-name "*SUPRA*" -o \
-name "*NOVA*" \
\) \
2>/dev/null

##############################################################################
echo
echo "4. PROJETS XCODE"
##############################################################################

find /Users \
\( \
-name "*.xcodeproj" -o \
-name "*.xcworkspace" \
\) \
2>/dev/null

##############################################################################
echo
echo "5. PACKAGE SWIFT"
##############################################################################

find /Users \
-name "Package.swift" \
2>/dev/null

##############################################################################
echo
echo "6. BACKUPS ZIP TAR"
##############################################################################

find /Users \
\( \
-name "*.zip" -o \
-name "*.tar" -o \
-name "*.tar.gz" -o \
-name "*.tgz" \
\) \
2>/dev/null | grep -Ei "supra|nova|backup|archive"

##############################################################################
echo
echo "7. SNAPSHOTS TIME MACHINE"
##############################################################################

tmutil listlocalsnapshots / 2>/dev/null || true

##############################################################################
echo
echo "8. DOSSIERS MODIFIES IL Y A 20 A 60 JOURS"
##############################################################################

find /Users \
-type d \
-mtime +20 \
-mtime -60 \
2>/dev/null | grep -Ei "SUPRA|NOVA"

##############################################################################
echo
echo "9. RECHERCHE DE FICHIERS FREEZE"
##############################################################################

find /Users \
-type f \
\( \
-name "*FREEZE*" -o \
-name "*CANON*" -o \
-name "*SNAPSHOT*" -o \
-name "*BACKUP*" \
\) \
2>/dev/null

##############################################################################
echo
echo "10. RECHERCHE DES FICHIERS XCODE DERNIER MOIS"
##############################################################################

find /Users \
-type f \
-name "*.swift" \
-mtime -45 \
2>/dev/null | grep -Ei "SUPRA|NOVA"

##############################################################################
echo
echo "11. RECHERCHE DES BUNDLES GIT"
##############################################################################

find /Users \
-type f \
-name "*.bundle" \
2>/dev/null

##############################################################################
echo
echo "========================================================"
echo "AUDIT TERMINE"
echo "========================================================"
echo
echo "Rapport : $REPORT"
