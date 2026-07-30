# FACTORY_06_PROOF — Specification V1

## Mission

Certify every assertion.

## Responsibility

Generate proofs for every claim made in the system. Validate evidence chains. Assign confidence scores. Certify artefacts and decisions.

## Owner

SUPRA-Auditor

## Inputs

| Input | Source | Format |
|-------|--------|--------|
| All factory outputs | All FACTORIES | Various |
| Knowledge graph | FACTORY_04 | KNOWLEDGE_GRAPH.json |
| Evidence data | FACTORY_04 | EVIDENCE_GRAPH.json |
| Claims and assertions | Repository | Various |

## Outputs

| Output | Format | Description |
|--------|--------|-------------|
| PROOF_REPORT.md | Markdown | Proof status for all claims, with evidence and confidence |
| CERTIFICATION_REPORT.md | Markdown | Certification status of all artefacts |

## Gates

### INPUT Gate
- FACTORY_04 outputs are certified
- Claims are enumerated
- Evidence is indexed

### EXECUTION Gate
- Proof strategy is defined
- Confidence model is calibrated

### OUTPUT Gate
- Every claim has a confidence score
- Every artefact has a certification status
- Proofs are complete (no dangling claims)
- Confidence scores are reproducible

## Quality Criteria

1. **Coverage**: 100% of claims have proof assignments
2. **Confidence**: Scores are calibrated and verifiable
3. **Traceability**: Every proof links to its evidence chain
4. **Completeness**: No unproven claims

## Templates

See `templates/` directory for output artefact templates.

## Automation

See `gates/` directory for gate validation scripts.
