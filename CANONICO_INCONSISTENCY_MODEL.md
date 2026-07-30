# CANONICO Inconsistency Model

## Status: SPECIFICATION V2 — INCONSISTENCY TAXONOMY

---

## 1. INCONSISTENCY MODEL OVERVIEW

An inconsistency is a violation of one or more constraints that renders the Graph state invalid with respect to its own rules. The Inconsistency Model defines a complete taxonomy of every type of inconsistency the Coherence Engine can detect.

### 1.1 Core Principle

An inconsistency is not merely an error — it is a **measurable deviation** from the set of valid states defined by the constraint system. Every inconsistency has:
- A **type** (what kind of violation)
- A **severity** (how critical)
- A **location** (where it occurs)
- A **cause** (why it happened)
- A **signature** (unique identifier for deduplication)

### 1.2 Inconsistency Structure

```
Inconsistency {
  id: Identity                    [can:inc:<hash-of-violation>]
  type: InconsistencyType
  severity: Severity              [INFO | WARNING | ERROR | CRITICAL]
  status: InconsistencyStatus     [OPEN | INVESTIGATING | MITIGATED | RESOLVED | FALSE_POSITIVE]

  location: GraphLocation {
    node: Identity?               [affected Node, if any]
    edge: Identity?               [affected Edge, if any]
    subgraph: Query?              [affected subgraph, if any]
    constraint: Identity           [violated constraint]
  }

  description: String             [human-readable summary]
  signature: Hash                 [deduplication hash]

  causation: CausalChain {
    directCause: String
    rootCause: RootCause
    contributingFactors: [Factor]
  }

  impact: ImpactAssessment
  repair: RepairProposal?

  discovered: Timestamp
  resolved: Timestamp?
  metadata: Map
}
```

---

## 2. COMPLETE TAXONOMY

### 2.1 Identity Conflicts

| Type | Description | Severity | Detection |
|------|-------------|----------|-----------|
| `IdentityCollision` | Two Nodes share the same identity hash | CRITICAL | Hash comparison |
| `IdentityFormatViolation` | Identity does not match can:type:hash format | CRITICAL | Regex validation |
| `IdentityMutation` | Identity changed after creation | CRITICAL | Audit log comparison |
| `IdentitySeedMismatch` | Identity hash does not match seed data | CRITICAL | Rehash verification |
| `PassportMismatch` | Digital Passport differs from Node state | ERROR | Field-by-field comparison |

### 2.2 Lifecycle Conflicts

| Type | Description | Severity | Detection |
|------|-------------|----------|-----------|
| `InvalidTransition` | Lifecycle transition not in allowed set | CRITICAL | Transition table lookup |
| `LifecycleSkip` | Lifecycle state skipped (e.g., CREATED → ARCHIVED) | ERROR | Transition history check |
| `LifecycleRollback` | Transition to a previous state not allowed | ERROR | State machine validation |
| `LifecycleDeadlock` | Node stuck in a state with no legal exit | CRITICAL | Reachability analysis |
| `LifecycleDurationViolation` | State duration outside allowed bounds | WARNING | Timestamp delta check |

### 2.3 Temporal Conflicts

| Type | Description | Severity | Detection |
|------|-------------|----------|-----------|
| `TemporalOrderViolation` | Event B occurs before Event A that must precede it | ERROR | Event log ordering |
| `TimestampInFuture` | Timestamp is in the future | WARNING | Clock comparison |
| `TimestampInconsistent` | Related events have inconsistent timestamps | ERROR | Cross-event comparison |
| `DurationViolation` | Duration exceeds or falls short of constraint | WARNING | Timestamp delta check |
| `TemporalAnomaly` | Statistically improbable timestamp pattern | INFO | Statistical outlier detection |

### 2.4 State Conflicts

| Type | Description | Severity | Detection |
|------|-------------|----------|-----------|
| `ForbiddenState` | Node is in a state forbidden by its Pattern | CRITICAL | State space check |
| `MissingState` | Node has not reached a required state | ERROR | State progression check |
| `StateDrift` | Node state differs from expected state | ERROR | Expected vs actual comparison |
| `StateCorruption` | Node state contains impossible values | CRITICAL | Value range validation |
| `StateStalemate` | No state transition possible from current state | ERROR | Outgoing transition check |

### 2.5 Execution Conflicts

| Type | Description | Severity | Detection |
|------|-------------|----------|-----------|
| `ConcurrentExecutionLimit` | Too many concurrent executions | ERROR | Execution counter check |
| `ExecutionPreconditionViolation` | Preconditions not met before execution | ERROR | Condition evaluation |
| `ExecutionTimeout` | Execution exceeded maximum duration | WARNING | Duration check |
| `ExecutionDeadlock` | Two executions waiting on each other | CRITICAL | Dependency graph cycle detection |
| `UnauthorizedExecution` | Execution attempted without authorization | CRITICAL | Permission check |

### 2.6 Relation Conflicts

| Type | Description | Severity | Detection |
|------|-------------|----------|-----------|
| `DanglingEdge` | Edge references a non-existent Node | CRITICAL | Endpoint existence check |
| `ForbiddenRelation` | Edge type not allowed for source/target Patterns | ERROR | Edge type × Pattern check |
| `MissingRequiredRelation` | Required relation does not exist | ERROR | Relation existence check |
| `SelfLoop` | Edge source equals target for non-reflexive type | ERROR | Source ≠ target check |
| `DuplicateParallelEdge` | Duplicate edge of same type between same Nodes | WARNING | Edge deduplication check |
| `RelationCycle` | Circular dependency (A→B→C→A) | ERROR | Cycle detection |
| `RelationCardinalityViolation` | Too many or too few relations of a type | ERROR | Cardinality check |

### 2.7 Dependency Conflicts

| Type | Description | Severity | Detection |
|------|-------------|----------|-----------|
| `CircularDependency` | Dependency cycle detected | CRITICAL | Cycle detection |
| `MissingDependency` | Required dependency does not exist | CRITICAL | Dependency resolution |
| `VersionMismatch` | Dependency version incompatible with requirement | ERROR | Version comparison |
| `DependencyConflict` | Two dependencies mutually exclude each other | CRITICAL | Conflict set detection |
| `OrphanDependency` | Dependency not used by any Node | WARNING | Reference count check |
| `DependencyDrift` | Dependency version differs from declared | WARNING | Declared vs actual comparison |

### 2.8 Trust Conflicts

| Type | Description | Severity | Detection |
|------|-------------|----------|-----------|
| `TrustBelowThreshold` | Trust score below minimum required | WARNING | Score comparison |
| `TrustChainBroken` | Trust chain has a missing or invalid link | ERROR | Chain traversal |
| `TrustCircular` | Trust loop (A trusts B trusts A) | WARNING | Cycle detection |
| `TrustExpired` | Trust has expired without renewal | WARNING | Expiration check |
| `TrustSourceUnauthorized` | Trust set by unauthorized source | CRITICAL | Source permission check |
| `TrustDecayViolation` | Trust decay not tracked or incorrect | WARNING | Decay function check |

### 2.9 Evidence Conflicts

| Type | Description | Severity | Detection |
|------|-------------|----------|-----------|
| `MissingEvidence` | Required evidence not attached | ERROR | Evidence existence check |
| `EvidenceTooOld` | Evidence exceeded freshness window | WARNING | Timestamp freshness check |
| `EvidenceChainBroken` | Evidence chain has missing link | CRITICAL | Chain traversal |
| `EvidenceSignatureInvalid` | Cryptographic signature invalid | CRITICAL | Signature verification |
| `EvidenceTampered` | Evidence content hash mismatch | CRITICAL | Content hash check |
| `InsufficientEvidence` | Not enough evidence for required confidence | WARNING | Evidence count/quality check |

### 2.10 Mission Conflicts

| Type | Description | Severity | Detection |
|------|-------------|----------|-----------|
| `MissionStalled` | Mission has not progressed within expected time | WARNING | Progress check |
| `MissionDeadlock` | Mission blocked by unresolved dependency | ERROR | Dependency resolution |
| `MissionScopeViolation` | Mission action outside defined scope | ERROR | Scope boundary check |
| `MissionDuplicate` | Duplicate mission with same objective | INFO | Objective similarity check |
| `MissionPreconditionViolation` | Mission started without preconditions met | ERROR | Precondition evaluation |

### 2.11 Memory Conflicts

| Type | Description | Severity | Detection |
|------|-------------|----------|-----------|
| `MemoryStaleness` | Memory not refreshed within expected period | WARNING | Refresh timestamp check |
| `MemoryContradiction` | Two memories contain contradictory information | ERROR | Semantic contradiction detection |
| `MemoryOrphan` | Memory not referenced by any Node | WARNING | Reference count check |
| `MemoryDecayViolation` | Memory decay rate exceeds expected | INFO | Decay function check |
| `MemoryCapacityExceeded` | Memory size exceeds Pattern-defined capacity | WARNING | Size check |

### 2.12 Version Conflicts

| Type | Description | Severity | Detection |
|------|-------------|----------|-----------|
| `VersionRollback` | Version number decreased | ERROR | Version monotonicity check |
| `VersionJump` | Version increment skipped | WARNING | Version sequence check |
| `VersionConflict` | Two Nodes claim to be same version of same entity | ERROR | Version + identity comparison |
| `VersionStaleness` | Node version significantly behind latest | INFO | Version comparison |
| `IncompatibleVersion` | Version incompatibility between related Nodes | ERROR | Version range check |

### 2.13 Security Conflicts

| Type | Description | Severity | Detection |
|------|-------------|----------|-----------|
| `UnauthorizedAccess` | Access attempted without authorization | CRITICAL | Permission check |
| `PrivilegeEscalation` | Node acquired unauthorized privileges | CRITICAL | Privilege audit |
| `SecurityPolicyViolation` | Action violates security policy | CRITICAL | Policy evaluation |
| `AuthenticationFailure` | Identity verification failed | CRITICAL | Authentication check |
| `AccessAnomaly` | Unusual access pattern detected | WARNING | Behavioral analysis |

### 2.14 Governance Conflicts

| Type | Description | Severity | Detection |
|------|-------------|----------|-----------|
| `MissingApproval` | Required approval not obtained | CRITICAL | Approval status check |
| `ApprovalChainViolation` | Approval order incorrect | ERROR | Chain ordering check |
| `UnauthorizedMutation` | Mutation by unauthorized actor | CRITICAL | Actor permission check |
| `MissingAuditTrail` | Operation without audit event | ERROR | Audit log check |
| `ComplianceViolation` | External regulation requirement not met | CRITICAL | Compliance rule check |
| `GovernanceDeadlock` | Governance process cannot complete | CRITICAL | Governance flow analysis |

### 2.15 Semantic Conflicts

| Type | Description | Severity | Detection |
|------|-------------|----------|-----------|
| `SemanticContradiction` | Two assertions contradict each other | ERROR | Logical contradiction detection |
| `SemanticOverload` | Same term used with different meanings | WARNING | Definition consistency check |
| `CategoryMismatch` | Entity categorized under wrong type | ERROR | Category validation |
| `NamingCollision` | Same name used for different entities of same type | WARNING | Name uniqueness check |
| `DefinitionConflict` | Entity definition conflicts with Pattern definition | ERROR | Definition comparison |

### 2.16 Behavior Conflicts

| Type | Description | Severity | Detection |
|------|-------------|----------|-----------|
| `BehaviorMismatch` | Node behavior does not match Pattern | ERROR | Behavior × Pattern check |
| `CapabilityViolation` | Node performed action without capability | ERROR | Capability check |
| `BehaviorAnomaly` | Unusual behavioral pattern detected | WARNING | Behavioral profiling |
| `InteractionViolation` | Interaction type not in Pattern interactions | ERROR | Interaction type check |
| `BehavioralDeadlock` | Multiple behaviors blocking each other | CRITICAL | Behavior dependency analysis |

### 2.17 Pattern Conflicts

| Type | Description | Severity | Detection |
|------|-------------|----------|-----------|
| `PatternNotRegistered` | Pattern referenced but not in library | CRITICAL | Registry lookup |
| `PatternIncompatible` | Pattern incompatible with Archetype | ERROR | Pattern × Archetype validation |
| `PatternConstraintConflict` | Pattern constraints contradict Archetype constraints | CRITICAL | Constraint hierarchy check |
| `PatternCircularReference` | Pattern references itself through composition | ERROR | Reference graph cycle check |
| `PatternVersionMismatch` | Node references outdated Pattern version | WARNING | Version comparison |

### 2.18 Projection Conflicts

| Type | Description | Severity | Detection |
|------|-------------|----------|-----------|
| `ProjectionDivergence` | Projection differs from canonical Graph | ERROR | Hash comparison |
| `ProjectionStaleness` | Projection not updated after Graph mutation | WARNING | Timestamp comparison |
| `ProjectionLossyViolation` | Projection lost information without declaring it | ERROR | Fidelity declaration check |
| `ProjectionCorruption` | Projection output is malformed | ERROR | Format validation |
| `ProjectionUnauthorized` | Projection contains data user cannot access | CRITICAL | Permission check |

---

## 3. INCONSISTENCY SEVERITY MATRIX

| Impact \ Probability | High | Medium | Low |
|--------------------|------|--------|-----|
| **High** | CRITICAL | CRITICAL | ERROR |
| **Medium** | CRITICAL | ERROR | WARNING |
| **Low** | ERROR | WARNING | INFO |

- **Impact**: What is the consequence if this inconsistency remains?
- **Probability**: How likely is this inconsistency to cause cascading failures?

---

## 4. INCONSISTENCY LIFECYCLE

```
OPEN
  → INVESTIGATING (engine or human is analyzing)
    → MITIGATED (temporary workaround applied)
    → RESOLVED (root cause fixed, state valid)
    → FALSE_POSITIVE (determined not to be an actual violation)
    → ESCALATED (requires human intervention)
```

### 4.1 Lifecycle Rules

- Any inconsistency can transition from any state to ESCALATED
- RESOLVED requires re-validation passing
- FALSE_POSITIVE requires documentation of why
- MITIGATED requires an associated workaround Node in the Graph
- Inconsistencies in OPEN state for >30 days auto-escalate

---

## 5. INCONSISTENCY DEDUPLICATION

Two inconsistencies are considered duplicates if they have the same **signature**:

```
signature = hash(
  inconsistency.type
  + inconsistency.location.node
  + inconsistency.location.edge
  + inconsistency.location.constraint
)
```

Deduplication prevents the same violation from generating multiple reports.

---

## 6. INCONSISTENCY PATTERNS

### 6.1 Cascading Inconsistency

One inconsistency triggers others:
```
IdentityCollision
  └─ RelationshipConflict (edges point to wrong Node)
    └─ TrustChainBroken (trust chain references wrong identity)
      └─ EvidenceChainBroken (evidence on wrong Node)
```

### 6.2 Compound Inconsistency

Multiple constraints violated by a single state:
```
ForbiddenState + LifecycleSkip + MissingRequiredRelation
  (e.g., Node jumped to ACTIVE without CREATED and without required edges)
```

### 6.3 Latent Inconsistency

Valid now, but will become invalid:
```
Trust score 0.6 with MinTrust 0.5
→ Tomorrow trust decays to 0.45 → violates MinTrust
```

The Coherence Engine must detect and warn about latent inconsistencies.

---

**CANONICO_INCONSISTENCY_MODEL.md — V2**
**INCONSISTENCY TAXONOMY**
**License: Open Standard**
