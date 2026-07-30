# NEXT EXECUTIVE SPRINT — UX SPRINT II Brief

**Date**: 2026-07-29  
**Authority**: Executive Product Council  
**Theme**: "Make It Native" — macOS Convention Compliance & Accessibility Foundation

---

## SPRINT MISSION

Complete the transition from "custom application" to "native macOS citizen."

SUPRA has the soul of a great application but does not yet follow the rules of its platform. This sprint is about earning the right to exist on macOS by respecting its conventions.

---

## WHY THIS SPRINT

The Executive Experience Audit identified the top 10 pain points:

| Rank | Issue | Priority |
|------|-------|----------|
| 1 | No menu bar | P0 |
| 2 | Window position not persisted | P0 |
| 3 | No context menus | P0 |
| 4 | Legacy ContentView still exists | P0 |
| 5 | Two competing entry points | P0 |
| 6 | Missing keyboard shortcuts | P0 |
| 7 | No Dynamic Type / Reduced Motion | P0 |
| 8 | No VoiceOver | P0 |
| 9 | Legacy color scheme in DashboardView | P0 |
| 10 | Flat sidebar hierarchy | P1 |

This sprint addresses all 10.

---

## SPRINT SCOPE

### In Scope
- Menu bar integration
- Window state persistence
- Context menus on key surfaces
- Missing keyboard shortcuts
- Accessibility foundations
- Legacy code removal (ContentView.swift, DashboardView fix)
- Entry point unification

### Out of Scope
- Drag & drop (Phase 3)
- Sidebar regrouping (Phase 4)
- Global search (Phase 4)
- Animation overhaul (Phase 3)
- Motion vocabulary (Phase 3)

### Strict Boundaries (DO NOT TOUCH)
- Runtime services
- Architecture
- Models
- Persistence
- Provider Engine
- Router
- Business Logic
- Build System
- Memory Engine
- Networking
- JSON
- Storage
- Any file outside the `SUPRA/` UI directory

---

## MISSION 1: macOS Menu Bar

**Owner**: SUPRA-Builder  
**Risk**: Low  
**Effort**: ~4 hours

### Tasks

1. Add `.commands` to the WindowGroup Scene in `SUPRAOperationalCoreApp.swift`:
   - File: New Mission (⌘N), Close Window (⌘W), Settings (⌘,)
   - Edit: Undo (⌘Z), Redo (⌘⇧Z), Cut, Copy, Paste
   - View: Toggle Sidebar, Toggle Inspector (⌘I), Enter Full Screen
   - Window: Minimize (⌘M), Zoom, Bring All to Front
   - Help: Search help, keyboard shortcuts

2. Create `SUPRAMenuBarCommands.swift` with custom command definitions

3. Add `Settings` scene with `.windowStyle(.settings)` when Settings is selected

### Files to create/modify

- `SUPRAOperationalCoreApp.swift` — add `.commands`
- `SUPRAMenuBarCommands.swift` — NEW, custom command definitions
- `SettingsView.swift` — verify it opens via menu

### Acceptance criteria

- [ ] File menu exists with all standard items
- [ ] Edit menu exists with Undo/Redo
- [ ] View menu has Toggle Inspector, Toggle Sidebar
- [ ] Window menu has Minimize, Zoom
- [ ] Help menu exists
- [ ] Settings opens via ⌘, and menu
- [ ] ⌘W closes window
- [ ] ⌘M minimizes window

---

## MISSION 2: Window State Persistence

**Owner**: SUPRA-Builder  
**Risk**: Low  
**Effort**: ~2 hours

### Tasks

1. Create `SUPRAWindowStateManager.swift` that saves/restores:
   - Window frame (x, y, width, height)
   - Sidebar selection (`ExecutiveSpace`)
   - Inspector visibility
   - Sidebar collapsed state

2. Use `UserDefaults` for persistence (no architecture changes)

3. Apply on launch in `SUPRAOperationalCoreApp` via `.onAppear`

### Files to create/modify

- `SUPRAWindowStateManager.swift` — NEW
- `SUPRAOperationalCoreApp.swift` — integrate state restoration
- `ExecutiveWindow.swift` — read initial state from manager

### Acceptance criteria

- [ ] Window opens at last position and size
- [ ] Last selected sidebar space is restored
- [ ] Inspector open/closed state is restored
- [ ] Sidebar collapsed state is restored
- [ ] State is updated when user changes any of these

---

## MISSION 3: Context Menus

**Owner**: SUPRA-Builder  
**Risk**: Low  
**Effort**: ~3 hours

### Tasks

Add `.contextMenu` to:

1. **Sidebar items** (`SidebarItem` in `ExecutiveWindow.swift`)
   - Navigate to Space
   - Copy Name
   - ⌘1-⌘9 hint

2. **Mission rows** (`MissionRow`)
   - Open Mission
   - Duplicate Mission
   - Archive Mission
   - Copy Mission ID
   - Reveal in Finder (if path exists)

3. **Decision rows** (`DecisionRow`)
   - Open Decision
   - Copy Decision ID
   - Export Decision

4. **Workspace items** (`SUPRAOSWorkspaceExplorerView`)
   - Reveal in Finder
   - Copy Path
   - Copy Name

5. **Inspector fields** (`ExecutiveInspector`)
   - Copy Value

### Acceptance criteria

- [ ] Right-click on sidebar shows contextual actions
- [ ] Right-click on mission shows mission-specific actions
- [ ] Right-click on decision shows decision-specific actions
- [ ] Right-click on workspace items shows file actions
- [ ] Copy actions write to clipboard

---

## MISSION 4: Missing Keyboard Shortcuts

**Owner**: SUPRA-Builder  
**Risk**: Low  
**Effort**: ~2 hours

### Tasks

Add `.keyboardShortcut()` modifiers to:

| Shortcut | Action | Location |
|----------|--------|----------|
| ⌘, | Open Settings | SettingsView or Scene command |
| ⌘W | Close window | Scene command |
| ⌘M | Minimize | Window command |
| ⌘F | Focus search in current space | ExecutiveWindow |
| ⌘N | New mission | MissionCenterView |
| ⌘R | Refresh current space | ExecutiveWindow |
| ⌘Z | Undo | Scene command |
| ⌘⇧Z | Redo | Scene command |
| ⌘[ | Go back (previous space) | ExecutiveWindow |
| ⌘] | Go forward | ExecutiveWindow |
| ␣ | Quick Look on selected item | MissionCenterView |

### Acceptance criteria

- [ ] All shortcuts work in their respective views
- [ ] Shortcuts are discoverable via menu bar
- [ ] No conflicts with existing shortcuts

---

## MISSION 5: Accessibility Foundation

**Owner**: SUPRA-Builder  
**Risk**: Low  
**Effort**: ~5 hours

### Tasks

1. **VoiceOver labels**
   - Add `accessibilityLabel()` to all `Image(systemName:)` icons
   - Add `accessibilityLabel()` to all buttons without text
   - Add `accessibilityElement(children: .contain)` to custom composite views
   - Add `accessibilityAddTraits(.isButton)` to tappable cards

2. **Dynamic Type**
   - Replace all hardcoded `.font(.system(size: ...))` with text style tokens
   - Use `.font(.body)`, `.font(.caption)`, `.font(.title)` etc.
   - Only keep `.design(.rounded)` on display text

3. **Reduced Motion**
   - Add `@Environment(\.accessibilityReduceMotion) var reduceMotion`
   - Conditionally disable animations when `reduceMotion` is true
   - Use `.animation(nil, value: reduceMotion)` for global disable

4. **Focus management**
   - Ensure Tab/Shift+Tab navigates through interactive elements
   - Add `focusable()` to custom controls
   - Ensure focus ring is visible

### Files to modify

- `SUPRAUXModifiers.swift` — add reduceMotion support to fadeIn, shimmer, skeleton
- `ExecutiveWindow.swift` — add labels to sidebar icons
- All view files — audit and add accessibility labels

### Acceptance criteria

- [ ] VoiceOver reads all interface elements correctly
- [ ] Dynamic Type changes resize all text
- [ ] Reduced Motion disables all animations
- [ ] Tab navigation works through all interactive elements
- [ ] Focus rings are visible on all custom controls

---

## MISSION 6: Legacy Code Cleanup

**Owner**: SUPRA-Builder  
**Risk**: Medium  
**Effort**: ~4 hours

### Tasks

1. **Audit ContentView references**
   - Search all files for `ContentView` references
   - Verify no view or navigation references it
   - Check any routing or deep link that points to ContentView

2. **Migrate remaining functionality**
   - Check if ContentView has unique functionality not in ExecutiveWindow
   - Migrate any unique features (unlikely — ExecutiveWindow is more complete)

3. **Delete ContentView.swift**
   - Remove the file from the project
   - Remove from Xcode project reference

4. **Unify entry points**
   - Remove `@main` from `SUPRACommandCenterApp`
   - Delete `SUPRACommandCenterApp.swift` if unused
   - Ensure `SUPRAOperationalCoreApp` is the single entry point

5. **Fix DashboardView**
   - Replace `Color(nsColor: .windowBackgroundColor)` with `Color.supraBackground`
   - Replace `Color(nsColor: .controlBackgroundColor)` with `Color.supraSurface`
   - Ensure consistent padding/spacing

### Acceptance criteria

- [ ] `ContentView.swift` is deleted
- [ ] `SUPRACommandCenterApp.swift` is deleted (or @main removed)
- [ ] Build succeeds without errors
- [ ] DashboardView uses supra color scheme
- [ ] No functional regression

---

## SPRINT DELIVERABLES

| File | Action |
|------|--------|
| `SUPRAOperationalCoreApp.swift` | Add commands, window restoration |
| `SUPRAMenuBarCommands.swift` | NEW — menu bar definitions |
| `SUPRAWindowStateManager.swift` | NEW — window state persistence |
| `ExecutiveWindow.swift` | Add context menus, restore state, VoiceOver labels |
| `SidebarItem` (in ExecutiveWindow) | Add context menu |
| `MissionRow.swift` | Add context menu |
| `DecisionRow.swift` | Add context menu |
| `ExecutiveInspector` (in ExecutiveWindow) | Add copy context menu |
| `SUPRAUXModifiers.swift` | Add reduceMotion support |
| `SUPRAOSWorkspaceExplorerView.swift` | Add context menus |
| `DashboardView.swift` | Fix color scheme |
| `ContentView.swift` | DELETE |
| `SUPRACommandCenterApp.swift` | DELETE (or remove @main) |
| `SettingsView.swift` | Verify menu integration |

---

## SPRINT RITUALS

### Daily Standup
- What UX issues were resolved?
- What macOS conventions were satisfied?
- Is there any drift from the "no architecture change" rule?

### Gate Review
- Before closing the sprint, run the macOS Convention Checklist:
  - [ ] Menu bar present with all standard menus
  - [ ] All standard keyboard shortcuts work
  - [ ] Window position persists between launches
  - [ ] Context menus on all interactive surfaces
  - [ ] VoiceOver reads all elements
  - [ ] Dynamic Type respected
  - [ ] Reduced Motion respected
  - [ ] No legacy ContentView
  - [ ] Single entry point
  - [ ] Dark color scheme throughout

### Definition of Done
- All acceptance criteria met for each mission
- Build succeeds with zero warnings
- No architecture or runtime files modified
- Executive Product Council signs off

---

## RISK ASSESSMENT

| Risk | Mitigation |
|------|------------|
| Menu bar interferes with existing ⌘1-⌘9 shortcuts | Test all shortcuts after integration; use `.removals()` if needed |
| Legacy ContentView removal breaks build | Extensive grep audit before deletion; keep backup |
| Window persistence conflicts with existing state | Use separate UserDefaults keys to avoid conflicts |
| Accessibility changes inadvertently affect layout | Test all views at multiple Dynamic Type sizes |
| Context menus cause visual regression | Test each context menu on its surface |

---

## EXECUTIVE SIGN-OFF

This sprint transforms SUPRA from a custom application into a native macOS citizen.

It is the foundation for all future UX work — without these fundamentals, SUPRA cannot disappear because it will always feel foreign on its own platform.

**Recommended**: APPROVE and execute as UX SPRINT II.

---

*End of UX SPRINT II Brief*
