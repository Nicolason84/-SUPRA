# ARCHITECTURE MAP — V1

## Status: CERTIFIED

| Property | Value |
|----------|-------|
| **Version** | ARCH_MAP_V1 |
| **Date** | 2026-07-29 |
| **Authority** | FACTORY_01_ARCHITECTURE |
| **Certified By** | FACTORY_06_PROOF |

---

## 1. SYSTEM OVERVIEW

SUPRA is an autonomous software factory operating on macOS. It combines:
- A SwiftUI application for visualization and control
- An AST analysis platform for code understanding
- A multi-agent system (via OpenCode) for automation
- A knowledge and memory system for continuity

---

## 2. COMPONENT MAP

### 2.1 Application Layer (SUPRA/)

| Component | Type | Responsibility | Dependencies |
|-----------|------|----------------|--------------|
| SUPRAApp | Application | App lifecycle, entry point | All |
| CompositionRoot | Pattern | Dependency injection | All services |
| ContentView | View | Main navigation | All views |
| DashboardView | View | System overview | All services |
| MissionCenterView | View | Mission management | MissionStore |
| ExecutiveWorkflow | Service | Workflow orchestration | All services |
| RuntimeMonitor | Service | System health | RuntimeGateway |
| MultiMemoryStore | Service | Persistence | File system |
| NOVAKnowledgeKernel | Service | Knowledge graph | File system |
| SUPRADecisionEngine | Service | Decision making | All services |
| WorkspaceDiscovery | Service | File indexing | File system |

### 2.2 AST Platform (SUPRA_AST_PLATFORM/)

| Component | Type | Responsibility | Dependencies |
|-----------|------|----------------|--------------|
| SUPRAAST | Library | Swift AST parsing | SwiftSyntax |
| ASTParser | Module | Source file parsing | SUPRAAST |
| DependencyGraph | Module | Dependency analysis | ASTParser |
| DependencyVisitor | Module | SwiftSyntax visitor | SwiftSyntax |
| DiscoveryVisitor | Module | Symbol discovery | SwiftSyntax |
| DeclarationGraph | Module | Declaration tracking | ASTParser |
| RefactoringEngine | Module | Code refactoring | ASTParser |
| Writer | Module | Code generation | ASTParser |
| Validation | Module | Validation | ASTParser |
| RuleEngine | Module | Rule checking | ASTParser |
| CLI | Executable | Command line interface | SUPRAAST |

### 2.3 Agent System (.opencode/)

| Component | Type | Responsibility |
|-----------|------|----------------|
| SUPRA-Architect | Agent | Architecture design |
| SUPRA-Builder | Agent | Code implementation (Single Writer) |
| SUPRA-Auditor | Agent | Compliance validation |
| SUPRA-Reviewer | Agent | Code review |
| SUPRA-Explorer | Agent | Codebase navigation |
| SUPRA-Research | Agent | Technical research |
| SUPRA-Runtime | Agent | Runtime diagnostics |
| SUPRA-Refactor | Agent | Refactoring analysis |
| SUPRA-Router | Agent | Task routing |

### 2.4 Factory System (FACTORIES/)

| Component | Type | Responsibility |
|-----------|------|----------------|
| FACTORY_01_ARCHITECTURE | Factory | Architecture governance |
| FACTORY_02_DISCOVERY | Factory | Repository discovery |
| FACTORY_03_RUNTIME | Factory | Build and execution |
| FACTORY_04_KNOWLEDGE | Factory | Knowledge management |
| FACTORY_05_MEMORY | Factory | Session continuity |
| FACTORY_06_PROOF | Factory | Certification |
| FACTORY_07_QUALITY | Factory | Quality assurance |
| FACTORY_08_DOCUMENTATION | Factory | Documentation |
| FACTORY_09_EXECUTION | Factory | Planning and scheduling |
| FACTORY_10_EXECUTIVE | Factory | Governance |

---

## 3. LAYER ARCHITECTURE

```
┌──────────────────────────────────────────────────────────┐
│                    UI LAYER (SwiftUI)                     │
│  Views, Navigation, Charts, Controls                     │
├──────────────────────────────────────────────────────────┤
│                  APPLICATION LAYER                        │
│  Stores, Services, Gateways, Controllers                 │
├──────────────────────────────────────────────────────────┤
│                  DOMAIN LAYER                             │
│  Models, Logic, Rules, Knowledge                         │
├──────────────────────────────────────────────────────────┤
│                  INFRASTRUCTURE LAYER                     │
│  Persistence, Networking, File System, IPC               │
├──────────────────────────────────────────────────────────┤
│                  AGENT LAYER (OpenCode)                   │
│  SUPRA-Architect, -Builder, -Auditor, etc.               │
└──────────────────────────────────────────────────────────┘
```

---

## 4. BOUNDARY DEFINITIONS

| Boundary | Components | Protocol | Owner |
|----------|------------|----------|-------|
| UI-Service | Views ↔ Stores | @Published / ObservableObject | UI Team |
| Service-Domain | Stores ↔ Models | async/await | Core Team |
| Domain-Infrastructure | Models ↔ Persistence | Codable | Data Team |
| App-Agent | OpenCodeBridge ↔ Agents | IPC | Infrastructure |

---

## 5. COMPONENT DEPENDENCIES

### 5.1 Package Dependencies

| Package | Dependencies |
|---------|--------------|
| SUPRA | SwiftUI, Observation, UniformTypeIdentifiers |
| SUPRAAST | SwiftSyntax, ArgumentParser |
| CAnnoNicoIntegration | Foundation |
| SUPRATests | XCTest, SUPRA |

### 5.2 Service Dependencies

```
CompositionRoot
  ├── ExecutiveMissionControlStore
  │     └── MultiMemoryStore
  ├── MultiMemoryStore
  │     ├── CAnnoNicoSnapshotStore
  │     └── FileManager
  ├── NOVAKnowledgeKernel
  │     ├── KnowledgeGraph
  │     └── KnowledgeAuthority
  ├── SUPRADecisionEngine
  │     └── MultiMemoryStore
  └── RuntimeMonitor
        └── RuntimeGateway
```
