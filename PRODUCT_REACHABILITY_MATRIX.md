# Product Reachability Matrix

**Date**: 2026-07-29
**Purpose**: Verify production accessibility of every certified capability

---

## 1. Capability Reachability Summary

| Capability | Status | Reachable | Current Location | Target Location |
|------------|--------|-----------|------------------|-----------------|
| G1 — Unified Dashboard | CERTIFIED | **YES** | ExecutiveCockpit (production) | — (migrated) |
| G2 — Health Monitoring | CERTIFIED | **YES** | ExecutiveCockpit (production) | — (migrated) |
| G3 — Export & Reporting | CERTIFIED | **YES** | ExecutiveCockpit (production) | — (migrated) |
| G4 — Integration Dashboard | CERTIFIED | **YES** | ExecutiveCockpit (production) | — (already integrated) |

---

## 2. Detailed Analysis

### G1 — Unified Dashboard

| Item | Value |
|------|-------|
| Files | `G1DashboardView.swift` (199 lines), `DashboardModels.swift` (96 lines), `DashboardCoordinator.swift` (43 lines) |
| Total | 338 lines |
| Production Reachable | NO |
| Current Path | `CommandCenterView` → `G1DashboardView()` |
| Target Path | `ExecutiveCockpit` → `G1DashboardView()` |
| Dependencies | `@EnvironmentObject state: SUPRACommandCenterState`, `@StateObject coordinator: DashboardCoordinator` |
| Migration Effort | LOW — add as ExecutivePanel in ExecutiveCockpit |
| State Required | `SUPRACommandCenterState` (already injected into ExecutiveWindow) |

### G2 — Health Monitoring

| Item | Value |
|------|-------|
| Files | `HealthMonitorView.swift` (106 lines), `HealthModels.swift` (64 lines), `HealthAnomalyDetector.swift` (158 lines) |
| Total | 328 lines |
| Production Reachable | NO |
| Current Path | `G1DashboardView` → `HealthMonitorView()` |
| Target Path | `ExecutiveCockpit` → `HealthMonitorView()` |
| Dependencies | `@StateObject detector: HealthAnomalyDetector`, `@EnvironmentObject state: SUPRACommandCenterState` |
| Migration Effort | LOW — add as ExecutivePanel in ExecutiveCockpit |
| State Required | `SUPRACommandCenterState` (already injected) |

### G3 — Export & Reporting

| Item | Value |
|------|-------|
| Files | `ExportSection.swift` (46 lines), `ExportView.swift` (206 lines), `ExportModel.swift` (107 lines), `ExportService.swift` (267 lines) |
| Total | 626 lines |
| Production Reachable | NO |
| Current Path | `G1DashboardView` → `ExportSection()` → `ExportView()` |
| Target Path | `ExecutiveCockpit` → `ExportSection()` |
| Dependencies | `@EnvironmentObject state: SUPRACommandCenterState`, `@StateObject service: ExportService` |
| Migration Effort | LOW — add as ExecutivePanel in ExecutiveCockpit |
| State Required | `SUPRACommandCenterState` (already injected) |

### G4 — Integration Dashboard

| Item | Value |
|------|-------|
| Files | `G4Models.swift` (94 lines), `G4IntegrationService.swift` (122 lines), `G4IntegrationView.swift` (47 lines) |
| Total | 263 lines |
| Production Reachable | **YES** |
| Current Path | `ExecutiveCockpit` → `integrationsSection` → `G4IntegrationView()` |
| Dependencies | `@StateObject service: G4IntegrationService` (self-contained) |
| Migration Effort | NONE — already integrated |

---

## 3. Migration Plan

### Order: G1 → G2 → G3

| Step | Capability | Action | Files Modified |
|------|-----------|--------|----------------|
| 1 | G1 | Add `G1DashboardView()` as ExecutivePanel | `ExecutiveWindow.swift` |
| 2 | G2 | Add `HealthMonitorView()` as ExecutivePanel | `ExecutiveWindow.swift` |
| 3 | G3 | Add `ExportSection()` as ExecutivePanel | `ExecutiveWindow.swift` |

### Constraints

- No new files created
- No architecture redesign
- No Foundation modifications
- Reuse existing components as-is
- Single file modified: `ExecutiveWindow.swift`

---

## 4. Expected Outcome

After migration, ExecutiveCockpit will contain:

```
ExecutiveCockpit
  ├─ cockpitHeader
  ├─ kpiGrid
  ├─ executiveHealth + missionCenter
  ├─ knowledgeCenter + discoveryCenter + decisionCenter
  ├─ G1DashboardView (NEW)
  ├─ HealthMonitorView (NEW)
  ├─ ExportSection (NEW)
  ├─ integrationsSection (G4 — existing)
  ├─ executiveAlerts
  └─ timeline
```

All four certified capabilities will be reachable from the production application.

---

**Documented by**: SUPRA-Architect
**Date**: 2026-07-29
