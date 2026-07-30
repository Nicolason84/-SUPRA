# SUPRA Constraint Framework — Specification V1

## Status: SPECIFICATION — SUPRA ULTIMATE CONSOLIDATED PHASE 1

| Propriété | Valeur |
|-----------|--------|
| **Version** | SUPRA_CONSTRAINT_FRAMEWORK_V1 |
| **Date** | 2026-07-29 |
| **Autorité** | SUPRA Knowledge Compiler — Constraint Engine |
| **Préséance** | Cadre de contraintes unique — supplante CANONICO_CONSTRAINT_ENGINE_V3 |
| **Héritage** | CANONICO_CONSTRAINT_ENGINE_V3 (absorbé comme moteur interne) |

---

## 1. CONSTRAINT PRINCIPLE

The Knowledge Compiler is a constraint satisfaction system.

Every compilation is a constraint satisfaction problem.

A compilation is valid iff all constraints are simultaneously satisfied.

---

## 2. CONSTRAINT TAXONOMY

### 2.1 By Scope

| Scope | Applies To | Priority |
|-------|-----------|----------|
| Global | Entire knowledge graph | HIGHEST |
| Archetype | All nodes of an archetype | HIGH |
| Pattern | All nodes of a pattern | HIGH |
| Instance | Specific node instance | NORMAL |
| Source | Specific source type | NORMAL |
| Temporal | Specific time window | LOW |

### 2.2 By Nature

| Nature | Description | Example |
|--------|-------------|---------|
| Required | Must be true | "Every node must have an identity" |
| Forbidden | Must not be true | "No circular dependencies" |
| Cardinality | Exact/min/max count | "Each node has 1-5 outgoing edges" |
| Range | Value within bounds | "TrustScore between 0.0 and 1.0" |
| Conditional | If A then B | "If node is Agent, it must have a capability" |
| Temporal | Time-based rule | "Timestamp must be monotonically increasing" |
| Invariant | Always true | "Identity is immutable" |
| Transition | State change rule | "Cannot transition from ACTIVE to DELETED" |

### 2.3 By Severity

| Severity | Compilation Impact | Report Color |
|----------|-------------------|--------------|
| CRITICAL | Blocking — compilation stops | RED |
| ERROR | Blocking — must be resolved | RED |
| WARNING | Non-blocking — reported | YELLOW |
| INFO | Informational | BLUE |

---

## 3. CONSTRAINT CATEGORIES

### 3.1 Structural Constraints

| ID | Name | Rule | Severity |
|----|------|------|----------|
| SC-01 | Node identity | Every node has a unique identity | CRITICAL |
| SC-02 | Edge identity | Every edge has a unique identity | CRITICAL |
| SC-03 | Edge endpoints | Every edge connects two existing nodes | CRITICAL |
| SC-04 | No self-loops | No edge connects a node to itself | ERROR |
| SC-05 | Type conformance | Node/edge types exist in ontology | ERROR |
| SC-06 | Graph connectivity | Knowledge graph is weakly connected | WARNING |
| SC-07 | No duplicate nodes | No two nodes have identical identity | ERROR |
| SC-08 | No duplicate edges | No two edges have identical source+target+type | WARNING |

### 3.2 Semantic Constraints

| ID | Name | Rule | Severity |
|----|------|------|----------|
| SM-01 | Definition uniqueness | Each concept has exactly one canonical definition | ERROR |
| SM-02 | No polysemy | No term maps to multiple concepts | WARNING |
| SM-03 | No synonym collision | Each concept has one canonical name | WARNING |
| SM-04 | Hierarchy validity | Concept hierarchy is acyclic | CRITICAL |
| SM-05 | Equivalence transitivity | A≡B AND B≡C → A≡C | ERROR |
| SM-06 | Relation consistency | EQUIVALENT_TO relations are symmetric | ERROR |
| SM-07 | Type consistency | Same entity type across all sources | ERROR |

### 3.3 Temporal Constraints

| ID | Name | Rule | Severity |
|----|------|------|----------|
| TC-01 | Monotonic timestamps | Timestamps increase monotonically | ERROR |
| TC-02 | No future timestamps | No event timestamp is in the future | ERROR |
| TC-03 | Causal ordering | Cause precedes effect | ERROR |
| TC-04 | Version ordering | Document versions increase monotonically | ERROR |
| TC-05 | Temporal consistency | Same event has same timestamp across sources | ERROR |
| TC-06 | Temporal scope | Entity lifecycle within valid time range | ERROR |

### 3.4 Identity Constraints

| ID | Name | Rule | Severity |
|----|------|------|----------|
| IC-01 | ID uniqueness | Every identity is globally unique | CRITICAL |
| IC-02 | ID immutability | Identity never changes after creation | CRITICAL |
| IC-03 | ID format | Identity conforms to SUPRA ID standard | ERROR |
| IC-04 | Cross-document ID consistency | Same entity has same ID across documents | ERROR |
| IC-05 | No ID reuse | Deleted IDs are never reused | ERROR |

### 3.5 Evidence Constraints

| ID | Name | Rule | Severity |
|----|------|------|----------|
| EC-01 | Claim evidence | Every claim has at least one evidence | ERROR |
| EC-02 | Chain completeness | Evidence chain reaches a trust anchor | CRITICAL |
| EC-03 | No circular evidence | Evidence chains are acyclic | CRITICAL |
| EC-04 | Evidence freshness | Evidence is not expired | WARNING |
| EC-05 | Evidence diversity | Not all evidence from same source | WARNING |
| EC-06 | Hypothesis-proof balance | Every hypothesis has a proof; every proof has a hypothesis | ERROR |

### 3.6 Trust Constraints

| ID | Name | Rule | Severity |
|----|------|------|----------|
| TR-01 | TrustScore range | TrustScore in [0.0, 1.0] | ERROR |
| TR-02 | Trust propagation | Trust score decreases with chain length | WARNING |
| TR-03 | Minimum trust | Critical claims require minTrust | ERROR |
| TR-04 | Trust decay | Trust decays over time | WARNING |

### 3.7 Governance Constraints

| ID | Name | Rule | Severity |
|----|------|------|----------|
| GC-01 | Authorization | Every mutation has authorized agent | CRITICAL |
| GC-02 | No authority conflict | No two rules grant conflicting permissions | CRITICAL |
| GC-03 | No deadlock | Approval chains can always complete | ERROR |
| GC-04 | Compliance coverage | Every entity is governed by at least one rule | WARNING |

### 3.8 Lifecycle Constraints

| ID | Name | Rule | Severity |
|----|------|------|----------|
| LC-01 | Valid state | Entity state is in allowed set | ERROR |
| LC-02 | Valid transition | State transition is in allowed set | ERROR |
| LC-03 | Lifecycle monotonicity | Lifecycle progresses forward | WARNING |
| LC-04 | Cross-document lifecycle | Same entity has compatible states across docs | ERROR |

### 3.9 Pattern Constraints

| ID | Name | Rule | Severity |
|----|------|------|----------|
| PC-01 | Pattern conformance | Node matches its assigned pattern | ERROR |
| PC-02 | Pattern inheritance | Pattern respects archetype constraints | CRITICAL |
| PC-03 | Cross-pattern compatibility | No incompatible constraints between patterns | ERROR |
| PC-04 | Required relations | Pattern-required relations exist | ERROR |

### 3.10 Invariant Constraints

| ID | Name | Rule | Severity |
|----|------|------|----------|
| IV-01 | Identity immutability | Identity cannot change | CRITICAL |
| IV-02 | Graph acyclicity | Knowledge graph has no unintended cycles | CRITICAL |
| IV-03 | Evidence chain acyclicity | Evidence chains are acyclic | CRITICAL |
| IV-04 | Ontology hierarchy acyclicity | Ontology hierarchy is acyclic | CRITICAL |
| IV-05 | Source integrity | Source content hash is immutable | CRITICAL |
| IV-06 | Compilation determinism | Same input produces same output | CRITICAL |

---

## 4. CONSTRAINT EVALUATION

### 4.1 Evaluation Pipeline

```
Input: GraphState + ConstraintSet
  │
  ▼
1. Collect applicable constraints
   ├── Global constraints (always apply)
   ├── Scope constraints (by node/edge type, archetype, pattern)
   └── Instance constraints (node/edge specific)
  │
  ▼
2. Merge constraint sets
   ├── Union of all applicable constraints
   └── Resolve duplicates (most restrictive wins)
  │
  ▼
3. Evaluate each constraint
   ├── For each constraint: test against GraphState
   ├── Collect PASS/FAIL results
   └── Detect constraint conflicts
  │
  ▼
4. Detect Minimal Unsatisfiable Subsets (MUS)
   ├── Find smallest constraint subset causing unsatisfiability
   └── For each MUS: identify conflict pattern
  │
  ▼
5. Generate Violation Report
   ├── Violation: constraint + state + cause
   ├── Severity: CRITICAL | ERROR | WARNING | INFO
   └── MUS: minimal conflicting subsets
```

### 4.2 Constraint Expression Format

```json
{
  "id": "SC-01",
  "name": "Node identity",
  "scope": "global",
  "nature": "required",
  "severity": "CRITICAL",
  "rule": "∀ node ∈ Graph.nodes: node.identity ≠ null ∧ node.identity.isUnique()",
  "evaluation": {
    "pass": "All nodes have unique identities",
    "fail": "Found {{count}} nodes with missing/duplicate identities"
  }
}
```

### 4.3 MUS Detection

```json
{
  "mus": [
    {
      "id": "MUS-001",
      "constraints": ["PC-01", "PC-02"],
      "conflictType": "PatternInheritanceViolation",
      "description": "Pattern P1 requires minTrust=0.7, Archetype A1 requires maxTrust=0.5",
      "resolution": "Relax pattern constraint or modify archetype constraint"
    }
  ]
}
```

---

## 5. CONSTRAINT REGISTRY

### 5.1 Global Constraints (Always Active)

- SC-01 through SC-08
- SM-01 through SM-07
- TC-01 through TC-06
- IC-01 through IC-05
- IV-01 through IV-06

### 5.2 Conditional Constraints (Activated by Type)

| Activator | Constraints |
|-----------|-------------|
| Evidence present | EC-01 through EC-06 |
| Trust scores | TR-01 through TR-04 |
| Governance rules | GC-01 through GC-04 |
| Lifecycle states | LC-01 through LC-04 |
| Pattern assignments | PC-01 through PC-04 |

### 5.3 Constraint Profiles by Archetype

| Archetype | Active Constraints |
|-----------|-------------------|
| SYSTEM | SC-01..08, SM-01..07, TC-01..06, IC-01..05, IV-01..06, GC-01..04, LC-01..04 |
| AGENT | SC-01..08, SM-01..07, TC-01..06, IC-01..05, IV-01..06, GC-01..04, TR-01..04, PC-01..04 |
| RESOURCE | SC-01..08, SM-01..07, TC-01..06, IC-01..05, IV-01..06, LC-01..04 |
| MEMORY | SC-01..08, SM-01..07, TC-01..06, IC-01..05, IV-01..06 |
| PROCESS | SC-01..08, SM-01..07, TC-01..06, IC-01..05, IV-01..06, EC-01..06, LC-01..04 |
| CONCEPT | SC-01..08, SM-01..07, TC-01..06, IC-01..05, IV-01..06 |

---

## 6. CONSTRAINT-PATTERN INTERACTION

### 6.1 Constraint Inheritance

```
Archetype constraints (broadest, most general)
  │
  ▼ MONOTONIC (can only add, never relax)
Pattern constraints (specific to pattern)
  │
  ▼ MONOTONIC (can only add, never relax)
Instance constraints (most specific, most restrictive)
```

### 6.2 Constraint Conflict Detection

| Conflict Type | Detection | Resolution |
|--------------|-----------|------------|
| Direct contradiction | Two constraints with opposite rules | Report as MUS |
| Transitive conflict | A conflicts with B through C | Trace dependency chain |
| Unsatisfiable set | No possible state satisfies all | Report as MUS |
| Inheritance violation | Pattern relaxes archetype constraint | BLOCKING — compilation stops |

---

## 7. COMPILATION STOP CONDITIONS

The Constraint Engine forces a **STOP** when:

| Condition | Constraint IDs | Action |
|-----------|---------------|--------|
| Node without identity | SC-01 | REJECT |
| Edge without endpoints | SC-03 | REJECT |
| Cycle in knowledge graph | SC-04, IV-02 | REJECT |
| Identity collision | IC-01 | REJECT |
| Identity mutation | IC-02 | REJECT |
| Evidence chain break | EC-02 | REJECT |
| Circular evidence | EC-03 | REJECT |
| Proof without hypothesis | EC-06 | REJECT |
| Hypothesis without proof | EC-06 | REJECT |
| Authority conflict | GC-02 | REJECT |
| Pattern inheritance violation | PC-02 | REJECT |
| Ontology cycle | IV-04 | REJECT |
| Source hash mismatch | IV-05 | REJECT |
| Non-deterministic compilation | IV-06 | REJECT |

---

## 8. CONSTRAINT METRICS

| Metric | Target | Collection |
|--------|--------|------------|
| Constraint evaluation time | < 100ms per 1000 constraints | Per compilation |
| Constraint satisfaction ratio | > 0.95 | Per graph state |
| MUS detection time | < 500ms | When unsatisfiable |
| False positive rate | < 0.01 | Per constraint type |
| Constraint coverage | 100% of ontology concepts | Per ontology version |
