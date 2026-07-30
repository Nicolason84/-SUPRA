# SUPRA Unified Ontology — Specification V1

## Status: SPECIFICATION — SUPRA ULTIMATE CONSOLIDATED PHASE 1

| Propriété | Valeur |
|-----------|--------|
| **Version** | SUPRA_UNIFIED_ONTOLOGY_V1 |
| **Date** | 2026-07-29 |
| **Autorité** | SUPRA Knowledge Compiler — Ontology Engine |
| **Préséance** | Ontologie unique — supplante tout mapping ontologique antérieur |
| **Héritage** | CANONICO_ONTOLOGY_V3 (absorbée comme corpus source) |

---

## 1. UNIFICATION PRINCIPLE

Every concept from any source maps to exactly one position in the Unified Ontology.

The Unified Ontology is the **single conceptual schema** for all SUPRA knowledge.

No concept exists outside the ontology.

---

## 2. ONTOLOGY ARCHITECTURE

```
TOP-LEVEL CATEGORIES
  │
  ├── ENTITY ────────────── Concrete and abstract things
  │   ├── SystemEntity
  │   ├── AgentEntity
  │   ├── ResourceEntity
  │   ├── MemoryEntity
  │   ├── ProcessEntity
  │   ├── ConceptEntity
  │   └── RelationEntity
  │
  ├── RELATION ──────────── Connections between entities
  │   ├── Structural
  │   ├── Dependency
  │   ├── Semantic
  │   ├── Temporal
  │   ├── Evidential
  │   └── Cognitive
  │
  ├── CONSTRAINT ────────── Rules and boundaries
  │   ├── StructuralConstraint
  │   ├── SemanticConstraint
  │   ├── TemporalConstraint
  │   ├── TrustConstraint
  │   ├── GovernanceConstraint
  │   └── EvidenceConstraint
  │
  ├── EVIDENCE ──────────── Proofs, attestations, chains
  │   ├── ProofChain
  │   ├── Attestation
  │   ├── Witness
  │   └── TrustAnchor
  │
  ├── PATTERN ───────────── Reusable structural templates
  │   ├── Archetype
  │   ├── DesignPattern
  │   ├── ProcessPattern
  │   ├── CommunicationPattern
  │   └── KnowledgePattern
  │
  ├── EVENT ─────────────── Immutable occurrence records
  │   ├── CreationEvent
  │   ├── MutationEvent
  │   ├── ValidationEvent
  │   └── CompilationEvent
  │
  ├── PROJECTION ────────── Derived read-only views
  │   ├── KnowledgeProjection
  │   ├── ConstraintProjection
  │   ├── ExecutiveProjection
  │   └── DomainProjection
  │
  └── VALUE ─────────────── Scalar and structured values
      ├── Identity
      ├── Timestamp
      ├── Signature
      ├── TrustScore
      ├── Confidence
      └── Metric
```

---

## 3. CANONICAL CONCEPT REGISTRY

### 3.1 Entity Concepts

| ID | Name | Definition | Source Heritage |
|----|------|------------|-----------------|
| C-001 | Entity | Abstract base for all things | UGIS, ProofGraph, INPI |
| C-002 | Node | Instantiable entity with identity, type, and lifecycle | UGIS Node, ProofGraph Vertex, INPI Asset |
| C-003 | Edge | Directed connection between two Nodes | UGIS Edge, ProofGraph Edge |
| C-004 | SystemEntity | Node representing a system component | SUPRA Executive |
| C-005 | AgentEntity | Node with agency, capable of action | SUPRA Agent, ProofGraph Witness |
| C-006 | ResourceEntity | Node representing a consumable asset | INPI Asset, SUPRA Resource |
| C-007 | MemoryEntity | Node representing persisted state | SUPRA Memory |
| C-008 | ProcessEntity | Node representing a process instance | SUPRA Mission, UGIS Pattern |
| C-009 | ConceptEntity | Node representing an abstract concept | CANONICO Concept |
| C-010 | RelationEntity | Abstract base for relation types | UGIS Edge |
| C-011 | Identity | Unique identifier structure | UGIS Identity, ProofGraph Vertex ID |
| C-012 | Signature | Cryptographic or logical proof marker | ProofGraph ChainSignature |

### 3.2 Relation Concepts

| ID | Name | Definition | Source Heritage |
|----|------|------------|-----------------|
| R-001 | DEPENDS_ON | A depends on B for validity | UGIS, ProofGraph, SUPRA |
| R-002 | CONTAINS | A contains B as component | UGIS Composition |
| R-003 | EQUIVALENT_TO | A and B are semantically identical | CANONICO Equivalence |
| R-004 | CLOSE_TO | A and B are semantically related | CANONICO Equivalence |
| R-005 | CONTRADICTS | A and B are logically contradictory | CANONICO Conflict |
| R-006 | GENERALIZES | A is a generalization of B | UGIS Inheritance |
| R-007 | SPECIALIZES | A is a specialization of B | UGIS Inheritance |
| R-008 | PRECEDES | A occurs before B in time | Temporal |
| R-009 | PROVES | A provides evidence for B | ProofGraph, Evidence |
| R-010 | INSTANTIATES | A is an instance of pattern B | UGIS Pattern |
| R-011 | COMPOSES | A is a component of B | UGIS Composition |
| R-012 | CONSTRAINS | A imposes a constraint on B | CANONICO Constraint |
| R-013 | REQUIRES | A requires B for operation | Dependency |
| R-014 | GENERATES | A generates B as output | Provenance |
| R-015 | OBSERVES | A observes/monitors B | Runtime |
| R-016 | GOVERNED_BY | A is governed by rule B | Governance |
| R-017 | MAPS_TO | Cross-ontology mapping | CANONICO Mapping |
| R-018 | VERIFIED_BY | A is verified by evidence B | ProofGraph |
| R-019 | DERIVED_FROM | A is derived from source B | Provenance |
| R-020 | PROJECTS_TO | A projects to view B | Projection |

### 3.3 Constraint Concepts

| ID | Name | Definition | Source Heritage |
|----|------|------------|-----------------|
| CR-001 | StructuralConstraint | Constraint on graph topology | CANONICO |
| CR-002 | SemanticConstraint | Constraint on meaning consistency | CANONICO V3 |
| CR-003 | TemporalConstraint | Constraint on temporal ordering | CANONICO |
| CR-004 | TrustConstraint | Constraint on trust scores | CANONICO |
| CR-005 | GovernanceConstraint | Constraint on authorization | CANONICO V3 |
| CR-006 | EvidenceConstraint | Constraint on proof completeness | ProofGraph |
| CR-007 | CardinalityConstraint | Constraint on relation multiplicity | UGIS, CANONICO |
| CR-008 | LifecycleConstraint | Constraint on state transitions | UGIS, CANONICO |
| CR-009 | IdentityConstraint | Constraint on identity rules | UGIS, CANONICO |
| CR-010 | PatternConstraint | Constraint defined by pattern | CANONICO |
| CR-011 | InvariantConstraint | Constraint that never changes | UGIS, CANONICO |

### 3.4 Evidence Concepts

| ID | Name | Definition | Source Heritage |
|----|------|------------|-----------------|
| E-001 | Evidence | Abstract proof or attestation | CANONICO, ProofGraph |
| E-002 | ProofChain | Ordered sequence of proof steps | ProofGraph |
| E-003 | Attestation | Signed statement of fact | INPI Certification |
| E-004 | Witness | Entity that provides testimony | ProofGraph |
| E-005 | TrustAnchor | Root of trust chain | ProofGraph |
| E-006 | Verification | Result of validation process | UGIS Validation |
| E-007 | ChainLink | Single step in a proof chain | ProofGraph |
| E-008 | Axiom | Foundational assumption | ProofGraph |

### 3.5 Pattern Concepts

| ID | Name | Definition | Source Heritage |
|----|------|------------|-----------------|
| P-001 | Archetype | Most general pattern category | UGIS, CANONICO |
| P-002 | DesignPattern | Reusable structural pattern | SUPRA, UGIS |
| P-003 | ProcessPattern | Reusable process template | SUPRA Mission |
| P-004 | CommunicationPattern | Message/interaction pattern | SUPRA Agent |
| P-005 | KnowledgePattern | Knowledge structure pattern | CANONICO |
| P-006 | ProofPattern | Proof structure template | ProofGraph |

### 3.6 Event Concepts

| ID | Name | Definition | Source Heritage |
|----|------|------------|-----------------|
| EV-001 | Event | Immutable occurrence record | UGIS Event |
| EV-002 | CreationEvent | Entity creation | UGIS Lifecycle |
| EV-003 | MutationEvent | Entity state change | UGIS Lifecycle |
| EV-004 | ValidationEvent | Validation occurrence | CANONICO Validation |
| EV-005 | CompilationEvent | Compilation occurrence | Knowledge Compiler |

### 3.7 Projection Concepts

| ID | Name | Definition | Source Heritage |
|----|------|------------|-----------------|
| PR-001 | Projection | Derived read-only view | UGIS Projection |
| PR-002 | KnowledgeProjection | Concept-focused projection | CANONICO |
| PR-003 | ConstraintProjection | Constraint-focused projection | CANONICO |
| PR-004 | ExecutiveProjection | Decision-focused projection | SUPRA Executive |
| PR-005 | DomainProjection | Domain-specific projection | All |

### 3.8 Value Concepts

| ID | Name | Definition | Source Heritage |
|----|------|------------|-----------------|
| V-001 | Identity | Unique identifier | UGIS, SUPRA |
| V-002 | Timestamp | Temporal coordinate | Universal |
| V-003 | Signature | Cryptographic or logical marker | ProofGraph |
| V-004 | TrustScore | Numeric trust value | ProofGraph, CANONICO |
| V-005 | Confidence | Extraction/reasoning confidence | CANONICO |
| V-006 | Metric | Measurable system value | SUPRA Metrics |
| V-007 | Hash | Content fingerprint | Universal |

---

## 4. CROSS-CORPUS EQUIVALENCE TABLE

| Unified Concept | UGIS | ProofGraph | INPI | SUPRA |
|----------------|------|------------|------|-------|
| Node (C-002) | Node | Vertex | Asset | Entity |
| Edge (C-003) | Edge | Edge | — | Relation |
| Identity (V-001) | Identity | VertexID | Reference | ID |
| Timestamp (V-002) | Timestamp | Time | Date | Timestamp |
| Signature (V-003) | — | ChainSignature | — | Signature |
| Evidence (E-001) | Evidence | Proof | Certification | Evidence |
| Constraint (CR-*) | Constraint | Axiom | IPRight | Rule |
| TrustAnchor (E-005) | — | TrustAnchor | — | TrustSource |
| Agent (C-005) | Agent | Witness | Holder | Agent |
| Pattern (P-*) | Pattern | ProofTemplate | — | Pattern |
| Projection (PR-*) | Projection | View | — | View |
| Event (EV-*) | Event | ProofEvent | Deposit | Event |
| Lifecycle | Lifecycle | ProofState | LegalStatus | Lifecycle |

---

## 5. ONTOLOGY HIERARCHY (FULL)

```
Entity (abstract)
├── Node (instantiable)
│   ├── SystemEntity
│   │   ├── RuntimeSystem
│   │   ├── StorageSystem
│   │   ├── NetworkSystem
│   │   └── CompilerSystem
│   ├── AgentEntity
│   │   ├── HumanAgent
│   │   ├── SoftwareAgent
│   │   │   ├── Router
│   │   │   ├── Builder
│   │   │   ├── Auditor
│   │   │   └── ...
│   │   └── Witness (ProofGraph)
│   ├── ResourceEntity
│   │   ├── IntellectualAsset (INPI)
│   │   ├── ComputeResource
│   │   ├── StorageResource
│   │   └── DataResource
│   ├── MemoryEntity
│   │   ├── Frame
│   │   ├── Snapshot
│   │   └── Log
│   ├── ProcessEntity
│   │   ├── Mission
│   │   ├── Compilation
│   │   ├── Validation
│   │   └── Execution
│   ├── ConceptEntity
│   │   ├── Principle
│   │   ├── Hypothesis
│   │   ├── Invariant
│   │   └── Rule
│   └── RelationEntity (abstract)
├── Edge (instantiable)
│   ├── StructuralEdge
│   │   ├── CONTAINS
│   │   ├── COMPOSES
│   │   └── INSTANTIATES
│   ├── DependencyEdge
│   │   ├── DEPENDS_ON
│   │   ├── REQUIRES
│   │   └── DERIVED_FROM
│   ├── SemanticEdge
│   │   ├── EQUIVALENT_TO
│   │   ├── CLOSE_TO
│   │   ├── CONTRADICTS
│   │   ├── GENERALIZES
│   │   └── SPECIALIZES
│   ├── TemporalEdge
│   │   ├── PRECEDES
│   │   └── FOLLOWS
│   ├── EvidentialEdge
│   │   ├── PROVES
│   │   ├── VERIFIED_BY
│   │   └── SUPPORTS
│   └── CognitiveEdge
│       ├── OBSERVES
│       └── GOVERNS
├── Event (immutable)
│   ├── CreationEvent
│   ├── MutationEvent
│   ├── ValidationEvent
│   └── CompilationEvent
├── Constraint
│   ├── StructuralConstraint
│   ├── SemanticConstraint
│   ├── TemporalConstraint
│   ├── TrustConstraint
│   ├── GovernanceConstraint
│   ├── EvidenceConstraint
│   ├── CardinalityConstraint
│   ├── LifecycleConstraint
│   ├── IdentityConstraint
│   ├── PatternConstraint
│   └── InvariantConstraint
├── Evidence
│   ├── ProofChain
│   ├── Attestation
│   ├── Witness
│   └── TrustAnchor
├── Pattern
│   ├── Archetype
│   ├── DesignPattern
│   ├── ProcessPattern
│   ├── CommunicationPattern
│   ├── KnowledgePattern
│   └── ProofPattern
├── Projection
│   ├── KnowledgeProjection
│   ├── ConstraintProjection
│   ├── ExecutiveProjection
│   └── DomainProjection
└── Value
    ├── Identity
    ├── Timestamp
    ├── Signature
    ├── TrustScore
    ├── Confidence
    ├── Metric
    └── Hash
```

---

## 6. ONTOLOGY OPERATIONS

### 6.1 Alignment

```json
{
  "operation": "align",
  "input": {"concept": "extracted concept", "source": "corpus reference"},
  "output": {
    "canonicalConcept": "C-002",
    "confidence": 0.95,
    "mappingType": "EQUIVALENT_TO | CLOSE_TO | GENERALIZES | SPECIALIZES | NEW",
    "conflicts": []
  }
}
```

### 6.2 Validation

```json
{
  "operation": "validate",
  "input": {"conceptId": "C-002", "properties": {}},
  "checks": {
    "definitionCompleteness": "PASS",
    "hierarchyPosition": "PASS",
    "relationConsistency": "PASS",
    "sourceTraceability": "PASS"
  }
}
```

### 6.3 Extension

```json
{
  "operation": "extend",
  "input": {"newConcept": {"name": "...", "definition": "...", "parentId": "C-002"}},
  "validation": {
    "noDuplicate": "PASS",
    "parentExists": "PASS",
    "hierarchyValid": "PASS"
  },
  "output": "C-069"
}
```

---

## 7. ONTOLOGY GOVERNANCE

| Rule | Description |
|------|-------------|
| Monotonicity | Adding new concepts never removes existing ones |
| Traceability | Every concept maps to at least one source document |
| Uniqueness | No two concepts share the same canonical name |
| Hierarchy | Every concept (except root) has exactly one parent |
| No Orphans | Every concept is reachable from root |
| Relation Validity | Every relation connects registered concept types |
| Conflict Transparency | All unresolvable conflicts are documented |
| Versioned | Every change produces a new ontology version |
