# SUPRA Capability Prioritized Matrix

**Date**: 2026-07-29
**Status**: ACTIVE
**Governed by**: CAPABILITY_PIPELINE.md V1

---

## 1. Capability Registry (Updated)

| ID | Capability | Priority | Status | Assigned |
|----|-----------|----------|--------|----------|
| G1 | Unified Project Dashboard | #1 | CERTIFIED (frozen) | SUPRA-Builder |
| G2 | Automated Health Monitoring | #0 | CERTIFIED (frozen) | SUPRA-Builder |
| G3 | Export & Reporting | #2 | NEXT | SUPRA-Builder |
| G4 | Integration Dashboard | #3 | CERTIFIED (frozen) | SUPRA-Builder |
| G5 | Capability Marketplace | #4 | DEFERRED | — |
| G6 | Audit Trail | #5 | READY | SUPRA-Builder |
| G7 | Smart Suggestions | #6 | READY | SUPRA-Builder |
| G8 | Real-Time Collaboration | #7 | DEFERRED | — |

---

## 2. Prioritized Capability Matrix

### Scoring Method
Each capability scored 1-10 on six dimensions:
- **User Value** (UV): Direct benefit to end users
- **Business Value** (BV): Strategic/compliance value
- **Implementation Effort** (IE): 1=easy, 10=very complex
- **Technical Risk** (TR): 1=low, 10=high
- **Runtime Dependencies** (RD): Number of new dependencies (0=none, 10=many)
- **Constitutional Compatibility** (CC): 10=full, 0=incompatible

**Composite Score** = (UV × BV) / (IE × TR / 10) × (CC / 10)

| ID | Capability | UV | BV | IE | TR | RD | CC | Score | Rank |
|----|-----------|----|----|----|----|----|----|-------|------|
| G3 | Export & Reporting | 8 | 8 | 4 | 2 | 0 | 10 | 8.0 | **1** |
| G4 | Integration Dashboard | 7 | 7 | 5 | 3 | 0 | 10 | 3.3 | 2 |
| G6 | Audit Trail | 6 | 7 | 4 | 2 | 0 | 10 | 5.3 | 3 |
| G7 | Smart Suggestions | 7 | 5 | 7 | 6 | 2 | 8 | 0.7 | 4 |
| G5 | Capability Marketplace | 8 | 7 | 8 | 7 | 3 | 7 | 0.7 | 5 |
| G8 | Real-Time Collaboration | 8 | 7 | 9 | 8 | 4 | 6 | 0.5 | 6 |

---

## 3. Capability Details

### G3 — Export & Reporting
- **User Value**: HIGH — users need to export dashboard data for external reporting, compliance, and sharing
- **Business Value**: HIGH — enables regulatory compliance, stakeholder reporting, external integration
- **Implementation Effort**: MEDIUM — uses existing data models (SUPRACommandCenterState), adds export UI and file generation
- **Technical Risk**: LOW — no new Foundation dependencies, no AI/ML, straightforward UI work
- **Runtime Dependencies**: 0 new — consumes existing SUPRACommandCenterState and SUPRAEnvironmentResolver
- **Constitutional Compatibility**: FULL — no Foundation modifications

### G4 — Integration Dashboard
- **User Value**: MEDIUM — centralizes third-party integration status
- **Business Value**: MEDIUM — useful for monitoring external service health
- **Implementation Effort**: MEDIUM — composes existing integration views
- **Technical Risk**: MEDIUM — depends on external service availability
- **Runtime Dependencies**: 0 new — consumes existing RuntimeGateway
- **Constitutional Compatibility**: FULL — no Foundation modifications

### G6 — Audit Trail
- **User Value**: MEDIUM — provides compliance history and change tracking
- **Business Value**: HIGH — essential for regulatory compliance
- **Implementation Effort**: MEDIUM — uses existing mission/event data
- **Technical Risk**: LOW — read-only data presentation
- **Runtime Dependencies**: 0 new — consumes existing mission/event stores
- **Constitutional Compatibility**: FULL — no Foundation modifications

### G7 — Smart Suggestions
- **User Value**: MEDIUM — AI-powered recommendations
- **Business Value**: LOW — nice-to-have, not critical
- **Implementation Effort**: HIGH — requires AI/ML integration
- **Technical Risk**: HIGH — new AI dependencies, model selection, prompt engineering
- **Runtime Dependencies**: 2 new — AI model integration, suggestion engine
- **Constitutional Compatibility**: HIGH — no Foundation modifications, but adds complexity

### G5 — Capability Marketplace
- **User Value**: HIGH — enables capability sharing and discovery
- **Business Value**: MEDIUM — ecosystem growth
- **Implementation Effort**: HIGH — requires marketplace infrastructure
- **Technical Risk**: HIGH — new marketplace engine, package management
- **Runtime Dependencies**: 3 new — marketplace engine, package registry, distribution
- **Constitutional Compatibility**: HIGH — no Foundation modifications, but adds complexity

### G8 — Real-Time Collaboration
- **User Value**: HIGH — enables team collaboration
- **Business Value**: MEDIUM — enterprise feature
- **Implementation Effort**: VERY HIGH — requires WebSocket, conflict resolution, presence
- **Technical Risk**: VERY HIGH — complex distributed system
- **Runtime Dependencies**: 4 new — WebSocket server, conflict resolution, presence, sync
- **Constitutional Compatibility**: MODERATE — no Foundation modifications, but significant complexity

---

## 4. Recommendation

### Next Capability: G3 — Export & Reporting

**Rank**: #1 (Score: 8.0/10)

**Justification**:
1. Highest composite score among remaining capabilities
2. User value: HIGH — directly addresses user need for data export
3. Business value: HIGH — enables compliance and external reporting
4. Implementation effort: MEDIUM — uses existing data models
5. Technical risk: LOW — no new dependencies, no AI/ML
6. Runtime dependencies: 0 new — consumes existing services
7. Constitutional compatibility: FULL — no Foundation modifications
8. Dependencies: G1 + G2 (both CERTIFIED) — fully satisfied

**Estimated Milestones**:
- M1: ExportModel — data export configuration, format selection (~60 lines)
- M2: ExportService — file generation (CSV, JSON, PDF) (~120 lines)
- M3: ExportView — export UI with format selection, progress, preview (~100 lines)
- M4: Integration — integrate into G1DashboardView (~20 lines)
- M5: Certification — validation, documentation, production readiness

**Success Criteria**:
- BUILD SUCCEEDED after each milestone
- Export produces valid CSV, JSON, and PDF files
- Export UI integrates into Dashboard
- Zero Foundation modifications
- Zero hardcoded paths
- Zero regressions
- Certification report published

---

## 5. Next Steps

1. G3 — Export & Reporting selected as next capability
2. Begin Architecture Discovery for G3
3. Follow 8-stage Capability Pipeline
4. Deliver incrementally (M1→M5)
5. Certify and freeze
6. Repeat for next capability

---

*This matrix is the authoritative source for capability prioritization.*
*Updated: 2026-07-29*
