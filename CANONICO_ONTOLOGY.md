# CANONICO Ontology — Unified Conceptual Ontology

## Status: SPECIFICATION V3 — UNIFIED ONTOLOGY

---

## 1. ONTOLOGY OVERVIEW

The CANONICO Ontology is a **unified conceptual framework** that reconciles the vocabularies, taxonomies, and relationship models across all source corpora: UGIS V1, ProofGraph, INPI, executive reports, and technical annexes.

### 1.1 Ontology Principles

| Principle | Description |
|-----------|-------------|
| Unification | Every concept from any source is mapped to a single canonical representation |
| Traceability | Every mapping is traceable to source documents |
| Monotonicity | Adding new sources never removes existing concepts |
| Conflict Transparency | Unresolvable conflicts are explicitly documented |
| Minimality | No unnecessary concepts are introduced |

### 1.2 Ontology Architecture

```
UGIS Ontology
  └─ Node/Edge/Pattern/Archetype/Projection
ProofGraph Ontology
  └─ Vertex/Edge/ProofChain/TrustAnchor/Witness
INPI Ontology
  └─ Asset/Deposit/Holder/Certification
SUPRA Ontology
  └─ Agent/Mission/Memory/Twin

       ↓
CANONICO Unified Ontology
  ├─ Canonical Entities (reconciled)
  ├─ Canonical Relations (mapped)
  ├─ Princles (extracted)
  ├─ Constraints (merged)
  └─ Invariants (cross-validated)
```

---

## 2. CROSS-CORPUS MAPPING

### 2.1 UGIS → CANONICO Mapping

| UGIS Concept | CANONICO Concept | Mapping Type |
|-------------|------------------|--------------|
| Node | Node (C-002) | IDENTITY |
| Edge | Edge (C-003) | IDENTITY |
| Pattern | Pattern (C-004) | IDENTITY |
| Archetype | Archetype (C-005) | IDENTITY |
| Projection | Projection (C-006) | IDENTITY |
| Identity | Identity (C-007) | IDENTITY |
| Dimension | Property concept | GENERALIZATION |
| Lifecycle State | Property (lifecycle) | GENERALIZATION |
| Digital Passport | Certificate concept | SPECIALIZATION |

### 2.2 ProofGraph → CANONICO Mapping

| ProofGraph Concept | CANONICO Concept | Mapping Type | Notes |
|--------------------|------------------|--------------|-------|
| Vertex | Node (C-002) | EQUIVALENT | Renamed for UGIS consistency |
| Edge | Edge (C-003) | EQUIVALENT | Renamed for UGIS consistency |
| ProofChain | Evidence Chain (Evidence Model) | CLOSE_TO | ProofGraph chains include axioms |
| TrustAnchor | Root of Trust (Trust Model) | EQUIVALENT | Same concept, different term |
| Witness | Verifier Agent (Agent concept) | CLOSE_TO | Witness may be non-agent in INPI |
| ProofState | Validation Status | CLOSE_TO | ProofState is narrower |
| Axiom | Invariant (I-*) | CLOSE_TO | Axiom is foundational, invariant is derived |
| ProofStep | Evidence link | CLOSE_TO | ProofStep includes inference rule |
| Verification | Validation | EQUIVALENT | Same operation, different context |
| TrustDistance | Trust chain length | EQUIVALENT | Same concept |
| ChainSignature | Signature (PR-018) | EQUIVALENT | Same cryptographic concept |

### 2.3 INPI → CANONICO Mapping

| INPI Concept | CANONICO Concept | Mapping Type | Notes |
|--------------|------------------|--------------|-------|
| Intellectual Asset | Node (C-002) | GENERALIZATION | Asset is a specific Node type |
| Deposit | Event (C-009) | CLOSE_TO | Deposit is a type of creation event |
| Holder | Agent (C-021) | SPECIALIZATION | Holder is an Agent with ownership |
| Certification | Evidence (C-010) | CLOSE_TO | Certification is attestation evidence |
| IP Right | Constraint (C-008) | CLOSE_TO | IP rights constrain usage |
| Prior Art | Evidence (C-010) | SPECIALIZATION | Prior art is evidence of existence |
| Deposit Date | Timestamp (PR-008) | EQUIVALENT | Same temporal concept |
| Classification Code | Type (PR-002) | CLOSE_TO | Classification is domain-specific type |
| Legal Status | Lifecycle (PR-007) | CLOSE_TO | Legal status is a domain lifecycle |
| Territory | Attribute (domain-specific) | SPECIALIZATION | Geographic scope |

### 2.4 SUPRA → CANONICO Mapping

| SUPRA Concept | CANONICO Concept | Mapping Type | Notes |
|---------------|------------------|--------------|-------|
| Agent Registry | Agent (C-021) + Registry concept | COMPOSITION | |
| Mission | Mission Pattern (Process) | IDENTITY | |
| Memory | MEMORY Archetype | IDENTITY | |
| Twin | Twin (C-024) | IDENTITY | |
| Router | Agent specialized pattern | SPECIALIZATION | |
| Executive Shell | SYSTEM Archetype specialization | SPECIALIZATION | |

---

## 3. EQUIVALENCE CLASSES

### 3.1 Identical Concepts (EQUIVALENT_TO)

| Class | Concepts | Source Documents |
|-------|----------|-----------------|
| Node | UGIS Node, ProofGraph Vertex, INPI Asset, SUPRA Entity | All corpora |
| Edge | UGIS Edge, ProofGraph Edge, SUPRA Relation | All corpora |
| Identity | UGIS Identity, SUPRA ID, INPI Reference | All corpora |
| Timestamp | UGIS Timestamp, ProofGraph Time, INPI Date | All corpora |
| Validation | UGIS Validation, ProofGraph Verification | UGIS, ProofGraph |
| Trust | UGIS Trust, ProofGraph TrustDistance, SUPRA TrustScore | All corpora |
| Evidence | UGIS Evidence, ProofGraph Proof, INPI Certification | All corpora |
| Constraint | UGIS Constraint, ProofGraph Axiom, SUPRA Rule | All corpora |

### 3.2 Close Concepts (CLOSE_TO)

| Class A | Class B | Difference |
|---------|---------|------------|
| UGIS Pattern | ProofGraph ProofTemplate | Pattern specifies behavior; template specifies proof structure |
| UGIS Projection | ProofGraph View | Projection is read-only; View may include derived proofs |
| INPI Holder | SUPRA Agent | Holder has legal status; Agent has agency |
| UGIS Lifecycle | ProofGraph ProofState | Lifecycle applies to all entities; ProofState applies to proofs |
| UGIS Invariant | ProofGraph Axiom | Invariant is derived from constraints; Axiom is foundational |

### 3.3 Contradictory Concepts (CONTRADICTS)

| Concept A | Concept B | Contradiction | Resolution |
|-----------|-----------|---------------|------------|
| UGIS: Identity derived from type + timestamp | ProofGraph: Identity derived from content only | Seed data differs | Identity seed = type + archetype + seed + timestamp (UGIS standard adopted) |
| UGIS: Edges have lifecycle | Some ProofGraph Edges: immutable | Lifecycle vs fixity | Edge lifecycle adopted (UGIS), immutable edges as special case |
| INPI: Asset is Node | UGIS: Everything is Node | Consistent — no contradiction | Confirmed compatible |

---

## 4. ONTOLOGY HIERARCHY

### 4.1 Top-Level Categories

```
Entity (abstract)
├─ Node (can be instantiated)
│  ├─ System Entity
│  ├─ Agent Entity
│  ├─ Resource Entity
│  ├─ Memory Entity
│  ├─ Process Entity
│  ├─ Concept Entity
│  └─ Relationship Entity (abstract)
├─ Edge (can be instantiated)
│  ├─ Structural Edge
│  ├─ Dependency Edge
│  ├─ Generation Edge
│  ├─ Provenance Edge
│  ├─ Execution Edge
│  ├─ Observation Edge
│  └─ Cognitive Edge
├─ Event (immutable record)
├─ Constraint (rule definition)
├─ Evidence (proof and attestation)
└─ Projection (derived view)
```

### 4.2 ProofGraph-Specific Hierarchy

```
ProofEntity
├─ Vertex (equivalent to Node)
├─ Edge (equivalent to Edge)
├─ ProofChain (specialized Evidence)
│  ├─ AxiomChain (foundational)
│  ├─ DerivedChain (inferred)
│  └─ CompositeChain (merged)
├─ TrustAnchor (specialized Node)
└─ Witness (specialized Agent)
```

### 4.3 INPI-Specific Hierarchy

```
IPEntity
├─ Asset (specialized Node)
├─ Deposit (specialized Event)
├─ Holder (specialized Agent)
├─ Certification (specialized Evidence)
└─ IPRight (specialized Constraint)
```

---

## 5. ONTOLOGY RELATIONS

### 5.1 Cross-Ontology Relations

| Source Ontology | Relation | Target Ontology | Meaning |
|-----------------|----------|-----------------|---------|
| UGIS | MAPS_TO | ProofGraph | UGIS concept has a ProofGraph equivalent |
| ProofGraph | EXTENDS | UGIS | ProofGraph adds detail to UGIS concept |
| INPI | SPECIALIZES | UGIS | INPI concept is domain-specific UGIS concept |
| SUPRA | INSTANTIATES | UGIS | SUPRA concept is a concrete instance |

### 5.2 Unified Relation Ontology

```
Relation Types (unified):
├─ Structural
│  ├─ CONTAINS / BELONGS_TO / PART_OF
│  └─ OWNS / MEMBER_OF
├─ Dependency
│  ├─ DEPENDS_ON / USES / REQUIRES / IMPORTS
│  └─ DEPENDS_ON_PROOF (ProofGraph)
├─ Provenance
│  ├─ PROVES / VALIDATES / CERTIFIES / AUTHORIZES
│  ├─ ATTESTED_BY / WITNESSED_BY
│  └─ CHAINED_TO (ProofGraph chain)
├─ Cognitive
│  ├─ REMEMBERS / LEARNS / DECIDES / INFERS
│  └─ BELIEVES / KNOWS
├─ Temporal
│  ├─ PRECEDES / SUPERSEDES / EVOLVES
│  └─ MIGRATES / ARCHIVES
├─ Semantic
│  ├─ EQUIVALENT_TO / CLOSE_TO / CONTRADICTS
│  ├─ GENERALIZES / SPECIALIZES
│  └─ INSTANTIATES / COMPOSES
└─ Constraint
   └─ CONSTRAINS / REQUIRES / FORBIDS / PERMITS
```

---

## 6. ONTOLOGY COMPLETENESS

### 6.1 Coverage Metrics

| Ontology | Concepts | Relations | Mapped to Canonical |
|----------|----------|-----------|---------------------|
| UGIS V1 | 47 | 45 | 100% |
| ProofGraph | 28 | 22 | 100% |
| INPI | 12 | 8 | 100% |
| SUPRA | 18 | 15 | 100% |
| **Unified** | **68** | **62** | — |

### 6.2 Mapping Completeness

| Mapping Status | Count | Definition |
|----------------|-------|------------|
| IDENTITY | 18 | Same concept, no transformation needed |
| EQUIVALENT | 9 | Same concept, different naming |
| CLOSE_TO | 12 | Related but not identical |
| GENERALIZATION | 5 | Broader concept in target |
| SPECIALIZATION | 7 | Narrower concept in target |
| COMPOSITION | 4 | Combined from multiple concepts |
| CONTRADICTS | 3 | Conflicting definitions (resolved) |

---

## 7. ONTOLOGY EVOLUTION

### 7.1 Versioning

```
OntologyVersion {
  id: Identity
  major: Int                          [breaking changes]
  minor: Int                          [additions]
  patch: Int                          [corrections, clarifications]
  date: Timestamp
  changes: [ChangeLog]
  sourceDocuments: [DocumentRef]      [documents included in this version]
}
```

### 7.2 Change Types

| Change | Description |
|--------|-------------|
| ADD_CONCEPT | New concept discovered or introduced |
| ADD_RELATION | New relationship between existing concepts |
| MERGE_CONCEPTS | Two concepts resolved as identical |
| SPLIT_CONCEPT | One concept refined into two |
| DEPRECATE_CONCEPT | Concept no longer needed |
| RESOLVE_CONFLICT | Contradiction resolved |
| UPDATE_DEFINITION | Definition refined |

---

## 8. ONTOLOGY GOVERNANCE

- The Unified Ontology is maintained as a read-only specification
- Changes require cross-document evidence
- Conflicts must be resolved with traceability
- Every concept has a single canonical definition, regardless of source count
- The ontology is the reference for all Coherence Engine operations
- Governance requires approval from SUPRA-Architect for ontology changes

---

**CANONICO_ONTOLOGY.md — V3**
**UNIFIED CONCEPTUAL ONTOLOGY**
**License: Open Standard**
