# NEXT UX SPRINT — SUPRA UX SPRINT 02

**Date**: 2026-07-29
**Authority**: SUPRA Executive
**Predecessor**: UX SPRINT 01 — From Runtime to Product

---

## MISSION BRIEF

UX SPRINT 01 addressed the foundational UX issues: loading states, animations, keyboard navigation, feedback, and visual hierarchy.

UX SPRINT 02 should focus on **depth of experience** — making the application not just visually polished but genuinely delightful to use throughout a full workflow.

---

## RECOMMENDED PHASES

### PHASE 1 — ContentView Retirement
**Priority**: HIGH
**Description**: The legacy `ContentView.swift` (1177+ lines) still exists alongside the new `ExecutiveWindow` architecture. It uses old color scheme (`Color(nsColor: .windowBackgroundColor)`) and has no UX improvements.

**Tasks**:
- Audit all references to `ContentView` across the codebase
- Either migrate remaining functionality to ExecutiveWindow or remove
- Delete the file once confirmed unused
- Verify no compilation breaks

### PHASE 2 — Window State Persistence
**Priority**: HIGH
**Description**: SUPRA should remember:
- Window position and size between launches
- Last selected sidebar space
- Inspector open/closed state
- Sidebar collapsed/expanded state

**Tasks**:
- Store window frame in UserDefaults
- Restore on launch
- Persist sidebar selection

### PHASE 3 — Drag & Drop
**Priority**: MEDIUM
**Description**: Allow users to:
- Drag files from Finder into SUPRA
- Reorder sidebar items
- Drag items between spaces

**Tasks**:
- Add `.onDrop` to workspace view
- Handle file URLs
- Visual drop target highlight

### PHASE 4 — Context Menus
**Priority**: MEDIUM
**Description**: Right-click menus on:
- Sidebar items (copy name, reveal in Finder)
- Mission rows (duplicate, delete, share)
- Inspector fields (copy value)

**Tasks**:
- Add `.contextMenu` to interactive items
- Define menu actions per item type

### PHASE 5 — Search Experience
**Priority**: MEDIUM
**Description**: Global search (⌘F) across:
- Missions
- Decisions
- Knowledge
- Workspace items
- Settings

**Tasks**:
- Unified search bar in header
- Result categories
- Keyboard navigation in results

### PHASE 6 — Accessibility Deep Dive
**Priority**: MEDIUM
**Description**: Full VoiceOver audit:
- All buttons need accessibility labels
- Custom views need `accessibilityElement()`
- Focus management
- Dynamic Type adaptation
- Reduced motion support

**Tasks**:
- Audit with VoiceOver enabled
- Add `accessibilityLabel` to all controls
- Test with `Accessibility Inspector`
- Add `@Environment(\.accessibilityReduceMotion)` support

### PHASE 7 — Touch Bar Support
**Priority**: LOW
**Description**: MacBook Pro Touch Bar shortcuts for:
- Space navigation
- Common actions (refresh, search, command palette)

**Tasks**:
- Add `.touchBar` items
- Group by context

### PHASE 8 — Responsive Layout
**Priority**: LOW
**Description**: Better adaptation to window resizing:
- Sidebar auto-collapse at narrow widths
- Grid → list adaptation for KPI cards
- Inspector auto-hide at medium widths

**Tasks**:
- Use `GeometryReader` for adaptive layouts
- Define breakpoints
- Test at various window sizes

### PHASE 9 — Micro-Interaction Polish
**Priority**: LOW
**Description**: Additional micro-interactions:
- Haptic feedback on state changes (where appropriate)
- Progress bar entry animation
- Counter increment animation
- Status dot breathing animation

### PHASE 10 — Onboarding
**Priority**: LOW
**Description**: First-launch experience:
- Welcome sheet on first boot
- Quick tour of spaces
- Tooltip hints on first visit

**Tasks**:
- Detect first launch via UserDefaults
- Onboarding view with page indicators
- "Skip tour" option

---

## DEFINITION OF DONE FOR UX SPRINT 02

- [ ] ContentView fully removed or migrated
- [ ] Window state persisted across launches
- [ ] Drag & drop from Finder works
- [ ] Context menus on all interactive items
- [ ] Global search functional
- [ ] VoiceOver audit passed
- [ ] Touch Bar shortcuts available
- [ ] Layout adapts to window size
- [ ] Additional micro-interactions in place
- [ ] Onboarding flow ready

---

## ESTIMATED EFFORT

| Phase | Effort | Complexity |
|-------|--------|------------|
| ContentView Retirement | 2h | Medium |
| Window State Persistence | 3h | Low |
| Drag & Drop | 4h | Medium |
| Context Menus | 2h | Low |
| Search Experience | 6h | High |
| Accessibility Deep Dive | 4h | Medium |
| Touch Bar Support | 2h | Low |
| Responsive Layout | 3h | Medium |
| Micro-Interaction Polish | 3h | Low |
| Onboarding | 4h | Medium |
| **TOTAL** | **33h** | |

---

## IMMEDIATE NEXT STEP

1. Confirm that UX SPRINT 01 meets Definition of Done
2. Verify no architecture was modified
3. Remove `ContentView.swift` if safe
4. Begin UX SPRINT 02 with Phase 1
