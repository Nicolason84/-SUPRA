#!/bin/bash
# ======================================================================
# SUPRA ROLLBACK PHASE 2 — Desktop Directory Restructuring
# Version: 1.0
# Usage: ./SUPRA_ROLLBACK_PHASE2.sh [--force]
# Prérequis: Backup disponible dans _SUPRA_BACKUPS/
# ======================================================================

set -euo pipefail

FORCE=${1:-}

echo "============================================"
echo "  ROLLBACK PHASE 2 — Desktop Restructuring"
echo "  Date: $(date)"
echo "============================================"

echo ""
echo "[CHECK] Prérequis..."

BACKUP=$(ls -t ~/Desktop/_SUPRA_BACKUPS/phase2_backup_*.tar.gz 2>/dev/null | head -1)
if [ -z "$BACKUP" ]; then
  BACKUP=$(ls -t ~/Desktop/_SUPRA_BACKUPS/workspace_backup_*.tar.gz 2>/dev/null | head -1)
fi
if [ -z "$BACKUP" ] && [ -z "$FORCE" ]; then
  echo "  FAIL: Aucun backup trouvé. Utilisez --force pour ignorer."
  exit 1
elif [ -n "$BACKUP" ]; then
  echo "  PASS: Backup trouvé: $(basename $BACKUP)"
else
  echo "  WARN: --force: aucun backup, rollback inverse uniquement"
fi

if [ "$(pwd)" != "$HOME/Desktop" ]; then
  echo "  WARN: Exécution depuis $(pwd), bascule vers ~/Desktop"
  cd ~/Desktop
fi
echo "  PASS: Répertoire: $(pwd)"

FREE_GB=$(df -g . | tail -1 | awk '{print $4}')
if [ "$FREE_GB" -lt 5 ] && [ -z "$FORCE" ]; then
  echo "  FAIL: Espace libre insuffisant: ${FREE_GB} GB (min 5)"
  exit 1
fi
echo "  PASS: Espace libre: ${FREE_GB} GB"

echo ""
echo "--- Phase 2 rollback démarré ---"

echo ""
echo "[2f] Restauration des scripts..."
if [ -d ~/Desktop/Scripts ]; then
  if [ -d ~/Desktop/Scripts/SUPRA_SCRIPTS ]; then
    echo "  Restauration de SUPRA_SCRIPTS/ vers ~/Desktop/"
    cp -a ~/Desktop/Scripts/SUPRA_SCRIPTS ~/Desktop/SUPRA_SCRIPTS
    rm -rf ~/Desktop/Scripts/SUPRA_SCRIPTS
    echo "  PASS: SUPRA_SCRIPTS/ restauré"
  fi
  rmdir ~/Desktop/Scripts 2>/dev/null || true
  echo "  PASS: Scripts/ traité"
else
  echo "  SKIP: Scripts/ non trouvé"
fi

echo ""
echo "[2e] Restauration de SUPRA_BUILD/import/..."
IMPORT_ARCHIVE=$(ls -t ~/Desktop/Archives/External/SUPRA_BUILD_import*.tar.gz 2>/dev/null | head -1)
if [ -n "$IMPORT_ARCHIVE" ] && [ -f "$IMPORT_ARCHIVE" ]; then
  if [ ! -d ~/Desktop/SUPRA_BUILD/import ]; then
    echo "  Restauration de l'archive import..."
    mkdir -p ~/Desktop/SUPRA_BUILD
    tar -xzf "$IMPORT_ARCHIVE" -C ~/Desktop/SUPRA_BUILD/
    echo "  PASS: import/ restauré depuis archive"
  else
    echo "  SKIP: import/ existe déjà"
  fi
else
  echo "  SKIP: Aucune archive import trouvée"
fi

echo ""
echo "[2d] Restauration des snapshots..."
SNAPSHOT_COUNT=0
if [ -d ~/Desktop/Snapshots ]; then
  echo "  Restauration des snapshots..."
  for dir in ~/Desktop/Snapshots/*/; do
    name=$(basename "$dir")
    if [ "$name" != "*" ]; then
      echo "    → $name"
      cp -a "$dir" ~/Desktop/
      SNAPSHOT_COUNT=$((SNAPSHOT_COUNT + 1))
    fi
  done
  rm -rf ~/Desktop/Snapshots
  echo "  PASS: $SNAPSHOT_COUNT snapshots restaurés"
else
  echo "  SKIP: Snapshots/ non trouvé"
fi

echo ""
echo "[2c] Restauration des archives..."
ARCHIVE_COUNT=0
if [ -d ~/Desktop/Archives ]; then
  for dir in ~/Desktop/Archives/*/; do
    name=$(basename "$dir")
    if [ "$name" != "*" ]; then
      if [ ! -d ~/Desktop/"$name" ]; then
        echo "    → $name"
        cp -a "$dir" ~/Desktop/
        ARCHIVE_COUNT=$((ARCHIVE_COUNT + 1))
      else
        echo "    ⚠ $name existe déjà sur Desktop, ignoré"
      fi
    fi
  done
  rm -rf ~/Desktop/Archives
  echo "  PASS: $ARCHIVE_COUNT archives restaurées"
else
  echo "  SKIP: Archives/ non trouvé"
fi

echo ""
echo "[2b] Restauration des produits..."
PRODUCT_COUNT=0
if [ -d ~/Desktop/Products ]; then
  if [ -d ~/Desktop/Products/SUPRA_VIDEO_SWAP/Bundles ]; then
    for bundle in ~/Desktop/Products/SUPRA_VIDEO_SWAP/Bundles/*.app; do
      name=$(basename "$bundle")
      if [ "$name" != "*.app" ]; then
        echo "    → $name"
        cp -a "$bundle" ~/Desktop/
        PRODUCT_COUNT=$((PRODUCT_COUNT + 1))
      fi
    done
  fi
  for product_group in ~/Desktop/Products/*/; do
    group_name=$(basename "$product_group")
    if [ "$group_name" != "*" ]; then
      for version_dir in "$product_group"*/; do
        version_name=$(basename "$version_dir")
        if [ "$version_name" != "*" ]; then
          new_name="${group_name}_${version_name}"
          new_name="${new_name%/}"
          if [ ! -d ~/Desktop/"$new_name" ]; then
            echo "    → $new_name"
            cp -a "$version_dir" ~/Desktop/"$new_name"
            PRODUCT_COUNT=$((PRODUCT_COUNT + 1))
          fi
        fi
      done
    fi
  done
  if [ -d ~/Desktop/Products/PLATFORM_CORE ]; then
    cp -a ~/Desktop/Products/PLATFORM_CORE ~/Desktop/PLATFORM_CORE
    PRODUCT_COUNT=$((PRODUCT_COUNT + 1))
  fi
  rm -rf ~/Desktop/Products
  echo "  PASS: $PRODUCT_COUNT produits restaurés"
else
  echo "  SKIP: Products/ non trouvé"
fi

echo ""
echo "[2a] Nettoyage des dossiers catégories..."
rmdir ~/Desktop/Products ~/Desktop/Archives ~/Desktop/Snapshots ~/Desktop/Scripts 2>/dev/null || true
echo "  PASS: Dossiers catégories supprimés (si vides)"

echo ""
echo "============================================"
echo "  ROLLBACK PHASE 2 TERMINÉ"
echo "============================================"
echo ""
echo "RESTORATION: Restaurer depuis backup si le reverse mapping a échoué:"
echo "  tar -xzf \"$BACKUP\" -C ~/Desktop/"
echo ""
echo "VALIDATION: Vérifier que les éléments suivants sont de retour sur le Desktop:"
echo "  □ SUPRA_VIDEO_SWAP_APP_V1/"
echo "  □ SUPRA_VIDEO_SWAP_V3/"
echo "  □ PLATFORM_CORE/"
echo "  □ SupraVideoSwap_*.app"
echo "  □ SUPRA_ARCHIVE/"
echo "  □ SUPRA_PROJECTS/"
echo "  □ SUPRA_SCRIPTS/"
echo "  □ SUPRA_BUILD/"
echo "  □ Tous les snapshots (*_202607*/)"
echo "  □ Toutes les archives (*_ARCHIVE_*/)"
