# MISSION — SUPRA COHÉRENCE ≥ 0.95

Date: 2026-09-22  
Authority: NICOLAS  
Control front: SUPRA

## Objective

Make the whole application behave like one operating system rather than a collection of screens.

Target: **COHERENCE_SCORE >= 0.95**.

## Canonical surface roles

- **SUPRA** — primary executive work surface and command/orchestration surface.
- **Chat** — conversation only; understand, discuss and plan.
- **ojO** — private Nicolas authority/context/human-gate surface.
- **Missions** — bounded execution and result tracking.
- **Runtime** — read-only observability and health.
- **Control** — decisions, proof and explicit authority gates.
- **CAnnoNico** — memory, provenance and canonical truth.
- Other universes may specialize presentation, but may not redefine canonical truth.

## Coherence laws

1. One canonical SUPRA application.
2. One shared runtime adapter for conversational/executive surfaces.
3. One human-gate semantics: machine-solvable work continues; Nicolas is asked only for a true human-only gate.
4. One visual grammar: shared spacing, radius, cards, headers and status pills.
5. One vocabulary per responsibility; no two surfaces claim the same primary role.
6. Historical failures remain evidence but do not impersonate live blockers.
7. No visible action that only opens a placeholder.
8. MacBook is the canonical physical host; legacy “iMac” references are aliases only.
9. Terminal is recovery/diagnostic, never the normal product workflow.
10. Every regression-prone invariant is CI-checkable.

## Acceptance

`RECOVERY/CHECK_SUPRA_COHERENCE_V1.sh` must return:

- `COHERENCE_SCORE >= 0.9500`
- `STATUS=COHERENCE_GATE_PASS`

The score is a measurable regression gate, not a subjective visual rating. Visual review remains complementary.

## Non-regression

- NO_NEW_ENGINE
- NO_NEW_BRIDGE
- NO_NEW_RUNTIME
- NO_DUPLICATE_TRUTH
- NO_FAKE_PASS
- NO_HUMAN_RELAY
- PRESERVE_ROLLBACK
