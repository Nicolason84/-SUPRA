# CANONICO Root Cause Engine — V3 Extended

## Status: SPECIFICATION V3 — ROOT CAUSE ANALYSIS (EXTENDED)

---

## 1. V3 ROOT CAUSE OVERVIEW

The V3 Root Cause Engine extends V2 backward chaining with **cross-document root cause analysis**, **systemic weakness detection**, **corpus-level causal chains**, and **minimum correction with propagation simulation**.

### 1.1 V3 Extensions

| Capability | V2 | V3 |
|-----------|-----|-----|
| Scope | Graph-local | Cross-document, cross-corpus |
| Causal chains | Within single Graph | Across documents, concepts, ontologies |
| Root causes | Constraint violations | Plus: concept contradictions, mapping errors |
| Systemic weakness | Optional field | Full systemic weakness analysis |
| Correction | Repair proposal | Plus: concept reconciliation, mapping correction |
| Expected state | Post-fix state | Plus: post-correction corpus coherence |

### 1.2 V3 Root Cause Principle

A conflict in V3 is not merely a violation of a constraint — it is a **measurable deviation from corpus coherence**. The root cause is the earliest document, concept, relation, or mapping decision that, if corrected, would eliminate the conflict and all its downstream effects across the entire corpus.

---

## 2. V3 CAUSAL CHAIN MODEL

### 2.1 Extended Causal Chain

```
Conflict (V3)
   ↑
Direct Cause (the immediate document-level discrepancy)
   ↑
Contributing Factors (conditions enabling the discrepancy)
   ↑
Root Cause (the earliest decision or omission)
   ↑
Document Origin (the source document introducing the cause)
   ↑
Systemic Weakness (the broader vulnerability in corpus design)
```

### 2.2 Causal Chain Structure (V3)

```
CausalChainV3 {
  conflict: Identity                    [the V3 conflict]
  
  directCause: CrossDocumentCause {
    type: CauseType
    description: String
    documents: [DocumentRef]            [documents involved]
    concepts: [ConceptRef]              [concepts involved]
    state: StateSummary
  }
  
  contributingFactors: [CrossDocumentCause] {
    type: CauseType
    description: String
    weight: Float
    sourceDocument: DocumentRef
  }
  
  rootCause: CrossDocumentCause {
    type: CauseType
    description: String
    originDocument: DocumentRef          [first document introducing cause]
    originConcept: ConceptRef            [first concept affected]
    fix: RemediationProposal             [minimal fix]
    expectedState: CorpusStateDescription
  }
  
  systemicWeakness: SystemicWeakness? {
    pattern: WeaknessPattern
    description: String
    affectedDocuments: [DocumentRef]
    preventionStrategy: String
  }
  
  propagation: PropagationAnalysis {
    affectedConcepts: [ConceptRef]
    affectedRelations: [RelationRef]
    affectedDocuments: [DocumentRef]
    impactScore: Float
    cascadeDepth: Int
  }
  
  confidence: Float
}
```

### 2.2 V3 Cause Types

| Cause Type | Description | Example |
|-----------|-------------|---------|
| `MISSING_CONCEPT` | Required concept not defined | "Proof" used but not defined |
| `CONTRADICTORY_DEFINITION` | Two documents define same term differently | "Node" in UGIS vs "Vertex" in ProofGraph |
| `MAPPING_ERROR` | Incorrect cross-document mapping | EQUIVALENT_TO mapping contradicts actual definitions |
| `AMBIGUOUS_TERM` | Term used with multiple meanings | "Edge" as graph edge vs competitive edge |
| `MISSING_RELATION` | Required cross-concept relation missing | "Proves" relation not defined between evidence and claim |
| `INCONSISTENT_CONSTRAINT` | Conflicting constraints across documents | MinTrust = 0.3 vs MinTrust = 0.7 |
| `HIERARCHY_VIOLATION` | Concept placed at wrong hierarchy level | "Agent" as Resource vs as Archetype |
| `INCOMPLETE_CHAIN` | Evidence chain does not reach root | Proof chain terminates at non-anchor |
| `CIRCULAR_DEPENDENCY` | Concepts depend on each other cyclically | A defined in terms of B, B defined in terms of A |
| `VERSION_CONFLICT` | Document versions incompatible | V2 document contradicts V1 of same standard |
| `SCOPE_VIOLATION` | Concept used outside defined scope | "Archived" lifecycle applied to axioms |
| `INHERITANCE_VIOLATION` | Pattern relaxes ancestor constraint | Pattern allows what Archetype forbids |
| `DUPLICATE_CONCEPT` | Same concept defined in multiple places | "Trust" defined in 3 separate sections |
| `ORPHAN_CONCEPT` | Concept defined but never used | "HyperEdge" defined but never referenced |
| `UNTESTED_HYPOTHESIS` | Claim made without evidence | Performance claim with no benchmark |

---

## 3. V3 BACKWARD CHAINING ALGORITHM

### 3.1 Cross-Document Backward Chaining

```
FUNCTION findCrossDocumentRootCause(conflict) → CausalChainV3

  // Phase 1: Capture the conflict state
  state = captureConflictState(conflict)
  
  // Phase 2: Identify immediate cause in documents
  immediateDocs = getDocumentsInvolved(conflict)
  directCause = findImmediateDocumentDiscrepancy(conflict, immediateDocs)
  
  // Phase 3: Walk document dependencies backward
  factors = []
  currentCause = directCause
  
  WHILE currentCause.hasPredecessor():
    pred = currentCause.predecessor()
    
    // Check each predecessor document
    doc = pred.sourceDocument
    
    // Find earlier document that introduced the discrepancy
    earlierDoc = findEarlierDocument(doc, pred.concept)
    
    IF earlierDoc != nil:
      factors.add(CrossDocumentCause(
        type: pred.type,
        description: pred.description,
        weight: computeWeight(pred),
        sourceDocument: earlierDoc
      ))
      currentCause = pred
    ELSE:
      BREAK  // reached root
  
  // Phase 4: Identify root document
  rootCause = factors.last ?? directCause
  rootDoc = rootCause.sourceDocument
  
  // Phase 5: Generate minimal fix
  fix = proposeCrossDocumentFix(conflict, rootCause)
  
  // Phase 6: Analyze propagation
  propagation = analyzeCorpusPropagation(fix)
  
  // Phase 7: Detect systemic weakness
  weakness = detectSystemicWeakness(rootCause, factors)
  
  RETURN CausalChainV3(
    conflict: conflict.id,
    directCause: directCause,
    contributingFactors: factors,
    rootCause: rootCause,
    systemicWeakness: weakness,
    propagation: propagation,
    confidence: computeConfidence(chain)
  )
```

### 3.2 Document Dependency Tracing

```
FUNCTION findEarlierDocument(doc, concept) → DocumentRef?

  // Find the earliest document that defines this concept
  allDocs = getDocumentsDefining(concept)
  sortedDocs = sortByVersion(allDocs)
  
  IF sortedDocs.first != doc:
    RETURN sortedDocs.first  // earlier document exists
  
  // Check for dependencies
  FOR dependency IN doc.dependencies:
    IF dependency.defines(concept):
      RETURN dependency
  
  RETURN nil  // this document is the origin
```

---

## 4. V3 ROOT CAUSE PATTERNS

### 4.1 Cross-Document Definition Conflict

```
Conflict: "Node" defined differently in UGIS and ProofGraph
  ↓ Direct Cause
ProofGraph uses "Vertex" for the same abstraction
  ↓ Contributing Factor
ProofGraph was developed independently from UGIS
  ↓ Root Cause
No cross-document vocabulary alignment was performed
  ↓ Document Origin
ProofGraph v1.0 initial specification
  ↓ Fix
Add EQUIVALENT_TO mapping: ProofGraph Vertex → CANONICO Node
  ↓ Expected State
"Vertex" in ProofGraph correctly mapped to "Node" in UGIS
```

### 4.2 Missing Concept Pattern

```
Conflict: "Proof Chain" concept used but not defined in UGIS standard
  ↓ Direct Cause
UGIS refers to "evidence chain" but ProofGraph uses "proof chain"
  ↓ Contributing Factor
Terminology bridge was not established between standards
  ↓ Root Cause
EvidenceChain pattern was defined without ProofGraph alignment
  ↓ Fix
Register "Proof Chain" as alias for "Evidence Chain" in Concept Registry
```

### 4.3 Constraint Contradiction Pattern

```
Conflict: MinTrust = 0.3 (AGENT pattern) vs MinTrust = 0.7 (Proves edge)
  ↓ Direct Cause
Agent must trust ≥ 0.3, but agent's PROVES edges require trust ≥ 0.7
  ↓ Contributing Factor
Trust rules were defined independently per Pattern
  ↓ Root Cause
No cross-constraint consistency check was performed
  ↓ Fix
Harmonize: PROVES trust ≤ source trust, or adjust Agent MinTrust
```

### 4.4 Incomplete Proof Chain Pattern

```
Conflict: Claim "System is coherent" has incomplete proof chain
  ↓ Direct Cause
Chain terminates at intermediate node, not at TrustAnchor
  ↓ Contributing Factor
TrustAnchor not defined in the document domain
  ↓ Root Cause
EvidenceChain invariant "terminates at root" was not enforced
  ↓ Fix
Add TrustAnchor at domain root, complete the evidence chain
```

### 4.5 Systemic Weakness Pattern

```
Conflict: Multiple definitional conflicts across corpus
  ↓ Systemic Weakness
No centralized terminology management process
  ↓ Prevention
Establish Terminology Authority with cross-document review mandate
  ↓ Affected Documents
All corpus documents
```

---

## 5. V3 CONFIDENCE SCORING

### 5.1 Extended Confidence Factors

| Factor | Impact | V3 Addition |
|--------|--------|-------------|
| Event log completeness | Higher → higher confidence | + Cross-document version history |
| Causal path convergence | More paths → higher | + Multiple document sources confirm |
| Temporal proximity | Shorter → higher | + Document version proximity |
| Chain length | Shorter → higher | + Cross-document hops |
| Source diversity | More sources → higher | + Independent document confirmation |
| **Mapping consistency** | Consistent → higher | + Ontology mapping alignment |
| **Evidence strength** | Stronger → higher | + ProofGraph chain verification |

### 5.2 Confidence Levels (V3)

| Level | Score | Meaning |
|-------|-------|---------|
| CERTAIN | 1.0 | Root cause proven by direct document evidence |
| HIGH | 0.8–0.99 | Multiple independent documents confirm |
| MEDIUM | 0.5–0.79 | Single document line, no contradiction |
| LOW | 0.25–0.49 | Inferred from incomplete corpus |
| SPECULATIVE | < 0.25 | Best guess, no direct evidence |

---

## 6. MINIMUM CORRECTION (V3)

### 6.1 Correction Types

| Type | Description |
|------|-------------|
| Concept addition | Register missing concept in Concept Registry |
| Concept reconciliation | Resolve contradictory definitions |
| Mapping correction | Fix incorrect EQUIVALENT_TO mapping |
| Constraint adjustment | Harmonize conflicting constraints |
| Document update | Suggest document revision |
| Evidence completion | Add missing evidence chain links |
| Terminology alignment | Standardize vocabulary across corpus |

### 6.2 Correction Properties

- **Necessity**: Every correction is required (removing any leaves conflict unresolved)
- **Sufficiency**: Applying all corrections resolves the conflict
- **Minimality**: No smaller set of corrections resolves the conflict
- **Traceability**: Every correction is traced to affected documents

---

## 7. EDGE CASES (V3)

| Case | Behavior |
|------|----------|
| Multiple document origins | Report all with confidence ranking |
| Circular cross-document dependency | Systemic weakness, not locally fixable |
| No origin document found | Report as "Corpus-level gap", LOW confidence |
| Self-conflicting document | Document contradicts itself → internal root cause |
| Third document reference | Root cause in document C, visible in A and B |
| Historical root cause | Origin document is superseded → still reported as root |

---

**CANONICO_ROOT_CAUSE_ENGINE.md — V3**
**CROSS-CORPUS ROOT CAUSE ANALYSIS**
**License: Open Standard**
