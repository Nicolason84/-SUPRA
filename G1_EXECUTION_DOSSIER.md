# G1 — Unified Project Dashboard: Execution Dossier

**Date**: 2026-07-29
**Priority**: #1 (next after G2)
**Status**: PLANNED
**Governed by**: CAPABILITY_PIPELINE.md V1

---

## 1. Scope

### Objective
Create a unified project dashboard within the SUPRA Command Center that aggregates all project health, runtime status, memory state, mission progress, and quick-access actions into a single, coherent view.

### Boundaries
- **In scope**: UI composition of existing views into a unified Dashboard layout; unified navigation; consolidated status indicators
- **Out of scope**: New data models (beyond layout config); new network layers; Foundation modifications; AI/ML features

### Deliverables
- `G1_DashboardView.swift` — unified dashboard component
- `G1_DashboardModels.swift` — dashboard layout configuration
- Integration into `CommandCenterView.swift` (additive)
- `IMPLEMENTATION_DOSSIER_G1.md` — implementation plan

---

## 2. Architecture Impact

| Component | Impact |
|-----------|--------|
| SUPRAEnvironmentResolver | NONE (consumed only) |
| ContinuityManager | NONE (consumed only) |
| ExecutiveBootManager | NONE (consumed only) |
| RuntimeContract V1 | NONE |
| RuntimeFoundation V2 | NONE |
| RuntimeConstitution V1 | NONE |
| CommandCenterView | ADDITIVE (G1_DashboardView added to grid) |
| HealthMonitorView | None (already integrated in G2) |
| Existing views (HealthView, RuntimeView, etc.) | None (consumed as subviews) |

**Total architecture risk**: MINIMAL. Pure UI composition with zero Foundation changes.

---

## 3. Milestones

| Milestone | Description | Acceptance Criteria | Est. Lines |
|-----------|-------------|---------------------|------------|
| M1 | DashboardModels — layout config, view registry, grid configuration | Models compile, grid config valid | ~80 |
| M2 | DashboardCoordinator — navigation and view orchestration | Coordinator routes to all subviews, state management works | ~100 |
| M3 | DashboardView — main unified dashboard layout | Layout renders all subviews in grid, sidebar navigation works | ~120 |
| M4 | Dashboard Integration — integrate into CommandCenterView | Command Center shows unified dashboard alongside existing views | ~50 |
| M5 | Polish & Certification — final validation, docs, production readiness | BUILD SUCCEEDED, zero regressions, certification report issued | ~50 |

**Total estimated**: ~400 lines across 5 increments

---

## 4. Acceptance Criteria

1. BUILD SUCCEEDED after each milestone (xcodebuild)
2. App launches with exit code 0
3. DashboardView renders all sub-views (Health, Runtime, Memory, Mission, etc.) in a unified grid
4. Navigation between dashboard views works without manual switching
5. Consolidated status indicators (connection, sync, errors, agents, missions) visible at a glance
6. Existing Command Center functionality preserved (no regressions)
7. Zero lines changed in any Foundation component
8. Zero hardcoded paths in any new G1 file
9. No modifications to SUPRAEnvironmentResolver, ContinuityManager, or ExecutiveBootManager
10. Documentation dossier published

---

## 5. Validation Plan

### Per-Milestone Validation
- xcodebuild BUILD after EACH milestone commit
- App launch verification after final milestone

### Constitutional Integrity Check
- git diff on all Foundation components must be 0 lines
- grep on G1 files for hardcoded paths must return 0 matches

### Regression Testing
- All G2 capability tests still pass (HealthMonitorView functional)
- Existing CommandCenterView subviews still accessible
- All existing SUPRA.app features untouched

### Final Certification
- PHASE 4 validation (build, signing, launch)
- PHASE 5 certification report issued

---

## 6. Rollback Strategy

| Scenario | Rollback Action |
|----------|----------------|
| G1 build fails at any milestone | Revert to last GREEN milestone commit |
| G1 causes regression in CommandCenterView | git checkout pre-G1 CommandCenterView state |
| G1 breaks Foundation components | IMPOSSIBLE by design — if occurs, halt and escalate to Executive |
| G1 does not meet acceptance criteria | Remediate in current milestone, do not proceed |

**Rollback mechanism**: Each milestone is a separate git commit. Rollback = git revert or git reset --hard to last green commit.

---

## 7. Measurable Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Build success rate | 100% (5/5 milestones) | xcodebuild output |
| Constitutional integrity | 0 lines changed | git diff on Foundation |
| Hardcoded paths | 0 in new files | grep audit |
| User value | Unified view reduces navigation time by >= 50% | User testing (post-deployment) |
| Regression rate | 0 regressions | All existing features tested |
| Incremental delivery | 5 increments delivered | M1-M5 commits |
| Documentation completeness | 4 deliverables published | Design, Implementation, Validation, Regression |

---

## 8. Dependency Graph

G1 (Unified Project Dashboard):
 ├── depends on G2 (HealthMonitorView) -- CERTIFIED
 ├── consumed by CommandCenterView -- existing, stable
 ├── composed views: HealthView, RuntimeView, MemoryView, MissionView -- existing, stable
 └── no new Foundation dependencies

**Dependency risk**: LOW. All dependencies are already certified or pre-existing.
