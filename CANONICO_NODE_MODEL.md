# CANONICO Node Model

## Status: SPECIFICATION V1

---

## 1. NODE STRUCTURE

A Node is the atomic unit of the CANONICO Graph. Every entity in any modeled system is a Node.

### 1.1 Canonical Form

```
Node {
  id: Identity                    [immutable, content-addressed]
  type: NodeType                  [immutable, set at creation]

  archetype: Archetype            [immutable, references Archetype Library]
  pattern: Pattern                [mutable, references Pattern Library]

  name: String                    [mutable, human-readable label]
  description: String             [mutable]

  attributes: Map<String, Any>    [mutable, domain-specific data]

  dimensions: Dimensions {
    ownership: Float         [0.0–1.0]
    dependency: Float        [0.0–1.0]
    semanticDistance: Float  [0.0–1.0]
    importance: Float        [0.0–1.0]
    trust: Float             [0.0–1.0]
    energy: Float            [0.0–1.0]
    activity: Float          [0.0–1.0]
    lifecycle: Float         [0.0–1.0]
    execution: Float         [0.0–1.0]
    version: Int
  }

  passport: DigitalPassport

  created: Timestamp
  updated: Timestamp
  lifecycle: LifecycleState
}
```

---

## 2. NodeType CATALOG

### 2.1 Physical Domain

| NodeType | Description | Default Archetype |
|----------|-------------|-------------------|
| Computer | Physical or virtual machine | SYSTEM |
| Device | Peripheral, sensor, actuator | SYSTEM |
| Network | Network segment or domain | SYSTEM |
| Storage | Disk, volume, partition | RESOURCE |
| Component | Hardware component (CPU, RAM) | RESOURCE |

### 2.2 Software Domain

| NodeType | Description | Default Archetype |
|----------|-------------|-------------------|
| Workspace | Development workspace | SYSTEM |
| Project | Software project | SYSTEM |
| Package | Library, framework, module | RESOURCE |
| Module | Source module | RESOURCE |
| File | Source or resource file | RESOURCE |
| Class | OOP class | RESOURCE |
| Function | Function or method | RESOURCE |
| API | Public or private API | SYSTEM |
| Database | Database instance | SYSTEM |
| Service | Running service | AGENT |
| Process | OS process | AGENT |
| Runtime | Language runtime (Swift, Python) | SYSTEM |

### 2.3 Agent Domain

| NodeType | Description | Default Archetype |
|----------|-------------|-------------------|
| Agent | AI agent or assistant | AGENT |
| Worker | Background worker | AGENT |
| Observer | Monitoring observer | AGENT |
| Scheduler | Task scheduler | AGENT |

### 2.4 Cognitive Domain

| NodeType | Description | Default Archetype |
|----------|-------------|-------------------|
| Memory | Stored knowledge or state | MEMORY |
| Decision | Architectural or operational decision | MEMORY |
| Mission | Active or completed mission | PROCESS |
| Knowledge | Domain knowledge entity | MEMORY |
| Conversation | Human-agent conversation | MEMORY |
| Prompt | LLM prompt template | RESOURCE |
| Evidence | Proof or attestation | MEMORY |

### 2.5 Human Domain

| NodeType | Description | Default Archetype |
|----------|-------------|-------------------|
| Person | Human individual | AGENT |
| Role | Functional role | PATTERN |
| Team | Group of people | SYSTEM |
| Organization | Company, institution | SYSTEM |

### 2.6 Abstract Domain

| NodeType | Description | Default Archetype |
|----------|-------------|-------------------|
| Concept | Abstract idea | CONCEPT |
| Pattern | Behavioral pattern | PATTERN |
| Archetype | Foundational archetype | PATTERN |
| Standard | Technical standard | CONCEPT |
| Product | Product or offering | CONCEPT |
| Service | Abstract service | CONCEPT |

---

## 3. DIMENSIONS

### 3.1 Core Dimensions

| Dimension | Type | Range | Meaning |
|-----------|------|-------|---------|
| X — Ownership | Float | 0.0–1.0 | Who controls this node |
| Y — Dependency | Float | 0.0–1.0 | How deep in dependency chain |
| Z — Semantic Distance | Float | 0.0–1.0 | How semantically related to origin |

### 3.2 Supplementary Dimensions

| Dimension | Type | Range | Meaning |
|-----------|------|-------|---------|
| Importance | Float | 0.0–1.0 | Criticality to system function |
| Trust | Float | 0.0–1.0 | Reliability/confidence score |
| Energy | Float | 0.0–1.0 | Current activity/load level |
| Activity | Float | 0.0–1.0 | Rate of recent changes |
| Lifecycle | Float | 0.0–1.0 | Maturity (0=concept, 1=archived) |
| Execution | Float | 0.0–1.0 | Execution state (0=idle, 1=running) |
| Version | Int | 0+ | Iteration count |

---

## 4. LIFECYCLE STATES

```
CONCEPT     → Node is proposed but not materialized
CREATED     → Node is created in the Graph
ACTIVE      → Node is operational
SUSPENDED   → Node is temporarily inactive
ARCHIVED    → Node is preserved but not active
DELETED     → Node is soft-deleted (identity preserved)
```

Each state transition generates an immutable Event.

---

## 5. ATTRIBUTES

Attributes are typed key-value pairs. The type system:

| Attribute Type | Example | Storage |
|---------------|---------|---------|
| String | "MyProject" | Text |
| Integer | 42 | Integer |
| Float | 3.14 | Floating point |
| Boolean | true | Boolean |
| Timestamp | 2026-07-29T12:00:00Z | ISO 8601 |
| Hash | 0x1a2b... | Hex string |
| Identity | can:sys:abc123 | Canonical ID |
| List | [1, 2, 3] | Ordered collection |
| Map | {"key": "value"} | Key-value collection |
| Reference | @can:sys:other | Link to another Node |

---

## 6. SERIALIZATION

### 6.1 Canonical JSON Form

```json
{
  "id": "can:sys:7f3a1b2c...",
  "type": "project",
  "archetype": "SYSTEM",
  "pattern": "SwiftProject",
  "name": "MyProject",
  "description": "A Swift project",
  "attributes": {
    "language": "Swift",
    "targets": ["App", "Tests"]
  },
  "dimensions": {
    "ownership": 0.85,
    "dependency": 0.72,
    "semanticDistance": 0.31,
    "importance": 0.90,
    "trust": 0.95,
    "energy": 0.45,
    "activity": 0.60,
    "lifecycle": 0.80,
    "execution": 0.0,
    "version": 3
  },
  "created": "2026-07-29T10:00:00Z",
  "updated": "2026-07-29T12:00:00Z",
  "lifecycle": "ACTIVE"
}
```

### 6.2 Binary Form

Compact binary encoding for high-performance Graph operations:
- 8 bytes: Identity prefix
- 1 byte: NodeType
- 1 byte: Archetype
- 2 bytes: Pattern index
- 4 bytes: Attribute count
- Variable: Attribute blocks
- 32 bytes: Dimension vector
- 8 bytes: Timestamps
- 1 byte: Lifecycle state

---

## 7. INTEGRITY

Every Node carries an implicit integrity chain:
- `id` is a hash of (type + archetype + creation attributes)
- `updated` is signed by the mutating engine
- `lifecycle` transitions are recorded in the Event log

Nodes cannot be deleted — only archived. Identities are never reused.

---

## 8. EXTENSION

Custom NodeTypes can be defined by registering:
1. A unique `type` identifier
2. An Archetype from the Archetype Library
3. A default Pattern from the Pattern Library
4. Optional: custom attribute schema

Custom NodeTypes must be registered in the Pattern Library.

---

**CANONICO_NODE_MODEL.md — V1**
