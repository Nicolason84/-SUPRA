# SUPRA KNOWLEDGE OPERATING SYSTEM (SKOS) — Knowledge Object Schema

## KnowledgeUUID

Chaque objet de connaissance possède un **Knowledge UUID** unique.

### Format

```
KNW-[SEQUENCE]-[YYYY]-[MM]-[DD]
```

### Exemples

| Knowledge UUID | Mission | Description |
|----------------|---------|-------------|
| KNW-000001 | Ω1 | Runtime Bootstrap Contamination |
| KNW-000002 | Ω1.1 | dispatch_once Deadlock in MultiMemoryStore |
| KNW-000003 | Ω2 | SKOS Foundation Architecture |

---

## Certification UUID

Chaque certification possède un **Certification UUID** unique.

### Format

```
PHX-CERT-[SEQUENCE]-[YYYY]-[MM]-[DD]
```

---

## Lifecycle States

Chaque objet de connaissance traverse les états suivants :

| État | Description | Transition autorisée |
|------|-------------|---------------------|
| `RESEARCHING` | Investigation en cours | → CERTIFIED, → ARCHIVED |
| `CERTIFIED` | Certification validée | → FROZEN, → ARCHIVED |
| `FROZEN` | Partie d'une baseline immuable | → ARCHIVED |
| `ARCHIVED` | Historique, non active | — |

---

## Confidence Levels

| Niveau | Description | Critères |
|--------|-------------|----------|
| `HIGH` | Preuves directes et reproductibles | Crash log + source + tests |
| `MEDIUM` | Preuves indirectes + analyse statique | Source + tests (sans crash log) |
| `LOW` | Hypothèses + analyse théorique | Source uniquement |

---

## Baseline Versioning

### Format

```
BASELINE_[TYPE]_[MISSION]_[YYYY]_[MM]_[DD]
```

### Exemples

| Baseline ID | Type | Mission | Date | Description |
|-------------|------|---------|------|-------------|
| BASELINE_RUNTIME_OMEGA1_2026_07_30 | Runtime | Ω1 | 2026-07-30 | Première baseline certifiée |
| BASELINE_RUNTIME_OMEGA1_1_2026_07_30 | Runtime | Ω1.1 | 2026-07-30 | Baseline post-correction deadlock |

---

## Certification Status

| Statut | Description |
|--------|-------------|
| `CERTIFIED` | Certification validée et active |
| `FROZEN` | Certification intégrée dans une baseline immuable |
| `REJECTED` | Certification rejetée (investigation infructueuse) |
| `REOPENED` | Certification remise en question (nouvelle preuve) |

---

## Evidence Reference Schema

Chaque référence d'évidence suit le format :

```
[path/to/evidence]#[section]
```

### Types d'évidence

| Type | Description | Exemple |
|------|-------------|---------|
| Report | Rapport de certification | `SUPRA/Artifacts/OMEGA1_1_FIX_CERTIFICATION.md` |
| RootCause | Rapport de cause racine | `SUPRA/Artifacts/ROOT_CAUSE_CERTIFICATION_OMEGA1_1.md` |
| xcresult | Bundle de résultats de tests | `DerivedData/.../Test-SUPRA-2026.07.30_18-26-26-+0200.xcresult` |
| CrashLog | Rapport de crash | `~/Library/Logs/DiagnosticReports/SUPRA-2026-07-30-002433.ips` |
| Source | Fichier source modifié | `SUPRA/MultiMemoryStore.swift` |
| Commit | Hash Git | `5c17aba3c9d4e9dbe00c685897071d8da711d24e` |

---

## ProofGraph Entity Model

### Core Entities

```
KnowledgeObject
├── KnowledgeUUID
├── Version
├── Owner
├── LifecycleState
├── History
├── Relations
├── ConfidenceLevel
├── OriginalBaseline
└── CertificationInfo

Certification
├── CertificationUUID
├── KnowledgeUUID
├── Mission
├── Date
├── Authority
├── EvidenceReferences
├── Status
└── ConfidenceLevel

Baseline
├── BaselineID
├── Version
├── Date
├── CommitHash
├── CertifiedBy
└── Status

Evidence
├── EvidenceUUID
├── Type
├── Source
├── Date
├── Context
├── ContentHash
└── ChainOfCustody

RootCause
├── RootCauseID
├── KnowledgeUUID
├── Symptoms
├── Hypotheses
├── RejectedHypotheses
├── CertifiedCause
├── MinimalFix
├── Risks
├── History
└── CertificationRef
```

### Relations

```
KnowledgeObject --[CERTIFIED_BY]--> Certification
Certification --[BASED_ON]--> Evidence (1..*)
Evidence --[SUPPORTS]--> RootCause
RootCause --[RESOLVED_BY]--> KnowledgeObject
KnowledgeObject --[PART_OF]--> Baseline
Baseline --[CONTAINS]--> Certification (1..*)
KnowledgeObject --[EXTENDS]--> KnowledgeObject (0..*)
KnowledgeObject --[CONTRADICTS]--> KnowledgeObject (0..*)
```
