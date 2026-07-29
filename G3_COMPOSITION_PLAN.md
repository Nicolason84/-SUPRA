# G3 Composition Plan

**Date**: 2026-07-29
**Phase**: 2 — Composition Plan
**Status**: PLANNED

---

## 1. Export Sections

| Section | Existing Reusable Component | New Component Required | Runtime Dependency | State Dependency | Artifact Dependency |
|---------|----------------------------|----------------------|-------------------|-----------------|-------------------|
| **Export Configuration** | None | `ExportModel` (new — format selection, scope, options) | None | None | None |
| **Export Service** | None | `ExportService` (new — file generation for CSV, JSON, Markdown) | SUPRAEnvironmentResolver | SUPRACommandCenterState | None |
| **Export UI** | `SUPRAOSCard`, `SUPRAOSStatCard` | `ExportView` (new — format picker, scope selector, progress, preview) | None | ExportModel, ExportService | None |
| **File Save** | `NSSavePanel` pattern (ProtectedFolderAccessCoordinator) | Reuse NSSavePanel for file save dialog | None | None | None |
| **Export Integration** | `G1DashboardView` | Add export button to dashboard header | None | DashboardCoordinator | None |

---

## 2. Composition Rules

### Rule 1: Compose, Do Not Replace
Every existing view and service is reused exactly as-is. No modifications to existing files except additive integration.

### Rule 2: Additive Integration Only
G3 adds new files and one integration line to G1DashboardView. No existing view is modified.

### Rule 3: Single Writer
Only SUPRA-Builder writes files. All other phases are READ-ONLY.

### Rule 4: Foundation Immutable
No Foundation component is modified.

### Rule 5: Design System Compliance
All spacing, padding, colors, fonts reference SUPRAOSDesignSystem.*. No hardcoded values.

### Rule 6: Data Access Pattern
ExportService consumes DashboardCoordinator for data access. No new state objects.

---

## 3. Component Hierarchy

```
ExportView (NEW)
 ├── Format Picker (CSV / JSON / Markdown)
 ├── Scope Selector (All / Health / Runtime / Missions / Intelligence)
 ├── Options (include timestamps, include details, compression)
 ├── Preview (sample of export data)
 ├── Progress Indicator
 └── Export Button → NSSavePanel → ExportService
```

---

## 4. Runtime Dependencies

| Dependency | Type | Consumed By | Modification |
|-----------|------|-------------|-------------|
| SUPRAEnvironmentResolver.shared | Service | ExportService (file path) | CONSUME ONLY |
| SUPRACommandCenterState.shared | State | ExportService (data source) | CONSUME ONLY |
| DashboardCoordinator | Coordinator | ExportView (data access) | CONSUME ONLY |

---

## 5. Design System Dependencies

| Token | Usage |
|-------|-------|
| `SUPRAOSDesignSystem.spacing` | Standard spacing |
| `SUPRAOSDesignSystem.spacingSmall` | Grid spacing |
| `SUPRAOSDesignSystem.padding` | Outer padding |
| `SUPRAOSDesignSystem.paddingSmall` | Card padding |
| `SUPRAOSDesignSystem.cornerRadiusSmall` | Card corners |
| `SUPRAOSDesignSystem.colors.supraAccent` | Export button accent |
| `SUPRAOSDesignSystem.colors.supraGreen` | Success indicator |
| `SUPRAOSDesignSystem.colors.supraOrange` | Progress indicator |
| `SUPRAOSDesignSystem.Fonts.body` | Body text |
| `SUPRAOSDesignSystem.Fonts.bodySmall` | Labels |

---

## 6. Composition Validation Checklist

- [x] All existing views reused as-is
- [x] G3 adds new files only (ExportModel, ExportService, ExportView)
- [x] No Foundation component modified
- [x] Data access via DashboardCoordinator (existing)
- [x] All layout uses SUPRAOSDesignSystem tokens
- [x] NSSavePanel pattern reused from ProtectedFolderAccessCoordinator
- [x] Additive integration only (export button in G1DashboardView)
- [x] No hardcoded paths in any G3 file
