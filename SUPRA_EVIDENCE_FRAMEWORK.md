# SUPRA Evidence Framework — Specification V1

## Status: SPECIFICATION — SUPRA ULTIMATE CONSOLIDATED PHASE 1

| Propriété | Valeur |
|-----------|--------|
| **Version** | SUPRA_EVIDENCE_FRAMEWORK_V1 |
| **Date** | 2026-07-29 |
| **Autorité** | SUPRA Knowledge Compiler — Evidence Engine |
| **Préséance** | Cadre de preuve unique |
| **Héritage** | CANONICO Evidence Model, ProofGraph Chain Model (absorbés) |

---

## 1. EVIDENCE PRINCIPLE

Every claim in SUPRA must be supported by evidence.

Every evidence must be traceable to a root of trust.

The evidence graph is the **verification backbone** of the knowledge graph.

---

## 2. EVIDENCE TYPES

| Type | Description | Source |
|------|-------------|--------|
| ProofChain | Ordered sequence of proof steps | ProofGraph, Compiler trace |
| Attestation | Signed statement of fact | INPI, Witness |
| Verification | Result of a validation process | CANONICO, Validator |
| Observation | Direct measurement or observation | Runtime, Monitor |
| Derivation | Logical derivation from premises | Reasoner |
| Reference | Citation of authoritative source | Document |
| Signature | Cryptographic or logical marker | ProofGraph |
| AuditLog | Immutable event record | Compiler, System |

---

## 3. EVIDENCE CHAIN MODEL

### 3.1 Chain Structure

```
TrustAnchor (root of trust)
  │
  ▼
ChainLink[1] (axiom or verified fact)
  │
  ▼
ChainLink[2] (derived fact)
  │
  ▼
ChainLink[3] (inferred fact)
  │
  ▼
...
  │
  ▼
Claim (the statement being proved)
```

### 3.2 Chain Link

```json
{
  "id": "ev:link:{uuid}",
  "type": "AXIOM | VERIFIED | DERIVED | INFERRED | OBSERVED",
  "statement": "The concept being evidenced",
  "source": {"type": "document | code | observation | inference", "ref": "source:ref"},
  "inferenceRule": "modus-ponens | induction | deduction | abductive | null (for axioms)",
  "premises": ["ev:link:{uuid1}", "ev:link:{uuid2}"],
  "confidence": 0.95,
  "timestamp": "ISO8601",
  "signature": "sig:{hash}"
}
```

### 3.3 Trust Anchor

```json
{
  "id": "ev:anchor:{uuid}",
  "type": "CONSTITUTION | AXIOM | OBSERVATION | SIGNATURE | HUMAN",
  "description": "Root of trust description",
  "trustScore": 1.0,
  "source": "SUPRA Constitution | Fundamental axiom | Direct observation",
  "timestamp": "ISO8601"
}
```

---

## 4. EVIDENCE ENGINE

### 4.1 Build Chain

```
Input: Claim + GraphState
  │
  ▼
1. Find all evidence connected to claim
2. For each evidence: verify its own proof chain
3. Continue recursively until reaching trust anchors
4. Assemble complete chain
5. Verify chain validity
  │
  ▼
Output: EvidenceChain { links, anchors, confidence, isValid }
```

### 4.2 Verify Chain

```
Input: EvidenceChain
  │
  ▼
1. Check each link has valid source reference
2. Check each inference rule is correctly applied
3. Check chain reaches at least one trust anchor
4. Check no cycles (circular proofs)
5. Check no gaps (missing intermediate steps)
6. Compute chain confidence (product of link confidences)
7. Verify signatures if present
  │
  ▼
Output: VerificationResult { isValid, confidence, breaks, cycles }
```

### 4.3 Detect Contradictions

```
Input: Two EvidenceChains
  │
  ▼
1. Extract conclusions of each chain
2. Compare conclusions
3. IF contradictory conclusions AND both chains valid:
   CONTRADICTORY_EVIDENCE
4. IF contradictory conclusions AND one chain invalid:
   RESOLVED_CONTRADICTION (trust valid chain)
  │
  ▼
Output: EvidenceContradiction { chainA, chainB, resolution }
```

---

## 5. HYPOTHESIS-PROOF BALANCE

### 5.1 Rules

| Rule | Description | Severity |
|------|-------------|----------|
| Every hypothesis has a proof | ∀ hypothesis: ∃ evidence chain | ERROR |
| Every proof has a hypothesis | ∀ proof: ∃ hypothesis it supports | ERROR |
| No circular proofs | Evidence chains are acyclic | CRITICAL |
| Chain reaches trust anchor | Every chain ends at a trust anchor | CRITICAL |
| No contradictory evidence | Two chains don't prove opposite claims | CRITICAL |
| Evidence freshness | Evidence is not expired | WARNING |
| Evidence diversity | Not all evidence from same source | WARNING |

### 5.2 Hypothesis Registry

```json
{
  "id": "hyp:{uuid}",
  "statement": "Proposition being tested",
  "status": "PROVEN | UNPROVEN | DISPROVEN | UNTESTABLE",
  "evidenceChains": ["ev:chain:{uuid}"],
  "confidence": 0.85,
  "source": "source:ref"
}
```

---

## 6. TRUST ENGINE

### 6.1 Trust Score Computation

```
trustScore(claim) = ∏ trustScore(link) for all links in chain
trustScore(anchor) = 1.0 (by definition)
trustScore(link) = sourceTrust(source) * inferenceConfidence(rule)
```

### 6.2 Source Trust

| Source Type | Base Trust | Decay Rate |
|-------------|------------|------------|
| SUPRA Constitution | 1.0 | None |
| Verified observation | 0.95 | 0.01/year |
| Formal proof | 0.90 | None |
| Expert attestation | 0.80 | 0.05/year |
| Documented evidence | 0.75 | 0.02/year |
| Inference | 0.70 | None |
| External reference | 0.50 | 0.10/year |
| Unverified claim | 0.10 | N/A |

### 6.3 Trust Propagation

```
trust(A → B → C) = trust(A) * trust(B|A) * trust(C|B)

Where:
- trust(A) is the trust in the root anchor
- trust(B|A) is the conditional trust of step B given A
- trust(C|B) is the conditional trust of step C given B
```

---

## 7. EVIDENCE METRICS

| Metric | Target | Measurement |
|--------|--------|-------------|
| Evidence chain completeness | 100% of claims | Per graph |
| Chain verification time | < 50ms | Per chain |
| Trust anchor reachability | 100% of chains | Per graph |
| Hypothesis coverage | > 90% | Per graph |
| Evidence diversity score | > 0.5 | Per claim |
| Evidence freshness | < 1 year | Per evidence item |
| Contradiction detection rate | > 0.99 | Per contradiction |
| False positive rate | < 0.01 | Per detection |
