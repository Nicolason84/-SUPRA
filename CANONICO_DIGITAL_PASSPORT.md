# CANONICO Digital Passport

## Status: SPECIFICATION V1

---

## 1. PURPOSE

The Digital Passport is the canonical identity card for every Node in the Graph. It provides a self-contained, verifiable snapshot of a Node's identity, provenance, and current state.

A Passport can be:
- Embedded in a QR code for physical tagging
- Exported as JSON for machine verification
- Displayed as a document for human inspection
- Signed for cryptographic verification

---

## 2. PASSPORT STRUCTURE

```
DigitalPassport {
  identity: Identity                    [canonical ID]
  type: String                          [NodeType]
  archetype: String                     [Archetype name]
  pattern: String                       [Pattern name]

  name: String                          [current name]
  aliases: [String]                     [known aliases]

  pedigree: Pedigree {
    created: Timestamp
    creator: Identity                   [who/what created this node]
    seed: String                        [creation seed data]
    version: Int                        [version sequence]
    lineage: [Identity]                 [parent nodes in creation chain]
  }

  lifecycle: LifecycleState             [current lifecycle state]
  status: String                        [human-readable status]

  dimensions: DimensionSnapshot         [current dimension values]

  dependencies: [Identity]              [nodes this depends on]
  providers: [Identity]                 [nodes that provide to this]
  consumers: [Identity]                 [nodes that consume from this]

  trust: TrustRecord {
    level: Float                        [0.0–1.0]
    attestations: [Attestation]
    lastVerified: Timestamp
  }

  evidence: EvidenceChain {
    entries: [EvidenceEntry]
    hash: Hash                          [chain hash]
  }

  metrics: Map<String, Float>           [custom metrics]

  signature: Signature                  [optional cryptographic signature]

  metadata: Map                         [extensible metadata]
}
```

---

## 3. PEDIGREE

The Pedigree is the Node's birth certificate:

```json
{
  "pedigree": {
    "created": "2026-07-29T10:00:00Z",
    "creator": "can:agt:3f4a...",
    "seed": "ContentView.swift",
    "version": 1,
    "lineage": [
      "can:sys:9a8b...",
      "can:sys:7c6d..."
    ]
  }
}
```

- `creator` identifies the AGENT that instantiated the Node
- `lineage` traces the chain of creation (workspace → project → file)
- `version` increments with each attribute mutation

---

## 4. TRUST RECORD

```json
{
  "trust": {
    "level": 0.95,
    "attestations": [
      {
        "attestor": "can:agt:5e6f...",
        "algorithm": "Ed25519",
        "timestamp": "2026-07-29T10:00:00Z",
        "statement": "CONTENT_VERIFIED"
      }
    ],
    "lastVerified": "2026-07-29T12:00:00Z"
  }
}
```

Trust levels:
| Level | Meaning |
|-------|---------|
| 0.0–0.2 | Unknown / untrusted |
| 0.2–0.5 | Self-attested |
| 0.5–0.8 | Third-party verified |
| 0.8–1.0 | Cryptographically proven |

---

## 5. EVIDENCE CHAIN

```json
{
  "evidence": {
    "entries": [
      {
        "id": "can:evt:a1b2...",
        "type": "CREATION",
        "timestamp": "2026-07-29T10:00:00Z",
        "provedBy": "can:agt:3f4a...",
        "statement": "Node created with SHA256 content hash",
        "hash": "0x7f83b165..."
      },
      {
        "id": "can:evt:c3d4...",
        "type": "ATTRIBUTE_UPDATE",
        "timestamp": "2026-07-29T11:00:00Z",
        "provedBy": "can:agt:5e6f...",
        "statement": "Name changed from OldName to NewName"
      }
    ],
    "hash": "0x9e8d7c6b..."
  }
}
```

The chain hash is the SHA-256 of the concatenation of all evidence entry hashes.

---

## 6. QR CODE

The Passport can be encoded as a QR code for physical tagging:

```
QR Content: JSON.minify(DigitalPassport)
Max size: ~3KB (Version 25 QR, sufficient for most passports)
```

For larger passports: QR points to a URL or includes a reference hash.

---

## 7. PASSPORT OPERATIONS

### 7.1 Generate
```
generatePassport(node: Node) → DigitalPassport
```

Reads Node state → constructs Passport → signs if key is available.

### 7.2 Verify
```
verifyPassport(passport: DigitalPassport) → Bool
```

Verifies:
- Identity format is valid
- Signature (if present) is valid
- Evidence chain hash is consistent
- Trust attestations are verifiable

### 7.3 Compare
```
comparePassports(p1: DigitalPassport, p2: DigitalPassport) → Diff
```

Detects:
- Identity match / mismatch
- Attribute drift
- Trust level changes
- Evidence chain divergence

---

## 8. USE CASES

| Use Case | Description |
|----------|-------------|
| Asset Tagging | QR on physical device links to Digital Passport |
| CI/CD Verification | Build artifact carries signed passport |
| Digital Twin | Twin node passport mirrors physical asset |
| Audit Trail | Evidence chain proves compliance |
| Dependency Check | Dependencies list shows full supply chain |
| Identity Verification | 3rd party verifies node authenticity |

---

## 9. EXAMPLE: FILE PASSPORT

```json
{
  "identity": "can:res:7f83b165...",
  "type": "file",
  "archetype": "RESOURCE",
  "pattern": "SourceFile",
  "name": "ContentView.swift",
  "aliases": [],
  "pedigree": {
    "created": "2026-07-29T10:00:00Z",
    "creator": "can:agt:3f4a...",
    "seed": "sha256:0xabc...",
    "version": 3,
    "lineage": ["can:sys:9a8b..."]
  },
  "lifecycle": "ACTIVE",
  "status": "Ready",
  "dimensions": {
    "ownership": 0.85,
    "dependency": 0.72,
    "importance": 0.90
  },
  "dependencies": ["can:res:5a6b...", "can:res:7c8d..."],
  "providers": [],
  "consumers": ["can:pro:9e0f..."],
  "trust": { "level": 0.95, "attestations": [], "lastVerified": "..." },
  "evidence": { "entries": [...], "hash": "0x..." }
}
```

---

**CANONICO_DIGITAL_PASSPORT.md — V1**
