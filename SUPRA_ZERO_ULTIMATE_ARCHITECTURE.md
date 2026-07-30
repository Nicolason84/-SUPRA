# SUPRA ZERO — Ultimate Architecture

## Target: SUPRA ULTIMATE

The definitive architecture that should become the sole reference for all future development.

```
SUPRA ULTIMATE
│
├── Executive Kernel        ← Orchestration, lifecycle, governance
├── Theory                  ← Knowledge, concepts, principles
├── Sherpa                  ← Context, routing, recommendations
├── Cortex                  ← Memory, decisions, evidence, learning
├── Runtime                 ← Execution, missions, workflows
├── Workspace               ← Index, discovery, twins, resources
├── Products                ← Business, monetization, value maps
├── Providers               ← AI engines, models, fallback
├── Plugins                 ← Extensions, contracts, registry
└── Industrial Base         ← Standards, conventions, schemas, SDK
```

## Current State vs Target

### Executive Kernel
| Target Component | Exists? | Location | Status |
|-----------------|---------|----------|--------|
| Composition Root | Yes | `SUPRACompositionRoot.swift` | ACTIVE |
| Executive Core | Yes | `SUPRAOperationalCoreApp.swift` | ACTIVE |
| Executive Dashboard | Yes | Multiple dashboard views | ACTIVE |
| Governance | Partial | `Governance/` directory | PARTIAL |
| Decision Engine | Yes | `SUPRADecisionEngine.swift` | ACTIVE |
| Policy Engine | Partial | `SUPRADecisionAuthority.swift` | PARTIAL |
| Lifecycle Manager | Partial | `ExecutiveBootManager.swift` | PARTIAL |

### Theory (NEW — needs creation)
| Target Component | Exists? | Priority |
|-----------------|---------|----------|
| Theory Ontology | No | CRITICAL |
| Theory Library | No | CRITICAL |
| Theory Graph | No | HIGH |
| Theory Search | No | HIGH |

### Sherpa (NEW — needs creation)
| Target Component | Exists? | Priority |
|-----------------|---------|----------|
| Context Selection | No | CRITICAL |
| Provider Recommendations | No | HIGH |
| Navigation Engine | No | HIGH |

### Cortex (NEW — needs creation)
| Target Component | Exists? | Priority |
|-----------------|---------|----------|
| Decision Memory | Partial | HIGH |
| Evidence Storage | Partial | HIGH |
| Learning Engine | Partial | HIGH |
| Experience Replay | No | MEDIUM |

### Runtime
| Target Component | Exists? | Location | Status |
|-----------------|---------|----------|--------|
| Mission Executor | Yes | `SUPRAMissionExecutor.swift` | PARTIAL (no LLM call) |
| Workflow Engine | Yes | Executive workflow views | ACTIVE |
| Runtime Monitor | Yes | `RuntimeMonitor.swift` | ACTIVE |
| Runtime Diagnostics | Yes | `RuntimeDiagnosticsView.swift` | ACTIVE |
| Transmission | Yes | `SUPRATransmission*.swift` | ACTIVE |
| Scheduler | Yes | `SUPRAScheduler.swift` | ACTIVE |
| Resource Governor | Yes | `SUPRAResourceGovernor.swift` | ACTIVE |

### Workspace
| Target Component | Exists? | Location | Status |
|-----------------|---------|----------|--------|
| Workspace Index | Yes | `WorkspaceIndexer.swift` | ACTIVE |
| Twin System | Yes | `Twin*.swift` | ACTIVE |
| Universe Engine | Yes | `Universe*.swift` | ACTIVE |
| Knowledge Graph | Yes | `KnowledgeGraph.swift` | ACTIVE |
| Object Model | Yes | `WorkspaceModels.swift` | ACTIVE |
| Memory | Yes | `WorkspaceMemory.swift` | ACTIVE |

### Products
| Target Component | Exists? | Location | Status |
|-----------------|---------|----------|--------|
| Monetization Engine | Yes | `SUPRAMonetizationEngine.swift` | ACTIVE |
| Business Engine | Yes | `SUPRABusinessPlatform.swift` | ACTIVE |
| Value Maps | Partial | Historical in SUPRA_PROJECTS | ARCHIVE |
| Product Registry | Partial | `SUPRA_PRODUCT` | ARCHIVE |

### Providers
| Target Component | Exists? | Location | Status |
|-----------------|---------|----------|--------|
| Provider Protocols | Yes | `SUPRAProviderProtocols.swift` | ACTIVE |
| Provider Broker | Yes | `SUPRAProviderBroker.swift` | ACTIVE |
| Ollama Provider | Yes | `SUPRAOllamaProvider.swift` | ACTIVE |
| Fallback Provider | Yes | `SUPRAFallbackEngine.swift` | ACTIVE |
| Provider Registry | Yes | `SUPRAProviderRegistry.swift` | ACTIVE |
| Plugin Provider | Partial | `SUPRAPluginRegistry.swift` | PARTIAL |

### Plugins
| Target Component | Exists? | Priority |
|-----------------|---------|----------|
| Plugin Registry | Partial | MEDIUM |
| Plugin Contracts | No | MEDIUM |
| Plugin Loader | No | LOW |
| Plugin SDK | No | LOW |

### Industrial Base
| Target Component | Exists? | Priority |
|-----------------|---------|----------|
| Standards | Implicit | HIGH |
| Conventions | Yes | LOW |
| Schemas | Implicit | MEDIUM |
| Templates | Implicit | MEDIUM |
| SDK | No | MEDIUM |

## What Exists (Complete)

1. Executive Kernel — 80% complete
2. Runtime — 85% complete (mission execution needs LLM connection)
3. Workspace — 90% complete
4. Providers — 75% complete (framework exists, actual calls pending)
5. Products — 40% complete (engine exists, no active products)
6. Industrial Base — 60% exists implicitly

## What Is Missing

1. **Theory** — 0% (must be built from scratch)
2. **Sherpa** — 0% (must be built from scratch)
3. **Cortex** — 20% (partial decision memory, needs formalization)
4. **Plugins** — 20% (registry exists, no contracts or loader)

## What Must Be Merged

| From | Into SUPRA ULTIMATE | Action |
|------|---------------------|--------|
| SUPRA_EXECUTIVE_RUNTIME_V1 | Runtime | Merge frozen evidence |
| NOVA_ERA_SUPRA | Archives | Keep as reference |
| NOVA_CORE | Workspace | Reference only |
| NOVA_BUILD_SYSTEM | Industrial Base | Reference CI patterns |
| PLATFORM_CORE | Industrial Base | Use as template |

## What Must Remain Independent

| Element | Reason |
|---------|--------|
| SUPRA_BISECT | Parallel activity for regression hunting |
| SUPRA_DEEPSEEK_EXIT_READINESS | Parallel migration testing |
| SUPRA_RELEASE (legal) | Separate domain (legal documents) |
| `~/NOVA_OS/` historical dirs | Non-destructive preservation |
| SUPRA Video Swap | Separate product experiment |
| SUPRA Helene (iOS/Android) | Separate platform |

## Architecture Layering

```
LAYER 0: INDUSTRIAL BASE
  Standards, conventions, registries, schemas, templates, SDK

LAYER 1: PROVIDERS + PLUGINS
  AI engines, model access, extensions, contracts

LAYER 2: THEORY + KNOWLEDGE
  Ontology, theories, concepts, principles, theory graph

LAYER 3: SHERPA + CORTEX
  Context selection, memory, decisions, evidence, learning

LAYER 4: RUNTIME + WORKSPACE
  Execution, missions, workflows, twins, resources

LAYER 5: EXECUTIVE KERNEL + PRODUCTS
  Orchestration, governance, business, monetization

LAYER 6: PRESENTATION
  Views, dashboards, control centers, product surfaces
```

## Migration Path to SUPRA ULTIMATE

1. **SUPRA ZERO** (current) — Map everything, no changes
2. **Theory Engine** — Build ontology, theory library, theory graph
3. **Sherpa V1** — Context selection engine
4. **Cortex V1** — Persistent memory with decisions + evidence
5. **Plugin System** — Contracts, registry, loader
6. **Runtime Activation** — Connect providers → actual LLM calls
7. **Executive Kernel Consolidation** — Merge all into single composition root
8. **SUPRA ULTIMATE V1** — First unified release
