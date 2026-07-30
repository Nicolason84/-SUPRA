# FACTORY_05_MEMORY — Specification V1

## Mission

Maintain complete continuity.

## Responsibility

Preserve all state across sessions. Consolidate conversations, missions, and snapshots. Maintain executive memory for continuity across sessions.

## Owner

SUPRA-Auditor / SUPRA-Builder

## Inputs

| Input | Source | Format |
|-------|--------|--------|
| Session history | .opencode/memory | JSON/Markdown |
| Mission records | _MISSIONS | Markdown |
| Snapshots | _FOUNDATION_MEMORY | JSON |
| All factory outputs | All FACTORIES | Various |

## Outputs

| Output | Format | Description |
|--------|--------|-------------|
| MEMORY_STATE.json | JSON | Complete memory state: all sessions, missions, snapshots |
| MISSION_HISTORY.md | Markdown | Consolidated history of all missions |
| SESSION_INDEX.md | Markdown | Index of all sessions with timestamps and outcomes |

## Gates

### INPUT Gate
- All upstream factory outputs are certified
- Memory directory is accessible
- Previous memory state exists

### EXECUTION Gate
- Session boundary is defined
- Consolidation strategy is documented

### OUTPUT Gate
- Every mission from the session is indexed
- Memory state is internally consistent
- Previous state is preserved (append-only)
- Zero data loss

## Quality Criteria

1. **Completeness**: Every session recorded
2. **Continuity**: Every mission links to its predecessor/successor
3. **Persistence**: No data loss across sessions
4. **Integrity**: Memory state is verifiable

## Templates

See `templates/` directory for output artefact templates.

## Automation

See `gates/` directory for gate validation scripts.
