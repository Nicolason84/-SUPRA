# Baseline V1 — Operational Reference

**Frozen**: 2026-07-29
**Authority**: SUPRA Executive
**Precedence**: This baseline is the unique reference for all future development.

---

## 1. Identity

| Item | Value |
|------|-------|
| Commit | `4194eac0f13618bafe0e0543658c172b6ab5c300` |
| Branch | `develop` |
| Date | 2026-07-29 |
| Swift Files | 239 |
| Build | SUCCEEDED |
| Regression | 0 |

---

## 2. Certified Capabilities

| ID | Capability | Status | Tag | Reachable |
|----|-----------|--------|-----|-----------|
| G1 | Unified Dashboard | CERTIFIED | `g1-certified-v1` | YES (ExecutiveCockpit) |
| G2 | Health Monitoring | CERTIFIED | — | YES (ExecutiveCockpit) |
| G3 | Export & Reporting | CERTIFIED | `g3-certified-v1` | YES (ExecutiveCockpit) |
| G4 | Integration Dashboard | CERTIFIED | `g4-certified-v1` | YES (ExecutiveCockpit) |

---

## 3. Runtime Foundation

| Component | Lines | Status |
|-----------|-------|--------|
| `SUPRAEnvironmentResolver.swift` | 76 | FROZEN |
| `ContinuityManager.swift` | 432 | FROZEN |
| `ExecutiveBootManager.swift` | 487 | FROZEN |

**Protection**: No modification without Executive Decision + FACTORY_06 certification.

---

## 4. ExecutiveCockpit Layout

```
ExecutiveCockpit
  ├─ cockpitHeader
  ├─ kpiGrid (Missions, Decisions, Knowledge, Discoveries, Health, Alerts)
  ├─ executiveHealth + missionCenter
  ├─ knowledgeCenter + discoveryCenter + decisionCenter
  ├─ integrationsSection (G4)
  ├─ dashboardSection (G1)
  ├─ healthSection (G2)
  ├─ exportSection (G3)
  ├─ executiveAlerts
  └─ timeline
```

---

## 5. Navigation Structure

| Sidebar Group | Spaces | Keyboard |
|--------------|--------|----------|
| MONITOR | cockpit, runtime | ⌘1, ⌘8 |
| WORK | missions, decisions, workflows | ⌘3, ⌘6, ⌘2 |
| EXPLORE | knowledge, discovery, workspace | ⌘4, ⌘5, ⌘7 |
| SYSTEM | settings | ⌘9 |

---

## 6. Known Limitations

| ID | Limitation | Severity |
|----|-----------|----------|
| NB1 | No "Take Decision" action button on proposal cards | LOW |
| NB2 | No onboarding flow for new users | LOW |
| NB3 | ExportView requires environment object injection | LOW |

---

## 7. Development Policy

From this baseline forward:

### Branching
- Every new capability MUST branch from Baseline V1 commit `4194eac`
- No direct modification of `develop` without passing through the capability pipeline

### Preservation Rules
- Build must always succeed
- Regression must remain zero
- ExecutiveCockpit integrity must be preserved
- Runtime Foundation must remain unchanged
- All certified capabilities must remain reachable

### Change Control
Every future evolution must include:
1. **Objective** — What and why
2. **Impact Analysis** — What is affected
3. **Implementation** — The change
4. **Validation** — Proof it works
5. **Evidence** — Objective artifacts
6. **Rollback** — How to revert

### Rejection Criteria
Any commit that violates the baseline is rejected:
- Breaks build
- Introduces regression
- Modifies Foundation without authorization
- Makes a certified capability unreachable
- Adds dead views

---

## 8. Stabilization History

| Commit | Description |
|--------|-------------|
| `4194eac` | Pilot Execution Report V1 |
| `c249efd` | Stabilization Sprint V1 complete |
| `aba1d89` | NB5: Remove redundant G1DashboardView header |
| `173af8e` | NB4: Delete dead CommandCenterView |
| `7d7aeee` | S3: Remove duplicate HealthMonitorView |
| `63457f2` | S2: Remove duplicate ExportSection |
| `a5577a7` | S1: Remove nested ScrollView |

---

## 9. Certification

**Decision**: FROZEN

Baseline V1 is the official operational reference for SUPRA. All future work must preserve or extend this baseline without degrading it.

---

**Frozen by**: SUPRA Executive
**Date**: 2026-07-29
**Commit**: `4194eac`
