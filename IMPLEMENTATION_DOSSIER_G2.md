# Implementation Dossier: G2 — Automated Health Monitoring

**Dossier Date**: 2026-07-29
**Capability Priority**: #1 (highest value / lowest effort)
**Foundation Impact**: Zero — purely additive

---

## 1. Functional Scope

The HealthMonitor capability provides proactive health anomaly detection and user-facing alerting for the SUPRA Runtime.

### 1.1 What It Does

1. **Monitors** RuntimeHealth metrics continuously (connection state, sync duration, error count, agent availability)
2. **Detects** anomalies when metrics deviate from normal thresholds
3. **Generates** alerts with severity levels (info, warning, critical)
4. **Surfaces** alerts in the Command Center without requiring navigation
5. **Stores** alert history for auditability (last 50 alerts)
6. **Tracks** external integration availability

### 1.2 What It Does NOT Do

- Modify any constitutional component
- Change Runtime behavior or path resolution
- Introduce new abstractions or frameworks
- Bypass SUPRAEnvironmentResolver

---

## 2. Runtime Services Consumed

| Service | File | Interface Used | Purpose |
|---------|------|---------------|---------|
| `RuntimeHealth` | `SUPRA/RuntimeHealth.swift` | `RuntimeHealth` struct | Health metrics source |
| `RuntimeMonitor` | `SUPRA/RuntimeMonitor.swift` | `@Published health`, `@Published events` | Observation pipeline |
| `RuntimeConnectionState` | `SUPRA/RuntimeConnectionState.swift` | `RuntimeConnectionState` enum | Connection state values |
| `ControlTowerState` | `SUPRA/ControlTowerState.swift` | Tower status structures | Build/runtime status |
| `CommandCenterSystemHealth` | `SUPRA/SUPRACommandCenterState.swift` | System health properties | Dashboard integration |

---

## 3. New Interfaces Required

### 3.1 AlertModel (NEW — M1)

```swift
struct AlertModel: Identifiable, Equatable {
    let id: UUID
    let severity: AlertSeverity
    let title: String
    let message: String
    let timestamp: Date
    let category: AlertCategory
    let acknowledged: Bool
}

enum AlertSeverity: String, CaseIterable {
    case info = "Info"
    case warning = "Warning"
    case critical = "Critical"
}

enum AlertCategory: String, CaseIterable {
    case connection = "Connection"
    case artifact = "Artifact"
    case performance = "Performance"
    case integration = "Integration"
    case system = "System"
}
```

### 3.2 HealthAnomalyDetector (NEW — M2)

```swift
final class HealthAnomalyDetector: ObservableObject {
    @Published var anomalies: [AlertModel] = []
    
    func analyze(_ health: RuntimeHealth) -> [AlertModel]
    func checkConnectionState(_ state: RuntimeConnectionState) -> AlertModel?
    func checkSyncDuration(_ durationMs: Int) -> AlertModel?
    func checkErrorCount(_ errors: Int) -> AlertModel?
    func checkAgentAvailability(_ count: Int, _ total: Int) -> AlertModel?
}
```

### 3.3 AlertHistoryStore (NEW — M4)

```swift
final class AlertHistoryStore: ObservableObject {
    @Published var alerts: [AlertModel] = []
    private let maxAlerts = 50
    
    func add(_ alert: AlertModel)
    func acknowledge(_ alert: AlertModel)
    func recentAlerts(count: Int) -> [AlertModel]
}
```

### 3.4 HealthMonitorViewModel (NEW — M5)

```swift
@MainActor
final class HealthMonitorViewModel: ObservableObject {
    @Published var alerts: [AlertModel] = []
    @Published var connectionState: RuntimeConnectionState = .disconnected
    @Published var isMonitoring = false
    
    func startMonitoring(monitor: RuntimeMonitor)
    func stopMonitoring()
}
```

### 3.5 HealthMonitorView (NEW — M6)

```swift
struct HealthMonitorView: View {
    @StateObject private var viewModel = HealthMonitorViewModel()
    
    var body: some View {
        // Non-intrusive alert banner in CommandCenter
        // Alert history panel
        // Health trend indicator
    }
}
```

---

## 4. Required Artifacts

| Artifact | Source | Required |
|----------|--------|----------|
| CONTINUITY.md | projectRoot | ✓ (existing) |
| SUPRA_STATE.json | projectRoot | ✓ (existing) |
| RUNTIME_STATUS.json | projectRoot | ✓ (existing) |
| runtime_diagnostics.json | projectRoot | ✓ (existing) |
| BUILD_STATUS.md | projectRoot | ✓ (existing) |
| version.json | projectRoot | ✓ (existing) |

**No new artifacts required.** The capability consumes existing artifacts through existing interfaces.

---

## 5. Acceptance Criteria

| # | Criterion | Measurable |
|---|-----------|-----------|
| AC1 | Build succeeds | `xcodebuild` → BUILD SUCCEEDED |
| AC2 | Runtime launches | `open SUPRA.app` → exit code 0 |
| AC3 | Anomaly detection | Anomalies detected within 5 seconds of metric change |
| AC4 | Alert severity | info/warning/critical correctly assigned |
| AC5 | Non-intrusive UI | Alerts visible alongside existing UI without blocking |
| AC6 | Alert history | Last 50 alerts stored and queryable |
| AC7 | No constitutional changes | Runtime Constitution V1 unchanged |
| AC8 | No regressions | All existing capabilities functional |
| AC9 | Foundation integrity | Runtime Foundation V2 stable |

---

## 6. Implementation Effort Estimate

| Increment | Effort | Description |
|-----------|--------|-------------|
| M1: AlertModel | ~30 min | Data model definition |
| M2: HealthAnomalyDetector | ~1 hour | Anomaly detection logic |
| M3: AlertHistoryStore | ~30 min | Alert persistence |
| M4: HealthMonitorViewModel | ~1 hour | Monitoring orchestration |
| M5: HealthMonitorView | ~1.5 hours | UI integration |
| M6: Validation | ~30 min | Build + launch + regression |
| **Total** | **~5 hours** | End-to-end delivery |

---

## 7. Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|-----------|
| Alert fatigue | Medium | Low | Configurable thresholds, 3-violation confirmation |
| Performance overhead | Low | Medium | Background actor with throttling |
| False positives | Medium | Medium | 3 consecutive violations before alerting |
| Foundation drift | Low | High | Phase 1 protection rules enforced |

---

## 8. Implementation Status

| Increment | Status |
|-----------|--------|
| M1: AlertModel | **READY TO IMPLEMENT** |
| M2: HealthAnomalyDetector | **Ready after M1** |
| M3: AlertHistoryStore | **Ready after M2** |
| M4: HealthMonitorViewModel | **Ready after M3** |
| M5: HealthMonitorView | **Ready after M4** |
| M6: Validation | **Ready after M5** |

---

*Dossier published. Execute M1 now.*
