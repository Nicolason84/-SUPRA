# G4 Architecture Discovery Report

**Date**: 2026-07-29
**Phase**: 1 — Architecture Discovery
**Status**: COMPLETE

---

## 1. Existing Integration Infrastructure

### RuntimeGateway (RuntimeGateway.swift)
- `@MainActor`, `ObservableObject`, singleton
- `@Published var status: RuntimeStatus?` — connection status
- `@Published var events: [RuntimeGatewayEvent]` — event stream
- `@Published var isConnected: Bool` — connection state
- `RuntimeStatus` — isRunning, activeMissions, activeWorkers, availableProviders, uptime, version
- `RuntimeGatewayEvent` — missionStarted, missionUpdated, workerCreated, workerFinished, contextReady, decisionGenerated, knowledgeUpdated, workspaceChanged, buildFinished, gitUpdated, error
- `func connect()` / `func disconnect()` — connection management
- `func execute(_ request: BridgeRequest) async -> BridgeResponse` — command execution

### RuntimeMonitor (RuntimeMonitor.swift)
- `@MainActor`, `ObservableObject`
- `@Published var health: RuntimeHealth` — health state
- `@Published var events: [RuntimeEvent]` — event history
- Delegates to `OpenCodeClient` for data sourcing
- `func start()` / `func stop()` — lifecycle management

### RuntimeHealth (RuntimeHealth.swift)
- `isConnected: Bool`, `agentCount: Int`, `activeProviderCount: Int`, `totalProviderCount: Int`
- `activeMissionCount: Int`, `lastSyncDate: Date?`, `lastSyncDurationMs: Int`
- `fileCount: Int`, `errorsSinceLastSync: Int`, `connectionState: RuntimeConnectionState`
- `lastSyncFormatted: String`, `statusIcon: String`, `statusColor: String`

### RuntimeConnectionState (RuntimeConnectionState.swift)
- Cases: disconnected, connecting, connected, degraded, offline
- Each case has `icon` and `color` properties

### ProviderRuntime (ProviderRuntime.swift)
- `@MainActor`, `ObservableObject`, singleton
- `@Published var providers: [SUPRAProviderType: SUPRAProvider]` — registered providers
- `@Published var activeProviderType: SUPRAProviderType` — current active provider
- `@Published var isInitialized: Bool`, `lastError: String?`, `isExecuting: Bool`
- Health caching, capability caching, metrics caching

### SUPRAProviderRegistry (SUPRAProviderRegistry.swift)
- `@MainActor`, `ObservableObject`, singleton
- `@Published var providers: [SUPRAProviderType: SUPRAProvider]` — registered providers
- `@Published var activeProviderType: SUPRAProviderType` — current active provider
- `@Published var powerMetadata: [SUPRAProviderType: SUPRAProviderPowerMetadata]` — provider metadata
- `SUPRAProviderPowerMetadata` — powerClass, contextCapacity, toolCapability, localOrRemote, paidOrFree, health, currentLoad

### CAnnoNicoIntegrationBridge (CAnnoNicoIntegrationBridge.swift)
- `enum SUPRACAnnoNicoIntegration` — static integration bridge
- `pucheroSource`, `nicoAppSource`, `videoSwapSource` — source paths
- `func snapshot() -> CAnnoNicoIntegrationSnapshot` — snapshot generation
- Consumes `SUPRAEnvironmentResolver` for path resolution

### OpenCodeClient (OpenCodeClient.swift)
- `@MainActor`, `ObservableObject`, singleton
- `@Published var events: [RuntimeEvent]`, `health: RuntimeHealth`, `connectionState: RuntimeConnectionState`
- JSON source and OpenCode source modes
- Delegates to `RuntimeDataService` for data

---

## 2. Reusable Components

### Existing views (reusable for integration dashboard)
| View | File | Reuse for G4 |
|------|------|-------------|
| `SUPRAOSCard` | SUPRAOSDesignSystem.swift | Card container for integration status |
| `RuntimeView` | RuntimeView.swift | Reference for status display pattern |
| `HealthView` | HealthView.swift | Reference for status display pattern |
| `DashboardCoordinator` | DashboardCoordinator.swift | Data access layer |

### Existing patterns (reusable for integration implementation)
| Pattern | Source | Application |
|---------|--------|-------------|
| `@Published var status` | RuntimeGateway | Integration status display |
| `@Published var isConnected` | RuntimeGateway | Connection state indicator |
| `RuntimeConnectionState` | RuntimeConnectionState.swift | State machine for connection status |
| `RuntimeHealth` | RuntimeHealth.swift | Health data structure |
| `@EnvironmentObject` | Existing views | State injection |
| `SUPRAOSCard` | SUPRAOSDesignSystem.swift | Card container |

### Existing Runtime services (consumed only)
| Service | Access | Role for G4 |
|---------|--------|-------------|
| `RuntimeGateway.shared` | Direct access | Gateway connection status |
| `RuntimeMonitor` | Via SUPRACommandCenterState | Runtime health and events |
| `ProviderRuntime.shared` | Direct access | Provider status and health |
| `SUPRAProviderRegistry.shared` | Direct access | Provider metadata |
| `CAnnoNicoIntegrationBridge` | Via CAnnoNicoSnapshotStore | Memory integration status |
| `SUPRACommandCenterState.shared` | `@EnvironmentObject` | Central state |
| `SUPRAEnvironmentResolver.shared` | Direct access | Path resolution |

---

## 3. Key Findings

1. **Rich integration infrastructure exists** — RuntimeGateway, RuntimeMonitor, ProviderRuntime, SUPRAProviderRegistry, CAnnoNicoIntegrationBridge, OpenCodeClient
2. **Status data is already available** — RuntimeHealth, RuntimeStatus, RuntimeConnectionState, provider health, connection state
3. **No unified integration dashboard exists** — Each integration is displayed separately; no consolidated view
4. **Reusable status display patterns** — RuntimeView and HealthView demonstrate how to display connection and health status
5. **All data is ObservableObject** — All services use `@Published` properties, enabling reactive UI updates
6. **No Foundation modifications needed** — All integrations are consumed through existing services

---

## 4. Architecture Risk Assessment

| Risk | Level | Mitigation |
|------|-------|-----------|
| Many integration services to compose | LOW | Use existing data access patterns |
| External service availability | LOW | Display status only, no control |
| Provider health checks | LOW | Use existing ProviderRuntime health caching |
| Constitutional impact | NONE | No Foundation modifications |

**Overall risk**: LOW
