# CANONICO Graph Kernel — Reference Architecture

## Status: SPECIFICATION V1

---

## 1. KERNEL OVERVIEW

The Graph Kernel is the reference architecture for any implementation of the CANONICO UGIS. It defines the engines, their responsibilities, and the data flows between them.

```
                    ┌─────────────────────────────┐
                    │      Identity Engine         │
                    │   (ID generation, lookup)    │
                    └──────────┬──────────────────┘
                               │
       ┌───────────────────────┼───────────────────────┐
       │                       │                       │
       ▼                       ▼                       ▼
┌──────────────┐   ┌────────────────────┐   ┌──────────────────┐
│  Asset       │   │   Pattern Engine   │   │   Relation       │
│  Engine      │   │   (pattern match,  │   │   Engine         │
│  (CRUD)      │   │    resolve)        │   │   (edge CRUD)    │
└──────┬───────┘   └─────────┬──────────┘   └──────┬───────────┘
       │                     │                      │
       └─────────────────────┼──────────────────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │  Behavior Engine  │
                    │  (pattern-driven) │
                    └────────┬─────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │  Lifecycle       │
                    │  Engine          │
                    └────────┬─────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │  Evidence        │
                    │  Engine          │
                    └────────┬─────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │  Validation      │
                    │  Engine          │
                    └────────┬─────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │  Projection      │
                    │  Engine          │
                    └────────┬─────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │  Graph Runtime   │
                    │  (orchestrator)  │
                    └──────────────────┘
```

---

## 2. ENGINE SPECIFICATIONS

### 2.1 Identity Engine

**Responsibility:** Generate, resolve, and validate immutable Node and Edge identities.

**Operations:**
- `createIdentity(seed: Data) → Identity`
- `resolveIdentity(identity: Identity) → Node | Edge`
- `validateIdentity(identity: Identity) → Bool`
- `hashOf(content: Data) → Hash`

**Constraints:**
- Identity is immutable once committed
- Identity is content-addressable (derived from seed data)
- No two identities can collide (collision-free by construction)

### 2.2 Asset Engine

**Responsibility:** Create, read, update (attributes only), and archive Nodes.

**Operations:**
- `createNode(archetype: Archetype, pattern: Pattern) → Node`
- `readNode(identity: Identity) → Node`
- `updateAttributes(identity: Identity, attributes: Map) → Node`
- `archiveNode(identity: Identity) → Event`

**Constraints:**
- Identity cannot be mutated
- Archetype cannot change after creation
- Pattern can evolve (with Event trail)

### 2.3 Pattern Engine

**Responsibility:** Match, resolve, and compose Patterns.

**Operations:**
- `resolvePattern(node: Node) → Pattern`
- `matchPattern(criteria: Criteria) → [Pattern]`
- `composePatterns(patterns: [Pattern]) → Pattern`
- `registerPattern(pattern: Pattern) → Pattern`

### 2.4 Relation Engine

**Responsibility:** Manage Edges between Nodes.

**Operations:**
- `createEdge(from: Node, to: Node, type: EdgeType) → Edge`
- `readEdges(node: Node, direction: Direction) → [Edge]`
- `traverse(from: Node, via: EdgeType) → [Node]`
- `archiveEdge(identity: Identity) → Event`

**Constraints:**
- Every Edge references exactly two Nodes
- Both Nodes must exist (referential integrity)
- Edge type must be a registered EdgeType

### 2.5 Behavior Engine

**Responsibility:** Execute Pattern-defined behavior for a Node.

**Operations:**
- `executeBehavior(node: Node) → Event`
- `simulateBehavior(node: Node, context: Context) → [Event]`
- `getCapabilities(node: Node) → [Capability]`

**Constraints:**
- Behavior is defined by Pattern, never by Node instance
- Behavior execution generates Events

### 2.6 Lifecycle Engine

**Responsibility:** Track and transition Node/Edge lifecycle states.

**States:**
```
CONCEPT → CREATED → ACTIVE → SUSPENDED → ARCHIVED
                                        → DELETED (soft)
```

**Operations:**
- `transition(identity: Identity, to: LifecycleState) → Event`
- `getLifecycle(identity: Identity) → LifecycleState`
- `getHistory(identity: Identity) → [LifecycleEvent]`

### 2.7 Evidence Engine

**Responsibility:** Attach and verify Evidence on any Node or Edge.

**Operations:**
- `attachEvidence(target: Identity, evidence: Evidence) → Edge`
- `verifyEvidence(identity: Identity) → Trust`
- `getEvidenceChain(identity: Identity) → [Evidence]`

### 2.8 Validation Engine

**Responsibility:** Validate Graph integrity, constraints, and consistency.

**Operations:**
- `validateGraph() → [ValidationReport]`
- `validateNode(identity: Identity) → ValidationReport`
- `validateEdge(identity: Identity) → ValidationReport`
- `detectAnomalies() → [Anomaly]`

**Validation rules:**
- No dangling edges
- All identities are unique
- All Patterns exist in Pattern Library
- All Archetypes exist in Archetype Library
- No orphaned Nodes

### 2.9 Projection Engine

**Responsibility:** Derive Projections from the canonical Graph.

**Operations:**
- `projectToJSON(graph: Graph) → JSON`
- `projectToYAML(graph: Graph) → YAML`
- `projectToSQLite(graph: Graph) → DB`
- `projectToFilesystem(graph: Graph) → FileTree`
- `projectToAPI(graph: Graph) → Endpoints`

**Constraints:**
- Projections are always read-only derivations
- Projection format is determined by a ProjectionDefinition
- Lossy transformations are documented

### 2.10 Graph Runtime

**Responsibility:** Orchestrate all engines, manage concurrency, and expose a unified interface.

**Responsibilities:**
- Route requests to correct engine
- Maintain event log
- Provide query interface (graphQL-like)
- Manage transactions (atomic multi-engine operations)
- Expose health and metrics

---

## 3. DATA FLOW

### 3.1 Node Creation Flow
```
Client → Graph Runtime → Identity Engine (generate ID)
                       → Asset Engine (create node)
                       → Pattern Engine (resolve pattern)
                       → Lifecycle Engine (set CONCEPT→CREATED)
                       → Evidence Engine (attach creation evidence)
                       → Event log (record creation event)
                       → Graph Runtime → Client
```

### 3.2 Edge Creation Flow
```
Client → Graph Runtime → Identity Engine (generate edge ID)
                       → Validation Engine (validate nodes exist)
                       → Relation Engine (create edge)
                       → Lifecycle Engine (set CREATED)
                       → Event log → Client
```

### 3.3 Projection Flow
```
Client (request: JSON) → Graph Runtime → Asset Engine (read all nodes)
                                       → Relation Engine (read all edges)
                                       → Projection Engine (transform)
                                       → Graph Runtime → Client (JSON)
```

---

## 4. TRANSACTION MODEL

All engine operations are atomic within a transaction:
- Begin transaction
- Execute engine operations
- Validate constraints
- Commit (or rollback)
- Record Event

---

## 5. EVENT MODEL

Every mutation generates a canonical Event:

```
Event {
  id: Identity
  type: EventType
  timestamp: Timestamp
  actor: Identity (who/what triggered)
  target: Identity (Node or Edge affected)
  mutation: Mutation
  before: State (optional)
  after: State (optional)
  signature: Hash
}
```

The event log is replayable to reconstruct any past Graph state.

---

## 6. METRICS

The Graph Runtime exposes:
- Node count
- Edge count
- Event count
- Engine latency (p50, p95, p99)
- Transaction throughput
- Projection generation time
- Storage size (serialized)

---

**CANONICO_GRAPH_KERNEL.md — V1**
