# SUPRA Knowledge Compiler — Architecture V1

## Status: ARCHITECTURE — SUPRA ULTIMATE CONSOLIDATED PHASE 1

| Propriété | Valeur |
|-----------|--------|
| **Version** | SUPRA_KNOWLEDGE_COMPILER_V1 |
| **Date** | 2026-07-29 |
| **Autorité** | SUPRA Constitution — Article 2 (Composant fondateur) |
| **Préséance** | Architecture cible — supplante tout pipeline antérieur |

---

## 1. FOUNDING PRINCIPLE

The Knowledge Compiler is the **single entry point** for all knowledge in SUPRA Ultimate Consolidated.

No information can be integrated directly into SUPRA.

All information must be compiled.

---

## 2. CORE ARCHITECTURE

```
                        ┌─────────────────────────────────────┐
                        │     SUPRA KNOWLEDGE COMPILER         │
                        │     (Single Entry Point)             │
                        └─────────────────────────────────────┘
                                      │
            ┌─────────────────────────┼─────────────────────────┐
            ▼                         ▼                         ▼
┌───────────────────────┐ ┌───────────────────────┐ ┌───────────────────────┐
│   INGESTION LAYER      │ │   PROCESSING LAYER     │ │   PUBLICATION LAYER   │
│                       │ │                       │ │                       │
│  Document Parser      │ │  Concept Extractor    │ │  Knowledge Graph      │
│  Code Parser          │ │  Entity Resolver      │ │  Constraint Graph     │
│  Git Parser           │ │  Relation Resolver    │ │  Evidence Graph       │
│  Image Parser         │ │  Pattern Engine       │ │  Consistency Graph    │
│  Memory Parser        │ │  Ontology Engine      │ │  Executive Graph      │
│  Log Parser           │ │  Constraint Engine    │ │  SUPRA Memory         │
│  Snapshot Parser      │ │  Evidence Engine      │ │  Projections          │
│  Theory Parser        │ │  Consistency Engine   │ │                       │
│                       │ │  Trust Engine         │ │                       │
│                       │ │  Root Cause Engine    │ │                       │
│                       │ │  Repair Engine        │ │                       │
│                       │ │  Projection Engine    │ │                       │
│                       │ │  Executive Engine     │ │                       │
│                       │ │  Mission Engine       │ │                       │
│                       │ │  Memory Engine        │ │                       │
└───────────────────────┘ └───────────────────────┘ └───────────────────────┘
```

## 3. COMPILER ENGINES

### 3.1 Ingestion Engines

| Engine | Input | Output | Responsibility |
|--------|-------|--------|----------------|
| Document Parser | PDF, Markdown, JSON, YAML | Normalized Document AST | Parse all document formats into a uniform AST |
| Code Parser | Swift, Python | Normalized Code AST | Parse source code with full symbol resolution |
| Git Parser | Git repository | Commit Graph + Deltas | Extract structural and temporal information from version history |
| Image Parser | PNG, JPG, SVG | Image Descriptors | Extract text (OCR), structure, and metadata from images |
| Memory Parser | SUPRA Memory snapshots | Memory Frames | Deserialize memory state into compilable frames |
| Log Parser | Log files | Structured Event Stream | Parse structured and unstructured logs into typed events |
| Snapshot Parser | System snapshots | State Vectors | Parse full-system snapshots into typed state vectors |
| Theory Parser | ProofGraph, CANONICO, INPI | Theory Corpus | Parse theory documents as compilable theory (not plain documents) |

### 3.2 Processing Engines

| Engine | Responsibility |
|--------|----------------|
| Concept Extractor | Extract typed concepts from normalized ASTs |
| Entity Resolver | Resolve entity references across sources |
| Relation Resolver | Extract and resolve typed relations between entities |
| Pattern Engine | Detect and apply structural patterns |
| Ontology Engine | Align extracted concepts with unified ontology |
| Constraint Engine | Validate all constraints, detect violations |
| Evidence Engine | Track evidence chains, verify proof completeness |
| Consistency Engine | Detect all forms of inconsistency |
| Trust Engine | Compute and propagate trust scores |
| Root Cause Engine | Trace violations to root causes |
| Repair Engine | Propose minimal corrections |
| Projection Engine | Generate validated projections |
| Executive Engine | Produce executive-ready summaries and graphs |
| Mission Engine | Map compiled knowledge to mission requirements |
| Memory Engine | Persist compiled state to SUPRA Memory |

### 3.3 Publication Engines

| Engine | Responsibility |
|--------|----------------|
| Knowledge Graph | Publish unified concept graph |
| Constraint Graph | Publish constraint satisfaction state |
| Evidence Graph | Publish evidence chain topology |
| Consistency Graph | Publish coherence state across all dimensions |
| Executive Graph | Publish decision-ready condensed graph |
| SUPRA Memory | Persist to long-term memory with full traceability |
| Projections | Generate typed read-only views |

---

## 4. COMPILATION CYCLE

Every piece of information follows this mandatory cycle:

```
DETECT
  │
  ▼
MERGE
  │
  ▼
NORMALIZE
  │
  ▼
VALIDATE
  │
  ▼
COMPILE
  │
  ▼
PUBLISH
```

### 4.1 Detect

- Identify new information from any source channel
- Register source identity, timestamp, and origin
- Classify information type (document, code, event, memory, theory)

### 4.2 Merge

- Resolve identity with existing knowledge
- Detect duplicates and near-duplicates
- Merge equivalent concepts when consistency is confirmed

### 4.3 Normalize

- Convert to canonical representation
- Align terminology with unified ontology
- Standardize timestamps, identifiers, and formats

### 4.4 Validate

- Check structural integrity
- Verify against all active constraints
- Detect contradictions, cycles, orphans, missing relations
- Run consistency engine
- If inconsistency is found: **STOP** — no publication

### 4.5 Compile

- Execute full pipeline (extraction → resolution → alignment → graphs)
- Integrate into Knowledge Graph
- Update Constraint Graph, Evidence Graph, Consistency Graph
- Generate Executive Graph

### 4.6 Publish

- Persist to SUPRA Memory
- Generate projections
- Notify dependent systems
- Record compilation trace

---

## 5. INGESTION INTERFACES

### 5.1 Source Registry

All source types register at initialization:

| Source Type | Parser | Normalizer | Schema |
|-------------|--------|------------|--------|
| PDF | Document Parser | Markdown Normalizer | `source:pdf/{hash}` |
| Markdown | Document Parser | MD Normalizer | `source:md/{hash}` |
| Swift | Code Parser | Swift Normalizer | `source:swift/{hash}` |
| Python | Code Parser | Python Normalizer | `source:py/{hash}` |
| JSON | Document Parser | JSON Normalizer | `source:json/{hash}` |
| YAML | Document Parser | YAML Normalizer | `source:yaml/{hash}` |
| Git | Git Parser | Git Normalizer | `source:git/{repo}/commit/{hash}` |
| Conversation | Document Parser | Conversation Normalizer | `source:conv/{id}` |
| Memory | Memory Parser | Memory Normalizer | `source:memory/{frame_id}` |
| Log | Log Parser | Log Normalizer | `source:log/{hash}` |
| Snapshot | Snapshot Parser | Snapshot Normalizer | `source:snap/{id}` |
| Image | Image Parser | Image Normalizer | `source:img/{hash}` |
| INPI | Theory Parser | Theory Normalizer | `source:inpi/{reference}` |
| ProofGraph | Theory Parser | Theory Normalizer | `source:proofgraph/{hash}` |
| Executive Report | Document Parser | Report Normalizer | `source:exec/{id}` |
| CANONICO | Theory Parser | Theory Normalizer | `source:canonico/{hash}` |

### 5.2 Compilation Request

```json
{
  "source": {
    "type": "pdf | md | swift | python | json | yaml | git | conv | memory | log | snap | img | inpi | proofgraph | exec | canonico",
    "uri": "string",
    "content": "raw | base64 | reference",
    "metadata": {
      "timestamp": "ISO8601",
      "origin": "string",
      "author": "string",
      "version": "string"
    }
  },
  "options": {
    "strict": true,
    "validateOnly": false,
    "projections": ["knowledge", "constraint", "evidence", "consistency", "executive"],
    "publish": true
  }
}
```

### 5.3 Compilation Response

```json
{
  "status": "COMPILED | REJECTED | PARTIAL",
  "compilationId": "kc:comp:{uuid}",
  "trace": [
    {"step": "ingestion", "status": "PASS", "duration_ms": 120},
    {"step": "normalization", "status": "PASS", "duration_ms": 45},
    {"step": "extraction", "status": "PASS", "concepts": 23, "relations": 47},
    {"step": "entityResolution", "status": "PASS", "resolved": 18, "new": 5},
    {"step": "relationResolution", "status": "PASS", "resolved": 42, "new": 5},
    {"step": "patternExtraction", "status": "PASS", "patterns": 3},
    {"step": "ontologyAlignment", "status": "PASS", "aligned": 20, "conflicts": 0},
    {"step": "constraintValidation", "status": "PASS", "violations": 0},
    {"step": "consistencyCheck", "status": "PASS", "score": 0.97},
    {"step": "graphPublish", "status": "PASS", "graphs": ["knowledge", "constraint", "evidence", "consistency", "executive"]}
  ],
  "violations": [],
  "graphs": {
    "knowledge": "kc:graph:knowledge:{uuid}",
    "constraint": "kc:graph:constraint:{uuid}",
    "evidence": "kc:graph:evidence:{uuid}",
    "consistency": "kc:graph:consistency:{uuid}",
    "executive": "kc:graph:executive:{uuid}"
  },
  "projections": ["kc:proj:{type}:{uuid}"],
  "memoryRef": "kc:memory:{uuid}"
}
```

### 5.4 Rejection Response

```json
{
  "status": "REJECTED",
  "compilationId": "kc:comp:{uuid}",
  "reason": "INCONSISTENCY_DETECTED",
  "violations": [
    {
      "type": "CONTRADICTION | INCOHERENCE | DUPLICATE | CYCLE | ORPHAN | MISSING_RELATION | UNPROVEN_HYPOTHESIS | PROOF_WITHOUT_HYPOTHESIS | VOCABULARY_CONFLICT | ONTOLOGY_CONFLICT | GOVERNANCE_CONFLICT | TEMPORAL_CONFLICT | IDENTITY_CONFLICT",
      "severity": "CRITICAL | ERROR | WARNING",
      "description": "string",
      "rootCause": "string",
      "impact": "string",
      "minimalCorrection": "string",
      "sources": ["source1", "source2"]
    }
  ],
  "trace": {"lastCompletedStep": "consistencyCheck", "failedAt": "consistencyCheck"}
}
```

---

## 6. TRACEABILITY

Every compilation produces an immutable trace:

| Artifact | Description |
|----------|-------------|
| Compilation ID | Unique identifier for the compilation session |
| Source hash | Cryptographic hash of source content |
| Step trace | Every pipeline step with status, duration, and result |
| Graph references | All published graph IDs |
| Violation record | All detected violations with root cause |
| Decision record | Merge/skip/reject decisions with rationale |
| Dependency record | All external dependencies accessed during compilation |

---

## 7. COMPONENT DECOMMISSIONING

The following components are now **internal** to the Knowledge Compiler:

| Previous Component | New Role | Status |
|--------------------|----------|--------|
| CANONICO Knowledge Graph | Internal: Concept Extraction + Knowledge Graph publication | ABSORBED |
| CANONICO Ontology | Internal: Ontology Engine + Unified Ontology | ABSORBED |
| CANONICO Constraint Engine | Internal: Constraint Engine | ABSORBED |
| CANONICO Coherence Engine | Internal: Consistency Engine | ABSORBED |
| CANONICO Evidence Model | Internal: Evidence Engine | ABSORBED |
| CANONICO Root Cause Engine | Internal: Root Cause Engine | ABSORBED |
| CANONICO Repair Engine | Internal: Repair Engine | ABSORBED |
| CANONICO Validation Model | Internal: Compilation Validation Gate | ABSORBED |
| CANONICO Projection Model | Internal: Projection Engine | ABSORBED |
| CANONICO Pattern Library | Internal: Pattern Engine | ABSORBED |
| CANONICO Pattern Constraints | Internal: Pattern Constraint Library | ABSORBED |
| CANONICO Node/Edge Model | Internal: Knowledge Graph primitives | ABSORBED |
| CANONICO ID Standard | Internal: Entity Resolution identity rules | ABSORBED |
| CANONICO Graph Health Model | Internal: Graph health scoring | ABSORBED |
| CANONICO Inconsistency Model | Internal: Inconsistency classification | ABSORBED |
| CANONICO Digital Passport | Internal: Source certificate generation | ABSORBED |
| CANONICO ProofGraph Mapping | Internal: Theory Compiler mapping tables | ABSORBED |
| ProofGraph | Internal: Theory Corpus reference | ABSORBED |
| INPI mappings | Internal: Theory Corpus reference | ABSORBED |

---

## 8. COHERENCE FIRST

Every compilation must pass all consistency checks before publication.

### 8.1 Detectable Violations

| Violation Type | Detection Method | Blocking |
|----------------|-----------------|----------|
| Contradictions | Logical comparison of equivalent concepts | YES |
| Incoherences | Constraint satisfaction analysis | YES |
| Duplicates | Identity resolution with similarity scoring | WARNING |
| Cycles | Graph cycle detection | YES |
| Orphan concepts | Graph connectivity analysis | WARNING |
| Missing relations | Pattern constraint validation | WARNING |
| Unproven hypotheses | Evidence chain traversal | WARNING |
| Proofs without hypotheses | Evidence chain traversal | WARNING |
| Vocabulary conflicts | Term disambiguation | YES |
| Ontology conflicts | Ontology alignment validation | YES |
| Governance conflicts | Authorization rule comparison | YES |
| Temporal conflicts | Timestamp alignment analysis | YES |
| Identity conflicts | Identity resolution collision detection | YES |

### 8.2 Violation Processing

```
Violation detected
  │
  ▼
Root Cause Analysis
  │
  ▼
Impact Assessment
  │
  ▼
Minimal Correction Proposal
  │
  ▼
New Valid State (if correction applied)
  │
  ▼
Re-compile or Report
```

---

## 9. COMPILER STATES

| State | Description |
|-------|-------------|
| INITIALIZED | Compiler loaded, all engines registered |
| IDLE | Waiting for compilation request |
| INGESTING | Parsing and normalizing source |
| EXTRACTING | Concept and relation extraction |
| RESOLVING | Entity and relation resolution |
| VALIDATING | Constraint and consistency validation |
| COMPILING | Graph integration |
| PUBLISHING | Persisting to memory and generating projections |
| REJECTED | Compilation stopped due to violation |
| ERROR | System error during compilation |
| SHUTDOWN | Compiler terminated |

---

## 10. MODULARITY

All engines are modular and independently replaceable:

| Engine | Interface | Default Implementation | Replaceable |
|--------|-----------|----------------------|-------------|
| Document Parser | `parse(DocumentSource) -> DocumentAST` | Multi-format parser | YES |
| Code Parser | `parse(CodeSource) -> CodeAST` | Tree-sitter based | YES |
| Concept Extractor | `extract(NormalizedAST) -> [Concept]` | Pattern-based extractor | YES |
| Entity Resolver | `resolve([Entity]) -> [ResolvedEntity]` | Similarity + graph resolver | YES |
| Relation Resolver | `resolve([Relation]) -> [ResolvedRelation]` | Pattern-based resolver | YES |
| Ontology Engine | `align([Concept]) -> AlignedOntology` | Mapping-table aligner | YES |
| Constraint Engine | `validate(GraphState) -> [Violation]` | SAT-based solver | YES |
| Consistency Engine | `check(GraphState) -> ConsistencyReport` | Multi-dimension checker | YES |
| Evidence Engine | `verify([Evidence]) -> [VerificationResult]` | Chain traversal verifier | YES |
| Trust Engine | `compute(GraphState) -> TrustScores` | Propagation-based scorer | YES |
| Root Cause Engine | `trace(Violation) -> RootCause` | Backward chain tracer | YES |
| Repair Engine | `repair(Violation) -> [Proposal]` | Minimal fix proposer | YES |
| Projection Engine | `project(GraphState, Type) -> Projection` | Typed view generator | YES |
| Executive Engine | `summarize(GraphState) -> ExecutiveGraph` | Relevance-based summarizer | YES |
| Mission Engine | `map(GraphState, Mission) -> MissionContext` | Requirement-mapping engine | YES |
| Memory Engine | `persist(CompilationResult) -> MemoryRef` | Versioned memory store | YES |
| Theory Parser | `parse(TheorySource) -> TheoryCorpus` | Theory-aware parser | YES |
| Git Parser | `parse(GitSource) -> GitGraph` | Commit graph extractor | YES |

---

## 11. DEPENDENCIES

```
Knowledge Compiler
  ├── SUPRA Constitution (compliance)
  ├── SUPRA Unified Ontology (alignment target)
  ├── SUPRA Constraint Library (constraint definitions)
  ├── SUPRA Pattern Library (pattern definitions)
  ├── SUPRA Memory (persistence)
  ├── SUPRA Executive Canon (executive graph formatting)
  ├── CANONICO sub-systems (absorbed as internal engines)
  └── Theory Corpus (ProofGraph, INPI, CANONICO documents)
```

---

## 12. CONSTRAINTS

| Constraint | Rule |
|------------|------|
| Single Entry | No information bypasses the Compiler |
| Deterministic | Same input always produces same output |
| Traceable | Every output is traceable to its source(s) |
| Modular | Every engine is independently replaceable |
| Coherent | No publication before consistency validation |
| Immutable | Published graphs are append-only |
| Versioned | Every compilation produces a versioned snapshot |
| Observable | All operations produce structured traces |
