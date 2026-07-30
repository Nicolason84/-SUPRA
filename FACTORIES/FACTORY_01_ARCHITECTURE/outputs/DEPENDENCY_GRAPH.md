# DEPENDENCY GRAPH — V1

## Status: CERTIFIED

| Property | Value |
|----------|-------|
| **Version** | DEP_GRAPH_V1 |
| **Date** | 2026-07-29 |
| **Authority** | FACTORY_01_ARCHITECTURE |

---

## 1. PACKAGE-LEVEL DEPENDENCIES

```
SUPRA (App)
  ├── Foundation (system)
  ├── SwiftUI (system)
  ├── Observation (system)
  └── UniformTypeIdentifiers (system)

SUPRA_AST_PLATFORM (Package)
  ├── Foundation (system)
  ├── SwiftSyntax (SPM dependency)
  ├── SwiftSyntaxParser (SPM dependency)
  └── ArgumentParser (SPM dependency)

CAnnoNicoIntegrationPackage
  └── Foundation (system)

SUPRATests
  ├── XCTest (system)
  └── SUPRA (local)
```

---

## 2. MODULE-LEVEL DEPENDENCIES

### 2.1 SUPRA Module Dependencies

```
SUPRAApp
  ├── ContentView
  ├── CompositionRoot
  └── SUPRAMonetizationEngine

CompositionRoot
  ├── ExecutiveMissionControlStore
  ├── MultiMemoryStore
  ├── NOVAKnowledgeKernel
  ├── SUPRADecisionEngine
  └── RuntimeMonitor

ExecutiveMissionControlStore
  ├── Foundation
  └── MultiMemoryStore

MultiMemoryStore
  ├── Foundation
  ├── ConversationMemoryStore
  └── CAnnoNicoSnapshotStore

NOVAKnowledgeKernel
  ├── Foundation
  ├── KnowledgeGraph
  ├── KnowledgeAuthority
  └── KnowledgeSource

SUPRADecisionEngine
  ├── Foundation
  └── MultiMemoryStore

RuntimeMonitor
  ├── Foundation
  ├── RuntimeGateway
  └── RuntimeDataService
```

### 2.2 AST Platform Module Dependencies

```
CLI
  └── SUPRAAST

SUPRAAST
  ├── ASTParser
  ├── DependencyGraph
  ├── DependencyVisitor
  ├── DiscoveryVisitor
  ├── DeclarationGraph
  ├── RefactoringEngine
  ├── Writer
  ├── Validation
  └── RuleEngine

DependencyGraph
  ├── ASTParser
  └── DependencyVisitor
```

---

## 3. FACTORY-LEVEL DEPENDENCIES

```
FACTORY_10_EXECUTIVE (governs all)
  │
  ├── FACTORY_09_EXECUTION
  │     ├── FACTORY_01_ARCHITECTURE
  │     └── FACTORY_02_DISCOVERY
  │
  ├── FACTORY_03_RUNTIME (depends on 01)
  │     └── FACTORY_01_ARCHITECTURE
  │
  ├── FACTORY_04_KNOWLEDGE (depends on 01, 02)
  │     ├── FACTORY_01_ARCHITECTURE
  │     └── FACTORY_02_DISCOVERY
  │
  ├── FACTORY_05_MEMORY (depends on all)
  ├── FACTORY_06_PROOF (depends on 04, 03)
  │     ├── FACTORY_03_RUNTIME
  │     └── FACTORY_04_KNOWLEDGE
  │
  ├── FACTORY_07_QUALITY (depends on all)
  └── FACTORY_08_DOCUMENTATION (depends on all)
```

---

## 4. DEPENDENCY RULES

| Rule | Description |
|------|-------------|
| No cycles | No circular dependencies between packages |
| Layered | UI depends on Service, Service depends on Domain |
| Stable | Infrastructure depends on nothing within the project |
| Acyclic | Factory dependency graph must remain a DAG |
| Direction | Dependency direction follows the factory pipeline |

---

## 5. EXTERNAL DEPENDENCIES

| Dependency | Version | Purpose | Criticality |
|------------|---------|---------|-------------|
| Swift 6.x | System | Programming language | Critical |
| SwiftUI | System | UI framework | Critical |
| SwiftSyntax | SPM | Source code parsing | High |
| ArgumentParser | SPM | CLI argument parsing | Medium |
| Ollama | 0.32.3 | LLM backend | High |
| OpenCode | 1.18.5 | Agent runtime | Critical |
| Xcode | System | Build environment | Critical |
