# WORKSPACE GOVERNANCE AUDIT

**Date:** 2026-07-29
**Scope:** Cartographie complète des écritures directes du Workspace SUPRA vers le Desktop et autres destinations externes
**Workspace:** `/Users/nicolasalonso/Desktop/NOVA_OS/SUPRA` (39 Gi)

---

## 1. État Actuel

Le Workspace SUPRA est situé sur le Desktop (`~/Desktop/NOVA_OS/SUPRA`). Ce positionnement crée une dépendance structurelle entre le Workspace et le Desktop, ce qui contrevient au principe d'écriture centralisée.

### 1.1 Structure du Workspace

| Composant | Taille | Description |
|---|---|---|
| Racine workspace | 39 Gi | Code source, scripts, documentation |
| Artifacts/ | 509 Mi | Artefacts de build et rapports |
| Evidence/ | 0 B | Répertoire d'évidence (vide) |
| Reports/ | 560 Ko | Rapports d'exécution |
| Logs/ | 8 Ki | Logs d'exécution |
| Outbox/ | 0 B | File d'attente de sortie (vide) |
| Inbox/ | 0 B | File d'attente d'entrée (vide) |
| build/ | 22 Mi | Build artifacts |
| Packages/ | 102 Mi | Gestionnaire de paquets |
| .git/ | 772 Mi | Historique Git |
| SUPRA zip/ | — | Archives workspace (si présent) |

---

## 2. Cartographie des Écritures Directes sur le Desktop

### 2.1 Scripts écrit/lu depuis le Desktop

Le Workspace lui-même réside sur le Desktop (`~/Desktop/NOVA_OS/SUPRA`). Les scripts suivants référencent explicitement le Desktop :

| Fichier | Ligne | Pattern | Usage |
|---|---|---|---|
| `GO_SUPRA.sh` | 8 | `ROOT="$HOME/Desktop/NOVA_OS/SUPRA"` | Définition de la root du workspace |
| `SUPRA_BOOTSTRAP_V3.sh` | 28 | `SUPRA_ROOT="${SUPRA_ROOT:-$HOME/Desktop/NOVA_OS/SUPRA}"` | Override de la root |
| `GO_SUPRA_GLOBAL_AUDIT.sh` | 203 | `du -sh "$HOME/Desktop" 2>/dev/null` | Audit d'espace disque |
| `GO_SUPRA_INSTALL.sh` | 8 | `ROOT="${HOME}/Desktop/NOVA_OS/SUPRA"` | Définition de la root |
| `GO_SUPRA_PARALLEL_V1.sh` | 4 | `ROOT="$HOME/Desktop/NOVA_OS/SUPRA"` | Définition de la root |
| `SUPRA_INSTALLER_V2.sh` | 26 | `ROOT="$HOME/Desktop/NOVA_OS/SUPRA"` | Définition de la root |
| `SUPRA_INSTALLER_V2.sh` | 29 | `REPORT="$HOME/Desktop/SUPRA_INSTALL_REPORT.md"` | **Écriture directe sur le Desktop** |
| `SUPRA_ROLLBACK_PHASE2.sh` | 3-59 | Références multiples à `~/Desktop/` | Restauration Desktop |

### 2.2 Écritures directes identifiées

| Destination | Source | Type | Fréquence | Statut |
|---|---|---|---|---|
| `~/Desktop/SUPRA_INSTALL_REPORT.md` | `SUPRA_INSTALLER_V2.sh:29` | Fichier de rapport | À chaque installation | **CRITIQUE — écriture directe sur Desktop** |
| `~/Desktop/_SUPRA_BACKUPS/` | `SUPRA_ROLLBACK_PHASE2.sh` | Backup archive | Lors de rollback | **Écriture directe sur Desktop** |
| `~/Desktop/Scripts/SUPRA_SCRIPTS/` | `SUPRA_ROLLBACK_PHASE2.sh:55` | Restauration scripts | Lors de rollback | **Écriture directe sur Desktop** |
| `~/Desktop/Scripts/` | `SUPRA_ROLLBACK_PHASE2.sh` | Restauration scripts | Lors de rollback | **Écriture directe sur Desktop** |

### 2.3 Écritures dans les sous-répertoires du Workspace

| Destination Interne | Source | Type |
|---|---|---|
| `$ROOT/Logs/recovery_*.log` | `GO_SUPRA_RECOVERY.sh`, `SUPRA_BOOTSTRAP_V3.sh` | Logs d'exécution |
| `$ROOT/Logs/uninstall_*.log` | `SUPRA_BOOTSTRAP_V3.sh:954`, `SUPRA_NODE_UNINSTALL.sh:7` | Logs de désinstallation |
| `$ROOT/Reports/architect.md` | `GO_SUPRA_PARALLEL_V1.sh:64` | Rapport architecte |
| `$ROOT/Reports/builder.md` | `GO_SUPRA_PARALLEL_V1.sh:77` | Rapport builder |
| `$ROOT/Reports/auditor.md` | `GO_SUPRA_PARALLEL_V1.sh:90` | Rapport auditor |
| `$ROOT/Reports/final_report.md` | `GO_SUPRA_PARALLEL_V1.sh:106` | Rapport final |
| `$ROOT/Inbox/*` | `GO_SUPRA_PARALLEL_V1.sh:44` | File d'attente d'entrée |
| `$RUNTIME/Logs/opencode_server.log` | `GO_SUPRA_PARALLEL_V1.sh:35` | Log serveur |

---

## 3. Problèmes Identifiés

### 3.1 Écritures Directes sur le Desktop (Critique)

**Problème:** Le Workspace SUPRA écrit directement des fichiers sur le Desktop en dehors de son propre périmètre. Cela crée:
- Une pollution du Desktop par des fichiers de rapport et de backup
- Un risque de suppression accidentelle lors de nettoyage du Desktop
- Une absence de traçabilité centralisée des artefacts
- Une violation du principe d'écriture unique

**Fichiers concernés:**
1. `~/Desktop/SUPRA_INSTALL_REPORT.md` — rapport d'installation écrit en dehors du workspace
2. `~/Desktop/_SUPRA_BACKUPS/` — archives de backup sur le Desktop
3. `~/Desktop/Scripts/SUPRA_SCRIPTS/` — scripts restaurés sur le Desktop

### 3.2 Dépendance Structurelle au Desktop

**Problème:** La positionnement du Workspace sur le Desktop (`~/Desktop/NOVA_OS/SUPRA`) crée une dépendance qui empêche:
- Le déplacement du Workspace vers un emplacement dédié
- La séparation des préoccupations (projet vs. fichiers personnels)
- Une gouvernance claire des artefacts

### 3.3 Logs Multiples et Redondants

**Problème:** Les logs sont écrits dans `$ROOT/Logs/` avec un timestamp au nom (`recovery_YYYYMMDD_HHMMSS.log`, `uninstall_YYYYMMDD_HHMMSS.log`) mais il n'existe pas de mécanisme de rotation ou d'archivage.

---

## 4. Cartographie Complète des Destinations d'Écriture

```
Workspace Root (~/Desktop/NOVA_OS/SUPRA)
├── Logs/                    ← Écrit par les scripts de récupération, bootstrap, uninstall
├── Reports/                 ← Écrit par GO_SUPRA_PARALLEL_V1.sh (architect, builder, auditor, final)
├── Inbox/                   ← Écrit par le mécanisme de file d'attente de missions
├── Outbox/                  ← (actuellement vide — file de sortie)
│
Desktop Direct (hors workspace)
├── ~/Desktop/SUPRA_INSTALL_REPORT.md    ← SUPRA_INSTALLER_V2.sh:29
├── ~/Desktop/_SUPRA_BACKUPS/            ← SUPRA_ROLLBACK_PHASE2.sh
├── ~/Desktop/Scripts/SUPRA_SCRIPTS/     ← SUPRA_ROLLBACK_PHASE2.sh:55
└ ~/Desktop/*.sh (GO_SUPRA_*.sh)         ← Certains scripts GN sont sur le Desktop
```

---

## 5. Stratégie de Gouvernance des Artefacts

### 5.1 Propagation Proposée

Le **Runtime Service** doit devenir le propriétaire unique des artefacts. Voici la cartographie des responsabilités:

| Artefact | Propriétaire Actuel | Propriétaire Cible | Destination |
|---|---|---|---|
| Rapports d'installation | Script direct | Runtime Service | `$RUNTIME/Reports/` |
| Backups de rollback | Script direct | Runtime Service | `$RUNTIME/Backups/` |
| Logs d'exécution | Scripts multiples | Runtime Service | `$RUNTIME/Logs/` |
| Rapports parallèles | GO_SUPRA_PARALLEL_V1.sh | Runtime Service | `$RUNTIME/Reports/` |
| Fichiers d'entrée (Inbox) | Mécanisme direct | Runtime Service | `$RUNTIME/Inbox/` |
| Fichiers de sortie (Outbox) | Mécanisme direct | Runtime Service | `$RUNTIME/Outbox/` |
| Artefacts de build | Build direct | Runtime Service | `$RUNTIME/Artifacts/` |

### 5.2 Principes de Gouvernance

1. **Write-through Runtime:** Tous les artefacts passent par le Runtime Service
2. **Single Write Point:** Un seul point d'écriture par type d'artefact
3. **No Direct Desktop Writes:** Interdiction d'écrire en dehors du Workspace ou du Runtime
4. **Centralized Logging:** Tous les logs routés via `$RUNTIME/Logs/`
5. **Artifact Classification:** Chaque artefact classifié (ACTIF, ARCHIVE, LABORATOIRE, SANDBOX, HISTORIQUE, LECTURE SEULE)

### 5.3 Migration Non-Réactive (Phase 3 — Observation uniquement)

Pour l'instant, aucune refactorisation n'est requise. La cartographie est suffisante pour:
1. Identifier les violations actuelles
2. Planifier la migration du Runtime Service
3. Documenter les dépendances
4. Préparer le prochain Execution Gate

---

## 6. Impacts

| Impact | Sévérité | Description |
|---|---|---|
| Pollution Desktop | Élevée | Fichiers de rapport et backup écrits en dehors du workspace |
| Risque de perte | Moyenne | Nettoyage du Desktop pourrait supprimer des artefacts critiques |
| Absence de traçabilité | Moyenne | Pas de centralisation des écritures |
| Dépendance structurelle | Élevée | Workspace positionné sur le Desktop |

---

## 7. Recommandations

### 7.1 Immédiates
1. Rediriger `SUPRA_INSTALLER_V2.sh` pour écrire `SUPRA_INSTALL_REPORT.md` dans `$ROOT/Reports/` au lieu de `~/Desktop/`
2. Migrer `~/Desktop/_SUPRA_BACKUPS/` vers `$ROOT/.trash/` ou un répertoire de backup interne au workspace
3. Migrer `~/Desktop/Scripts/SUPRA_SCRIPTS/` vers `$ROOT/Artifacts/scripts/`

### 7.2 À court terme
1. Implémenter le Runtime Service comme propriétaire unique des artefacts (cf. RUNTIME_CONSOLIDATION_REPORT.md)
2. Établir un cycle de rotation des logs
3. Centraliser toutes les écritures dans les répertoires du workspace

### 7.3 À planifier
1. Déplacer le workspace vers `~/NOVA_OS/SUPRA/` pour rompre la dépendance au Desktop
2. Établir un contrat d'interface (API) pour le Runtime Service (cf. PROVIDER_AUDIT.md)
3. Implémenter le mécanisme de gouvernance des artefacts via le Runtime

---

## 8. Prochaines Actions

1. Implémenter la migration des écritures directes vers le Runtime Service
2. Déplacer le workspace hors du Desktop
3. Produire la roadmap d'industrialisation (cf. EXECUTION_GATE_REPORT.md)