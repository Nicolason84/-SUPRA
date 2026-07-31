# V2 EXECUTION ROADMAP

## Status: DRAFT — AWAITING EXECUTIVE APPROVAL

| Property | Value |
|----------|-------|
| **Version** | V2_ROADMAP_V1 |
| **Date** | 2026-07-31T03:36:00Z |
| **Authority** | FACTORY_09_EXECUTION |
| **Baseline** | BUILD_CERTIFIED_V1 |

---

## 1. ROADMAP OVERVIEW

The V2 development roadmap is organized into sequential phases, each building on the previous. Every phase produces certified artefacts and measurable evidence.

```
BUILD_CERTIFIED_V1
    │
    ▼
PHASE 1: PERSISTENCE & DURABILITY
    │  └── Snapshot persistence, Event journal, Projections
    ▼
PHASE 2: KNOWLEDGE & MEMORY
    │  └── Knowledge Graph population, Memory store wiring
    ▼
PHASE 3: DIGITAL TWIN & HEALTH
    │  └── Digital Twin live data, Health check scheduling
    ▼
PHASE 4: QUALITY & AUTOMATION
    │  └── UI tests, Integration tests, Pipeline automation
    ▼
PHASE 5: CAPABILITY EXPANSION
    │  └── Per Executive-approved roadmap items
    ▼
V2 COMPLETE → CERTIFICATION
```

---

## 2. PHASE DETAILS

### Phase 1: Persistence & Durability

**Goal**: Make runtime state survive app restarts.

| Initiative | Expected Value | Dependencies | Effort |
|------------|---------------|--------------|--------|
| P1.1 Snapshot persistence | State continuity across launches | None (ExecutiveContextSnapshot is Codable) | Small |
| P1.2 Event journal durability | Audit trail that persists | None (schema exists in `.kernel/schemas/event.schema.json`) | Small |
| P1.3 Projection generation | Read-optimized query models | P1.1, P1.2 | Medium |

**Success criteria**:
- ✅ ExecutiveContextSnapshot saved to/loaded from `.kernel/memory/snapshots/`
- ✅ Events appended to `.kernel/projections/event_journal.jsonl`
- ✅ mission_index, decision_index generated from persisted data

### Phase 2: Knowledge & Memory

**Goal**: Activate FACTORY_04 (Knowledge) and FACTORY_05 (Memory) as data-producing factories.

| Initiative | Expected Value | Dependencies | Effort |
|------------|---------------|--------------|--------|
| P2.1 Knowledge Graph population | Certified knowledge available for queries | Phase 1 | Medium |
| P2.2 Memory store wiring | Persistent mission/decision/proof store | Phase 1 | Medium |
| P2.3 Component & dependency tracking | Full lineage for all objects | P2.2 | Medium |

**Success criteria**:
- ✅ FACTORY_04 produces Knowledge Graph artefacts
- ✅ FACTORY_05 produces Memory state artefacts
- ✅ `.kernel/` storage layers populated

### Phase 3: Digital Twin & Health

**Goal**: Connect the Digital Twin to live engine data and automate health monitoring.

| Initiative | Expected Value | Dependencies | Effort |
|------------|---------------|--------------|--------|
| P3.1 Digital Twin live data | Real-time engine state reflection | Phase 1 | Small |
| P3.2 Health check scheduling | Proactive health monitoring | None | Small |
| P3.3 Runtime telemetry wiring | Performance data capture | P3.1, P3.2 | Medium |

**Success criteria**:
- ✅ DigitalTwinRuntime populated with live engine metrics
- ✅ SUPRAHealthMonitor runs on schedule
- ✅ Telemetry data captured in `.kernel/`

### Phase 4: Quality & Automation

**Goal**: Automate validation to reduce manual verification burden.

| Initiative | Expected Value | Dependencies | Effort |
|------------|---------------|--------------|--------|
| P4.1 UI tests | Automated UI regression detection | None | Medium |
| P4.2 Snapshot pipeline integration tests | End-to-end Builder → Bus verification | Phase 1 | Medium |
| P4.3 Validation pipeline automation | One-command full validation | Phase 1, P4.1, P4.2 | Medium |

**Success criteria**:
- ✅ UI tests for ExecutiveWindow, MISSION_SURFACE, MissionCopilotView
- ✅ SnapshotBuilder → SnapshotBus integration test
- ✅ `supra-pipeline.sh validate` executes fully

### Phase 5: Capability Expansion

**Goal**: Add Executive-approved features from the Phase II roadmap.

| Initiative | Expected Value | Dependencies | Effort |
|------------|---------------|--------------|--------|
| P5.1 Per Executive-approved item | TBD | TBD | TBD |

**Success criteria**: As defined per approved initiative.

---

## 3. EXECUTION DAG

```
BUILD_CERTIFIED_V1
  │
  ├── Phase 1 ──────────────────────────────┐
  │   ├── P1.1 [S] Snapshot persistence      │
  │   ├── P1.2 [S] Event journal durability  │
  │   └── P1.3 [M] Projection generation     │
  │                                          │
  ├── Phase 2 ──────────────────────────────┤
  │   ├── P2.1 [M] Knowledge Graph          │  ← depends on Phase 1
  │   ├── P2.2 [M] Memory store             │
  │   └── P2.3 [M] Component tracking       │
  │                                          │
  ├── Phase 3 ──────────────────────────────┤
  │   ├── P3.1 [S] Digital Twin live data   │  ← depends on Phase 1
  │   ├── P3.2 [S] Health scheduling        │
  │   └── P3.3 [M] Telemetry wiring         │
  │                                          │
  ├── Phase 4 ──────────────────────────────┤
  │   ├── P4.1 [M] UI tests                 │
  │   ├── P4.2 [M] Integration tests        │  ← depends on Phase 1
  │   └── P4.3 [M] Pipeline automation      │  ← depends on Phase 4.1, 4.2
  │                                          │
  └── Phase 5 ──────────────────────────────┤
      └── P5.x  Executive-approved features  │  ← depends on all above
                                             │
                                             ▼
                                     V2 CERTIFICATION
```

[S] = Small effort, [M] = Medium effort, [L] = Large effort

---

## 4. EFFORT ESTIMATES

| Phase | Initiatives | Small | Medium | Large | Total Est. |
|-------|-------------|-------|--------|-------|------------|
| Phase 1 | 3 | 2 | 1 | 0 | ~5 days |
| Phase 2 | 3 | 0 | 3 | 0 | ~9 days |
| Phase 3 | 3 | 2 | 1 | 0 | ~5 days |
| Phase 4 | 3 | 0 | 3 | 0 | ~9 days |
| Phase 5 | TBD | TBD | TBD | TBD | TBD |
| **Total** | **12** | **4** | **8** | **0** | **~28 days** |

*Note: Estimates assume 1 day = 1 focused development session with validation.*

---

## 5. MILESTONES

| Milestone | Phase | Criteria | Evidence |
|-----------|-------|----------|----------|
| M1 | Phase 1 | Snapshot survives app restart | Loaded snapshot matches saved snapshot |
| M2 | Phase 1 | Event journal has entries | `.kernel/projections/event_journal.jsonl` non-empty |
| M3 | Phase 2 | Knowledge Graph queryable | FACTORY_04 produces certified output |
| M4 | Phase 2 | Memory store populated | `.kernel/memory/` directories non-empty |
| M5 | Phase 3 | Digital Twin shows live data | Twin reflects engine state changes |
| M6 | Phase 3 | Health check runs on timer | Health log shows periodic entries |
| M7 | Phase 4 | UI tests pass in automation | `xcodebuild test` includes UI tests |
| M8 | Phase 4 | Integration tests pass | Snapshot pipeline validated end-to-end |
| M9 | Phase 5 | Per approved initiative | Per initiative criteria |
| M10 | V2 | All phases complete, certified | V2_CERTIFICATION report produced |

---

*Roadmap generated by FACTORY_09_EXECUTION — V2 Transition*
