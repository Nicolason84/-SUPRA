# CANONICO Constraint Library

## Status: SPECIFICATION V2 — CONSTRAINT LIBRARY

---

## 1. CONSTRAINT LIBRARY OVERVIEW

The Constraint Library is a catalog of pre-defined, reusable constraints organized by domain and archetype. These constraints serve as the default rule set for any CANONICO Graph instance. They are all registered in the Constraint Registry and can be activated, modified, or extended.

### 1.1 Library Organization

```
ARCHETYPE-level constraints (applied to all Nodes of that Archetype)
  └─ PATTERN-level constraints (applied to all Nodes of that Pattern)
    └─ DOMAIN constraints (cross-cutting, applied by node type or edge type)
      └─ GLOBAL constraints (applied to the entire Graph)
```

---

## 2. GLOBAL CONSTRAINTS

Applied to the entire Graph, regardless of Archetype or Pattern.

| ID | Constraint | Type | Severity | Expression |
|----|-----------|------|----------|------------|
| G-001 | No dangling edges | Referential | CRITICAL | `∀ edge : exists(node(edge.source)) ∧ exists(node(edge.target))` |
| G-002 | Unique identities | Identity | CRITICAL | `∀ n1, n2 : n1.id ≠ n2.id` |
| G-003 | Valid identity format | Identity | CRITICAL | `∀ n : n.id matches can:type:hash` |
| G-004 | Immutable identity | Identity | CRITICAL | `∀ n : n.id(current) = n.id(creation)` |
| G-005 | Event completeness | Audit | ERROR | `∀ mutation : ∃ event(event.target = mutation.target)` |
| G-006 | No orphan Nodes | Structural | WARNING | `∀ n : count(incoming(CONTAINS, n)) ≥ 1 ∨ n.type = ROOT` |
| G-007 | No self-loops | Structural | ERROR | `∀ e : e.source ≠ e.target` for non-reflexive EdgeTypes |
| G-008 | Timestamp monotonicity | Temporal | ERROR | `∀ e1, e2 : if e1 precedes e2 then e1.timestamp ≤ e2.timestamp` |
| G-009 | Lifecycle order | Lifecycle | CRITICAL | `∀ n : lifecycle transitions follow allowed paths` |
| G-010 | Archetype existence | Structural | CRITICAL | `∀ n : exists(archetype(n.archetype))` |
| G-011 | Pattern existence | Structural | CRITICAL | `∀ n : exists(pattern(n.pattern))` |
| G-012 | Dimension bounds | Structural | ERROR | `∀ n : ∀ dim ∈ dimensions(n) : dim ∈ [0.0, 1.0]` |

---

## 3. SYSTEM ARCHETYPE CONSTRAINTS

Applied to all Nodes with Archetype = SYSTEM.

| ID | Constraint | Type | Severity | Expression |
|----|-----------|------|----------|------------|
| SYS-001 | System must have name | Property | ERROR | `exists(name)` |
| SYS-002 | System must contain at least one RESOURCE | Relation | WARNING | `count(CONTAINS, OUTGOING) ≥ 1` |
| SYS-003 | System must have owner | Relation | ERROR | `exists(OWNS, INCOMING)` |
| SYS-004 | System cannot DEPENDS_ON itself | Relation | ERROR | `¬exists(DEPENDS_ON, source = target)` |
| SYS-005 | System trust ≥ 0.5 | Trust | WARNING | `trust ≥ 0.5` |
| SYS-006 | System lifecycle cannot skip CREATED | Lifecycle | CRITICAL | `lifecycle.history contains CREATED` |

### 3.1 OperatingSystem Pattern

| ID | Constraint | Type | Severity | Expression |
|----|-----------|------|----------|------------|
| OS-001 | Must have PROCESS capability | Property | ERROR | `capabilities contains "process_management"` |
| OS-002 | Must have at least one RUNS edge | Relation | ERROR | `count(RUNS, OUTGOING) ≥ 1` |
| OS-003 | Cannot be SUSPENDED while active processes exist | Lifecycle | ERROR | `lifecycle = SUSPENDED → count(RUNS, OUTGOING, ACTIVE) = 0` |

### 3.2 Application Pattern

| ID | Constraint | Type | Severity | Expression |
|----|-----------|------|----------|------------|
| APP-001 | Must DEPENDS_ON at least one other System | Relation | ERROR | `count(DEPENDS_ON, OUTGOING) ≥ 1` |
| APP-002 | Must have version attribute | Property | ERROR | `exists(version)` |
| APP-003 | Version must be semantic | Property | WARNING | `version matches semver` |
| APP-004 | Must have evidence of deployment | Evidence | ERROR | `exists(PROVES, INCOMING, type = deployment)` |

### 3.3 Workspace Pattern

| ID | Constraint | Type | Severity | Expression |
|----|-----------|------|----------|------------|
| WKS-001 | Must CONTAIN at least one Project | Relation | ERROR | `count(CONTAINS, OUTGOING, type = project) ≥ 1` |
| WKS-002 | Ownership dimension ≥ 0.5 | Dimension | WARNING | `ownership ≥ 0.5` |
| WKS-003 | Cannot have DEPENDS_ON cycle with contained Nodes | Dependency | CRITICAL | `¬∃ cycle in subgraph(CONTAINS ∪ DEPENDS_ON)` |

---

## 4. AGENT ARCHETYPE CONSTRAINTS

Applied to all Nodes with Archetype = AGENT.

| ID | Constraint | Type | Severity | Expression |
|----|-----------|------|----------|------------|
| AGT-001 | Agent must have at least one capability | Property | ERROR | `count(capabilities) ≥ 1` |
| AGT-002 | Agent must be created by an authorized creator | Identity | CRITICAL | `exists(CREATES, INCOMING, actor.authorized = true)` |
| AGT-003 | Agent must have evidence of identity | Evidence | ERROR | `exists(ATTESTED_BY, INCOMING)` |
| AGT-004 | Agent cannot be in CONCEPT and ACTIVE simultaneously | State | ERROR | `lifecycle ≠ CONCEPT ∨ execution = 0` |
| AGT-005 | Agent trust ≥ 0.3 | Trust | WARNING | `trust ≥ 0.3` |
| AGT-006 | Agent must OBSERVE at least one Node | Relation | ERROR | `count(OBSERVES, OUTGOING) ≥ 1` |

### 4.1 AIAgent Pattern

| ID | Constraint | Type | Severity | Expression |
|----|-----------|------|----------|------------|
| AIA-001 | Must have LEARNS edge to at least one Knowledge Node | Relation | ERROR | `count(LEARNS, OUTGOING) ≥ 1` |
| AIA-002 | Must have REMEMBERS edge for memory persistence | Relation | ERROR | `count(REMEMBERS, OUTGOING) ≥ 1` |
| AIA-003 | Cannot execute actions outside declared capabilities | Behavior | CRITICAL | `∀ action ∈ executed : action ∈ capabilities` |
| AIA-004 | Must have energy dimension between 0.0 and 1.0 | Dimension | ERROR | `energy ∈ [0.0, 1.0]` |
| AIA-005 | Trust decays 0.1 per 30 days without re-attestation | Trust | WARNING | `trust = trust - 0.1 * floor(daysSinceLastAttestation / 30)` |

### 4.2 Worker Pattern

| ID | Constraint | Type | Severity | Expression |
|----|-----------|------|----------|------------|
| WRK-001 | Must REPORTS_TO exactly one Scheduler | Relation | ERROR | `count(REPORTS_TO, OUTGOING) = 1` |
| WRK-002 | Cannot execute more than 5 concurrent tasks | Execution | ERROR | `count(EXECUTES, OUTGOING, ACTIVE) ≤ 5` |
| WRK-003 | Must report status after each execution | Evidence | ERROR | `after(EXECUTES, ∃ event(type = status_report))` |

### 4.3 Observer Pattern

| ID | Constraint | Type | Severity | Expression |
|----|-----------|------|----------|------------|
| OBS-001 | Must OBSERVE at least one Node | Relation | ERROR | `count(OBSERVES, OUTGOING) ≥ 1` |
| OBS-002 | Must generate event on state change | Behavior | ERROR | `after(MONITORS, state_change, ∃ event)` |
| OBS-003 | Observation frequency must be defined | Property | WARNING | `exists(monitoring.frequency)` |

---

## 5. RESOURCE ARCHETYPE CONSTRAINTS

Applied to all Nodes with Archetype = RESOURCE.

| ID | Constraint | Type | Severity | Expression |
|----|-----------|------|----------|------------|
| RES-001 | Resource must BELONGS_TO exactly one System | Relation | ERROR | `count(BELONGS_TO, OUTGOING) = 1` |
| RES-002 | Resource must have type attribute | Property | ERROR | `exists(type)` |
| RES-003 | Resource cannot DEPENDS_ON another Resource | Relation | WARNING | `count(DEPENDS_ON, OUTGOING) = 0` |
| RES-004 | Resource lifecycle cannot exceed parent System | Lifecycle | ERROR | `resource.lifecycle ≤ parent(CONTAINS).lifecycle` |

### 5.1 Module Pattern

| ID | Constraint | Type | Severity | Expression |
|----|-----------|------|----------|------------|
| MOD-001 | Must have dependency dimension ≥ 0.3 | Dimension | ERROR | `dependency ≥ 0.3` |
| MOD-002 | Must DEPENDS_ON or IMPORTS at least one other Module | Relation | WARNING | `count(DEPENDS_ON ∪ IMPORTS, OUTGOING) ≥ 1` |
| MOD-003 | Cannot have circular dependencies through IMPORTS | Dependency | CRITICAL | `¬∃ cycle in IMPORTS subgraph` |

### 5.2 File Pattern

| ID | Constraint | Type | Severity | Expression |
|----|-----------|------|----------|------------|
| FIL-001 | Must BELONGS_TO exactly one parent | Relation | ERROR | `count(BELONGS_TO, OUTGOING) = 1` |
| FIL-002 | Must have extension attribute | Property | INFO | `exists(extension)` |
| FIL-003 | Cannot have outgoing CONTAINS edge | Relation | ERROR | `count(CONTAINS, OUTGOING) = 0` |

### 5.3 DataStore Pattern

| ID | Constraint | Type | Severity | Expression |
|----|-----------|------|----------|------------|
| DST-001 | Must STORES data for at least one System | Relation | ERROR | `count(PROVIDES_DATA_TO, OUTGOING) ≥ 1` |
| DST-002 | Must have capacity attribute | Property | WARNING | `exists(capacity)` |
| DST-003 | Replication factor must be ≥ 1 | Property | ERROR | `exists(replication) ∧ replication ≥ 1` |

---

## 6. MEMORY ARCHETYPE CONSTRAINTS

Applied to all Nodes with Archetype = MEMORY.

| ID | Constraint | Type | Severity | Expression |
|----|-----------|------|----------|------------|
| MEM-001 | Memory must be linked to at least one Agent | Relation | ERROR | `count(REMEMBERS, INCOMING) ≥ 1` |
| MEM-002 | Memory must have creation timestamp | Temporal | ERROR | `exists(created)` |
| MEM-003 | Memory evidence must be fresh (≤ 90 days) | Evidence | WARNING | `now - evidence.timestamp ≤ 90 days` |
| MEM-004 | Memory cannot contain contradictory assertions | Semantic | ERROR | `¬ containsContradiction(content)` |

### 6.1 DecisionLog Pattern

| ID | Constraint | Type | Severity | Expression |
|----|-----------|------|----------|------------|
| DEC-001 | Must have DECIDES edge to the decision target | Relation | ERROR | `exists(DECIDES, OUTGOING)` |
| DEC-002 | Must have at least one PROVES evidence | Evidence | ERROR | `count(PROVES, OUTGOING) ≥ 1` |
| DEC-003 | Can only SUPERSEDE decisions within same domain | Semantic | ERROR | `∀ superseded : superseded.domain = this.domain` |

### 6.2 EvidenceChain Pattern

| ID | Constraint | Type | Severity | Expression |
|----|-----------|------|----------|------------|
| EVC-001 | Chain must be acyclic | Dependency | CRITICAL | `¬∃ cycle in CHAINED_TO subgraph` |
| EVC-002 | Chain length ≤ 5 | Evidence | WARNING | `maxDepth(CHAINED_TO) ≤ 5` |
| EVC-003 | Each link must have valid cryptographic signature | Integrity | CRITICAL | `∀ link : verifySignature(link.signature)` |
| EVC-004 | Chain must terminate in a root of trust | Trust | ERROR | `∃ leaf : leaf.type = ROOT_OF_TRUST` |

---

## 7. PROCESS ARCHETYPE CONSTRAINTS

Applied to all Nodes with Archetype = PROCESS.

| ID | Constraint | Type | Severity | Expression |
|----|-----------|------|----------|------------|
| PRC-001 | Process must have start and end timestamps | Temporal | ERROR | `exists(started) ∧ exists(completed ∨ failed)` |
| PRC-002 | Process must be started by an authorized Agent | Governance | CRITICAL | `exists(EXECUTES, INCOMING, actor.authorized = true)` |
| PRC-003 | Process duration must not exceed Pattern-defined max | Temporal | WARNING | `duration ≤ pattern.maxDuration` |
| PRC-004 | Process must report completion or failure | Evidence | ERROR | `lifecycle ∈ {COMPLETED, FAILED, ARCHIVED}` |

### 7.1 Mission Pattern

| ID | Constraint | Type | Severity | Expression |
|----|-----------|------|----------|------------|
| MIS-001 | Mission must have defined objective | Property | ERROR | `exists(objective)` |
| MIS-002 | Mission lifecycle: CONCEPT → CREATED → ACTIVE → COMPLETED → ARCHIVED | Lifecycle | CRITICAL | `transitions follow allowed path` |
| MIS-003 | Mission can fail (COMPLETED → FAILED transition allowed) | Lifecycle | ERROR | `transition(ACTIVE, FAILED) allowed` |
| MIS-004 | Mission must have at least one dependency resolved before ACTIVE | Dependency | ERROR | `before(ACTIVE, ∀ dep ∈ depends_on : dep.status = RESOLVED)` |
| MIS-005 | Mission cannot have cycle in dependency graph | Dependency | CRITICAL | `¬∃ cycle in DEPENDS_ON subgraph` |

### 7.2 Pipeline Pattern

| ID | Constraint | Type | Severity | Expression |
|----|-----------|------|----------|------------|
| PIP-001 | Pipeline stages must be linearly ordered | Structural | ERROR | `stages form a total order via PRECEDES` |
| PIP-002 | Each stage must VALIDATE output before passing to next | Evidence | ERROR | `∀ stage : after(stage, ∃ VALIDATES)` |
| PIP-003 | Pipeline cannot skip stages | Lifecycle | ERROR | `∀ stage : if stage PRECEDES target then stage must complete before target starts` |

### 7.3 Build Pattern

| ID | Constraint | Type | Severity | Expression |
|----|-----------|------|----------|------------|
| BLD-001 | Build must have source reference | Property | ERROR | `exists(source)` |
| BLD-002 | Build must generate exactly one output | Relation | ERROR | `count(GENERATES, OUTGOING) = 1` |
| BLD-003 | Build must have evidence of test passing | Evidence | ERROR | `exists(VALIDATES, OUTGOING, type = test)` |

---

## 8. CONCEPT ARCHETYPE CONSTRAINTS

Applied to all Nodes with Archetype = CONCEPT.

| ID | Constraint | Type | Severity | Expression |
|----|-----------|------|----------|------------|
| CPT-001 | Concept must have definition attribute | Property | ERROR | `exists(definition)` |
| CPT-002 | Concept must have at least one REFERENCE | Relation | WARNING | `count(REFERENCES, OUTGOING) ≥ 1` |
| CPT-003 | Concept cannot have lifecycle beyond ACTIVE | Lifecycle | INFO | `lifecycle ∈ {CONCEPT, CREATED, ACTIVE}` |

---

## 9. EDGE TYPE CONSTRAINTS

### 9.1 DEPENDS_ON

| ID | Constraint | Type | Severity | Expression |
|----|-----------|------|----------|------------|
| DEP-001 | DEPENDS_ON must be acyclic | Dependency | CRITICAL | `¬∃ cycle in DEPENDS_ON subgraph` |
| DEP-002 | DEPENDS_ON weight ≥ 0.3 | Structural | WARNING | `weight ≥ 0.3` |
| DEP-003 | DEPENDS_ON target must be ACTIVE | Lifecycle | ERROR | `target.lifecycle = ACTIVE` |

### 9.2 CONTAINS

| ID | Constraint | Type | Severity | Expression |
|----|-----------|------|----------|------------|
| CNT-001 | CONTAINS forms a tree (no cycles, single parent) | Structural | CRITICAL | `¬∃ cycle ∧ ∀ n : count(CONTAINS, INCOMING) ≤ 1` |
| CNT-002 | Container lifecycle ≥ contained lifecycle | Lifecycle | ERROR | `source.lifecycle ≥ target.lifecycle` |
| CNT-003 | Container must be SYSTEM or CONCEPT type | Structural | ERROR | `source.archetype ∈ {SYSTEM, CONCEPT}` |

### 9.3 PROVES

| ID | Constraint | Type | Severity | Expression |
|----|-----------|------|----------|------------|
| PRV-001 | PROVES must have evidence content | Property | ERROR | `exists(metadata.evidenceContent)` |
| PRV-002 | PROVES trust ≥ 0.7 | Trust | ERROR | `trust ≥ 0.7` |
| PRV-003 | PROVES source must be authorized | Governance | CRITICAL | `source.authorizedToProve = true` |

### 9.4 EXECUTES

| ID | Constraint | Type | Severity | Expression |
|----|-----------|------|----------|------------|
| EXE-001 | EXECUTES source must be ACTIVE | Lifecycle | ERROR | `source.lifecycle = ACTIVE` |
| EXE-002 | EXECUTES target must be ACTIVE | Lifecycle | ERROR | `target.lifecycle = ACTIVE` |
| EXE-003 | EXECUTES generates an event | Audit | ERROR | `after(EXECUTES, ∃ event)` |

### 9.5 REMEMBERS

| ID | Constraint | Type | Severity | Expression |
|----|-----------|------|----------|------------|
| REM-001 | REMEMBERS target must be MEMORY | Structural | ERROR | `target.archetype = MEMORY` |
| REM-002 | REMEMBERS must have timestamp | Temporal | ERROR | `exists(timestamp)` |
| REM-003 | REMEMBERS trust depends on source trust | Trust | WARNING | `trust ≤ source.trust` |

---

## 10. CARDINALITY CONSTRAINTS

| ID | Constraint | Pattern/Target | Cardinality |
|----|-----------|----------------|-------------|
| C-001 | CONTAINS incoming | RESOURCE | exactly 1 |
| C-002 | Reports_TO outgoing | Worker | exactly 1 |
| C-003 | BELONGS_TO outgoing | All Nodes (non-root) | exactly 1 |
| C-004 | CREATES incoming | AGENT | at least 1 |
| C-005 | OBSERVES outgoing | Observer | at least 1 |
| C-006 | DEPENDS_ON outgoing | Application | at least 1 |
| C-007 | IMPORTS outgoing | Module | 0 or more |
| C-008 | REMEMBERS incoming | MEMORY | at least 1 |

---

## 11. DOMAIN-SPECIFIC CONSTRAINTS

### 11.1 Security Domain

| ID | Constraint | Severity | Expression |
|----|-----------|----------|------------|
| SEC-001 | All Nodes must have access control attributes | ERROR | `exists(accessControl)` |
| SEC-002 | CRITICAL severity mutations require MFA | CRITICAL | `actor.mfaVerified = true` |
| SEC-003 | Trust changes must be signed | CRITICAL | `exists(signature) on trust change event` |

### 11.2 Compliance Domain

| ID | Constraint | Severity | Expression |
|----|-----------|----------|------------|
| COM-001 | Personal data Nodes must have GDPR region attribute | CRITICAL | `exists(gdprRegion)` |
| COM-002 | Financial transaction Nodes must have audit trail | CRITICAL | `count(relevantEvents) ≥ requiredCount` |
| COM-003 | Retention policy must be defined for each Node | WARNING | `exists(retentionPolicy)` |

### 11.3 Quality Domain

| ID | Constraint | Severity | Expression |
|----|-----------|----------|------------|
| QLT-001 | Each Node must have at least one observation in 30 days | WARNING | `∃ observation(timestamp > now - 30d)` |
| QLT-002 | Evidence must be verified before use in decisions | ERROR | `before(DECIDES, evidence.verified = true)` |
| QLT-003 | No ERROR or CRITICAL violations older than 7 days | WARNING | `∀ v : v.severity ≥ ERROR → v.age < 7d` |

---

## 12. CONSTRAINT EXTENSION

New constraints can be added to the library by providing:
1. Unique ID following domain convention (e.g., MYD-001)
2. Target scope (Archetype, Pattern, EdgeType, Global)
3. Constraint expression
4. Severity level
5. Description and rationale

Custom constraints follow the same validation and registration process as core constraints.

---

**CANONICO_CONSTRAINT_LIBRARY.md — V2**
**CONSTRAINT LIBRARY**
**License: Open Standard**
