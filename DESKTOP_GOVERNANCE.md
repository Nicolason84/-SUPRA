# Desktop Governance — SUPRA FOUNDATION

## Gouvernance du Desktop pour l'Écosystème SUPRA

| Propriété | Valeur |
|-----------|--------|
| **Statut** | CANONIQUE |
| **Version** | SUPRA_FOUNDATION_V1 |
| **Date** | 2026-07-29 |
| **Périmètre** | `~/Desktop/` et `~/NOVA_OS/` |
| **Principe** | Aucun déplacement physique. Uniquement une gouvernance logique. |

---

## 1. Système de Classification

Chaque entrée sur le Desktop est classifiée selon une des catégories suivantes :

| Catégorie | Code | Description | Action Autorisée |
|-----------|------|-------------|-----------------|
| **ACTIF** | 🔵 | Outils, scripts, workspaces utilisés régulièrement | Utilisation normale |
| **ARCHIVE** | 🟤 | Missions terminées, artifacts frozen | Consultation uniquement |
| **LABORATOIRE** | 🟣 | Espaces expérimentaux | Modification libre |
| **SANDBOX** | 🟡 | Tests temporaires | Création/Suppression libre |
| **HISTORIQUE** | ⚪ | Époque pré-git, conservée en l'état | Lecture seule |
| **LECTURE SEULE** | 🔴 | Preuves frozen, artifacts certifiés | Aucune modification |

---

## 2. Zone Active

### 2.1 Workspace Principal

| Entrée | Classification | Gouvernance |
|--------|---------------|-------------|
| `~/Desktop/NOVA_OS/SUPRA` | 🔵 ACTIF | Git, AGENTS.md, opencode.json. Toute modification via Builder. |

C'est le SEUL workspace actif. Tout le développement s'y déroule.

### 2.2 Scripts Actifs

| Script | Classification | Dernière Activité |
|--------|---------------|-------------------|
| `GO_SUPRA_RUNTIME_DOCTOR_V1.sh` | 🔵 ACTIF | 2026-07-24 |
| `GO_SUPRA_TOTAL_RECOVERY_AUDIT.sh` | 🔵 ACTIF | 2026-07-24 |
| `GO_OPENCODE_FIX_STAGE0.sh` | 🔵 ACTIF | 2026-07-24 |
| `GO_OPENCODE_PROVIDER_FORENSICS.sh` | 🔵 ACTIF | 2026-07-24 |
| `GO_SUPRA_BISECT.sh` | 🔵 ACTIF | 2026-07-24 |
| `GO_SUPRA_BISECT_FIX.sh` | 🔵 ACTIF | 2026-07-24 |
| `GO_SUPRA_BUILD_MATRIX.sh` | 🔵 ACTIF | 2026-07-24 |
| `GO_SUPRA_CONTINUITY_AUDIT.sh` | 🔵 ACTIF | 2026-07-24 |
| `GO_SUPRA_FIND_REGRESSION.sh` | 🔵 ACTIF | 2026-07-24 |
| `opencode_clean_config.sh` | 🔵 ACTIF | 2026-07-26 |
| `opencode_debug.sh` | 🔵 ACTIF | 2026-07-26 |
| `opencode_diagnostic.sh` | 🔵 ACTIF | 2026-07-26 |

---

## 3. Workspaces Parallèles

| Workspace | Classification | Justification |
|-----------|---------------|---------------|
| `~/Desktop/NOVA_OS/SUPRA_BISECT` | 🔵 ACTIF | Regression bisection active |
| `~/Desktop/NOVA_OS/SUPRA_DEEPSEEK_EXIT_READINESS` | 🔵 ACTIF | Migration testing active |
| `~/Desktop/NOVA_OS/SUPRA_FRESH` | 🟤 ARCHIVE | Clean clone, peut être stale |
| `~/Desktop/NOVA_OS/SUPRA_MODEL_TEST` | 🟤 ARCHIVE | Model testing terminé |
| `~/Desktop/NOVA_OS/SUPRA_RECOVERY` | 🟤 ARCHIVE | Recovery scenarios |
| `~/Desktop/NOVA_OS/SUPRA_RUNTIME_EVIDENCE_READONLY` | 🔴 LECTURE SEULE | Evidence snapshot frozen |

---

## 4. Archives

| Archive | Classification | Contenu |
|---------|---------------|---------|
| `~/Desktop/_DESKTOP_CLEAN_ARCHIVE_20260630_122028` | 🟤 ARCHIVE | 13 entrées nettoyées |
| `~/Desktop/SUPRA_PROJECTS` | 🟤 ARCHIVE | 73 projets d'audit |
| `~/Desktop/SUPRA_ARCHIVE` | 🟤 ARCHIVE | 5 fichiers zip (GPT, Recovery, VideoSwap) |
| `~/Desktop/SUPRA_TEMP` | 🟤 ARCHIVE | 34 éléments temporaires |

---

## 5. Build & Release

| Entrée | Classification | Règle |
|--------|---------------|-------|
| `~/Desktop/SUPRA_BUILD` | 🟤 ARCHIVE | Artifacts de build (peuvent être regénérés) |
| `~/Desktop/SUPRA_RELEASE` | 🔴 LECTURE SEULE | Documents légaux (155 fichiers) |
| `~/Desktop/PLATFORM_CORE` | 🟤 ARCHIVE | Template de plateforme (référence) |
| `~/Desktop/SUPRA_VIDEO_SWAP_*` | 🟣 LABORATOIRE | Expérimentation produit |

---

## 6. Scripts Historiques

Les scripts suivants sont classifiés HISTORIQUE. Conservés pour référence mais potentiellement supersédés :

| Script | Date Approx | Classification |
|--------|-------------|---------------|
| `GO_INSTALL_ACTIVATE_SUPRA_CONTINUOUS_RUNTIME_V1.sh` | 2026-07-17 | ⚪ HISTORIQUE |
| `GO_RESOLVE_REAL_SUPRA_RUNTIME_BINDINGS_V1.sh` | 2026-07-17 | ⚪ HISTORIQUE |
| `GO_SUPRA_KERNEL_V1_1_CLASSIFY_AND_LIVE_RUNTIME.sh` | 2026-07-16 | ⚪ HISTORIQUE |
| `GO_SUPRA_TERMINAL_RUNTIME_AUDIT_SAFE_V1.sh` | 2026-07-18 | ⚪ HISTORIQUE |
| `GO_SUPRA_AUTOINTEGRATOR_V2.sh` | 2026-07-23 | ⚪ HISTORIQUE |
| `GO_SUPRA_OVERNIGHT_FACTORY.sh` | 2026-07-23 | ⚪ HISTORIQUE |
| `GO_SUPRA_RESTORE_BUILD_V1.sh` | 2026-07-23 | ⚪ HISTORIQUE |
| `GO_SUPRA_SWIFT_DISCOVERY_V1.sh` | 2026-07-23 | ⚪ HISTORIQUE |
| `GO_SUPRA_STORAGE_AUDIT_V1.sh` | 2026-07-23 | ⚪ HISTORIQUE |
| `GO_SUPRA_MEMORY_DISCOVERY_V1.sh` | 2026-07-22 | ⚪ HISTORIQUE |
| `GO_SUPRA_EXTRACT_STORE_MODELS_SERVICES_V1.sh` | 2026-07-22 | ⚪ HISTORIQUE |
| `GO_SUPRA_FIND_ACTIVE_PROJECT.sh` | 2026-07-23 | ⚪ HISTORIQUE |
| `GO_SUPRA_CONVERSATION_SUMMARY_V1.sh` | 2026-07-23 | ⚪ HISTORIQUE |
| `GO_SUPRA_PHASE_0_INDEX_SCHEMA.sh` | 2026-07-23 | ⚪ HISTORIQUE |
| `GO_XCODE_001_IDENTITY.sh` | 2026-07-22 | ⚪ HISTORIQUE |
| `MISSION_001_DISCOVERY.sh` | 2026-07-22 | ⚪ HISTORIQUE |
| `check_opencode_override.sh` | 2026-07-26 | ⚪ HISTORIQUE |

---

## 7. Zone Historique (~/NOVA_OS/)

| Propriété | Valeur |
|-----------|--------|
| **Classification** | ⚪ HISTORIQUE |
| **Entrées** | ~562 entrées, ~400 SUPRA_* directories |
| **Actions** | Aucune. Préservé en l'état. Aucune migration, aucune suppression. |

### Catégories dans ~/NOVA_OS/

| Catégorie | Nombre | Exemples |
|-----------|--------|---------|
| Missions PHASE | ~60 | SUPRA_PHASE1 à SUPRA_PHASE13 |
| Mémoire/Recovery | ~25 | SUPRA_MEMORY_CORE_V1 |
| Executive | ~15 | SUPRA_EXECUTIVE_BLUEPRINT |
| Audit/Vérification | ~50 | SUPRA_AUDIT_CANONIQUE_360_V1 |
| Stockage | ~15 | SUPRA_STORAGE_TWIN_V1 |
| Canonique | ~20 | SUPRA_CANONICAL_APP_V1 |
| Infrastructure | ~30 | SUPRA_BUILD, SUPRA_FACTORY_V1 |
| Archive/Freeze | ~15 | _SUPRA_ANTIAMNESIE_20260611 |
| Helene (iOS/Android) | ~5 | SUPRA_HELENE_IOS |

---

## 8. Gestion des Doublons

Basé sur SUPRA_ZERO_DUPLICATE_ANALYSIS.md :

| Catégorie | Instances | Canonique | Action |
|-----------|-----------|-----------|--------|
| Runtimes | 7 | Active v2.2.0 | ✅ Préservés comme historiques |
| Cores | 10 | Swift codebase | ✅ Préservés comme historiques |
| Manifests | 10 | SUPRA_MASTER_MANIFEST.json | ✅ Vues dérivées acceptables |
| Workspaces | 7 | Main workspace | ✅ Bisect/DeepSeek actifs, autres archives |
| Rapports | ~30 | Variable | ✅ Vues différentes acceptables |

---

## 9. Documents Flottants

| Document | Classification |
|----------|---------------|
| `Capture d'écran 2026-07-15` | 🟤 ARCHIVE (screenshot) |
| `GO_SUPRA_INDEX_FOUNDATION_V1.md` | 🟤 ARCHIVE (documentation) |
| `SUPRA RUNTIME DOCTOR*.md` | 🟤 ARCHIVE (rapport 245KB) |

---

## 10. Règles de Gouvernance

### Règle 1 : Aucune suppression non autorisée
Aucune suppression de fichier ou dossier sans autorisation explicite de l'Executive.

### Règle 2 : Aucun déplacement physique
Les fichiers et dossiers restent où ils sont. Seule la classification change.

### Règle 3 : Classification trimestrielle
La classification doit être revue tous les trimestres pour refléter l'état actuel.

### Règle 4 : Nouveaux actifs déclarés
Tout nouveau fichier ou dossier actif doit être déclaré dans cette gouvernance.

### Règle 5 : Archives immuables
Les ARCHIVES ne sont jamais modifiées. Si une archive doit être réactivée, elle change de classification.

### Règle 6 : Lecture seule certifiée
Les entrées LECTURE SEULE (FREEZE_*, evidence) sont des preuves certifiées. Aucune modification autorisée.

---

## 11. Évolution de la Gouvernance

Cette gouvernance évoluera selon les besoins :
- Quand des entrées ACTIF deviennent ARCHIVE
- Quand de nouveaux workspaces sont créés
- Quand la classification trimestrielle est effectuée
- Quand Phase 2 commence

Toute modification de cette gouvernance doit être tracée dans git.

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA FOUNDATION V1. Aucun déplacement physique n'a été effectué.*
