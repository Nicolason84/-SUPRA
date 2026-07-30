# FACTORY_04_KNOWLEDGE — Specification V1

## Mission

Maintain executable knowledge.

## Responsibility

Build and maintain the canonical knowledge model of the SUPRA system. Extract concepts, relations, and evidence from all sources. Keep the knowledge graph coherent and up to date.

## Owner

SUPRA-Research / SUPRA-Explorer

## Inputs

| Input | Source | Format |
|-------|--------|--------|
| All documentation | Repository | *.md |
| Architecture map | FACTORY_01 | ARCHITECTURE_MAP.md |
| Discovery report | FACTORY_02 | DISCOVERY_REPORT.md |
| Source code | Swift files | Source text |
| Relations data | Known | JSON |

## Outputs

| Output | Format | Description |
|--------|--------|-------------|
| CANONICAL_MODEL.json | JSON | Canonical entity model with definitions and properties |
| KNOWLEDGE_GRAPH.json | JSON | Complete knowledge graph: concepts, entities, relations |
| RELATION_GRAPH.json | JSON | Relation-only subgraph with types and cardinalities |
| EVIDENCE_GRAPH.json | JSON | Evidence chains linking claims to proofs |

## Gates

### INPUT Gate
- FACTORY_01 and FACTORY_02 outputs are certified
- Source documents are accessible

### EXECUTION Gate
- Previous knowledge graph available for diff
- Ontology is defined

### OUTPUT Gate
- Every concept has a canonical definition
- Every relation is typed
- Every evidence chain is unbroken
- Knowledge graph is internally consistent

## Quality Criteria

1. **Completeness**: All source documents mapped to concepts
2. **Coherence**: No contradictory concepts
3. **Traceability**: Every concept links to source document
4. **Freshness**: Graph reflects current documentation state

## Templates

See `templates/` directory for output artefact templates.

## Automation

See `gates/` directory for gate validation scripts.
