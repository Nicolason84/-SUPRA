# FACTORY_10_EXECUTIVE — Specification V1

## Mission

Govern the entire Factory.

## Responsibility

Observe all factories continuously. Monitor progress, velocity, confidence, health, risk, and debt. Produce ONE unique Executive Decision per observation cycle.

## Owner

SUPRA-Architect / Executive

## Inputs

| Input | Source | Format |
|-------|--------|--------|
| All factory outputs | All FACTORIES | Various |
| Architecture health | FACTORY_01 | Architecture metrics |
| Knowledge health | FACTORY_04 | Knowledge metrics |
| Runtime health | FACTORY_03 | Runtime metrics |
| Quality report | FACTORY_07 | QUALITY_REPORT.md |
| Proof report | FACTORY_06 | PROOF_REPORT.md |
| Memory state | FACTORY_05 | MEMORY_STATE.md |
| Execution plan | FACTORY_09 | EXECUTION_PLAN.md |
| Factory queue | FACTORY_09 | FACTORY_QUEUE.md |

## Outputs

| Output | Format | Description |
|--------|--------|-------------|
| EXECUTIVE_REPORT.md | Markdown | Comprehensive executive report with all metrics |
| NEXT_DECISION.md | Markdown | Single executive decision for next cycle |

## Gates

### INPUT Gate
- All factory outputs are certified
- Health metrics are computed
- Previous executive decision is archived

### EXECUTION Gate
- Observation window is defined
- Decision model is loaded

### OUTPUT Gate
- EXECUTIVE_REPORT covers all health dimensions
- NEXT_DECISION contains exactly ONE decision
- Decision is actionable and specific
- Decision is traceable to evidence
- Decision has a clear owner

## Health Dimensions

| Dimension | Source | Description |
|-----------|--------|-------------|
| Progress | FACTORY_09 | Are factories delivering on schedule? |
| Velocity | FACTORY_09 | Is throughput improving? |
| Confidence | FACTORY_06 | Are artefacts trustworthy? |
| Runtime Health | FACTORY_03 | Does the system compile and run? |
| Knowledge Health | FACTORY_04 | Is the knowledge graph coherent? |
| Architecture Health | FACTORY_01 | Is the architecture consistent? |
| Risk | All | What are the top risks? |
| Technical Debt | FACTORY_07 | What needs refactoring? |

## Decision Types

| Type | Description | Example |
|------|-------------|---------|
| CONTINUE | Keep executing current plan | "Continue FACTORY_03 build cycle" |
| ADAPT | Adjust current execution | "Shift priority to FACTORY_02" |
| REPLAN | Replan execution sequence | "Re-order FACTORY queue for critical fix" |
| ESCALATE | Escalate to human | "Architecture inconsistency requires human decision" |
| HALT | Stop all execution | "Halt: critical runtime failure detected" |

## Templates

See `templates/` directory for output artefact templates.

## Automation

See `gates/` directory for gate validation scripts.
