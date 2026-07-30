# FACTORY_02_DISCOVERY — Specification V1

## Mission

Continuously discover repository knowledge.

## Responsibility

Surface every capability, module, pattern, and relationship present in the repository. Detect hidden capabilities, dead code, and duplication opportunities.

## Owner

SUPRA-Explorer

## Inputs

| Input | Source | Format |
|-------|--------|--------|
| Full repository | Filesystem | Directory tree + file contents |
| Architecture map | FACTORY_01 | ARCHITECTURE_MAP.md |
| Source code | Swift files | Source text + AST |
| Scripts | *.sh | Shell scripts |
| Configuration | *.json, *.plist | Structured data |

## Outputs

| Output | Format | Description |
|--------|--------|-------------|
| DISCOVERY_REPORT.md | Markdown | Comprehensive discovery findings |
| MODULE_INDEX.md | Markdown | Index of all modules with capabilities, interfaces, and dependencies |
| DUPLICATE_REPORT.md | Markdown | All detected code, pattern, and documentation duplication |

## Gates

### INPUT Gate
- FACTORY_01 outputs are certified
- Repository is fully readable

### EXECUTION Gate
- Previous discovery reports available for diff
- Workspace is indexed

### OUTPUT Gate
- Every module documented
- Every duplicate logged
- Every hidden capability surfaced
- Discovery is reproducible

## Quality Criteria

1. **Completeness**: Every file classified
2. **Accuracy**: Module boundaries are correct
3. **Duplication**: Zero false positives in duplicate detection
4. **Freshness**: Discovery reflects HEAD of repository

## Templates

See `templates/` directory for output artefact templates.

## Automation

See `gates/` directory for gate validation scripts.
