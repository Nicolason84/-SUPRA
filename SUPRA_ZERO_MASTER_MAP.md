# SUPRA ZERO — Master Map

## Overview

SUPRA ecosystem spans **two NOVA_OS roots**, **multiple workspaces**, **562+ directories** at `~/NOVA_OS`, and **101 Desktop entries**.

## Primary Workspace (Active)

| Property | Value |
|----------|-------|
| **Path** | `/Users/nicolasalonso/Desktop/NOVA_OS/SUPRA` |
| **Type** | Xcode project (SwiftUI) |
| **Git** | Branch `develop`, 19 commits, 12 ahead of origin |
| **Swift files** | 214 in SUPRA/, 9 in SUPRATests/ |
| **Docs** | 130 `.md`, 123 `.json`, 27 `.sh` |
| **Runtime** | v2.2.0, build SUCCEEDED, 10-stage pipeline |
| **Status** | CAMP_BASE_02_FOUNDATION, WORKSPACE_MANIFEST valid |

## SECONDARY SUPRA Workspaces (Desktop/NOVA_OS)

| # | Workspace | Purpose | Git | Activity |
|---|-----------|---------|-----|----------|
| 1 | SUPRA_BISECT | Regression bisection | Yes | 2026-07-24 |
| 2 | SUPRA_DEEPSEEK_EXIT_READINESS | DeepSeek exit migration test | Yes | 2026-07-28 |
| 3 | SUPRA_FRESH | Clean clone for fresh builds | Yes | 2026-07-26 |
| 4 | SUPRA_MODEL_TEST | Provider model testing | Yes | 2026-07-25 |
| 5 | SUPRA_RECOVERY | Recovery scenarios | No | 2026-07-24 |
| 6 | SUPRA_RUNTIME_EVIDENCE_READONLY | Runtime proof evidence | No | 2026-07-25 |

## EXTERNAL SUPRA Locations

### `~/SUPRA_RELEASE` — 155 files
Legal documents, contracts, declarations, observations, references. Static archive from 2026-07-22.

### `~/SUPRA_CORE` — Node.js core (13 entries)
Older generation SUPRA (Node.js): backend, app, ui, core modules. Dated 2026-06-29.

### `~/SUPRA_SHELL` — Swift Package Manager shell
Swift CLI shell project. Dated 2026-07-22.

### `~/SUPRA_STABLE_V1` — Node.js stable (9 entries)
Stable V1 release: app, backend, ui, node_modules. Dated 2026-06-29.

### `~/SUPRA_OS_V2 / SUPRA_OS_V3`
Older OS generations (Node.js + backend + ui + core).

### `~/SUPRA_PRODUCT` — Product space (SUPRA_MVP, SUPRA_PRODUCT)

### `~/NOVA_ERA_SUPRA` — 172 entries
Older SUPRA generation with freezes, scripts, architecture books.

### `~/NOVA_CORE` — 144 entries
Decision hub, projects, engines, runtime, archives.

### `~/NOVA_RUNTIME` — 47 entries
Runtime services: CONTROL_TOWER, APPCREATOR, ENERGY_SCHEDULER, etc.

### `~/NOVA_BUILD_SYSTEM` — 103 entries, git repo
Build system with analyzers, agents, backend.

### `~/NOVA_LABS` — 650 entries
Experimental space: 00_CANON through 04_MEMORY_CORE, snapshots, archives.

## Desktop (101 entries)

### Active Tools (scripts)
- `GO_SUPRA_*.sh` — 30+ orchestration scripts
- `GO_INSTALL_ACTIVATE_SUPRA_CONTINUOUS_RUNTIME_V1.sh`
- `GO_OPENCODE_FIX_STAGE0.sh`, `GO_OPENCODE_PROVIDER_FORENSICS.sh`
- `opencode_*.sh` — diagnostic scripts

### SUPRA Projects (`~/Desktop/SUPRA_PROJECTS` — 73 dirs)
Audits, cases (ondupack, Lulu), capability engines, phase missions (Phase1-Phase13), memories, storages.

### SUPRA Archives
- `~/Desktop/SUPRA_ARCHIVE` — 5 zip files (GPT, SUPRA_XCODE_RECOVERY, SupraVideoSwap)
- `~/Desktop/_DESKTOP_CLEAN_ARCHIVE_20260630_122028` — historical cleanup

### SUPRA Temp
- `~/Desktop/SUPRA_TEMP` — 34 items, temp scripts, GPT exports

### Build Artifacts
- `~/Desktop/SUPRA_BUILD` — 21 entries, build outputs
- `~/Desktop/PLATFORM_CORE` — new platform core template (5 entries)

## `~/NOVA_OS/` (562 entries — Historical)

Contains **~400 SUPRA_* directories** representing every phase, mission, audit, and experiment. Key categories:

| Category | Count | Examples |
|----------|-------|---------|
| PHASE missions | ~60 | SUPRA_PHASE1 through SUPRA_PHASE13, each with multiple sub-missions |
| Memory/Recovery | ~25 | SUPRA_MEMORY_CORE_V1, SUPRA_MEMORY_RECOVERY_V1, etc. |
| Executive | ~15 | SUPRA_EXECUTIVE_BLUEPRINT, SUPRA_EXECUTIVE_RUNTIME_V1, etc. |
| Audit/Verification | ~50 | SUPRA_AUDIT_CANONIQUE_360_V1, SUPRA_BRIDGE_DETERMINISTIC_EVIDENCE_TEST_V2, etc. |
| Storage | ~15 | SUPRA_STORAGE_TWIN_V1, SUPRA_STORAGE_RECOVERY_V1, etc. |
| Canonical | ~20 | SUPRA_CANONICAL_APP_V1, SUPRA_CANONICAL_WELL_V2, etc. |
| Infrastructure | ~30 | SUPRA_BUILD, SUPRA_FACTORY_V1, SUPRA_CONTROL, etc. |
| Archive/Freeze | ~15 | _SUPRA_ANTIAMNESIE_20260611, _SUPRA_CORE_DISCOVERY, etc. |
| Helene (iOS/Android) | ~5 | SUPRA_HELENE_IOS, SUPRA_HELENE_ANDROID, etc. |

## Runtime Instances

| Runtime | Location | Version | Status |
|---------|----------|---------|--------|
| SUPRA Executive Runtime V1 | `~/NOVA_OS/SUPRA_EXECUTIVE_RUNTIME_V1` | 1.0 | FROZEN (with backups) |
| SUPRA Runtime V6 | `~/NOVA_OS/_SUPRA_RUNTIME_V6` | V6 | Historic |
| SUPRA Runtime V2 | `~/NOVA_ERA_SUPRA/SUPRA_RUNTIME_V2` | V2 | Historic |
| Active Runtime | `~/Desktop/NOVA_OS/SUPRA` | 2.2.0 | ACTIVE |

## Applications Built

| App | Location | Notes |
|-----|----------|-------|
| SUPRA.app | `~/Applications/SUPRA.app` | Built app |
| SUPRA Mission Launcher.app | `~/Applications/` | Mission launcher |
| SUPRA_OS_WEBVIEW.app | `~/Applications/` | WebView OS |
| SUPRA Partner Twin App | `~/SUPRA_PARTNER_TWIN_APP_V1` | Twin app |
| SUPRA Video Swap | `~/Desktop/SUPRA_VIDEO_SWAP_APP_V1` | Video swap app |

## Dependency Graph

```
Desktop (orchestration)
  |
  +-> Desktop/NOVA_OS/SUPRA (ACTIVE WORKSPACE)
  |     |-- SUPRA/ (214 Swift files)
  |     |-- SUPRA.xcodeproj
  |     |-- SUPRATests/
  |     |-- .opencode/ (runtime config)
  |     |-- .kernel/ (node identity)
  |     +-- FREEZES/ (5 snapshots)
  |
  +-> Desktop/SUPRA_PROJECTS (73 audit missions)
  +-> Desktop/SUPRA_BUILD (build artifacts)
  +-> Desktop/SUPRA_TEMP (temporary exports)
  +-> Desktop/PLATFORM_CORE (template)
  |
  +-> ~/SUPRA_RELEASE (legal archive)
  +-> ~/SUPRA_CORE (Node.js old gen)
  +-> ~/SUPRA_SHELL (SPM shell)
  +-> ~/NOVA_ERA_SUPRA (older gen, 172 entries)
  +-> ~/NOVA_CORE (hub, 144 entries)
  +-> ~/NOVA_RUNTIME (services, 47 entries)
  +-> ~/NOVA_BUILD_SYSTEM (build system, 103 entries)
  +-> ~/NOVA_LABS (experiments, 650 entries)
  |
  +-> ~/NOVA_OS/ (562 entries, historical SUPRA missions)
```

## Key Insight

**The active workspace is `~/Desktop/NOVA_OS/SUPRA`.** All other SUPRA locations are either:
- **Historical**: older generations, frozen missions, previous phases
- **Parallel**: temporary clones for testing (bisect, fresh, model test, deepseek exit)
- **Archival**: legal documents, zip archives, cleanup backups
- **External NOVA**: NOVA_CORE, NOVA_RUNTIME, NOVA_BUILD_SYSTEM, NOVA_LABS (shared with SUPRA)
