# CANONICO Pattern Constraints — Complete Constraint Profiles per Pattern

## Status: SPECIFICATION V3 — PATTERN CONSTRAINT LIBRARY

---

## 1. PATTERN CONSTRAINTS OVERVIEW

This document defines the **full constraint profile** for every Pattern in the CANONICO system. Each Pattern now carries complete constraint definitions across all categories — properties, relations, lifecycle, cardinality, trust, evidence, governance, dimensions, and invariants.

---

## 2. SYSTEM PATTERN CONSTRAINTS

### 2.1 OperatingSystem

| Category | Constraint | Severity |
|----------|-----------|----------|
| RequiredProperties | name, type, version, architecture | ERROR |
| ForbiddenProperties | none | — |
| RequiredRelations | CONTAINS ≥ 1 (to RESOURCE), RUNS ≥ 1 (to PROCESS) | ERROR |
| ForbiddenRelations | DEPENDS_ON (to self) | ERROR |
| AllowedStates | CONCEPT, CREATED, ACTIVE, SUSPENDED, ARCHIVED | — |
| ForbiddenStates | DELETED | CRITICAL |
| Cardinality | CONTAINS incoming ≤ 1 | ERROR |
| AllowedTransitions | CONCEPT→CREATED, CREATED→ACTIVE, ACTIVE→SUSPENDED, ACTIVE→ARCHIVED, SUSPENDED→ACTIVE | CRITICAL |
| ForbiddenTransitions | CREATED→ARCHIVED (skip), ACTIVE→CONCEPT (rollback) | ERROR |
| TrustRules | minTrust ≥ 0.5, decayRate = 0.05/30d | WARNING |
| EvidenceRules | deploymentEvidence required, freshness ≤ 1 year | ERROR |
| GovernanceRules | lifecycleTransition(ARCHIVED) requires approval | ERROR |
| DimensionRules | ownership ∈ [0.7, 1.0], dependency ∈ [0.0, 0.4] | WARNING |
| Invariants | lifecycle monotonic (never goes backward) | CRITICAL |

### 2.2 Application

| Category | Constraint | Severity |
|----------|-----------|----------|
| RequiredProperties | name, version | ERROR |
| ForbiddenProperties | architecture | INFO |
| RequiredRelations | DEPENDS_ON ≥ 1 (to SYSTEM) | ERROR |
| ForbiddenRelations | CONTAINS (to other Application) | WARNING |
| Cardinality | BELONGS_TO (incoming) = 1 | ERROR |
| AllowedTransitions | CONCEPT→CREATED→ACTIVE→ARCHIVED | CRITICAL |
| TrustRules | minTrust ≥ 0.3 | WARNING |
| EvidenceRules | deploymentEvidence (PROVES edge with deployment type) required | ERROR |
| GovernanceRules | version update requires changelog | WARNING |

### 2.3 Workspace

| Category | Constraint | Severity |
|----------|-----------|----------|
| RequiredProperties | name, type | ERROR |
| RequiredRelations | CONTAINS ≥ 1 (Project type) | ERROR |
| ForbiddenRelations | DEPENDS_ON (to self or contained nodes causing cycle) | CRITICAL |
| Cardinality | BELONGS_TO (incoming) = 1 | ERROR |
| DimensionRules | ownership ≥ 0.5 | WARNING |
| Invariants | NO_CYCLE in CONTAINS ∪ DEPENDS_ON subgraph | CRITICAL |

### 2.4 DataStore

| Category | Constraint | Severity |
|----------|-----------|----------|
| RequiredProperties | name, type, capacity | WARNING |
| RequiredRelations | PROVIDES_DATA_TO ≥ 1 | ERROR |
| TrustRules | minTrust ≥ 0.7 | ERROR |
| DimensionRules | importance ≥ 0.5 | WARNING |
| EvidenceRules | backupEvidence required, freshness ≤ 90d | ERROR |

---

## 3. AGENT PATTERN CONSTRAINTS

### 3.1 AIAgent

| Category | Constraint | Severity |
|----------|-----------|----------|
| RequiredProperties | name, capabilities | ERROR |
| ForbiddenProperties | none | — |
| RequiredRelations | OBSERVES ≥ 1, LEARNS ≥ 1 (to MEMORY), REMEMBERS ≥ 1 (to MEMORY) | ERROR |
| ForbiddenRelations | DEPENDS_ON (to self) | ERROR |
| AllowedStates | CONCEPT, CREATED, ACTIVE, SUSPENDED, ARCHIVED | — |
| TrustRules | minTrust ≥ 0.3, decayRate = 0.1/30d without re-attestation | WARNING |
| EvidenceRules | identityAttestation required | ERROR |
| GovernanceRules | creationByAuthorizedCreator required | CRITICAL |
| DimensionRules | energy ∈ [0.0, 1.0], trust ∈ [0.3, 1.0] | ERROR |
| Invariants | capabilities must include at least one | ERROR |

### 3.2 Worker

| Category | Constraint | Severity |
|----------|-----------|----------|
| RequiredProperties | name, maxConcurrent | ERROR |
| RequiredRelations | REPORTS_TO = 1 (to Scheduler) | ERROR |
| AllowedStates | CREATED, ACTIVE, SUSPENDED, ARCHIVED | — |
| Cardinality | EXECUTES (concurrent ACTIVE) ≤ 5 | ERROR |
| EvidenceRules | statusReport after every EXECUTES required | ERROR |
| GovernanceRules | cannot self-assign tasks | CRITICAL |

### 3.3 Observer

| Category | Constraint | Severity |
|----------|-----------|----------|
| RequiredProperties | name, monitoringFrequency | WARNING |
| RequiredRelations | OBSERVES ≥ 1 | ERROR |
| AllowedTransitions | must generate event on observed state change | ERROR |

### 3.4 Scheduler

| Category | Constraint | Severity |
|----------|-----------|----------|
| RequiredProperties | name, schedulingPolicy | ERROR |
| RequiredRelations | SCHEDULES ≥ 1 (to Worker) | ERROR |
| TrustRules | minTrust ≥ 0.8 | ERROR |
| GovernanceRules | schedule changes require audit | WARNING |

---

## 4. RESOURCE PATTERN CONSTRAINTS

### 4.1 Module

| Category | Constraint | Severity |
|----------|-----------|----------|
| RequiredProperties | name, language | ERROR |
| RequiredRelations | IMPORTS ≥ 1 (to other Module) | WARNING |
| ForbiddenRelations | DEPENDS_ON (circular) | CRITICAL |
| DimensionRules | dependency ∈ [0.3, 1.0] | ERROR |
| Invariants | NO_CYCLE in IMPORTS subgraph | CRITICAL |

### 4.2 File

| Category | Constraint | Severity |
|----------|-----------|----------|
| RequiredProperties | name | ERROR |
| RequiredRelations | BELONGS_TO = 1 (parent container) | ERROR |
| ForbiddenRelations | CONTAINS (outgoing) | ERROR |
| AllowedStates | CREATED, ACTIVE, ARCHIVED | — |

### 4.3 ComputeUnit

| Category | Constraint | Severity |
|----------|-----------|----------|
| RequiredProperties | name, capacity | WARNING |
| DimensionRules | energy ∈ [0.0, 1.0], execution ∈ [0.0, 1.0] | ERROR |
| RequiredRelations | BELONGS_TO = 1 (to parent System) | ERROR |

### 4.4 NetworkResource

| Category | Constraint | Severity |
|----------|-----------|----------|
| RequiredProperties | name, address, protocol | ERROR |
| RequiredRelations | CONNECTS ≥ 1 | WARNING |
| TrustRules | minTrust ≥ 0.6 | WARNING |

---

## 5. MEMORY PATTERN CONSTRAINTS

### 5.1 EvidenceChain

| Category | Constraint | Severity |
|----------|-----------|----------|
| RequiredProperties | name, claim | ERROR |
| RequiredRelations | PROVES ≥ 1, CHAINED_TO ≥ 1 | ERROR |
| Cardinality | CHAINED_TO (depth) ≤ 5 | WARNING |
| AllowedStates | CREATED, ACTIVE, ARCHIVED | — |
| TrustRules | eachLinkTrust ≥ 0.5, chainRoot = TrustAnchor | ERROR |
| EvidenceRules | eachLink must have validSignature | CRITICAL |
| Invariants | CHAINED_TO subgraph is acyclic, terminates at root | CRITICAL |

### 5.2 DecisionLog

| Category | Constraint | Severity |
|----------|-----------|----------|
| RequiredProperties | name, decision, rationale | ERROR |
| RequiredRelations | DECIDES ≥ 1 (to decision target), PROVES ≥ 1 | ERROR |
| TrustRules | minTrust ≥ 0.7 | ERROR |
| ForbiddenRelations | DECIDES to self | ERROR |

### 5.3 ConversationLog

| Category | Constraint | Severity |
|----------|-----------|----------|
| RequiredProperties | name, participants | ERROR |
| RequiredRelations | CONTAINS ≥ 1 (messages) | ERROR |
| TransitionRules | messages must be ordered by PRECEDES | ERROR |

---

## 6. PROCESS PATTERN CONSTRAINTS

### 6.1 Mission

| Category | Constraint | Severity |
|----------|-----------|----------|
| RequiredProperties | name, objective | ERROR |
| RequiredRelations | DEPENDS_ON ≥ 1 (resolved before ACTIVE), GENERATES ≥ 1 | ERROR |
| ForbiddenRelations | DEPENDS_ON (cycle) | CRITICAL |
| AllowedStates | CONCEPT, CREATED, ACTIVE, COMPLETED, FAILED, ARCHIVED | — |
| ForbiddenStates | SUSPENDED (not applicable to Missions) | ERROR |
| AllowedTransitions | CONCEPT→CREATED→ACTIVE→COMPLETED→ARCHIVED, ACTIVE→FAILED→ARCHIVED | CRITICAL |
| EvidenceRules | completionEvidence required if COMPLETED | ERROR |
| TrustRules | minTrust ≥ 0.4 | WARNING |
| Invariants | lifecycle follows allowed path, no skips | CRITICAL |

### 6.2 Pipeline

| Category | Constraint | Severity |
|----------|-----------|----------|
| RequiredProperties | name, stages | ERROR |
| RequiredRelations | PRECEDES (stages form total order) | ERROR |
| EvidenceRules | eachStage validatesOutput before passing | ERROR |
| Invariants | stages ordered, no skip | ERROR |

### 6.3 Build

| Category | Constraint | Severity |
|----------|-----------|----------|
| RequiredProperties | name, source | ERROR |
| RequiredRelations | GENERATES = 1 (output), DEPENDS_ON ≥ 1 | ERROR |
| EvidenceRules | testEvidence required (VALIDATES edge with test type) | ERROR |
| TransitionRules | build must complete before output available | ERROR |

---

## 7. CONCEPT PATTERN CONSTRAINTS

### 7.1 Standard

| Category | Constraint | Severity |
|----------|-----------|----------|
| RequiredProperties | name, definition, version | ERROR |
| RequiredRelations | REFERENCES ≥ 1 | WARNING |
| TrustRules | minTrust ≥ 0.8 | ERROR |
| GovernanceRules | standardChanges require governance approval | CRITICAL |

### 7.2 Product

| Category | Constraint | Severity |
|----------|-----------|----------|
| RequiredProperties | name, version | ERROR |
| RequiredRelations | PRODUCES ≥ 1 | WARNING |
| EvidenceRules | certificationEvidence required | WARNING |

---

## 8. GLOBAL CROSS-PATTERN CONSTRAINTS

These constraints apply regardless of Pattern, enforced across all Nodes.

| ID | Constraint | Severity |
|----|-----------|----------|
| GLOBAL-001 | No dangling edges (every Edge endpoint exists) | CRITICAL |
| GLOBAL-002 | No duplicate identities | CRITICAL |
| GLOBAL-003 | Identity format must be can:type:hash | CRITICAL |
| GLOBAL-004 | No orphan Nodes (every Node has incoming CONTAINS or is root) | WARNING |
| GLOBAL-005 | No self-loops on non-reflexive Edge types | ERROR |
| GLOBAL-006 | Timestamp monotonicity (causes precede effects) | ERROR |
| GLOBAL-007 | Archetype existence (referenced Archetype must be registered) | CRITICAL |
| GLOBAL-008 | Pattern existence (referenced Pattern must be registered) | CRITICAL |
| GLOBAL-009 | Dimension bounds (all dimensions within [0.0, 1.0]) | ERROR |
| GLOBAL-010 | No identity mutation (identity never changes) | CRITICAL |
| GLOBAL-011 | Edge permanence (edges are never deleted, only archived) | CRITICAL |
| GLOBAL-012 | No unsupervised CRITICAL repairs | CRITICAL |

---

## 9. V3 SPECIFIC CONFLICT PATTERNS

### 9.1 Cross-Document Concept Conflict

| Property | Constraint |
|----------|-----------|
| RequiredRelations | EQUIVALENT_TO or CONTRADICTS for cross-document concepts |
| EvidenceRules | conceptMappings must be traceable to source documents |
| GovernanceRules | conflictResolution requires cross-document verification |

### 9.2 Proof Chain Incompleteness

| Property | Constraint |
|----------|-----------|
| RequiredRelations | CHAINED_TO must form complete path from claim to TrustAnchor |
| Cardinality | PROVES min = 1 per claim |
| Invariants | No orphan proof claims |

### 9.3 Vocabulary Conflict

| Property | Constraint |
|----------|-----------|
| ForbiddenProperties | duplicateNameInSameContext(alias, context) |
| RequiredRelations | EQUIVALENT_TO if same concept, different terms |
| EvidenceRules | definitionSource must be documented |

---

**CANONICO_PATTERN_CONSTRAINTS.md — V3**
**PATTERN CONSTRAINT LIBRARY**
**License: Open Standard**
