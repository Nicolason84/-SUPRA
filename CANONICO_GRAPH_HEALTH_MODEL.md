# CANONICO Graph Health Model

## Status: SPECIFICATION V2 — GRAPH HEALTH

---

## 1. HEALTH MODEL OVERVIEW

The Graph Health Model defines how coherence is measured at every level of the system — Node, Edge, Pattern, Subgraph, and Graph. Health is not a single number but a **composite vector** of scores, each derived from constraint satisfaction rates, integrity checks, and temporal metrics.

### 1.1 Core Principle

Health is a **derived metric**, never a stored attribute. It is computed on demand by the Health Scorer subsystem of the Coherence Engine, based on the current Graph state and its constraint satisfaction status.

### 1.2 Score Categories

| Category | What It Measures | Range |
|----------|-----------------|-------|
| Coherence | Overall constraint satisfaction | 0.0 – 1.0 |
| Trust | Reliability and confidence | 0.0 – 1.0 |
| Integrity | Structural and cryptographic soundness | 0.0 – 1.0 |
| Consistency | Semantic and behavioral alignment | 0.0 – 1.0 |
| Evidence | Proof and attestation completeness | 0.0 – 1.0 |

---

## 2. NODE HEALTH

Every Node in the Graph has a health profile computed from its constraint satisfaction, dimension values, and evidence status.

```
NodeHealth {
  nodeId: Identity

  // Core scores
  coherenceScore: Float              [0.0 – 1.0]
  trustScore: Float                  [0.0 – 1.0]
  integrityScore: Float              [0.0 – 1.0]
  consistencyScore: Float            [0.0 – 1.0]
  evidenceScore: Float               [0.0 – 1.0]

  // Composite
  overallHealth: Float               [0.0 – 1.0]

  // Details
  constraintSatisfaction: ConstraintSatisfactionSummary {
    total: Int
    satisfied: Int
    violated: Int
    notApplicable: Int
    satisfactionRate: Float          [satisfied / total]
  }

  integrityChecks: IntegritySummary {
    total: Int
    passed: Int
    failed: Int
    integrityRate: Float
  }

  evidenceStatus: EvidenceSummary {
    required: Int
    attached: Int
    verified: Int
    expired: Int
    evidenceCompleteness: Float
  }

  dimensionHealth: DimensionHealth {
    ownership: Float?
    dependency: Float?
    importance: Float?
    trust: Float?
    energy: Float?
    activity: Float?
    lifecycle: Float?
    execution: Float?
    version: Int?
  }

  lifecycleHealth: LifecycleHealth {
    currentState: String
    legalTransitions: [String]
    stuck: Bool                      [true if no legal transition available]
    durationInCurrent: Duration
  }

  lastValidated: Timestamp?
  metadata: Map
}
```

### 2.1 Node Score Computation

#### Coherence Score

```
coherenceScore = constraintSatisfaction.satisfactionRate

If coherenceScore < 0.5:
  additional penalty for CRITICAL violations

coherenceScore -= (criticalViolationCount * 0.2)
coherenceScore = max(0.0, coherenceScore)
```

#### Trust Score

```
trustScore = node.dimensions.trust

If evidenceStatus.verified < evidenceStatus.required:
  trustScore *= (evidenceStatus.verified / evidenceStatus.required)

If evidenceStatus.expired > 0:
  trustScore *= (1.0 - (evidenceStatus.expired / evidenceStatus.attached) * 0.5)
```

#### Integrity Score

```
integrityScore = integrityChecks.integrityRate

If any CRITICAL integrity failure:
  integrityScore *= 0.5

If identity verified:
  integrityScore = min(integrityScore, 1.0)
```

#### Consistency Score

```
consistencyScore = weighted average of:
  - semantic consistency checks
  - behavioral consistency checks
  - temporal consistency checks
  - identity consistency checks

Each check contributes equally unless configured otherwise.
```

#### Evidence Score

```
evidenceScore = evidenceStatus.evidenceCompleteness

If required evidence missing:
  evidenceScore *= 0.5

If evidence expired:
  evidenceScore *= (1.0 - expiredRatio * 0.25)
```

#### Overall Health

```
overallHealth = (
  coherenceScore * COHERENCE_WEIGHT     [0.30]
  + trustScore * TRUST_WEIGHT           [0.20]
  + integrityScore * INTEGRITY_WEIGHT   [0.25]
  + consistencyScore * CONSISTENCY_WEIGHT [0.15]
  + evidenceScore * EVIDENCE_WEIGHT     [0.10]
)

Default: overallHealth ∈ [0.0, 1.0]
```

---

## 3. EDGE HEALTH

Every Edge has a health profile focused on validity, confidence, and integrity.

```
EdgeHealth {
  edgeId: Identity

  // Core scores
  validityScore: Float               [0.0 – 1.0]
  confidenceScore: Float             [0.0 – 1.0]
  integrityScore: Float              [0.0 – 1.0]

  // Edge properties
  weight: Float
  trust: Float
  direction: Direction
  lifecycle: LifecycleState

  // Details
  constraintSatisfaction: ConstraintSatisfactionSummary
  endpointHealth: {
    sourceHealth: NodeHealth?
    targetHealth: NodeHealth?
    bothExist: Bool
    bothActive: Bool
  }

  lastValidated: Timestamp?
}
```

### 3.1 Edge Score Computation

#### Validity Score

```
validityScore = constraintSatisfaction.satisfactionRate

If endpointHealth.bothExist = false:
  validityScore = 0.0 (CRITICAL)
```

#### Confidence Score

```
confidenceScore = edge.trust

If endpointHealth.bothActive = false:
  confidenceScore *= 0.5
```

#### Integrity Score

```
integrityScore = 1.0

If edge is dangling (endpoint missing):
  integrityScore = 0.0

If edge lifecycle is inconsistent with endpoints:
  integrityScore = max(0.0, integrityScore - 0.3)
```

---

## 4. SUBGRAPH HEALTH

A subgraph health profile aggregates Node and Edge health within a query-defined scope.

```
SubgraphHealth {
  query: GraphQuery
  nodeCount: Int
  edgeCount: Int

  // Aggregated scores
  averageNodeHealth: Float
  averageEdgeHealth: Float
  subgraphCoherence: Float
  subgraphTrust: Float
  subgraphIntegrity: Float
  subgraphHealth: Float

  // Distribution
  healthDistribution: {
    critical: Int     [health < 0.3]
    degraded: Int     [health 0.3–0.6]
    healthy: Int      [health 0.6–0.8]
    excellent: Int    [health 0.8–1.0]
  }

  worstNodes: [NodeHealth]           [bottom 5 by health]
  worstEdges: [EdgeHealth]           [bottom 5 by health]
}
```

### 4.1 Subgraph Score Computation

```
subgraphHealth = weighted average of all Node and Edge health scores
subgraphCoherence = average of all Node coherence scores
subgraphTrust = average of all Node trust scores
subgraphIntegrity = average of all Node and Edge integrity scores
```

---

## 5. GRAPH HEALTH

The global Graph health model is the top-level aggregation.

```
GraphHealth {
  graphId: Identity
  timestamp: Timestamp

  // Node metrics
  totalNodes: Int
  activeNodes: Int
  archivedNodes: Int
  suspendedNodes: Int

  // Edge metrics
  totalEdges: Int
  activeEdges: Int

  // Global scores
  globalCoherenceScore: Float        [0.0 – 1.0]
  globalIntegrityScore: Float         [0.0 – 1.0]
  globalTrustScore: Float             [0.0 – 1.0]
  globalConsistencyScore: Float       [0.0 – 1.0]
  globalEvidenceScore: Float          [0.0 – 1.0]
  globalHealthScore: Float            [0.0 – 1.0] (composite)

  // Distribution
  nodeHealthDistribution: Distribution
  edgeHealthDistribution: Distribution
  coherenceDistribution: Distribution

  // Violation summary
  totalViolations: Int
  criticalViolations: Int
  errorViolations: Int
  warningViolations: Int
  infoViolations: Int

  // Trend (compared to last health check)
  trend: HealthTrend {
    direction: "IMPROVING" | "STABLE" | "DEGRADING" | "CRITICAL"
    deltaGlobalHealth: Float
    deltaCriticalViolations: Int
    since: Timestamp
  }

  // Metadata
  validatedAt: Timestamp
  validationDuration: Duration
  nextScheduledValidation: Timestamp
}
```

### 5.1 Global Score Computation

#### Global Coherence Score

```
globalCoherenceScore = (
  sum of all Node coherence scores / totalNodes
  * COHERENCE_NODE_WEIGHT             [0.6]
  + sum of all Edge validity scores / totalEdges
  * COHERENCE_EDGE_WEIGHT             [0.4]
)
```

#### Global Integrity Score

```
globalIntegrityScore = (
  sum of all Node integrity scores / totalNodes
  * INTEGRITY_NODE_WEIGHT             [0.5]
  + sum of all Edge integrity scores / totalEdges
  * INTEGRITY_EDGE_WEIGHT             [0.5]
)
```

#### Global Trust Score

```
globalTrustScore = sum of all Node trust scores / totalNodes
```

#### Global Consistency Score

```
globalConsistencyScore = sum of all Node consistency scores / totalNodes
```

#### Global Evidence Score

```
globalEvidenceScore = sum of all Node evidence scores / totalNodes
```

#### Global Health Score

```
globalHealthScore = (
  globalCoherenceScore * 0.30
  + globalIntegrityScore * 0.25
  + globalTrustScore * 0.20
  + globalConsistencyScore * 0.15
  + globalEvidenceScore * 0.10
)
```

---

## 6. HEALTH THRESHOLDS

| Level | Global Health Score | Meaning | Action |
|-------|-------------------|---------|--------|
| `EXCELLENT` | 0.90 – 1.00 | All systems coherent | Normal operation |
| `HEALTHY` | 0.75 – 0.89 | Minor issues, non-critical | Monitor |
| `DEGRADED` | 0.50 – 0.74 | Significant issues | Investigate and plan repairs |
| `CRITICAL` | 0.25 – 0.49 | Severe coherence failures | Immediate intervention required |
| `COLLAPSED` | 0.00 – 0.24 | System integrity compromised | Emergency governance escalation |

### 6.1 Threshold Actions

| Threshold | Automated Action |
|-----------|-----------------|
| `CRITICAL` | Alert governance channel, block non-essential mutations |
| `DEGRADED` | Generate repair proposals, notify administrators |
| `HEALTHY` | Log, continue normal operation |
| `EXCELLENT` | Log achievement (optional) |

---

## 7. HEALTH TREND

Health is tracked over time to detect degradation patterns.

```
HealthHistory {
  snapshots: [HealthSnapshot]        [ordered by timestamp]
  trendWindow: Duration              [default: 7 days]
  metrics: {
    averageHealth: Float
    healthVariance: Float
    degradationRate: Float            [negative = improving]
    volatility: Float                 [how much health fluctuates]
  }
}
```

### 7.1 Trend Direction

| Trend | Condition |
|-------|-----------|
| `IMPROVING` | health delta > +0.05 over trend window |
| `STABLE` | health delta ∈ [-0.05, +0.05] |
| `DEGRADING` | health delta < -0.05 |
| `CRITICAL` | globalHealthScore < 0.25 |

---

## 8. HEALTH REPORTING

### 8.1 Periodic Report

Generated on schedule (default: hourly):

```
Health Report — 2026-07-29T14:00:00Z
─────────────────────────────────────
Global Health:      0.87 (HEALTHY)   ▲ +0.02
  Coherence:        0.91
  Integrity:        0.88
  Trust:            0.84
  Consistency:      0.86
  Evidence:         0.82

Violations:         12 total
  CRITICAL:         0
  ERROR:            3
  WARNING:          9

Node Health Distribution:
  Excellent:        142 (71%)
  Healthy:          42  (21%)
  Degraded:         12  (6%)
  Critical:         4   (2%)

Worst Nodes:
  can:sys:a1b2...   0.31 (CRITICAL)  — Missing required evidence
  can:agt:c3d4...   0.45 (CRITICAL)  — Trust below minimum
  ...
```

### 8.2 Alert Triggers

| Trigger | Action |
|---------|--------|
| Any Node enters CRITICAL health | Immediate alert |
| Global health drops below 0.50 | Immediate alert |
| CRITICAL violation count increases | Immediate alert |
| Health trend becomes DEGRADING | Warning notification |
| Any Node stuck in lifecycle for >30 days | Warning notification |

---

## 9. HEALTH GOVERNANCE

- Health scores are never stored — they are always derived
- Health computation must complete within bounded time (default: 30s for full Graph)
- Health reports are immutable Graph Events
- Any component can query health at any scope level
- Health data is accessible via the Graph Runtime health endpoint

---

**CANONICO_GRAPH_HEALTH_MODEL.md — V2**
**GRAPH HEALTH MODEL**
**License: Open Standard**
