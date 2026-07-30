# CANONICO Constraint Engine — Pattern-Based Constraint Satisfaction

## Status: SPECIFICATION V3 — CONSTRAINT ENGINE

---

## 1. CONSTRAINT ENGINE OVERVIEW

The Constraint Engine is the **core reasoning subsystem** of CANONICO V3. It extends the V2 Constraint Model into a full pattern-based constraint satisfaction system where every Pattern defines a complete constraint profile. The engine determines whether Graph states are valid, detects violations, and identifies the root cause of unsatisfied constraints.

### 1.1 Core Principle

Every Pattern is a constraint set. Every Node is a constraint satisfaction problem. The Graph is valid iff all Pattern constraints are simultaneously satisfied.

### 1.2 Engine Architecture

```
Pattern Definitions
  └─ Pattern Constraints (required/forbidden properties, relations, states)
      └─ Archetype Constraints (inherited by all child Patterns)
          └─ Global Constraints (applied Graph-wide)
              └─ Instance Constraints (Node-specific)
                  ↓
Constraint Solver
  ├─ SAT-based satisfaction checking
  ├─ Constraint propagation
  ├─ Conflict detection
  └─ Unsatisfiability detection
                  ↓
Violation Report
  ├─ Which constraints are violated
  ├─ Which state elements cause the violation
  ├─ Minimal violating subset
  └─ Suggested relaxation
```

---

## 2. PATTERN CONSTRAINT PROFILE

### 2.1 Constraint Categories

Every Pattern defines constraints in these categories:

| Category | Description |
|----------|-------------|
| RequiredProperties | Attributes that must exist on the Node |
| ForbiddenProperties | Attributes that must not exist |
| RequiredRelations | Edge types that must exist (with direction) |
| ForbiddenRelations | Edge types that must not exist |
| AllowedStates | Valid lifecycle states |
| ForbiddenStates | Invalid lifecycle states |
| Cardinality | Min/max/exact counts for relations |
| LifecycleRules | Allowed/forbidden state transitions |
| TransitionRules | Pre/post conditions for transitions |
| TrustRules | Trust score requirements and decay rules |
| EvidenceRules | Evidence requirements and freshness |
| GovernanceRules | Authorization and approval requirements |
| DimensionRules | Dimension value ranges and constraints |
| InvariantRules | Immutable conditions that always hold |

### 2.2 Pattern Constraint Definition

```
PatternConstraintSet {
  patternId: Identity
  archetype: Archetype
  
  // Properties
  requiredProperties: [PropertyConstraint]
  forbiddenProperties: [PropertyConstraint]
  
  // Relations
  requiredRelations: [RelationConstraint]
  forbiddenRelations: [RelationConstraint]
  
  // Lifecycle
  allowedStates: [LifecycleState]
  forbiddenStates: [LifecycleState]
  allowedTransitions: [TransitionRule]
  
  // Cardinality
  cardinality: [CardinalityConstraint]
  
  // Trust
  trustRules: [TrustRule]
  
  // Evidence
  evidenceRules: [EvidenceRule]
  
  // Governance
  governanceRules: [GovernanceRule]
  
  // Dimensions
  dimensionRules: [DimensionRule]
  
  // Invariants
  invariants: [InvariantRule]
}
```

### 2.3 Constraint Inheritance

Constraints are inherited through the Pattern → Archetype hierarchy:

```
Archetype constraints (broadest, most general)
  ↓ MONOTONIC INHERITANCE (cannot relax, only add)
Pattern constraints (specific to the Pattern)
  ↓ MONOTONIC INHERITANCE (cannot relax, only add)
Instance constraints (Node-specific, most restrictive)
```

**Monotonic Inheritance Rule:** A descendant can only add constraints. It cannot remove or relax a constraint from an ancestor.

---

## 3. CONSTRAINT EVALUATION

### 3.1 Evaluation Pipeline

```
FUNCTION evaluateConstraints(node, constraintSet) → EvaluationResult

  1. Collect all applicable constraints:
     archetypeConstraints = loadConstraints(node.archetype)
     patternConstraints = loadConstraints(node.pattern)
     instanceConstraints = loadInstanceConstraints(node.id)
     globalConstraints = loadGlobalConstraints()

  2. Merge with inheritance:
     mergedConstraints = merge(
       archetypeConstraints,
       patternConstraints,
       instanceConstraints,
       globalConstraints
     )

  3. Check monotonicity:
     FOR each constraint in mergedConstraints:
       assert not relaxesAnyAncestor(constraint)

  4. Evaluate each constraint:
     results = []
     FOR constraint IN mergedConstraints:
       result = evaluate(constraint, node)
       results.add(result)

  5. Aggregate results:
     RETURN EvaluationResult(
       satisfied: all(results, PASS),
       failingConstraints: filter(results, FAIL),
       minimalViolatingSubset: findMinimalViolatingSet(results),
       satisfactionRatio: count(PASS) / count(results)
     )
```

### 3.2 Atomic Constraint Evaluation

```
FUNCTION evaluate(constraint, node) → ConstraintResult

  SWITCH constraint.type:
    CASE RequiredProperties:
      FOR prop IN constraint.properties:
        IF not hasProperty(node, prop):
          RETURN FAIL(missing: prop)
      RETURN PASS

    CASE ForbiddenProperties:
      FOR prop IN constraint.properties:
        IF hasProperty(node, prop):
          RETURN FAIL(forbidden: prop)
      RETURN PASS

    CASE RequiredRelations:
      FOR rel IN constraint.relations:
        IF not hasRelation(node, rel.type, rel.direction, rel.targetPattern):
          RETURN FAIL(missing: rel)
      RETURN PASS

    CASE Cardinality:
      count = countRelations(node, constraint.relationType, constraint.direction)
      IF count < constraint.min OR count > constraint.max:
        RETURN FAIL(expected: constraint, actual: count)
      RETURN PASS

    CASE LifecycleRules:
      IF node.lifecycle NOT IN constraint.allowedStates:
        RETURN FAIL(state: node.lifecycle, expected: constraint.allowedStates)
      RETURN PASS

    CASE TransitionRules:
      IF constraint.precondition:
        IF not evaluatePrecondition(constraint.precondition, node):
          RETURN FAIL(precondition: constraint.precondition)
      RETURN PASS

    CASE TrustRules:
      IF node.trust < constraint.minTrust:
        RETURN FAIL(trust: node.trust, min: constraint.minTrust)
      RETURN PASS

    CASE EvidenceRules:
      evidence = getEvidence(node, constraint.evidenceType)
      IF evidence.count < constraint.minCount:
        RETURN FAIL(missing: constraint.evidenceType)
      IF constraint.freshness and anyExpired(evidence, constraint.freshness):
        RETURN FAIL(expired: constraint.evidenceType)
      RETURN PASS
```

---

## 4. CONFLICT DETECTION

### 4.1 Intra-Constraint Conflicts

Conflicts within a single constraint set:

| Conflict Type | Detection | Example |
|---------------|-----------|---------|
| Self-Contradiction | Required and forbidden same property | requires `name` AND forbids `name` |
| Impossible Cardinality | min > max | minParents = 3, maxParents = 1 |
| Unsatisfiable Lifecycle | No valid transitions from any state | All states have no outgoing transitions |
| Circular Requirement | A requires B, B requires A | requires CONTAINS parent AND CONTAINS child |

### 4.2 Inter-Constraint Conflicts

Conflicts between Pattern and Archetype constraints:

| Conflict Type | Detection | Example |
|---------------|-----------|---------|
| Inheritance Violation | Pattern relaxes Archetype constraint | Archetype forbids DELETED, Pattern allows DELETED |
| Contradictory States | Pattern and Archetype define overlapping Forbidden and Allowed | Archetype allows ACTIVE, Pattern forbids ACTIVE |
| Conflicting Cardinality | Pattern min < Archetype min | Archetype requires min 2, Pattern requires min 1 |

### 4.3 Cross-Pattern Conflicts

| Conflict Type | Detection | Example |
|---------------|-----------|---------|
| Edge Type Contradiction | Two Patterns have conflicting edge rules | Pattern A requires DEPENDS_ON to B, B forbids DEPENDS_ON |
| Lifecycle Deadlock | Two Patterns form a lifecycle dependency cycle | A requires B to be ACTIVE, B requires A to be ACTIVE |

---

## 5. CONSTRAINT SATISFACTION SOLVER

### 5.1 Solver Architecture

The Constraint Solver determines whether a set of constraints is simultaneously satisfiable.

```
ConstraintSolver {
  // Check if any possible state satisfies all constraints
  isSatisfiable(constraintSet) → Bool
  
  // Find the minimal set of constraints to relax for satisfiability
  findMinRelaxation(constraintSet) → [Constraint]
  
  // Suggest valid state configurations
  enumerateValidStates(constraintSet) → [StateConfiguration]
  
  // Verify a specific state against constraint set
  satisfies(state, constraintSet) → Bool
  
  // Find the minimal violating subset (MUS)
  findMUS(constraintSet, state) → [Constraint]
}
```

### 5.2 Minimal Unsatisfiable Subset (MUS)

The MUS is the smallest set of constraints that cannot be simultaneously satisfied:

```
FUNCTION findMUS(constraintSet, state) → [Constraint]

  // Start with violated constraints
  violated = evaluateAll(constraintSet, state).failingConstraints()
  
  // Shrink to minimal set
  FOR constraint IN violated:
    testSet = violated - constraint
    IF isSatisfiable(testSet):
      // Constraint is necessary for unsatisfiability
      keep constraint
    ELSE:
      // Constraint is not necessary, remove
      violated = testSet
  
  RETURN violated
```

---

## 6. CONSTRAINT LIFECYCLE

```
DRAFT → PROPOSED → REVIEW → ACTIVE → SUPERSEDED
                        ↓
                    REJECTED        RETIRED
```

### 6.1 Constraint States

| State | Meaning |
|-------|---------|
| DRAFT | Being defined, not yet in effect |
| PROPOSED | Submitted for review |
| REVIEW | Under evaluation by governance |
| ACTIVE | Enforced by Coherence Engine |
| SUPERSEDED | Replaced by newer version |
| REJECTED | Not approved |
| RETIRED | No longer applicable |

### 6.2 Constraint Validation at Registration

```
FUNCTION validateConstraint(constraint) → ValidationReport

  checks = []
  
  // Self-consistency
  checks.add(checkSelfConsistent(constraint))
  checks.add(checkNonContradictory(constraint))
  
  // Inheritance
  checks.add(checkMonotonicInheritance(constraint))
  
  // Feasibility
  checks.add(checkSatisfiable(constraint))
  
  // Conflicts
  checks.add(checkNoConflictsWithExisting(constraint))
  
  RETURN aggregate(checks)
```

---

## 7. CONSTRAINT PATTERNS FOR V3 CONFLICT TYPES

### 7.1 Identity Conflict Pattern

```
IdentityConflictPattern {
  requiredProperties: [id, type, archetype]
  forbiddenProperties: []  // all properties allowed
  requiredRelations: []    // no mandatory relations
  cardinality: {
    identityUniqueness: "GLOBAL"  // no two Nodes share same identity
  }
  invariants: [
    "Identity once created never changes",
    "Identity format must be can:type:hash"
  ]
}
```

### 7.2 Semantic Conflict Pattern

```
SemanticConflictPattern {
  requiredProperties: [definition]
  forbiddenRelations: []  // no forbidden relations
  evidenceRules: [
    "Definition must be traceable to source document",
    "If EQUIVALENT_TO relation exists, definitions must agree"
  ]
  governanceRules: [
    "Semantic resolution requires cross-document verification"
  ]
}
```

### 7.3 Proof Conflict Pattern

```
ProofConflictPattern {
  requiredRelations: [PROVES, CHAINED_TO]
  evidenceRules: [
    "Every proof claim must have complete chain",
    "Chain must terminate at TrustAnchor"
  ]
  trustRules: [
    "Each chain link trust ≥ 0.5",
    "Max chain depth = 5"
  ]
  invariants: [
    "Proof chains are acyclic",
    "Every chain has exactly one root"
  ]
}
```

---

## 8. CONSTRAINT GOVERNANCE

- Constraint registration requires verification of self-consistency
- ACTIVE constraints cannot be modified without governance approval
- Constraint violations at CRITICAL severity auto-alert governance
- The Constraint Engine must pass self-validation on startup
- All constraint evaluations are recorded as immutable Events

---

**CANONICO_CONSTRAINT_ENGINE.md — V3**
**PATTERN-BASED CONSTRAINT SATISFACTION**
**License: Open Standard**
