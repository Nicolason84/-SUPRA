# FACTORY_01_ARCHITECTURE — Specification V1

## Mission

Maintain the unique architectural truth of the SUPRA system.

## Responsibility

The architectural integrity of the entire repository. Every structural decision, every dependency, every component boundary must be documented, validated, and traceable.

## Owner

SUPRA-Architect

## Inputs

| Input | Source | Format |
|-------|--------|--------|
| Repository structure | Filesystem | Directory tree |
| Source code | Swift files | AST |
| Package definitions | Package.swift | Swift PM |
| Xcode project | SUPRA.xcodeproj | pbxproj |
| Existing documentation | *.md | Markdown |

## Outputs

| Output | Format | Description |
|--------|--------|-------------|
| ARCHITECTURE_MAP.md | Markdown | Complete component map with boundaries and responsibilities |
| SYSTEM_TOPOLOGY.md | Markdown | Runtime topology: processes, threads, communication channels |
| EXECUTION_GRAPH.md | Markdown | Complete execution flow: entry points, call chains, async boundaries |
| DEPENDENCY_GRAPH.md | Markdown | Dependency graph: package, module, component, and file-level deps |

## Gates

### INPUT Gate
- Filesystem is readable
- Source code is parseable
- Package manifests exist

### EXECUTION Gate
- Architecture artefacts from previous cycle are available for diff
- Repository is in a known state

### OUTPUT Gate
- Every component in code is mapped
- Every dependency is documented
- Every execution path is traced
- No orphan components (present in code, absent in map)
- Architecture map is internally consistent

## Quality Criteria

1. **Completeness**: 100% of runtime components mapped
2. **Consistency**: No contradictions between map and code
3. **Freshness**: Map reflects current repository state
4. **Traceability**: Every map entry links to source location

## Templates

See `templates/` directory for output artefact templates.

## Automation

See `gates/` directory for gate validation scripts.
