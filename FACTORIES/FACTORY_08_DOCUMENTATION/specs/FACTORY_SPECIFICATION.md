# FACTORY_08_DOCUMENTATION — Specification V1

## Mission

Generate documentation automatically.

## Responsibility

Produce all external documentation from certified artefacts. README, architecture docs, API references, RFCs, and agent instructions. Never write documentation from scratch — always derive from certified sources.

## Owner

SUPRA-Builder

## Inputs

| Input | Source | Format |
|-------|--------|--------|
| Architecture map | FACTORY_01 | ARCHITECTURE_MAP.md |
| Discovery report | FACTORY_02 | DISCOVERY_REPORT.md |
| Knowledge graph | FACTORY_04 | KNOWLEDGE_GRAPH.json |
| Quality report | FACTORY_07 | QUALITY_REPORT.md |
| Certification report | FACTORY_06 | CERTIFICATION_REPORT.md |
| Source code | Repository | Swift files |

## Outputs

| Output | Format | Description |
|--------|--------|-------------|
| AGENTS.md | Markdown | Production-grade agent operating contract |
| ARCHITECTURE.md | Markdown | System architecture guide |
| README.md | Markdown | Project overview and getting started |
| RFC/ | Markdown | RFC directory for design documents |
| API/ | Markdown | API reference documentation |

## Gates

### INPUT Gate
- All upstream factory outputs are certified
- Documentation templates exist

### EXECUTION Gate
- Documentation strategy is defined
- Output structure is planned

### OUTPUT Gate
- Every public interface is documented
- Architecture is described completely
- No placeholder or TODO in documentation
- Documentation is internally consistent
- Documentation matches the code

## Quality Criteria

1. **Completeness**: Every component documented
2. **Accuracy**: Documentation matches source code
3. **Freshness**: Documentation regenerated from current artefacts
4. **Consistency**: No contradictions across documents

## Templates

See `templates/` directory for output artefact templates.

## Automation

See `gates/` directory for gate validation scripts.
