# M1 G4Models — Milestone Definition

**Date**: 2026-07-29
**Milestone**: M1 of G4 Integration Dashboard
**Status**: DEFINED — pending implementation
**Governed by**: CAPABILITY_PIPELINE.md V1 + G4_ARCHITECTURE_DISCOVERY.md

---

## 1. Scope

### Deliverable
`SUPRA/G4Models.swift` — integration status data models for the Integration Dashboard.

### Boundaries
- In scope: Integration status enums, service status structs, aggregated status model
- Out of scope: View implementations (M2), integration (M3), certification (M4)

---

## 2. Implementation Plan

### M1.1 — IntegrationServiceType enum
Define an enum for integration service types:
- case gateway
- case runtime
- case providers
- case memory
- case events

Each case carries:
- title: String (display name)
- icon: String (SF Symbol)

### M1.2 — ServiceConnectionStatus enum
Define an enum for connection status:
- case connected
- case disconnected
- case degraded
- case unknown

Each case carries:
- icon: String (SF Symbol)
- color: String (color name)

### M1.3 — IntegrationServiceStatus struct
Define a struct for individual service status:
- type: IntegrationServiceType
- isConnected: Bool
- statusText: String
- detailText: String?
- lastUpdated: Date?

### M1.4 — IntegrationDashboardSnapshot struct
Define a struct for aggregated integration status:
- services: [IntegrationServiceStatus]
- overallHealth: String
- lastUpdated: Date

### M1.5 — G4Models.swift consolidation
Consolidate all models into a single file with clear MARK sections.

---

## 3. Acceptance Criteria

1. G4Models.swift compiles (xcodebuild BUILD SUCCEEDED)
2. IntegrationServiceType covers 5 service types
3. ServiceConnectionStatus covers 4 states
4. IntegrationServiceStatus has all required properties
5. IntegrationDashboardSnapshot aggregates all services
6. All values are Swift-native (no external dependencies)
7. File is under 100 lines total
8. Zero modifications to any existing file

---

## 4. Validation Commands

```bash
# Build validation
xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -sdk macosx build 2>&1 | grep "BUILD"

# Hardcoded path audit
grep -c '/Users/nicolasalonso' SUPRA/G4Models.swift
# Expected: 0

# Line count
wc -l SUPRA/G4Models.swift
# Expected: <= 100
```

---

## 5. File Location

`SUPRA/G4Models.swift`

---

## 6. Dependencies

| Dependency | Type | Required For |
|-----------|------|-------------|
| Foundation | Framework | Date formatting |
| SwiftUI | Framework | Color (for icon tinting) |
| (none) | State/consumer | Pure data model — no state consumption |

---

## 7. Rollback

Revert the single G4Models.swift commit:
```bash
git revert <M1-commit-hash>
```
