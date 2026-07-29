# G4 Accessibility Audit

**Date**: 2026-07-29
**Purpose**: Verify G4IntegrationView is reachable from the production application entry point

---

## 1. Active Application Entry Point

| Item | Value |
|------|-------|
| @main | `SUPRAOperationalCoreApp` |
| File | `SUPRA/SUPRAOperationalCoreApp.swift:3` |
| Root View | `SUPRAOSProductRootView()` |
| Boot | `ExecutiveBootManager` → boot sequence → `ExecutiveWindow` |
| Primary UI | `ExecutiveWindow` with sidebar + workspace + inspector |

`SUPRACommandCenterApp` is **commented out** (`//@main`). It is NOT the active entry point.

---

## 2. Navigation Graph

```
SUPRAOperationalCoreApp (@main)
  └─ SUPRAOSProductRootView
       └─ ExecutiveBootView (boot sequence)
            └─ ExecutiveWindow
                 ├─ ExecutiveSidebar (9 spaces)
                 │    ├─ MONITOR: cockpit, runtime
                 │    ├─ WORK: missions, decisions, workflows
                 │    ├─ EXPLORE: knowledge, discovery, workspace
                 │    └─ SYSTEM: settings
                 ├─ ExecutiveWorkspace (destination switch)
                 │    ├─ .cockpit → ExecutiveCockpit
                 │    ├─ .workflows → ExecutiveWorkflowListView
                 │    ├─ .missions → MissionCenterView
                 │    ├─ .knowledge → ConversationTwinView
                 │    ├─ .discovery → SUPRAEnvironmentCommandCenterView
                 │    ├─ .decisions → SUPRADecisionRoomView
                 │    ├─ .workspace → SUPRAOSWorkspaceExplorerView
                 │    ├─ .runtime → RuntimeDiagnosticsView
                 │    └─ .settings → SettingsView
                 └─ ExecutiveInspector
```

---

## 3. Reachability Status

| View | Referenced in ExecutiveWindow? | Reachable? |
|------|-------------------------------|------------|
| G4IntegrationView | NO — only in CommandCenterView | **NOT REACHABLE** |
| G1DashboardView | NO — only in CommandCenterView | **NOT REACHABLE** |
| ExportSection | NO — only in G1DashboardView | **NOT REACHABLE** |
| ExportView | NO — only in ExportSection | **NOT REACHABLE** |
| HealthMonitorView | NO — only in G1DashboardView | **NOT REACHABLE** |
| CommandCenterView | NO — only in SUPRACommandCenterApp (dead) | **DEAD VIEW** |

---

## 4. Dead Views

`CommandCenterView` is defined and contains G1-G4 views, but it is **not referenced** from the active application entry point:

- `SUPRACommandCenterApp` (commented out @main) → CommandCenterView
- `SUPRAOperationalCoreApp` (active @main) → ExecutiveWindow → **no CommandCenterView**

CommandCenterView is a **dead view** — compiled but never displayed.

---

## 5. Required Integration Point

`G4IntegrationView` must be added to `ExecutiveWindow` to be reachable.

The most natural integration point is `ExecutiveCockpit` — the first screen users see after boot. It already displays system health, missions, knowledge, discovery, and decisions. Adding integration status here is architecturally consistent.

**Alternative**: Add `G4IntegrationView` as a new `ExecutiveSpace` entry (e.g., `.integrations`), but this adds navigation complexity and is disproportionate for a status card.

**Recommended**: Add `G4IntegrationView` as a card within `ExecutiveCockpit`, matching the existing `ExecutivePanel` pattern.

---

## 6. Decision

**OPTION B** — G4IntegrationView is not reachable.

### Required Integration Patch

Add `G4IntegrationView()` as an `ExecutivePanel` inside `ExecutiveCockpit`, within the existing health/status section. This is a minimal, targeted change:

- **File**: `SUPRA/ExecutiveWindow.swift` (inside `ExecutiveCockpit` body)
- **Location**: After `executiveHealth` panel, before `executiveAlerts`
- **Change**: Add one `G4IntegrationView()` card to the cockpit layout
- **Scope**: Single insertion point, no redesign, no Foundation modification

This patch makes G4 reachable from the production application with zero architectural changes.
