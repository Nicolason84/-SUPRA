# SUPRA UX SPRINT III — Next Implementation

**Date**: 2026-07-29
**Predecessor**: Sprint II — Design Language, Apple HIG, Boot Flow
**Status**: READY FOR SPRINT III

---

## Mission

Complete the remaining UX phases: Motion System, Cognitive Load Reduction, Accessibility, and Executive Presence.

---

## Prerequisites

- [x] Sprint II build verified (BUILD SUCCEEDED)
- [x] Design language unified (corners, motion vocabulary, shadows, icons, colors, typography)
- [x] Apple HIG menu bar and keyboard shortcuts in place
- [x] Boot flow with skip and auto-restore
- [x] Pre-existing build errors fixed

---

## Implementation Order

### Phase 3: Motion System (Estimated: 2h)

| ID | Task | File(s) | Dependencies |
|----|------|---------|-------------|
| M-01 | Add `.pressAnimation()` to remaining buttons | All button views | None (modifier exists) |
| M-02 | Add card lift on hover to all card views | Various card views | CardHoverModifier (exists) |
| M-03 | Implement cross-fade transitions between spaces | ExecutiveWindow.swift | Motion.transition (exists) |
| M-04 | Add matched geometry effect for space navigation | ExecutiveWindow.swift | Requires geometry IDs |
| M-05 | Animate KPI values counting up on load | SUPRAOSStatCard | Needs value animation |
| M-06 | Add micro-interactions (selection, toggle, status) | Various | Motion.feedback |

### Phase 4: Cognitive Load Reduction (Estimated: 2h)

| ID | Task | File(s) | Dependencies |
|----|------|---------|-------------|
| CL-01 | Add trend indicators (↑↓→) to KPI cards | SUPRAOSStatCard | Done (exists) |
| CL-02 | Hide badges when status is PASS/healthy | SUPRAOSBadge | Done (showOnlyWhenNotPass) |
| CL-03 | Preserve scroll position between spaces | ExecutiveWindow.swift | @SceneStorage per space |
| CL-04 | Preserve search query between spaces | ExecutiveWindow.swift | @SceneStorage per space |
| CL-05 | Persist window frame between launches | SUPRAOperationalCoreApp.swift | NSWindow restoration |

### Phase 5: Accessibility (Estimated: 2h)

| ID | Task | File(s) | Dependencies |
|----|------|---------|-------------|
| A-01 | Add VoiceOver labels to all interactive elements | All views | .supraAccessibility() (exists) |
| A-02 | Implement Dynamic Type support | All views | Replace fixed sizes |
| A-03 | Ensure 4.5:1 contrast ratio on all text | All views | Color audit |
| A-04 | Add full keyboard access (Tab navigation) | All views | Focus rings + Tab order |
| A-05 | Test with VoiceOver enabled | — | Manual testing |

### Phase 6: Executive Presence (Estimated: 2h)

| ID | Task | File(s) | Dependencies |
|----|------|---------|-------------|
| EP-01 | Add ambient gradient pulse on background | SUPRAOSDesignSystem.swift | Motion.attention |
| EP-02 | Add subtle shimmer to loading states | SUPRAUXModifiers.swift | ShimmerModifier (exists) |
| EP-03 | Add completion celebration animation | MissionCenterView.swift | Motion.celebration |
| EP-04 | Animate empty state appearance | SupraReadyView/ActionNeededView | fadeIn modifier (exists) |
| EP-05 | Add error recovery suggestions | All error states | Retry button pattern |
| EP-06 | Persist errors in notification panel | ExecutiveWindow.swift | Notification system |

---

## Files That Will Be Modified in Sprint III

| File | Sprint III Changes |
|------|-------------------|
| `SUPRA/ExecutiveWindow.swift` | Cross-fade transitions, matched geometry, scroll/search persistence |
| `SUPRA/SUPRAOSDesignSystem.swift` | Ambient animations, additional components |
| `SUPRA/SUPRAOperationalCoreApp.swift` | Window frame persistence |
| `SUPRA/SUPRAOSProductRootView.swift` | Ambient boot animation |
| `SUPRA/MissionCenterView.swift` | Completion celebrations |
| `SUPRA/SUPRADecisionRoomView.swift` | Context menus |
| `SUPRA/SUPRAOSWorkspaceExplorerView.swift` | Context menus |
| `SUPRA/ConversationTwinView.swift` | Context menus |
| `SUPRA/SUPRAEnvironmentCommandCenterView.swift` | Context menus |
| `SUPRA/RuntimeDiagnosticsView.swift` | Context menus |
| All view files | Accessibility labels, Dynamic Type, keyboard access |

---

## Validation Checklist for Sprint III

- [ ] Press animations on all buttons
- [ ] Card hover effects on all card-like views
- [ ] Cross-fade transitions between all spaces
- [ ] KPI values animate counting up
- [ ] Trend indicators on all KPI cards
- [ ] Badges hidden when status is PASS
- [ ] Scroll position preserved between navigations
- [ ] Window frame restored between launches
- [ ] VoiceOver reads all interactive elements
- [ ] Dynamic Type respected across all views
- [ ] Minimum 4.5:1 contrast ratio
- [ ] Tab navigation reaches all controls
- [ ] Ambient gradient pulse on background
- [ ] Completion celebration animations
- [ ] Error states with recovery suggestions
- [ ] Errors persisted in notification panel
- [ ] All files compile without errors
- [ ] Build succeeds (0 errors, 0 warnings)

---

## Sprint II Handoff Notes

### What Sprint II delivers to Sprint III
1. Clean design system foundation (tokens, colors, typography, shadows, motion vocabulary)
2. Working menu bar with standard keyboard shortcuts
3. Reusable components (Card, StatCard, Badge, SectionHeader, Button)
4. Reusable modifiers (pressAnimation, cardHoverEffect, fadeIn, animatedMotion)
5. Accessibility infrastructure (supraAccessibility modifier, Reduce Motion support)
6. Boot flow with skip and auto-restore
7. Pre-existing build errors fixed
8. Positive framing for empty states
9. Sidebar with grouping, recents, context menus
10. Hover states on panels and interactive elements

### What Sprint III must NOT do
- Modify Runtime, Services, Router, Provider Engine, Business Logic, Models, Persistence, Memory Engine, Networking, Storage, JSON, Build System
- Break any existing functionality
- Add new dependencies or frameworks
- Modify the architecture

### Sprint III starting point
```
BUILD: ✅ SUCCEEDED
MODIFIED: SUPRAOSDesignSystem.swift, ExecutiveWindow.swift, SUPRAOperationalCoreApp.swift, 
          SUPRAOSProductRootView.swift, SUPRAUXModifiers.swift, DashboardView.swift
UNTOUCHED: All Runtime, Services, Router, Provider, Business Logic, Models, Persistence
```
