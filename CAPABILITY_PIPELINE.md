# SUPRA Capability Delivery Pipeline

**Version**: V1
**Effective**: 2026-07-29
**Status**: PERMANENT
**Authority**: SUPRA-Architect / SUPRA-Executive
**Precedence**: This document supersedes any ad-hoc development process for capabilities.

---

## 1. Purpose

This pipeline is the permanent delivery process for every SUPRA production capability.
It replaces ad-hoc, one-off development with an industrialized, repeatable, evidence-driven process.

**Core principle**: The Runtime Foundation is never modified by capability delivery.
Capabilities are purely additive — they consume Foundation artifacts but never alter them.

---

## 2. Pipeline Stages

Every capability MUST pass through these 8 stages in order:

```
DISCOVERY → DESIGN → PLANNING → IMPLEMENTATION → VALIDATION → CERTIFICATION → DEPLOYMENT → KNOWLEDGE CAPTURE
```

### Stage 1: DISCOVERY
- **Owner**: SUPRA-Explorer
- **Purpose**: Identify the capability need from user patterns, gaps, or strategic priorities
- **Output**: Capability brief (what users need, why it matters, where the gap is)

### Stage 2: DESIGN
- **Owner**: SUPRA-Architect
- **Purpose**: Define the capability architecture, interfaces, and data models
- **Output**: Capability Design Document (scope, interfaces, data structures, component diagram)

### Stage 3: PLANNING
- **Owner**: SUPRA-Router
- **Purpose**: Break the capability into prioritized, incrementally deliverable milestones
- **Output**: Implementation plan with milestones (M1, M2, ...) and acceptance criteria

### Stage 4: IMPLEMENTATION
- **Owner**: SUPRA-Builder
- **Purpose**: Implement the capability incrementally, one milestone at a time
- **Output**: Source code files, each milestone validated independently (xcodebuild BUILD SUCCEEDED after each)
- **Constraint**: Single Writer Rule — only SUPRA-Builder writes files
- **Constraint**: No modifications to Foundation components (SUPRAEnvironmentResolver, ContinuityManager, ExecutiveBootManager, RuntimeContract, RuntimeFoundation, RuntimeConstitution)

### Stage 5: VALIDATION
- **Owner**: SUPRA-Auditor
- **Purpose**: Verify the capability meets all acceptance criteria with evidence
- **Output**: Validation Report (build, signing, launch, constitutional integrity, hardcoded path audit)

### Stage 6: CERTIFICATION
- **Owner**: SUPRA-Auditor + SUPRA-Architect + Executive
- **Purpose**: Issue the official Capability Certification Report
- **Output**: CAPABILITY_CERTIFICATION_REPORT.md
- **Decision**: CERTIFIED | NOT CERTIFIED (with remediation path)

### Stage 7: DEPLOYMENT
- **Owner**: SUPRA-Builder
- **Purpose**: Make the capability available in the production SUPRA.app
- **Output**: Build artifact on disk, integration into Command Center or target UI

### Stage 8: KNOWLEDGE CAPTURE
- **Owner**: SUPRA-Research / SUPRA-Builder
- **Purpose**: Update the Capability Registry, register learnings, update the pipeline itself
- **Output**: Updated Execution Mode + Capability Registry documents, lessons learned

---

## 3. Governance Rules

### Foundation Protection Rule
**No capability may modify any Foundation component.**
All Foundation components are IMMUTABLE during capability delivery.
If a capability requires a Foundation change, a separate Foundation Amendment must be approved via the Executive Gate first.

### Single Writer Rule
**Only SUPRA-Builder may create or modify files during implementation.**
All other pipeline stages are READ-ONLY — research, analyze, review, certify.

### Evidence Rule
**No capability increments proceed without build-verified evidence.**
Each milestone must produce BUILD SUCCEEDED before the next milestone begins.

### Integrity Rule
**Every capability must leave zero regressions.**
Constitutional component diffs must be 0 at the end of certification.
Hardcoded path audit must be 0 in all new capability files.

### Certification Gate Rule
**No capability is deployed until CERTIFIED.**
The Capability Certification Report must be issued by the Auditor + Architect + Executive before deployment.

### Incremental Delivery Rule
**Capabilities are delivered in increments (M1, M2, M3, ...).**
Each increment is independently validated. No capability is delivered in a single monolithic commit.

---

## 4. Capability Registry

| ID | Capability | Priority | Status | Assigned |
|----|-----------|----------|--------|----------|
| G1 | Unified Project Dashboard | #1 | CERTIFIED | SUPRA-Builder |
| G2 | Automated Health Monitoring | #0 | CERTIFIED | SUPRA-Builder |
| G3 | Export & Reporting | #2 | CERTIFIED | SUPRA-Builder |
| G4 | Integration Dashboard | #3 | CERTIFIED | SUPRA-Builder |
| G5 | Capability Marketplace | #4 | DEFERRED | — |
| G6 | Audit Trail | #5 | READY | SUPRA-Builder |
| G7 | Smart Suggestions | #6 | READY | SUPRA-Builder |
| G8 | Real-Time Collaboration | #7 | DEFERRED | — |

---

## 5. Execution Mode

The pipeline operates in **Execution Mode** — a permanent state where:
- Infrastructure engineering is complete
- The Runtime Foundation V2 is locked and protected
- All engineering effort goes to capability delivery
- Each capability follows the 8-stage pipeline above
- The Execution Mode document (SUPRA_EXECUTION_MODE_V1.md) governs the process

**This is the default mode for all SUPRA sessions.**
