# SUPRA Plugin SDK — Specification

## Spécification du SDK de Plugins SUPRA

| Propriété | Valeur |
|-----------|--------|
| **Statut** | SPÉCIFICATION — Aucune implémentation |
| **Version** | SUPRA_FOUNDATION_V1 |
| **Date** | 2026-07-29 |
| **Principe** | Définir avant de développer. Compatible OpenCode. |

---

## 1. Design Principles

1. **No implementation** — this document is a specification only
2. **OpenCode-compatible** — plugins must load via standard OpenCode mechanisms
3. **Reversible** — all plugin definitions must allow rollback
4. **Loose coupling** — plugins communicate via contracts, not direct calls
5. **Versioned** — each plugin has a defined API version
6. **Secure** — plugins run in scoped permission sandboxes

---

## 2. Plugin API

### 2.1 Core Protocol

```swift
protocol SUPRAPlugin: AnyObject {
    var id: String { get }
    var name: String { get }
    var version: String { get }
    var apiVersion: String { get }
    var type: PluginType { get }
    var capabilities: [Capability] { get }
    var permissions: [Permission] { get }
    
    func initialize(config: PluginConfig) async throws
    func activate() async throws
    func deactivate() async throws
    func shutdown() async throws
    func health() async throws -> PluginHealth
}

enum PluginType: String, Codable {
    case theory
    case sherpa
    case cortex
    case proof
    case workspace
    case runtime
    case provider
}

struct Capability: Codable {
    let name: String
    let version: String
    let description: String
}

struct Permission: Codable {
    let resource: String
    let access: PermissionAccess
}

enum PermissionAccess: String, Codable {
    case read
    case write
    case execute
}

struct PluginConfig: Codable {
    let settings: [String: String]
    let timeout: Int
    let retryPolicy: RetryPolicy
}

struct PluginHealth: Codable {
    let status: HealthStatus
    let message: String
    let lastCheck: Date
    let metrics: [String: Double]
}

enum HealthStatus: String, Codable {
    case healthy
    case degraded
    case unhealthy
    case unknown
}
```

### 2.2 Plugin Manifest

```swift
struct PluginManifest: Codable {
    let id: String
    let name: String
    let version: String
    let pluginType: PluginType
    let apiVersion: String
    let capabilities: [String]
    let dependencies: [String]
    let permissions: [String]
    let configSchema: String?
    let author: String?
    let description: String?
    let homepage: String?
    let license: String?
}
```

---

## 3. Plugin Types

### 3.1 TheoryPlugin

```swift
protocol TheoryPlugin: SUPRAPlugin {
    func query(concept: String) async throws -> TheoryResult
    func search(query: String, domain: TheoryDomain) async throws -> [TheoryResult]
    func relations(of concept: String) async throws -> [TheoryRelation]
}
```

**Responsibilities**: Retrieve theories, concepts, principles. Search ontology. Navigate theory graph.

### 3.2 SherpaPlugin

```swift
protocol SherpaPlugin: SUPRAPlugin {
    func selectContext(for mission: Mission) async throws -> ContextSelection
    func recommendProviders(for task: Task) async throws -> [ProviderRecommendation]
    func route(request: ExecutionRequest) async throws -> RoutingDecision
}
```

**Responsibilities**: Select relevant context for missions. Recommend optimal providers. Route execution requests.

### 3.3 CortexPlugin

```swift
protocol CortexPlugin: SUPRAPlugin {
    func store(decision: Decision) async throws
    func retrieve(context: QueryContext) async throws -> [Decision]
    func learn(from outcome: ExecutionOutcome) async throws
    func getMemory(namespace: MemoryNamespace) async throws -> MemoryState
}
```

**Responsibilities**: Persistent decision storage. Experience learning. Memory retrieval.

### 3.4 ProofPlugin

```swift
protocol ProofPlugin: SUPRAPlugin {
    func gather(evidence: EvidenceRequest) async throws -> EvidenceSet
    func verify(claim: Claim) async throws -> VerificationResult
    func link(evidence: Evidence, to artifact: Artifact) async throws
}
```

**Responsibilities**: Evidence collection. Claim verification. Evidence-artifact linking.

### 3.5 WorkspacePlugin

```swift
protocol WorkspacePlugin: SUPRAPlugin {
    func index(paths: [String]) async throws -> WorkspaceIndex
    func discover() async throws -> WorkspaceDiscovery
    func query(resource: ResourceQuery) async throws -> [Resource]
}
```

**Responsibilities**: Workspace scanning. Resource discovery. File indexing.

### 3.6 RuntimePlugin

```swift
protocol RuntimePlugin: SUPRAPlugin {
    func getHealth() async throws -> HealthStatus
    func getMetrics() async throws -> RuntimeMetrics
    func diagnose(issue: DiagnosticRequest) async throws -> DiagnosticReport
}
```

**Responsibilities**: Runtime health monitoring. Metrics collection. Issue diagnostics.

### 3.7 ProviderPlugin

```swift
protocol ProviderPlugin: SUPRAPlugin {
    var capabilities: [Capability] { get }
    func execute(request: ProviderRequest) async throws -> ProviderResponse
    func health() async throws -> ProviderHealth
    func models() async throws -> [ModelInfo]
}
```

**Responsibilities**: AI model execution. Provider health. Model discovery.

---

## 4. Plugin Lifecycle

```
REGISTERED → LOADED → CONFIGURED → ACTIVE → DISABLED → UNLOADED
                                               ↓
                                          ERROR → RETRY
```

| State | Description |
|-------|-------------|
| **REGISTERED** | Plugin declared in registry (manifest registered) |
| **LOADED** | Plugin binary loaded by runtime |
| **CONFIGURED** | Plugin received its configuration |
| **ACTIVE** | Plugin ready for requests |
| **DISABLED** | Plugin disabled (config, error, or manual) |
| **UNLOADED** | Plugin removed from runtime |

### Lifecycle Events

| Event | Trigger | Handler |
|-------|---------|---------|
| `onRegistered` | Manifest added to registry | Registry update |
| `onLoaded` | Binary loaded | Resource allocation |
| `onConfigured` | Config applied | `initialize(config:)` |
| `onActivated` | Plugin ready | `activate()` |
| `onDeactivated` | Plugin stopped | `deactivate()` |
| `onUnloaded` | Plugin removed | `shutdown()` + cleanup |
| `onError` | Error occurred | Retry or disable |
| `onHealthCheck` | Periodic health | `health()` |

---

## 5. Plugin Registry

```swift
protocol PluginRegistry {
    func register(manifest: PluginManifest) async throws
    func unregister(pluginId: String) async throws
    func get(pluginId: String) async throws -> PluginManifest
    func list(type: PluginType?) async throws -> [PluginManifest]
    func find(capability: String) async throws -> [PluginManifest]
    func health(pluginId: String) async throws -> PluginHealth
}
```

### Registry Storage

- **Project-level**: `.opencode/plugins/registry.json`
- **Global-level**: `~/.opencode/plugins/registry.json`
- **Runtime**: In-memory cache with periodic persistence

---

## 6. Plugin Discovery

### Discovery Mechanisms

| Mechanism | Scope | Method |
|-----------|-------|--------|
| Local directory scan | Project | `.opencode/plugins/*/manifest.json` |
| Global directory scan | Machine | `~/.opencode/plugins/*/manifest.json` |
| Registry lookup | Runtime | `PluginRegistry.find(capability:)` |
| Dynamic discovery | Network | Optional, Phase 2+ |

### Directory Structure

```
.opencode/plugins/
├── registry.json              ← Master plugin registry
├── plugins/
│   ├── my-theory-plugin/
│   │   ├── manifest.json      ← PluginManifest
│   │   └── Plugin.swift       ← Plugin implementation
│   └── my-provider-plugin/
│       ├── manifest.json
│       └── Plugin.swift
```

---

## 7. Plugin Security

### Principles

1. **Least privilege** — plugins request only needed permissions
2. **Sandboxed execution** — plugins cannot access outside their scope
3. **Capability verification** — runtime verifies declared vs actual capabilities
4. **Audit logging** — all plugin actions are logged
5. **Resource limits** — CPU, memory, and time limits per plugin

### Permission Scopes

| Scope | Resources |
|-------|-----------|
| `theory.read` | Read theory graph, concepts |
| `theory.write` | Modify theory graph |
| `memory.read` | Read decision memory |
| `memory.write` | Write decision memory |
| `workspace.read` | Read workspace index |
| `workspace.write` | Modify workspace |
| `runtime.metrics` | Read runtime metrics |
| `provider.execute` | Execute AI provider calls |
| `network` | Network access |
| `filesystem.read` | Read filesystem |
| `filesystem.write` | Write filesystem |

---

## 8. Plugin Validation

### Validation Stages

| Stage | Checks | Timing |
|-------|--------|--------|
| **Manifest validation** | Schema conformance, required fields | On registration |
| **Capability validation** | Declared vs actual capabilities | On load |
| **Security validation** | Permission scope, sandbox rules | On configure |
| **Health validation** | Plugin responds to health check | Periodic |
| **Runtime validation** | No crashes, resource limits respected | Continuous |

### Manifest Schema

```json
{
  "$schema": "https://supra.opencode.ai/plugin-manifest.schema.json",
  "type": "object",
  "required": ["id", "name", "version", "pluginType", "apiVersion", "capabilities"],
  "properties": {
    "id": { "type": "string", "pattern": "^[a-z0-9-]+$" },
    "name": { "type": "string" },
    "version": { "type": "string", "pattern": "^\\d+\\.\\d+\\.\\d+$" },
    "pluginType": { "enum": ["theory", "sherpa", "cortex", "proof", "workspace", "runtime", "provider"] },
    "apiVersion": { "type": "string", "pattern": "^\\d+\\.\\d+$" },
    "capabilities": { "type": "array", "items": { "type": "string" } },
    "dependencies": { "type": "array", "items": { "type": "string" } },
    "permissions": { "type": "array", "items": { "type": "string" } },
    "configSchema": { "type": "string" }
  }
}
```

---

## 9. Extension Points

| Extension Point | Consumed By | Purpose |
|----------------|-------------|---------|
| `theory.query` | Runtime | Before architectural decisions |
| `sherpa.route` | Runtime | Mission execution routing |
| `cortex.store` | Runtime | After decisions are made |
| `cortex.retrieve` | Sherpa | Context building |
| `proof.verify` | Governance | Before release |
| `workspace.index` | Runtime | On file change |
| `runtime.metrics` | Dashboard | UI display |
| `provider.execute` | Runtime | LLM calls |

---

## 10. OpenCode Compatibility

| OpenCode Feature | SUPRA Plugin Equivalent |
|-----------------|------------------------|
| `.opencode/plugins/` | Plugin directory (project) |
| `~/.opencode/plugins/` | Plugin directory (global) |
| `opencode.json skills.paths` | Plugin discovery paths |
| Plugin hooks | Lifecycle events |
| Agent permissions | Plugin permissions |

---

## 11. Implementation Roadmap (Post-Foundation)

| Phase | Deliverable | Effort |
|-------|-------------|--------|
| **Phase 1** | Implement plugin protocols in Swift (7 protocols) | 1 session |
| **Phase 2** | Implement PluginRegistry + PluginLoader | 1 session |
| **Phase 3** | Convert existing modules to plugin format | 1-2 sessions |
| **Phase 4** | Add dynamic loading (external plugins) | 1 session |
| **Phase 5** | Plugin marketplace (optional) | 2 sessions |

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA FOUNDATION V1. Aucune implémentation — spécification uniquement.*
