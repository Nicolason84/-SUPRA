# CANONICO Graph Runtime

## Status: SPECIFICATION V1

---

## 1. RUNTIME OVERVIEW

The Graph Runtime is the execution environment that orchestrates all Graph Kernel engines, manages the event log, and provides the unified query interface.

The Runtime is **engine-agnostic** — it only defines interfaces and protocols. Engines are pluggable implementations.

---

## 2. ARCHITECTURE

```
┌──────────────────────────────────────────────────────┐
│                   Graph Runtime                       │
│                                                       │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────┐  │
│  │ Query Layer   │  │ Command Bus  │  │ Event Bus  │  │
│  └──────┬───────┘  └──────┬───────┘  └─────┬──────┘  │
│         │                 │                 │         │
│  ┌──────┴─────────────────┴─────────────────┴──────┐  │
│  │              Engine Registry                     │  │
│  │  ┌──────────┐ ┌──────────┐ ┌────────────────┐  │  │
│  │  │ Identity │ │  Asset   │ │    Pattern     │  │  │
│  │  │ Engine   │ │  Engine  │ │    Engine      │  │  │
│  │  ├──────────┤ ├──────────┤ ├────────────────┤  │  │
│  │  │ Relation │ │ Behavior │ │   Lifecycle    │  │  │
│  │  │ Engine   │ │  Engine  │ │    Engine      │  │  │
│  │  ├──────────┤ ├──────────┤ ├────────────────┤  │  │
│  │  │ Evidence │ │Validation│ │   Projection   │  │  │
│  │  │ Engine   │ │  Engine  │ │    Engine      │  │  │
│  │  └──────────┘ └──────────┘ └────────────────┘  │  │
│  └─────────────────────────────────────────────────┘  │
│                                                       │
│  ┌──────────────────┐  ┌──────────────────────────┐   │
│  │   Event Log      │  │    Storage Backend        │   │
│  └──────────────────┘  └──────────────────────────┘   │
└──────────────────────────────────────────────────────┘
```

---

## 3. INTERFACES

### 3.1 Engine Interface

```
protocol Engine {
  id: String
  version: String
  capabilities: [Capability]

  initialize(config: Config) → Result
  health() → HealthStatus
  shutdown() → Result
}
```

### 3.2 IdentityEngine Interface

```
protocol IdentityEngine: Engine {
  createIdentity(type, archetype, seed?) → Identity
  resolveIdentity(identity) → Node | Edge | nil
  validateIdentity(identity) → Bool
  hashContent(data) → Hash
}
```

### 3.3 AssetEngine Interface

```
protocol AssetEngine: Engine {
  createNode(type, archetype, pattern, attributes) → Node
  readNode(identity) → Node | nil
  updateAttributes(identity, attributes) → Node
  archiveNode(identity) → Event
  findNodes(filter) → [Node]
}
```

### 3.4 RelationEngine Interface

```
protocol RelationEngine: Engine {
  createEdge(type, source, target, metadata?) → Edge
  readEdge(identity) → Edge | nil
  readEdges(node, direction) → [Edge]
  traverse(from, via, direction, depth) → Path
  archiveEdge(identity) → Event
}
```

### 3.5 PatternEngine Interface

```
protocol PatternEngine: Engine {
  resolvePattern(node) → Pattern
  matchPattern(criteria) → [Pattern]
  composePatterns(patterns) → Pattern
  registerPattern(pattern) → Pattern
}
```

### 3.6 LifecycleEngine Interface

```
protocol LifecycleEngine: Engine {
  transition(identity, to) → Event
  getState(identity) → LifecycleState
  getHistory(identity) → [LifecycleEvent]
  validateTransition(from, to) → Bool
}
```

### 3.7 ProjectionEngine Interface

```
protocol ProjectionEngine: Engine {
  projectToJSON(query) → JSON
  projectToYAML(query) → YAML
  projectToSQLite(query) → DB
  projectToFilesystem(query) → FileTree
  projectToAPI(query) → Endpoints
  registerProjection(type, definition) → Projection
}
```

---

## 4. QUERY LANGUAGE

The Runtime exposes a query interface:

### 4.1 Find Nodes

```graphql
findNodes(
  type: NodeType
  archetype: Archetype
  pattern: String
  filter: AttributeFilter
  dimensions: DimensionRange
) → [Node]
```

### 4.2 Traverse

```graphql
traverse(
  from: Identity
  edges: [EdgeType]
  direction: TraversalDirection
  maxDepth: Int
  filter: NodeFilter
) → Path
```

### 4.3 Query

```graphql
query(
  pattern: QueryPattern
  params: Map
) → QueryResult
```

---

## 5. EVENT LOG

### 5.1 Event Structure

```
Event {
  id: Identity
  timestamp: Timestamp
  type: EventType
  actor: Identity
  target: Identity
  mutation: Mutation
  before: State | nil
  after: State | nil
  signature: Hash
  previousEvent: Identity | nil     [linked list chain]
}
```

### 5.2 Event Types

| Type | Trigger |
|------|---------|
| NODE_CREATED | AssetEngine.createNode |
| NODE_ARCHIVED | AssetEngine.archiveNode |
| NODE_UPDATED | AssetEngine.updateAttributes |
| EDGE_CREATED | RelationEngine.createEdge |
| EDGE_ARCHIVED | RelationEngine.archiveEdge |
| LIFECYCLE_CHANGED | LifecycleEngine.transition |
| PATTERN_REGISTERED | PatternEngine.registerPattern |
| PROJECTION_GENERATED | ProjectionEngine.projectTo* |

### 5.3 Replay

The event log supports full replay:

```
replay(from: Timestamp, to: Timestamp) → [Event]
replayToState(target: Timestamp) → Graph
```

Replay reconstructs the complete Graph state at any point in time.

---

## 6. TRANSACTIONS

### 6.1 Atomicity

Multi-engine operations are atomic:

```
beginTransaction()
  → IdentityEngine.createIdentity(...)
  → AssetEngine.createNode(...)
  → LifecycleEngine.transition(...)
commitTransaction()  |  rollbackTransaction()
```

### 6.2 Isolation

Each transaction operates on a snapshot of the Graph. Concurrent transactions are serialized.

---

## 7. STORAGE BACKEND

The Runtime defines a storage interface, not an implementation:

```
protocol StorageBackend {
  storeNode(node) → Result
  readNode(identity) → Node | nil
  storeEdge(edge) → Result
  readEdge(identity) → Edge | nil
  storeEvent(event) → Result
  queryIndex(index, filter) → [Identity]
  beginTransaction() → Transaction
  commit(transaction) → Result
  rollback(transaction) → Result
}
```

Implementations can be:
- In-memory (development, small graphs)
- SQLite (embedded)
- PostgreSQL (production)
- Custom distributed store

---

## 8. HEALTH & METRICS

The Runtime exposes:

### 8.1 Health Endpoint
```
GET /health → {
  status: "ok" | "degraded" | "down"
  engines: { engineId: "ok" | "error" }
  storage: "ok" | "error"
  uptime: seconds
}
```

### 8.2 Metrics Endpoint
```
GET /metrics → {
  nodeCount: Int
  edgeCount: Int
  eventCount: Int
  engineLatency: { engineId: { p50, p95, p99 } }
  transactionThroughput: Float
  projectionLatency: Float
  storageSize: Bytes
}
```

---

## 9. ERROR HANDLING

| Error | Code | Description |
|-------|------|-------------|
| NODE_NOT_FOUND | 404 | Identity does not resolve |
| EDGE_NOT_FOUND | 404 | Edge identity does not resolve |
| IDENTITY_COLLISION | 409 | Duplicate identity |
| INVALID_TRANSITION | 422 | Lifecycle transition not allowed |
| CONSTRAINT_VIOLATION | 422 | Graph integrity constraint violated |
| ENGINE_ERROR | 500 | Engine internal error |
| STORAGE_ERROR | 500 | Storage backend error |

---

**CANONICO_GRAPH_RUNTIME.md — V1**
