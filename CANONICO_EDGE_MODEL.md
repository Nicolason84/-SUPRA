# CANONICO Edge Model

## Status: SPECIFICATION V1

---

## 1. EDGE STRUCTURE

An Edge is the atomic unit of interaction in the CANONICO Graph. Every relationship, dependency, flow, or transformation between Nodes is an Edge.

Edges are **first-class citizens**: they have identity, weight, trust, lifecycle, and metadata — independent of their source and target Nodes.

### 1.1 Canonical Form

```
Edge {
  id: Identity                    [immutable, content-addressed]
  type: EdgeType                  [immutable]

  source: Identity                [immutable, must exist in Graph]
  target: Identity                [immutable, must exist in Graph]

  weight: Float                   [0.0–1.0, strength of relationship]
  trust: Float                    [0.0–1.0, confidence in this edge]
  direction: Direction            [DIRECTED | BIDIRECTIONAL | UNDIRECTED]

  metadata: Map<String, Any>      [domain-specific edge data]

  timestamp: Timestamp            [when the relationship was established]
  lifecycle: LifecycleState       [same lifecycle as Nodes]
  history: [LifecycleEvent]       [full edge evolution trail]
}
```

---

## 2. EdgeType CATALOG

### 2.1 Structural

| EdgeType | Direction | Meaning | Example |
|----------|-----------|---------|---------|
| CONTAINS | Directed | Parent contains child | Workspace CONTAINS Project |
| BELONGS_TO | Directed | Child belongs to parent | File BELONGS_TO Module |
| OWNS | Directed | Owner possesses asset | Person OWNS Computer |
| PART_OF | Directed | Component of a whole | Module PART_OF Project |
| MEMBER_OF | Directed | Membership | Person MEMBER_OF Team |

### 2.2 Dependency

| EdgeType | Direction | Meaning | Example |
|----------|-----------|---------|---------|
| DEPENDS_ON | Directed | Source depends on target | Module DEPENDS_ON Package |
| USES | Directed | Source uses target | Function USES API |
| REQUIRES | Directed | Hard requirement | System REQUIRES Service |
| IMPORTS | Directed | Import relationship | File IMPORTS Module |
| CONFIGURES | Directed | Configuration | Service CONFIGURES Runtime |

### 2.3 Generation

| EdgeType | Direction | Meaning | Example |
|----------|-----------|---------|---------|
| GENERATES | Directed | Source produces target | Compiler GENERATES Binary |
| PRODUCES | Directed | Source creates output | Factory PRODUCES Product |
| CREATES | Directed | Source brings into existence | Agent CREATES Node |
| DERIVES | Directed | Derived from source | Decision DERIVES Evidence |

### 2.4 Implementation

| EdgeType | Direction | Meaning | Example |
|----------|-----------|---------|---------|
| IMPLEMENTS | Directed | Source implements target | Class IMPLEMENTS Protocol |
| EXTENDS | Directed | Source extends target | Module EXTENDS BaseModule |
| CONFORMS_TO | Directed | Conformance | Struct CONFORMS_TO Protocol |
| SPECIALIZES | Directed | Specialization | iOS SPECIALIZES Darwin |
| ABSTRACTION_OF | Directed | Is abstraction of | Interface ABSTRACTION_OF Impl |

### 2.5 Execution

| EdgeType | Direction | Meaning | Example |
|----------|-----------|---------|---------|
| EXECUTES | Directed | Source executes target | Runtime EXECUTES Binary |
| RUNS | Directed | Source runs on target | Service RUNS Computer |
| CALLS | Directed | Source invokes target | Function CALLS Function |
| INVOKES | Directed | Source triggers target | Event INVOKES Handler |
| SCHEDULES | Directed | Scheduling | Scheduler SCHEDULES Worker |

### 2.6 Observation

| EdgeType | Direction | Meaning | Example |
|----------|-----------|---------|---------|
| OBSERVES | Directed | Source monitors target | Monitor OBSERVES System |
| MONITORS | Directed | Active monitoring | Agent MONITORS Process |
| READS | Directed | Read access | Knowledge READS Source |
| TRACKS | Directed | Tracking relationship | Logger TRACKS Event |

### 2.7 Cognition

| EdgeType | Direction | Meaning | Example |
|----------|-----------|---------|---------|
| REMEMBERS | Directed | Source recalls target | Memory REMEMBERS Node |
| LEARNS | Directed | Source learns from | Agent LEARNS Experience |
| DECIDES | Directed | Decision made about | Agent DECIDES Action |
| INFERS | Directed | Inference | Engine INFERS Knowledge |
| BELIEVES | Bidirectional | Belief relationship | Agent BELIEVES Statement |

### 2.8 Provenance

| EdgeType | Direction | Meaning | Example |
|----------|-----------|---------|---------|
| PROVES | Directed | Source proves target | Evidence PROVES Claim |
| VALIDATES | Directed | Validation | Validation VALIDATES Node |
| CERTIFIES | Directed | Certification | Authority CERTIFIES Identity |
| AUTHORIZES | Directed | Authorization | Policy AUTHORIZES Action |
| ATTESTED_BY | Directed | Attestation | Identity ATTESTED_BY Issuer |

### 2.9 Lifecycle

| EdgeType | Direction | Meaning | Example |
|----------|-----------|---------|---------|
| EVOLVES | Directed | Source evolves into | Node EVOLVES Node |
| MIGRATES | Directed | Migration | Data MIGRATES Storage |
| ARCHIVES | Directed | Archival action | System ARCHIVES Project |
| SUPERSEDES | Directed | Replacement | V2 SUPERSEDES V1 |
| PRECEDES | Directed | Temporal ordering | Event PRECEDES Event |

---

## 3. EDGE PROPERTIES

### 3.1 Weight
Float 0.0–1.0 indicating the strength or intensity of the relationship:
- 0.0: minimal (optional, weak)
- 0.5: moderate (standard dependency)
- 1.0: maximal (critical, inseparable)

### 3.2 Trust
Float 0.0–1.0 indicating confidence in the edge's accuracy:
- 0.0: unknown/untrusted
- 0.5: partially verified
- 1.0: fully verified, immutable

### 3.3 Direction

| Direction | Meaning | Visual |
|-----------|---------|--------|
| DIRECTED | source → target (unidirectional) | Arrow |
| BIDIRECTIONAL | source ↔ target (mutual) | Double arrow |
| UNDIRECTED | source — target (symmetric) | Line |

### 3.4 Metadata
TypeMap for domain-specific edge data. Common metadata keys:

| Key | Type | Meaning |
|-----|------|---------|
| label | String | Human readable label |
| description | String | Edge description |
| strength | String | "weak", "moderate", "strong" |
| frequency | String | "once", "periodic", "continuous" |
| latency | Float | Response latency (ms) |
| bandwidth | Float | Throughput (req/s) |
| protocol | String | Communication protocol |
| version | String | Edge definition version |

---

## 4. EDGE LIFECYCLE

Same lifecycle model as Nodes:

```
CREATED → ACTIVE → SUSPENDED → ARCHIVED
```

Edges are **never deleted**. An edge in ARCHIVED state preserves:
- Its full identity
- All metadata
- Historical integrity
- Trust and weight values

---

## 5. CONSTRAINTS

### 5.1 Referential Integrity
- `source` and `target` must reference existing Nodes
- An Edge cannot exist without both endpoints

### 5.2 Uniqueness
- Edge identity is unique (content-addressed from type + source + target + timestamp)
- Parallel edges of the same type between the same Nodes must differ in metadata or timestamp

### 5.3 Cardinality

| Constraint | Rule |
|-----------|------|
| One-to-One | One Edge between two Nodes per type |
| One-to-Many | One source, multiple targets |
| Many-to-One | Multiple sources, one target |
| Many-to-Many | Multiple sources, multiple targets |

---

## 6. TRAVERSAL

The Edge model supports graph traversal operations:

```
traverse(from: Identity, via: EdgeType, direction: Direction) → [Node]
traverse(from: Identity, maxDepth: Int) → [Path]
traverse(from: Identity, filter: EdgeFilter) → [Subgraph]
```

Path result:
```
Path {
  nodes: [Identity]
  edges: [Identity]
  totalWeight: Float
  totalTrust: Float
  length: Int
}
```

---

## 7. SERIALIZATION

### 7.1 Canonical JSON Form

```json
{
  "id": "can:edge:a1b2c3d4...",
  "type": "DEPENDS_ON",
  "source": "can:sys:7f3a1b2c...",
  "target": "can:sys:9e8d7c6b...",
  "weight": 0.87,
  "trust": 0.95,
  "direction": "DIRECTED",
  "metadata": {
    "label": "Swift Package Dependency",
    "version": "1.2.3"
  },
  "timestamp": "2026-07-29T10:00:00Z",
  "lifecycle": "ACTIVE"
}
```

---

**CANONICO_EDGE_MODEL.md — V1**
