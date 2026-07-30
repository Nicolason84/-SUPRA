# CANONICO Constraint Model

## Status: SPECIFICATION V2 — CONSTRAINT GRAPH

---

## 1. CONSTRAINT MODEL OVERVIEW

A Constraint is a first-class citizen in the CANONICO Graph. Every Pattern, every EdgeType, every Archetype carries a set of constraints that define the boundary of valid states. The Constraint Graph transforms CANONICO from a descriptive standard into a **prescriptive standard** — one that not only describes what is, but defines what is allowed.

### 1.1 Core Principle

```
State is valid
  ⇔
∀ constraint ∈ applicableConstraints(state) : constraint(state) = true
```

A Node, Edge, or Graph is valid **iff** every applicable constraint is satisfied.

### 1.2 Constraint Identity

Every constraint has an immutable identity and is itself a Node in the Graph:

```
Constraint {
  id: Identity                    [can:con:<hash>]
  type: ConstraintType
  name: String
  description: String
  scope: ConstraintScope          [NODE | EDGE | GRAPH | PATTERN | RELATIONSHIP]
  target: NodeType | EdgeType | Archetype | Pattern
  severity: Severity              [CRITICAL | ERROR | WARNING | INFO]
  expression: ConstraintExpression
  metadata: Map
  version: String
}
```

---

## 2. CONSTRAINT TYPES

### 2.1 State Constraints

Define which states are allowed or forbidden for a Node.

| Constraint | Description | Example |
|-----------|-------------|---------|
| `AllowedStates` | Set of valid lifecycle states | Node with Pattern "Mission" → ACTIVE, COMPLETED, ARCHIVED |
| `ForbiddenStates` | Set of invalid lifecycle states | Node with Pattern "Mission" → cannot be CONCEPT after EXECUTION started |
| `AllowedAttributeValues` | Valid value ranges for attributes | `importance` ∈ [0.0, 1.0], `version` ∈ ℕ |
| `ForbiddenAttributeValues` | Invalid configurations | `lifecycle` = DELETED and `pattern` = Mission → forbidden |

### 2.2 Relation Constraints

Define which relationships are allowed or required between Nodes.

| Constraint | Description | Example |
|-----------|-------------|---------|
| `AllowedRelations` | Permitted EdgeTypes for a Pattern | Mission → EXECUTES, GENERATES, DEPENDS_ON |
| `ForbiddenRelations` | Prohibited EdgeTypes | Mission → cannot CONTAIN another Mission |
| `RequiredRelations` | EdgeTypes that must exist | Every Agent must have at least one OBSERVES edge |
| `ForbiddenRelations` | EdgeTypes that must not exist | A Node cannot DEPENDS_ON itself |

### 2.3 Property Constraints

Define required or forbidden properties on Nodes and Edges.

| Constraint | Description | Example |
|-----------|-------------|---------|
| `RequiredProperties` | Attributes that must be present | Every Node must have `name`, `type`, `archetype` |
| `ForbiddenProperties` | Attributes that must be absent | A Pattern Node cannot have `execution` dimension |
| `PropertyTypes` | Type constraints on attributes | `weight` must be Float ∈ [0.0, 1.0] |
| `PropertyCardinality` | Min/max occurrences | A Node must have exactly 1 `type`, 0+ `attributes` |

### 2.4 Cardinality Constraints

Define numerical limits on graph structures.

| Constraint | Description | Example |
|-----------|-------------|---------|
| `MinCardinality` | Minimum count of a relationship | Agent → min 1 OBSERVES edge |
| `MaxCardinality` | Maximum count of a relationship | Node → max 1 CONTAINS parent |
| `ExactCardinality` | Exact count required | Every Edge has exactly 1 source and 1 target |
| `Uniqueness` | No duplicates allowed | No two Nodes share the same identity |

### 2.5 Transition Constraints

Define legal state transitions.

| Constraint | Description | Example |
|-----------|-------------|---------|
| `AllowedTransitions` | Permitted lifecycle transitions | CREATED → ACTIVE ✅, ACTIVE → CONCEPT ❌ |
| `ForbiddenTransitions` | Prohibited transitions | ARCHIVED → ACTIVE ❌ (unless Pattern allows revival) |
| `TransitionPreconditions` | Conditions that must hold before transition | Node must have all RequiredRelations before ACTIVE |
| `TransitionPostconditions` | Conditions that must hold after transition | After ARCHIVED, all incoming edges must be SUSPENDED |

### 2.6 Lifecycle Constraints

Define lifecycle-related rules beyond simple transitions.

| Constraint | Description | Example |
|-----------|-------------|---------|
| `MinLifecycleDuration` | Minimum time in a state | Node must be ACTIVE for 1s before SUSPENDED |
| `MaxLifecycleDuration` | Maximum time in a state | Node cannot remain CONCEPT for >1 year |
| `LifecycleOrder` | Required ordering of transitions | CREATED must precede ACTIVE |
| `LifecycleParallelism` | Can multiple states coexist? | A Node cannot be ACTIVE and ARCHIVED simultaneously |

### 2.7 Trust Constraints

Define trust-related rules.

| Constraint | Description | Example |
|-----------|-------------|---------|
| `MinTrust` | Minimum trust score required | A Node generating Projections must have trust ≥ 0.7 |
| `TrustChainLength` | Maximum length of trust chain | Trust chain must not exceed 3 hops |
| `TrustSource` | Trust must originate from specific source | Only GOVERNANCE Nodes can set trust ≥ 0.9 |
| `TrustDecay` | Trust decays over time without re-verification | Trust drops 0.1 per month without re-attestation |

### 2.8 Evidence Constraints

Define evidence-related rules.

| Constraint | Description | Example |
|-----------|-------------|---------|
| `RequiredEvidence` | Evidence that must exist | Every Node must have creation Evidence |
| `EvidenceFreshness` | How old evidence can be | Evidence must be refreshed every 90 days |
| `EvidenceChainLength` | Maximum chain length | Evidence chain must not exceed 5 hops |
| `EvidenceType` | Required evidence type | GOVERNANCE decisions require ATTESTED_BY evidence |

### 2.9 Identity Constraints

Define identity-related rules.

| Constraint | Description | Example |
|-----------|-------------|---------|
| `IdentityUniqueness` | No two identities collide | Enforced by content-addressed hashing |
| `IdentityImmutability` | Identity never changes | Enforced by law |
| `IdentityFormat` | Identity must follow can:type:hash | No other formats accepted |
| `IdentitySeed` | Identity derivation must include specific fields | ID must include type + archetype + creation timestamp |

### 2.10 Execution Constraints

Define execution-related rules.

| Constraint | Description | Example |
|-----------|-------------|---------|
| `MaxConcurrentExecution` | Maximum parallel executions | A Node cannot be executed by more than 3 agents simultaneously |
| `ExecutionPrecondition` | Conditions before execution | Node must be ACTIVE and have all dependencies resolved |
| `ExecutionPostcondition` | Conditions after execution | After execution, an Event must be recorded |
| `ExecutionTimeout` | Maximum execution duration | A Mission must complete within 30 days |

### 2.11 Governance Constraints

Define governance-related rules.

| Constraint | Description | Example |
|-----------|-------------|---------|
| `RequiredApproval` | Approvals needed for mutation | ARCHIVED → ACTIVE requires GOVERNANCE approval |
| `ApprovalChain` | Who must approve | Mutations on SYSTEM archetype require 2 approvals |
| `AuditRequired` | Actions that must be audited | Any trust score change must be audited |
| `ComplianceRule` | External regulation compliance | Personal data Nodes must have GDPR attributes |

---

## 3. CONSTRAINT SCOPE

### 3.1 Scope Levels

| Scope | Applies To | Evaluated When |
|-------|-----------|----------------|
| `NODE` | Individual Node | Node creation, update, lifecycle transition |
| `EDGE` | Individual Edge | Edge creation, update, lifecycle transition |
| `PATTERN` | All Nodes of a Pattern | Pattern registration, Node creation |
| `ARCHETYPE` | All Nodes of an Archetype | Node creation, Archetype registration |
| `RELATIONSHIP` | Pairs of connected Nodes | Edge creation, traversal |
| `SUBGRAPH` | Subgraph defined by query | Projection, export |
| `GLOBAL` | Entire Graph | Health check, startup |

### 3.2 Constraint Inheritance

Constraints are inherited through the Pattern → Archetype hierarchy:

```
Archetype (broadest constraints)
  └─ Pattern (adds specific constraints)
       └─ Node (adds instance-level constraints)
```

- A Node must satisfy all constraints from its Archetype + Pattern + own constraints
- A Pattern cannot relax Archetype-level constraints (monotonic inheritance)
- Instance-level constraints can only be more restrictive, never less

---

## 4. CONSTRAINT EXPRESSION

Constraints are expressed in a declarative constraint language:

### 4.1 Atomic Expressions

| Expression | Meaning |
|-----------|---------|
| `property(name) = value` | Attribute equals value |
| `property(name) ∈ range` | Attribute in range |
| `property(name) ≥ min` | Attribute ≥ minimum |
| `property(name) ≤ max` | Attribute ≤ maximum |
| `exists(edgeType, direction)` | Relationship of type exists |
| `not(exists(edgeType))` | Relationship must not exist |
| `count(edgeType) ≥ n` | At least n relationships |
| `count(edgeType) ≤ n` | At most n relationships |

### 4.2 Composite Expressions

| Expression | Meaning |
|-----------|---------|
| `A ∧ B` | Both A and B must hold |
| `A ∨ B` | Either A or B must hold |
| `A → B` | If A holds, B must hold (implication) |
| `A ↔ B` | A holds iff B holds (equivalence) |
| `¬A` | A must not hold |
| `∀x ∈ scope : P(x)` | All elements in scope satisfy P |
| `∃x ∈ scope : P(x)` | At least one element satisfies P |

### 4.3 Temporal Expressions

| Expression | Meaning |
|-----------|---------|
| `always(P)` | P holds at all times |
| `eventually(P)` | P must hold at some future time |
| `until(P, Q)` | P holds until Q becomes true |
| `after(event, P)` | After event occurs, P must hold |
| `before(event, P)` | Before event occurs, P must hold |
| `between(t1, t2, P)` | P holds between t1 and t2 |

---

## 5. CONSTRAINT REGISTRY

Every constraint in the system must be registered:

```
ConstraintRegistry {
  register(constraint: Constraint) → Constraint
  unregister(constraintId: Identity) → Void
  getConstraint(id: Identity) → Constraint
  getConstraints(scope: Scope, target: Target) → [Constraint]
  getApplicableConstraints(node: Node) → [Constraint]
  getApplicableConstraints(edge: Edge) → [Constraint]
  getApplicableConstraints(graph: Graph) → [Constraint]
  validateConstraint(constraint: Constraint) → Bool
}
```

### 5.1 Constraint Validation

A constraint definition itself must be validated before registration:
- Self-consistent: the constraint expression must not be trivially contradictory
- Typed: all type references must exist
- Scoped: scope target must exist in the Graph
- Non-redundant: should not duplicate an existing constraint (warning)
- Non-conflicting: should not directly contradict an existing constraint (warning)

---

## 6. CONSTRAINT SATISFACTION

### 6.1 Satisfaction Check

```
satisfies(constraint: Constraint, state: GraphState) → SatisfactionResult {
  result: Bool
  violatedConditions: [Condition]
  context: Map
}
```

### 6.2 Unsatisfiability Detection

A constraint set is **unsatisfiable** if no possible Graph state can satisfy all constraints simultaneously. This is distinct from a violation (where the current state fails, but some state exists).

The Constraint Solver detects:
- Circular dependencies in RequiredRelations
- Contradictory AllowedStates/ForbiddenStates overlap
- Cardinality constraints that cannot be simultaneously met
- Lifecycle transitions that deadlock

---

## 7. CONSTRAINT LIFECYCLE

```
DRAFT     → PROPOSED
PROPOSED  → ACTIVE    (after review)
PROPOSED  → REJECTED
ACTIVE    → SUPERSEDED (replaced by newer version)
ACTIVE    → RETIRED   (no longer applicable)
```

- Only ACTIVE constraints participate in validation
- SUPERSEDED constraints remain in the registry for historical traceability
- RETIRED constraints are preserved but excluded from evaluation

---

## 8. CONSTRAINT GOVERNANCE

- Constraints cannot be self-registered by unprivileged agents
- ACTIVE constraints require GOVERNANCE Archetype approval
- Modifying an ACTIVE constraint generates a mandatory audit event
- Constraint violations at CRITICAL severity must alert governance
- Constraint registry is itself validated by the Coherence Engine bootstrap

---

**CANONICO_CONSTRAINT_MODEL.md — V2**
**CONSTRAINT GRAPH MODEL**
**License: Open Standard**
