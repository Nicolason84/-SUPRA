# SUPRA WORKSPACE CLASSIFICATION

**Version**: 1.0  
**Status**: STABLE  
**Category**: Workspace Governance  
**Path**: `SUPRA_WORKSPACE_CLASSIFICATION.md`

---

## Overview

Classification de l'ensemble des espaces physiques du Workspace SUPRA en 10 catégories principales. Chaque dossier appartient à une et une seule catégorie.

---

## Categories

| # | Category | Prefix | Lifecycle | Description |
|---|----------|--------|-----------|-------------|
| 1 | **Active Workspace** | `AW-` | ACTIVE | Espaces de travail actifs, point d'entrée quotidien |
| 2 | **Products** | `PR-` | ACTIVE/STABLE | Produits livrés ou en cours de livraison |
| 3 | **Runtime** | `RT-` | ACTIVE | Données d'exécution, logs, state |
| 4 | **Development** | `DV-` | ACTIVE | Code source, tests, builds en cours |
| 5 | **Documentation** | `DC-` | STABLE | Documentation et spécifications |
| 6 | **Archives** | `AR-` | ARCHIVED | Données historiques compressées ou figées |
| 7 | **Snapshots** | `SN-` | FROZEN | Instantanés ponctuels du workspace |
| 8 | **Temporary** | `TP-` | TRANSIENT | Données temporaires à durée de vie limitée |
| 9 | **Sandbox** | `SB-` | EXPERIMENTAL | Espaces d'expérimentation isolés |
| 10 | **External Imports** | `EI-` | LEGACY | Imports externes non consolidés |

---

## Classification Detail

### 1. ACTIVE WORKSPACE (AW)

| Path | Type | Description |
|------|------|-------------|
| `~/Desktop/NOVA_OS/SUPRA/` | AW-CORE | Workspace racine, noyau physique de SUPRA |
| `~/Desktop/NOVA_OS/SUPRA/SUPRA/` | AW-SOURCE | Code source Swift de l'application SUPRA |
| `~/Desktop/NOVA_OS/SUPRA/.kernel/` | AW-KERNEL | Kernel SUPRA (schemas, registry, runtime) |
| `~/Desktop/NOVA_OS/SUPRA/.opencode/` | AW-OPENCODE | Configuration OpenCode |
| `~/Desktop/NOVA_OS/SUPRA/Inbox/` | AW-INBOX | Boîte de réception active |
| `~/Desktop/NOVA_OS/SUPRA/Outbox/` | AW-OUTBOX | Boîte d'envoi active |
| `~/Desktop/NOVA_OS/SUPRA/Missions/` | AW-MISSIONS | Missions en cours |
| `~/Desktop/NOVA_OS/SUPRA/Governance/` | AW-GOV | Gouvernance active |
| `~/Desktop/NOVA_OS/SUPRA/Freeze/` | AW-FREEZE | Points de freeze actifs |

### 2. PRODUCTS (PR)

| Path | Type | Description |
|------|------|-------------|
| `~/Desktop/SUPRA_VIDEO_SWAP_APP_V1/` | PR-VIDEOSWAP | Application Video Swap V1 |
| `~/Desktop/SUPRA_VIDEO_SWAP_V3/` | PR-VIDEOSWAP-V3 | Application Video Swap V3 |
| `~/Desktop/SupraVideoSwap_FINAL.app` | PR-APP-BUNDLE | Bundle final V1 |
| `~/Desktop/SupraVideoSwap_FINAL 2.app` | PR-APP-BUNDLE | Duplicate bundle |
| `~/Desktop/SupraVideoSwap_V3_TEST.app` | PR-APP-TEST | Bundle test V3 |
| `~/Desktop/PLATFORM_CORE/` | PR-PLATFORM | Plateforme Core |
| `~/Desktop/NOVA_OS/SUPRA/Packages/` | PR-PACKAGES | Packages Swift |
| `~/Desktop/NOVA_OS/SUPRA/SUPRA.xcodeproj/` | PR-XCODE | Projet Xcode principal |

### 3. RUNTIME (RT)

| Path | Type | Description |
|------|------|-------------|
| `~/Desktop/NOVA_OS/SUPRA/SUPRA_RUNTIME/` | RT-CORE | Runtime SUPRA (Inbox/Outbox/Logs/Running/Blocked/Done) |
| `~/Desktop/NOVA_OS/SUPRA/Logs/` | RT-LOGS | Logs système |
| `~/Desktop/NOVA_OS/SUPRA/Reports/` | RT-REPORTS | Rapports runtime |
| `~/Desktop/NOVA_OS/SUPRA/SUPRA_E2E_PROOF_HARNESS_V1/` | RT-PROOF | Harness de preuve |
| `~/Desktop/NOVA_OS/SUPRA_RUNTIME_CLEANUP_20260726_004052/` | RT-CLEANUP | Cleanup runtime |
| `~/Desktop/NOVA_OS/SUPRA_TERMINAL_RUNTIME_AUDIT_SAFE_20260718_050729/` | RT-AUDIT | Audit terminal runtime |

### 4. DEVELOPMENT (DV)

| Path | Type | Description |
|------|------|-------------|
| `~/Desktop/NOVA_OS/SUPRA/SUPRATests/` | DV-TESTS | Tests unitaires Swift |
| `~/Desktop/NOVA_OS/SUPRA/Artifacts/` | DV-ARTIFACTS | Artéfacts de build |
| `~/Desktop/NOVA_OS/SUPRA/build/` | DV-BUILD | Outputs de compilation |
| `~/Desktop/NOVA_OS/SUPRA/SUPRA_AST_PLATFORM/` | DV-AST | Analyse AST Swift |
| `~/Desktop/NOVA_OS/SUPRA/docs/` | DV-DOCS | Documentation technique |
| `~/Desktop/NOVA_OS/SUPRA/SUPRA.xcodeproj/` | DV-XCODE | Projet Xcode (lié) |
| `~/Desktop/NOVA_OS/SUPRA/SUPRA_HANDOFF_OPENCODE_V2_1/` | DV-HANDOFF | Handoff OpenCode |
| `~/Desktop/SUPRA_BUILD/` | DV-BUILD-DESKTOP | Build assets desktop (import: 65535 fichiers) |

### 5. DOCUMENTATION (DC)

| Path | Type | Description |
|------|------|-------------|
| `~/Desktop/NOVA_OS/SUPRA/*.md` | DC-CORE | Tous les documents markdown racine |
| `~/Desktop/NOVA_OS/SUPRA/docs/releases/` | DC-RELEASES | Notes de release |
| `~/Desktop/NOVA_OS/SUPRA/SUPRA_ADR_GOVERNANCE.md` | DC-ADR | ADR Governance |
| `~/Desktop/NOVA_OS/SUPRA/SUPRA_ADR_STANDARD.md` | DC-ADR | ADR Standard |
| `~/Desktop/NOVA_OS/SUPRA/SUPRA_CONSTITUTION.md` | DC-CONSTITUTION | Constitution SUPRA |
| `~/Desktop/NOVA_OS/SUPRA/SUPRA_MASTER_INDEX.md` | DC-INDEX | Master Index |
| `~/Desktop/NOVA_OS/SUPRA/AGENTS.md` | DC-AGENTS | Configuration agents |
| `~/Desktop/SUPRA_RELEASE/` | DC-RELEASES-DESKTOP | Releases historiques |
| `~/Desktop/SUPRA_INSTALL_REPORT.md` | DC-INSTALL | Rapport d'installation |

### 6. ARCHIVES (AR)

| Path | Type | Description |
|------|------|-------------|
| `~/Desktop/SUPRA_ARCHIVE/` | AR-ZIP | Archives compressées (zips) |
| `~/Desktop/SUPRA_VIDEO_SWAP_V1_ARCHIVE_20260715_140116/` | AR-PROJECT | Archive projet Video Swap V1 |
| `~/Desktop/SUPRA_XCODE_TARGETED_RECOVERY_V1_20260719_230912/` | AR-RECOVERY | Archive recovery Xcode |
| `~/Desktop/NOVA_OS/SUPRA/EXECUTIVE_ARCHIVES/` | AR-EXECUTIVE | Archives exécutives |
| `~/Desktop/NOVA_OS/SUPRA/_FOUNDATION_MEMORY/` | AR-FOUNDATION | Mémoire Foundation (29 fichiers JSON/MD) |
| `~/Desktop/NOVA_OS/SUPRA/_SUPRA_BACKUPS/` | AR-BACKUPS | Backups système |
| `~/Desktop/NOVA_OS/SUPRA/_VERIFICATIONS/` | AR-VERIFICATIONS | Vérifications passées |
| `~/Desktop/NOVA_OS/SUPRA/Evidence/` | AR-EVIDENCE | Preuves archivées |
| `~/Desktop/DESKTOP_CLEAN_ARCHIVE_20260630_122028/` | AR-DESKTOP | Archive Desktop (7 sous-dossiers) |
| `~/Desktop/NOVA_OS/SUPRA/_NON_RUNTIME_ARCHITECTURE/` | AR-ARCH | Architecture non-runtime |
| `~/Desktop/NOVA_OS/SUPRA/_MISSIONS/` | AR-MISSIONS | Missions archivées |

### 7. SNAPSHOTS (SN)

| Path | Type | Description |
|------|------|-------------|
| `~/Desktop/SUPRA_PROJECTS/` | SN-PROJECTS | 76 snapshots de projets historiques |
| `~/Desktop/SUPRA_CONTINUITY_20260724_160526/` | SN-CONTINUITY | Snapshot continuité |
| `~/Desktop/SUPRA_MEMORY_DISCOVERY_20260722_231052/` | SN-MEMORY | Snapshot mémoire |
| `~/Desktop/SUPRA_MISSION_001_20260722_225909/` | SN-MISSION | Snapshot mission 001 |
| `~/Desktop/SUPRA_CANONICAL_SELECTION_20260722_224439/` | SN-CANONICAL | Snapshot sélection canonique |
| `~/Desktop/SUPRA_AUTOINTEGRATOR_20260723_005325/` | SN-AUTOINTEGRATOR | Snapshot auto-intégrateur |
| `~/Desktop/SUPRA_ROOT_CAUSE/` | SN-ROOTCAUSE | Snapshot root cause |
| `~/Desktop/SUPRA_V4/` | SN-V4 | Snapshot V4 |
| `~/Desktop/SUPRA_ACTIVE_PROJECT_DISCOVERY/` | SN-DISCOVERY | Snapshot discovery |
| `~/Desktop/NOVA_OS/SUPRA_BISECT/` | SN-BISECT | Snapshot bisect |
| `~/Desktop/NOVA_OS/SUPRA_FRESH/` | SN-FRESH | Snapshot fresh |
| `~/Desktop/NOVA_OS/SUPRA_MODEL_TEST/` | SN-MODELTEST | Snapshot model test |
| `~/Desktop/NOVA_OS/SUPRA_RECOVERY/` | SN-RECOVERY | Snapshot recovery |
| `~/Desktop/NOVA_OS/SUPRA_RUNTIME_EVIDENCE_READONLY/` | SN-EVIDENCE | Snapshot evidence read-only |
| `~/Desktop/OPENCODE_AUDIT_20260724_220340/` | SN-OPENCODE-AUDIT | Snapshot audit OpenCode |
| `~/Desktop/OPENCODE_PROVIDER_DIAG_20260724_221311/` | SN-PROVIDER-DIAG | Snapshot diagnostic provider |
| `~/Desktop/OPENCODE_PROVIDER_FORENSICS_20260724_222014/` | SN-PROVIDER-FORENSICS | Snapshot forensics provider |
| `~/Desktop/STORAGE_AUDIT_20260723_093501/` | SN-STORAGE-AUDIT | Snapshot audit stockage |
| `~/Desktop/NOVA_OS/SUPRA/Freeze/` | AW-FREEZE | Points de freeze (V3, V4) — voir Active Workspace |

### 8. TEMPORARY (TP)

| Path | Type | Description |
|------|------|-------------|
| `~/Desktop/SUPRA_TEMP/` | TP-TEMP | Fichiers temporaires, scripts backup, KRIMI |
| `~/Desktop/SUPRA_BUILD_FULL.log` | TP-LOG | Log de build volumineux |
| `~/Desktop/SUPRA_BUILD_MATRIX_20260724_154914.txt` | TP-MATRIX | Matrice de build |
| `~/Desktop/SUPRA_CONVERSATION_SUMMARY_*.txt` | TP-SUMMARY | Résumés de conversation |
| `~/Desktop/SUPRA_CONVERSATION_SUMMARY_*.md` | TP-SUMMARY | Résumés de conversation |
| `~/Desktop/SUPRA_DASHBOARDSNAPSHOT_AUDIT_*.txt` | TP-DASHBOARD | Snapshot dashboard |
| `~/Desktop/SUPRA_RECOVERY_REPORT_*.txt` | TP-RECOVERY | Rapport recovery |
| `~/Desktop/SUPRA_RECOVERY_V2_*.txt` | TP-RECOVERY | Recovery data (large) |
| `~/Desktop/SUPRA_REGRESSION_*.txt` | TP-REGRESSION | Rapport régression |
| `~/Desktop/SUPRA_RUNTIME_SEARCH.txt` | TP-SEARCH | Recherche runtime (large) |
| `~/Desktop/SUPRA_TOTAL_RECOVERY_*.txt` | TP-RECOVERY | Recovery totale (large) |
| `~/Desktop/SUPRA_VIDEO_SWAP_RUNTIME.log` | TP-LOG | Log runtime |
| `~/Desktop/TEST_VALIDATION.md` | TP-TEST | Test validation |
| `~/Desktop/TEST_VALIDATION_2.md` | TP-TEST | Test validation |
| `~/Desktop/*.sh` | TP-SCRIPTS | Scripts shell desktop |
| `~/Desktop/*.png` | TP-IMAGES | Captures d'écran |

### 9. SANDBOX (SB)

| Path | Type | Description |
|------|------|-------------|
| `~/Desktop/NOVA_OS/SUPRA_DEEPSEEK_EXIT_READINESS/` | SB-DEEPSEEK | Bac à sable DeepSeek |
| `~/Desktop/SUPRA_XCODE_IDENTITY/` | SB-XCODE-IDENTITY | Exploration identité Xcode |
| `~/Desktop/NOVA_OS/_IMMUNITY/` | SB-IMMUNITY | Logs immunité système |
| `~/Desktop/NOVA_OS/MEMORY_CORE/` | SB-MEMORY | Mémoire noyau NOVA |

### 10. EXTERNAL IMPORTS (EI)

| Path | Type | Description |
|------|------|-------------|
| `~/Desktop/SUPRA_BUILD/import/` | EI-IMPORT | 65535 fichiers importés (Desktop Cleanup data) |
| `~/Desktop/SUPRA_REPORTS/` | EI-REPORTS | Rapports classification desktop historiques |
| `~/Desktop/PLATFORM_CORE/` | EI-PLATFORM | Plateforme externe |

---

## Cross-Reference Matrix

| Category | Count | Est. Size | Risk | Priority |
|----------|-------|-----------|------|----------|
| Active Workspace | ~10 | Medium | Critical | P0 |
| Products | ~8 | Medium | High | P0 |
| Runtime | ~6 | Small | Medium | P1 |
| Development | ~10 | Large | Medium | P1 |
| Documentation | ~100+ | Medium | Low | P2 |
| Archives | ~11 | Large | Low | P2 |
| Snapshots | ~20 | Medium | Low | P3 |
| Temporary | ~25 | Very Large | Low | P3 |
| Sandbox | ~5 | Small | Low | P4 |
| External Imports | ~3 | Very Large | Low | P4 |

---

## Classification Rules

1. **Uniqueness**: chaque dossier appartient à une seule catégorie principale
2. **Immutability**: les catégories ne changent pas sans ADR
3. **Lifecycle Binding**: la catégorie détermine le cycle de vie par défaut
4. **Tagging**: toute création future doit être taggée dès la création
5. **Review**: la classification est revue à chaque phase majeure
