# CANONICO UGIS — Universal Graph Information Standard

## Status: STANDARD V1

---

## 1. FOUNDATIONAL LAWS

### Law 1 — The Graph is the only reality
Every entity, every interaction, every state change, every relationship exists **exclusively** in the Graph. No external representation is authoritative.

### Law 2 — Everything is a Node
Any entity — concrete or abstract — is represented as a Node. A Node has no intrinsic location, path, file, or storage. It exists only as an identity in the Graph.

### Law 3 — Every interaction is an Edge
Any relationship, dependency, flow, or transformation between Nodes is an Edge. Edges are first-class citizens with their own identity, weight, trust, and lifecycle.

### Law 4 — Everything else is a Projection
File systems, JSON, APIs, databases, UIs, documents — all are derived **read-only** projections of the canonical Graph. Projections are never authoritative.

### Law 5 — Pattern over Implementation
Every Node references a Pattern. Every Pattern references an Archetype. Behavior is determined by Pattern, never by implementation.

---

## 2. CORE CONCEPTS

### 2.1 Node
A Node is the atomic unit of the Graph. It represents any entity:
- Physical (computer, file, human)
- Logical (project, module, function)
- Abstract (idea, decision, memory, mission)
- Composite (workspace, organization, network)

### 2.2 Edge
An Edge is the atomic unit of interaction. It represents any relationship between two Nodes:
- Structural (CONTAINS, BELONGS_TO)
- Functional (DEPENDS_ON, USES)
- Temporal (GENERATES, EXECUTES)
- Cognitive (REMEMBERS, LEARNS)
- Evaluative (PROVES, OBSERVES)

### 2.3 Pattern
A Pattern is a reusable behavioral template that determines how a Node interacts. Patterns are the behavioral atoms of the Graph.

### 2.4 Archetype
An Archetype is the most abstract classification of a Node. It defines the fundamental nature of an entity:
- SYSTEM
- AGENT
- RESOURCE
- MEMORY
- PROCESS
- RELATIONSHIP
- CONCEPT

### 2.5 Projection
A Projection is a materialized view of the Graph in a specific format. Projections are always **read-only** derivations.

---

## 3. GRAPH PROPERTIES

### 3.1 Source of Truth
The Graph is the single source of truth. No dual representation is permitted. Any divergence between a Projection and the Graph is resolved in favor of the Graph.

### 3.2 Immutability by Default
Once committed, a Node's identity never changes. Attributes can evolve, but identity is immutable. Edges can be superseded but never deleted — they transition to an `ARCHIVED` lifecycle state.

### 3.3 Temporal Completeness
Every Edge carries a timestamp. Every state change generates an Event. The Graph can be rewound to any point in its history.

### 3.4 Context Independence
A Node has meaning within the Graph without reference to:
- File paths
- Storage locations
- API endpoints
- Database tables
- Network addresses

These are all **Projections** of a Node, never its identity.

---

## 4. NODE TAXONOMY

The canonical node taxonomy spans every domain:

| Domain | Example Node Types |
|--------|-------------------|
| Physical | Computer, Device, Network, Sensor, Drive |
| Digital | File, Process, Service, API, Database |
| Software | Project, Module, Class, Function, Package |
| Human | Person, Role, Team, Organization |
| Cognitive | Memory, Decision, Mission, Knowledge |
| Temporal | Event, Session, Version, Release |
| Abstract | Concept, Pattern, Archetype, Standard |
| Composite | Workspace, System, Platform, Twin |

---

## 5. EDGE TAXONOMY

| Category | Edge Types |
|----------|-----------|
| Structural | CONTAINS, BELONGS_TO, OWNS, PART_OF |
| Dependency | DEPENDS_ON, USES, REQUIRES, IMPORTS |
| Generation | GENERATES, PRODUCES, CREATES, DERIVES |
| Implementation | IMPLEMENTS, EXTENDS, CONFORMS_TO |
| Execution | EXECUTES, RUNS, CALLS, INVOKES |
| Observation | OBSERVES, MONITORS, READS, TRACKS |
| Cognition | REMEMBERS, LEARNS, DECIDES, INFERS |
| Provenance | PROVES, VALIDATES, CERTIFIES, AUTHORIZES |
| Lifecycle | EVOLVES, MIGRATES, ARCHIVES, DELETES |

---

## 6. PATTERN-ARCHETYPE HIERARCHY

```
Node
  └─ references → Pattern
                    └─ references → Archetype

Archetype: SYSTEM
  └─ Pattern: OperatingSystem
  └─ Pattern: Application
  └─ Pattern: Service
  └─ Pattern: Database

Archetype: AGENT
  └─ Pattern: AIAgent
  └─ Pattern: Worker
  └─ Pattern: Observer
  └─ Pattern: Scheduler

Archetype: RESOURCE
  └─ Pattern: ComputeUnit
  └─ Pattern: StorageUnit
  └─ Pattern: NetworkResource
  └─ Pattern: EnergyUnit
```

---

## 7. PROJECTION PRINCIPLES

### 7.1 Derivation Rule
All Projections are derived from the Graph by deterministic transformation. Given the same Graph state and the same Projection definition, the output is identical.

### 7.2 No-Write Rule
Projections never write back to the Graph. The Graph is modified exclusively through its native API (Identity Engine).

### 7.3 Standard Projections

| Projection | Target | Use Case |
|-----------|--------|----------|
| JSON | Filesystem | Interchange, backup |
| YAML | Filesystem | Human-readable config |
| SQLite | Database | Query, analytics |
| SwiftUI | Screen | Visualization |
| FileSystem | Finder | File browser |
| Git | Repository | Version control |
| API | REST/GraphQL | Remote access |
| Documentation | Markdown | Human reference |
| QR | Image | Physical tagging |
| Digital Passport | JSON+QR | Node identity card |

---

## 8. COMPATIBILITY

### 8.1 Existing Standards

| Standard | Reusable Concepts | CANONICO Innovation |
|----------|------------------|---------------------|
| Property Graph (Neo4j) | Node-Edge model, labels, properties | Immutable ID, temporal edges, Pattern-Archetype hierarchy |
| Knowledge Graph | Semantic relations, inference | Projection-first design, no dual storage |
| AAS (Asset Administration Shell) | Submodel descriptors, digital passport | Graph-native passport, no hierarchy constraint |
| Digital Twins | Twin synchronization | Projection model eliminates sync — Graph is the source |
| Ontologies (OWL, RDF) | Class inheritance, reasoning | Archetype is lighter, execution-oriented, not logic-oriented |

### 8.2 Interoperability
CANONICO can project into any of these standards. A CANONICO Graph can be serialized as RDF, imported into Neo4j, or mapped to AAS submodels — always as a **lossy projection**, never as the source.

---

## 9. GRAPH DIMENSIONS (3D)

The Graph is designed for native 3D navigation:

| Axis | Meaning | Range |
|------|---------|-------|
| X | Ownership | 0.0 (none) → 1.0 (full) |
| Y | Dependency Depth | 0.0 (leaf) → 1.0 (root) |
| Z | Semantic Distance | 0.0 (identical) → 1.0 (unrelated) |

### Supplementary Dimensions

| Dimension | Meaning |
|-----------|---------|
| Importance | 0.0–1.0 criticality score |
| Trust | 0.0–1.0 reliability score |
| Energy | 0.0–1.0 activity level |
| Activity | 0.0–1.0 recent change frequency |
| Lifecycle | 0.0 (concept) → 1.0 (archived) |
| Execution | 0.0 (idle) → 1.0 (running) |
| Version | Integer sequence |

A Node is primarily understood by: **position, form, color, relationship signature, metrics**. Text is a Projection.

---

## 10. GOVERNANCE

### 10.1 Graph Integrity
- No edge can reference a non-existent Node
- No Node can exist without an identity
- Every mutation generates an Event
- Every Event is replayable

### 10.2 Versioning
The Standard itself follows Semantic Versioning:
- MAJOR: incompatible standard change
- MINOR: backward-compatible addition
- PATCH: clarification, correction

### 10.3 Extension
Extensions define new Patterns, Archetypes, or Projections. They must conform to the core model and be registered in the Pattern Library.

---

## 11. SCOPE

CANONICO UGIS is designed to represent, in a single coherent Graph:
- A personal computer
- A software workspace
- A software project
- A business organization
- A computer network
- An AI agent ecosystem
- A digital twin of any system
- A human cognitive map
- A product portfolio
- A knowledge domain

No scope limit is imposed by the Standard. Any domain can be modeled by extending the Pattern Library.

---

**CANONICO_STANDARD.md — V1**
**Universal Graph Information Standard**
**License: Open Standard**
