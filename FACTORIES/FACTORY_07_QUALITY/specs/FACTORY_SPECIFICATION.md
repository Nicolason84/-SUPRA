# FACTORY_07_QUALITY — Specification V1

## Mission

Protect production quality.

## Responsibility

Detect regressions. Verify consistency across all artefacts. Track technical debt. Analyze duplication. Verify system stability.

## Owner

SUPRA-Reviewer / SUPRA-Auditor

## Inputs

| Input | Source | Format |
|-------|--------|--------|
| All factory outputs | All FACTORIES | Various |
| Source code | Repository | Swift files |
| Build reports | FACTORY_03 | BUILD_REPORT.md |
| Knowledge graph | FACTORY_04 | KNOWLEDGE_GRAPH.json |
| Proof report | FACTORY_06 | PROOF_REPORT.md |
| Memory state | FACTORY_05 | MEMORY_STATE.json |

## Outputs

| Output | Format | Description |
|--------|--------|-------------|
| QUALITY_REPORT.md | Markdown | Quality assessment across all dimensions |

## Gates

### INPUT Gate
- All upstream factory outputs are certified
- FACTORY_06 proof report is available

### EXECUTION Gate
- Quality dimensions are defined
- Thresholds are calibrated

### OUTPUT Gate
- Every quality dimension is scored
- All regressions are documented
- All inconsistencies are flagged
- Technical debt is quantified
- Quality score is reproducible

## Quality Dimensions

| Dimension | Description | Threshold |
|-----------|-------------|-----------|
| Build Quality | % of successful builds | ≥ 100% |
| Test Coverage | % of code covered by tests | ≥ 70% |
| Documentation Coverage | % of components documented | ≥ 90% |
| Duplication | % of code duplicated | ≤ 5% |
| Consistency | % of artefacts consistent with each other | ≥ 95% |
| Knowledge Coherence | % of knowledge graph internally consistent | ≥ 98% |
| Technical Debt | Estimated effort to fix known issues | Tracked |
| Dead Code | % of code that is unreachable | ≤ 2% |

## Templates

See `templates/` directory for output artefact templates.

## Automation

See `gates/` directory for gate validation scripts.
