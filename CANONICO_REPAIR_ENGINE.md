# CANONICO Repair Engine

## Status: SPECIFICATION V2 — REPAIR ENGINE (CONCEPTUAL)

---

## 1. REPAIR ENGINE OVERVIEW

The Repair Engine is responsible for proposing minimal corrections to restore Graph coherence. It is a **proposal-only** engine — it never automatically modifies the Graph. All repairs must be reviewed and explicitly authorized before execution.

### 1.1 Core Principle

The Repair Engine operates under the principle of **minimal intervention**: the best repair is the one that restores coherence with the fewest changes, the least side effects, and the highest confidence.

### 1.2 Repair Lifecycle

```
Violation Detected
  ↓
Root Cause Identified
  ↓
Repair Proposal Generated
  ↓
Repair Simulated
  ↓
Repair Validated
  ↓
Repair Prioritized
  ↓
[Human/Agent Review]
  ↓
Repair Executed (by authorized actor only)
  ↓
Post-Repair Validation
```

---

## 2. REPAIR PROPOSAL

```
RepairProposal {
  id: Identity
  title: String
  description: String

  violation: Identity               [what violation this repairs]
  rootCause: Identity                [what root cause this addresses]

  operations: [RepairOperation]      [ordered list of changes]
  cost: RepairCost                   [estimated effort/risk]

  expectedResult: StateDescription   [what the state will be after repair]
  validationReport: ValidationReport [simulated validation result]

  confidence: Float                  [0.0–1.0, confidence in this repair]
  impact: ImpactReport               [side effects of this repair]

  alternatives: [RepairProposal]     [alternative approaches]
  metadata: Map
}
```

### 2.1 Repair Operation Types

| Operation | Description | Parameters |
|-----------|-------------|------------|
| `CREATE_NODE` | Create a new Node | archetype, pattern, attributes, dimensions |
| `CREATE_EDGE` | Create a new Edge | type, source, target, weight, trust |
| `UPDATE_ATTRIBUTE` | Update a Node/Edge attribute | target, key, newValue |
| `TRANSITION_LIFECYCLE` | Transition lifecycle state | target, to, reason |
| `ARCHIVE_EDGE` | Archive an edge (soft-delete) | target |
| `ATTACH_EVIDENCE` | Attach evidence to a Node/Edge | target, evidence, type |
| `REGISTER_CONSTRAINT` | Register a new constraint | constraint definition |
| `UPDATE_CONSTRAINT` | Update an existing constraint | constraintId, newDefinition |
| `RETIRE_CONSTRAINT` | Retire a problematic constraint | constraintId, reason |
| `ADJUST_DIMENSION` | Adjust a dimension value | target, dimension, newValue |
| `REROUTE_EDGE` | Change edge source or target | target, newSource/target |

### 2.2 Repair Operation Structure

```
RepairOperation {
  id: Identity
  type: RepairOperationType
  target: Identity
  params: Map
  order: Int                         [execution order]
  precondition: StateCondition?      [must be true before execution]
  postcondition: StateCondition?     [will be true after execution]
  rollback: RepairOperation?         [how to undo if needed]
  atomic: Bool                       [must succeed or all operations roll back]
}
```

---

## 3. REPAIR STRATEGIES

### 3.1 Corrective Repair

Fix the violating state to satisfy the constraint.

| Strategy | When to Use | Example |
|----------|-------------|---------|
| Attribute adjustment | Invalid attribute value | Set trust = 0.5 to meet MinTrust |
| Edge creation | Missing required relation | Add missing CONTAINS edge |
| Edge archival | Forbidden relation present | Archive violating DEPENDS_ON edge |
| Lifecycle transition | Node in wrong state | Transition from ACTIVE → SUSPENDED |

### 3.2 Compensatory Repair

Add compensating state to neutralize the violation without modifying the violating element.

| Strategy | When to Use | Example |
|----------|-------------|---------|
| Add compensating evidence | Insufficient evidence | Add additional PROVES edge |
| Add compensating Node | Missing capability | Create required dependency Node |
| Adjust dimension to compensate | Dimensional imbalance | Increase trust to compensate for low evidence |

### 3.3 Constraint Adjustment

Modify the constraint instead of the state (used when the constraint is incorrect, not the state).

| Strategy | When to Use | Example |
|----------|-------------|---------|
| Constraint relaxation | Constraint too strict | Increase MinTrust from 0.7 to 0.5 |
| Constraint removal | Constraint incorrect or outdated | Remove obsolete requirement |
| Constraint addition | Missing constraint that caused violation | Add cycle detection constraint |

### 3.4 Structural Repair

Modify the Graph topology to restore validity.

| Strategy | When to Use | Example |
|----------|-------------|---------|
| Node migration | Node in wrong location | Re-parent Node to correct CONTAINS |
| Edge rerouting | Edge connects wrong Nodes | Reroute DEPENDS_ON to correct target |
| Node splitting | Identity collision | Split colliding identities |
| Node merging | Duplicate Nodes | Merge duplicate representations |

---

## 4. REPAIR GENERATION

### 4.1 Generation Algorithm

```
FUNCTION generateRepairs(violation, rootCause) → [RepairProposal]

  repairs = []

  // Strategy 1: Correct the violating element
  corrective = generateCorrectiveRepairs(violation, rootCause)
  repairs.addAll(corrective)

  // Strategy 2: Compensate for the violation
  compensative = generateCompensativeRepairs(violation, rootCause)
  repairs.addAll(compensative)

  // Strategy 3: Adjust the constraint
  constraintAdjustments = generateConstraintAdjustments(violation, rootCause)
  repairs.addAll(constraintAdjustments)

  // Strategy 4: Structural modification
  structural = generateStructuralRepairs(violation, rootCause)
  repairs.addAll(structural)

  // Deduplicate
  repairs = deduplicate(repairs)

  // Simulate and validate each
  FOR repair IN repairs:
    repair.validationReport = simulateRepair(repair)
    repair.impact = analyzeImpact(repair)
    repair.cost = estimateCost(repair)

  // Sort by cost (ascending)
  repairs = sortByCost(repairs)

  RETURN repairs
```

### 4.2 Repair Deduplication

Two repairs are considered duplicates if they have the same **signature**:

```
signature = hash(
  sorted(repair.operations.map(op → hash(op.type + op.target + op.params)))
)
```

---

## 5. REPAIR SIMULATION

Before any repair is proposed, it must be simulated against the Graph state.

```
FUNCTION simulateRepair(repair) → SimulationResult

  // Create a sandbox copy of relevant Graph state
  sandbox = copySubgraph(repair.getAffectedScope())

  // Apply repair operations to sandbox
  FOR op IN repair.operations:
    result = applyToSandbox(sandbox, op)
    IF not result.success:
      RETURN SimulationResult(
        success: false,
        error: result.error,
        partialState: sandbox
      )

  // Validate the sandbox state
  validationResult = validate(sandbox)

  RETURN SimulationResult(
    success: validationResult.passed,
    passedChecks: validationResult.passed,
    failedChecks: validationResult.failed,
    finalState: captureState(sandbox),
    diff: computeDiff(originalState, sandbox)
  )
```

### 5.1 Simulation Result

```
SimulationResult {
  success: Bool                      [did the repair produce a valid state?]
  finalState: StateDescription       [what the state will look like]
  diff: GraphDiff                    [what changed]

  passedChecks: Int                  [constraints satisfied after repair]
  failedChecks: Int                  [constraints still violated after repair]
  newViolations: [Violation]         [new violations introduced by repair]
  residualViolations: [Violation]    [original violations not fixed]

  executionOrder: [RepairOperation]  [optimized execution order]
  warnings: [String]
}
```

---

## 6. REPAIR VALIDATION

A repair proposal is valid iff:
1. All operations are legal (authorized, type-safe, reference-valid)
2. The simulated post-repair state satisfies all applicable constraints
3. No new CRITICAL or ERROR violations are introduced
4. The repair does not violate any governance rules
5. The repair can be rolled back if it fails

---

## 7. REPAIR PRIORITIZATION

Repairs are ranked by a composite score:

```
priorityScore = (
  (1.0 - cost.normalized) * COST_WEIGHT       +
  confidence * CONFIDENCE_WEIGHT               +
  (1.0 - impact.severity) * IMPACT_WEIGHT      +
  minimalityScore * MINIMALITY_WEIGHT          +
  durabilityScore * DURABILITY_WEIGHT
)
```

Default weights:
| Factor | Weight | Description |
|--------|--------|-------------|
| Cost | 0.30 | Lower cost = higher priority |
| Confidence | 0.25 | Higher confidence = higher priority |
| Impact | 0.20 | Lower side effects = higher priority |
| Minimality | 0.15 | Fewer operations = higher priority |
| Durability | 0.10 | Less likely to need re-repair = higher priority |

---

## 8. REPAIR COST MODEL

```
RepairCost {
  operations: Int                    [number of operations]
  complexity: Float                  [0.0–1.0, structural complexity]
  risk: Float                        [0.0–1.0, probability of side effects]
  time: Duration                     [estimated execution time]
  approvalsRequired: Int             [how many approvals needed]
  rollbackComplexity: Float          [0.0–1.0, how hard to roll back]
  normalized: Float                  [0.0–1.0, composite cost score]
}
```

---

## 9. NON-REPAIRABLE VIOLATIONS

Some violations cannot be repaired. The engine must detect these and report them as such:

| Condition | Reason | Action |
|-----------|--------|--------|
| Identity collision | Identities are immutable | Must archive one Node, create new identity |
| Irreversible data loss | Required data never existed | Cannot create data ex nihilo |
| Governance deadlock | Requires self-approval | Escalate to human governance |
| Contradictory constraints | No valid state possible | Constraint set is inherently unsatisfiable |

---

## 10. GOVERNANCE RULES

| Rule | Description |
|------|-------------|
| No auto-apply | Repair Engine never automatically modifies the Graph |
| Review required | CRITICAL severity repairs require human review |
| Audit trail | All repair proposals and executions are immutable Events |
| Rollback plan | Every repair must include a rollback plan |
| Approval threshold | Repairs affecting SYSTEM Archetype require 2+ approvals |
| Time-bounded | Repair proposals expire after 30 days if not executed |

---

## 11. REPAIR PATTERNS

### 11.1 Dangling Edge Repair

```
Violation: Edge references non-existent Node
Proposal:
  1. CREATE_NODE with the referenced identity (if seed data available)
  2. OR ARCHIVE_EDGE (remove the dangling reference)
  3. OR REROUTE_EDGE to existing correct Node
```

### 11.2 Missing Relation Repair

```
Violation: Missing required relation (e.g., no CONTAINS parent)
Proposal:
  1. CREATE_EDGE of required type to appropriate existing Node
  2. OR CREATE_NODE as parent + CREATE_EDGE
  3. OR TRANSITION_LIFECYCLE to SUSPENDED (if parent cannot be found)
```

### 11.3 Trust Decay Repair

```
Violation: Trust score below MinTrust
Proposal:
  1. ATTACH_EVIDENCE (fresh attestation) → trust recalculation
  2. OR ADJUST_DIMENSION (increase trust directly, requires authorization)
  3. OR UPDATE_CONSTRAINT (adjust MinTrust to realistic value)
```

---

**CANONICO_REPAIR_ENGINE.md — V2**
**REPAIR ENGINE (CONCEPTUAL)**
**License: Open Standard**
