# CANONICO Knowledge Graph — Corpus Concept Extraction & Graph Construction

## Status: SPECIFICATION V3 — KNOWLEDGE GRAPH

---

## 1. KNOWLEDGE GRAPH OVERVIEW

The Knowledge Graph is the **conceptual backbone** of CANONICO V3. It transforms a heterogeneous corpus of documents (ProofGraph, UGIS, INPI, annexes, executive reports) into a structured, queryable graph of concepts, principles, hypotheses, definitions, relations, constraints, invariants, equivalences, dependencies, and evidences.

### 1.1 Core Principle

Every document in the corpus is a **projection** of an underlying concept space. The Knowledge Graph extracts the canonical concepts from all projections and reconciles them into a single coherent representation.

### 1.2 Knowledge Graph Architecture

```
Corpus Documents (heterogeneous)
  ↓
Extraction Pipeline
  ├─ Concept Extraction
  ├─ Relation Extraction
  ├─ Constraint Extraction
  ├─ Equivalence Detection
  └─ Contradiction Detection
  ↓
Canonical Knowledge Graph
  ├─ Concept Layer
  ├─ Principle Layer
  ├─ Hypothesis Layer
  ├─ Evidence Layer
  └─ Invariant Layer
  ↓
Query & Projection Layer
  ├─ Coherence Queries
  ├─ Impact Analysis
  ├─ Root Cause Tracing
  └─ Audit Reports
```

### 1.3 Graph Layers

| Layer | Contents | Purpose |
|-------|----------|---------|
| Concept Layer | All extracted concepts with definitions | Unified vocabulary |
| Principle Layer | Foundational principles across corpus | Invariant rules |
| Hypothesis Layer | Stated and implied hypotheses | Testable assertions |
| Evidence Layer | Proofs, attestations, chains | Justification tracking |
| Invariant Layer | Immutable laws across all documents | Boundary conditions |

---

## 2. CONCEPT EXTRACTION

### 2.1 Extraction Pipeline

```
Document
  ↓
Tokenization & Normalization
  ↓
Term Extraction (noun phrases, named entities)
  ↓
Concept Candidate Generation
  ↓
Cross-Document Matching
  ↓
Definition Extraction
  ↓
Canonical Concept Registration
  ↓
Relation Discovery
```

### 2.2 Concept Types

| Type | Description | Example |
|------|-------------|---------|
| `ENTITY` | A concrete or abstract thing | Node, Edge, Graph, Agent |
| `PRINCIPLE` | A foundational truth or law | Graph is the only reality |
| `PROPERTY` | A characteristic of an entity | Identity, Trust, Weight |
| `RELATION` | A connection between entities | CONTAINS, DEPENDS_ON, PROVES |
| `CONSTRAINT` | A boundary or rule | MinTrust, Cardinality, AllowedStates |
| `HYPOTHESIS` | A testable assertion | "ProofGraph reduces verification time" |
| `EVIDENCE` | A proof or attestation | Signature, Chain, Witness |
| `INVARIANT` | A condition that never changes | Identity immutability |
| `EQUIVALENCE` | A mapping between equivalent concepts | UGIS Node ≈ ProofGraph Vertex |
| `CONTRADICTION` | A detected inconsistency | Divergent definitions |
| `PATTERN` | A reusable template | AIAgent, Mission, Workspace |
| `MECHANISM` | A process or algorithm | Root Cause Analysis, Conflict Detection |

### 2.3 Extraction Algorithm

```
FUNCTION extractConcepts(document) → [Concept]

  1. Parse document structure (headings, sections, paragraphs)
  2. Extract noun phrases using dependency parsing
  3. Identify defining sentences (patterns: "X is Y", "X refers to", "X means")
  4. Extract relational statements (patterns: "X depends on Y", "X contains Y")
  5. Extract constraint statements (patterns: "X must Y", "X cannot Y", "X ≥ 0")
  6. Extract principle statements (patterns: "Every X", "No X", "X always")
  7. Generate concept candidates with source locations
  8. Filter by relevance threshold
  9. Return typed concept set
```

### 2.4 Cross-Document Resolution

When the same or similar concept appears in multiple documents:

```
Concept A (doc1) ─── Similarity Score ──── Concept B (doc2)
                        │
                   Resolution:
                   ─ IDENTICAL → merge (same definition)
                   ─ SIMILAR → relate via EQUIVALENT_TO or CLOSE_TO
                   ─ CONTRADICTORY → flag as CONTRADICTION
                   ─ UNRELATED → keep separate
```

Similarity is computed via:
- **Lexical similarity**: shared terms in definitions
- **Structural similarity**: same position in document hierarchy
- **Relational similarity**: same relations to other concepts
- **Semantic similarity**: embedding-based cosine similarity

---

## 3. CONCEPT GRAPH STRUCTURE

### 3.1 Concept Node

```
ConceptNode {
  id: Identity                          [can:cpt:<hash>]
  name: String                          [canonical name]
  type: ConceptType                     [ENTITY | PRINCIPLE | ...]
  definition: String                    [canonical definition]
  sourceDocuments: [DocumentRef]        [all documents referencing this concept]
  aliases: [String]                     [alternative names across corpus]
  confidence: Float                     [0.0–1.0, extraction confidence]
  status: ConceptStatus                 [STABLE | PROVISIONAL | CONFLICTED | DEPRECATED]
  version: String
}
```

### 3.2 Concept Edge Types

| EdgeType | Meaning |
|----------|---------|
| `EQUIVALENT_TO` | Concepts are identical across documents |
| `CLOSE_TO` | Concepts are semantically related but not identical |
| `CONTRADICTS` | Concepts directly contradict each other |
| `DEPENDS_ON` | Concept depends on another for its definition |
| `GENERALIZES` | Concept is a broader category |
| `SPECIALIZES` | Concept is a specific case |
| `PRECEDES` | Temporal ordering of concept introduction |
| `PROVES` | Concept provides evidence for another |
| `INSTANTIATES` | Concept is an instance of another |
| `COMPOSES` | Concept is part of another |
| `CONSTRAINS` | Concept imposes a constraint on another |
| `REQUIRES` | Concept requires another to be valid |

### 3.3 Concept Graph Operations

```
ConceptGraph {
  // Extraction
  func extract(from document: Document) -> [ConceptNode]
  func resolveCrossDocument(concepts: [ConceptNode]) -> [ConceptNode]
  func detectContradictions(concepts: [ConceptNode]) -> [Contradiction]

  // Query
  func concept(named: String) -> ConceptNode?
  func concepts(ofType: ConceptType) -> [ConceptNode]
  func related(to concept: ConceptNode, via: RelationType) -> [ConceptNode]
  func path(from: ConceptNode, to: ConceptNode) -> [ConceptEdge]
  func subgraph(containing: [ConceptNode]) -> ConceptSubgraph

  // Analysis
  func orphans() -> [ConceptNode]
  func cycles() -> [[ConceptEdge]]
  func density() -> Float
  func connectivity(concept: ConceptNode) -> Float
  func coherence() -> ConceptGraphHealth
}
```

---

## 4. PRINCIPLE EXTRACTION

### 4.1 Principle Types

| Principle Type | Source | Example |
|---------------|--------|---------|
| UGIS Law | CANONICO_STANDARD.md | "The Graph is the only reality" |
| ProofGraph Axiom | ProofGraph corpus | "Every proof has a chain" |
| Invariant Rule | All documents | "Identity is immutable" |
| Constraint Rule | Constraint Library | "No dangling edges" |
| Governance Rule | Governance documents | "CRITICAL requires approval" |

### 4.2 Principle Structure

```
Principle {
  id: Identity
  name: String
  statement: String                    [the principle itself]
  type: PrincipleType
  source: DocumentRef
  status: PrincipleStatus              [INVARIANT | CONSTRAINT | GUIDELINE | ASPIRATION]
  evidence: [EvidenceRef]              [proofs supporting this principle]
  exceptions: [Exception]              [documented exceptions]
  conflicts: [ConflictRef]             [principles that contradict this one]
  implications: [ConceptRef]           [concepts affected by this principle]
}
```

---

## 5. HYPOTHESIS EXTRACTION

### 5.1 Hypothesis Types

| Hypothesis Type | Description |
|----------------|-------------|
| `STATED` | Explicitly claimed in a document |
| `IMPLIED` | Logically follows from stated premises |
| `ASSUMED` | Taken as given without proof |
| `TESTED` | Has been experimentally verified |
| `FALSIFIED` | Has been proven false |

### 5.2 Hypothesis Structure

```
Hypothesis {
  id: Identity
  statement: String
  type: HypothesisType
  source: DocumentRef
  assumptions: [Assumption]
  predictions: [Prediction]            [what must be true if hypothesis holds]
  evidence: [EvidenceRef]              [supporting or contradicting evidence]
  status: HypothesisStatus             [UNTESTED | CONFIRMED | FALSIFIED | CONTESTED]
  confidence: Float
  dependsOn: [HypothesisRef]           [sub-hypotheses]
}
```

---

## 6. EVIDENCE TRACKING

### 6.1 Evidence Structure

```
Evidence {
  id: Identity
  type: EvidenceType                   [PROOF | TEST | ATTESTATION | CITATION | DERIVATION]
  claim: String                        [what is being evidenced]
  source: DocumentRef
  target: ConceptRef | HypothesisRef   [what this evidence supports/refutes]
  strength: Float                      [0.0–1.0]
  freshness: Timestamp
  chain: [EvidenceRef]                 [evidence chain]
  signature: Signature?
  status: EvidenceStatus               [VERIFIED | PENDING | EXPIRED | CONTESTED]
}
```

### 6.2 Evidence Chain Traversal

```
FUNCTION traceEvidence(claim) → EvidenceChain

  chain = []
  visited = Set()
  current = getEvidenceFor(claim)

  WHILE current != nil AND current NOT IN visited:
    visited.add(current)
    chain.add(current)
    current = getEvidenceFor(current)  // follow chain upward

  RETURN EvidenceChain(
    root: current,                     // root of trust
    length: chain.count,
    unbroken: isUnbroken(chain),
    weakestLink: min(chain.strength),
    confidence: computeConfidence(chain)
  )
```

---

## 7. CONTRADICTION DETECTION

### 7.1 Contradiction Types

| Type | Detection | Example |
|------|-----------|---------|
| Definitional | Same term, different definitions | "Node" in UGIS vs "Node" in ProofGraph |
| Relational | Same relation, different semantics | DEPENDS_ON in different contexts |
| Constraint | Conflicting rules | MinTrust = 0.3 in doc A, MinTrust = 0.7 in doc B |
| Principle | Conflicting principles | "Always validate" vs "Skip validation for performance" |
| Evidential | Conflicting evidence | Proof A disproves Proof B |
| Structural | Incompatible taxonomies | Different Archetype hierarchies |

### 7.2 Contradiction Resolution

```
Resolution {
  contradiction: ContradictionRef
  resolution: ResolutionType           [HARMONIZE | CHOOSE_A | CHOOSE_B | DECLARE_AMBIGUITY]
  rationale: String
  resultingConcept: ConceptRef         [the resolved canonical concept]
  confidence: Float
  resolvedBy: AgentRef
  resolvedAt: Timestamp
}
```

---

## 8. INVARIANT DETECTION

### 8.1 Invariant Sources

Invariants are extracted from:
1. Explicit laws (UGIS Laws 1–5)
2. Constraint rules marked CRITICAL
3. Principles marked INVARIANT
4. Structural properties that hold across all documents
5. Mathematical and logical axioms

### 8.2 Invariant Registry

| Invariant | Source | Scope |
|-----------|--------|-------|
| Graph is single source of truth | UGIS Law 1 | Global |
| Everything is a Node | UGIS Law 2 | Global |
| Every interaction is an Edge | UGIS Law 3 | Global |
| Everything else is a Projection | UGIS Law 4 | Global |
| Pattern over Implementation | UGIS Law 5 | Global |
| Identity is immutable | ID Standard | Identity |
| No dangling edges | Constraint G-001 | Structural |
| Edges are never deleted | Edge Model | Lifecycle |
| Coherence is emergent | Coherence Engine | Validation |
| Constraint monotonic inheritance | Constraint Model | Pattern |
| Evidence chains terminate | Evidence Model | Proof |

---

## 9. KNOWLEDGE GRAPH HEALTH

### 9.1 Metrics

| Metric | Description |
|--------|-------------|
| Concept Count | Total canonical concepts |
| Relation Count | Total cross-concept relations |
| Contradiction Count | Unresolved contradictions |
| Orphan Count | Concepts with no relations |
| Density | Ratio of edges to possible edges |
| Connectivity | Average paths between concepts |
| Coverage | % of document concepts mapped |
| Resolution Rate | % of contradictions resolved |

### 9.2 Health Scoring

```
KnowledgeGraphHealth {
  completeness: Float                  [% of concepts extracted]
  consistency: Float                   [1 - contradictionCount / totalConcepts]
  connectivity: Float                  [average degree / max degree]
  resolution: Float                    [resolved / total contradictions]
  freshness: Float                     [avg evidence freshness]
  overall: Float                       [composite score]
}
```

---

## 10. GOVERNANCE

- The Knowledge Graph is read-only for all agents except the Coherence Engine
- Concept resolution requires cross-document validation
- Contradictions are never silently resolved — always documented
- The Knowledge Graph must be regenerated when new documents are added
- Every extraction is traced to its source document and location

---

**CANONICO_KNOWLEDGE_GRAPH.md — V3**
**KNOWLEDGE GRAPH & CONCEPT EXTRACTION**
**License: Open Standard**
