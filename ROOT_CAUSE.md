# ROOT_CAUSE.MD — CockpitRuntimeView.swift Compilation Error

## Root Cause
The compilation error is NOT a missing module or dependency issue.  
It is a **simple identifier typo** in `SUPRA/CockpitRuntimeView.swift`:

- Line 5 incorrectly declares `var store: RuntimeDataService` (from legacy SUPRAExecutiveStore).  
- All view body uses `service` which never exists.  
- The file should use `runtimeDataService: RuntimeDataService` (correct environment injection) and consistently reference `runtimeDataService`.

This is a copy-paste artifact from legacy SUPRA architecture that was never cleaned up.

## Evidence

### 1. Source File Inspection
```swift
// SUPRA/CockpitRuntimeView.swift line 5
@property var service: RuntimeDataService  // ❌ TYPO: service never defined
```

### 2. Error Output
```
ERROR [5:48] Cannot find type 'RuntimeDataService' in scope
ERROR [13:16] Cannot find 'service' in scope
ERROR [17:23] Cannot find 'service' in scope
... etc.
```

### 3. Contextual Proof
- Environment injection in `SUPRAOperationalCoreApp.swift` correctly injects `RuntimeDataService`.  
- `CockpitRuntimeView` is used by `ExecutiveCockpitFoundation` which receives runtimeDataService through the dependency chain.  
- No `service` property anywhere else in the codebase.  

## Correct Fix
1. Change line 5 to: `@EnvironmentObject var runtimeDataService: RuntimeDataService`
2. Replace all `service.` references with `runtimeDataService.` in the entire file (lines 13, 17, 24, 30, 40, 87, 183, 188).  
3. Verify no other legacy `service` references remain.

## Build Impact
- **Severity**: HIGH (compilation failure for any developer using Cockpit runtime view)  
- **Effort**: LOW (identifier rename)  
- **Testing**: Minimal (UI cannot function without fix)  

## Validation Procedure
1. Rename identifier: `service` → `runtimeDataService`
2. Ensure all 10 references updated.  
3. Clean build (delete DerivedData).  
4. Run compilation; verify no "Cannot find type" or "Cannot find 'service'" errors.  

## After Fix Verification
- Compilation passes.  
- Runtime cockpit loads correctly.  
- All environment-injected services work as expected.

**Recommendation**: Fix IMMEDIATELY as this blocks all runtime UI development and impossible to preview runtime state.  
