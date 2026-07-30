# SUPRA Executive Graph — Specification V1

## Status: SPECIFICATION — SUPRA ULTIMATE CONSOLIDATED PHASE 1

| Propriété | Valeur |
|-----------|--------|
| **Version** | SUPRA_EXECUTIVE_GRAPH_V1 |
| **Date** | 2026-07-29 |
| **Autorité** | SUPRA Knowledge Compiler — Executive Engine |
| **Préséance** | Graphe décisionnel unique pour la gouvernance SUPRA |

---

## 1. EXECUTIVE GRAPH PRINCIPLE

The Executive Graph is the **decision-ready condensed view** of all compiled knowledge.

It is the single source of truth for executive decision-making.

Every statement in the Executive Graph is traceable to its full evidence chain.

---

## 2. GRAPH STRUCTURE

### 2.1 Node Types

| Type | Description | Contents |
|------|-------------|----------|
| Decision | An executive decision taken | decisionId, timestamp, rationale, authority |
| Risk | Identified risk or issue | riskId, type, severity, impact, mitigation |
| Fact | Verified statement of fact | factId, statement, confidence, sourceRef |
| Metric | Measurable system value | metricId, name, value, trend, threshold |
| Change | Delta from previous state | changeId, type, oldValue, newValue, impact |
| Alert | Critical notification | alertId, type, severity, details, action |
| Recommendation | Proposed course of action | recId, description, expectedImpact, cost |
| Dependency | Cross-component dependency | depId, source, target, type, criticality |
| Status | Component or system status | componentId, status, health, lastUpdated |

### 2.2 Edge Types

| Type | Meaning |
|------|---------|
| BASED_ON | Decision is based on fact/metric |
| MITIGATES | Recommendation mitigates risk |
| CAUSES | Change causes impact |
| DEPENDS_ON | Dependency relationship |
| TRIGGERED_BY | Alert triggered by metric |
| RESOLVES | Decision resolves issue |
| UPDATES | Change updates status |

---

## 3. EXECUTIVE GRAPH PIPELINE

```
Input: All compiled graphs (Knowledge, Constraint, Evidence, Consistency)
  │
  ▼
1. Extract Key Facts
   ├── All verified statements with high confidence (>0.9)
   ├── All published decisions
   └── All active constraints
  │
  ▼
2. Extract Critical Risks
   ├── All CRITICAL severity violations
   ├── All ERROR severity violations
   └── Risk aggregation by category
  │
  ▼
3. Compute Deltas
   ├── Compare with previous Executive Graph
   ├── New facts, changed facts, removed facts
   ├── New violations, resolved violations
   └── Metric trends
  │
  ▼
4. Generate Recommendations
   ├── For each unresolved violation: repair proposal
   ├── For each risk: mitigation strategy
   └── Priority-based ranking
  │
  ▼
5. Build Graph
   ├── Create Executive Graph topology
   ├── Link every node to source trace
   └── Verify executive graph consistency
  │
  ▼
6. Publish
   ├── Register in Executive Graph registry
   ├── Notify executive consumers
   └── Archive previous version
```

---

## 4. EXECUTIVE GRAPH FORMAT

### 4.1 Full Format

```json
{
  "graphId": "exec:graph:{uuid}",
  "version": 142,
  "timestamp": "2026-07-29T22:00:00Z",
  "sourceCompilation": "kc:comp:{uuid}",
  "summary": {
    "status": "CONSISTENT | WARNING | CRITICAL",
    "globalCoherence": 0.97,
    "totalFacts": 1250,
    "totalDecisions": 48,
    "totalRisks": 7,
    "criticalViolations": 0,
    "errorViolations": 2,
    "warningViolations": 15
  },
  "facts": [
    {
      "id": "exec:fact:{uuid}",
      "statement": "Knowledge Compiler is the single entry point for all knowledge",
      "confidence": 1.0,
      "source": "SUPRA_KNOWLEDGE_COMPILER.md §1",
      "category": "ARCHITECTURE",
      "status": "VERIFIED"
    }
  ],
  "decisions": [
    {
      "id": "exec:decision:{uuid}",
      "decision": "Adopt compositional root pattern for SUPRA OS",
      "rationale": "Unifies 12 functional spaces under single shell",
      "authority": "SUPRA Constitution Article 11",
      "date": "2026-07-28",
      "status": "ACTIVE",
      "evidence": ["ev:chain:{uuid}"],
      "impacts": ["Component reorganization", "Interface consolidation"]
    }
  ],
  "risks": [
    {
      "id": "exec:risk:{uuid}",
      "type": "INCONSISTENCY",
      "severity": "HIGH",
      "description": "Vocabulary drift between CANONICO and SUPRA ontology",
      "impact": "Potential alignment failures in future compilations",
      "mitigation": "Run ontology alignment audit",
      "status": "MONITORING",
      "sourceViolation": "V-009-{uuid}"
    }
  ],
  "metrics": [
    {
      "id": "exec:metric:{uuid}",
      "name": "Global Coherence Score",
      "value": 0.97,
      "threshold": 0.95,
      "trend": "STABLE | IMPROVING | DECLINING",
      "unit": "score",
      "timestamp": "2026-07-29T22:00:00Z"
    }
  ],
  "changes": [
    {
      "id": "exec:change:{uuid}",
      "type": "ADDITION | MODIFICATION | REMOVAL | STATUS_CHANGE",
      "description": "New violation detected: Vocabulary conflict in 'Node' definition",
      "impact": "2 documents affected",
      "resolution": "Pending ontology alignment",
      "timestamp": "2026-07-29T22:00:00Z"
    }
  ],
  "recommendations": [
    {
      "id": "exec:rec:{uuid}",
      "priority": "HIGH | MEDIUM | LOW",
      "description": "Run cross-document term normalization",
      "expectedImpact": "Resolve 3 vocabulary conflicts",
      "cost": "Low (automated)",
      "status": "PENDING"
    }
  ],
  "graph": {
    "nodes": [...],
    "edges": [...]
  }
}
```

### 4.2 Compact Format (For Dashboard)

```json
{
  "graphId": "exec:graph:{uuid}",
  "summary": {
    "status": "CONSISTENT",
    "coherence": 0.97,
    "criticalRisks": 0,
    "changes": 23,
    "recommendations": 5
  },
  "keyFacts": ["Fact 1", "Fact 2", "Fact 3"],
  "topRisks": ["Risk 1", "Risk 2"],
  "topRecommendations": ["Rec 1", "Rec 2"]
}
```

---

## 5. EXECUTIVE REPORTING

### 5.1 Report Types

| Report | Content | Frequency |
|--------|---------|-----------|
| Daily | Summary, risks, changes, recommendations | Daily |
| Per-Compilation | Full graph for each compilation | Per event |
| Weekly | Trends, metrics, risk evolution | Weekly |
| Milestone | Full system state at milestone | Per milestone |
| Crisis | Immediate critical violations + resolution | On critical violation |

### 5.2 Report Generation

```
Input: ExecutiveGraph
  │
  ▼
1. Filter by severity (CRITICAL + ERROR + WARNING)
2. Group by category
3. Rank by priority (severity * impact * urgency)
4. Generate natural language summary
5. Link every statement to traceability
6. Format for target audience (executive, technical, operational)
```

---

## 6. EXECUTIVE GRAPH GOVERNANCE

| Rule | Description |
|------|-------------|
| Traceability | Every node links to source compilation evidence |
| Consistency | Executive graph must be consistent with source graphs |
| Freshness | Never older than the latest compilation |
| Minimality | Only decision-relevant information |
| No duplication | Each fact exists in exactly one position |
| Immutable history | Previous versions are never modified |

---

## 7. EXECUTIVE ENGINE

### 7.1 Responsibilities

1. Extract decision-relevant facts from compiled graphs
2. Aggregate risks by category and severity
3. Compute deltas from previous executive state
4. Generate ranked recommendations
5. Format for multiple consumption channels
6. Maintain versioned history

### 7.2 Interfaces

| Method | Input | Output |
|--------|-------|--------|
| `compile(graphs)` | All compiled graphs | ExecutiveGraph |
| `current()` | — | Latest ExecutiveGraph |
| `delta(version)` | Previous version | ChangeSet |
| `report(type)` | Report type | Formatted report |
| `subscribe(consumer, filter)` | Consumer + filter | Subscription |
