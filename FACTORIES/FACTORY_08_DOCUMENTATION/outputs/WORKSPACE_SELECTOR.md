# WORKSPACE SELECTOR — V1

## Status: CERTIFIED

| Property | Value |
|----------|-------|
| **Version** | WS_SELECTOR_V1 |
| **Date** | 2026-07-29 |
| **Authority** | FACTORY_10_EXECUTIVE |

---

## 1. SELECTION CRITERIA

The Executive Boot workspace selector automatically finds the correct Xcode workspace.

### Rule 1: Canonical Project Path

Search order:
1. `$REPO_ROOT/SUPRA.xcodeproj` — primary project
2. `$REPO_ROOT/*.xcodeproj` — fallback glob (alphabetical first)

### Rule 2: Workspace Selection

For the selected project:
1. `$PROJECT/project.xcworkspace` — embedded workspace (canonical)
2. `$REPO_ROOT/*.xcworkspace` — standalone workspace (fallback)

### Rule 3: Single Decision

If exactly one workspace is found, it is selected.
If multiple workspaces exist, the canonical embedded workspace takes priority.
If no workspace exists, boot reports the issue and halts.

---

## 2. CURRENT SELECTION

| Property | Value |
|----------|-------|
| Repository Root | `/Users/nicolasalonso/Desktop/NOVA_OS/SUPRA` |
| Xcode Project | `SUPRA.xcodeproj` |
| Xcode Workspace | `SUPRA.xcodeproj/project.xcworkspace` |
| Selection Reason | Canonical embedded workspace — single project |

---

## 3. CERTIFICATION

| Criterion | Status |
|-----------|--------|
| Project exists | PASS — SUPRA.xcodeproj |
| Workspace exists | PASS — project.xcworkspace |
| Single project | PASS — no ambiguity |
| Hardcoded paths | NONE — all relative discovery |

---

## 4. MULTIPLE WORKSPACE HANDLING

If multiple workspaces are detected in the future:

```bash
# Discovery logic
projects=( "$REPO_ROOT"/*.xcodeproj )
workspaces=( "$REPO_ROOT"/*.xcworkspace )

# Priority: embedded workspace > standalone > alphabetical
```

The selector always explains its choice with:
- Count of discovered projects
- Count of discovered workspaces
- Selection rationale

---

**END OF WORKSPACE SELECTOR V1**
