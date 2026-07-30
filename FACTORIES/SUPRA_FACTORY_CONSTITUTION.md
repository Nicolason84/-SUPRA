# SUPRA FACTORY CONSTITUTION — V1

## Status: RATIFIED

| Property | Value |
|----------|-------|
| **Version** | FACTORY_CONSTITUTION_V1 |
| **Date** | 2026-07-29 |
| **Authority** | SUPRA Executive |
| **Precedence** | Supersedes all prior governance models |

---

## 1. THE FACTORY MODEL

SUPRA is an Autonomous Software Factory composed of 10 specialized Factories.

Each Factory is a production unit with:
- ONE Mission
- ONE Responsibility
- ONE Owner
- ONE Validation
- ONE Certified Output

Factories never compete. Factories collaborate through certified artefacts only.

---

## 2. THE 10 FACTORIES

| ID | Factory | Mission | Output |
|----|---------|---------|--------|
| 01 | ARCHITECTURE | Maintain the unique architectural truth | EXECUTION_GRAPH.md, SYSTEM_TOPOLOGY.md, ARCHITECTURE_MAP.md, DEPENDENCY_GRAPH.md |
| 02 | DISCOVERY | Continuously discover repository knowledge | DISCOVERY_REPORT.md, MODULE_INDEX.md, DUPLICATE_REPORT.md |
| 03 | RUNTIME | Maintain executable production | PATCH_REPORT.md, BUILD_REPORT.md, VALIDATION_REPORT.md |
| 04 | KNOWLEDGE | Maintain executable knowledge | CANONICAL_MODEL.json, KNOWLEDGE_GRAPH.json, EVIDENCE_GRAPH.json |
| 05 | MEMORY | Maintain complete continuity | MEMORY_STATE.json, MISSION_HISTORY.md, SESSION_INDEX.md |
| 06 | PROOF | Certify every assertion | PROOF_REPORT.md, CERTIFICATION_REPORT.md |
| 07 | QUALITY | Protect production quality | QUALITY_REPORT.md |
| 08 | DOCUMENTATION | Generate documentation automatically | README.md, ARCHITECTURE.md, RFC/, API/, AGENTS.md |
| 09 | EXECUTION | Schedule production | EXECUTION_PLAN.md, EXECUTION_DAG.md, FACTORY_QUEUE.md |
| 10 | EXECUTIVE | Govern the entire Factory | EXECUTIVE_REPORT.md, NEXT_DECISION.md |

---

## 3. INDUSTRIAL RULES

### 3.1 Production Rules
1. **One Factory** — One Mission
2. **One Responsibility** — One Owner
3. **One Validation** — One Certified Output
4. **Evidence before Implementation** — No implementation without evidence
5. **Architecture before Runtime** — Architecture must be certified before runtime changes
6. **Runtime before Documentation** — Runtime must be validated before documentation
7. **Proof before Merge** — Every merge requires proof of correctness
8. **Validation before Release** — Every release requires validation
9. **Memory before Next Mission** — Every mission must consolidate memory before starting the next
10. **Executive Decision before every new Execution Gate** — No gate passage without executive decision

### 3.2 Collaboration Rules
1. No duplicated capabilities — Always reuse before creating
2. Factories communicate through certified artefacts only
3. Every Factory publishes its artefacts to the shared knowledge base
4. Every Factory consumes artefacts from upstream Factories
5. Downstream Factories validate upstream artefacts before consumption

### 3.3 Quality Rules
1. Every artefact must have a version
2. Every artefact must have a status (DRAFT, VALIDATED, CERTIFIED, DEPRECATED)
3. Every artefact must trace to its source evidence
4. Every assertion must be provable
5. Every change must be reversible

---

## 4. EXECUTION SEQUENCE

```
Mission
  │
  ▼
FACTORY_10_EXECUTIVE (Decision)
  │
  ▼
FACTORY_09_EXECUTION (Plan)
  │
  ▼
FACTORY_01_ARCHITECTURE (Architecture) ─► FACTORY_02_DISCOVERY (Discovery)
  │                                              │
  ▼                                              ▼
FACTORY_03_RUNTIME (Implementation) ◄──── FACTORY_04_KNOWLEDGE
  │                                              │
  ▼                                              ▼
FACTORY_05_MEMORY ◄────────────────────── FACTORY_06_PROOF
  │
  ▼
FACTORY_07_QUALITY
  │
  ▼
FACTORY_08_DOCUMENTATION
  │
  ▼
FACTORY_10_EXECUTIVE (Next Decision)
  │
  ▼
Next Mission
```

---

## 5. GATE SYSTEM

Every Factory has three gates:

| Gate | Criteria | Authority |
|------|----------|-----------|
| INPUT | All required upstream artefacts are certified | Previous Factory |
| EXECUTION | Factory can produce its output | Factory Owner |
| OUTPUT | Output artefact is valid and complete | FACTORY_07_QUALITY |

No Factory can pass EXECUTION gate without passing INPUT gate.
No Factory can close without passing OUTPUT gate.

---

## 6. FACTORY LIFECYCLE

Each Factory follows this lifecycle:
1. **STANDBY** — Ready for mission
2. **LOADED** — Input artefacts received and validated
3. **ACTIVE** — Processing mission
4. **VALIDATING** — Output being validated
5. **CERTIFIED** — Output certified and published
6. **IDLE** — Mission complete, awaiting next

---

## 7. GOVERNANCE

The FACTORY_10_EXECUTIVE is the sole governance authority.

It monitors:
- **Progress** — Are factories delivering on schedule?
- **Velocity** — Is the system improving throughput?
- **Confidence** — Are artefacts trustworthy?
- **Runtime Health** — Does the code compile and run?
- **Knowledge Health** — Is the knowledge graph coherent?
- **Architecture Health** — Is the architecture consistent?
- **Risk** — What are the top risks?
- **Technical Debt** — What needs refactoring?

The Executive produces ONE unique decision per observation cycle.

---

## 8. AMENDMENTS

This Constitution can only be amended by:
1. Executive Decision from FACTORY_10
2. Ratification by FACTORY_01_ARCHITECTURE
3. Validation by FACTORY_06_PROOF
4. Registration by FACTORY_05_MEMORY

---

**END OF CONSTITUTION**
