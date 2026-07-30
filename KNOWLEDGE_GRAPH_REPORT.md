# KNOWLEDGE GRAPH REPORT — V1

## Status: CERTIFIED

| Property | Value |
|----------|-------|
| **Version** | KNOWLEDGE_GRAPH_V1 |
| **Date** | 2026-07-29 |
| **Authority** | FACTORY_04_KNOWLEDGE |

---

## 1. KNOWLEDGE GRAPH OVERVIEW

This report maps all SUPRA component relationships into a living knowledge graph.

### Node Categories

| Category | Count | Description |
|----------|-------|-------------|
| Factories | 10 | FACTORY_01 through FACTORY_10 |
| Agents | 9 | SUPRA-Architect through SUPRA-Router |
| Commands | 13 | supra-* CLI commands |
| Registries | 5 | Factory, Agent, Model, Capability, Workflow |
| Workflows | 1 | Standard pipeline (8 stages) |
| Scripts | 20+ | Shell scripts in FACTORIES/ and root |
| Swift Modules | 226 | Source files in SUPRA/ |
| Documents | 300+ | MD files across repository |

---

## 2. GRAPH: FACTORIES → AGENTS

```
FACTORY_01_ARCHITECTURE ─── owns ─── SUPRA-Architect
FACTORY_02_DISCOVERY   ─── owns ─── SUPRA-Explorer
FACTORY_03_RUNTIME     ─── owns ─── SUPRA-Runtime / SUPRA-Builder
FACTORY_04_KNOWLEDGE   ─── owns ─── SUPRA-Research / SUPRA-Explorer
FACTORY_05_MEMORY      ─── owns ─── SUPRA-Auditor / SUPRA-Builder
FACTORY_06_PROOF       ─── owns ─── SUPRA-Auditor
FACTORY_07_QUALITY     ─── owns ─── SUPRA-Reviewer / SUPRA-Auditor
FACTORY_08_DOCUMENTATION ── owns ─── SUPRA-Builder
FACTORY_09_EXECUTION   ─── owns ─── SUPRA-Router
FACTORY_10_EXECUTIVE   ─── owns ─── SUPRA-Architect / Executive
```

**Relations**: Each factory has ONE primary agent owner. FACTORY_03, FACTORY_04, FACTORY_05, FACTORY_07, FACTORY_10 have secondary owners.

---

## 3. GRAPH: AGENTS → COMMANDS

```
SUPRA-Architect  ─── executes ─── supra-architect, supra-executive
SUPRA-Builder    ─── executes ─── supra-build, supra-docs
SUPRA-Auditor    ─── executes ─── supra-memory, supra-proof, supra-audit
SUPRA-Reviewer   ─── executes ─── supra-quality, supra-review
SUPRA-Explorer   ─── executes ─── supra-discover
SUPRA-Research   ─── executes ─── supra-knowledge
SUPRA-Runtime    ─── executes ─── (runtime validation)
SUPRA-Refactor   ─── executes ─── (refactoring analysis)
SUPRA-Router     ─── executes ─── supra-factory-status, supra-factory-execute
```

**Relations**: 13 commands mapped to 9 agents. Each agent owns at least 1 command.

---

## 4. GRAPH: FACTORIES → REGISTRIES

```
FACTORY_01_ARCHITECTURE ─── produces ─── ARCHITECTURE_MAP.md, DEPENDENCY_GRAPH.md, EXECUTION_GRAPH.md, SYSTEM_TOPOLOGY.md
FACTORY_02_DISCOVERY   ─── produces ─── DISCOVERY_REPORT.md, DUPLICATE_REPORT.md, MODULE_INDEX.md
FACTORY_03_RUNTIME     ─── produces ─── BUILD_REPORT.md, PATCH_REPORT.md, VALIDATION_REPORT.md
FACTORY_04_KNOWLEDGE   ─── produces ─── CANONICAL_MODEL.json (knowledge graph entry point)
FACTORY_05_MEMORY      ─── produces ─── MEMORY_STATE.json
FACTORY_06_PROOF       ─── produces ─── CERTIFICATION_REPORT.md
FACTORY_07_QUALITY     ─── produces ─── QUALITY_REPORT.md
FACTORY_08_DOCUMENTATION ── produces ─── EXECUTIVE_BOOT.md, BOOT_SEQUENCE.md, EXECUTIVE_DASHBOARD.md, WORKSPACE_SELECTOR.md, CERTIFIED_ENTRYPOINT.md
FACTORY_09_EXECUTION   ─── produces ─── EXECUTION_PLAN.md, EXECUTION_DAG.md, FACTORY_QUEUE.md
FACTORY_10_EXECUTIVE   ─── produces ─── EXECUTIVE_REPORT.md, NEXT_DECISION.md
```

**Relations**: 26 certified outputs across 10 factories. All registered in FACTORY_REGISTRY.json.

---

## 5. GRAPH: REGISTRIES → WORKFLOWS

```
FACTORY_REGISTRY.json ─── feeds ─── Executive Dashboard
AGENT_REGISTRY_V1.md  ─── feeds ─── Delegation Rules → SUPRA-Router
MODEL_REGISTRY_V1.md  ─── feeds ─── Model Selection → SUPRA-Router
DELEGATION_RULES.json ─── feeds ─── WorkflowEngine → Agent Assignment
SUPRA_WORKFLOW_V1.md  ─── defines ─── Pipeline: Planner → Router → WorkflowEngine → Comparator → Fusion → Validator → Learning → Memory
```

---

## 6. GRAPH: SCRIPTS → FACTORIES

```
FACTORIES/EXECUTIVE_BOOT.sh     ─── triggers ─── All 10 factories (boot sequence)
FACTORIES/supra-factory.sh      ─── manages ─── Individual factory lifecycle
FACTORIES/supra-pipeline.sh     ─── orchestrates ─── Factory pipeline (validate)
GO_SUPRA_GLOBAL_AUDIT.sh        ─── audits ─── All Swift sources
GO_SUPRA_BUILD_MATRIX.sh        ─── builds ─── FACTORY_03_RUNTIME
SUPRA_BOOTSTRAP_V3.sh           ─── deploys ─── Multiple factories
SUPRA_RUNTIME.sh                ─── manages ─── FACTORY_03_RUNTIME
SUPRA_ROLLBACK_PHASE2.sh        ─── rollback ─── FACTORY_10_EXECUTIVE
SUPRA_INSTALLER_V2.sh           ─── installs ─── Entire SUPRA platform
```

**Relations**: 20+ scripts mapped to factory operations. EXECUTIVE_BOOT.sh is the single entry point.

---

## 7. GRAPH: SWIFT MODULES → FACTORIES

Key Swift modules mapped to their factory domain:

| Swift Module | Factory | Purpose |
|-------------|---------|---------|
| ExecutiveBootManager.swift | FACTORY_10 | Boot sequence execution |
| ExecutiveMissionControlView.swift | FACTORY_10 | Mission control UI |
| ExecutiveCockpitFoundation.swift | FACTORY_10 | Cockpit data model |
| ExecutiveDemoMode.swift | FACTORY_10 | Demo mode |
| DashboardView.swift | FACTORY_08 | Dashboard rendering |
| Decision*.swift | FACTORY_10 | Decision engine |
| Mission*.swift | FACTORY_10 | Mission lifecycle |
| MissionCenterView.swift | FACTORY_09 | Mission center UI |
| ContextEngine.swift | FACTORY_04 | Knowledge context |
| CommandCenterView.swift | FACTORY_09 | Command center UI |
| ControlCenterStore.swift | FACTORY_09 | Control center state |
| ControlTowerState.swift | FACTORY_09 | Tower state management |
| ConversationMemoryStore.swift | FACTORY_05 | Memory storage |
| ConversationKnowledgeProvider.swift | FACTORY_04 | Knowledge provider |
| EvidenceExplorerView.swift | FACTORY_06 | Evidence UI |
| ContinuityManager.swift | FACTORY_05 | Session continuity |
| ContentView.swift | FACTORY_08 | Main app view |
| SUPRAApp.swift | FACTORY_03 | App entry point |

**Total Swift modules mapped**: 226 files in SUPRA/, 11 in SUPRA_AST_PLATFORM/

---

## 8. GRAPH: DOCUMENTS → SYSTEM

### Executive Documents
```
AGENTS.md                  ─── defines ─── Factory Operating Contract
EXECUTIVE_BOOT_REPORT.md   ─── certifies ─── Boot sequence
EXECUTIVE_DASHBOARD.md     ─── reports ─── Current state
EXECUTIVE_STATE.json       ─── snapshots ─── Machine-readable state
HEALTH_REPORT.md           ─── monitors ─── 13 subsystem health scores
EXECUTIVE_REGISTRY_REPORT.md ── audits ─── All registries
VALIDATION_PIPELINE.md     ─── automates ─── 7-phase validation
EXECUTION_TIMELINE.md      ─── traces ─── 32 mission history
NEXT_MISSION.md            ─── decides ─── Next gate mission
```

### Operational Documents
```
BUILD_CERTIFICATION.md     ─── certifies ─── Build
FACTORY_CERTIFICATION.md   ─── certifies ─── All factory outputs
FACTORIES/SUPRA_FACTORY_CONSTITUTION.md ─── governs ─── Factory operations
SUPRA_ROUTER_SPECIFICATION_V1.md ─── specifies ─── Router behavior
SUPRA_WORKFLOW_V1.md       ─── specifies ─── Full pipeline
SUPRA_AGENT_REGISTRY_V1.md ─── registers ─── 9 agents
SUPRA_MODEL_REGISTRY_V1.md ─── catalogues ─── Models and providers
```

---

## 9. GRAPH HEALTH

| Metric | Value |
|--------|-------|
| Total nodes traced | 574+ (10 factories + 9 agents + 13 commands + 5 registries + 1 workflow + 20 scripts + 226 Swift modules + 300+ docs) |
| Total relationships | 200+ |
| Missing links | SUPRA-Router → Swift implementation (no Router*.swift exists) |
| Broken links | 5 overlapping registries — unclear which is authoritative |
| Stale nodes | 28GB .overnight_audit/, freeze archives (94MB+) |
| Graph refresh needed | After every mission |

---

## 10. RECOMMENDATIONS

1. **Consolidate registries**: Merge CANONICAL_REGISTRY.json, SUPRA_MASTER_REGISTRY.json, SUPRA_EXECUTIVE_PLATFORM_REGISTRY.json into FACTORY_REGISTRY.json
2. **Implement Router in Swift**: Create SUPRA/RouterEngine.swift to close the spec-to-code gap
3. **Update knowledge graph**: Wire this report into FACTORY_04_KNOWLEDGE/outputs/ as CANONICAL_MODEL.json replacement or supplement
4. **Archive stale data**: Remove .overnight_audit/ (28GB) and consolidate freeze archives

---

**END OF KNOWLEDGE GRAPH REPORT V1**
