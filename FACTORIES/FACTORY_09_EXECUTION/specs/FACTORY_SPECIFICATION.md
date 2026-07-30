# FACTORY_09_EXECUTION — Specification V1

## Mission

Schedule production.

## Responsibility

Plan and schedule factory operations. Maintain the execution DAG. Manage the factory queue. Optimize throughput by parallelizing independent factory operations.

## Owner

SUPRA-Router

## Inputs

| Input | Source | Format |
|-------|--------|--------|
| Factory specifications | All FACTORIES | FACTORY_SPECIFICATION.md |
| Executive decision | FACTORY_10 | NEXT_DECISION.md |
| Factory queue | .opencode | mission_queue.json |
| Factory states | FACTORIES | Current status |
| Dependency graph | FACTORY_01 | DEPENDENCY_GRAPH.md |

## Outputs

| Output | Format | Description |
|--------|--------|-------------|
| EXECUTION_PLAN.md | Markdown | Complete execution plan for current cycle |
| EXECUTION_DAG.md | Markdown | Directed acyclic graph of factory execution order |
| FACTORY_QUEUE.md | Markdown | Current factory queue with priorities and dependencies |

## Gates

### INPUT Gate
- FACTORY_10 executive decision is available
- Executive decision is certified by FACTORY_06
- All factory states are known

### EXECUTION Gate
- Execution plan is validated against dependency graph
- Resource constraints are accounted for

### OUTPUT Gate
- Execution plan covers all pending work
- Execution DAG has no cycles
- Factory queue is ordered by dependency
- Plan is feasible within resource constraints

## Scheduling Rules

1. Respect factory dependencies (architecture before runtime)
2. Maximize parallelism (independent factories run concurrently)
3. Respect resource constraints (one writer at a time)
4. Priority is determined by: criticality × urgency × dependency count
5. No factory starts before its inputs are certified

## Templates

See `templates/` directory for output artefact templates.

## Automation

See `gates/` directory for gate validation scripts.
