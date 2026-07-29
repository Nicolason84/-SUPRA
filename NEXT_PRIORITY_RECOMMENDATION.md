# Execution Era V2 — Next Priority Recommendation

**Date**: 2026-07-29
**Phase**: 3 — Next Priority
**Governed by**: SUPRA_EXECUTION_MODE_V1.md

---

## Remaining Capability Registry Review

| ID | Capability | User Impact | Business Value | Effort | Risk | Score (Impact×Value / Effort×Risk) |
|----|-----------|-------------|---------------|--------|------|--------------------------------------|
| G1 | Unified Project Dashboard | HIGH | HIGH | MEDIUM | LOW | **9.0** |
| G3 | Export & Reporting | MEDIUM | MEDIUM | MEDIUM | LOW | 3.0 |
| G4 | Integration Dashboard | MEDIUM | MEDIUM | MEDIUM | MEDIUM | 2.0 |
| G6 | Audit Trail | MEDIUM | MEDIUM | MEDIUM | LOW | 3.0 |
| G7 | Smart Suggestions | MEDIUM | LOW | HIGH | HIGH | 0.5 |
| G5 | Capability Marketplace | HIGH | HIGH | HIGH | HIGH | 1.0 |
| G8 | Real-Time Collaboration | HIGH | HIGH | HIGH | HIGH | 1.0 |

**Scoring method**: (Impact × Value) / (Effort × Risk), normalized 0–10

---

## Recommendation: G1 — Unified Project Dashboard

### Rationale

G1 ranks #1 among remaining capabilities by a significant margin (9.0 vs. next highest 3.0):

1. **User Impact** — HIGH: A unified dashboard replaces the need to navigate between separate views (HealthView, RuntimeView, MemoryView, MissionView). Users see all project state in one place.

2. **Business Value** — HIGH: This is the Command Center — the primary interface users interact with daily. Unifying it dramatically improves UX and adoption.

3. **Implementation Effort** — MEDIUM: G1 is a UI composition task (assembling existing views into a unified layout). No new data models or network layers required.

4. **Technical Risk** — LOW: G1 uses existing, battle-tested views and the SUPRAEnvironmentResolver for path resolution. No new Foundation dependencies.

5. **Dependency Graph** — G1 depends on G2 (HealthMonitorView) which is now CERTIFIED. All other views (HealthView, RuntimeView, MemoryView, MissionView) are pre-existing and stable.

6. **Constitutional Compatibility** — G1 modifies no Foundation components. It only assembles UI components within CommandCenterView. Fully compatible with Runtime Constitution V1.

---

## Why Not Others

- **G3 (Export & Reporting)**: Valuable but lower impact — it's an export feature, not a core UX improvement.
- **G6 (Audit Trail)**: Important for compliance but doesn't directly improve user experience or daily workflow.
- **G5/G8 (Marketplace/Collaboration)**: High value but HIGH effort and HIGH risk — deferred to later.
- **G7 (Smart Suggestions)**: Low business value in current phase, high technical risk with AI integration.
- **G4 (Integration Dashboard)**: Useful but medium effort with medium value.

---

## Decision

**Execute G1 next.** Begin in Phase 4 with the execution dossier.
