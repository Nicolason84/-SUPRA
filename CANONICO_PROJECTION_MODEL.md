# CANONICO Projection Model

## Status: SPECIFICATION V1

---

## 1. PROJECTION PRINCIPLES

### 1.1 Definition
A Projection is a **derived, read-only view** of the canonical Graph in a specific format. The Graph is the source of truth; all Projections are synchronized derivatives.

### 1.2 Derivation Rule
Given the same Graph state and the same Projection definition, the output is always identical. Projections are deterministic.

### 1.3 No-Write Rule
Projections never write back to the Graph. The Graph is modified exclusively through the Identity Engine.

### 1.4 Lossy Nature
Some Projections may lose information (e.g., a file system cannot represent all Graph dimensions). Lossy transformations are documented and explicit.

---

## 2. PROJECTION DEFINITION

```
ProjectionDefinition {
  id: Identity
  name: String
  format: ProjectionFormat
  query: GraphQuery           [what part of the Graph to project]
  transform: TransformFunction [how to transform nodes/edges to target format]
  schedule: Schedule           [when to regenerate]
  metadata: Map
}
```

---

## 3. STANDARD PROJECTIONS

### 3.1 JSON Projection

| Property | Value |
|----------|-------|
| Format | JSON |
| Use | Interchange, backup, API |
| Fidelity | Lossless (all fields preserved) |

```json
{
  "graph": {
    "version": "1.0",
    "generated": "2026-07-29T12:00:00Z",
    "nodes": [...],
    "edges": [...]
  }
}
```

### 3.2 YAML Projection

| Property | Value |
|----------|-------|
| Format | YAML |
| Use | Human-readable configuration |
| Fidelity | Lossless |

```yaml
graph:
  version: "1.0"
  generated: 2026-07-29T12:00:00Z
nodes:
  - id: can:sys:...
    name: MyProject
    type: project
```

### 3.3 SQLite Projection

| Property | Value |
|----------|-------|
| Format | SQLite |
| Use | Query, analytics |
| Fidelity | Lossless (normalized to tables) |

Tables:
- `nodes` (id, type, archetype, pattern, name, dimensions, lifecycle)
- `edges` (id, type, source, target, weight, trust, timestamp)
- `events` (id, timestamp, type, actor, target)
- `attributes` (node_id, key, value, type)
- `metadata` (key, value)

### 3.4 File System Projection

| Property | Value |
|----------|-------|
| Format | File system tree |
| Use | Finder, file browser |
| Fidelity | Lossy (dimensions, edges, trust partially lost) |

```
/Graph/
  Projects/
    SUPRA/
      SUPRA.xcodeproj/
      SUPRA/
        ContentView.swift
        SUPRAApp.swift
      SUPRATests/
  Documents/
  ...
```

Mapping rules:
- CONTAINS edges → directory hierarchy
- BELONGS_TO edges → subdirectory placement
- Node name → file/directory name
- Node type → file extension (when applicable)
- Dimensions lost

### 3.5 Git Projection

| Property | Value |
|----------|-------|
| Format | Git repository |
| Use | Version control |
| Fidelity | Lossy (dimensions, trust lost) |

Each commit corresponds to a Graph mutation event. Git branches represent alternate Graph states.

### 3.6 SwiftUI Projection

| Property | Value |
|----------|-------|
| Format | SwiftUI view hierarchy |
| Use | Screen visualization |
| Fidelity | Lossy (designed for visual consumption) |

- Nodes → Views
- Archetype colors → View colors
- CONTAINS edges → View hierarchy
- Dimensions → Visual properties (size, opacity, position)
- Edges → Lines between views

### 3.7 API Projection

| Property | Value |
|----------|-------|
| Format | REST / GraphQL |
| Use | Remote access |
| Fidelity | Lossless |

```
GET /api/v1/graph
GET /api/v1/nodes/:id
GET /api/v1/nodes/:id/edges
GET /api/v1/edges/:id
POST /api/v1/query
GET /api/v1/projections/:id
GET /api/v1/health
GET /api/v1/metrics
```

### 3.8 Documentation Projection

| Property | Value |
|----------|-------|
| Format | Markdown |
| Use | Human reference |
| Fidelity | Lossy |

Generates structured documentation from the Graph, including:
- System overview (SYSTEM nodes)
- Component catalog (RESOURCE nodes)
- Relationship diagrams (Edges)
- Architecture Decision Records (DECISION nodes)

### 3.9 QR Projection

| Property | Value |
|----------|-------|
| Format | QR code image |
| Use | Physical tagging |
| Fidelity | Digest only |

Encodes the Digital Passport (or a hash reference to it) as a QR code.

### 3.10 Digital Twin Projection

| Property | Value |
|----------|-------|
| Format | Twin state snapshot |
| Use | Digital twin synchronization |
| Fidelity | Functional (twin-relevant fields) |

Projects the Graph into a format consumable by digital twin platforms.

---

## 4. PROJECTION ENGINE

### 4.1 Generation Pipeline

```
1. Receive ProjectionDefinition + optional query
2. Read Graph state via AssetEngine + RelationEngine
3. Apply query filter (select relevant subgraph)
4. Apply transform function (Graph → target format)
5. Write output to target location
6. Record ProjectionGenerated event
```

### 4.2 Schedule

Projections can be:
- **On-demand**: triggered by request
- **Periodic**: regenerated at intervals (cron-like)
- **Event-driven**: regenerated on Graph mutation
- **Continuous**: streaming updates (for APIs)

### 4.3 Caching

Projections are cached. Cache invalidation:
- On Graph mutation (for event-driven)
- On TTL expiry (for periodic)
- On explicit request (for on-demand)

---

## 5. PROJECTION INTEGRITY

Each Projection carries:
- Source Graph state hash (what Graph version produced this)
- Generation timestamp
- Definition used
- Optional signature

```json
{
  "projection": {
    "definition": "can:prj:...",
    "graphState": "0x7f83b165...",
    "generated": "2026-07-29T12:00:00Z",
    "format": "json",
    "signed": "can:res:key..."
  },
  "data": { ... }
}
```

---

## 6. CUSTOM PROJECTIONS

New Projections can be defined by registering:
1. Unique name and format identifier
2. Query that selects the relevant subgraph
3. Transform function (can be a reference to an external converter)
4. Schedule policy
5. Output target

---

## 7. PROJECTION VS SYNCHRONIZATION

| Aspect | Projection | Synchronization |
|--------|-----------|-----------------|
| Direction | Graph → External | Bidirectional |
| Authority | Graph is source | Both sides may diverge |
| Conflict | Impossible | Resolution needed |
| Latency | Deterministic | Variable |

CANONICO uses **Projection only** for external representations. True synchronization is not supported — the Graph is the single source of truth.

---

**CANONICO_PROJECTION_MODEL.md — V1**
