# G4 Gap Analysis

**Date**: 2026-07-29
**Phase**: 3 — Gap Analysis
**Status**: PLANNED

---

## 1. Existing Capabilities (Already Present)

| Element | Location | Status | Reuse Action |
|---------|----------|--------|-------------|
| `RuntimeGateway` | RuntimeGateway.swift | EXISTING | Consume — status, events, connection |
| `RuntimeMonitor` | RuntimeMonitor.swift | EXISTING | Consume — health, events |
| `RuntimeHealth` | RuntimeHealth.swift | EXISTING | Read — health data |
| `RuntimeConnectionState` | RuntimeConnectionState.swift | EXISTING | Read — connection state enum |
| `ProviderRuntime` | ProviderRuntime.swift | EXISTING | Consume — provider status, health |
| `SUPRAProviderRegistry` | SUPRAProviderRegistry.swift | EXISTING | Consume — provider metadata |
| `CAnnoNicoSnapshotStore` | CAnnoNicoSnapshotStore.swift | EXISTING | Consume — memory integration status |
| `SUPRACommandCenterState` | SUPRACommandCenterState.swift | EXISTING | Consume — central state |
| `DashboardCoordinator` | DashboardCoordinator.swift | EXISTING | Consume — data access layer |
| `G1DashboardView` | G1DashboardView.swift | EXISTING | Integrate — add G4 section |
| `SUPRAOSCard` | SUPRAOSDesignSystem.swift | EXISTING | Reuse — card container |
| `SUPRAOSDesignSystem` tokens | SUPRAOSDesignSystem.swift | EXISTING | Reference — all design tokens |

---

## 2. Reusable Patterns

| Pattern | Source | Application | Abstraction Needed? |
|---------|--------|-------------|---------------------|
| RuntimeView status display | RuntimeView.swift | Reference for connection status display | NO — replicate pattern |
| HealthView status display | HealthView.swift | Reference for health status display | NO — replicate pattern |
| RuntimeConnectionState icon/color | RuntimeConnectionState.swift | Connection state indicators | NO — use directly |
| @EnvironmentObject | Existing views | State injection | NO — reuse directly |
| SUPRAOSCard | SUPRAOSDesignSystem.swift | Card container | NO — reuse directly |
| Indicator pill pattern | G1DashboardView.swift | Status indicators | NO — replicate directly |

---

## 3. Requires Extension

| Element | Current State | Required Extension | Reason |
|---------|--------------|-------------------|--------|
| GatewayStatusCard | No gateway status card exists | New card displaying RuntimeGateway status | Consolidated gateway view |
| RuntimeHealthCard | RuntimeView exists but is generic | New card focused on health metrics | Dedicated health view |
| ProviderStatusCard | No provider status card exists | New card displaying provider list and health | Provider overview |
| MemoryIntegrationCard | MemoryView exists but focuses on CAnnoNico | New card for integration source status | Integration source overview |
| EventStreamCard | No event stream card exists | New card displaying recent events | Event monitoring |
| ConnectionMatrixCard | No matrix view exists | New card aggregating all connection states | At-a-glance status |

---

## 4. New Implementation

| Element | Purpose | Size Estimate | Dependency |
|---------|---------|---------------|------------|
| `G4Models.swift` | Integration status data models | ~80 lines | None |
| `G4DashboardView.swift` | Main integration dashboard view | ~150 lines | G4Models, all services |
| Integration into `G1DashboardView.swift` | Add G4DashboardView to grid | ~5 lines | G4DashboardView |

---

## 5. Gap Summary

| Category | Count | Details |
|----------|-------|---------|
| Existing (reuse) | 12 | Services, views, state, design tokens |
| Reusable patterns | 6 | Status display, card container, indicator pill |
| Requires extension | 6 | New cards for each integration section |
| New implementation | 3 | G4Models, G4DashboardView, integration |
| New abstractions | 0 | No new frameworks, protocols, or services |
| Foundation modifications | 0 | No Runtime component changes |

---

## 6. Key Finding

The gap is entirely within **UI composition**. All integration data is already available through existing services. The only new elements are:

1. A `G4Models` file for integration status data structures
2. A `G4DashboardView` composing status cards for each integration
3. Integration wiring to add G4DashboardView to G1DashboardView

No new architectures, abstractions, protocols, services, or Foundation modifications are required.
