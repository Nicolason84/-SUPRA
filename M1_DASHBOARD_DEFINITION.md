# M1 Dashboard Models — Milestone Definition

**Date**: 2026-07-29
**Milestone**: M1 of G1 Unified Project Dashboard
**Status**: DEFINED — pending implementation
**Governed by**: CAPABILITY_PIPELINE.md V1 + G1_ARCHITECTURE_DISCOVERY.md

---

## 1. Scope

### Deliverable
`SUPRA/DashboardModels.swift` — layout configuration, view registry, grid configuration for the unified dashboard.

### Boundaries
- In scope: Dashboard layout enums, section identifiers, grid column configuration, section ordering, section metadata
- Out of scope: View implementations (M3), state management (M2), integration (M4), polishing (M5)

---

## 2. Implementation Plan

### M1.1 — DashboardSection enum
Define an enum that identifies every dashboard section:
- case systemHealth
- case runtime
- case memory
- case missions
- case intelligence
- case healthAlerts

Each case carries:
- title: String
- icon: String
- color: Color (from SUPRAOSDesignSystem)
- sortOrder: Int

### M1.2 — DashboardGridLayout struct
Define a struct for grid configuration:
- columns: [GridItem] (adaptive, minimum 260pt — matching CommandCenterView pattern)
- spacing: CGFloat (use SUPRAOSDesignSystem.spacingSmall = 12pt)
- sectionSpacing: CGFloat (use SUPRAOSDesignSystem.spacing = 20pt)

### M1.3 — DashboardSectionOrder static
Define static ordered list of sections:
- static let defaultOrder: [DashboardSection]
- Returns sections in priority order for the grid layout

### M1.4 — DashboardHeaderConfig struct
Define header configuration:
- title: String ("SUPRA Dashboard")
- subtitle: String ("Unified project overview")
- showLiveIndicator: Bool (true)
- showStatusStrip: Bool (true)

### M1.5 — DashboardModels.swift consolidation
Consolidate all models into a single file with clear MARK sections.

---

## 3. Acceptance Criteria

1. DashboardModels.swift compiles (xcodebuild BUILD SUCCEEDED)
2. DashboardSection enum covers all 6 sections
3. DashboardGridLayout matches CommandCenterView grid pattern
4. DashboardSectionOrder provides correct default ordering
5. DashboardHeaderConfig has correct default values
6. All values reference SUPRAOSDesignSystem tokens (no hardcoded values)
7. File is under 80 lines total
8. Zero modifications to any existing file

---

## 4. Validation Commands

```bash
# Build validation
xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -sdk macosx build 2>&1 | grep "BUILD"

# Hardcoded path audit
grep -c '/Users/nicolasalonso' SUPRA/DashboardModels.swift
# Expected: 0

# Line count
wc -l SUPRA/DashboardModels.swift
# Expected: <= 80
```

---

## 5. File Location

`SUPRA/DashboardModels.swift`

---

## 6. Dependencies

| Dependency | Type | Required For |
|-----------|------|-------------|
| SwiftUI | Framework | ViewBuilder, Color, GridItem |
| SUPRAOSDesignSystem | Design tokens | spacing, colors, fonts |
| (none) | State/consumer | Pure data model — no state consumption |

---

## 7. Rollback

Revert the single DashboardModels.swift commit:
```bash
git revert <M1-commit-hash>
```
