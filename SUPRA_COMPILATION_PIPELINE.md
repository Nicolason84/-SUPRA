# SUPRA Compilation Pipeline — Specification V1

## Status: SPECIFICATION — SUPRA ULTIMATE CONSOLIDATED PHASE 1

| Propriété | Valeur |
|-----------|--------|
| **Version** | SUPRA_COMPILATION_PIPELINE_V1 |
| **Date** | 2026-07-29 |
| **Autorité** | SUPRA Knowledge Compiler Architecture |
| **Préséance** | Définit le pipeline unique et obligatoire |

---

## 1. PIPELINE PRINCIPLE

There is exactly one pipeline.

Every piece of information follows every step.

No step can be skipped.

No projection can be generated before the pipeline completes.

---

## 2. PIPELINE OVERVIEW

```
SOURCE
  │
  ▼
① INGESTION ──────────────────────────────────────────
  │   Parse source into normalized intermediate format
  │   Register source identity, timestamp, origin
  │   Detect source type and select parser
  │
  ▼
② NORMALISATION ──────────────────────────────────────
  │   Convert to canonical representation
  │   Standardize terminology, timestamps, identifiers
  │   Align encoding, structure, and metadata
  │
  ▼
③ EXTRACTION ────────────────────────────────────────
  │   Extract typed concepts
  │   Extract typed relations
  │   Extract constraints, patterns, evidence
  │   Extract hypotheses and principles
  │
  ▼
④ ENTITY RESOLUTION ──────────────────────────────────
  │   Resolve entity references within source
  │   Match against existing entity registry
  │   Detect duplicates and near-duplicates
  │   Assign or link identities
  │
  ▼
⑤ RELATION RESOLUTION ────────────────────────────────
  │   Resolve relation references
  │   Validate relation types against ontology
  │   Detect relation conflicts
  │   Link relations to entities
  │
  ▼
⑥ PATTERN EXTRACTION ─────────────────────────────────
  │   Detect structural patterns
  │   Classify nodes by pattern type
  │   Apply pattern constraints
  │   Register pattern instances
  │
  ▼
⑦ ONTOLOGY ALIGNMENT ─────────────────────────────────
  │   Align extracted concepts with Unified Ontology
  │   Resolve terminology conflicts
  │   Apply equivalence mappings
  │   Flag unmappable concepts
  │
  ▼
⑧ KNOWLEDGE GRAPH ────────────────────────────────────
  │   Build typed concept graph
  │   Integrate with existing Knowledge Graph
  │   Validate graph connectivity
  │   Detect orphans and cycles
  │
  ▼
⑨ CONSTRAINT GRAPH ───────────────────────────────────
  │   Evaluate all pattern constraints
  │   Detect constraint violations
  │   Build constraint satisfaction matrix
  │   Identify minimal violating subsets
  │
  ▼
⑩ EVIDENCE GRAPH ─────────────────────────────────────
  │   Build evidence chain topology
  │   Verify chain completeness
  │   Detect broken chains and circular proofs
  │   Compute trust scores
  │
  ▼
⑪ CONSISTENCY GRAPH ──────────────────────────────────
  │   Run all consistency checks
  │   Detect contradictions, incoherences
  │   Detect vocabulary, ontology, governance conflicts
  │   Compute coherence scores
  │
  ▼
⑫ ROOT CAUSE ANALYSIS ────────────────────────────────
  │   For each violation: trace root cause
  │   Identify originating sources
  │   Classify violation type and severity
  │   Assess impact scope
  │
  ▼
⑬ GRAPH VALIDATION ───────────────────────────────────
  │   Validate all graphs (structural, semantic, temporal)
  │   Verify cross-graph consistency
  │   Run final coherence check
  │   If FAIL: return to repair or reject
  │
  ▼
⑭ EXECUTIVE GRAPH ────────────────────────────────────
  │   Condense compiled knowledge for decision-making
  │   Extract key facts, risks, decisions
  │   Format for executive consumption
  │   Link to full traceability
  │
  ▼
⑮ SUPRA MEMORY ───────────────────────────────────────
  │   Persist all graphs to long-term memory
  │   Index for semantic retrieval
  │   Record compilation trace
  │   Update knowledge statistics
  │
  ▼
⑯ PROJECTIONS ────────────────────────────────────────
  │   Generate typed read-only views
  │   Validate projection consistency
  │   Publish to projection registry
  │   Notify dependent consumers
```

---

## 3. STEP DETAILS

### ① Ingestion

**Input:** Raw source (file, stream, memory frame, git commit)

**Processing:**
1. Identity source type via registry
2. Select parser from engine registry
3. Parse into normalized intermediate format
4. Register source identity with hash
5. Extract metadata (author, timestamp, version, origin)
6. Store raw source reference

**Output:** `NormalizedSource { id, type, hash, ast, metadata }`

**Validation Gate:**
- Parse success: mandatory
- Format conformance: mandatory
- Metadata completeness: warning
- Source hash uniqueness: warning on collision

---

### ② Normalisation

**Input:** `NormalizedSource`

**Processing:**
1. Convert to canonical text encoding (UTF-8)
2. Normalize whitespace and line endings
3. Standardize terminology using ontology glossary
4. Normalize timestamps to ISO 8601
5. Normalize identifiers to SUPRA ID format
6. Standardize structural elements (headings, sections, lists)

**Output:** `CanonicalSource { id, type, hash, normalizedAst, metadata }`

**Validation Gate:**
- Encoding valid: mandatory
- Timestamps parseable: mandatory
- Identifiers conform to standard: warning
- Terminology alignment: warning on unmapped terms

---

### ③ Extraction

**Input:** `CanonicalSource`

**Processing:**
1. Extract typed concepts:
   - Entities (concrete, abstract)
   - Principles (foundational truths)
   - Properties (entity characteristics)
   - Relations (connections)
   - Constraints (boundaries, rules)
   - Hypotheses (testable assertions)
   - Evidence (proofs, attestations)
   - Invariants (immutable conditions)
   - Patterns (reusable structures)
   - Mechanisms (processes, algorithms)
2. Extract typed relations:
   - Structural (contains, composes)
   - Dependency (depends-on, requires)
   - Semantic (equivalent-to, generalizes)
   - Temporal (precedes, follows)
   - Evidential (proves, supports, contradicts)
3. Extract constraint statements
4. Extract evidence statements
5. Extract pattern indicators

**Output:** `ExtractedContent { concepts: [Concept], relations: [Relation], constraints: [Constraint], evidence: [Evidence], patterns: [Pattern] }`

**Validation Gate:**
- Minimum concept extraction: warning
- Relation type validity: mandatory
- Constraint parseability: mandatory
- Evidence source reference: mandatory

---

### ④ Entity Resolution

**Input:** `ExtractedContent` + `EntityRegistry`

**Processing:**
1. For each entity reference in source:
   - Compute identity signature (type + properties + context)
   - Match against entity registry
   - If match found: link to existing identity
   - If near-match: flag for review
   - If no match: create new identity
2. Resolve aliases and synonyms
3. Detect identity collisions
4. Assign or confirm entity status (STABLE, PROVISIONAL, CONFLICTED)

**Output:** `ResolvedEntities { entities: [ResolvedEntity], newEntities: [Entity], collisions: [Collision] }`

**Validation Gate:**
- All references resolved: mandatory
- Identity uniqueness: mandatory
- Collision severity assessment: mandatory

---

### ⑤ Relation Resolution

**Input:** `ExtractedContent` + `RelationRegistry`

**Processing:**
1. For each extracted relation:
   - Verify source and target entities exist
   - Validate relation type against ontology
   - Check cardinality constraints
   - Detect duplicate relations
   - Detect contradictory relations
2. Resolve relation direction and semantics
3. Apply transitive closures where appropriate

**Output:** `ResolvedRelations { relations: [ResolvedRelation], conflicts: [Conflict] }`

**Validation Gate:**
- Source/target entity existence: mandatory
- Relation type validity: mandatory
- Cardinality compliance: mandatory
- Contradiction detection: mandatory

---

### ⑥ Pattern Extraction

**Input:** `ResolvedEntities` + `PatternLibrary`

**Processing:**
1. For each resolved entity:
   - Compare against pattern definitions
   - Score pattern match confidence
   - Assign best-matching pattern
   - Apply pattern constraints
2. Detect cross-pattern constraint incompatibilities
3. Register pattern instances

**Output:** `PatternInstances { assignments: [Entity → Pattern], incompatibilities: [Incompatibility] }`

**Validation Gate:**
- Pattern assignment completeness: warning
- Pattern constraint compatibility: mandatory
- Archetype compliance: mandatory

---

### ⑦ Ontology Alignment

**Input:** `ResolvedEntities` + `UnifiedOntology`

**Processing:**
1. For each concept:
   - Compute alignment score against ontology concepts
   - Map to best-matching ontology position
   - Detect conflicting mappings
2. Apply equivalence mappings (EQUIVALENT_TO, CLOSE_TO)
3. Register new sub-concepts when no exact match exists
4. Flag unmappable concepts

**Output:** `AlignedOntology { mappings: [Concept → OntologyPosition], conflicts: [MappingConflict], unmappable: [Concept] }`

**Validation Gate:**
- All concepts mapped: warning
- No contradictory mappings: mandatory
- Ontology hierarchy respected: mandatory
- Equivalence transitivity verified: mandatory

---

### ⑧ Knowledge Graph

**Input:** `AlignedOntology` + `ExistingKnowledgeGraph`

**Processing:**
1. Build typed concept graph nodes
2. Add typed edges (relations, dependencies, equivalences)
3. Merge with existing Knowledge Graph
4. Validate graph connectivity
5. Detect orphans (unconnected nodes)
6. Detect cycles
7. Compute graph metrics (density, connectivity, clustering)

**Output:** `KnowledgeGraph { nodes: [Node], edges: [Edge], orphans: [Node], cycles: [[Edge]], metrics: GraphMetrics }`

**Validation Gate:**
- No critical orphans: warning
- No unintended cycles: mandatory
- Graph connectivity threshold: warning
- Node/edge type validity: mandatory

---

### ⑨ Constraint Graph

**Input:** `KnowledgeGraph` + `ConstraintLibrary`

**Processing:**
1. For each node with pattern assignment:
   - Collect all applicable constraints (pattern + archetype + global)
   - Evaluate each constraint
   - Record satisfaction/violation
2. Detect minimally unsatisfiable subsets (MUS)
3. Compute constraint satisfaction ratio
4. Identify constraint conflicts

**Output:** `ConstraintGraph { evaluations: [ConstraintResult], violations: [Violation], mus: [MUS], satisfactionRatio: Float }`

**Validation Gate:**
- No CRITICAL violations: mandatory
- No ERROR violations: mandatory
- Satisfaction ratio threshold > 0.9: warning
- MUS minimality verified: mandatory

---

### ⑩ Evidence Graph

**Input:** `KnowledgeGraph` + `EvidenceRegistry`

**Processing:**
1. Build evidence chains:
   - For each claim/hypothesis: find supporting evidence chain
   - Verify chain connects to root of trust
   - Detect chain breaks
   - Detect circular evidence
2. Compute per-chain trust score
3. Detect contradictory evidence
4. Classify evidence quality

**Output:** `EvidenceGraph { chains: [EvidenceChain], breaks: [ChainBreak], contradictions: [EvidenceContradiction], trustScores: [TrustScore] }`

**Validation Gate:**
- Hypothesis → evidence chain mandatory: warning
- No chain breaks: mandatory for CRITICAL claims
- No circular evidence: mandatory
- Root of trust reachable: mandatory for all chains

---

### ⑪ Consistency Graph

**Input:** KnowledgeGraph + ConstraintGraph + EvidenceGraph

**Processing:**
1. Run all 14 conflict detection types:
   - Contradictions
   - Incoherences
   - Duplicates
   - Cycles
   - Orphan concepts
   - Missing relations
   - Unproven hypotheses
   - Proofs without hypotheses
   - Vocabulary conflicts
   - Ontology conflicts
   - Governance conflicts
   - Temporal conflicts
   - Identity conflicts
2. Compute per-dimension coherence scores
3. Compute global coherence score
4. If any CRITICAL violation: STOP — no further steps

**Output:** `ConsistencyGraph { dimensionScores: [String → Float], globalScore: Float, violations: [Violation], blockingViolations: [Violation] }`

**Validation Gate:**
- Global coherence score > 0.95: mandatory
- Zero CRITICAL violations: mandatory
- Zero blocking violations: mandatory
- All violation root causes identified: mandatory

---

### ⑫ Root Cause Analysis

**Input:** `ConsistencyGraph`

**Processing:**
1. For each violation:
   - Trace backward through pipeline to originating source
   - Identify contributing entities, relations, constraints
   - Classify violation type and severity
   - Assess impact scope (node, subgraph, graph, corpus)
2. Identify systemic weakness patterns
3. Rank violations by impact severity

**Output:** `RootCauses { causes: [RootCause], systemicWeaknesses: [SystemicWeakness], impactRanking: [Violation → Impact] }`

**Validation Gate:**
- Each violation has root cause: mandatory
- Impact scope assessed: mandatory
- Systemic weaknesses documented: warning

---

### ⑬ Graph Validation

**Input:** All graphs + All validation rules

**Processing:**
1. Structural validation:
   - Graph topology completeness
   - Node/edge type conformance
   - Schema validation
2. Semantic validation:
   - Cross-graph concept consistency
   - Term usage consistency
3. Temporal validation:
   - Timestamp ordering
   - Version monotonicity
4. Proof validation:
   - Evidence chain completeness
5. Constraint validation:
   - Cross-graph constraint consistency
6. Pattern validation:
   - Pattern integrity
7. Projection validation:
   - Projection consistency

**Output:** `ValidationReport { structural: Status, semantic: Status, temporal: Status, proof: Status, constraint: Status, pattern: Status, projection: Status, combined: PASS | FAIL }`

**Validation Gate:**
- All dimensions PASS: mandatory for publication
- If FAIL: route to Repair Engine or reject

---

### ⑭ Executive Graph

**Input:** All validated graphs

**Processing:**
1. Extract key decisions and their rationale
2. Identify critical risks and violations
3. Summarize changes from previous state
4. Compute delta metrics
5. Format for executive consumption
6. Link every statement to full traceability

**Output:** `ExecutiveGraph { decisions: [Decision], risks: [Risk], changes: [Change], metrics: Metrics, traceLinks: [SourceRef] }`

**Validation Gate:**
- Every statement traceable: mandatory
- Risk assessment complete: mandatory
- Delta from previous state: mandatory

---

### ⑮ SUPRA Memory

**Input:** All graphs + CompilationTrace

**Processing:**
1. Persist Knowledge Graph to long-term memory
2. Persist Constraint Graph
3. Persist Evidence Graph
4. Persist Consistency Graph
5. Persist Executive Graph
6. Index for semantic retrieval
7. Update knowledge statistics
8. Record compilation trace

**Output:** `MemoryRef { knowledgeRef, constraintRef, evidenceRef, consistencyRef, executiveRef, traceRef }`

**Validation Gate:**
- All graphs persisted: mandatory
- Index built: mandatory
- Trace complete: mandatory

---

### ⑯ Projections

**Input:** All persisted graphs

**Processing:**
1. Generate requested projection types:
   - Knowledge projection (concept view)
   - Constraint projection (rule view)
   - Evidence projection (proof view)
   - Consistency projection (health view)
   - Executive projection (decision view)
   - Domain-specific projections
2. Validate projection consistency against source graphs
3. Register projections in projection registry
4. Notify subscribed consumers

**Output:** `Projections { projections: [Projection], validationResults: [ValidationResult] }`

**Validation Gate:**
- Projection consistent with source: mandatory
- Projection registered: mandatory
- Consumers notified: mandatory

---

## 4. PIPELINE COORDINATION

### 4.1 Step State Machine

```
PENDING → RUNNING → PASS → NEXT_STEP
                 → FAIL → RETRY → PASS | FAIL → REJECT
                 → BLOCKING_VIOLATION → REJECT
```

### 4.2 Parallelism Rules

| Step | Parallelizable | Notes |
|------|---------------|-------|
| ①-③ | YES | Per-source-type parallel ingestion |
| ④-⑤ | NO | Must be sequential (entities before relations) |
| ⑥-⑦ | NO | Must be sequential (patterns before ontology) |
| ⑧-⑪ | YES | Graphs can be built in parallel |
| ⑫ | NO | Requires all graphs |
| ⑬ | NO | Requires all analysis |
| ⑭-⑯ | YES | Publication steps can be parallel |

### 4.3 Pipeline Modes

| Mode | Behavior | Use Case |
|------|----------|----------|
| STRICT | Stop on first CRITICAL violation | Production ingestion |
| LENIENT | Continue after violations, flag for review | Exploratory analysis |
| VALIDATE_ONLY | Execute steps ①-⑬ only, no publication | Audit mode |
| REBUILD | Full pipeline from existing memory | System recovery |
| INCREMENTAL | Only process deltas from last compilation | Continuous sync |

---

## 5. STOP CONDITIONS

The pipeline **MUST STOP** when:

| Condition | Step | Action |
|-----------|------|--------|
| Source unparseable | ① | REJECT |
| Critical identity collision | ④ | STOP + report |
| Unresolvable relation conflict | ⑤ | STOP + report |
| Ontology mapping contradiction | ⑦ | STOP + report |
| Knowledge graph contains cycle | ⑧ | STOP + report |
| Constraint unsatisfiable (CRITICAL) | ⑨ | STOP + report |
| Evidence chain break (CRITICAL) | ⑩ | STOP + report |
| Global coherence < 0.95 | ⑪ | STOP + report |
| Graph validation FAIL | ⑬ | STOP + report |

---

## 6. PIPELINE METRICS

| Metric | Collection Point | Target |
|--------|-----------------|--------|
| End-to-end latency | After step ⑯ | < 30s |
| Per-step latency | Each step | < 5s |
| Concept extraction precision | Step ③ | > 0.90 |
| Entity resolution accuracy | Step ④ | > 0.95 |
| Relation resolution accuracy | Step ⑤ | > 0.90 |
| Ontology alignment coverage | Step ⑦ | > 0.95 |
| Constraint satisfaction ratio | Step ⑨ | > 0.95 |
| Evidence chain completeness | Step ⑩ | > 0.95 |
| Global coherence score | Step ⑪ | > 0.95 |
| Graph validation pass rate | Step ⑬ | > 0.99 |
| Compilation success rate | End-to-end | > 0.90 |
