# UX ROADMAP — From Visible to Invisible

**Date**: 2026-07-29  
**Council**: Executive Product Council  
**Mission**: Make SUPRA disappear behind the work

---

## ROADMAP PHILOSOPHY

This roadmap is organized not by feature area but by **depth of user experience**. Each phase builds on the previous one, moving from "the app works" to "the app disappears."

```
Phase 1: Foundation    → The app works correctly
Phase 2: Reaction      → The app responds to me
Phase 3: Anticipation  → The app knows what I need
Phase 4: Invisibility  → I forget the app exists
```

---

## PHASE 1: FOUNDATION (Current — UX SPRINT 01)

**Status**: ✅ COMPLETE
**Theme**: The app works correctly

### Completed

- [x] Boot experience with animated sequence
- [x] Design system with colors, typography, spacing
- [x] Skeleton loading states
- [x] Fade-in content reveals
- [x] Keyboard shortcuts (⌘1-⌘9, ⌘I, ⌘K)
- [x] Hover states on sidebar
- [x] Command palette
- [x] Feedback system (toast notifications)
- [x] Pulse effects on status indicators
- [x] Content transitions between views

### Score at Phase 1 completion
- Presence: 5.5/10
- Native macOS feeling: 4/10
- Cognitive simplicity: 4.9/10
- Overall delight: 5/10

---

## PHASE 2: MACOS NATIVE (UX SPRINT II — Next)

**Theme**: The app feels like it belongs on macOS

### Objectives

1. **Complete macOS conventions**
   - Add menu bar with File, Edit, View, Window, Help
   - Add missing keyboard shortcuts (⌘W, ⌘M, ⌘,, ⌘F, ⌘N, ⌘Z, ⌘⇧Z, ⌘R)
   - Persist window position, size, state
   - Support Dynamic Type and Reduced Motion

2. **Eliminate legacy code**
   - Remove ContentView.swift
   - Unify app entry points
   - Fix DashboardView color scheme

3. **Add context menus everywhere**
   - Sidebar items
   - Mission rows
   - Decision rows
   - Inspector fields
   - Workspace items

4. **Accessibility baseline**
   - VoiceOver labels on all controls
   - Keyboard focus management
   - Tab navigation through interactive elements

### Key deliverables
- Native menu bar with all standard commands
- Window state persistence
- Context menus on 5+ surfaces
- VoiceOver support for all views

### Target scores
- Presence: 6.5/10
- Native macOS feeling: 7/10
- Cognitive simplicity: 5.5/10
- Overall delight: 6/10

### Estimated effort: 60-80 hours

---

## PHASE 3: INTERACTION (UX SPRINT III)

**Theme**: The app responds to every action

### Objectives

1. **Micro-interactions complete**
   - Button press animations (scale, shadow)
   - Card hover effects (lift, shadow)
   - Selection ripple on lists
   - Status change transitions
   - Loading indicators on async buttons

2. **Motion vocabulary**
   - Consistent animation types (Reveal, Focus, Transition, Feedback, Progress, Attention, Celebration)
   - Reduced Motion respected
   - All animations purposeful

3. **Feedback everywhere**
   - Toast on every completion
   - Inline errors with recovery
   - Optimistic UI updates
   - Progress on long operations

4. **Drag and drop**
   - Files from Finder into workspace
   - Sidebar reordering
   - Mission reordering

### Key deliverables
- Complete micro-interaction system
- Drag & drop on workspace
- Inline error recovery on all surfaces
- Motion vocabulary documented and enforced

### Target scores
- Presence: 7.5/10
- Native macOS feeling: 8/10
- Cognitive simplicity: 6/10
- Overall delight: 7/10

### Estimated effort: 80-100 hours

---

## PHASE 4: COGNITIVE (UX SPRINT IV)

**Theme**: The app reduces thinking

### Objectives

1. **Navigation redesign**
   - Grouped sidebar (Monitor, Work, Explore, System)
   - Recents at top
   - Context preserved on navigation
   - Breadcrumb trail

2. **Information hierarchy**
   - KPI cards with context (trends, targets, comparisons)
   - Visual priority in mission lists
   - Reduced badge noise
   - Progressive disclosure (summary first, details on demand)

3. **Search dominates**
   - Global search (⌘F) across all spaces
   - Natural language query support
   - Search results with preview
   - Keyboard navigation in results

4. **Empty states transformed**
   - Custom illustrations per space
   - Action prompts
   - Positive framing ("All systems nominal" vs "No critical notification")

### Key deliverables
- Sidebar redesign with grouping
- Global search implementation
- Cognitive load reduction across all views
- Empty state system

### Target scores
- Presence: 8/10
- Native macOS feeling: 8.5/10
- Cognitive simplicity: 7.5/10
- Overall delight: 8/10

### Estimated effort: 100-120 hours

---

## PHASE 5: PREDICTION (UX SPRINT V)

**Theme**: The app knows what I need

### Objectives

1. **Context-aware sidebar**
   - Predictive navigation highlights
   - Space suggestions based on current activity
   - Auto-hide irrelevant items

2. **Smart cockpit**
   - Today view with "things that need my attention"
   - Suggested next actions
   - Predictive KPI highlights

3. **Adaptive UI**
   - Power user mode (higher density)
   - Novice mode (lower density)
   - Automatic density adjustment based on usage patterns

4. **Ambient awareness**
   - Subtle idle animations
   - Peripheral status indicators
   - Non-disruptive notifications

### Key deliverables
- Predictive navigation system
- Adaptive UI modes
- Ambient awareness layer

### Target scores
- Presence: 9/10
- Native macOS feeling: 9/10
- Cognitive simplicity: 8.5/10
- Overall delight: 9/10

### Estimated effort: 120-150 hours

---

## PHASE 6: INVISIBILITY (UX SPRINT VI)

**Theme**: I forget the app exists

### Objectives

1. **Zero-thought operation**
   - All shortcuts are muscle memory
   - Navigation is subconscious
   - Information is where the user looks

2. **Anticipation**
   - The app has prepared what the user needs
   - Missions suggest themselves
   - Decisions are pre-analyzed

3. **Delight without demand**
   - Subtle celebration moments
   - Unexpected helpfulness
   - Personality without noise

4. **Complete trust**
   - The user knows the system is working correctly
   - Errors are prevented, not just handled
   - Recovery is automatic

### Key deliverables
- Full predictive UI
- Autonomous workflow suggestions
- Complete trust system
- Moment of delight on every session

### Target scores
- Presence: 10/10 (alive but not demanding)
- Native macOS feeling: 10/10
- Cognitive simplicity: 9.5/10
- Overall delight: 10/10

### Estimated effort: Ongoing

---

## ROADMAP TIMELINE

```
Phase 1: FOUNDATION      ████████████████████░░░░░░░░░░░░░░░░  COMPLETE
Phase 2: MACOS NATIVE    ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  NEXT (2-3 missions)
Phase 3: INTERACTION     ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  3-4 missions
Phase 4: COGNITIVE       ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  4-5 missions
Phase 5: PREDICTION      ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  5-6 missions
Phase 6: INVISIBILITY    ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  Ongoing
```

---

## SUCCESS METRICS

| Metric | Current | Phase 2 Target | Phase 4 Target | Phase 6 Target |
|--------|---------|----------------|----------------|----------------|
| Executive Presence Score | 5.5/10 | 6.5/10 | 8/10 | 10/10 |
| Native macOS Feel | 4/10 | 7/10 | 8.5/10 | 10/10 |
| Cognitive Load Index | 4.9/10 | 5.5/10 | 7.5/10 | 9.5/10 |
| Accessibility Score | 1/10 | 6/10 | 8/10 | 10/10 |
| Motion Quality | 43/100 | 60/100 | 80/100 | 95/100 |
| Design Language Consistency | 52/100 | 70/100 | 85/100 | 95/100 |
| Time to First Action | 8-12s | 3-5s | 1-2s | <1s |
| Clicks per Task | 4-6 | 3-4 | 2-3 | 1-2 |

---

## RISK MATRIX

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Menu bar breaks existing shortcuts | Low | High | Test all shortcuts after menu bar integration |
| Legacy ContentView removal breaks build | Medium | High | Careful audit of all references before deletion |
| Accessibility changes affect visual design | Low | Medium | Design with accessibility first |
| Drag & drop requires provider engine changes | Medium | High | Scope to UI layer only; no backend changes |
| Window persistence requires entitlement changes | Low | Medium | Check sandbox requirements first |
| Animation overhaul increases app size | Low | Low | Use system animations, not custom frameworks |

---

## IMMEDIATE NEXT STEPS

### Mission 1: macOS Foundation

1. Add `Scene` commands for menu bar (File, Edit, View, Window, Help)
2. Add window state persistence (UserDefaults)
3. Add context menus to sidebar and mission lists
4. Add missing keyboard shortcuts (⌘W, ⌘M, ⌘,, ⌘F, ⌘N)
5. Support `@Environment(\.accessibilityReduceMotion)`

### Mission 2: Eliminate Legacy

1. Audit `ContentView` references across codebase
2. Migrate any remaining functionality to `ExecutiveWindow`
3. Delete `ContentView.swift`
4. Remove `SUPRACommandCenterApp`, keep `SUPRAOperationalCoreApp`
5. Fix `DashboardView` color scheme

### Mission 3: Accessibility Foundation

1. Add `accessibilityLabel()` to all buttons and controls
2. Add `accessibilityElement()` to custom views
3. Add `accessibilityAddTraits()` for button/header traits
4. Test with VoiceOver enabled
5. Support Dynamic Type via text style tokens
