# G3 Architecture Discovery Report

**Date**: 2026-07-29
**Phase**: 1 — Architecture Discovery
**Status**: COMPLETE
**Purpose**: Complete understanding of existing export/reporting infrastructure before implementation.

---

## 1. Existing Export Infrastructure

### Finding: No existing export service
There is no dedicated export service, ExportModel, ExportView, or export utility in the SUPRA codebase.

### Existing file save patterns
| Pattern | Location | Purpose |
|---------|----------|---------|
| `NSOpenPanel` | ProtectedFolderAccessCoordinator.swift | Folder authorization for discovery |
| `NSOpenPanel` | SettingsView.swift | Settings file selection |
| `FileManager.createFile` | ContentView.swift | Log file creation |
| `Data(contentsOf:)` | ArtifactReader.swift, ContentView.swift | Reading existing files |
| `JSONDecoder.decode` | ContentView.swift | Reading JSON manifests |
| `SHA256.hash` | ContentView.swift | Content hashing for integrity |

### Existing data serialization
| Pattern | Location | Purpose |
|---------|----------|---------|
| `Codable` conformance | ExecutiveMissionControlModels.swift | Executive agent/build/freeze status |
| `JSONEncoder/JSONDecoder` | ContentView.swift | Reading JSON files |
| `String(contentsOf:encoding:)` | ArtifactReader.swift, ContentView.swift | Reading text files |

---

## 2. Data Models Available for Export

### CommandCenterSnapshot (SUPRACommandCenterState.swift)
- `health: CommandCenterSystemHealth` — system health status
- `missions: CommandCenterMissions` — mission counts and recent missions
- `resources: CommandCenterResources` — CPU, RAM, disk, scheduler
- `cannonico: CommandCenterCannonico` — memory sources and references
- `runtime: CommandCenterRuntime` — connection, agents, sync, gateway
- `multiMemory: CommandCenterMultiMemory` — multi-source memory
- `intelligence: CommandCenterIntelligence` — health score, anomalies, insights
- `decision: CommandCenterDecision` — mission decisions and verdicts
- `copilot: CommandCenterCopilot` — proposals and execution
- `actions: CommandCenterActions` — warnings and next actions
- `lastUpdated: Date` — snapshot timestamp

### CommandCenterSystemHealth
- `overall: String`, `build: String`, `runtime: String`, `git: String`
- `agents: String`, `storage: String`
- `capabilities: Int`, `activeProjects: Int`, `swiftFiles: Int`, `gitRepos: Int`

### CommandCenterMissions
- `total: Int`, `active: Int`, `blocked: Int`, `completed: Int`
- `recentMissions: [Mission]`

### CommandCenterResources
- `cpuUsage: Double`, `ramFraction: Double`, `activeProcessCount: Int`
- `freeDiskGB: Double`, `isHighLoad: Bool`, `isCritical: Bool`
- `schedulerActiveTasks: Int`, `schedulerPending: Int`, `schedulerPaused: Bool`

### CommandCenterRuntime
- `isConnected: Bool`, `agentCount: Int`, `activeMissions: Int`
- `lastSync: String`, `connectionState: RuntimeConnectionState`
- `events: [RuntimeEvent]`, `gatewayConnected: Bool`
- `gatewayActiveMissions: Int`, `gatewayActiveWorkers: Int`

### CommandCenterIntelligence
- `healthScore: Double`, `anomalyCount: Int`
- `nextBestAction: String?`, `insightCount: Int`

---

## 3. Reusable Components

### Existing views (reusable for export UI)
| View | File | Reuse for G3 |
|------|------|-------------|
| `SUPRAOSCard` | SUPRAOSDesignSystem.swift | Card container for export options |
| `SUPRAOSStatCard` | SUPRAOSDesignSystem.swift | Export status display |
| `DashboardCoordinator` | DashboardCoordinator.swift | Data access layer for export |
| `SUPRACommandCenterState` | SUPRACommandCenterState.swift | Central state for export data |
| `G1DashboardView` | G1DashboardView.swift | Integration point for export button |

### Existing patterns (reusable for export implementation)
| Pattern | Source | Application |
|---------|--------|-------------|
| `NSSavePanel` | ProtectedFolderAccessCoordinator.swift | File save dialog |
| `FileManager.createFile` | ContentView.swift | File creation |
| `JSONEncoder` | ContentView.swift | JSON serialization |
| `String(contentsOf:encoding:)` | ArtifactReader.swift | Text file writing |
| `@EnvironmentObject` | Existing views | State injection |
| `@StateObject` | ContentView.swift | Local state management |
| `.onAppear` | Existing views | Export trigger |

### Existing Runtime services (consumed only)
| Service | Access | Role for G3 |
|---------|--------|-------------|
| `SUPRACommandCenterState.shared` | `@EnvironmentObject` | Data source for export |
| `SUPRAEnvironmentResolver.shared` | Direct access | File path resolution |
| `DashboardCoordinator` | `@StateObject` | Data access layer |

---

## 4. Key Findings

1. **No existing export service** — G3 is a greenfield capability within the export domain
2. **Data models are NOT Codable** — CommandCenterSnapshot and sub-models lack Codable conformance; export will need to manually extract values
3. **NSSavePanel is the established pattern** — ProtectedFolderAccessCoordinator and SettingsView both use NSOpenPanel/NSSavePanel for file operations
4. **FileManager is the established pattern** — ContentView uses FileManager.createFile for file creation
5. **JSONEncoder is available** — ContentView uses JSONDecoder for reading; JSONEncoder can be used for writing
6. **DashboardCoordinator provides data access** — The coordinator already exposes all data sections needed for export
7. **No PDF generation infrastructure** — PDF export will require additional work (AppKit PDF APIs or similar)

---

## 5. Architecture Risk Assessment

| Risk | Level | Mitigation |
|------|-------|-----------|
| No existing export service | LOW | Greenfield implementation, no legacy constraints |
| Data models not Codable | LOW | Manual value extraction from existing structs |
| NSSavePanel requires AppKit | LOW | Already used in codebase (ProtectedFolderAccessCoordinator) |
| No PDF generation | MEDIUM | Use AppKit NSPrintOperation or PDFKit for basic PDF |
| File format compatibility | LOW | Use standard formats (CSV, JSON, Markdown) |
| Constitutional impact | NONE | No Foundation modifications |

**Overall risk**: LOW
