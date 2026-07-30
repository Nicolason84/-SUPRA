# SUPRA ZERO — Industrial Base

## Target Structure: `INDUSTRIAL_BASE/`

```
INDUSTRIAL_BASE/
├── Standards/          # Coding standards, naming conventions, architecture principles
├── Conventions/        # Git conventions, review process, release process
├── Registries/         # Agent registry, model registry, plugin registry
├── Contracts/          # Provider contracts, plugin contracts, service contracts
├── Schemas/            # JSON schemas, manifest schemas, data models
├── Templates/          # Component templates, workflow templates, mission templates
├── Agents/             # Agent definitions, capabilities, routing rules
├── Plugins/            # Plugin interfaces, extension points
├── Policies/           # Security policies, governance policies, routing policies
├── Rules/              # Validation rules, linting rules, business rules
├── Guides/             # Developer guides, operator guides, integration guides
├── SDK/                # Provider SDK, plugin SDK, twin SDK
└── Documentation/      # Reference docs, API docs, architecture docs
```

## Existing Elements by Category

### Standards
| Element | Exists? | Location | Reusable? |
|---------|---------|----------|-----------|
| Swift coding conventions | Yes | Implicit in codebase | Yes — extract from code |
| Architecture principles | Yes | `SUPRA_AI_LAB_ARCHITECTURE_V1.md` | Yes |
| Executive Object Model | Yes | `EXECUTIVE_OBJECT_MODEL.md` | Yes |
| Naming conventions | Partial | Implicit | Needs formalization |

### Conventions
| Element | Exists? | Location |
|---------|---------|----------|
| Git hygiene plan | Yes | `GIT_CLEANUP_PLAN.md` |
| Workflow standard | Yes | `SUPRA_WORKFLOW_V1.md` |
| Continuity standard | Yes | `CAnnoNico_CONTINUITY_STANDARD.md` |
| Dev guide | Yes | `CAnnoNico_DEVELOPMENT_GUIDE.md` |
| Workflow standard (CAnnoNico) | Yes | `CAnnoNico_WORKFLOW_STANDARD.md` |

### Registries
| Element | Exists? | Location | Status |
|---------|---------|----------|--------|
| Agent Registry | Yes | `SUPRA_AGENT_REGISTRY_V1.md` + `AGENTS.md` | ACTIVE |
| Model Registry | Yes | `SUPRA_MODEL_REGISTRY_V1.md` | ACTIVE |
| Router Spec | Yes | `SUPRA_ROUTER_SPECIFICATION_V1.md` | ACTIVE |
| Plugin Registry | No | — | NEEDS CREATION |
| Provider Registry | Partial | `.opencode/runtime/provider_registry.json` | PARTIAL |

### Contracts
| Element | Exists? | Location |
|---------|---------|----------|
| Provider Protocols | Yes | `SUPRA/SUPRAProviderProtocols.swift` |
| Provider Contracts | No | — |
| Plugin Contracts | No | — |
| Service Contracts | Partial | `SUPRA_RUNTIME_CONTRACTS.json` |
| Transmission Contract | Yes | `SUPRA/SUPRATransmissionContract.swift` |

### Schemas
| Element | Exists? | Location |
|---------|---------|----------|
| Manifest Schema | Implicit | WORKSPACE_MANIFEST.json structure |
| State Schema | Implicit | SUPRA_STATE.json structure |
| Runtime Schema | Implicit | RUNTIME_STATUS.json structure |
| Decision Schema | Yes | `SUPRA_REQUEST_SCHEMA.json` |
| UDCL Spec | Yes | `UDCL_SPECIFICATION.md` |

### Templates
| Element | Exists? | Location |
|---------|---------|----------|
| Mission Templates | Implicit | Mission.swift model |
| Workflow Templates | Implicit | Executive workflow patterns |
| Session Report | Yes | SESSION_CONTINUITY_REPORT.md pattern |
| Snapshot Template | Yes | SESSION_SNAPSHOT_*.json pattern |

### Agents
| Element | Exists? | Location |
|---------|---------|----------|
| Agent Definitions | Yes | `AGENTS.md` |
| Agent Permissions | Yes | `.opencode/agent_permissions.json` |
| Agent Registry (Runtime) | Yes | `.opencode/agent_registry_runtime.json` |
| Delegation Rules | Yes | `.opencode/delegation_rules.json` |

### Policies
| Element | Exists? | Location |
|---------|---------|----------|
| Routing Policy | Yes | `.opencode/runtime/routing_policy.json` |
| Governance | Yes | `Governance/` directory |
| Security | Implicit | macOS permission architecture |
| Validation Protocol | Yes | `VALIDATION_PROTOCOL.md` |

### Rules
| Element | Exists? | Location |
|---------|---------|----------|
| Routing Rules | Yes | `.opencode/runtime/routing_rules.json` |
| Validation Rules | Implicit | Various audit matrices |
| Business Rules | Partial | Workflow implementations |

### Guides
| Element | Exists? | Location |
|---------|---------|----------|
| Install Guide | Yes | `GO_SUPRA_INSTALL.sh`, `GO_SUPRA_INSTALL_AUDIT.md` |
| Bootstrap Guide | Yes | `SUPRA_BOOTSTRAP_V3.sh` |
| Runtime Guide | Yes | `SUPRA_RUNTIME.sh` |
| Node Guide | Yes | `SUPRA_NODE_STATUS.sh` |

### SDK
| Element | Exists? | Location | Status |
|---------|---------|----------|--------|
| Provider SDK | Implicit | Provider protocols | NEEDS FORMALIZATION |
| Plugin SDK | No | — | NEEDS CREATION |
| Twin SDK | Implicit | Twin protocols | PARTIAL |

## Reuse Assessment

**Already available (85% of Industrial Base exists in some form):**
- Standards: 80% exists, needs extraction
- Conventions: 100% exists
- Registries: 60% exists
- Contracts: 40% exists (protocols yes, formal contracts no)
- Schemas: 70% exists (implicit in JSON structures)
- Templates: 50% exists (patterns established)
- Agents: 100% exists
- Policies: 70% exists
- Rules: 60% exists
- Guides: 80% exists
- SDK: 20% exists
- Documentation: 80% exists

**Gaps requiring creation:**
1. Plugin Registry (formal registry for plugins)
2. Plugin Contracts (interface definitions)
3. Provider Contracts (formal service contracts)
4. Plugin SDK (if plugins are external)
5. Formal JSON schemas for manifests/state/runtime
6. Coding standards document (extract from existing code)
7. Formal reference architecture document

## Migration Plan

1. **Extract** existing patterns into formal documents (no new content)
2. **Reference** existing files instead of duplicating them
3. **Create** only genuinely missing elements (plugin-related)
4. **Link** all documents from a single `INDUSTRIAL_BASE/INDEX.md`
5. **Keep** all originals in place — INDUSTRIAL_BASE is a logical view, not a physical move
