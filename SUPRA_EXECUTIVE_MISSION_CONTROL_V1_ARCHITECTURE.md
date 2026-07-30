# SUPRA Executive Mission Control V1

## Decision

Executive Mission Control is the canonical structured supervision surface for
engineering agents. It extends `MissionCenterView`; it does not replace or
redesign the Executive Shell or Runtime.

## Runtime contract

The configured root is `executiveRuntimePath`, falling back to
`<process working directory>/.runtime`.

```text
.runtime/
├── runtime.json
├── alerts.json
├── events.json                 # or events/*.json
├── agents/
│   └── <agent_id>.json
├── missions/
│   └── <mission_id>.json
└── freeze/
    └── current_freeze.json
```

Dates use ISO-8601. Progress uses the closed interval `0...1`. Writers publish
complete snapshots atomically. File names and identifiers are stable.

Every agent snapshot contains:

`agent_id`, `agent_name`, `provider_id`, `role`, `current_task`,
`current_phase`, `progress`, `status`, `last_update`, `current_file`,
`files_modified`, `tests_running`, `tests_passed`, `tests_failed`, `warnings`,
`errors`, `eta`, `branch`, `build_status`, `freeze_status`, `heartbeat`.

## Provider boundary

Providers conform to `ExecutiveProviderAdapter`, which composes:

- `ExecutiveAgentStatePublishing`
- `ExecutiveHeartbeatPublishing`

The Mission Control store has no Codex, OpenCode, Ollama, Xcode, Claude,
Gemini, Cursor or local-worker dependency. Provider identity is data.

## Data flow

```text
Provider adapter
  → atomic structured snapshot/event publication
  → .runtime canonical files
  → one ExecutiveMissionControlStore
  → @Published immutable snapshots
  → ExecutiveMissionControlView
```

The consumer uses file-system change notifications for reloads. One five-second
heartbeat clock evaluates liveness. There is no Terminal polling, console
parsing, screen scraping, OCR, Accessibility, AppleScript or manual refresh.

## Alert rules

The engine derives and deduplicates:

- build failed / succeeded
- agent timeout
- heartbeat timeout
- permission popup detected (structured warning)
- Runtime crash
- duplicate writers
- merge conflict
- regression
- missing Freeze

Published `alerts.json` entries and derived alerts share the same presentation
pipeline. Derived alert identifiers are deterministic, so repeated heartbeat
evaluation does not duplicate state.

## Timeline

`events.json` or `events/*.json` carries chronological
`ExecutiveRuntimeEvent` records. Mission Control sorts them newest-first for
display while retaining their source timestamps and evidence references.

## Single-writer boundary

Mission Control is read-only with respect to `.runtime`. Runtime/provider
adapters own publication. The UI store never modifies agent, mission, event,
alert or Freeze files.

## Validation

| Evidence | Result |
|---|---|
| Debug application build | PASS |
| Two simulated agents | PASS |
| Codex/Ollama provider interchange | PASS |
| Heartbeat freshness | PASS |
| Mission progress | PASS |
| Timeline ordering | PASS |
| Complete alert matrix | PASS |
| Alert deduplication | PASS |
| Terminal/screen automation | NONE |

Commands:

```text
xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug \
  -derivedDataPath /private/tmp/SUPRA_MISSION_CONTROL_DERIVED \
  CODE_SIGNING_ALLOWED=NO build

xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug \
  -derivedDataPath /private/tmp/SUPRA_MISSION_CONTROL_DERIVED \
  CODE_SIGNING_ALLOWED=NO \
  -only-testing:SUPRATests/ExecutiveMissionControlTests test
```

Both completed successfully on 2026-07-27.
