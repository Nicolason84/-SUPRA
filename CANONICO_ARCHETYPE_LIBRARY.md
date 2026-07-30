# CANONICO Archetype Library

## Status: SPECIFICATION V1

---

## 1. ARCHETYPE MODEL

An Archetype is the most abstract classification of a Node. It defines the fundamental nature of an entity. Archetypes are the root of the Pattern hierarchy.

### 1.1 Archetype Structure

```
Archetype {
  id: Identity
  name: String
  description: String
  color: String                    [canonical color for 3D visualization]
  symbol: String                   [canonical symbol]
  form: String                     [3D form: sphere, cube, pyramid, etc.]

  patterns: [Pattern]              [all patterns under this archetype]
  nodeTypes: [NodeType]            [valid node types]

  abstract: Bool                   [true if cannot be instantiated directly]

  metadata: Map
  version: String
}
```

---

## 2. ARCHETYPE CATALOG

### 2.1 SYSTEM
| Property | Value |
|----------|-------|
| ID | `can:arch:system` |
| Color | `#4A90D9` (Blue) |
| Symbol | `◆` (Diamond) |
| Form | Cube |
| Abstract | No |

**Description:** A SYSTEM is an organized structure of interconnected elements that form a coherent whole. Systems contain, host, and provide context for other entities.

**Valid Patterns:** OperatingSystem, Application, Workspace, DataStore, Network, Platform, Organization, Team

**Examples:** macOS, MyProject.xcodeproj, SUPRA Workspace, Production Database, Engineering Team

**Typical Dimensions:**
- Ownership: high (0.7–1.0)
- Dependency: low (0.0–0.4)
- Importance: variable
- Lifecycle: long (0.5–1.0)

### 2.2 AGENT
| Property | Value |
|----------|-------|
| ID | `can:arch:agent` |
| Color | `#50C878` (Green) |
| Symbol | `●` (Circle) |
| Form | Sphere |
| Abstract | No |

**Description:** An AGENT is an autonomous entity that perceives, decides, and acts within a SYSTEM. Agents have agency — they can initiate actions.

**Valid Patterns:** AIAgent, Worker, Observer, Scheduler, HumanAgent, ServiceAgent

**Examples:** SUPRA-Router, Build Worker, File Watcher, Human Developer, Chat Assistant

**Typical Dimensions:**
- Energy: variable
- Trust: 0.3–1.0
- Activity: 0.0–1.0
- Execution: 0.0–1.0

### 2.3 RESOURCE
| Property | Value |
|----------|-------|
| ID | `can:arch:resource` |
| Color | `#F5A623` (Orange) |
| Symbol | `▲` (Triangle) |
| Form | Pyramid |
| Abstract | No |

**Description:** A RESOURCE is a passive entity that is consumed, used, or referenced by AGENTS and SYSTEMS. Resources have no agency.

**Valid Patterns:** ComputeUnit, StorageUnit, Module, File, API, Configuration, Asset

**Examples:** CPU core, Swift file, JSON config, REST API, Package.swift

**Typical Dimensions:**
- Dependency: 0.3–1.0
- Ownership: 0.0–1.0
- Lifecycle: 0.3–1.0

### 2.4 MEMORY
| Property | Value |
|----------|-------|
| ID | `can:arch:memory` |
| Color | `#9B59B6` (Purple) |
| Symbol | `■` (Square) |
| Form | Torus |
| Abstract | No |

**Description:** MEMORY is a persistent record of past states, interactions, decisions, or knowledge. Memory enables learning and continuity.

**Valid Patterns:** KnowledgeGraph, ConversationLog, DecisionLog, EvidenceChain, Cache, Archive

**Examples:** Project knowledge base, Chat history, ADR log, Build artifacts

**Typical Dimensions:**
- Importance: 0.5–1.0
- Trust: 0.5–1.0
- Lifecycle: 0.3–1.0

### 2.5 PROCESS
| Property | Value |
|----------|-------|
| ID | `can:arch:process` |
| Color | `#E74C3C` (Red) |
| Symbol | `▶` (Play) |
| Form | Cone |
| Abstract | No |

**Description:** A PROCESS is a sequence of operations that transforms inputs into outputs. Processes are temporal and have state.

**Valid Patterns:** Mission, Pipeline, Build, Workflow, Transformation, Compilation

**Examples:** Swift compilation, CI pipeline, User onboarding, Data migration

**Typical Dimensions:**
- Energy: 0.2–1.0
- Execution: 0.0–1.0
- Activity: 0.3–1.0
- Lifecycle: 0.0–0.8

### 2.6 CONCEPT
| Property | Value |
|----------|-------|
| ID | `can:arch:concept` |
| Color | `#1ABC9C` (Teal) |
| Symbol | `☆` (Star) |
| Form | Dodecahedron |
| Abstract | No |

**Description:** A CONCEPT is an abstract idea, standard, definition, or principle. Concepts are the most intangible Node type.

**Valid Patterns:** Standard, Product, Principle, Law, Definition, Metric

**Examples:** SOLID principles, Swift language, CANONICO Standard, Business model

**Typical Dimensions:**
- Importance: variable
- Trust: variable
- Dependency: 0.0–0.3
- Semantic Distance: high (>0.5)

### 2.7 RELATIONSHIP
| Property | Value |
|----------|-------|
| ID | `can:arch:relationship` |
| Color | `#ECF0F1` (Light Gray) |
| Symbol | `—` (Line) |
| Form | Edge |
| Abstract | Yes |

**Description:** RELATIONSHIP is an abstract archetype for Edges and relational Nodes. It represents connection itself.

**Valid Patterns:** (abstract — used for Edge classification only)

**Notes:** This archetype is abstract. No Node can be directly instantiated with it.

### 2.8 PATTERN
| Property | Value |
|----------|-------|
| ID | `can:arch:pattern` |
| Color | `#F39C12` (Gold) |
| Symbol | `⚘` (Lozenge) |
| Form | Octahedron |
| Abstract | Yes |

**Description:** PATTERN is the meta-archetype for Patterns and Archetypes themselves — the self-referential foundation of the system.

**Valid Patterns:** (meta — used to classify Pattern definitions)

**Notes:** This archetype is abstract. It exists for meta-modeling purposes only.

---

## 3. ARCHETYPE HIERARCHY

```
PATTERN (abstract)
  └─ Archetypes
       ├─ SYSTEM        ◆ Blue   Cube
       ├─ AGENT         ● Green  Sphere
       ├─ RESOURCE      ▲ Orange Pyramid
       ├─ MEMORY        ■ Purple Torus
       ├─ PROCESS       ▶ Red    Cone
       ├─ CONCEPT       ☆ Teal   Dodecahedron
       └─ RELATIONSHIP  — Gray   (edges only)
```

---

## 4. ARCHETYPE COLOR SYSTEM

Each Archetype has a canonical color for consistent 3D visualization:

| Archetype | Hex | Meaning |
|-----------|-----|---------|
| SYSTEM | `#4A90D9` | Stable, structural |
| AGENT | `#50C878` | Alive, autonomous |
| RESOURCE | `#F5A623` | Material, usable |
| MEMORY | `#9B59B6` | Reflective, preserved |
| PROCESS | `#E74C3C` | Active, transforming |
| CONCEPT | `#1ABC9C` | Abstract, ideal |
| RELATIONSHIP | `#ECF0F1` | Neutral, connective |
| PATTERN | `#F39C12` | Foundational, meta |

---

## 5. ARCHETYPE COMPOSITION

A Node belongs to exactly one Archetype. Archetypes cannot be mixed. Pattern composition allows behavioral mixing while maintaining a single archetypal identity.

---

**CANONICO_ARCHETYPE_LIBRARY.md — V1**
