# G4 Composition Plan

**Date**: 2026-07-29
**Phase**: 2 — Composition Plan
**Status**: PLANNED

---

## 1. Integration Sections

| Section | Existing Reusable Component | New Component Required | Runtime Dependency | State Dependency |
|---------|----------------------------|----------------------|-------------------|-----------------|
| **Gateway Status** | `RuntimeGateway` | `GatewayStatusCard` (new — connection, version, uptime, active missions) | RuntimeGateway.shared | `status`, `isConnected` |
| **Runtime Health** | `RuntimeHealth`, `RuntimeMonitor` | `RuntimeHealthCard` (new — connection state, sync, errors, agents) | RuntimeMonitor | `health` |
| **Provider Status** | `ProviderRuntime`, `SUPRAProviderRegistry` | `ProviderStatusCard` (new — provider list, health, active provider) | ProviderRuntime.shared, SUPRAProviderRegistry.shared | `providers`, `activeProviderType` |
| **Memory Integration** | `CAnnoNicoIntegrationBridge`, `CAnnoNicoSnapshotStore` | `MemoryIntegrationCard` (new — source status, reference count) | CAnnoNicoSnapshotStore.shared | `snapshot` |
| **Event Stream** | `RuntimeGatewayEvent`, `RuntimeEvent` | `EventStreamCard` (new — recent events, event count) | RuntimeGateway.shared | `events` |
| **Connection Matrix** | `RuntimeConnectionState` | `ConnectionMatrixCard` (new — all connection states in one view) | Multiple services | Aggregated |

---

## 2. Composition Rules

### Rule 1: Compose, Do Not Replace
Every existing view and service is reused exactly as-is. No modifications to existing files except additive integration.

### Rule 2: Additive Integration Only
G4 adds new files and one integration line to G1DashboardView. No existing view is modified.

### Rule 3: Single Writer
Only SUPRA-Builder writes files. All other phases are READ-ONLY.

### Rule 4: Foundation Immutable
No Foundation component is modified.

### Rule 5: Design System Compliance
All spacing, padding, colors, fonts reference SUPRAOSDesignSystem.*. No hardcoded values.

### Rule 6: Data Access Pattern
All cards consume existing singleton services directly. No new state objects.

---

## 3. Component Hierarchy

```
G4DashboardView (NEW)
 ├── GatewayStatusCard (NEW)
 │   ├── Connection state (isConnected)
 │   ├── Version (RuntimeStatus.version)
 │   ├── Uptime (RuntimeStatus.uptime)
 │   └── Active missions/workers
 ├── RuntimeHealthCard (NEW)
 │   ├── Connection state (RuntimeConnectionState)
 │   ├── Sync status (lastSyncFormatted)
 │   ├── Error count (errorsSinceLastSync)
 │   └── Agent/provider count
 ├── ProviderStatusCard (NEW)
 │   ├── Provider list (ProviderRuntime.providers)
 │   ├── Active provider (ProviderRuntime.activeProviderType)
 │   ├── Health per provider
 │   └── Power metadata
 ├── MemoryIntegrationCard (NEW)
 │   ├── Source status (Puchero, NicoApp, VideoSwap)
 │   ├── Reference count
 │   └── Last sync
 ├── EventStreamCard (NEW)
 │   ├── Recent events (RuntimeGateway.events)
 │   ├── Event count
 │   └── Event type breakdown
 └── ConnectionMatrixCard (NEW)
     ├── Gateway: connected/disconnected
     ├── Runtime: connected/disconnected
     ├── Providers: healthy/unhealthy
     └── Memory: resolved/unresolved
```

---

## 4. Runtime Dependencies

| Dependency | Type | Consumed By | Modification |
|-----------|------|-------------|-------------|
| RuntimeGateway.shared | Service | GatewayStatusCard, EventStreamCard | CONSUME ONLY |
| RuntimeMonitor | Service | RuntimeHealthCard | CONSUME ONLY |
| ProviderRuntime.shared | Service | ProviderStatusCard | CONSUME ONLY |
| SUPRAProviderRegistry.shared | Service | ProviderStatusCard | CONSUME ONLY |
| CAnnoNicoSnapshotStore.shared | Service | MemoryIntegrationCard | CONSUME ONLY |
| SUPRACommandCenterState.shared | State | G4DashboardView | CONSUME ONLY |
| SUPRAEnvironmentResolver.shared | Service | All cards (path resolution) | CONSUME ONLY |

---

## 5. Design System Dependencies

| Token | Usage |
|-------|-------|
| `SUPRAOSDesignSystem.spacing` | Standard spacing |
| `SUPRAOSDesignSystem.spacingSmall` | Grid spacing |
| `SUPRAOSDesignSystem.padding` | Outer padding |
| `SUPRAOSDesignSystem.paddingSmall` | Card padding |
| `SUPRAOSDesignSystem.cornerRadiusSmall` | Card corners |
| `SUPRAOSDesignSystem.colors.supraGreen` | Connected/healthy |
| `SUPRAOSDesignSystem.colors.supraRed` | Disconnected/error |
| `SUPRAOSDesignSystem.colors.supraOrange` | Degraded/warning |
| `SUPRAOSDesignSystem.colors.supraBlue` | Info/active |
| `SUPRAOSDesignSystem.colors.supraPurple` | Memory integration |
| `SUPRAOSDesignSystem.Fonts.body` | Body text |
| `SUPRAOSDesignSystem.Fonts.bodySmall` | Labels |

---

## 6. Composition Validation Checklist

- [x] All existing services reused as-is
- [x] G4 adds new files only
- [x] No Foundation component modified
- [x] All data access via existing singletons
- [x] All layout uses SUPRAOSDesignSystem tokens
- [x] Additive integration only (G4DashboardView in G1DashboardView)
- [x] No hardcoded paths in any G4 file
