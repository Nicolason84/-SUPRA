# SUPRA Consistency Engine — Specification V1

## Status: SPECIFICATION — SUPRA ULTIMATE CONSOLIDATED PHASE 1

| Propriété | Valeur |
|-----------|--------|
| **Version** | SUPRA_CONSISTENCY_ENGINE_V1 |
| **Date** | 2026-07-29 |
| **Autorité** | SUPRA Knowledge Compiler — Consistency Engine |
| **Préséance** | Moteur de cohérence unique — supplante CANONICO_COHERENCE_ENGINE_V3 |
| **Héritage** | CANONICO_COHERENCE_ENGINE_V3 (absorbé comme détection de conflits V3) |

---

## 1. CONSISTENCY PRINCIPLE

Consistency is the **supreme law** of SUPRA Ultimate Consolidated.

No information can be published unless the system is consistent.

Coherence is measured, verified, and enforced at every step.

---

## 2. CONSISTENCY DIMENSIONS

| Dimension | Description | Scope |
|-----------|-------------|-------|
| Structural | Graph topology integrity | Knowledge Graph |
| Semantic | Meaning consistency across all sources | All Graphs |
| Temporal | Time ordering and causality | Evidence Graph |
| Evidential | Proof chain completeness | Evidence Graph |
| Constraint | Constraint satisfaction | Constraint Graph |
| Pattern | Pattern integrity and compatibility | Knowledge Graph |
| Projection | Projection accuracy relative to source | Projections |

---

## 3. VIOLATION DETECTION

### 3.1 Complete Violation Taxonomy

| # | Violation Type | Dimension | Severity | Detection Method |
|---|---------------|-----------|----------|-----------------|
| 1 | Contradiction | Semantic | CRITICAL | Logical comparison of equivalent statements |
| 2 | Incoherence | Structural | ERROR | Graph topology analysis |
| 3 | Duplicate | All | WARNING | Identity/similarity resolution |
| 4 | Cycle | Structural | CRITICAL | Graph cycle detection |
| 5 | Orphan concept | Structural | WARNING | Connectivity analysis |
| 6 | Missing relation | Structural | WARNING | Pattern constraint validation |
| 7 | Hypothesis without proof | Evidential | ERROR | Evidence chain traversal |
| 8 | Proof without hypothesis | Evidential | ERROR | Evidence chain traversal |
| 9 | Vocabulary conflict | Semantic | ERROR | Term disambiguation |
| 10 | Ontology conflict | Semantic | CRITICAL | Ontology alignment validation |
| 11 | Governance conflict | Constraint | CRITICAL | Authorization rule comparison |
| 12 | Temporal conflict | Temporal | ERROR | Timestamp alignment analysis |
| 13 | Identity conflict | Semantic | CRITICAL | Identity resolution collision |
| 14 | Constraint conflict | Constraint | CRITICAL | Constraint satisfaction analysis |
| 15 | Evidence conflict | Evidential | CRITICAL | Evidence comparison |
| 16 | Lifecycle conflict | Temporal | ERROR | State comparison across documents |
| 17 | State conflict | Constraint | CRITICAL | State space analysis |
| 18 | Projection divergence | Structural | ERROR | Graph-projection comparison |
| 19 | Pattern incompatibility | Structural | ERROR | Cross-pattern constraint comparison |
| 20 | Inheritance violation | Constraint | CRITICAL | Pattern-archetype constraint comparison |

### 3.2 Detection Pipeline

```
Input: All Graphs + Unified Ontology + Constraint Library
  │
  ▼
1. Structural Consistency Check
   ├── Graph connectivity
   ├── Orphan detection
   ├── Cycle detection
   └── Duplicate detection
  │
  ▼
2. Semantic Consistency Check
   ├── Cross-document definition alignment
   ├── Term disambiguation
   ├── Ontology position validation
   └── Equivalence transitivity verification
  │
  ▼
3. Temporal Consistency Check
   ├── Timestamp monotonicity
   ├── Causal ordering
   ├── Version ordering
   └── Cross-document temporal alignment
  │
  ▼
4. Evidence Consistency Check
   ├── Chain completeness
   ├── Hypothesis-proof balance
   ├── Circular evidence detection
   └── Evidence contradiction detection
  │
  ▼
5. Constraint Consistency Check
   ├── Constraint satisfaction evaluation
   ├── Constraint conflict detection
   ├── MUS detection
   └── Inheritance compliance
  │
  ▼
6. Pattern Consistency Check
   ├── Pattern assignment validation
   ├── Cross-pattern compatibility
   └── Archetype compliance
  │
  ▼
7. Projection Consistency Check
   ├── Source-graph alignment
   ├── Undocumented loss detection
   └── Staleness detection
  │
  ▼
8. Global Coherence Scoring
   ├── Per-dimension score computation
   ├── Global score computation
   └── Violation prioritization
```

### 3.3 Detailed Violation Detection

#### 3.3.1 Contradictions (V-001)

**Detection:** For every pair of equivalent statements across the graph, compare their truth values.

```
IF statement A ≡ statement B (via EQUIVALENT_TO chain)
AND truthValue(A) ≠ truthValue(B)
THEN CONTRADICTION(A, B, severity: CRITICAL)
```

**Resolution:** Root cause analysis → identify originating sources → propose correction (retract one statement or add qualification).

#### 3.3.2 Incoherences (V-002)

**Detection:** For every inferred statement, verify it does not contradict known facts.

```
IF inferred(A) AND known(¬A)
THEN INCOHERENCE(inferred, known, severity: ERROR)
```

#### 3.3.3 Duplicates (V-003)

**Detection:** For every pair of entities, compute identity similarity.

```
IF identitySimilarity(A, B) > threshold(0.95)
AND A ≠ B
THEN DUPLICATE(A, B, severity: WARNING)
```

#### 3.3.4 Cycles (V-004)

**Detection:** Depth-first search with back-edge detection.

```
IF hasCycle(graph, edgeType: [DEPENDS_ON, CONTAINS, PROVES, DERIVED_FROM])
THEN CYCLE(cycle, severity: CRITICAL)
```

#### 3.3.5 Orphan Concepts (V-005)

**Detection:** Find nodes with zero connections to the main graph.

```
orphans = { n ∈ graph.nodes | connectivity(n, graph) = 0 }
```

#### 3.3.6 Missing Relations (V-006)

**Detection:** For every node with a pattern assignment, verify all required relations exist.

```
FOR node IN graph.nodes:
  pattern = getPattern(node)
  FOR rel IN pattern.requiredRelations:
    IF NOT hasRelation(node, rel.type, rel.targetType):
      MISSING_RELATION(node, rel)
```

#### 3.3.7 Hypothesis-Proof Balance (V-007, V-008)

**Detection:** Evidence chain analysis.

```
hypotheses = { n ∈ graph.nodes | n.type == HYPOTHESIS }
proofs = { n ∈ graph.nodes | n.type == PROOF }
evidenceChains = buildChains(graph)

FOR h IN hypotheses:
  IF NOT hasEvidenceChain(h, evidenceChains):
    HYPOTHESIS_WITHOUT_PROOF(h)

FOR p IN proofs:
  IF NOT isConnectedToHypothesis(p, evidenceChains):
    PROOF_WITHOUT_HYPOTHESIS(p)
```

#### 3.3.8 Vocabulary Conflicts (V-009)

**Detection:** Cross-document term analysis.

```
terms = extractTerms(graph.documents)
FOR term IN terms:
  definitions = getDefinitions(term, graph.documents)
  IF len(definitions) > 1 AND notEquivalent(definitions):
    VOCABULARY_CONFLICT(term, definitions)
```

#### 3.3.9 Ontology Conflicts (V-010)

**Detection:** Ontology position analysis.

```
FOR concept IN graph.concepts:
  positions = getOntologyPositions(concept)
  IF len(positions) > 1 AND notCompatible(positions):
    ONTOLOGY_CONFLICT(concept, positions)
```

#### 3.3.10 Governance Conflicts (V-011)

**Detection:** Rule intersection analysis.

```
FOR entity IN graph.entities:
  rules = getApplicableRules(entity)
  FOR pair IN combinations(rules, 2):
    IF contradicts(pair[0], pair[1]):
      GOVERNANCE_CONFLICT(pair[0], pair[1], entity)
```

#### 3.3.11 Temporal Conflicts (V-012)

**Detection:** Cross-document temporal alignment.

```
FOR event IN graph.events:
  timestamps = getTimestamps(event, graph.documents)
  IF notConsistent(timestamps):
    TEMPORAL_CONFLICT(event, timestamps)
```

#### 3.3.12 Identity Conflicts (V-013)

**Detection:** Identity resolution collision.

```
FOR pair IN combinations(graph.entities, 2):
  collision = resolveIdentity(pair[0], pair[1])
  IF collision.type == CONFLICT:
    IDENTITY_CONFLICT(pair[0], pair[1], collision)
```

---

## 4. VIOLATION PROCESSING

### 4.1 Violation Lifecycle

```
DETECTED
  │
  ▼
CLASSIFIED (type + severity + dimension)
  │
  ▼
ROOT CAUSE ANALYSIS
  │
  ▼
IMPACT ASSESSMENT
  │
  ▼
IF blocking: STOP — no publication
IF non-blocking: REPORT + flag for repair
  │
  ▼
CORRECTION PROPOSAL (from Repair Engine)
  │
  ▼
NEW VALID STATE
```

### 4.2 Violation Record

```json
{
  "id": "V-001-{uuid}",
  "type": "CONTRADICTION",
  "dimension": "SEMANTIC",
  "severity": "CRITICAL",
  "status": "DETECTED",
  "description": "Concept 'Node' has contradictory definitions in source-A and source-B",
  "sources": [
    {"id": "source-A", "statement": "Node is an abstract entity"},
    {"id": "source-B", "statement": "Node is a concrete instantiable entity"}
  ],
  "rootCause": {
    "type": "DEFINITION_DRIFT",
    "origin": "source-B (v2.0)",
    "trigger": "Version upgrade without cross-document alignment"
  },
  "impact": {
    "scope": "GLOBAL",
    "affectedNodes": 42,
    "affectedEdges": 156,
    "affectedDocuments": ["source-A", "source-B", "source-C"]
  },
  "correction": {
    "type": "UNIFY_DEFINITION",
    "proposal": "Node is an instantiable entity (adopt source-A definition)",
    "sideEffects": ["Update 12 relation definitions", "Reclassify 3 subtypes"]
  }
}
```

---

## 5. COHERENCE SCORING

### 5.1 Per-Dimension Score

```
score(dimension) = 1.0 - (weightedViolations(dimension) / maxViolations(dimension))
```

Where:
- CRITICAL violations: weight = 1.0
- ERROR violations: weight = 0.5
- WARNING violations: weight = 0.1

### 5.2 Global Coherence Score

```
globalScore = Σ(score(d) * weight(d)) / Σ(weight(d))
```

| Dimension | Weight |
|-----------|--------|
| Structural | 0.25 |
| Semantic | 0.20 |
| Temporal | 0.10 |
| Evidential | 0.15 |
| Constraint | 0.15 |
| Pattern | 0.10 |
| Projection | 0.05 |

### 5.3 Coherence Thresholds

| Score Range | Label | Publication Allowed |
|-------------|-------|---------------------|
| 0.95 - 1.00 | CONSISTENT | YES |
| 0.85 - 0.94 | MOSTLY_CONSISTENT | YES (with review) |
| 0.70 - 0.84 | PARTIALLY_INCONSISTENT | NO |
| 0.50 - 0.69 | SIGNIFICANTLY_INCONSISTENT | NO |
| 0.00 - 0.49 | CRITICALLY_INCONSISTENT | NO |

---

## 6. COHERENCE-FIRST ENFORCEMENT

### 6.1 Compilation Gate

```
BEFORE ANY PUBLICATION:
  IF globalScore < 0.95: STOP
  IF any CRITICAL violation: STOP
  IF any blocking ERROR: STOP
  ELSE: PROCEED to publication
```

### 6.2 Continuous Coherence

The Consistency Engine is not a one-time check. It is continuously active:

| Event | Action |
|-------|--------|
| New source ingested | Re-check affected subgraph |
| Entity resolved | Re-check identity consistency |
| Relation added | Re-check constraint satisfaction |
| Evidence updated | Re-check evidence chain completeness |
| Ontology modified | Re-check all concept alignments |
| Constraint added | Re-check all pattern assignments |
| Projection generated | Re-check projection consistency |

### 6.3 Coherence Recovery

When inconsistency is detected:

```
1. IDENTIFY all violations
2. PRIORITIZE by severity + impact
3. FOR each violation:
   a. Root cause analysis
   b. Minimal correction proposal
   c. Impact simulation
   d. Apply correction
4. RE-CHECK coherence
5. IF coherent: publish new state
6. IF still incoherent: repeat from step 2
```

---

## 7. COHERENCE METRICS

| Metric | Target | Measurement |
|--------|--------|-------------|
| Global coherence score | > 0.95 | Per compilation |
| Per-dimension minimum | > 0.90 | Per compilation |
| Violation detection latency | < 100ms | Per check |
| False positive rate | < 0.01 | Per violation type |
| Recovery time (automatic) | < 5s | Per violation |
| Recovery success rate | > 0.95 | Per 1000 violations |
