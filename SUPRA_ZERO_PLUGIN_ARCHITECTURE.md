# SUPRA ZERO — Plugin Architecture

## Design Principles

1. **No implementation during SUPRA ZERO** — only interfaces, responsibilities, and contracts
2. **OpenCode-compatible** — plugins must load via standard OpenCode mechanisms
3. **Reversible** — all plugin definitions must allow rollback
4. **Loose coupling** — plugins communicate via contracts, not direct calls
5. **Versioned** — each plugin has a defined API version

## Plugin Architecture Overview

```
Runtime (OpenCode host)
  │
  ├── TheoryPlugin        ← Knowledge retrieval, ontology queries
  ├── SherpaPlugin        ← Context selection, routing recommendations
  ├── CortexPlugin        ← Persistent memory, decision storage
  ├── ProofPlugin         ← Evidence gathering, verification
  ├── WorkspacePlugin     ← Workspace indexing, discovery
  ├── RuntimePlugin       ← Runtime monitoring, diagnostics
  └── ProviderPlugin      ← AI provider integration, model access
```

## Plugin Interfaces

### TheoryPlugin
```swift
protocol TheoryPlugin {
    var id: String { get }
    var version: String { get }
    func query(concept: String) async throws -> TheoryResult
    func search(query: String, domain: TheoryDomain) async throws -> [TheoryResult]
    func relations(of concept: String) async throws -> [TheoryRelation]
}
```

**Responsibilities**: Retrieve theories, concepts, principles. Search ontology. Navigate theory graph.

### SherpaPlugin
```swift
protocol SherpaPlugin {
    var id: String { get }
    var version: String { get }
    func selectContext(for mission: Mission) async throws -> ContextSelection
    func recommendProviders(for task: Task) async throws -> [ProviderRecommendation]
    func route(request: ExecutionRequest) async throws -> RoutingDecision
}
```

**Responsibilities**: Select relevant context for missions. Recommend optimal providers. Route execution requests.

### CortexPlugin
```swift
protocol CortexPlugin {
    var id: String { get }
    var version: String { get }
    func store(decision: Decision) async throws
    func retrieve(context: QueryContext) async throws -> [Decision]
    func learn(from outcome: ExecutionOutcome) async throws
    func getMemory(namespace: MemoryNamespace) async throws -> MemoryState
}
```

**Responsibilities**: Persistent decision storage. Experience learning. Memory retrieval.

### ProofPlugin
```swift
protocol ProofPlugin {
    var id: String { get }
    var version: String { get }
    func gather(evidence: EvidenceRequest) async throws -> EvidenceSet
    func verify(claim: Claim) async throws -> VerificationResult
    func link(evidence: Evidence, to artifact: Artifact) async throws
}
```

**Responsibilities**: Evidence collection. Claim verification. Evidence-artifact linking.

### WorkspacePlugin
```swift
protocol WorkspacePlugin {
    var id: String { get }
    var version: String { get }
    func index(paths: [String]) async throws -> WorkspaceIndex
    func discover() async throws -> WorkspaceDiscovery
    func query(resource: ResourceQuery) async throws -> [Resource]
}
```

**Responsibilities**: Workspace scanning. Resource discovery. File indexing.

### RuntimePlugin
```swift
protocol RuntimePlugin {
    var id: String { get }
    var version: String { get }
    func getHealth() async throws -> HealthStatus
    func getMetrics() async throws -> RuntimeMetrics
    func diagnose(issue: DiagnosticRequest) async throws -> DiagnosticReport
}
```

**Responsibilities**: Runtime health monitoring. Metrics collection. Issue diagnostics.

### ProviderPlugin
```swift
protocol ProviderPlugin {
    var id: String { get }
    var version: String { get }
    var capabilities: [Capability] { get }
    func execute(request: ProviderRequest) async throws -> ProviderResponse
    func health() async throws -> ProviderHealth
    func models() async throws -> [ModelInfo]
}
```

**Responsibilities**: AI model execution. Provider health. Model discovery.

## Plugin Lifecycle

```
REGISTERED → LOADED → CONFIGURED → ACTIVE → DISABLED → UNLOADED
                                              ↓
                                         ERROR → RETRY
```

1. **REGISTERED**: Plugin declared in registry (manifest)
2. **LOADED**: Plugin binary loaded by runtime
3. **CONFIGURED**: Plugin received its configuration
4. **ACTIVE**: Plugin ready for requests
5. **DISABLED**: Plugin disabled (config, error, or manual)
6. **UNLOADED**: Plugin removed from runtime

## Plugin Contract

Each plugin must provide:
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
    let configSchema: String?  // JSON schema URL or inline
}
```

## OpenCode Compatibility

Plugins will be loaded via:
- **Project-level**: `.opencode/plugins/` directory (per-workspace)
- **Global-level**: `~/.opencode/plugins/` (machine-wide)
- **Registry**: Plugin manifest in `SUPRA_PLUGIN_REGISTRY.json`

## Extension Points

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

## Implementation Plan (Post SUPRA ZERO)

1. **Phase 1**: Define all plugin interfaces in Swift (protocols only)
2. **Phase 2**: Implement PluginRegistry and PluginLoader
3. **Phase 3**: Convert existing modules to plugin format
4. **Phase 4**: Add dynamic loading (external plugins)
5. **Phase 5**: Plugin marketplace (optional)
