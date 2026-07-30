# Legacy Knowledge Importer V1
## Architecture & Design Document

**Status**: DESIGN  
**Authority**: SUPRA Executive  
**Owner**: SUPRA-Architect  
**Created**: 2026-07-29  
**Version**: 1.0.0

---

## 1. Purpose

The Legacy Knowledge Importer (LKI) is a permanent Runtime capability that transforms historical SUPRA repositories into governed, certified Runtime knowledge. It is a knowledge compiler, not a migration tool. It never copies code wholesale; it extracts, understands, certifies, and publishes only governed knowledge.

## 2. Core Principles

| Principle | Description |
|-----------|-------------|
| **No Copy** | Never copy raw repositories. Never modify historical sources. |
| **Extract Only** | Read-only extraction of components, never write to source. |
| **Certify Always** | Every extracted component receives a certification status. |
| **Govern Knowledge** | Only Certified components may enter the Runtime. |
| **Continuous Enrichment** | Future SUPRA versions must automatically enrich this knowledge base. |
| **No Loss** | No repository is ever forgotten. No knowledge is ever lost. |

## 3. System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    LEGACY KNOWLEDGE IMPORTER V1                      │
│                           (Runtime Faculty)                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────┐  ┌────────────────┐  ┌────────────────┐           │
│  │   DISCOVERY   │  │ CLASSIFICATION │  │ EXTRACTION     │           │
│  │   ENGINE      │  │   ENGINE       │  │   ENGINE       │           │
│  │               │  │                │  │                │           │
│  │ - Scan repos  │  │ - Purpose      │  │ - Parse Swift  │           │
│  │ - Detect types│  │ - Maturity     │  │ - Extract Views│           │
│  │ - Build index │  │ - Version      │  │ - Extract Models│          │
│  └──────┬───────┘  └──────┬─────────┘  └──────┬─────────┘           │
│         │                 │                   │                     │
│         ▼                 ▼                   ▼                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    SEMANTIC UNDERSTANDING                  │   │
│  │                    ENGINE                                  │   │
│  │                                                              │   │
│  │  - Responsibility   - Role       - Dependencies            │   │
│  │  - Interactions     - Cohesion   - Coupling               │   │
│  │  - Business Value   - Tech Value  - Redundancy             │   │
│  │                                                              │   │
│  │  ┌─────────────────────────────────────────────────────┐   │   │
│  │  │              PATTERN DETECTION                      │   │   │
│  │  │                                                     │   │   │
│  │  │  - Mission patterns  - Decision patterns           │   │   │
│  │  │  - Runtime patterns  - Provider patterns           │   │   │
│  │  │  - Navigation patterns - Memory patterns           │   │   │
│  │  │  - Observer patterns - Engine patterns             │   │   │
│  │  │  - Service patterns - SwiftUI patterns             │   │   │
│  │  │  - Executive workflows                               │   │   │
│  │  └─────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│         │                                                          │
│         ▼                                                          │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    DUPLICATE RESOLUTION                    │   │
│  │                                                              │   │
│  │  - Detect duplicates   - Detect forks                       │   │
│  │  - Detect variants     - Detect obsolete                    │   │
│  │  - Detect experimental  - Rank alternatives                 │   │
│  └─────────────────────────────────────────────────────────────┘   │
│         │                                                          │
│         ▼                                                          │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    CERTIFICATION                           │   │
│  │                                                              │   │
│  │  Status: Experimental | Legacy | Reusable | Certified      │   │
│  │           Deprecated  | Canonical                           │   │
│  └─────────────────────────────────────────────────────────────┘   │
│         │                                                          │
│         ▼                                                          │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    RUNTIME PUBLICATION                     │   │
│  │                                                              │   │
│  │  - LEGACY_COMPONENTS.json                                   │   │
│  │  - LEGACY_CERTIFICATION.json                                │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## 4. Pipeline Stages

### Stage 1: Repository Discovery
- **Input**: Filesystem paths to historical repositories
- **Process**: Scan for Xcode Projects, Xcode Workspaces, Swift Packages, Frameworks, Modules, Assets, Documentation, Tests, Scripts, RFCs, AGENTS.md, README, Snapshots
- **Output**: `LEGACY_INDEX.json`

### Stage 2: Project Classification
- **Input**: `LEGACY_INDEX.json`
- **Process**: For each repository determine purpose, maturity, version, date, architecture, technologies, dependencies, current status, estimated reuse score
- **Output**: `LEGACY_CATALOG.json`

### Stage 3: Knowledge Extraction
- **Input**: `LEGACY_CATALOG.json`
- **Process**: Extract independently: SwiftUI Views, ViewModels, Models, Protocols, Services, Managers, Engines, Utilities, Extensions, Assets, Animations, Tests, Documentation, Architecture decisions, Mission workflows, Decision workflows, Memory workflows, Runtime workflows, Provider workflows
- **Output**: Extracted component metadata (in-memory, never moves files)

### Stage 4: Semantic Understanding
- **Input**: Extracted component metadata
- **Process**: Determine responsibility, role, dependencies, interactions, cohesion, coupling, business value, technical value, redundancy. Build semantic graph.
- **Output**: `LEGACY_GRAPH.json`

### Stage 5: Pattern Detection
- **Input**: `LEGACY_GRAPH.json`
- **Process**: Automatically identify reusable patterns (Mission patterns, Decision patterns, Runtime patterns, Provider patterns, Navigation patterns, Memory patterns, Executive workflows, Observer patterns, Engine patterns, Service patterns, SwiftUI patterns)
- **Output**: `LEGACY_PATTERNS.json`

### Stage 6: Duplicate Resolution
- **Input**: `LEGACY_GRAPH.json`
- **Process**: Detect duplicate components, forks, variants, obsolete implementations, experimental implementations. Select strongest candidate. Rank alternatives.
- **Output**: Duplicate resolution report (in-memory)

### Stage 7: Certification
- **Input**: Resolved components
- **Process**: Every extracted component receives one status: Experimental, Legacy, Reusable, Certified, Deprecated, Canonical
- **Output**: Certification metadata

### Stage 8: Runtime Publication
- **Input**: Certified components
- **Process**: Publish only governed knowledge. Generate `LEGACY_COMPONENTS.json` and `LEGACY_CERTIFICATION.json`
- **Output**: `LEGACY_COMPONENTS.json`, `LEGACY_CERTIFICATION.json`

## 5. Runtime Integration

The Legacy Knowledge Importer exposes a query interface that future Runtime queries must support:

| Query | Description |
|-------|-------------|
| `findReusableMissionCenter` | Find reusable Mission Center implementations |
| `findReusableDecisionInbox` | Find reusable Decision Inbox implementations |
| `findMemoryEngine` | Find Memory Engine implementations |
| `findRuntimePattern` | Find Runtime Pattern implementations |
| `findProviderImplementation` | Find Provider Implementation |
| `findExecutiveWorkflow` | Find Executive Workflow |
| `findSwiftUISurface` | Find SwiftUI Surface |
| `findCanonicalImplementation` | Find canonical implementation |

## 6. Data Contracts

All output artifacts follow the JSON schemas defined in:
- `.kernel/legacy_importer/schemas/legacy_index.schema.json`
- `.kernel/legacy_importer/schemas/legacy_catalog.schema.json`
- `.kernel/legacy_importer/schemas/legacy_graph.schema.json`
- `.kernel/legacy_importer/schemas/legacy_patterns.schema.json`
- `.kernel/legacy_importer/schemas/legacy_components.schema.json`
- `.kernel/legacy_importer/schemas/legacy_certification.schema.json`

## 7. Governance

- **Read-Only**: The LKI never modifies historical repositories.
- **No File Movement**: The LKI never moves files.
- **Certification Gate**: Only Certified components may enter the Runtime.
- **Continuous Enrichment**: Future SUPRA versions must automatically enrich the knowledge base.
- **No Loss**: No repository is ever forgotten. No knowledge is ever lost.

## 8. Interfaces

### Runtime Interface
```swift
protocol LegacyKnowledgeImporter: AnyObject {
    func discoverRepositories() async throws -> LegacyIndex
    func classifyProjects() async throws -> LegacyCatalog
    func extractKnowledge() async throws -> [ExtractedComponent]
    func buildSemanticGraph() async throws -> LegacyGraph
    func detectPatterns() async throws -> LegacyPatterns
    func resolveDuplicates() async throws -> DuplicateResolutionReport
    func certifyComponents() async throws -> LegacyCertification
    func publishToRuntime() async throws -> LegacyComponents
    
    // Query interface for future Runtime queries
    func findReusableMissionCenter() async throws -> [LegacyComponent]
    func findReusableDecisionInbox() async throws -> [LegacyComponent]
    func findMemoryEngine() async throws -> [LegacyComponent]
    func findRuntimePattern(pattern: String) async throws -> [LegacyComponent]
    func findProviderImplementation() async throws -> [LegacyComponent]
    func findExecutiveWorkflow() async throws -> [LegacyComponent]
    func findSwiftUISurface() async throws -> [LegacyComponent]
    func findCanonicalImplementation(name: String) async throws -> LegacyComponent?
}
```

## 9. Storage

The LKI stores its knowledge base in:
- `.kernel/legacy_importer/knowledge/` - Certified knowledge artifacts
- `.kernel/legacy_importer/schemas/` - JSON schemas for all artifacts
- `.kernel/legacy_importer/logs/` - Import logs and audit trails

## 10. Future Evolution

Every future version of SUPRA must:
1. Automatically scan for new historical repositories
2. Enrich the existing knowledge base
3. Re-run certification on previously uncategorized components
4. Update the semantic graph with new relationships
5. Detect new patterns from evolved codebases

---

**END OF ARCHITECTURE DOCUMENT**