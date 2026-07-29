# G1 Dashboard Composition Plan

**Date**: 2026-07-29
**Document**: Phase 2 of G1 Execution
**Status**: PLANNED — pending validation

---

## 1. Dashboard Sections

| Section | Existing Reusable Component | New Component Required | Runtime Dependency | State Dependency | Artifact Dependency |
|---------|----------------------------|----------------------|-------------------|-----------------|-------------------|
| **Header** | `CommandCenterView.header` (existing) | `DashboardHeaderView` (new — consolidated status strip with connection, sync, error count, agent availability) | None | `SUPRACommandCenterState.shared.snapshot` | None |
| **System Health** | `HealthView` (existing) | None | SUPRACommandCenterState | `state.healthSection` | None |
| **Runtime Status** | `RuntimeView` (existing) | None | SUPRACommandCenterState | `state.runtimeSection` | None |
| **CAnnoNico Memory** | `MemoryView` (existing) | None | SUPRAEnvironmentResolver | `state.cannonicoSection` | Memory snapshot artifacts |
| **Missions** | `MissionView` (existing) | None | SUPRACommandCenterState | `state.missionsSection` | Mission store |
| **Intelligence** | `IntelligenceView` (existing) | None | SUPRAEnvironmentResolver | `state.intelligenceSection` | Intelligence engine state |
| **G2 Health Alerts** | `HealthMonitorView` (existing, G2) | None | RuntimeMonitor | HealthMonitorView internal | None |
| **Navigation** | None | `DashboardNavigationView` (new — sidebar section navigation) | None | Dashboard navigation state | None |
| **Consolidated Indicators** | None | `DashboardIndicatorsBar` (new — single row of key metrics: connection state, sync duration, error count, agent availability) | `RuntimeHealth` via `SUPRACommandCenterState` | `state.runtimeSection` + `state.healthSection` | None |
| **Actions** | None | `DashboardActionsBar` (new — quick-access actions: refresh, acknowledge alerts, navigate to specific views) | None | Dashboard state | None |

---

## 2. Composition Rules

### Rule 1: Compose, Do Not Replace
Every existing view (HealthView, RuntimeView, MemoryView, MissionView, IntelligenceView, HealthMonitorView) is reused exactly as-is. No modifications, no replacements, no deletions.

### Rule 2: Additive Integration Only
DashboardView is a new view that embeds the existing views into a unified layout. It does NOT modify any existing view file.

### Rule 3: Single Writer
Only SUPRA-Builder writes files. All other phases are READ-ONLY.

### Rule 4: Foundation Immutable
No Foundation component (SUPRAEnvironmentResolver, ContinuityManager, ExecutiveBootManager, RuntimeContract, RuntimeFoundation, RuntimeConstitution) is modified.

### Rule 5: Design System Compliance
All spacing, padding, colors, fonts, and shadows reference SUPRAOSDesignSystem.*. No hardcoded values.

### Rule 6: State Model Reuse
All state data comes from SUPRACommandCenterState.shared. No new state objects or data models defined (except G1_DashboardModels.swift for layout configuration only).

---

## 3. View Hierarchy

```
DashboardView (NEW)
 ├── DashboardHeaderView (NEW)
 │   ├── Title: "SUPRA Dashboard"
 │   ├── Live indicator (from SUPRACommandCenterState)
 │   └── Consolidated indicators bar (NEW)
 │       ├── Connection state (from RuntimeHealth)
 │       ├── Sync duration (from RuntimeHealth)
 │       ├── Error count (from RuntimeHealth)
 │       └── Agent availability (from RuntimeHealth)
 ├── DashboardNavigationView (NEW)
 │   ├── Section links: Health, Runtime, Memory, Missions, Intelligence, Alerts
 │   └── Active section highlighting
 └── DashboardContentGrid (NEW — LazyVGrid)
     ├── HealthView (existing, REUSABLE)
     ├── RuntimeView (existing, REUSABLE)
     ├── MemoryView (existing, REUSABLE)
     ├── MissionView (existing, REUSABLE)
     ├── IntelligenceView (existing, REUSABLE)
     └── HealthMonitorView (existing, G2, REUSABLE)
```

---

## 4. Runtime Dependencies

| Dependency | Type | Consumed By | Modification |
|-----------|------|-------------|-------------|
| SUPRAEnvironmentResolver.shared | Service | DashboardView | CONSUME ONLY |
| SUPRACommandCenterState.shared | State | All dashboard views | CONSUME ONLY |
| RuntimeMonitor | Service | DashboardIndicatorsBar | CONSUME ONLY |
| RuntimeHealth | Data | DashboardIndicatorsBar | CONSUME ONLY |
| ControlTowerState | Service | (indirect via SUPRACommandCenterState) | CONSUME ONLY |
| SUPRAResourceGovernor | Service | (indirect via SUPRACommandCenterState) | CONSUME ONLY |
| RuntimeGateway | Service | (indirect via SUPRACommandCenterState) | CONSUME ONLY |

---

## 5. Design System Dependencies

| SUPRAOSDesignSystem Token | Usage |
|---------------------------|-------|
| `spacing` (20pt) | Standard spacing in DashboardView |
| `spacingSmall` (12pt) | Grid spacing, card internal spacing |
| `spacingMini` (4pt) | Tight spacing in indicators bar |
| `padding` (24pt) | DashboardView outer padding |
| `paddingSmall` (16pt) | Card internal padding |
| `cardHeight` (200pt) | Default card height |
| `colors.supraAccent` | Dashboard header accent |
| `colors.supraBackground` | Dashboard background |
| `colors.supraSurface` | Card backgrounds |
| `colors.supraBorder` | Card borders |
| `colors.supraGreen` | Healthy indicators |
| `colors.supraOrange` | Warning indicators |
| `colors.supraRed` | Critical indicators |
| `colors.supraText` | Primary text |
| `colors.supraTextSecondary` | Secondary text |
| `Fonts.body` | Body text |
| `Fonts.bodySmall` | Small labels |
| `Fonts.section` | Section headers |
| `cornerRadiusSmall` (10pt) | Card corner radius |

---

## 6. Composition Validation Checklist

- [x] All existing views are reused as-is (no modifications)
- [x] DashboardView is a new file only (G1_DashboardView.swift)
- [x] No Foundation component is modified
- [x] All state comes from SUPRACommandCenterState
- [x] All layout uses SUPRAOSDesignSystem tokens
- [x] LazyVGrid pattern matches CommandCenterView pattern
- [x] Additive integration only (DashboardView added to CommandCenterView grid)
- [x] G2 HealthMonitorView is included in the grid
- [x] No hardcoded paths in any G1 file
