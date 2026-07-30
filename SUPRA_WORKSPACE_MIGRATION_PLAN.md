# SUPRA WORKSPACE MIGRATION PLAN

**Version**: 1.0  
**Status**: STABLE (Plan Only — No Execution)  
**Category**: Workspace Governance  
**Path**: `SUPRA_WORKSPACE_MIGRATION_PLAN.md`

---

## Migration Rules

1. **ZERO EXECUTION** — Ce plan n'est pas exécuté durant cette mission.
2. **Reversibility First** — Toute opération doit avoir un rollback documenté.
3. **No Data Loss** — Backup avant chaque déplacement.
4. **Core Protection** — SUPRA CORE reste strictement inchangé.
5. **Phased Approach** — Migration par vagues, pas tout à la fois.

---

## Phase 0: Desktop Cleanup (Desktop-Level Files)

### Files to Remove (Desktop → appropriate location)

| File | Target | Action | Reversible |
|------|--------|--------|------------|
| `*.sh` scripts (30 scripts) | `SUPRA_SCRIPTS/` | Move | Yes (unmove) |
| `*.log` files (5 files) | `Logs/` or delete | Move + Archive | Yes |
| `*.txt` reports (10 files) | `SUPRA_RUNTIME/` or `Reports/` | Move | Yes |
| `*.md` test files (2 files) | `SUPRA_TEMP/` | Move | Yes |
| `*.png` screenshots (4 files) | `Artifacts/` or `Evidence/` | Move | Yes |
| `opencode.jsonc.DIAG` | `.opencode/` | Move | Yes |
| `desktop_clean_archive_20260630_122028/` | `Archives/` (future) | Keep in place until Phase 2 | Yes |

### Priority: P1 (after plan validation)

---

## Phase 1: Sibling Consolidation (NOVA_OS Level)

| Directory | Category | Recommended Action | Justification |
|-----------|----------|--------------------|---------------|
| `SUPRA_BISECT/` | Snapshot | Merge into `SUPRA_PROJECTS/` as dated snapshot | Duplicate of main SUPRA at a point in time |
| `SUPRA_FRESH/` | Snapshot | Merge into `SUPRA_PROJECTS/` as dated snapshot | Similar to BISECT |
| `SUPRA_MODEL_TEST/` | Snapshot | Merge into `SUPRA_PROJECTS/` | Test snapshot |
| `SUPRA_RECOVERY/` | Snapshot | Merge into `SUPRA_PROJECTS/` | Recovery snapshot |
| `SUPRA_RUNTIME_EVIDENCE_READONLY/` | Snapshot | Merge into `SUPRA_PROJECTS/` | Evidence snapshot |
| `SUPRA_DEEPSEEK_EXIT_READINESS/` | Sandbox | Keep separate or move to `Sandbox/` (future) | Active sandbox |
| `_IMMUNITY/` | Sandbox | Keep in place | System logs |
| `MEMORY_CORE/` | Sandbox | Keep in place | NOVA core memory |

### Priority: P2 (after Desktop is clean)

---

## Phase 2: Desktop Directory Restructuring

| Directory | Category | Action | Target | Justification |
|-----------|----------|--------|--------|---------------|
| `SUPRA_VIDEO_SWAP_APP_V1/` | Product | Move | `Products/SUPRA_VIDEO_SWAP/V1/` | Product consolidation |
| `SUPRA_VIDEO_SWAP_V3/` | Product | Move | `Products/SUPRA_VIDEO_SWAP/V3/` | Product consolidation |
| `SUPRA_VIDEO_SWAP_V1_ARCHIVE_*` | Archive | Move | `Archives/SUPRA_VIDEO_SWAP/` | Archive consolidation |
| `SupraVideoSwap_*.app` | Product | Move | `Products/SUPRA_VIDEO_SWAP/Bundles/` | Bundle consolidation |
| `PLATFORM_CORE/` | Product | Move | `Products/PLATFORM_CORE/` | Product consolidation |
| `SUPRA_BUILD/` | Dev | Keep | See note below | Contains import/ (massive) |
| `SUPRA_SCRIPTS/` | Archive | Move | `Scripts/` (future) | Script library |
| `SUPRA_PROJECTS/` | Snapshot | Move | `Snapshots/` (future) | Snapshot consolidation |
| `SUPRA_TEMP/` | Temp | Purge | After selective backup | Temporary data |
| `SUPRA_ARCHIVE/` | Archive | Move | `Archives/` (future) | Archive consolidation |
| `SUPRA_RELEASE/` | Doc | Move into | `NOVA_OS/SUPRA/docs/releases/` | Doc consolidation |
| `SUPRA_REPORTS/` | External Import | Archive | `Archives/External/` | Historical reports |
| `SUPRA_CONTINUITY_*/` | Snapshot | Move | `Snapshots/SUPRA_CONTINUITY/` | Snapshot |
| `SUPRA_MEMORY_DISCOVERY_*/` | Snapshot | Move | `Snapshots/SUPRA_MEMORY/` | Snapshot |
| `SUPRA_MISSION_001_*/` | Snapshot | Move | `Snapshots/SUPRA_MISSIONS/` | Snapshot |
| `SUPRA_CANONICAL_SELECTION_*/` | Snapshot | Move | `Snapshots/SUPRA_CANONICAL/` | Snapshot |
| `SUPRA_AUTOINTEGRATOR_*/` | Snapshot | Move | `Snapshots/SUPRA_AUTOINTEGRATOR/` | Snapshot |
| `SUPRA_RUNTIME_CLEANUP_*/` | Runtime | Archive | `Archives/Runtime/` | Runtime cleanup data |
| `SUPRA_ROOT_CAUSE/` | Snapshot | Move | `Snapshots/SUPRA_ROOT_CAUSE/` | Snapshot |
| `SUPRA_V4/` | Snapshot | Move | `Snapshots/SUPRA_V4/` | Snapshot |
| `SUPRA_ACTIVE_PROJECT_DISCOVERY/` | Snapshot | Move | `Snapshots/SUPRA_DISCOVERY/` | Snapshot |
| `SUPRA_XCODE_TARGETED_RECOVERY_*/` | Archive | Move | `Archives/Xcode/` | Recovery archive |
| `SUPRA_XCODE_IDENTITY/` | Sandbox | Keep or move to `Sandbox/` | Minimal data |
| `OPENCODE_AUDIT_*/` | Snapshot | Move | `Snapshots/OpenCode/` | Audit snapshot |
| `OPENCODE_PROVIDER_DIAG_*/` | Snapshot | Move | `Snapshots/OpenCode/` | Provider diagnostic |
| `OPENCODE_PROVIDER_FORENSICS_*/` | Snapshot | Move | `Snapshots/OpenCode/` | Provider forensics |
| `STORAGE_AUDIT_*/` | Snapshot | Move | `Snapshots/SUPRA_STORAGE/` | Storage audit |
| `SUPRA_TERMINAL_RUNTIME_AUDIT_SAFE_*/` | Runtime | Archive | `Archives/Runtime/` | Terminal audit |
| `_DESKTOP_CLEAN_ARCHIVE_*/` | Archive | Keep in place | Already organized |

### Priority: P3 (after Phases 0-1)

---

## Phase 3: Core Internal Cleanup (NOVA_OS/SUPRA/)

| Path | Action | Justification |
|------|--------|---------------|
| `_FOUNDATION_MEMORY/` | Keep (archive) | Foundation memory archive |
| `_MISSIONS/` | Keep (archive) | Archived missions |
| `_NON_RUNTIME_ARCHITECTURE/` | Keep (archive) | Architecture docs |
| `_SUPRA_BACKUPS/` | Keep (archive) | System backups |
| `_VERIFICATIONS/` | Keep (archive) | Past verifications |
| `SUPRA_RUNTIME/Inbox/` | Keep (active) | Runtime inbox |
| `SUPRA_RUNTIME/Outbox/` | Keep (active) | Runtime outbox |
| `SUPRA_RUNTIME/Running/` | Keep (active) | Running tasks |
| `SUPRA_RUNTIME/Blocked/` | Review periodically | Blocked items |
| `SUPRA_RUNTIME/Done/` | Archive periodically | Completed |
| `SUPRA_HANDOFF_OPENCODE_V2_1/` | Keep | Active handoff |
| `SUPRA_E2E_PROOF_HARNESS_V1/` | Keep | Active proof harness |
| `.analysis/` | Keep (hidden) | Analysis data |
| `.cannonico/` | Keep (hidden) | Canonical data |
| `.mechanical_extract_backup_*/` | Archive | Backup data |
| `.overnight_audit/` | Archive | Audit data |
| `.restore_build/` | Archive | Build restore data |
| `.supra_reports/` | Keep (hidden) | Reports data |
| `SUPRA_AST_PLATFORM/` | Keep | Active AST platform |
| `EXECUTIVE_ARCHIVES/` | Keep | Executive archives |

### Priority: P4 (after Desktop is organized)

---

## Migration Sequence Diagram

```
Phase 0 (P1)    Phase 1 (P2)    Phase 2 (P3)    Phase 3 (P4)
Desktop Files    NOVA_OS Siblings  Desktop Dirs     Core Internal
    |                |                |                |
    v                v                v                v
[Clean scripts]  [Consolidate]    [Restructure]    [Organize]
[Move logs]      [Merge snaps]    [Create dirs]    [Purge temp]
[Remove temp]    [Classify]       [Move products]  [Archive old]
```

---

## Rollback Strategy

Chaque opération doit être accompagnée d'un rollback plan :

| Operation | Rollback |
|-----------|----------|
| Move file | `mv <target> <source>` |
| Merge directory | Restore from backup |
| Archive directory | `unzip` + restore |
| Delete temp file | Restore from backup (if exists) |
| Create directory | `rmdir` |

---

## Pre-Migration Checklist

Avant chaque phase de migration :

- [ ] Backup complet du workspace
- [ ] Checksum des dossiers concernés
- [ ] Notification Executive
- [ ] Fenêtre de maintenance planifiée
- [ ] Rollback script préparé
- [ ] Workspace Index mis à jour (simulation)
- [ ] Post-migration audit planifié

---

## Post-Migration Verification

Après chaque phase :

- [ ] Aucune perte de données
- [ ] Workspace Index reflète la nouvelle structure
- [ ] Liens symboliques fonctionnels (si utilisés)
- [ ] Tests CI passent
- [ ] SUPRA CORE inchangé
- [ ] Rapport de migration produit
