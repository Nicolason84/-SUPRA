# M1 ExportModel — Milestone Definition

**Date**: 2026-07-29
**Milestone**: M1 of G3 Export & Reporting
**Status**: DEFINED — pending implementation
**Governed by**: CAPABILITY_PIPELINE.md V1 + G3_ARCHITECTURE_DISCOVERY.md

---

## 1. Scope

### Deliverable
`SUPRA/ExportModel.swift` — export configuration, format selection, scope selection, options.

### Boundaries
- In scope: Export format enum, export scope enum, export options struct, export configuration struct
- Out of scope: File generation (M2), UI (M3), integration (M4), certification (M5)

---

## 2. Implementation Plan

### M1.1 — ExportFormat enum
Define an enum for export formats:
- case csv
- case json
- case markdown

Each case carries:
- title: String (display name)
- fileExtension: String (csv, json, md)
- contentType: String (text/csv, application/json, text/markdown)

### M1.2 — ExportScope enum
Define an enum for export scope:
- case all
- case health
- case runtime
- case missions
- case intelligence
- case resources

Each case carries:
- title: String (display name)
- icon: String (SF Symbol)

### M1.3 — ExportOptions struct
Define a struct for export options:
- includeTimestamps: Bool (default: true)
- includeDetails: Bool (default: true)
- compactFormat: Bool (default: false)

### M1.4 — ExportConfiguration struct
Define a struct for export configuration:
- format: ExportFormat (default: .json)
- scope: ExportScope (default: .all)
- options: ExportOptions (default: .init())

### M1.5 — ExportModel.swift consolidation
Consolidate all models into a single file with clear MARK sections.

---

## 3. Acceptance Criteria

1. ExportModel.swift compiles (xcodebuild BUILD SUCCEEDED)
2. ExportFormat covers 3 formats (CSV, JSON, Markdown)
3. ExportScope covers 6 scopes (All, Health, Runtime, Missions, Intelligence, Resources)
4. ExportOptions has 3 configurable options
5. ExportConfiguration has correct default values
6. All values are Swift-native (no external dependencies)
7. File is under 80 lines total
8. Zero modifications to any existing file

---

## 4. Validation Commands

```bash
# Build validation
xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -sdk macosx build 2>&1 | grep "BUILD"

# Hardcoded path audit
grep -c '/Users/nicolasalonso' SUPRA/ExportModel.swift
# Expected: 0

# Line count
wc -l SUPRA/ExportModel.swift
# Expected: <= 80
```

---

## 5. File Location

`SUPRA/ExportModel.swift`

---

## 6. Dependencies

| Dependency | Type | Required For |
|-----------|------|-------------|
| Foundation | Framework | Date formatting |
| SwiftUI | Framework | Color (for icon tinting) |
| (none) | State/consumer | Pure data model — no state consumption |

---

## 7. Rollback

Revert the single ExportModel.swift commit:
```bash
git revert <M1-commit-hash>
```
