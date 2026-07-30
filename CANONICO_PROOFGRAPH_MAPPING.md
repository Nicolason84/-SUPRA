# CANONICO ProofGraph Mapping — Cross-Corpus Fusion & Equivalence

## Status: SPECIFICATION V3 — PROOFGRAPH FUSION

---

## 1. PROOFGRAPH MAPPING OVERVIEW

This document defines the **complete mapping** between the ProofGraph theoretical corpus and the CANONICO UGIS standard. It identifies concept equivalences, structural analogies, constraint correspondences, and integration points.

### 1.1 Mapping Corpus

The ProofGraph corpus includes:
- Φ-ProofGraph_v3.0 specification
- ProofGraph annexes (technical appendices)
- ProofGraph executive summaries
- ProofGraph chain JSON definitions
- ProofGraph axioms and inference rules

### 1.2 Mapping Dimensions

| Dimension | Question |
|-----------|----------|
| Conceptual | What does each concept mean in its source system? |
| Structural | How is the concept positioned in the knowledge hierarchy? |
| Behavioral | What operations does the concept support? |
| Constraint | What rules govern the concept? |
| Evidential | How is the concept proven or verified? |

---

## 2. CONCEPT MAPPING TABLE

### 2.1 Core Entity Mapping

| ProofGraph Concept | CANONICO Concept | Mapping Type | Confidence | Notes |
|-------------------|------------------|--------------|------------|-------|
| Vertex | Node (C-002) | EQUIVALENT | 0.95 | Same abstraction: atomic entity |
| Edge | Edge (C-003) | EQUIVALENT | 0.95 | Same abstraction: relationship |
| Graph | Graph (C-001) | EQUIVALENT | 0.90 | Same abstraction: container of entities |
| Label | Type (PR-002) | CLOSE_TO | 0.85 | ProofGraph label = CANONICO type |
| Property | Attribute (Node property) | EQUIVALENT | 0.90 | Same abstraction: entity characteristic |
| Signature | Signature (PR-018) | EQUIVALENT | 0.95 | Cryptographic verification |
| Timestamp | Timestamp (PR-008) | EQUIVALENT | 1.00 | ISO 8601 in both systems |

### 2.2 Proof-Specific Mapping

| ProofGraph Concept | CANONICO Concept | Mapping Type | Confidence | Notes |
|-------------------|------------------|--------------|------------|-------|
| ProofChain | EvidenceChain (Pattern) | CLOSE_TO | 0.85 | ProofGraph chains include inference rules; CANONICO chains include evidence links |
| Axiom | Invariant (I-*) | CLOSE_TO | 0.80 | Axiom is foundational truth; Invariant is derived rule |
| Theorem | Proven Claim (Evidence target) | CLOSE_TO | 0.75 | Theorem = proven statement; Evidence proves claims |
| Hypothesis | Hypothesis (H-*) | EQUIVALENT | 0.90 | Same: untested proposition |
| InferenceRule | Constraint (transition rule) | CLOSE_TO | 0.70 | Inference rule reasons; Constraint restricts |
| Derivation | ProofEdge (CHAINED_TO) | CLOSE_TO | 0.80 | Derivation = step in proof; CHAINED_TO = link in chain |

### 2.3 Trust Mapping

| ProofGraph Concept | CANONICO Concept | Mapping Type | Confidence | Notes |
|-------------------|------------------|--------------|------------|-------|
| TrustAnchor | Root of Trust (EvidenceChain invariant) | EQUIVALENT | 0.95 | Both: ultimate trust source |
| TrustDistance | Trust chain length | EQUIVALENT | 0.90 | Both: hop count from anchor |
| TrustDecay | Trust decay rate (TrustRules) | EQUIVALENT | 0.85 | Both: trust diminishes with distance/time |
| Witness | Verifier Agent (Observer pattern) | CLOSE_TO | 0.80 | Witness = independent verifier; Agent can be verifier |
| Attestation | Evidence (ATTESTED_BY) | EQUIVALENT | 0.95 | Both: signed claim by trusted party |
| Reputation | TrustScore (dimension) | CLOSE_TO | 0.75 | Reputation = aggregate trust; TrustScore = current trust |

### 2.4 Constraint Mapping

| ProofGraph Concept | CANONICO Concept | Mapping Type | Confidence | Notes |
|-------------------|------------------|--------------|------------|-------|
| ProofConstraint | Constraint (C-008) | EQUIVALENT | 0.90 | Both: rule limiting valid states |
| InvarianceConstraint | Invariant (I-*) | EQUIVALENT | 0.95 | Both: condition that always holds |
| Precondition | Transition precondition | EQUIVALENT | 0.90 | Both: condition before operation |
| Postcondition | Transition postcondition | EQUIVALENT | 0.90 | Both: condition after operation |
| CardinalityConstraint | Cardinality (CT-008/009) | EQUIVALENT | 0.95 | Both: numerical limit on relations |
| TypeConstraint | PropertyType constraint | EQUIVALENT | 0.90 | Both: type restriction on values |

### 2.5 Verification Mapping

| ProofGraph Concept | CANONICO Concept | Mapping Type | Confidence | Notes |
|-------------------|------------------|--------------|------------|-------|
| Verification | Validation (Coherence Engine) | EQUIVALENT | 0.90 | Both: check against rules |
| Proof | Evaluation result (PASS) | CLOSE_TO | 0.75 | Proof = complete verification; PASS = constraint satisfied |
| Counterexample | Violation report | CLOSE_TO | 0.80 | Counterexample = failing state; Violation = constraint fail |
| Model | Graph state | CLOSE_TO | 0.70 | Model = system state; GraphState = current state |
| Satisfiability | Constraint satisfaction | EQUIVALENT | 0.85 | Both: existence of valid state |

---

## 3. STRUCTURAL MAPPING

### 3.1 Graph Structure Analogy

```
ProofGraph                             CANONICO
─────────────────                     ─────────
VertexSet ∪ EdgeSet                    NodeSet ∪ EdgeSet
  ├─ Labeled Graph                      ├─ Typed Graph
  ├─ Directed Edges                     ├─ Directed/Bidirectional Edges
  └─ Properties on Vertices            └─ Attributes on Nodes

ProofChain                             EvidenceChain (Pattern)
  ├─ Ordered Edge Sequence              ├─ CHAINED_TO edge sequence
  ├─ Terminates at Axiom               ├─ Terminates at TrustAnchor
  ├─ Each step verified                ├─ Each link signed
  └─ Acyclic                           └─ Acyclic
```

### 3.2 Proof Hierarchy Mapping

```
ProofGraph Layer        CANONICO Layer
─────────────────       ─────────────
Axiom Layer             Invariant Layer
  └─ Foundational truths   └─ Immutable rules
Theorem Layer           Principle Layer
  └─ Derived truths         └─ Established principles
Hypothesis Layer        Hypothesis Layer
  └─ Testable claims        └─ Testable claims
Evidence Layer          Evidence Layer
  └─ Proof steps            └─ Chain links
```

### 3.3 Operation Mapping

| ProofGraph Operation | CANONICO Operation |
|---------------------|-------------------|
| addVertex(type) | createNode(type, pattern) |
| addEdge(source, target, type) | createEdge(source, target, type) |
| verify(claim) | validate(node/edge) |
| prove(claim, chain) | attachEvidence(node, evidence) |
| checkConsistency(graph) | checkConsistency(scope) |
| findContradictions(graph) | detectConflicts(scope) |
| resolve(conflict) | proposeRepair(violation) |
| derive(theorem, premises) | infer(conclusion, premises) |

---

## 4. CONSTRAINT CORRESPONDENCE

### 4.1 Direct Mappings

| ProofGraph Constraint | CANONICO Constraint | ID |
|----------------------|---------------------|----|
| NoDanglingEdges | G-001 No dangling edges | C-001 |
| UniqueIdentities | G-002 Unique identities | C-002 |
| NoSelfLoops | G-007 No self-loops | C-007 |
| AxiomConsistency | Invariant constraint | I-* |
| ChainAcyclicity | EVC-001 Chain acyclic | EVC-001 |
| SignatureVerification | EVC-003 Signature validity | EVC-003 |
| TrustTransitivity | TRUST-002 Trust chain | REM-003 |

### 4.2 ProofGraph Constraints Not in V2

These constraints from ProofGraph are **new additions** in V3:

| ID | Constraint | Description | Source |
|----|-----------|-------------|--------|
| PG-001 | Proof chain must be complete | Every claim has a complete chain to axioms | ProofGraph |
| PG-002 | No orphan proof steps | Every chain link has a predecessor/successor | ProofGraph |
| PG-003 | Witness independence | Witness must not be party to the claim | ProofGraph |
| PG-004 | Axiom irreducibility | Axioms cannot be derived from other axioms | ProofGraph |
| PG-005 | Proof monotonicity | Adding evidence never invalidates existing proofs | ProofGraph |
| PG-006 | Freshness chain | Evidence freshness propagates through chain | ProofGraph |
| PG-007 | Diversity requirement | Proof chain must include ≥2 independent sources | ProofGraph |
| PG-008 | Cross-verification | Proof must be verifiable by multiple methods | ProofGraph |

### 4.3 V2 Constraints Not in ProofGraph

These CANONICO V2 constraints extend ProofGraph:

| V2 ID | Constraint | ProofGraph Gap |
|-------|-----------|----------------|
| G-009 | Lifecycle order | ProofGraph has no lifecycle model |
| G-012 | Dimension bounds | ProofGraph has no dimensions |
| SYS-001 | System must have name | ProofGraph has no naming convention |
| AGT-001 | Agent must have capability | ProofGraph has no agent model |
| DEP-001 | DEPENDS_ON acyclic | ProofGraph has no dependency model |
| GOV-001 | Authorization required | ProofGraph has no governance model |

---

## 5. INTEGRATION PATTERNS

### 5.1 Direct Integration

Where ProofGraph and CANONICO concepts map EQUIVALENT or IDENTITY:
- ProofGraph Vertex → CANONICO Node (no transformation)
- ProofGraph Edge → CANONICO Edge (no transformation)
- ProofGraph Signature → CANONICO Signature (same format)

### 5.2 Translation Integration

Where concepts are CLOSE_TO:
- ProofGraph ProofChain → CANONICO EvidenceChain (add lifecycle states)
- ProofGraph Axiom → CANONICO Invariant (add governance rules)
- ProofGraph Witness → CANONICO Agent (add capabilities)

### 5.3 Extension Integration

Where ProofGraph has concepts not in CANONICO:
- PG-001 to PG-008 → new constraints in V3 Constraint Library
- ProofGraph inference rules → new Pattern behaviors

### 5.4 Enrichment Integration

Where CANONICO has concepts not in ProofGraph:
- Lifecycle model → enrich ProofGraph entities with state
- Dimension model → enrich ProofGraph entities with metrics
- Governance model → enrich ProofGraph verification with authorization

---

## 6. PROOFGRAPH CHAIN JSON MAPPING

### 6.1 ProofGraph Chain Structure

```json
{
  "chain_id": "pg:chain:abc123",
  "claim": "System X is coherent",
  "steps": [
    {
      "step_id": "pg:step:001",
      "premise": "pg:vertex:A",
      "inference": "MODUS_PONENS",
      "conclusion": "pg:vertex:B",
      "witness": "pg:witness:W1",
      "signature": "0x..."
    }
  ],
  "root": "pg:axiom:TRUST_ROOT"
}
```

### 6.2 Canonical Mapping

```json
{
  "canonical_chain": {
    "id": "can:evc:abc123",
    "claim": "System X is coherent",
    "links": [
      {
        "id": "can:edg:step001",
        "type": "CHAINED_TO",
        "source": "can:res:vertexA",
        "target": "can:res:vertexB",
        "metadata": {
          "inference_rule": "MODUS_PONENS",
          "source_system": "ProofGraph"
        },
        "evidence": {
          "witness": "can:agt:witnessW1",
          "signature": "0x..."
        }
      }
    ],
    "root_of_trust": "can:con:trustRoot",
    "source_chain": "pg:chain:abc123"
  }
}
```

---

## 7. FUSION GOVERNANCE

- All ProofGraph mappings are documented with confidence scores
- Confidence < 0.80 requires manual validation
- EQUIVALENT mappings can be auto-resolved
- CLOSE_TO mappings require human review
- ProofGraph axioms are treated as INVARIANT unless contradicted by UGIS
- When ProofGraph and UGIS conflict, UGIS takes precedence (Graph is source of truth)
- The mapping is versioned and traceable to specific ProofGraph ZIP contents

---

**CANONICO_PROOFGRAPH_MAPPING.md — V3**
**PROOFGRAPH FUSION & CROSS-CORPUS MAPPING**
**License: Open Standard**
