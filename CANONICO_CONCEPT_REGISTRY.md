# CANONICO Concept Registry — Canonical Concept Catalog

## Status: SPECIFICATION V3 — CONCEPT REGISTRY

---

## 1. CONCEPT REGISTRY OVERVIEW

The Concept Registry is the **canonical catalog** of every concept extracted from the combined corpus (UGIS V1, ProofGraph, INPI, annexes, executive reports). Each concept has a unique identity, a canonical definition reconciled across all sources, and full traceability to origin documents.

### 1.1 Registry Structure

```
CanonicalConcept {
  id: Identity                    [can:cpt:<hash>]
  name: String                    [canonical name]
  type: ConceptType               [ENTITY | PRINCIPLE | RELATION | ...]
  definition: String              [cross-document reconciled definition]
  aliases: [String]               [alternative names per document]
  sourceDocuments: [{
    document: DocumentRef
    definition: String            [original definition in source]
    location: String              [section/paragraph reference]
    confidence: Float
  }]
  relations: [{
    type: RelationType
    target: Identity
    strength: Float
  }]
  status: ConceptStatus           [STABLE | PROVISIONAL | CONFLICTED]
  version: String
}
```

---

## 2. ENTITY CONCEPTS

### 2.1 Core Graph Entities

| ID | Name | Definition | Sources | Status |
|----|------|------------|---------|--------|
| C-001 | Graph | The single authoritative representation of all entities, relationships, and state | UGIS Law 1, CANONICO_STANDARD | STABLE |
| C-002 | Node | The atomic unit of the Graph; any entity concrete or abstract | UGIS Law 2, Node Model, Edge Model | STABLE |
| C-003 | Edge | The atomic unit of interaction between two Nodes | UGIS Law 3, Edge Model | STABLE |
| C-004 | Pattern | A reusable behavioral template for Nodes | UGIS Law 5, Pattern Library | STABLE |
| C-005 | Archetype | The most abstract classification of a Node | Archetype Library | STABLE |
| C-006 | Projection | A derived read-only view of the Graph in a specific format | UGIS Law 4, Projection Model | STABLE |
| C-007 | Identity | Immutable content-addressed identifier following can:type:hash format | ID Standard | STABLE |
| C-008 | Constraint | A rule defining valid states, relations, or behaviors | Constraint Model, Constraint Library | STABLE |
| C-009 | Event | An immutable record of a state change in the Graph | Validation Pipeline, Event Model | STABLE |
| C-010 | Evidence | A proof, attestation, or supporting data for a claim | Evidence Engine, ProofGraph | STABLE |

### 2.2 ProofGraph Entities

| ID | Name | Definition | Sources | Status |
|----|------|------------|---------|--------|
| C-011 | ProofGraph Vertex | A node in the ProofGraph system, equivalent to CANONICO Node | ProofGraph corpus | PROVISIONAL |
| C-012 | ProofGraph Edge | A directed relationship in ProofGraph, equivalent to CANONICO Edge | ProofGraph corpus | PROVISIONAL |
| C-013 | Proof Chain | An ordered sequence of ProofGraph Edges establishing validity | ProofGraph annexes | STABLE |
| C-014 | Trust Anchor | A root of trust from which all trust chains originate | ProofGraph, Evidence Model | STABLE |
| C-015 | Witness | An independent verifier of a proof step | ProofGraph, INPI | PROVISIONAL |
| C-016 | Proof State | The validity state of a proof (PROVEN | UNPROVEN | CONTESTED) | ProofGraph | STABLE |

### 2.3 INPI Entities

| ID | Name | Definition | Sources | Status |
|----|------|------------|---------|--------|
| C-017 | Intellectual Asset | A legally protected or protectable intellectual creation | INPI dossiers | PROVISIONAL |
| C-018 | Deposit | A formal registration of an intellectual asset with INPI | INPI dossiers | STABLE |
| C-019 | Holder | The legal entity holding rights to an intellectual asset | INPI dossiers | STABLE |
| C-020 | Certification | A formal attestation of compliance or validity | INPI, Governance Model | PROVISIONAL |

### 2.4 SUPRA Entities

| ID | Name | Definition | Sources | Status |
|----|------|------------|---------|--------|
| C-021 | Agent | An autonomous entity that perceives, decides, and acts | SUPRA Agent Registry, Archetype Library | STABLE |
| C-022 | Mission | A goal-directed process with defined objective | Mission Model, Process Archetype | STABLE |
| C-023 | Memory | A persistent record of past states, interactions, or knowledge | Memory Archetype | STABLE |
| C-024 | Twin | A digital representation synchronized with a physical entity | Twin model, Digital Twin framework | PROVISIONAL |
| C-025 | Inconsistency | A measurable deviation from valid state | Inconsistency Model | STABLE |
| C-026 | Violation | A constraint that is not satisfied | Coherence Engine | STABLE |

---

## 3. PRINCIPLE CONCEPTS

### 3.1 Foundational Principles

| ID | Name | Statement | Sources | Status |
|----|------|-----------|---------|--------|
| P-001 | Graph Authority | The Graph is the single source of truth; no dual representation permitted | UGIS Law 1 | INVARIANT |
| P-002 | Universal Node | Every entity is represented as a Node | UGIS Law 2 | INVARIANT |
| P-003 | Universal Edge | Every interaction is represented as an Edge | UGIS Law 3 | INVARIANT |
| P-004 | Projection Derivative | All external representations are read-only projections | UGIS Law 4 | INVARIANT |
| P-005 | Pattern Primacy | Behavior is determined by Pattern, never by implementation | UGIS Law 5 | INVARIANT |
| P-006 | Identity Immutability | Identity never changes after creation | ID Standard | INVARIANT |
| P-007 | Content Addressing | Identity is derived from content at creation time | ID Standard | INVARIANT |
| P-008 | Temporal Completeness | Every Edge carries a timestamp; every change generates an Event | CANONICO_STANDARD | INVARIANT |
| P-009 | Coherence Emergence | Validity is an emergent property, not a stored attribute | Coherence Engine V2 | INVARIANT |
| P-010 | Minimal Intervention | The best repair is the one with the fewest changes | Repair Engine | GUIDELINE |

### 3.2 ProofGraph Principles

| ID | Name | Statement | Sources | Status |
|----|------|-----------|---------|--------|
| P-011 | Chain Completeness | Every proof must form a complete chain from axioms to conclusion | ProofGraph | INVARIANT |
| P-012 | Trust Transitivity | Trust propagates along proof chains but decays with distance | ProofGraph | CONSTRAINT |
| P-013 | Evidence Verifiability | All evidence must be independently verifiable | ProofGraph, INPI | INVARIANT |
| P-014 | Non-Repudiation | Proof steps cannot be denied after commitment | ProofGraph | INVARIANT |
| P-015 | Minimal Proof | The simplest valid proof is preferred | ProofGraph | GUIDELINE |

### 3.3 Coherence Principles

| ID | Name | Statement | Sources | Status |
|----|------|-----------|---------|--------|
| P-016 | Deterministic Validation | Same state + same constraints = same validation result | Validation Model | INVARIANT |
| P-017 | Exhaustive Evaluation | All applicable constraints are evaluated | Validation Model | INVARIANT |
| P-018 | Non-Destructive Validation | Validation never modifies the Graph | Validation Model | INVARIANT |
| P-019 | No Silent Degradation | No operation can silently degrade coherence | Validation Pipeline | INVARIANT |
| P-020 | Repair Requires Authorization | Repair Engine never auto-applies | Repair Engine | INVARIANT |

---

## 4. PROPERTY CONCEPTS

| ID | Name | Definition | Domain | Status |
|----|------|------------|--------|--------|
| PR-001 | Identity | Immutable content-addressed identifier | ID Standard | STABLE |
| PR-002 | Type | Classification of a Node or Edge | Node Model | STABLE |
| PR-003 | Name | Human-readable label | Node Model | STABLE |
| PR-004 | Description | Human-readable explanation | Node Model | STABLE |
| PR-005 | Weight | Strength of an Edge (0.0–1.0) | Edge Model | STABLE |
| PR-006 | Trust | Confidence score (0.0–1.0) | Edge Model, Trust Model | STABLE |
| PR-007 | Lifecycle | Current state in the lifecycle model | Node Model | STABLE |
| PR-008 | Timestamp | Temporal marker for events | Edge Model, Event Model | STABLE |
| PR-009 | Ownership | Control dimension (0.0–1.0) | Dimension Model | STABLE |
| PR-010 | Dependency | Depth in dependency chain (0.0–1.0) | Dimension Model | STABLE |
| PR-011 | Importance | Criticality to system function | Dimension Model | STABLE |
| PR-012 | Energy | Activity/load level (0.0–1.0) | Dimension Model | STABLE |
| PR-013 | Semantic Distance | Relatedness to origin (0.0–1.0) | Dimension Model | STABLE |
| PR-014 | Confidence | Certainty in a concept or relation | Cross-cutting | STABLE |
| PR-015 | Severity | Criticality of a violation or constraint | Validation Model | STABLE |
| PR-016 | Coherence Score | Constraint satisfaction metric (0.0–1.0) | Health Model | STABLE |
| PR-017 | Freshness | Recency of evidence or data | Evidence Model | STABLE |
| PR-018 | Signature | Cryptographic proof of authenticity | ID Standard, ProofGraph | STABLE |
| PR-019 | Evidence Strength | Reliability of evidence (0.0–1.0) | ProofGraph | PROVISIONAL |
| PR-020 | Chain Depth | Distance from root of trust | ProofGraph | PROVISIONAL |

---

## 5. RELATION CONCEPTS

| ID | Name | Definition | Category | Status |
|----|------|------------|----------|--------|
| R-001 | CONTAINS | Parent-child structural relationship | Structural | STABLE |
| R-002 | BELONGS_TO | Child-parent membership | Structural | STABLE |
| R-003 | DEPENDS_ON | Source depends on target | Dependency | STABLE |
| R-004 | PROVES | Source proves target claim | Provenance | STABLE |
| R-005 | VALIDATES | Validation relationship | Provenance | STABLE |
| R-006 | EXECUTES | Execution relationship | Execution | STABLE |
| R-007 | OBSERVES | Monitoring relationship | Observation | STABLE |
| R-008 | REMEMBERS | Memory relationship | Cognition | STABLE |
| R-009 | GENERATES | Production relationship | Generation | STABLE |
| R-010 | EQUIVALENT_TO | Semantic equivalence | Concept Graph | STABLE |
| R-011 | CONTRADICTS | Semantic contradiction | Concept Graph | STABLE |
| R-012 | PRECEDES | Temporal ordering | Lifecycle | STABLE |
| R-013 | SUPERSEDES | Replacement relationship | Lifecycle | STABLE |
| R-014 | ATTESTED_BY | Attestation relationship | Provenance | STABLE |
| R-015 | CHAINED_TO | Evidence chain link | ProofGraph | PROVISIONAL |
| R-016 | GENERALIZES | Generalization hierarchy | Ontology | STABLE |
| R-017 | INSTANTIATES | Instance-of relationship | Ontology | STABLE |
| R-018 | COMPOSES | Part-whole relationship | Ontology | STABLE |
| R-019 | CONSTRAINS | Constraint application | Constraint | STABLE |
| R-020 | REFERENCES | Citation or reference | Cross-cutting | STABLE |
| R-021 | DEPENDS_ON_PROOF | Proof dependency (ProofGraph) | ProofGraph | PROVISIONAL |
| R-022 | WITNESSED_BY | Witness verification | ProofGraph | PROVISIONAL |

---

## 6. CONSTRAINT CONCEPTS

| ID | Name | Definition | Type | Status |
|----|------|------------|------|--------|
| CT-001 | AllowedStates | Set of valid lifecycle states | State | STABLE |
| CT-002 | ForbiddenStates | Set of invalid lifecycle states | State | STABLE |
| CT-003 | AllowedRelations | Permitted Edge types for a Pattern | Relation | STABLE |
| CT-004 | ForbiddenRelations | Prohibited Edge types | Relation | STABLE |
| CT-005 | RequiredRelations | Edge types that must exist | Relation | STABLE |
| CT-006 | RequiredProperties | Attributes that must be present | Property | STABLE |
| CT-007 | ForbiddenProperties | Attributes that must be absent | Property | STABLE |
| CT-008 | MinCardinality | Minimum count of a relationship | Cardinality | STABLE |
| CT-009 | MaxCardinality | Maximum count of a relationship | Cardinality | STABLE |
| CT-010 | AllowedTransitions | Permitted lifecycle transitions | Lifecycle | STABLE |
| CT-011 | ForbiddenTransitions | Prohibited lifecycle transitions | Lifecycle | STABLE |
| CT-012 | MinTrust | Minimum trust score | Trust | STABLE |
| CT-013 | MaxTrustChain | Maximum trust chain length | Trust | STABLE |
| CT-014 | RequiredEvidence | Required evidence existence | Evidence | STABLE |
| CT-015 | EvidenceFreshness | Maximum evidence age | Evidence | STABLE |
| CT-016 | IdentityUniqueness | No identity collisions | Identity | STABLE |
| CT-017 | MaxConcurrentExecution | Maximum parallel executions | Execution | STABLE |
| CT-018 | RequiredApproval | Required governance approval | Governance | STABLE |
| CT-019 | IdentityConflict | Two concepts with same identity but different definitions | Concept Graph | STABLE |
| CT-020 | SemanticConflict | Two assertions that logically contradict | Concept Graph | STABLE |
| CT-021 | StructuralConflict | Incompatible graph topologies | Concept Graph | STABLE |
| CT-022 | TemporalConflict | Temporal ordering violation | Concept Graph | STABLE |
| CT-023 | EvidenceConflict | Conflicting evidence | Concept Graph | STABLE |
| CT-024 | DuplicationConflict | Redundant concept definitions | Concept Graph | STABLE |
| CT-025 | VocabularyConflict | Same term used with different meanings | Concept Graph | PROVISIONAL |
| CT-026 | ProofConflict | Incomplete or contradictory proof chain | ProofGraph | PROVISIONAL |

---

## 7. INVARIANT CONCEPTS

| ID | Name | Statement | Category | Status |
|----|------|-----------|----------|--------|
| I-001 | Graph Authority Invariant | The Graph is never overridden by any projection | Foundational | INVARIANT |
| I-002 | Identity Immutability Invariant | Identity never changes after creation | Identity | INVARIANT |
| I-003 | Edge Permanence Invariant | Edges are never deleted — only archived | Structural | INVARIANT |
| I-004 | No Dangling Edge Invariant | Every Edge references existing Nodes | Structural | INVARIANT |
| I-005 | Deterministic Projection Invariant | Same state + same definition = same projection | Projection | INVARIANT |
| I-006 | Constraint Monotonicity Invariant | Patterns add constraints, never remove | Constraint | INVARIANT |
| I-007 | Evidence Chain Continuity Invariant | Evidence chains must be unbroken | Evidence | INVARIANT |
| I-008 | Root Cause Completeness Invariant | Every violation traces to a root cause | Coherence | INVARIANT |
| I-009 | Temporal Causality Invariant | Cause precedes effect | Temporal | INVARIANT |
| I-010 | Non-Repudiation Invariant | Every mutation generates an immutable Event | Audit | INVARIANT |

---

## 8. HYPOTHESIS CONCEPTS

| ID | Hypothesis | Source | Status |
|----|-----------|--------|--------|
| H-001 | ProofGraph verification reduces audit time by >50% | ProofGraph executive summary | UNTESTED |
| H-002 | Constraint-based validation catches more inconsistencies than rule-based | Coherence Engine | UNTESTED |
| H-003 | Cross-document equivalence detection reduces duplication by >30% | Concept Graph | UNTESTED |
| H-004 | Root cause analysis with causal chains reduces repair time | Root Cause Engine | UNTESTED |
| H-005 | Health scoring correlates with system reliability | Health Model | UNTESTED |
| H-006 | Automated contradiction detection improves ontology coherence | Concept Registry | UNTESTED |
| H-007 | INPI deposit integration increases legal protection coverage | INPI dossiers | UNTESTED |
| H-008 | Proof chain minimality reduces verification complexity | ProofGraph | UNTESTED |

---

## 9. CONCEPT GOVERNANCE

- The Concept Registry is the **single source of truth** for all concept definitions
- New concepts are added only through the Extraction Pipeline
- Concept status changes require traceability to source documents
- CONFLICTED concepts must be resolved before use in coherence analysis
- The Registry is versioned and immutable — changes create new concept versions

---

**CANONICO_CONCEPT_REGISTRY.md — V3**
**CANONICAL CONCEPT CATALOG**
**License: Open Standard**
