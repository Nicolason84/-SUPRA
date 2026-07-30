# SUPRA Theory Compiler — Specification V1

## Status: SPECIFICATION — SUPRA ULTIMATE CONSOLIDATED PHASE 1

| Propriété | Valeur |
|-----------|--------|
| **Version** | SUPRA_THEORY_COMPILER_V1 |
| **Date** | 2026-07-29 |
| **Autorité** | SUPRA Knowledge Compiler — Theory Parser |
| **Préséance** | Théorie compilable unique — supplante tout document brut |

---

## 1. THEORY COMPILER PRINCIPLE

ProofGraph, CANONICO, and INPI documents are no longer documents.

They are a **compilable theory**.

The Theory Compiler extracts concepts, merges equivalent concepts, builds a unified ontology, identifies invariants, axioms, and constraints, measures global coherence, and signals non-demonstrated zones.

---

## 2. THEORY CORPORA

### 2.1 Source Theories

| Corpus | Contents | Status | Compilation Priority |
|--------|----------|--------|---------------------|
| ProofGraph | Proof chains, trust model, verification axioms | Complete reference | 1 (highest) |
| CANONICO V1-V3 | Knowledge graph, ontology, constraints, coherence | Complete specifications | 1 (highest) |
| INPI | Intellectual property model, certification, assets | Conceptual mapping | 2 |
| UGIS V1-V3 | Node/edge model, patterns, projections, lifecycle | Complete standard | 1 (highest) |
| SUPRA Constitution | Immutable principles, governance, architecture | Active constitution | 1 (highest) |
| Executive Reports | Decision records, mission reports, audits | Continuous | 3 |

### 2.2 Theory Status

| Status | Meaning |
|--------|---------|
| COMPILED | Theory fully extracted, aligned, and validated |
| PARTIAL | Theory partially compiled (some unmapped concepts) |
| PENDING | Theory registered but not yet compiled |
| CONFLICTED | Compilation produced unresolvable contradictions |
| DEPRECATED | Superseded by newer theory version |

---

## 3. THEORY COMPILATION PIPELINE

### 3.1 Pipeline

```
Theory Corpus (ProofGraph, CANONICO, INPI, UGIS, Constitution)
  │
  ▼
1. CORPUS INGESTION
   ├── Parse each document as theory (not plain text)
   ├── Identify document type, version, authority level
   └── Register theory identity
  │
  ▼
2. CONCEPT EXTRACTION
   ├── Extract all defined concepts
   ├── Extract principles, axioms, invariants
   ├── Extract constraints and rules
   ├── Extract hypotheses and claims
   └── Extract evidence and proofs
  │
  ▼
3. CONCEPT FUSION
   ├── Match equivalent concepts across theories
   ├── Merge identical concepts
   ├── Create equivalence mappings for close concepts
   ├── Detect contradictory concepts
   └── Flag unmatchable concepts
  │
  ▼
4. ONTOLOGY CONSTRUCTION
   ├── Build unified concept hierarchy
   ├── Assign canonical names and definitions
   ├── Validate hierarchy consistency
   └── Register in Unified Ontology
  │
  ▼
5. INVARIANT IDENTIFICATION
   ├── Extract statements that are universally true
   ├── Validate invariants across all theories
   ├── Detect invariant conflicts
   └── Register confirmed invariants
  │
  ▼
6. AXIOM IDENTIFICATION
   ├── Extract foundational assumptions
   ├── Verify axiom independence
   ├── Classify by domain
   └── Register axiom set
  │
  ▼
7. CONSTRAINT EXTRACTION
   ├── Extract all constraint statements
   ├── Classify by type (structural, semantic, temporal, etc.)
   ├── Resolve constraint conflicts
   └── Register in Constraint Library
  │
  ▼
8. COHERENCE MEASUREMENT
   ├── Compute per-theory coherence score
   ├── Compute cross-theory coherence score
   ├── Identify non-demonstrated zones
   ├── Identify unproven claims
   └── Generate coherence report
  │
  ▼
9. THEORY PUBLICATION
   ├── Register compiled theory
   ├── Publish to Knowledge Compiler
   ├── Generate theory trace
   └── Update theory status
```

---

## 4. CONCEPT FUSION

### 4.1 Equivalence Detection

| Method | Description | Threshold |
|--------|-------------|-----------|
| Name matching | Exact or normalized name match | 1.0 (exact) |
| Definition similarity | Semantic similarity of definitions | > 0.85 |
| Structural similarity | Same position in ontology hierarchy | > 0.90 |
| Relation similarity | Same relations to other concepts | > 0.80 |
| Combined score | Weighted combination of above | > 0.90 |

### 4.2 Fusion Decision

```
IF score > 0.95: MERGE (identical concepts)
IF 0.85 < score < 0.95: EQUIVALENT_TO mapping
IF 0.70 < score < 0.85: CLOSE_TO mapping
IF score < 0.70 AND contradiction: CONTRADICTS
IF score < 0.70 AND no contradiction: UNRELATED
```

### 4.3 Contradiction Resolution

| Contradiction Type | Resolution Strategy |
|-------------------|-------------------|
| Definition conflict | Adopt highest-authority source definition |
| Constraint conflict | Most restrictive constraint wins |
| Temporal conflict | Latest timestamp wins |
| Identity conflict | Most specific identity wins |
| Unresolvable | Flag as CONFLICTED, no automatic resolution |

### 4.4 Authority Hierarchy

| Authority Level | Sources |
|----------------|---------|
| 1 (Highest) | SUPRA Constitution |
| 2 | UGIS Standard |
| 3 | CANONICO Specification |
| 4 | ProofGraph Axioms |
| 5 | INPI Model |
| 6 | Executive Reports |
| 7 (Lowest) | External references |

---

## 5. INVARIANT IDENTIFICATION

### 5.1 Invariant Sources

| Source | Example Invariants |
|--------|-------------------|
| Constitution | Identity immutability, Graph is the only reality |
| UGIS Standard | Node identity uniqueness, Edge has two endpoints |
| CANONICO | Knowledge graph connectivity, Cycle-free evidence |
| ProofGraph | Chain reaches trust anchor, No circular proofs |
| Compiler | Deterministic compilation, Source hash immutability |

### 5.2 Invariant Record

```json
{
  "id": "inv:{uuid}",
  "name": "Identity immutability",
  "statement": "Identity never changes after creation",
  "source": "SUPRA Constitution Article 14",
  "theories": ["CONSTITUTION", "UGIS", "CANONICO"],
  "confirmed": true,
  "conflicts": [],
  "provenBy": ["ev:chain:{uuid}"]
}
```

---

## 6. AXIOM IDENTIFICATION

### 6.1 Axiom Types

| Type | Description | Example |
|------|-------------|---------|
| Foundational | Self-evident truth | "The Graph is the only reality" |
| Definitional | True by definition | "A Node has identity, type, and lifecycle" |
| Structural | True by construction | "Every Edge connects exactly two Nodes" |
| Operational | True by system design | "The Compiler is the only entry point" |

### 6.2 Axiom Record

```json
{
  "id": "ax:{uuid}",
  "name": "Graph is the only reality",
  "statement": "The Knowledge Graph is the single source of truth for all SUPRA knowledge",
  "type": "FOUNDATIONAL",
  "source": "SUPRA Constitution Article 1",
  "domain": "KNOWLEDGE",
  "provenBy": ["ev:chain:{uuid}"],
  "usedBy": ["inv:{uuid}", "cr:{uuid}"]
}
```

---

## 7. NON-DEMONSTRATED ZONES

### 7.1 Detection

| Zone Type | Description | Detection |
|-----------|-------------|-----------|
| Unproven hypothesis | Claim without evidence chain | Evidence Engine |
| Hypothesis without proof | Stated hypothesis, no supporting evidence | Evidence Engine |
| Proof without hypothesis | Evidence not connected to any claim | Evidence Engine |
| Undefined concept | Concept used but never defined | Ontology Engine |
| Unvalidated constraint | Constraint assumed but never verified | Constraint Engine |
| Unmeasured coherence | Dimension never assessed | Consistency Engine |
| Missing axiom | Gap in deductive chain | Theory Compiler |

### 7.2 Zone Record

```json
{
  "id": "gap:{uuid}",
  "type": "UNPROVEN_HYPOTHESIS",
  "statement": "System X improves compilation throughput by 50%",
  "source": "Executive Report §4.2",
  "severity": "WARNING",
  "resolution": "Design benchmark, collect data, build evidence chain"
}
```

---

## 8. THEORY COHERENCE REPORT

```json
{
  "theoryId": "theory:compiled:{uuid}",
  "timestamp": "2026-07-29T22:00:00Z",
  "sourceTheories": ["PROOFGRAPH", "CANONICO", "INPI", "UGIS", "CONSTITUTION"],
  "summary": {
    "totalConcepts": 68,
    "canonicalConcepts": 58,
    "equivalenceMappings": 42,
    "closeMappings": 18,
    "contradictions": 0,
    "unmappableConcepts": 2
  },
  "invariants": {
    "identified": 12,
    "confirmed": 12,
    "conflicted": 0
  },
  "axioms": {
    "identified": 8,
    "foundational": 3,
    "definitional": 3,
    "structural": 1,
    "operational": 1
  },
  "constraints": {
    "extracted": 48,
    "unified": 44,
    "conflicted": 4,
    "resolved": 4
  },
  "coherence": {
    "perTheory": {
      "CONSTITUTION": 1.0,
      "UGIS": 0.98,
      "CANONICO": 0.97,
      "PROOFGRAPH": 0.95,
      "INPI": 0.88
    },
    "crossTheory": 0.94,
    "global": 0.95
  },
  "nonDemonstratedZones": [
    {"type": "UNPROVEN_HYPOTHESIS", "count": 8, "severity": "WARNING"},
    {"type": "UNDEFINED_CONCEPT", "count": 2, "severity": "WARNING"},
    {"type": "UNVALIDATED_CONSTRAINT", "count": 1, "severity": "INFO"}
  ],
  "status": "CONSISTENT | WARNING | CONFLICTED"
}
```

---

## 9. THEORY GOVERNANCE

| Rule | Description |
|------|-------------|
| Authority precedence | Higher authority source wins in conflicts |
| Monotonicity | New theory additions never remove concepts |
| Traceability | Every theory concept traces to source document |
| Versioning | Every compilation produces a versioned theory |
| Conflict transparency | All unresolvable conflicts documented |
| Non-demonstration flagging | Every gap is recorded and tracked |
| Re-compilation | Source theory changes trigger re-compilation |
