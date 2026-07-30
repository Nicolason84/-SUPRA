# CANONICO Validation Pipeline

## Status: SPECIFICATION V2 — VALIDATION PIPELINE

---

## 1. PIPELINE OVERVIEW

The Validation Pipeline defines **when** validation occurs, in **what order**, and at **what granularity**. It ensures that no operation can silently degrade Graph coherence.

### 1.1 Pipeline Principle

Validation is not a single event — it is a **continuous process** embedded at every lifecycle point of the Graph. Every mutation, every query, every projection, every decision is preceded and/or followed by validation.

### 1.2 Pipeline Architecture

```
                         ┌─────────────────────────────────────────┐
                         │         VALIDATION PIPELINE              │
                         │         (continuous validation)          │
                         └──────┬──────────┬───────────┬───────────┘
                                │          │           │
              ┌─────────────────┘          │           └─────────────────┐
              ▼                            ▼                             ▼
   ┌────────────────────┐      ┌────────────────────┐      ┌────────────────────┐
   │   PRE-OPERATION     │      │   POST-OPERATION    │      │   PERIODIC          │
   │   VALIDATION        │      │   VALIDATION        │      │   VALIDATION        │
   │   (synchronous)     │      │   (synchronous)     │      │   (asynchronous)    │
   └────────┬───────────┘      └────────┬───────────┘      └────────┬───────────┘
            │                           │                           │
            ▼                           ▼                           ▼
   ┌────────────────────┐      ┌────────────────────┐      ┌────────────────────┐
   │   Can this         │      │   Did this         │      │   Is the Graph     │
   │   operation        │      │   operation        │      │   still            │
   │   proceed?         │      │   maintain         │      │   coherent?        │
   │                    │      │   coherence?       │      │                    │
   │   BLOCK if not     │      │   ALERT if not     │      │   REPORT if not    │
   └────────────────────┘      └────────────────────┘      └────────────────────┘
```

---

## 2. VALIDATION TRIGGERS

### 2.1 At Creation

| Trigger | Scope | Mode | Actions |
|---------|-------|------|---------|
| Node creation | Node + Pattern constraints | BLOCKING | Validate identity uniqueness, Pattern existence, Archetype compatibility, required properties, dimension bounds |
| Edge creation | Edge + source + target | BLOCKING | Validate endpoint existence, EdgeType compatibility, referential integrity, cardinality, cycle detection |
| Pattern registration | Pattern definition | BLOCKING | Validate self-consistency, Archetype compatibility, non-redundancy, non-conflict |
| Constraint registration | Constraint definition | BLOCKING | Validate self-consistency, target existence, non-contradiction, type correctness |

### 2.2 At Modification

| Trigger | Scope | Mode | Actions |
|---------|-------|------|---------|
| Attribute update | Node | BLOCKING | Validate new values against property constraints, dimension ranges |
| Lifecycle transition | Node + related Edges | BLOCKING | Validate transition legality, preconditions, postconditions, cascade effects |
| Edge attribute update | Edge | BLOCKING | Validate new values against Edge type constraints |
| Pattern update | Pattern + all affected Nodes | BLOCKING | Validate backward compatibility, re-validate affected Nodes |

### 2.3 Before Projection

| Trigger | Scope | Mode | Actions |
|---------|-------|------|---------|
| JSON projection | Projection subgraph | WARNING | Validate subgraph coherence, check projection definition validity |
| API response | Request scope | WARNING | Validate data being exposed, check authorization |
| File system sync | Entire Graph | WARNING | Validate Graph coherence before generating file tree |
| Digital Passport generation | Single Node | BLOCKING | Validate Node integrity before passport creation |

### 2.4 Before Execution

| Trigger | Scope | Mode | Actions |
|---------|-------|------|---------|
| Behavior execution | Node + dependencies | BLOCKING | Validate capability existence, preconditions, authorization, dependency status |
| Mission start | Mission scope | BLOCKING | Validate dependency resolution, authorization, resource availability |
| Pipeline stage | Stage scope | BLOCKING | Validate previous stage completion, input validity, stage preconditions |

### 2.5 Before Decision

| Trigger | Scope | Mode | Actions |
|---------|-------|------|---------|
| Governance decision | Decision scope | BLOCKING | Validate authority, conflict of interest, precedent consistency |
| Agent decision | Agent + affected scope | BLOCKING | Validate agent authorization, decision within scope, evidence sufficiency |
| Automated action | Action scope | BLOCKING | Validate action rules, preconditions, safety constraints |

### 2.6 Before Synchronization

| Trigger | Scope | Mode | Actions |
|---------|-------|------|---------|
| Cross-Graph merge | Incoming subgraph | BLOCKING | Validate identity collision, constraint compatibility, trust chain |
| Federation sync | Federation scope | BLOCKING | Validate federation agreement, data sovereignty, schema compatibility |

### 2.7 Periodic Validation

| Interval | Scope | Mode | Actions |
|----------|-------|------|---------|
| Real-time (event-driven) | Mutated elements | ASYNC | Re-validate after each mutation |
| Every minute | Recently active Nodes | ASYNC | Health check on high-activity Nodes |
| Every hour | Full Graph | ASYNC | Complete health assessment |
| Every day | Deep validation | ASYNC | Full constraint satisfaction, trend analysis |
| On startup | Bootstrap validation | BLOCKING | Validate Graph integrity before accepting operations |

---

## 3. PIPELINE STAGES

### 3.1 Pre-Operation Validation Stage

```
Input: Operation Request
  ↓
Stage 1: Request Validation
  ├─ Is the request well-formed?
  ├─ Are all required fields present?
  └─ Is the actor authorized?
  ↓
Stage 2: State Validation
  ├─ Does the target exist? (for updates/deletes)
  ├─ Is the target in a valid state for this operation?
  └─ Are preconditions satisfied?
  ↓
Stage 3: Constraint Validation
  ├─ Will the operation violate any constraints?
  ├─ Will it create any forbidden states?
  └─ Will it break any cardinality rules?
  ↓
Stage 4: Impact Validation
  ├─ What Nodes/Edges will be affected?
  ├─ Will any cascading violations occur?
  └─ Will the operation degrade global health?
  ↓
Output: ValidationDecision (PASS / FAIL / WARNING)
```

### 3.2 Post-Operation Validation Stage

```
Input: Mutation Result
  ↓
Stage 1: State Capture
  ├─ Capture new state of affected elements
  └─ Compute diff from previous state
  ↓
Stage 2: Re-Validation
  ├─ Re-validate all affected Nodes/Edges
  ├─ Check invariant constraints
  └─ Verify expected postconditions
  ↓
Stage 3: Propagation Check
  ├─ Check dependents of affected elements
  ├─ Validate cascade effects
  └─ Update health scores for affected scope
  ↓
Stage 4: Event Recording
  ├─ Record validation event in event log
  ├─ Attach validation report to mutation event
  └─ Update health history
  ↓
Output: PostOperationReport
```

### 3.3 Periodic Validation Stage

```
Input: Schedule Trigger
  ↓
Stage 1: Scope Resolution
  ├─ Determine what to validate (full Graph / subgraph)
  └─ Load applicable constraints
  ↓
Stage 2: Batch Validation
  ├─ Validate all Nodes in scope
  ├─ Validate all Edges in scope
  ├─ Validate cross-cutting constraints
  └─ Detect conflicts and anomalies
  ↓
Stage 3: Health Computation
  ├─ Compute Node health scores
  ├─ Compute Edge health scores
  ├─ Compute Subgraph/Graph health scores
  └─ Compute trend
  ↓
Stage 4: Report Generation
  ├─ Generate health report
  ├─ Identify critical issues
  ├─ Trigger alerts if thresholds exceeded
  └─ Record health snapshot in history
  ↓
Output: HealthReport
```

---

## 4. PIPELINE CONFIGURATION

```
ValidationPipelineConfig {
  // Per-trigger mode overrides
  triggers: {
    nodeCreation: Mode.BLOCKING
    nodeUpdate: Mode.BLOCKING
    edgeCreation: Mode.BLOCKING
    projection: Mode.WARNING
    execution: Mode.BLOCKING
    decision: Mode.BLOCKING
    periodic: Mode.ASYNC
  }

  // Scope configuration
  defaultScope: ValidationScope.GRAPH
  maxValidationDepth: Int = 5       [max cascade depth]
  timeoutPerConstraint: Duration = 5s

  // Health thresholds
  thresholds: {
    critical: 0.25
    degraded: 0.50
    healthy: 0.75
    excellent: 0.90
  }

  // Alert configuration
  alerts: {
    onCriticalViolation: true
    onHealthDegraded: true
    onHealthTrendDegrading: true
    onStuckLifecycle: true
    alertChannel: "governance"
  }

  // Scheduling
  schedule: {
    deepValidation: "0 * * * *"     [every hour]
    fullValidation: "0 0 * * *"     [every day]
    trendComputation: "0 */6 * * *" [every 6 hours]
  }
}
```

---

## 5. PIPELINE MODES

| Mode | Behavior | Latency | Use Case |
|------|----------|---------|----------|
| `BLOCKING` | Operation waits for validation result; fails if invalid | Higher | Critical mutations |
| `WARNING` | Operation proceeds; validation warnings logged | Lower | Non-critical operations |
| `ASYNC` | Operation proceeds; validation queued for async processing | Lowest | High-throughput operations |
| `DRY_RUN` | Full validation, no operation performed | Medium | What-if analysis, testing |
| `BACKGROUND` | Continuous low-priority validation | Lowest | Periodic health checks |
| `DEEP` | Exhaustive validation including transitive dependencies | Highest | Nightly integrity audit |

---

## 6. ERROR HANDLING

| Condition | Behavior |
|-----------|----------|
| Validation timeout | Fail open (allow) for WARNING mode; fail closed (block) for BLOCKING mode |
| Constraint not found | SKIP constraint, log warning |
| Circular validation dependency | Detect and abort after 3 hops, log error |
| Engine unavailable | Queue validation, retry with exponential backoff |
| Concurrent validation conflict | Serialize per target identity |
| Validation result inconsistency (retry) | Re-run validation; if inconsistent, escalate |

---

## 7. PIPELINE METRICS

| Metric | Description |
|--------|-------------|
| Validation count | Total validations performed |
| Pass rate | Percentage of validations passing |
| Average latency | Average validation duration |
| P95 latency | 95th percentile validation duration |
| Blocker count | Number of blocked operations |
| Alert count | Number of triggered alerts |
| Violation count by severity | Distribution of violation severities |
| Health score history | Time series of global health scores |

---

## 8. PIPELINE GOVERNANCE

- Pipeline configuration cannot be modified without governance approval
- Validation events are immutable and auditable
- BLOCKING mode cannot be downgraded to WARNING for CRITICAL constraints
- Pipeline metrics are exposed via Graph Runtime health endpoint
- Pipeline must self-validate on startup

---

**CANONICO_VALIDATION_PIPELINE.md — V2**
**VALIDATION PIPELINE**
**License: Open Standard**
