# Canonicalization Engine V1 — SUPRA ULTIMATE CONSOLIDATED

## Execution Gate Specification

| Property | Value |
|---|---|
| **Name** | Canonicalization Engine |
| **Version** | V1 |
| **Date** | 2026-07-29 |
| **Status** | LIVRABLE EXECUTION GATE |
| **Authority** | SUPRA Constitution — Article 2 |
| **Location** | `SUPRA_RUNTIME/Services/canonicalization/` |

---

## 1. MISSION

The Canonicalization Engine discovers the truth canonical of SUPRA.
Its mission is NOT to delete duplicates.
Its mission is to prove the canonical representation and prepare safe migrations.

Pipeline:
```
DETECT → GROUP → COMPARE → CANONICALIZE → LINK → MIGRATE → PROVE
```

No automatic deletion.
Every fusion must be proved.

---

## 2. ARCHITECTURE

### 2.1 Directory Structure

```
SUPRA_RUNTIME/Services/canonicalization/
├── Core/
│   ├── CanonicalModels.swift              — All CANNoNICO primitives & data models
│   ├── CanonicalizationEngine.swift        — Main orchestrator (7-phrase pipeline)
│   ├── CanonicalKnowledgeGraph.swift       — Knowledge graph manager
│   ├── CanonicalProofEngine.swift          — PROVE phase implementation
│   └── CanonicalMigrationEngine.swift      — MIGRATE phase implementation
├── Pipeline/
│   ├── DetectPhase.swift                   — DETECT duplicates
│   ├── GroupPhase.swift                    — GROUP semantically
│   ├── ComparePhase.swift                  — COMPARE equivalence
│   ├── CanonizePhase.swift                 — CANONICALIZE truth
│   └── LinkPhase.swift                     — LINK to knowledge graph
├── TUV5/
│   └── TUV5RuntimeCompiler.swift           — Evolved TUV5 (compacts Runtime knowledge)
├── CANNoNICO/
│   └── CANNoNICO_Runtime.swift               — CANNoNICO unique internal representation
├── NAMBROCAHORA/
│   └── NAMBROCAHORA_Runtime.swift          — NAMBROCAHORA unique temporal reference
├── KnowledgeGraph/
│   └── CanonicalKnowledgeGraph.swift       — Knowledge graph manager (standalone)
└── Documentation/
    └── CANONICALIZATION_ENGINE_SPEC.md     — This document
```

### 2.2 Layer Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    CANONICALIZATION ENGINE                  │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ 7-PHASE PIPELINE                                     │  │
│  │                                                        │  │
│  │  DETECT  →  GROUP  →  COMPARE  →  CANONICALIZE      │  │
│  │                                                ↓       │  │
│  │  LINK  →  MIGRATE  →  PROVE                      │  │
│  │                                                        │  │
│  └─────────────────────────────────────────────────────┘  │
│                              │                               │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ CANONICAL KNOWLEDGE GRAPH                            │  │
│  │  Nodes: CGNode (CAN_ID, label, type, primitive,     │  │
│  │         responsibility, capability, proof,           │  │
│  │         nambrohoraRef, properties, relations)        │  │
│  │  Edges: CGEdge (source, target, relationType,       │  │
│  │         weight, evidence, tick)                      │  │
│  └─────────────────────────────────────────────────────┘  │
│                              │                               │
│  ┌──────────────┐  ┌──────────────────┐  ┌─────────────┐ │
│  │  TUV5 Runtime │  │  CANNoNICO Core  │  │ NAMBROCAHORA │ │
│  │ Compiler      │  │  Runtime         │  │ Time Ref     │ │
│  └──────────────┘  └──────────────────┘  └─────────────┘ │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ PROJECTION ENGINE                                     │  │
│  │  CANNoNICO → Swift / JSON / Bash / Markdown / UI/API │  │
│  └─────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## 3. PHASE SPECIFICATIONS

### 3.1 DETECT Phase

**Purpose**: Analyze the entire repository and identify all artifacts.

**Input**: Repository path
**Output**: `[ArtifactReference]` — enriched with semantic fingerprints and CAN_IDs

**What it detects**:
- Swift source files (structs, enums, classes, protocols)
- Bash orchestration scripts
- JSON data files (registries, manifests, configs)
- YAML configuration files
- Markdown documentation
- SQL schema definitions

**Key method**: `discoverArtifacts(at:)` — recursive file enumeration with semantic fingerprinting

**Fingerprint**: Each artifact gets a `semanticFingerprint` computed from its type, source category, and name. This is the basis for all duplicate detection.

**CAN_ID Assignment**: Every artifact gets a provisional CAN_ID of the form `can:<type>:<hash>`.

### 3.2 GROUP Phase

**Purpose**: Cluster semantically related artifacts.

**Input**: `[ArtifactReference]`
**Output**: `[DuplicateCluster]` — clusters of potentially duplicate or equivalent artifacts

**Clustering strategy**:
1. Primary clustering by `semanticFingerprint` (exact match = identical content)
2. Secondary clustering by name similarity (Jaccard index on tokenized names)
3. Tertiary clustering by source category alignment

**Cluster types**:
- `duplicateConcept` — Same conceptual entity in different files
- `duplicateResponsibility` — Same responsibility implemented in multiple places
- `duplicateRuntimeService` — Same service exposed in multiple forms
- `duplicateModel` — Same model defined in different formats
- `duplicateDocumentation` — Same documentation in different formats
- `duplicateSwiftStructure` — Same Swift type defined multiple times
- `duplicateBashScript` — Same script in different locations
- `duplicateJSON` — Same JSON structure in different files
- `duplicateYAML` — Same YAML config in different files
- `duplicateManifest` — Same manifest declared multiple times
- `duplicateRegistry` — Same registry entry in multiple places
- `equivalentConcept` — Semantically equivalent but not identical
- `semanticallyRelated` — Related but not equivalent

**Confidence scoring**: Weighted combination of name similarity (0.6), type alignment (0.3), and source overlap (0.4).

### 3.3 COMPARE Phase

**Purpose**: Perform detailed semantic comparison within each cluster.

**Input**: `[DuplicateCluster]`
**Output**: `[ComparativeAnalysis]` — detailed comparison results with recommendations

**Comparison dimensions**:
1. **Name similarity** — Jaccard index on tokenized artifact names
2. **Content similarity** — Checksum comparison (exact match = 1.0)
3. **Structural similarity** — ARTIFACT_TYPE alignment
4. **Semantic overlap** — Fingerprint component overlap

**Overall score**: Weighted: semantic (0.4) + structural (0.3) + overlap (0.3)

**Recommendations**:
- `canonicalize` (confidence ≥ 0.90) — One is canonical, the rest are duplicates
- `merge` (confidence ≥ 0.75) — All are variants that should be merged
- `review` (confidence ≥ 0.50) — Requires human judgment
- `keepSeparate` (confidence < 0.50) — They are genuinely different

### 3.4 CANONICALIZE Phase

**Purpose**: Prove which artifact is the canonical truth for each cluster.

**Input**: `[ComparativeAnalysis]`
**Output**: `[CanonicalEntity]` — the canonical representation for each concept

**Canonicalization rules**:
1. The artifact with the highest confidence becomes the canonical source
2. All other artifacts in the cluster are marked as duplicates or variants
3. The canonical entity receives a definitive CAN_ID
4. All source artifacts are linked to the canonical entity via CAN_RELATION

**Each CanonicalEntity contains**:
- `canId`: The definitive CAN_ID
- `canType`: The CAN_TYPE of the entity
- `canName`: Human-readable name
- `canSemantics`: All semantic properties discovered
- `canResponsibilities`: The responsibilities this entity fulfills
- `canCapabilities`: CAN_IDs of capabilities it exposes
- `canRelations`: Links to other canonical entities
- `canState`: Current state (active, canonical, etc.)
- `canTick`: NAMBROCAHORA tick of canonization
- `canArtifacts`: All source artifacts (including duplicates)
- `canEvidence`: Proof of canonization
- `canProjections`: Formats this entity projects to
- `canConfidence`: Confidence in the canonization
- `canValidated`: Whether the canonization passed validation

### 3.5 LINK Phase

**Purpose**: Connect canonical entities into the Canonical Knowledge Graph.

**Input**: `[CanonicalEntity]`
**Output**: `[CGNode]` — nodes connected by `CGEdge` relationships

**Graph construction**:
1. Each canonical entity becomes a `CGNode`
2. Each `CAN_RELATION_REF` on an entity becomes a `CGEdge`
3. New edges are discovered between related nodes based on semantic similarity
4. Each node is linked to its primitive (P1-P14)
5. Each node is linked to its NAMBROCAHORA tick
6. Each node is linked to its proof chain

**Graph query capabilities**:
- `node(for:)` — Look up by CAN_ID
- `edges(from:)` / `edges(to:)` — Traverse relationships
- `relatedNodes(for:)` — Find all connected nodes
- `queryByPrimitive(_:)` — Find all nodes using a specific primitive
- `queryByType(_:)` — Find all nodes of a given type
- `queryByResponsibility(_:)` — Find nodes by responsibility keyword
- `queryByCapability(_:)` — Find nodes by capability
- `queryByProof(_:)` — Find nodes that use a specific proof
- `queryByNambrohoraRef(_:)` — Find nodes at a specific temporal reference
- `findDuplicates()` — Discover groups of semantically equivalent nodes
- `findEquivalentConcepts(concept:)` — Search for concepts by name
- `findProjections(for:)` — Find projection formats for a node
- `findMigrationImpact(for:)` — Assess impact of modifying a node

### 3.6 MIGRATE Phase

**Purpose**: Plan safe migrations from the current state to the canonical state.

**Input**: `[CGNode]`
**Output**: `MigrationPlan` — step-by-step migration with risk assessment

**Migration phases**:
1. **Prepare** — Map and catalog the migration target
2. **Validate** — Verify preconditions are met
3. **Execute** — Perform the migration step
4. **Verify** — Confirm the migration succeeded
5. **Rollback** — Define how to revert if needed

**Each MigrationStep includes**:
- `stepId`: Unique identifier
- `phase`: Current migration phase
- `action`: Description of what to do
- `target`: The CAN_ID being migrated
- `evidence`: Proof supporting this step
- `riskLevel`: CAN_SEVERITY (critical, error, warning, info)
- `reversible`: Whether this step can be undone
- `prerequisiteTick`: NAMBROCAHORA tick that must be reached first
- `projectionImpact`: List of external formats affected

**Key principle**: No deletion without a proven replacement and a rollback plan.

### 3.7 PROVE Phase

**Purpose**: Validate the entire canonization with evidence chains.

**Input**: `[CGNode]` (linked graph), `MigrationPlan`
**Output**: `ProofResult` — validation results with overall verdict

**Validations performed**:
1. **Node count** — All entities are registered
2. **Consistency** — Knowledge graph has no contradictions
3. **Traceability** — Every node traces to a CANNoNICO primitive
4. **Completeness** — All entities have a canonical representation
5. **Rollback** — Migration plan is reversible
6. **Projections** — All projections are accounted for

**Overall verdict**:
- `pass` — All validations passed
- `retry` — Some non-critical validations failed
- `fail` — Critical validations failed

---

## 4. TUV5 EVOLUTION

### 4.1 What Changed

TUV5 now compiles not just conversations, but ALL Runtime knowledge:
- Swift source code
- Bash scripts
- JSON/YAML configs
- Markdown documentation
- Runtime services
- Registries
- Manifests
- Graphs
- Runtime events
- Memories

### 4.2 TUV5 Runtime Compiler

`TUV5RuntimeCompiler` provides:
- `compile(repositoryPath:)` — Full compilation pipeline
- `compactKnowledge(from:)` — Compress entities into a single CAN_KNOWLEDGE

### 4.3 Compact Knowledge Output

The `compactKnowledge` method produces a single `CAN_KNOWLEDGE` entity representing the entire Runtime knowledge base. This is the minimal representation from which the full Runtime can be reconstructed.

---

## 5. CANNoNICO AS UNIQUE INTERNAL REPRESENTATION

### 5.1 CANNoNICO Runtime

`CANNoNICO_Runtime` provides the Runtime with a unified interface to all CANNoNICO primitives:

| Core | Responsibility |
|------|---------------|
| IdentityCore | CAN_ID management, entity registration |
| KnowledgeCore | CAN_KNOWLEDGE storage and retrieval |
| RelationCore | CAN_RELATION_REF management |
| CapabilityCore | CAN_CAPABILITY registration |
| EventCore | CAN_EVENT recording |
| DecisionCore | CAN_DECISION storage |
| StateCore | CAN_STATE management |
| ConstraintCore | CAN_CONSTRAINT validation |
| TemporalCore | NAMBROCAHORA tick tracking |

### 5.2 Runtime Rules

1. The Runtime NEVER stores raw Swift code as knowledge
2. The Runtime NEVER uses `Date()` directly — all temporal references use NAMBROCAHORA ticks
3. The Runtime NEVER references JSON/YAML/Markdown as authoritative knowledge sources
4. The Runtime NEVER creates new representation formats beyond CANNoNICO projections
5. Every Runtime operation goes through the Canonicalization Engine

---

## 6. NAMBROCAHORA AS UNIQUE TEMPORAL REFERENCE

### 6.1 NAMBROCAHORA Runtime

`NAMBROCAHORA_Runtime` provides:

| Method | Description |
|--------|-------------|
| `advance()` | Increments the tick counter and returns the new value |
| `now()` | Returns the current tick |
| `elapsed(from:)` | Returns ticks since the given tick |
| `compare(_:_:)` | Compares two ticks |
| `isBefore(_:_:)` | Checks temporal ordering |
| `isAfter(_:_:)` | Checks temporal ordering |
| `format(_:)` | Projects tick to ISO8601 string |
| `parse(_:)` | Converts ISO8601 string back to tick |
| `validateTick(_:)` | Validates tick is non-negative |
| `reset()` | Resets tick counter (for testing only) |

### 6.2 Temporal Rules

1. All timestamps in the Runtime are NAMBROCAHORA ticks (Int64)
2. Machine time (Date()) is converted to NAMBROCAHORA ticks by TUV5
3. The Runtime never stores Date objects — only ticks
4. ISO8601 strings are projections generated by the Projection Engine
5. Tick 0 is the initialization point of the Runtime

---

## 7. CANONICAL KNOWLEDGE GRAPH CAPABILITIES

The Canonical Knowledge Graph enables the Runtime to answer:

| Question | Method |
|----------|--------|
| Why does this component exist? | Trace its CAN_ID → CAN_KNOWLEDGE → source artifacts |
| Does an equivalent concept already exist? | `findEquivalentConcepts(concept:)` |
| What is the canonical concept for this idea? | Look up by semanticFingerprint or CAN_ID |
| What projections does it generate? | `findProjections(for:)` |
| Which components are redundant? | `findDuplicates()` |
| What migration is safe? | `MigrationPlan` with risk assessment |
| What is the impact of deletion? | `findMigrationImpact(for:)` |
| What is the impact of fusion? | `computeImpact(of:)` |

---

## 8. INTEGRATION WITH EXISTING FOUNDATIONS

### 8.1 TUV5 × Canonicalization Engine

```
TUV5 (existing KOMPILER)
  │
  ├──→ DETECT discovers all source artifacts
  ├──→ GROUP clusters them semantically
  ├──→ COMPARE analyzes equivalence
  ├──→ CANONICALIZE proves the canonical truth
  ├──→ LINK builds the Knowledge Graph
  ├──→ MIGRATE plans safe transitions
  └──→ PROVE validates the entire process
```

### 8.2 CANNoNICO × Canonicalization Engine

```
CANNoNICO (existing RUNTIME REPRESENTATION)
  │
  ├──→ CANNoNICO_Runtime stores all canonical entities
  ├──→ Each entity is a CanonicalEntity with CAN_ID + CAN_KNOWLEDGE
  ├──→ Relations between entities are CGEdges
  └──→ The Runtime queries only via the Knowledge Graph
```

### 8.3 NAMBROCAHORA × Canonicalization Engine

```
NAMBROCAHORA (existing TEMPORAL REFERENCENCE)
  │
  ├──→ NAMBROCAHORA_Runtime provides tick management
  ├──→ Every canonization event gets a tick
  ├──→ Every migration step has a prerequisite tick
  ├──→ Every proof entry has a tick
  └──→ Temporal ordering is guaranteed by monotone ticks
```

---

## 9. VALIDATION CRITERIA

The Canonicalization Engine is considered operational when:

1. ✅ It analyzes the repository and discovers all artifacts
2. ✅ It clusters duplicates and semantically equivalent concepts
3. ✅ It compares artifacts across multiple dimensions
4. ✅ It canonizes — proving which is the canonical truth
5. ✅ It links all entities into a queryable Knowledge Graph
6. ✅ It plans safe, reversible migrations
7. ✅ It validates the entire process with evidence chains
8. ✅ It can answer the Runtime questions (Why? Equivalent? Canonical? Projections? Redundant? Migration? Impact?)

---

## 10. PRINCIPLES

1. **No automatic deletion** — The Engine never removes anything without a proved replacement
2. **Every fusion is demonstrated** — If two concepts are merged, the proof is recorded
3. **Knowledge is the source of truth** — Not files, not Swift code, not JSON
4. **Code is a projection** — Swift source is generated from CANNoNICO, not the other way around
5. **Temporal references are canonical** — NAMBROCAHORA ticks, never Date()
6. **Every entity is traceable** — CAN_ID → TUV5 source → NAMBROCAHORA tick → CANNoNICO primitive

---

*Canonicalization Engine V1 — SUPRA ULTIMATE CONSOLIDATED*
*Execution Gate: 2026-07-29*
*Authority: SUPRA Constitution — Article 2*