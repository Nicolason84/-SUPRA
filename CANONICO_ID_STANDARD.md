# CANONICO Identity Standard

## Status: SPECIFICATION V1

---

## 1. PRINCIPLES

### 1.1 Immutability
Once created, an Identity **never changes**. The name can change, the path can change, the attributes can change — the Identity never changes.

### 1.2 Content-Addressability
Identity is derived from content at creation time. The same entity, created at the same moment with the same attributes, always generates the same Identity.

### 1.3 Collision-Freedom
The Identity space is large enough (256 bits) that collision is astronomically improbable. If a collision occurs, the Graph must reject the duplicate creation.

### 1.4 Referential Integrity
Every Identity referenced in the Graph must resolve to an existing Node or Edge. Orphan identities are forbidden.

---

## 2. IDENTITY FORMAT

### 2.1 Canonical Form

```
can:<type>:<hash>
```

Where:
- `can` — constant prefix for CANONICO
- `<type>` — entity type prefix
- `<hash>` — 64-character hex-encoded SHA-256 hash

### 2.2 Type Prefixes

| Prefix | Entity | Example |
|--------|--------|---------|
| `sys` | System Node | `can:sys:a1b2...` |
| `agt` | Agent Node | `can:agt:c3d4...` |
| `res` | Resource Node | `can:res:e5f6...` |
| `mem` | Memory Node | `can:mem:g7h8...` |
| `pro` | Process Node | `can:pro:i9j0...` |
| `con` | Concept Node | `can:con:k1l2...` |
| `rel` | Relationship (abstract) | `can:rel:m3n4...` |
| `pat` | Pattern | `can:pat:o5p6...` |
| `arc` | Archetype | `can:arc:q7r8...` |
| `edg` | Edge | `can:edg:s9t0...` |
| `evt` | Event | `can:evt:u1v2...` |
| `prj` | Projection | `can:prj:w3x4...` |

### 2.3 Full Example

```
can:sys:7f83b1657ff1fc53b92dc18148a1d65dfc2d4b1fa3d677284addd200126d9069
```

---

## 3. HASH ALGORITHM

### 3.1 Default
SHA-256 over the canonical seed:

```
seed = canonicalJSON({
  type: NodeType,
  archetype: Archetype,
  seed: seedData,
  timestamp: creationTimestamp
})
hash = SHA256(seed)
```

### 3.2 Seed Data
The seed includes:
- Node type
- Archetype reference
- Creator-provided seed (if any)
- Creation timestamp (nanosecond precision)
- Optional: parent graph context

### 3.3 Extensibility
Future hash algorithms can be indicated by a prefix:

| Prefix | Algorithm |
|--------|-----------|
| `can:` | SHA-256 (default V1) |
| `can2:` | Reserved |
| `can3:` | Reserved |

---

## 4. SHORT FORM

For human-readable references within a known context:

```
# Full
can:sys:7f83b1657ff1fc53b92dc18148a1d65dfc2d4b1fa3d677284addd200126d9069

# Short (first 8 chars)
can:sys:7f83b165

# Named reference (context-dependent)
@SUPRAWorkspace
```

Short forms are resolved within the current Graph context. They are not globally unique.

---

## 5. IDENTITY OPERATIONS

### 5.1 Creation
```python
def create_identity(type, archetype, seed=None):
    data = {
        "type": type,
        "archetype": archetype,
        "seed": seed,
        "timestamp": now_ns()
    }
    hash = sha256(canonical_json(data))
    return f"can:{type_prefix(type)}:{hash}"
```

### 5.2 Resolution
```
resolve(identity: Identity) → Node | Edge | null
```

Resolution is O(1) — identity maps directly to storage location.

### 5.3 Validation
```
validate(identity: Identity) → Bool
```

Checks:
- Format validity
- Prefix matches entity type
- Hash is well-formed hex
- Entity exists in Graph

---

## 6. IDENTITY IN PRACTICE

### 6.1 A File Node Example

```json
{
  "id": "can:res:7f83b165...",
  "name": "ContentView.swift",
  "path": "/Users/.../ContentView.swift",
  "type": "file",
  "archetype": "RESOURCE",
  "pattern": "File"
}
```

The `id` is **immutable**. The `name` and `path` can change. The Node remains the same entity.

### 6.2 After Rename

```json
{
  "id": "can:res:7f83b165...",
  "name": "MainView.swift",
  "path": "/Users/.../MainView.swift",
  "type": "file",
  "archetype": "RESOURCE",
  "pattern": "File",
  "aliases": ["ContentView.swift"]
}
```

Same `id` — the Node persisted through the rename.

---

## 7. ALIASES

A Node can have aliases (previous names, known-as labels):

```
aliases: [
  { name: "ContentView.swift", validUntil: "2026-07-29T10:00:00Z" },
  { name: "MainView.swift", validFrom: "2026-07-29T10:00:01Z" }
]
```

---

## 8. SIGNATURE

Identity can be cryptographically signed:

```
signed_id = sign(identity, private_key)
signature = {
  identity: "can:sys:7f83b165...",
  algorithm: "Ed25519",
  key_id: "can:res:key-abc...",
  value: "base64_signature..."
}
```

---

**CANONICO_ID_STANDARD.md — V1**
