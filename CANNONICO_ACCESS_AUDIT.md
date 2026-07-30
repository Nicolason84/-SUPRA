# CAnnoNico Access Control Audit

## Phase 1 — All calls to `SUPRACAnnoNicoIntegration.snapshot()`

| File | Caller | Status |
|---|---|---|
| `SUPRA/CAnnoNicoSnapshotStore.swift:52` | `refresh()` → `SUPRACAnnoNicoIntegration.snapshot()` | ✅ LIVE — authorized |
| `_SUPRA_BACKUPS/.../ContentView.swift:1150` | Backup file | ❌ NOT LIVE |
| `.mechanical_extract_backup/.../ContentView.swift:1150` | Backup file | ❌ NOT LIVE |

## Phase 2 — Access level

`snapshot()` is now explicitly `internal static func` — only visible within the module.

## Phase 3 — SnapshotStore is unique entry point

All consumers access CAnnoNico data through `CAnnoNicoSnapshotStore.shared`:
- `SUPRACommandCenterState.swift` → `snapshotStore.state`
- `MultiMemoryStore.swift` → `CAnnoNicoSnapshotStore.shared`
- `SUPRAIntelligenceEngine.swift` → `snapshotStore.$state`
- `MemoryView` → `state.cannonicoSection` → `CommandCenterCannonico(from: snapshotStore)`
- `HealthView` → `state.healthSection` → tower state (indirect)

## Phase 4 — Performance

- TTL cache: 30s (`isStale` computed from `age > 30`)
- `refreshIfNeeded()` — only refreshes when nil or stale
- `currentState` computed property — returns cached if fresh
- Combine publishers — views update only on state change
- Intelligence engine hash-guarded — no recompute on same state

## Conclusion

✅ CAnnoNicoIntegrationBridge is internal-only, consumed exclusively by SnapshotStore
✅ No direct UI access to adapters or integration
✅ Cache enforced, no permanent scanning
✅ Build OK — no changes to consumers required
