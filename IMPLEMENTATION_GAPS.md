# Implementation Gaps — Execution Era 001

The following gaps are the only unresolved items identified by the constitutional proof. Each is an executable mission with a bounded outcome.

| Priority | Gap | Required evidence | Owner | Mission |
|---|---|---|---|---|
| P1 | Universal execution-to-knowledge lineage is not enforced | Every completed mission links lessons, evidence, proof, and memory record | FACTORY_04_KNOWLEDGE | Implement append-only knowledge-ingestion coverage and lineage validation |
| P1 | Policy source paths and enforcement are not fully canonical | One valid constitution source and a passing policy-source gate | FACTORY_10_EXECUTIVE | Canonicalize constitution registry paths and enforce policy loading |
| P1 | Evidence-before-edit is contractual but not enforced | Every source change carries a valid evidence identifier | FACTORY_06_PROOF | Add the pre-change evidence manifest gate |
| P1 | Runtime external-operation timeout coverage is incomplete | Inventory of shell, filesystem, git, provider, and inference timeouts with failure proofs | FACTORY_03_RUNTIME | Complete bounded-operation audit |
| P1 | Memory close gate and checksums are incomplete | Append-only memory snapshot, checksum, and next-mission linkage | FACTORY_05_MEMORY | Make memory consolidation a certified close step |
| P2 | Repository-wide singleton policy is narrower than bootstrap scope | ArchitectureGuard scan covering all production services | FACTORY_01_ARCHITECTURE | Extend architecture guard coverage |
| P2 | Artefact hashes and freshness checks are incomplete | Source revision, content hash, and freshness validation for each certified output | FACTORY_06_PROOF | Add certification reproducibility gate |
| P2 | Factory leverage is not scored during mission review | Mission score includes reusable capability and cross-product value | FACTORY_10_EXECUTIVE | Add Factory-leverage scoring |
| P2 | Continuous improvement is not proven across multiple cycles | Durable KPI trend showing improvement over at least two completed cycles | FACTORY_10_EXECUTIVE | Persist and benchmark Factory KPIs |

No new architecture is required by these gaps. They are governance, instrumentation, validation, and evidence-completeness tasks over existing services.
