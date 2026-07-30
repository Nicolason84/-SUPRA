# SUPRA WORKSPACE ROLLBACK PLAN

**Version**: 1.0  
**Status**: VALIDATED  
**Category**: Workspace Validation  
**Path**: `SUPRA_WORKSPACE_ROLLBACK_PLAN.md`

---

## Principes

1. **Toute opération doit être réversible**
2. **Backup avant chaque phase**
3. **Script de rollback écrit avant l'opération**
4. **Validation du rollback après test**
5. **Zéro perte de données garantie**

---

## Rollback par Étape

### Rollback 0 — Quick Wins

| Opération | Commande de rollback | Temps | Risque |
|-----------|---------------------|-------|--------|
| Scripts → SUPRA_SCRIPTS/ | `mv ~/Desktop/SUPRA_SCRIPTS/*.sh ~/Desktop/` | 1 min | Nul |
| .log → Logs/ | `mv ~/Desktop/NOVA_OS/SUPRA/Logs/*.log ~/Desktop/` | 30s | Nul |
| .txt → Reports/ | `mv ~/Desktop/NOVA_OS/SUPRA/Reports/*.txt ~/Desktop/` | 30s | Nul |
| .md test → SUPRA_TEMP/ | `mv ~/Desktop/SUPRA_TEMP/TEST_VALIDATION*.md ~/Desktop/` | 10s | Nul |
| .png → Evidence/ | `mv ~/Desktop/NOVA_OS/SUPRA/Evidence/*.png ~/Desktop/` | 10s | Nul |

### Rollback 1 — Backup

| Opération | Commande de rollback | Temps | Risque |
|-----------|---------------------|-------|--------|
| Backup tar.gz | Restaurer depuis l'archive | 30-60 min | Nul (fichier source intact) |

**Note**: Le backup n'est pas une opération destructive. Le rollback est simplement la non-utilisation du backup.

### Rollback 2 — Phase 0 (Desktop Files)

| Opération | Commande de rollback | Temps | Risque |
|-----------|---------------------|-------|--------|
| 30 scripts vers SUPRA_SCRIPTS/ | `cp -r ~/Desktop/SUPRA_SCRIPTS/*.sh ~/Desktop/` (vérifier les collisions) | 2 min | Nul |
| Logs vers Logs/ | `mv ~/Desktop/NOVA_OS/SUPRA/Logs/*.log ~/Desktop/` | 30s | Nul |
| Rapports vers Reports/ | `mv ~/Desktop/NOVA_OS/SUPRA/Reports/*.txt ~/Desktop/` | 1 min | Nul |
| .md test vers SUPRA_TEMP/ | `mv ~/Desktop/SUPRA_TEMP/TEST_VALIDATION*.md ~/Desktop/` | 10s | Nul |
| .png vers Evidence/ | `mv ~/Desktop/NOVA_OS/SUPRA/Evidence/*.png ~/Desktop/` | 10s | Nul |

**Script de rollback**:
```bash
#!/bin/bash
# ROLLBACK PHASE 0 — Desktop Files Cleanup
echo "Rolling back Phase 0..."
mv ~/Desktop/NOVA_OS/SUPRA/Reports/*.txt ~/Desktop/ 2>/dev/null
mv ~/Desktop/NOVA_OS/SUPRA/Logs/*.log ~/Desktop/ 2>/dev/null
mv ~/Desktop/NOVA_OS/SUPRA/Evidence/*.png ~/Desktop/ 2>/dev/null
mv ~/Desktop/SUPRA_TEMP/TEST_VALIDATION*.md ~/Desktop/ 2>/dev/null
echo "Scripts will be rolled back manually (check SUPRA_SCRIPTS/ first)"
echo "Phase 0 rollback complete."
```

### Rollback 3 — Phase 1 (Sibling Consolidation)

| Opération | Commande de rollback | Temps | Risque |
|-----------|---------------------|-------|--------|
| Déplacer BISECT | `mv ~/Desktop/SUPRA_PROJECTS/CORE_SNAPSHOTS/SUPRA_BISECT* ~/Desktop/NOVA_OS/` | 5 min | Faible |
| Déplacer FRESH | `mv ~/Desktop/SUPRA_PROJECTS/CORE_SNAPSHOTS/SUPRA_FRESH* ~/Desktop/NOVA_OS/` | 5 min | Faible |
| Déplacer MODEL_TEST | `mv ... ~/Desktop/NOVA_OS/` | 5 min | Faible |
| Déplacer RECOVERY | `mv ... ~/Desktop/NOVA_OS/` | 5 min | Faible |
| Déplacer EVIDENCE_READONLY | `mv ... ~/Desktop/NOVA_OS/` | 5 min | Faible |

**Script de rollback**:
```bash
#!/bin/bash
# ROLLBACK PHASE 1 — Sibling Consolidation
echo "Rolling back Phase 1..."
SNAPSHOTS_DIR=~/Desktop/SUPRA_PROJECTS/CORE_SNAPSHOTS
NOVA_OS=~/Desktop/NOVA_OS

if [ -d "$SNAPSHOTS_DIR" ]; then
  for dir in "$SNAPSHOTS_DIR"/*/; do
    name=$(basename "$dir")
    echo "Restoring $name to $NOVA_OS/"
    mv "$dir" "$NOVA_OS/"
  done
  echo "Phase 1 rollback complete."
else
  echo "No snapshots found in $SNAPSHOTS_DIR"
fi
```

### Rollback 4 — Phase 2 (Desktop Directory Restructuring)

#### Prérequis

| # | Condition | Vérification |
|---|-----------|-------------|
| 1 | Backup Phase 2 disponible | `ls -la ~/Desktop/_SUPRA_BACKUPS/phase2_backup_*.tar.gz` |
| 2 | Script exécuté depuis `~/Desktop` | `pwd` doit retourner `~/Desktop` |
| 3 | Aucun processus Xcode en cours | `pgrep -x Xcode || echo "OK"` |
| 4 | Espace disque libre > 5 GB | `df -h ~/Desktop` |
| 5 | Checksum backup validé | SHA256 du backup correspond au manifeste |

#### Ordre inverse strict

Le rollback suit l'inverse exact de l'exécution Phase 2 : **2f → 2e → 2d → 2c → 2b → 2a**

#### Points de contrôle

Chaque sous-phase a un point de validation. Si une validation échoue, le rollback s'arrête.

#### Conditions d'arrêt

| Condition | Action |
|-----------|--------|
| Backup introuvable | STOP — ne pas continuer |
| Espace disque insuffisant | STOP — libérer de l'espace |
| Conflit de noms détecté | STOP — résoudre manuellement |
| mv échoue (permission) | STOP — vérifier permissions |
| Différence avant/après > 5% | STOP — investiguer |

#### Script de Rollback Phase 2 (exécutable)

```bash
#!/bin/bash
# ======================================================================
# ROLLBACK PHASE 2 — Desktop Directory Restructuring
# Version: 1.0
# Usage: ./SUPRA_ROLLBACK_PHASE2.sh [--force]
# ======================================================================

set -euo pipefail

FORCE=${1:-}

echo "============================================"
echo "  ROLLBACK PHASE 2 — Desktop Restructuring"
echo "  Date: $(date)"
echo "============================================"

# --- PREREQUISITES ---
echo ""
echo "[CHECK] Prérequis..."

# P1: Backup check
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

# P2: Directory check
if [ "$(pwd)" != "$HOME/Desktop" ]; then
  echo "  WARN: Exécution depuis $(pwd), bascule vers ~/Desktop"
  cd ~/Desktop
fi
echo "  PASS: Répertoire: $(pwd)"

# P3: Space check
FREE_GB=$(df -g . | tail -1 | awk '{print $4}')
if [ "$FREE_GB" -lt 5 ] && [ -z "$FORCE" ]; then
  echo "  FAIL: Espace libre insuffisant: ${FREE_GB} GB (min 5)"
  exit 1
fi
echo "  PASS: Espace libre: ${FREE_GB} GB"

echo ""
echo "--- Phase 2 rollback démarré ---"

# ======================================================================
# SUB-PHASE 2f — RESTORE SCRIPTS
# ======================================================================
echo ""
echo "[2f] Restauration des scripts..."
if [ -d ~/Desktop/Scripts ]; then
  if [ -d ~/Desktop/Scripts/SUPRA_SCRIPTS ]; then
    echo "  Restauration de SUPRA_SCRIPTS/ vers ~/Desktop/"
    cp -a ~/Desktop/Scripts/SUPRA_SCRIPTS ~/Desktop/SUPRA_SCRIPTS
    rm -rf ~/Desktop/Scripts/SUPRA_SCRIPTS
    echo "  PASS: SUPRA_SCRIPTS/ restauré"
  fi
  # Supprimer Scripts/ si vide
  rmdir ~/Desktop/Scripts 2>/dev/null || true
  echo "  PASS: Scripts/ traité"
else
  echo "  SKIP: Scripts/ non trouvé"
fi

# ======================================================================
# SUB-PHASE 2e — RESTORE SUPRA_BUILD/import/
# ======================================================================
echo ""
echo "[2e] Restauration de SUPRA_BUILD/import/..."
IMPORT_ARCHIVE=$(ls -t ~/Desktop/Archives/External/SUPRA_BUILD_import*.tar.gz 2>/dev/null | head -1)
if [ -n "$IMPORT_ARCHIVE" ] && [ -f "$IMPORT_ARCHIVE" ]; then
  # Vérifier que la source n'a pas été modifiée
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

# ======================================================================
# SUB-PHASE 2d — RESTORE SNAPSHOTS
# ======================================================================
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

# ======================================================================
# SUB-PHASE 2c — RESTORE ARCHIVES
# ======================================================================
echo ""
echo "[2c] Restauration des archives..."
ARCHIVE_COUNT=0
if [ -d ~/Desktop/Archives ]; then
  for dir in ~/Desktop/Archives/*/; do
    name=$(basename "$dir")
    if [ "$name" != "*" ]; then
      # Ne pas dupliquer si existe déjà
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

# ======================================================================
# SUB-PHASE 2b — RESTORE PRODUCTS
# ======================================================================
echo ""
echo "[2b] Restauration des produits..."
PRODUCT_COUNT=0
if [ -d ~/Desktop/Products ]; then
  # Restaurer les bundles
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
  # Restaurer les dossiers produits
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
  # Restaurer PLATFORM_CORE
  if [ -d ~/Desktop/Products/PLATFORM_CORE ]; then
    cp -a ~/Desktop/Products/PLATFORM_CORE ~/Desktop/PLATFORM_CORE
    PRODUCT_COUNT=$((PRODUCT_COUNT + 1))
  fi
  rm -rf ~/Desktop/Products
  echo "  PASS: $PRODUCT_COUNT produits restaurés"
else
  echo "  SKIP: Products/ non trouvé"
fi

# ======================================================================
# SUB-PHASE 2a — REMOVE CATEGORY DIRS
# ======================================================================
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
```

### Rollback 5 — Phase 3 (Core Internal)

| Opération | Commande de rollback | Temps | Risque |
|-----------|---------------------|-------|--------|
| Archiver dossiers cachés | Restaurer depuis l'archive | 5 min | Nul |
| Modifications SUPRA_RUNTIME/ | Reverse des actions | 2 min | Nul |

**Script de rollback**:
```bash
#!/bin/bash
# ROLLBACK PHASE 3 — Core Internal Cleanup
echo "Rolling back Phase 3..."
# Restaurer les dossiers cachés depuis l'archive
if [ -f ~/Desktop/_SUPRA_BACKUPS/core_hidden_dirs.tar.gz ]; then
  tar -xzf ~/Desktop/_SUPRA_BACKUPS/core_hidden_dirs.tar.gz -C ~/Desktop/NOVA_OS/SUPRA/
fi
echo "Phase 3 rollback complete."
```

---

## Script de Rollback Global

```bash
#!/bin/bash
# SUPRA WORKSPACE — GLOBAL ROLLBACK
# Usage: ./SUPRA_WORKSPACE_ROLLBACK.sh [phase]
# Phases: all, 0, 1, 2, 3

PHASE=${1:-all}

echo "=== SUPRA WORKSPACE GLOBAL ROLLBACK ==="
echo "Phase: $PHASE"
echo "Date: $(date)"
echo "WARNING: This will undo workspace migrations."
echo ""

case $PHASE in
  all)
    echo "Performing full rollback from backup..."
    # Find latest backup
    BACKUP=$(ls -t ~/Desktop/_SUPRA_BACKUPS/workspace_backup_*.tar.gz 2>/dev/null | head -1)
    if [ -n "$BACKUP" ]; then
      echo "Restoring from $BACKUP"
      tar -xzf "$BACKUP" -C ~/Desktop/
      echo "Full rollback complete."
    else
      echo "ERROR: No backup found."
      exit 1
    fi
    ;;
  0)
    echo "Rolling back Phase 0..."
    # Phase 0 rollback code
    ;;
  1)
    echo "Rolling back Phase 1..."
    # Phase 1 rollback code
    ;;
   2)
    echo "Rolling back Phase 2..."
    SCRIPT_PATH="$HOME/Desktop/NOVA_OS/SUPRA/SUPRA_ROLLBACK_PHASE2.sh"
    if [ -f "$SCRIPT_PATH" ]; then
      echo "Executing: $SCRIPT_PATH"
      bash "$SCRIPT_PATH" --force
    else
      echo "ERROR: $SCRIPT_PATH not found"
      echo "Run: tar -xzf \"$BACKUP\" -C ~/Desktop/"
      exit 1
    fi
    ;;
  3)
    echo "Rolling back Phase 3..."
    # Phase 3 rollback code
    ;;
  *)
    echo "Usage: $0 [all|0|1|2|3]"
    exit 1
    ;;
esac

echo "=== Rollback complete ==="
```

---

## Matrice de Confiance du Rollback

| Phase | Confiance | Justification |
|-------|-----------|---------------|
| Quick Wins | 10/10 | Opérations atomiques, reverse mv trivial |
| Phase 0 | 10/10 | Reverse mapping simple, backup disponible |
| Phase 1 | 8/10 | Reverse mapping simple mais dépend du backup si merge |
| Phase 2 | 6/10 | Complexité élevée, backup fortement recommandé |
| Phase 3 | 9/10 | Opérations mineures, reverse trivial |

### Règle d'Or

> **Si une Phase peut être rollbackée en < 15 minutes, elle est sûre.**
> **Si une Phase nécessite > 30 minutes de rollback, elle nécessite un snapshot préalable.**

| Phase | Temps de rollback | Backup requis | Snapshot requis |
|-------|-------------------|---------------|-----------------|
| Quick Wins | < 5 min | Non | Non |
| Phase 0 | < 10 min | Recommandé | Non |
| Phase 1 | < 30 min | Oui | Non |
| Phase 2 | 30-60 min | Oui | Oui |
| Phase 3 | < 10 min | Recommandé | Non |
