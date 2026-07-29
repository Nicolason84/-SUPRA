# G3 Gap Analysis

**Date**: 2026-07-29
**Phase**: 3 — Gap Analysis
**Status**: PLANNED

---

## 1. Existing Capabilities (Already Present)

| Element | Location | Status | Reuse Action |
|---------|----------|--------|-------------|
| `SUPRACommandCenterState` | SUPRACommandCenterState.swift | EXISTING | Consume — data source |
| `DashboardCoordinator` | DashboardCoordinator.swift | EXISTING | Consume — data access layer |
| `G1DashboardView` | G1DashboardView.swift | EXISTING | Integrate — add export button |
| `CommandCenterSnapshot` | SUPRACommandCenterState.swift | EXISTING | Read — export data structure |
| `CommandCenterSystemHealth` | SUPRACommandCenterState.swift | EXISTING | Read — health export |
| `CommandCenterMissions` | SUPRACommandCenterState.swift | EXISTING | Read — missions export |
| `CommandCenterResources` | SUPRACommandCenterState.swift | EXISTING | Read — resources export |
| `CommandCenterRuntime` | SUPRACommandCenterState.swift | EXISTING | Read — runtime export |
| `CommandCenterIntelligence` | SUPRACommandCenterState.swift | EXISTING | Read — intelligence export |
| `SUPRAOSCard` | SUPRAOSDesignSystem.swift | EXISTING | Reuse — card container |
| `NSSavePanel` pattern | ProtectedFolderAccessCoordinator.swift | EXISTING | Replicate — file save dialog |
| `FileManager.createFile` | ContentView.swift | EXISTING | Replicate — file creation |
| `SUPRAOSDesignSystem` tokens | SUPRAOSDesignSystem.swift | EXISTING | Reference — all design tokens |

---

## 2. Reusable Patterns

| Pattern | Source | Application | Abstraction Needed? |
|---------|--------|-------------|---------------------|
| NSSavePanel for file save | ProtectedFolderAccessCoordinator.swift | Export file save dialog | NO — replicate directly |
| FileManager.createFile | ContentView.swift | Export file creation | NO — replicate directly |
| JSONEncoder for serialization | Foundation | JSON export format | NO — use directly |
| String writing | ArtifactReader.swift | Text/CSV export format | NO — replicate directly |
| @EnvironmentObject | Existing views | State injection | NO — reuse directly |
| @StateObject | ContentView.swift | Local state | NO — reuse directly |
| SUPRAOSCard | SUPRAOSDesignSystem.swift | Export UI container | NO — reuse directly |
| .onAppear | Existing views | Export trigger | NO — reuse directly |

---

## 3. Requires Extension

| Element | Current State | Required Extension | Reason | Abstraction Needed? |
|---------|--------------|-------------------|--------|---------------------|
| Export format selection | No format selection exists | New picker for CSV/JSON/Markdown | Users need to choose format | NO — simple enum picker |
| Export scope selection | No scope selection exists | New picker for data sections | Users need to choose what to export | NO — simple enum picker |
| Export options | No export options exist | New toggles for timestamps, details | Users need export customization | NO — simple toggles |
| Export progress | No progress indicator exists | New progress view | Users need feedback during export | NO — simple progress bar |
| Export preview | No preview exists | New preview panel | Users need to see what will be exported | NO — simple text view |

---

## 4. New Implementation

| Element | Purpose | Size Estimate | Dependency |
|---------|---------|---------------|------------|
| `ExportModel.swift` | Format/scope/options configuration | ~60 lines | None |
| `ExportService.swift` | File generation (CSV, JSON, Markdown) | ~120 lines | ExportModel, DashboardCoordinator |
| `ExportView.swift` | Export UI with format/scope/options/progress/preview | ~100 lines | ExportModel, ExportService, DashboardCoordinator |
| Integration into `G1DashboardView.swift` | Add export button to header | ~5 lines | ExportView |

---

## 5. Gap Summary

| Category | Count | Details |
|----------|-------|---------|
| Existing (reuse) | 13 | Views, state models, UI components, design tokens, runtime services |
| Reusable patterns | 8 | NSSavePanel, FileManager, JSONEncoder, @EnvironmentObject, etc. |
| Requires extension | 5 | Format picker, scope picker, options toggles, progress, preview |
| New implementation | 4 | ExportModel, ExportService, ExportView, integration |
| New abstractions | 0 | No new frameworks, protocols, or services |
| Foundation modifications | 0 | No Runtime component changes |

---

## 6. Key Finding

The gap between the existing codebase and G3 Export & Reporting is entirely within **UI composition and file generation**. Every data model, every state source, and every file operation pattern is already present. The only new elements are:

1. An `ExportModel` for configuration
2. An `ExportService` for file generation
3. An `ExportView` for the export UI
4. Integration wiring to add export button to DashboardView

No new architectures, abstractions, protocols, services, or Foundation modifications are required.
