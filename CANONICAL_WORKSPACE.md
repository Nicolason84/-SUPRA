# CANONICAL WORKSPACE — V1

## Status: CERTIFIED

| Property | Value |
|----------|-------|
| **Version** | CANONICAL_WS_V1 |
| **Date** | 2026-07-29 |
| **Authority** | FACTORY_01_ARCHITECTURE |

---

## 1. DISCOVERY RESULTS

### Xcode Workspaces

| # | Path | Type |
|---|------|------|
| 1 | `SUPRA.xcodeproj/project.xcworkspace` | Embedded workspace |

**Total: 1 workspace**

### Xcode Projects

| # | Path | Type |
|---|------|------|
| 1 | `SUPRA.xcodeproj` | Application (macOS) |

**Total: 1 project**

### Swift Packages

| # | Path | Products |
|---|------|----------|
| 1 | `Packages/CAnnoNicoIntegrationPackage/` | CAnnoNicoContracts, PucheroMemoryAdapter, NicoAppAdapter, VideoSwapAdapter |
| 2 | `SUPRA_AST_PLATFORM/` | SUPRAAST (library), supra-ast (CLI) |

**Total: 2 Swift packages**

---

## 2. TARGET ANALYSIS

### SUPRA (Application)

| Property | Value |
|----------|-------|
| **Target Type** | Application (`com.apple.product-type.application`) |
| **Product** | SUPRA.app |
| **Bundle ID** | com.nicolasalonso.SUPRA |
| **Platform** | macOS (macOS 26.5) |
| **Architecture** | arm64 |
| **Swift Version** | 5.0 |
| **Sources** | File-system synchronized from SUPRA/ |
| **Dependencies** | CAnnoNicoIntegration (local package) |

### SUPRATests (Unit Tests)

| Property | Value |
|----------|-------|
| **Target Type** | Unit test bundle (`com.apple.product-type.bundle.unit-test`) |
| **Product** | SUPRATests.xctest |
| **Bundle ID** | com.novasupra.SUPRATests |
| **Test Host** | SUPRA.app |
| **Sources** | File-system synchronized from SUPRATests/ |

---

## 3. CANONICAL WORKSPACE SELECTION

**Canonical workspace: `SUPRA.xcodeproj/project.xcworkspace`**

### Selection Rationale

| Factor | Decision |
|--------|----------|
| Single workspace | Only 1 workspace exists — no ambiguity |
| Embedded workspace | Embedded within SUPRA.xcodeproj (canonical pattern) |
| Single project | Only 1 Xcode project — SUPRA.xcodeproj |
| Local packages | Both packages resolved via Xcode dependency resolution |

### Build Command

```
xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -destination 'platform=macOS' build
```

---

## 4. EXECUTABLE & APPLICATION TARGETS

| Target | Type | Path |
|--------|------|------|
| SUPRA | macOS Application | SUPRA.xcodeproj |
| supra-ast | CLI Executable | SUPRA_AST_PLATFORM (Package.swift) |

---

## 5. CERTIFICATION

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Workspace discovered | CERTIFIED | Exactly 1 embedded workspace |
| Project discovered | CERTIFIED | Exactly 1 .xcodeproj |
| Packages discovered | CERTIFIED | 2 Swift packages |
| No ambiguity | CERTIFIED | Single candidate |
| Build command verified | CERTIFIED | xcodebuild returns BUILD SUCCEEDED |

---

**END OF CANONICAL WORKSPACE V1**
