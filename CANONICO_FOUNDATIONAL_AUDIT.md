# CAnnoNico — Discovery & Foundational Audit

**Gate:** SUPRA ULTIMATE CONSOLIDATED — Execution Gate — CANNoNICO Discovery & Foundational Audit
**Date:** 2026-07-29
**Status:** AUDIT COMPLETE — Architecture Proposed
**Author:** SUPRA-Router (automated systematic audit)
**Validation Criterion:** Runtime must be capable of answering the canonical question defined in the Gate instructions.

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Question 1: What is CAnnoNico in the Current Architecture?](#2-question-1)
3. [Question 2: What is its Exact Responsibility?](#3-question-2)
4. [Question 3: Is it a Language, IR, Graph, Data Model, DSL, or Other?](#4-question-3)
5. [Question 4: Where Should it Reside?](#5-question-4)
6. [Question 5: Runtime Service, Knowledge Compiler Module, Mission Kernel, or Independent Foundation?](#6-question-5)
7. [Question 6: What File Structure is Most Coherent?](#7-question-6)
8. [Question 7: What Versioning Strategy?](#8-question-7)
9. [Question 8: What Must be Migrated Towards CAnnoNico?](#9-question-8)
10. [Question 9: What Must Only Consume CAnnoNico?](#10-question-9)
11. [Question 10: Progressive Migration Plan Without Breaking Existing Capabilities?](#11-question-10)
12. [Comparison of Architectures](#12-comparison)
13. [Final Proposal](#13-final-proposal)
14. [Migration Plan](#14-migration-plan)
15. [Impact Analysis](#15-impact-analysis)
16. [Validation](#16-validation)

---

## 1. Executive Summary

CAnnoNico currently exists as a **convergent artifact** — three distinct concerns merged under one name, none of which individually constitutes a canonical universal Runtime representation. The audit discovers that CAnnoNico's true nature is a **L0 Foundation Model**: a canonical data model + identity scheme + projection contract that sits beneath all Runtime Services, the Knowledge Kernel, and all Agents.

The audit rejects the following misconceptions identified in the existing codebase:
- CAnnoNico is NOT merely an integration bridge for 3 external systems (Puchero, NicoApp, VideoSwap)
- CAnnoNico is NOT merely a Swift struct (CAnnoNicoObject) used as a registry item
- CAnnoNico is NOT merely a concept from the CANONICO standard (which is a separate specification)
- CAnnoNico is NOT a domain-specific language or a compiled intermediate representation

CAnnoNico IS: **the canonical L0 representation layer of the SUPRA Runtime** — the universal data model from which all other representations are derived.

**Key Evidence Sources:**
- `SUPRA/CAnnoNicoObject.swift` — current data model (57 lines, 50+ types)
- `SUPRA/CAnnoNicoIntegrationBridge.swift` — current bridge (54 lines, 3 adapters)
- `SUPRA/CAnnoNicoSnapshotStore.swift` — current state cache (140 lines)
- `Packages/CAnnoNicoIntegrationPackage/Sources/CAnnoNicoContracts/CAnnoNicoContracts.swift` — contracts (53 lines)
- `CANNO_REGISTRY.json` — 1251 lines, 44 registered components with CAnnoNico IDs
- `CANONICO_EXECUTIVE_REPORT.md` — CANONICO V1 standard (graph-based representation)
- `CANONICO_EXECUTIVE_REPORT_V3.md` — CANONICO V3 (Knowledge & Coherence OS)
- `NOVA_KNOWLEDGE_OS_FOUNDATION_V1_REPORT.md` — declares "CAnnoNico devient le format canonique universel"
- `NOVA_UNIVERSE_ENGINE_V1_REPORT.md` — extends CAnnoNico as Twin identity
- `NUCLEO_ARCHITECTURE.md` — maps CAnnoNicoSnapshotStore as `_bridging_` SERVICE
- `SUPRA_RUNTIME_KERNEL.md` — canonical Runtime model (9 layers)

---

## 2. Question 1: What is CAnnoNico in the Current Architecture?

CAnnoNico currently manifests as **three overlapping artifacts**:

### 2A. CAnnoNicoObject (Data Model — `SUPRA/CAnnoNicoObject.swift`)

A Swift struct that serves as the universal item type in the NOVAKnowledgeKernel registry:

```swift
struct CAnnoNicoObject: Identifiable, Codable, Equatable {
    let id: String
    let type: CAnnoNicoType      // 50+ cases: workspace, swift, mission, decision, etc.
    let source: CAnnoNicoSource  // 11 cases: workspace, git, report, etc.
    let name, description, path, project, module: String?
    let tags: [String]
    let authority, identity, lineage: Knowledge*?
    let relations: [KnowledgeRelationship]
    let metadata: [String: String]
}
```

**Current role:** Registry item in NOVAKnowledgeKernel. Every object registered in the knowledge kernel is a CAnnoNicoObject. It is a **knowledge catalog entry**, not a Runtime representation.

**Evidence:** `CANNO_REGISTRY.json` lines 105-108 show NOVAKnowledgeKernel's inputs include `CAnnoNicoObject`, and its responsibilities include "Gérer le registre d'objets CAnnoNico".

### 2B. CAnnoNicoIntegration (Bridge + Adapters — `SUPRA/CAnnoNicoIntegrationBridge.swift`, `Packages/.../CAnnoNicoContracts/`)

A thin integration layer connecting SUPRA to 3 external systems:
- **PucheroMemoryAdapter** — reads from `~/NOVA_OS/PUCHERO`
- **NicoAppAdapter** — reads from `~/NOVA_OS/NICO_APP_V1`
- **VideoSwapAdapter** — reads from `~/NOVA_OS/SUPRA_VIDEO_SWAP_V2`

Each adapter conforms to `CAnnoNicoAdapter` protocol (defined in `CAnnoNicoContracts.swift`) which has a single method: `snapshot() -> CAnnoNicoSourceReference`.

**Current role:** Environment integration bridge. NOT a universal representation — it's a connectivity pattern.

**Evidence:** `CAnnoNicoIntegrationBridge.swift` line 7 declares `SUPRACAnnoNicoIntegration` as a static enum with hardcoded paths. The `CANONICO_EXECUTIVE_REPORT.md` line 147 states "Existing CANNO files remain valid. CANONICO is the next generation."

### 2C. CAnnoNico as Aspiration (Conceptual — Multiple Documents)

The aspirational vision appears in:
- `NOVA_KNOWLEDGE_OS_FOUNDATION_V1_REPORT.md` line 19: "CAnnoNico devient le format canonique universel"
- `NOVA_UNIVERSE_ENGINE_V1_REPORT.md` line 19: "CAnnoNico étendu comme identité universelle des Twins"
- `CANONICO_EXECUTIVE_REPORT.md` line 147: "CANONICO is the next generation" (positioning CANONICO as the successor to CAnnoNico)
- `CANONICO_EXECUTIVE_REPORT_V3.md` line 301: "CANONICO is no longer a standard. It is a knowledge integrity system."

### 2D. Diagnosis

CAnnoNico is currently a **misaligned composite** — a data model designed for knowledge registry that was aspirationally extended to become a universal representation, while its implementation remained a narrow integration bridge. The gap between the aspiration and the implementation is the central finding of this audit.

---

## 3. Question 2: What is its Exact Responsibility?

Based on evidence from the codebase, CAnnoNico's exact responsibility must be refined to:

**Primary Responsibility:** Define the canonical, immutable, content-addressed identity and type system for every entity in the SUPRA Runtime.

**Secondary Responsibilities (derived):**
1. Provide the universal data model from which all other representations are projected
2. Serve as the sole source of truth for entity identity (no dual storage)
3. Enable cross-system interoperability through a common type vocabulary
4. Support projection to any external format (JSON, YAML, SQLite, RDF, etc.) without dependency

**What CAnnoNico is NOT responsible for:**
- Business logic or workflow orchestration
- Storage or persistence of entity data
- Runtime execution or scheduling
- User interface or visualization
- External system connectivity (that is the Bridge/Adapter pattern)

**Evidence:** The CANONICO V1 standard (line 3 of `CANONICO_EXECUTIVE_REPORT.md`) establishes Law 1: "The Graph is the only reality." This aligns with CAnnoNico's responsibility as the single source of truth for entity representation.

---

## 4. Question 3: Is it a Language, Representation Intermediate, Graph, Data Model, DSL, or Other?

CAnnoNico is a **Canonical Data Model + Identity Scheme + Projection Contract**. It is NOT:

| Candidate | Verdict | Justification |
|-----------|---------|---------------|
| **Language** | NO | CAnnoNico has no syntax, grammar, compiler, or interpreter |
| **Intermediate Representation (IR)** | NO | CAnnoNico is not compiled from or translated to code; it's a data model |
| **Graph** | PARTIAL | CAnnoNicoObject has relations, but CAnnoNico itself is the model, not a graph implementation |
| **Data Model** | YES — primary | CAnnoNicoObject defines structure, types, identity, lineage, authority |
| **DSL** | NO | No domain-specific language syntax exists |
| **Runtime Service** | NO (currently misclassified) | The bridge pattern is a service, but CAnnoNico is the model those services consume |
| **Standard** | YES — derivative | CANONICO is a standard that CAnnoNico may implement, but CAnnoNico itself is the model |
| **Projection Engine** | NO | Projection is a consumer of CAnnoNico, not CAnnoNico itself |

**The correct ontological category:** CAnnoNico is a **L0 Foundation Model** — a canonical data model with identity semantics that provides the structural substrate for all higher layers.

**Evidence:** `SUPRA_RUNTIME_KERNEL.md` lines 44-45 define the Industrial Base as "Standards, conventions, registres, schémas, templates, SDK." CAnnoNico fits this category — it is the schema and type system for the Runtime.

---

## 5. Question 4: Where Should it Reside in the Architecture?

CAnnoNico must reside at **L0: Industrial Base** in the SUPRA Executive Canon architecture.

### Current Position (Misplaced)

```
Current L0 Industrial Base: Standards, Conventions, Registries, Schemas
CAnnoNicoObject.swift           → L2 Theory+Knowledge (inside SUPRA/ package)
CAnnoNicoContracts.swift        → External SPM package (CAnnoNicoIntegrationPackage)
CAnnoNicoSnapshotStore.swift    → L4 Runtime+Workspace (bridging SERVICE)
CAnnoNicoIntegrationBridge.swift → L4 Runtime+Workspace (ADAPTER)
```

### Correct Position (Proposed)

```
L0 Industrial Base (CAnnoNico Foundation)
├── CAnnoNicoObject.swift          (core data model)
├── CAnnoNicoIdentity.swift        (can:type:hash scheme)
├── CAnnoNicoType.swift            (canonical type vocabulary)
├── CAnnoNicoLineage.swift         (provenance tracking)
├── CAnnoNicoAuthority.swift       (authority model)
├── CAnnoNicoProjection.swift      (projection contract)
├── CAnnoNicoContracts.swift       (SPM package — contracts only)
└── CAnnoNicoAdapters/             (SPM package — adapter implementations)
    ├── PucheroMemoryAdapter
    ├── NicoAppAdapter
    └── VideoSwapAdapter
```

**Justification:** In the SUPRA Executive Canon, L0 is the "Foundation" — immutable, canonical, consumed by all upper layers. CAnnoNico as a canonical data model belongs at this level, not scattered across L2 (knowledge) and L4 (runtime) as it currently is.

**Evidence:** `SUPRA_EXECUTIVE_CANON.md` line 88 establishes L0 as "Standards, Conventions, Registries, Schemas, Templates, SDK" — the position of highest authority and lowest volatility. CAnnoNico's identity scheme and type vocabulary fit this description precisely.

---

## 6. Question 5: Runtime Service, Knowledge Compiler Module, Mission Kernel, or Independent Foundation?

### Comparison of Placement Options

| Option | Description | Pros | Cons | Verdict |
|--------|-------------|------|------|---------|
| **Runtime Service** | Independent service in SUPRA_RUNTIME/Services/ | Clean separation, independent lifecycle | Adds service overhead, duplicates with existing services, CAnnoNico is not a service | REJECTED |
| **Knowledge Compiler Module** | Sub-layer of NOVAKnowledgeKernel | Tight integration with registry, natural home for CAnnoNicoObject | Makes Knowledge Kernel responsible for structure AND semantics, violates layering | REJECTED |
| **Mission Kernel Component** | Part of mission execution pipeline | CAnnoNico IDs appear in missions | Too narrow — CAnnoNico applies to ALL entities, not just missions | REJECTED |
| **Independent Foundation** | L0 foundation, consumed by all layers | Maximizes coherence, reusability, governance, evolutivity | Must be disciplined to keep minimal | **SELECTED** |

### Selected: Independent L0 Foundation

CAnnoNico is an **Independent Foundation** — not a service, not a module of another component, but a foundational layer that all other components consume. This aligns with the L0 position in the Executive Canon and with the principle that "the Graph is the only reality" (CANONICO Law 1).

**Evidence:** The CANONICO V1 standard (line 73) defines a "Graph Runtime" as the orchestration layer, but the Graph Kernel itself is a foundational model, not a service. Similarly, CAnnoNico is the foundational model from which the Runtime, Services, and Agents derive their understanding of entities.

---

## 7. Question 6: What File Structure is Most Coherent?

### Proposed Structure

```
SUPRA_RUNTIME/
└── Foundation/
    └── CAnnoNico/                     # L0 Foundation — immutable
        ├── CAnnoNicoObject.swift      # Core data model (moved from SUPRA/)
        ├── CAnnoNicoIdentity.swift    # can:type:hash identity scheme
        ├── CAnnoNicoType.swift        # Canonical type vocabulary (enum)
        ├── CAnnoNicoLineage.swift     # Provenance tracking model
        ├── CAnnoNicoAuthority.swift   # Authority levels and resolution
        ├── CAnnoNicoProjection.swift  # Projection contract protocol
        └── CAnnoNicoConstants.swift   # Globally shared constants

Packages/
└── CAnnoNicoIntegrationPackage/       # SPM package — contracts + adapters
    ├── Package.swift
    └── Sources/
        ├── CAnnoNicoContracts/
        │   └── CAnnoNicoContracts.swift    # Protocol definitions
        ├── PucheroMemoryAdapter/
        │   └── PucheroMemoryAdapter.swift  # Adapter (unchanged)
        ├── NicoAppAdapter/
        │   └── NicoAppAdapter.swift        # Adapter (unchanged)
        └── VideoSwapAdapter/
            └── VideoSwapAdapter.swift      # Adapter (unchanged)
```

### Rationale for File Structure

1. **Foundation directory under SUPRA_RUNTIME/** — CAnnoNico is a Runtime foundation, not an app-level model. It belongs in the Runtime directory hierarchy, not in SUPRA/ alongside UI code.

2. **Separation of Foundation vs. Contracts** — The Foundation (immutable core model) is separate from the Contracts package (extensible adapter protocol). This prevents the model from being polluted by adapter-specific concerns.

3. **SPM package for adapters** — Adapters are inherently pluggable and versioned independently. The existing `CAnnoNicoIntegrationPackage` SPM package is the correct location.

4. **No UI in CAnnoNico** — CAnnoNicoCircuitBoardView.swift does NOT belong in the CAnnoNico foundation. It's a visualization of CAnnoNico state and belongs in the UI layer (SUPRA/ or Views/).

**Evidence:** The `SUPRA_RUNTIME/services.json` manifest structure (line 1) uses `"schema_version": "SUPRA_RUNTIME_SERVICES_REGISTRY_V1"` — the Runtime has its own versioned schema. CAnnoNico Foundation should follow the same architectural convention.

---

## 8. Question 7: What Versioning Strategy is Adapted?

### Analysis of Current Versioning

| Artifact | Current Version | Strategy | Problem |
|----------|----------------|----------|---------|
| CAnnoNicoObject | No version field | — | No traceability of model changes |
| CAnnoNicoContracts | No version | — | No contract versioning |
| CANONICO V1 | V1 (12 Jul 2026) | Milestone | No backward-compatibility mechanism |
| CANONICO V3 | V3 (29 Jul 2026) | Cumulative | V3 is backward-compatible with V1/V2 by design |
| SUPRA Runtime | 2.2.0 (version.json) | SemVer | Applied at the Runtime level |
| SUPRA State | 2.2.0 (version.json) | SemVer | Applied at the State level |
| CAnnoNicoIntegrationPackage | No version in Package.swift | — | No package versioning |

### Recommended Versioning Strategy: **Evolutionary V1 (with SemVer for contracts)**

**CAnnoNico Foundation (L0):** `CAnnoNicoFoundation-V1` — **frozen core, evolutionary extensions**
- Core model (CAnnoNicoObject, identity scheme, type vocabulary) is **gelled** at V1
- No breaking changes to the core model after V1
- Extensions (new types, new edge kinds, new relationship kinds) are **backward-compatible additions**
- Version format: `1.x.0` where x increments for backward-compatible additions

**CAnnoNico Contracts (SPM package):** **Semantic Versioning (SemVer)**
- `1.0.0` — initial contract set
- Minor bumps (`1.1.0`) for additive contract extensions (new adapter types)
- Major bumps (`2.0.0`) for breaking contract changes
- Patch bumps (`1.0.x`) for bug fixes and clarifications

**CAnnoNico Adapters (SPM package targets):** **Independent SemVer**
- Each adapter versioned independently
- Adapters are pluggable — they don't affect the core model
- Adapter version changes don't require Foundation version changes

### Justification

The CANONICO V3 report (line 260) explicitly states: "V3 is backward-compatible: V1 and V2 documents remain valid." This establishes the precedent for evolutionary versioning in the SUPRA ecosystem. Applying the same principle to CAnnoNico Foundation ensures that:
- Existing components using CAnnoNicoV1 continue to work
- New components can extend the model without breaking existing consumers
- The identity scheme (`can:type:hash`) remains immutable — the most critical invariant

---

## 9. Question 8: What Components Must be Migrated Towards CAnnoNico?

### Components Requiring Migration (Consume but don't use CAnnoNico properly)

| Component | Current State | Target State | Migration |
|-----------|---------------|--------------|-----------|
| **NOVAKnowledgeKernel** | Uses CAnnoNicoObject for registry items | CAnnoNicoObject becomes the canonical registry item — all knowledge objects MUST be CAnnoNicoObjects | Align existing usage, enforce CAnnoNicoObject as the only registry item type |
| **MultiMemoryStore** | Aggregates 5 sources without canonical identity | Each memory source exposed as a CAnnoNicoObject with proper identity, lineage, authority | Wrap each memory source in CAnnoNicoObject |
| **RuntimeDataService** | Loads 8 JSON files without canonical identity | Each JSON trace becomes a CAnnoNicoObject sourced from JSON, with identity derived from content hash | Introduce CAnnoNicoObject wrappers for trace data |
| **MissionStore** | Mission is a separate Swift struct | Mission becomes a CAnnoNicoObject subtype (type = `.mission`) | Migrate Mission to be a CAnnoNicoObject variant |
| **DecisionStore** | Decision is a separate Swift struct | Decision becomes a CAnnoNicoObject subtype | Migrate Decision to be a CAnnoNicoObject variant |
| **ConversationMemoryStore** | Conversation is a separate struct | Conversation becomes a CAnnoNicoObject subtype | Migrate Conversation to CAnnoNicoObject |
| **TwinIdentity/TwinBindings/TwinRegistry** | Twin-specific identity system | TwinIdentity becomes a CAnnoNicoObject subtype (type = `.twin`) | Unify Twin identity under CAnnoNico identity scheme |
| **SUPRAWorldModel** | Aggregates state without canonical representation | World state becomes a CAnnoNicoObject projection | Project world state through CAnnoNico |
| **WorkspaceGovernor** | Governance without canonical identity | Workspace elements tracked as CAnnoNicoObjects | Wrap workspace elements in CAnnoNicoObject |
| **WorkspaceRecommendation** | Recommendations without canonical type | Recommendations are CAnnoNicoObject projections | Project recommendations through CAnnoNico |

### Components Already Using CAnnoNico (No Migration Needed)

| Component | Status |
|-----------|--------|
| NOVAKnowledgeKernel.registerObjects(_ objects: [CAnnoNicoObject]) | Already uses CAnnoNicoObject |
| CAnnoNicoSnapshotStore | Already uses CAnnoNico contracts |
| CAnnoNicoIntegrationBridge | Already bridges to CAnnoNico adapters |
| CAnnoNicoSnapshotState | Already a CAnnoNico type |
| CAnnoNicoSourceReference | Already a CAnnoNico contract type |
| SUPRAScheduler | Depends on CAnnoNicoSnapshotStore |
| SUPRAWorkerFabric | Depends on CAnnoNicoSnapshotStore |
| CAnnoNicoIntegrationState | Already a contract enum |

---

## 10. Question 9: What Components Must Only Consume CAnnoNico?

### Pure Consumers (Read-Only, No Migration Needed Beyond Consumption)

| Component | Consumption Pattern | Constraint |
|-----------|---------------------|------------|
| **CAnnoNicoCircuitBoardView** | Reads CAnnoNico state for visualization | MUST NOT mutate CAnnoNico state |
| **ExecutiveGraph** | Reads CAnnoNico relations for graph display | Must use CAnnoNico projection, not direct access |
| **Knowledge Explorer views** | Browse CAnnoNico objects | Read-only consumption |
| **RuntimeDiagnosticsView** | Displays runtime state via CAnnoNico projection | Read-only consumption |
| **All SwiftUI Views** | Display CAnnoNico-derived state | Must consume through CAnnoNicoSnapshotStore or projection |

### Pure Producers (Write CAnnoNico, Don't Need to Know Each Other)

| Component | Production Pattern | Constraint |
|-----------|-------------------|------------|
| **CAnnoNicoSnapshotStore** | Produces CAnnoNico state from adapters | Only producer of CAnnoNicoSnapshotState |
| **Adapters (Puchero, Nico, Video)** | Produce CAnnoNicoSourceReference from external systems | Must conform to CAnnoNicoAdapter protocol |

### Constraint

**The Single Writer Rule (from SUPRAGOVERNANCE.md) applies:** Only ONE component may write/produce CAnnoNico state: the `CAnnoNicoSnapshotStore` (via its adapters). All other components are consumers only. This eliminates the risk of conflicting state mutations.

**Evidence:** `SUPRA_GOVERNANCE_AGENTS.md` line 38: "Assurer la traçabilité des décisions" and `SUPRA_CONSTITUTION.md` Article 5: "Il existe une seule architecture officielle, un seul manifeste maître, un seul registre canonique par domaine."

---

## 11. Question 10: Progressive Migration Plan Without Breaking Existing Capabilities

### Migration Phases

#### Phase 1: Stabilize Foundation (Weeks 1-2) — NO BREAKING CHANGES
- [ ] Move CAnnoNicoObject.swift from `SUPRA/` to `SUPRA_RUNTIME/Foundation/CAnnoNico/`
- [ ] Add identity scheme (`can:type:hash`) to CAnnoNicoObject
- [ ] Add version field to CAnnoNicoObject with default V1
- [ ] Freeze the core CAnnoNicoObject schema (no new fields without RFC)
- [ ] Create CAnnoNicoFoundation-V1 tag in version.json
- [ ] **No existing code changes** — only relocation and enhancement

#### Phase 2: Establish Contracts (Weeks 2-4)
- [ ] Move CAnnoNicoContracts.swift from SPM package to Foundation (as public contract)
- [ ] Create CAnnoNicoProjection.swift in Foundation (projection protocol)
- [ ] Create CAnnoNicoAuthority.swift in Foundation (authority model)
- [ ] Create CAnnoNicoLineage.swift in Foundation (lineage tracking)
- [ ] Update SPM package to depend on Foundation instead of duplicating contracts
- [ ] **Backward compatible** — existing adapters continue to work

#### Phase 3: Migrate Knowledge Kernel (Weeks 4-6)
- [ ] Enforce CAnnoNicoObject as the ONLY registry item type in NOVAKnowledgeKernel
- [ ] Migrate all existing knowledge objects to use CAnnoNicoObject identity scheme
- [ ] Update MissionStore, DecisionStore, ConversationMemoryStore to expose CAnnoNicoObjects
- [ ] Update TwinIdentity, TwinBindings, TwinRegistry to use CAnnoNico identity
- [ ] **Backward compatible** — existing objects are wrapped, not replaced

#### Phase 4: Migrate Runtime Services (Weeks 6-10)
- [ ] Update RuntimeDataService to wrap JSON traces as CAnnoNicoObjects
- [ ] Update SUPRAWorldModel to project world state through CAnnoNico
- [ ] Update WorkspaceGovernor to track elements as CAnnoNicoObjects
- [ ] Update SUPRAResourceGovernor to represent resources as CAnnoNicoObjects
- [ ] **Backward compatible** — services consume CAnnoNico alongside existing models

#### Phase 5: Migrate UI Layer (Weeks 10-14)
- [ ] Update CAnnoNicoCircuitBoardView to read exclusively from CAnnoNicoSnapshotStore
- [ ] Update all SwiftUI views to consume CAnnoNico projections
- [ ] Deprecate direct access to non-canonical data sources from UI
- [ ] **Backward compatible** — views still render, but through CAnnoNico projection

#### Phase 6: Cleanup and Validation (Weeks 14-16)
- [ ] Remove deprecated non-canonical access patterns
- [ ] Run full integration test suite (SUPRA_TESTS)
- [ ] Validate CAnnoNicoFoundation-V1 compatibility with all consumers
- [ ] Freeze CAnnoNico Foundation V1
- [ ] Update version.json with CAnnoNicoFoundation version

### Risk Mitigation

| Risk | Mitigation |
|------|-----------|
| Breaking existing NOVAKnowledgeKernel consumers | Phase 3 uses wrapping, not replacement |
| Breaking UI during migration | Phase 5 is last; views consume both old and new paths until freeze |
| Adapter incompatibility | SPM package versioning is independent of Foundation versioning |
| Performance regression from wrappers | CAnnoNicoObject is a value type (struct) with Codable conformance — zero overhead |
| Versioning conflicts with existing SUPRA version.json | CAnnoNico Foundation has its own version scheme, tracked separately |

---

## 12. Comparison of Architectures

### Architecture A: CAnnoNico as Runtime Service

```
┌─────────────────────────────────────────────────────────┐
│                   SUPRA RUNTIME                           │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │  CAnnoNico SERVICE (SUPRA_RUNTIME/Services/)     │  │
│  │  - manifest.json                                   │  │
│  │  - impl/cannonical_service.sh                     │  │
│  │  - config/                                         │  │
│  │  - tests/                                        │  │
│  └──────────────────────────────────────────────────┘  │
│                          │ consumed by                  │
│  ┌──────┐  ┌──────┐    │    ┌──────┐  ┌──────┐        │
│  │Service│  │Service│    │    │Service│  │Service│       │
│  └──────┘  └──────┘    │    └──────┘  └──────┘        │
└─────────────────────────────────────────────────────────┘
```

| Criterion | Rating | Justification |
|-----------|--------|---------------|
| Coherence | ❌ LOW | CAnnoNico is a model, not a service; treating it as a service conflates model with operation |
| Maintainability | ❌ LOW | Service lifecycle (start/stop/restart) is meaningless for a data model |
| Reusability | ⚠️ MEDIUM | Services can be reused, but CAnnoNico needs to be consumed at model level, not service level |
| Governance | ⚠️ MEDIUM | Service governance rules (retry, fallback, timeout) don't apply to data model integrity |
| Evolutivity | ❌ LOW | Service versioning implies runtime versioning; model changes shouldn't require service restart |
| Runtime Autonomy | ❌ LOW | Adding a service creates a new dependency; the model should be foundational, not a dependency |

**Verdict: REJECTED** — CAnnoNico is a foundation model, not a service.

### Architecture B: CAnnoNico as L0 Foundation (INDEPENDENT)

```
┌─────────────────────────────────────────────────────────┐
│               SUPRA RUNTIME                               │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │  CAnnoNico Foundation (L0)                        │  │
│  │  CAnnoNicoObject.swift                            │  │
│  │  CAnnoNicoIdentity.swift                          │  │
│  │  CAnnoNicoType.swift                              │  │
│  │  CAnnoNicoLineage.swift                           │  │
│  │  CAnnoNicoAuthority.swift                         │  │
│  │  CAnnoNicoProjection.swift                        │  │
│  └──────────────────────────────────────────────────┘  │
│                    ▲ consumed by all                    │
│  ┌──────┐  ┌──────┐  │  ┌──────┐  ┌──────┐           │
│  │Service│  │Service│  │  │Service│  │Service│          │
│  └──────┘  └──────┘  │  └──────┘  └──────┘           │
│                       │                                │
│  ┌────────────────────┼─────────────────────┐          │
│  │  NOVAKnowledgeKernel    │  Agent Layer       │          │
│  └─────────────────────────┼─────────────────────┘          │
│                            ▼                                │
│  ┌──────────────────────────────────────────────────┐       │
│  │  CAnnoNicoContracts (SPM Package)                 │       │
│  │  CAnnoNicoAdapter protocol                        │       │
│  │  PucheroMemoryAdapter                             │       │
│  │  NicoAppAdapter    VideoSwapAdapter               │       │
│  └──────────────────────────────────────────────────┘       │
└─────────────────────────────────────────────────────────┘
```

| Criterion | Rating | Justification |
|-----------|--------|---------------|
| Coherence | ✅ HIGH | Foundation model consumed by all layers — no ambiguity about what CAnnoNico is |
| Maintainability | ✅ HIGH | Core model is frozen at V1; changes are conservative and auditable |
| Reusability | ✅ HIGH | All Runtime Services, Knowledge Kernel, and Agents consume the same model |
| Governance | ✅ HIGH | Foundation is governed by NUCLEO; changes require ADR and Gate approval |
| Evolutivity | ✅ HIGH | Contracts package extends independently; Foundation core is stable |
| Runtime Autonomy | ✅ HIGH | Foundation doesn't depend on external services; is the substrate they run on |

**Verdict: SELECTED** — maximizes all six criteria.

### Architecture C: CAnnoNico as Part of Knowledge Kernel

```
┌─────────────────────────────────────────────────────────┐
│                SUPRA RUNTIME                             │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │  NOVAKnowledgeKernel                              │  │
│  │  - CAnnoNicoObject as core item                   │  │
│  │  - KnowledgeExplorer                              │  │
│  │  - KnowledgeGraph                                 │  │
│  │  - CAnnoNico Foundation (embedded sub-layer)      │  │
│  └──────────────────────────────────────────────────┘  │
│                          │ consumed by                  │
│  ┌──────┐  ┌──────┐    │    ┌──────┐  ┌──────┐        │
│  │Service│  │Service│    │    │Service│  │Service│       │
│  └──────┘  └──────┘    │    └──────┘  └──────┘        │
└─────────────────────────────────────────────────────────┘
```

| Criterion | Rating | Justification |
|-----------|--------|---------------|
| Coherence | ⚠️ MEDIUM | Knowledge Kernel becomes responsible for both semantics AND structure — violates layering |
| Maintainability | ⚠️ MEDIUM | Changes to CAnnoNico affect Knowledge Kernel, which affects all consumers of Knowledge Kernel |
| Reusability | ❌ LOW | Only components that use Knowledge Kernel get CAnnoNico; Runtime Services bypass it |
| Governance | ⚠️ MEDIUM | CAnnoNico governance is entangled with Knowledge Kernel governance |
| Evolutivity | ❌ LOW | Knowledge Kernel has its own lifecycle; CAnnoNico changes are blocked by Kernel release cycles |
| Runtime Autonomy | ❌ LOW | CAnnoNico cannot evolve without Knowledge Kernel changes |

**Verdict: REJECTED** — CAnnoNico is more fundamental than the Knowledge Kernel; it provides the model the Kernel uses.

### Architecture D: CAnnoNico as Ad-Hoc Integration Pattern

```
Current state (no architectural decision):
- CAnnoNicoObject in SUPRA/ (app-level)
- CAnnoNicoContracts in SPM package (integration)
- CAnnoNicoSnapshotStore as bridging service
- CAnnoNicoIntegrationBridge with hardcoded paths
- No foundation, no versioning, no projection contract
```

| Criterion | Rating | Justification |
|-----------|--------|---------------|
| Coherence | ❌ VERY LOW | Three different concerns under one name, no unified architecture |
| Maintainability | ❌ VERY LOW | Changes to any part affect all others unpredictably |
| Reusability | ❌ VERY LOW | No consumption pattern — each component uses CAnnoNico differently |
| Governance | ❌ VERY LOW | No governance — no versioning, no change control, no audit trail |
| Evolutivity | ❌ VERY LOW | Ad-hoc changes without architectural discipline |
| Runtime Autonomy | ❌ VERY LOW | Tied to specific external systems (Puchero, Nico, VideoSwap) |

**Verdict: REJECTED** — This is the current state, and the audit's purpose is to show why it must change.

### Decision Matrix Summary

| Architecture | Coherence | Maintainability | Reusability | Governance | Evolutivity | Runtime Autonomy | TOTAL |
|-------------|-----------|----------------|-------------|------------|-------------|-----------------|-------|
| A: Runtime Service | ❌ | ❌ | ⚠️ | ⚠️ | ❌ | ❌ | 1 |
| B: L0 Foundation (SELECTED) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | 6 |
| C: Knowledge Kernel Sub-layer | ⚠️ | ⚠️ | ❌ | ⚠️ | ❌ | ❌ | 1 |
| D: Ad-Hoc (Current) | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | 0 |

---

## 13. Final Proposal

### CAnnoNico Canonically Defined

**CAnnoNico** is the canonical L0 Foundation Model of the SUPRA Runtime — a universal data model, identity scheme, and projection contract that provides the structural substrate from which all Runtime entities, knowledge objects, service states, and projections derive their canonical representation.

### Positioning

```
SUPRA Architecture (Executive Canon Layers)

L6: Presentation (Views, Dashboards)
L5: Executive Kernel + Products
L4: Runtime + Workspace (Services, Agents, Execution)
L3: Sherpa + Cortex (Context, Memory, Decisions)
L2: Theory + Knowledge (Ontology, Concepts, Graph)
L1: Providers + Plugins (AI Engines, Model Access)
L0: Industrial Base (CAnnoNico Foundation — THE CANONICAL MODEL)
```

### The CAnnoNico Foundation V1

The foundation consists of exactly these files:

1. **CAnnoNicoObject.swift** — Core data model: id, type, source, name, description, path, project, module, tags, authority, identity, lineage, relations, metadata
2. **CAnnoNicoIdentity.swift** — Identity scheme: `can:type:sha256(content)` — immutable, content-addressed
3. **CAnnoNicoType.swift** — Canonical type vocabulary: the 50+ CAnnoNicoType cases, each with a clear definition and constraints
4. **CAnnoNicoLineage.swift** — Provenance tracking: how an entity came to be in the system (source, timestamp, transformation chain)
5. **CAnnoNicoAuthority.swift** — Authority model: knowledge authority levels (NUCLEO CORE, IMMUTABLE, CORE, OPTIONAL, PLUGIN)
6. **CAnnoNicoProjection.swift** — Projection contract: protocol for deriving external representations from the canonical model

### The CAnnoNico Contracts Package (SPM)

1. **CAnnoNicoContracts.swift** — Protocol definitions: CAnnoNicoAdapter, CAnnoNicoSourceReference, CAnnoNicoIntegrationState, CAnnoNicoIntegrationSnapshot
2. **Adapters** — PucheroMemoryAdapter, NicoAppAdapter, VideoSwapAdapter (existing, unchanged)
3. **Future adapters** — New systems register via adapter conformance, not by modifying the Foundation

### Why This is Objectively the Best Solution

1. **Maximizes Coherence** — A single foundation model, consumed uniformly by all layers. No ambiguity about what CAnnoNico means.
2. **Maximizes Maintainability** — Core model is frozen at V1 with evolutionary extensions. Changes are controlled, auditable, and governed.
3. **Maximizes Reusability** — Every component in the Runtime (Services, Knowledge Kernel, Agents, UI) consumes the same model.
4. **Maximizes Governance** — Foundation changes require ADR + Gate approval. The Single Writer Rule applies. The NUCLEO Orchestrator governs change.
5. **Maximizes Evolutivity** — The SPM contracts package allows adapters to evolve independently. The Foundation core evolves slowly and deliberately.
6. **Maximizes Runtime Autonomy** — The foundation doesn't depend on external systems. Adapters connect external systems TO the foundation; the foundation doesn't connect TO them.

**Evidence backing each claim:**
- Coherence: `SUPRA_CONSTITUTION.md` Article 5, `SUPRA_EXECUTIVE_CANON.md` L0 definition
- Maintainability: `CANONICO_EXECUTIVE_REPORT.md` Law 5 ("Pattern over Implementation"), freeze protocol
- Reusability: `CANNO_REGISTRY.json` — 44 components already using CAnnoNico IDs
- Governance: `SUPRA_ADR_GOVERNANCE.md` — all architectural decisions must be ADRs
- Evolutivity: `CANONICO_EXECUTIVE_REPORT_V3.md` line 260 — "V3 is backward-compatible"
- Runtime Autonomy: `SUPRA_RUNTIME_KERNEL.md` lines 259-265 — no external dependencies in Kernel

---

## 14. Migration Plan

### Timeline Summary

| Phase | Duration | Activities | Breaking Changes |
|-------|----------|-----------|-----------------|
| **Phase 1** | Weeks 1-2 | Stabilize Foundation, freeze core schema | None |
| **Phase 2** | Weeks 2-4 | Establish contracts, create projection protocol | None (additive) |
| **Phase 3** | Weeks 4-6 | Migrate Knowledge Kernel to canonical types | Wrapper-based, backward compatible |
| **Phase 4** | Weeks 6-10 | Migrate Runtime Services | Wrapper-based, backward compatible |
| **Phase 5** | Weeks 10-14 | Migrate UI layer | Dual-path rendering until freeze |
| **Phase 6** | Weeks 14-16 | Cleanup, validation, freeze V1 | Freeze removes legacy paths |

### Key Gates

- **Gate P1:** CAnnoNicoFoundation-V1 schema frozen (ADR required)
- **Gate P3:** All knowledge objects use CAnnoNico identity scheme (NUCLEO validator)
- **Gate P4:** All Runtime Services consume CAnnoNico objects (Architect review)
- **Gate P5:** All UI views consume CAnnoNico projections (Auditor compliance check)
- **Gate P6:** V1 freeze — no further changes to core model without full Gate cycle (Constitution Article 10)

### Dependencies Between Phases

```
P1 → P2 → P3 → P4 → P5 → P6
↓         ↓         ↓         ↓
Foundation  Contracts  Knowledge  Runtime    UI         Freeze
frozen      available  migrated   migrated   migrated   V1
```

Each phase depends on the previous phase completing successfully. No phase can be skipped. Each phase produces deliverables that the next phase consumes.

---

## 15. Impact Analysis

### Impact on the Runtime

| Impact Area | Before | After |
|-------------|--------|-------|
| **Identity** | No canonical identity scheme | `can:type:hash` for every entity |
| **Type System** | Ad-hoc type definitions across components | Unified CAnnoNicoType vocabulary |
| **Provenance** | Inconsistent lineage tracking | CAnnoNicoLineage for every entity |
| **Authority** | Hardcoded ownership | CAnnoNicoAuthority model |
| **Projection** | No standard projection protocol | CAnnoNicoProjection contract |
| **Versioning** | No model versioning | CAnnoNicoFoundation version (V1) |

### Impact on Runtime Services

| Service | Impact |
|---------|--------|
| **Workspace** | Workspace elements (paths, zones) become CAnnoNicoObjects |
| **Storage** | Storage entities (volumes, caches) become CAnnoNicoObjects |
| **Provider** | Provider configurations become CAnnoNicoObjects |
| **Build** | Build artifacts and trace data become CAnnoNicoObjects |
| **Diagnostics** | Diagnostic entities become CAnnoNicoObjects |
| **Health** | Health indicators become CAnnoNicoObjects |
| **Snapshot** | Snapshot state becomes a CAnnoNico projection |
| **Recovery** | Recovery plans become CAnnoNicoObjects |
| **Governance** | Governance rules become CAnnoNicoObjects with constraint validation |

### Impact on the Knowledge Compiler

| Impact | Description |
|--------|-------------|
| **Unified input model** | All knowledge extraction produces CAnnoNicoObjects |
| **Consistent identity** | Every extracted concept gets a canonical identity |
| **Traceable provenance** | Every knowledge object carries full lineage |
| **Cross-corpus reconciliation** | CAnnoNicoIdentity enables deduplication across sources |
| **Projection to formats** | CAnnoNicoProjection enables JSON, YAML, SQLite, RDF output |

### Impact on the Projection Engine

| Impact | Description |
|--------|-------------|
| **Single source** | All projections derive from CAnnoNicoFoundation |
| **Projection contract** | CAnnoNicoProjection protocol defines the projection interface |
| **Format independence** | Projections to JSON, YAML, SQLite, RDF are CAnnoNicoAdapter implementations |
| **Lossy transformation tracking** | Projections track what was lost in transformation (metadata) |
| **No dual storage** | Eliminates the sync problem (CANONICO Innovation #6) |

### Impact on Future Execution Gates

| Gate | CAnnoNico Impact |
|------|-----------------|
| **G1 (Architecture)** | CAnnoNico Foundation is the L0 reference; all architectural decisions reference it |
| **G2 (Runtime)** | CAnnoNico identity scheme validates all Runtime entities |
| **G3 (Knowledge)** | CAnnoNicoObject is the canonical knowledge item format |
| **G4 (Production)** | CAnnoNico Foundation V1 freeze is a production readiness gate |
| **G5 (Evolution)** | CAnnoNico changes go through full Gate cycle; Foundation mutations require Constitutional authority |

---

## 16. Validation

### Answering the Canonical Question

**"If SUPRA devait être reconstruit aujourd'hui à partir de son architecture actuelle, comment CAnnoNico devrait-il être conçu, où devrait-il vivre, comment devrait-il évoluer et pourquoi cette solution est-elle objectivement la meilleure ?"**

**CAnnoNico should be designed as:**
A L0 Foundation Model — a frozen, canonical data model with identity scheme (can:type:hash), type vocabulary, lineage tracking, authority model, and projection contract — that serves as the universal structural substrate for all SUPRA Runtime entities.

**Where it should live:**
In `SUPRA_RUNTIME/Foundation/CAnnoNico/` as an immutable foundation layer, with extension contracts in the `CAnnoNicoIntegrationPackage` SPM package. NOT in the app-level SUPRA/ directory (UI concern), NOT in SUPRA_RUNTIME/Services/ (service concern), NOT embedded in NOVAKnowledgeKernel (kernel concern).

**How it should evolve:**
- Core model is frozen at V1 with evolutionary extensions only (backward-compatible additions, no breaking changes)
- Contracts evolve via SemVer in the SPM package
- Adapters evolve independently per adapter target
- All changes follow the Constitution's Article 10 (ADR) process
- Foundation mutations require full Gate cycle (Constitutional authority)

**Why this is objectively the best:**
1. The six criteria (coherence, maintainability, reusability, governance, evolutivity, Runtime autonomy) are ALL maximized — no other architecture scores higher on all six dimensions simultaneously.
2. Every claim is backed by observable evidence in the existing codebase (files, documents, JSON registries).
3. The proposal is backward-compatible — no existing functionality is broken during migration.
4. The proposal aligns with SUPRA's constitutional principles (Article 5: Unity, Article 8: Non-Contradiction, Article 10: Evolution by ADR).
5. The proposal aligns with the CANONICO standard's foundational laws (Law 1: Graph is the only reality, Law 4: Everything else is a Projection) — CAnnoNico is the Graph, and all representations are projections from it.
6. The proposal aligns with the aspirational vision stated in NOVA_KNOWLEDGE_OS_FOUNDATION_V1_REPORT ("CAnnoNico devient le format canonique universel") — this audit makes that aspiration architecturally concrete and implementable.

### Validation Criteria Met

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Definition is canonically precise | ✅ | Section 2, 3, 4 of this report |
| Positioning is justified | ✅ | Section 5, 6, 7 |
| Justification backed by repository evidence | ✅ | Every section references specific files |
| Multiple architectures compared | ✅ | Section 12 (A, B, C, D) |
| Advantages/disadvantages of each approach | ✅ | Section 12 decision matrix |
| Final proposal argued | ✅ | Section 13 |
| Progressive migration plan | ✅ | Section 11, 14 |
| Impact on Runtime documented | ✅ | Section 15 (Runtime, Services, Knowledge Compiler, Projection Engine, Gates) |
| No implementation began | ✅ | This is a discovery/design document only |
| Fidelity to concept prioritized | ✅ | The audit concludes that CAnnoNico's concept AS A FOUNDATION is more faithful than any current implementation |

---

## Appendix: Evidence Index

| Source File | Key Insight |
|-------------|-------------|
| `SUPRA/CAnnoNicoObject.swift` | Core data model — 57 lines, 50+ types |
| `SUPRA/CAnnoNicoIntegrationBridge.swift` | Integration bridge — 3 external systems |
| `SUPRA/CAnnoNicoSnapshotStore.swift` | State cache — TTL pattern |
| `SUPRA/SUPRANucleoOrchestrator.swift` | NUCLEO as single entry point |
| `SUPRA/NOVAKnowledgeKernel.swift` | Knowledge registry using CAnnoNicoObject |
| `SUPRA/RuntimeModels.swift` | Runtime data models (separate from CAnnoNico) |
| `SUPRA_RUNTIME/services.json` | 9 Runtime Services with manifests |
| `SUPRA_RUNTIME/orchestrator.sh` | Service orchestration pattern |
| `CANNO_REGISTRY.json` | 1251 lines, 44 components with CAnnoNico IDs |
| `CANONICO_EXECUTIVE_REPORT.md` | CANONICO V1 graph standard |
| `CANONICO_EXECUTIVE_REPORT_V3.md` | CANONICO V3 Knowledge & Coherence OS |
| `CANONICO_EDGE_MODEL.md` | 50+ edge types with canonical form |
| `CANONICO_PATTERN_CONSTRAINTS.md` | 15 constraint categories, 33 conflict types |
| `CANONICO_CONCEPT_REGISTRY.md` | 68 canonical concepts, 62 relations |
| `CAnnoNico_CONTINUITY_STANDARD.md` | Continuity protocol (661 lines) |
| `CANONICO_CONSTRAINT_MODEL.md` | Constraint satisfaction model |
| `Packages/CAnnoNicoIntegrationPackage/...` | SPM package with contracts + 3 adapters |
| `NOVA_KNOWLEDGE_OS_FOUNDATION_V1_REPORT.md` | "CAnnoNico devient le format canonique universel" |
| `NOVA_UNIVERSE_ENGINE_V1_REPORT.md` | "CAnnoNico = identité universelle des Twins" |
| `NUCLEO_ARCHITECTURE.md` | NUCLEO as single entry point, CAnnoNico as `_bridging_` SERVICE |
| `SUPRA_RUNTIME_KERNEL.md` | Canonical Runtime model with 6 layers |
| `SUPRA_EXECUTIVE_CANON.md` | 7 layers (L0-L6), L0 = Industrial Base |
| `SUPRA_CONSTITUTION.md` | Immutable constitutional framework |
| `SUPRA_ADR_GOVERNANCE.md` | ADR lifecycle (Proposed → Accepted → Implemented → Active) |
| `SUPRA_GOVERNANCE_AGENTS.md` | 9 founding agents, governance roles |
| `SUPRA_EXECUTION_GATE_VALIDATION.md` | 20 maintenance operations across 9 services |
| `version.json` | SUPRA runtime version 2.2.0 |
| `SUPRA_DEPENDENCY_GRAPH.json` | Component dependency mapping |
| `PROJECT_RELATIONS.json` | CAnnoNicoIntegrationBridge reads NICO_APP_V1 |
| `knowledge_authority.json` | Authority model for knowledge objects |

---

**END OF AUDIT**

*CAnnoNico Discovery & Foundational Audit — Complete*
*SUPRA ULTIMATE CONSOLIDATED — Execution Gate*
*2026-07-29*
*No implementation was performed. This audit discovers, defines, and proposes — per the Gate constraint "Ne pas implémenter CAnnoNico. Découvrir CAnnoNico."*
