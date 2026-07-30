# CANONICO Pattern Library

## Status: SPECIFICATION V1

---

## 1. PATTERN MODEL

A Pattern is a reusable behavioral template that determines how a Node interacts with the Graph. Patterns are the behavioral atoms of the CANONICO system.

### 1.1 Pattern Structure

```
Pattern {
  id: Identity
  name: String
  description: String
  archetype: Archetype              [parent archetype]
  nodeTypes: [NodeType]             [applicable to these types]

  capabilities: [Capability]        [what the node can do]
  behaviors: [Behavior]             [how it behaves]
  constraints: [Constraint]         [limits and rules]
  interactions: [Interaction]       [allowed edge types]

  dimensions: DimensionProfile      [default dimension ranges]
  lifecycle: LifecycleDefinition    [allowed state transitions]

  metadata: Map
  version: String
}
```

### 1.2 Pattern Resolution

A Node resolves its effective behavior through:
```
Node → references Pattern → includes Behavior definitions
     → behavior is executed by Behavior Engine
```

---

## 2. SYSTEM PATTERNS

### 2.1 OperatingSystem
| Property | Value |
|----------|-------|
| Archetype | SYSTEM |
| NodeTypes | computer, device |
| Capabilities | process_management, file_system, networking, security |
| Interactions | RUNS, CONTAINS, EXECUTES, CONFIGURES |
| Lifecycle | CONCEPT → CREATED → ACTIVE → SUSPENDED → ARCHIVED |

### 2.2 Application
| Property | Value |
|----------|-------|
| Archetype | SYSTEM |
| NodeTypes | application, service, daemon |
| Capabilities | serve_requests, process_data, manage_state |
| Interactions | DEPENDS_ON, USES, IMPLEMENTS, GENERATES |
| Lifecycle | CONCEPT → CREATED → ACTIVE → ARCHIVED |

### 2.3 Workspace
| Property | Value |
|----------|-------|
| Archetype | SYSTEM |
| NodeTypes | workspace |
| Capabilities | contain_projects, track_changes, manage_config |
| Interactions | CONTAINS, BELONGS_TO, CONFIGURES |
| Dimensions | ownership: 0.5–1.0, dependency: 0.0–0.5 |

### 2.4 DataStore
| Property | Value |
|----------|-------|
| Archetype | SYSTEM |
| NodeTypes | database, storage, cache |
| Capabilities | store, retrieve, query, index |
| Interactions | STORES, PROVIDES_DATA_TO, REPLICATES |

### 2.5 Network
| Property | Value |
|----------|-------|
| Archetype | SYSTEM |
| NodeTypes | network, domain, cluster |
| Capabilities | route, connect, secure |
| Interactions | CONNECTS, ROUTES_TO, GATEWAY_TO |

---

## 3. AGENT PATTERNS

### 3.1 AIAgent
| Property | Value |
|----------|-------|
| Archetype | AGENT |
| NodeTypes | agent |
| Capabilities | perceive, decide, act, learn, remember |
| Interactions | OBSERVES, DECIDES, EXECUTES, REMEMBERS, LEARNS |
| Dimensions | trust: 0.3–1.0, energy: 0.0–1.0 |

### 3.2 Worker
| Property | Value |
|----------|-------|
| Archetype | AGENT |
| NodeTypes | worker, executor |
| Capabilities | execute_task, report_status, handle_failure |
| Interactions | EXECUTES, GENERATES, REPORTS_TO, DEPENDS_ON |
| Lifecycle | CREATED → ACTIVE → SUSPENDED → ARCHIVED |

### 3.3 Observer
| Property | Value |
|----------|-------|
| Archetype | AGENT |
| NodeTypes | observer, monitor, watcher |
| Capabilities | observe, detect_change, report, alert |
| Interactions | OBSERVES, MONITORS, TRACKS, REPORTS_TO |

### 3.4 Scheduler
| Property | Value |
|----------|-------|
| Archetype | AGENT |
| NodeTypes | scheduler, orchestrator |
| Capabilities | schedule, dispatch, prioritize, throttle |
| Interactions | SCHEDULES, INVOKES, MONITORS, PAUSES |

---

## 4. RESOURCE PATTERNS

### 4.1 ComputeUnit
| Property | Value |
|----------|-------|
| Archetype | RESOURCE |
| NodeTypes | cpu, gpu, accelerator |
| Capabilities | compute, process |
| Dimensions | energy: 0.0–1.0, execution: 0.0–1.0 |

### 4.2 StorageUnit
| Property | Value |
|----------|-------|
| Archetype | RESOURCE |
| NodeTypes | disk, volume, partition, memory |
| Capabilities | store, read, write, cache |
| Dimensions | ownership: 0.0–1.0, importance: 0.0–1.0 |

### 4.3 Module
| Property | Value |
|----------|-------|
| Archetype | RESOURCE |
| NodeTypes | module, package, framework |
| Capabilities | export, import, compile |
| Interactions | IMPORTS, EXPORTS_TO, DEPENDS_ON, CONTAINS |
| Dimensions | dependency: 0.3–1.0 |

### 4.4 File
| Property | Value |
|----------|-------|
| Archetype | RESOURCE |
| NodeTypes | file, document, source |
| Capabilities | be_read, be_written, be_executed |
| Interactions | BELONGS_TO, IMPORTS, GENERATES |
| Lifecycle | CREATED → ACTIVE → ARCHIVED |

---

## 5. MEMORY PATTERNS

### 5.1 KnowledgeGraph
| Property | Value |
|----------|-------|
| Archetype | MEMORY |
| NodeTypes | knowledge, memory |
| Capabilities | store_knowledge, query, infer, relate |
| Interactions | REMEMBERS, RELATES_TO, DERIVES, PROVES |

### 5.2 ConversationLog
| Property | Value |
|----------|-------|
| Archetype | MEMORY |
| NodeTypes | conversation, message, prompt |
| Capabilities | record, search, summarize |
| Interactions | CONTAINS, REFERENCES, PRECEDES |

### 5.3 DecisionLog
| Property | Value |
|----------|-------|
| Archetype | MEMORY |
| NodeTypes | decision, evaluation |
| Capabilities | record_decision, evaluate, trace |
| Interactions | DECIDES, PROVES, BASED_ON, SUPERSEDES |

### 5.4 EvidenceChain
| Property | Value |
|----------|-------|
| Archetype | MEMORY |
| NodeTypes | evidence, proof |
| Capabilities | attest, verify, chain |
| Interactions | PROVES, ATTESTED_BY, CHAINED_TO, VALIDATES |

---

## 6. PROCESS PATTERNS

### 6.1 Mission
| Property | Value |
|----------|-------|
| Archetype | PROCESS |
| NodeTypes | mission, task, job |
| Capabilities | execute, rollback, report |
| Interactions | EXECUTES, GENERATES, DEPENDS_ON, PRECEDES |
| Lifecycle | CONCEPT → CREATED → ACTIVE → COMPLETED → ARCHIVED |

### 6.2 Pipeline
| Property | Value |
|----------|-------|
| Archetype | PROCESS |
| NodeTypes | pipeline, workflow, chain |
| Capabilities | sequence, transform, validate |
| Interactions | PRECEDES, GENERATES, VALIDATES, GATES |

### 6.3 Build
| Property | Value |
|----------|-------|
| Archetype | PROCESS |
| NodeTypes | build, compilation |
| Capabilities | compile, link, test, package |
| Interactions | COMPILES, GENERATES, DEPENDS_ON, VALIDATES |

---

## 7. CONCEPT PATTERNS

### 7.1 Standard
| Property | Value |
|----------|-------|
| Archetype | CONCEPT |
| NodeTypes | standard, specification |
| Capabilities | define, constrain, validate |
| Interactions | DEFINES, CONSTRAINS, VALIDATES, REFERENCES |

### 7.2 Product
| Property | Value |
|----------|-------|
| Archetype | CONCEPT |
| NodeTypes | product, offering |
| Capabilities | be_used, generate_value |
| Interactions | PRODUCES, CONSUMES, GENERATES_VALUE |

---

## 8. PATTERN COMPOSITION

Patterns can be composed to create compound behavior:

```
Node {
  pattern: [DataStore, Service]
  → inherits store/retrieve/query from DataStore
  → inherits serve_requests from Service
}
```

Composition rules:
- Conflicting capabilities are resolved by priority (last wins)
- All constraints from all patterns apply
- All interactions from all patterns are allowed

---

## 9. CUSTOM PATTERNS

New Patterns can be registered by providing:
1. Unique name and description
2. Reference to an existing Archetype
3. Capability list
4. Interaction list (allowed EdgeTypes)
5. Dimension profile
6. Lifecycle definition

Registration creates a new Pattern Node in the Graph.

---

**CANONICO_PATTERN_LIBRARY.md — V1**
