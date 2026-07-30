# TOP 100 UX IMPROVEMENTS

**Date**: 2026-07-29  
**Council**: Executive Product Council  
**Priority**: P0 (Critical) → P3 (Enhancement)

---

## PRIORITY LEGEND

| Priority | Definition | Target |
|----------|------------|--------|
| **P0** | Blocks user experience. Must fix before next release. | Next 2 missions |
| **P1** | Significant quality gap. Should fix in current sprint. | This sprint |
| **P2** | Important enhancement. Schedule after critical issues. | Next 2 sprints |
| **P3** | Delightful improvement. Add when convenient. | Backlog |

**Impact**: 1 (Low) → 5 (Transformative)  
**Complexity**: 1 (Trivial) → 5 (Architecture change)  
**Risk**: 1 (Safe) → 5 (Could break things)

---

## P0 — CRITICAL (10 items)

| # | Improvement | Impact | Complexity | Risk | Visible Value |
|---|-------------|--------|------------|------|---------------|
| 01 | **Add native macOS menu bar** — File, Edit, View, Window, Help with standard shortcuts | 5 | 3 | 2 | 5 |
| 02 | **Persist window position and size** — save frame to UserDefaults, restore on launch | 4 | 2 | 1 | 5 |
| 03 | **Add context menus** — right-click on sidebar, missions, decisions, workspace items | 4 | 2 | 1 | 5 |
| 04 | **Remove legacy ContentView.swift** — migrate remaining functionality or delete | 3 | 3 | 3 | 4 |
| 05 | **Unify app entry points** — single @main, consistent window size (1400×900) | 3 | 2 | 2 | 3 |
| 06 | **Add ⌘W, ⌘M, ⌘, ⌘F, ⌘N shortcuts** — standard macOS window and action shortcuts | 4 | 1 | 1 | 5 |
| 07 | **Support Dynamic Type** — use `.font(.body)` etc. instead of hardcoded sizes | 4 | 2 | 1 | 4 |
| 08 | **Support Reduced Motion** — disable animations when `@Environment(\.accessibilityReduceMotion)` is true | 4 | 2 | 1 | 4 |
| 09 | **Add VoiceOver labels** — `accessibilityLabel()` on all controls, `accessibilityElement()` on custom views | 5 | 3 | 1 | 5 |
| 10 | **Fix DashboardView color scheme** — migrate from `nsColor.windowBackgroundColor` to `supraBackground` | 3 | 1 | 1 | 3 |

---

## P1 — HIGH PRIORITY (20 items)

| # | Improvement | Impact | Complexity | Risk | Visible Value |
|---|-------------|--------|------------|------|---------------|
| 11 | **Group sidebar items** — Monitor, Work, Explore, System sections | 4 | 2 | 2 | 4 |
| 12 | **Auto-boot on continuity restored** — skip boot when session is healthy | 4 | 2 | 2 | 5 |
| 13 | **Preserve scroll position** — save/restore per-space scroll offset | 3 | 2 | 1 | 4 |
| 14 | **Preserve sidebar selection** — persist to UserDefaults | 3 | 1 | 1 | 4 |
| 15 | **Preserve inspector toggle state** — persist to UserDefaults | 3 | 1 | 1 | 4 |
| 16 | **Add recents to sidebar** — last 3 visited spaces at top | 3 | 1 | 1 | 4 |
| 17 | **Add global search (⌘F)** — unified search across all spaces | 4 | 3 | 2 | 5 |
| 18 | **Add undo/redo support** — `UndoManager` integration for user actions | 3 | 3 | 2 | 4 |
| 19 | **Add button press animation** — 0.1s scale to 0.97 on all buttons | 3 | 1 | 1 | 4 |
| 20 | **Add hover highlight to all interactive surfaces** — cards, panels, list rows | 3 | 2 | 1 | 4 |
| 21 | **Fix space navigation transition** — cross-fade between ready content instead of skeleton flash | 4 | 3 | 2 | 4 |
| 22 | **Add mission progress bars** — visual completion indicators in mission rows | 3 | 1 | 1 | 4 |
| 23 | **Add KPI context** — trend arrows, min/max, or comparison values on numbers | 3 | 2 | 1 | 4 |
| 24 | **Add empty state illustrations** — custom per-space empty states with action prompts | 3 | 2 | 1 | 4 |
| 25 | **Reduce badge noise** — show status badges only when status deviates from "pass" | 3 | 1 | 1 | 3 |
| 26 | **Unify card components** — merge ExecutivePanel and SUPRAOSCard into single component | 3 | 2 | 1 | 4 |
| 27 | **Add notification badge count** — show unread count on bell icon | 3 | 1 | 1 | 4 |
| 28 | **Add Tab keyboard navigation** — standard Tab/Shift+Tab through interactive elements | 4 | 3 | 2 | 4 |
| 29 | **Make cockpit panels clickable** — navigate to corresponding space on click | 3 | 1 | 1 | 4 |
| 30 | **Improve content fade-in** — make animation more perceivable (16pt offset, no blur) | 2 | 1 | 1 | 3 |

---

## P2 — MEDIUM PRIORITY (30 items)

| # | Improvement | Impact | Complexity | Risk | Visible Value |
|---|-------------|--------|------------|------|---------------|
| 31 | **Add window state restoration** — save/restore entire window configuration | 4 | 4 | 2 | 4 |
| 32 | **Support drag & drop from Finder** — drop files onto workspace, missions | 4 | 3 | 2 | 4 |
| 33 | **Add sidebar item reordering** — drag to reorder sidebar items | 3 | 2 | 2 | 3 |
| 34 | **Add breadcrumb navigation** — show "Cockpit > Missions > Mission Name" | 3 | 2 | 1 | 4 |
| 35 | **Add quick entry (⌃⌘Space)** — rapid mission/item creation from anywhere | 3 | 2 | 1 | 4 |
| 36 | **Add today view to cockpit** — what happened today, what needs attention | 3 | 3 | 1 | 4 |
| 37 | **Add ⏎ to continue on boot complete** — keyboard shortcut instead of click | 2 | 1 | 1 | 3 |
| 38 | **Add ⌘⏎ to skip boot** — for returning users | 3 | 1 | 1 | 4 |
| 39 | **Add shimmer to skeletons** — replace uniform pulse with gradient shimmer | 2 | 1 | 1 | 3 |
| 40 | **Add KPI value count-up animation** — numbers animate from 0 on first load | 2 | 1 | 1 | 3 |
| 41 | **Add status change animation** — badges fluidly transition between colors | 2 | 1 | 1 | 3 |
| 42 | **Add mission completion celebration** — brief success animation on completion | 3 | 1 | 1 | 4 |
| 43 | **Add loading indicator on async buttons** — button shows spinner during async operation | 3 | 1 | 1 | 4 |
| 44 | **Add inline error recovery** — error states with retry buttons and guidance | 4 | 2 | 1 | 4 |
| 45 | **Add keyboard shortcut hints in tooltips** — show shortcut in hover tooltip | 2 | 1 | 1 | 3 |
| 46 | **Standardize corner radii** — enforce 4 values (6, 10, 16, 20) across all views | 2 | 2 | 1 | 3 |
| 47 | **Standardize padding** — enforce design system padding tokens everywhere | 2 | 2 | 1 | 3 |
| 48 | **Add adaptive full-screen mode** — hide sidebar in full screen | 2 | 2 | 2 | 3 |
| 49 | **Add Space key for Quick Look** — preview mission details or files | 3 | 2 | 1 | 4 |
| 50 | **Add ⌘R refresh shortcut** — consistent refresh across all spaces | 2 | 1 | 1 | 3 |
| 51 | **Add business platform view** — `SUPRABusinessPlatform` needs UX pass | 3 | 3 | 1 | 3 |
| 52 | **Add evolution room view** — `SUPRAEvolutionRoomView` needs UX pass | 3 | 3 | 1 | 3 |
| 53 | **Improve mission row design** — larger title, smaller metadata, visual priority | 3 | 1 | 1 | 4 |
| 54 | **Add filter/sort to mission list** — filter by status, priority, date | 3 | 2 | 1 | 4 |
| 55 | **Add batch selection in mission list** — multi-select for bulk operations | 3 | 3 | 2 | 3 |
| 56 | **Add mission creation wizard** — guided step-by-step mission creation | 3 | 3 | 2 | 3 |
| 57 | **Add decision flow visualization** — visual path from pending through reviewed to executed | 3 | 3 | 1 | 4 |
| 58 | **Add runtime health summary** — plain-language health status before technical metrics | 3 | 2 | 1 | 4 |
| 59 | **Add time series visualization** — sparklines for runtime metrics | 4 | 3 | 2 | 4 |
| 60 | **Add help menu** — searchable help content integrated into menu bar | 3 | 3 | 1 | 4 |

---

## P3 — ENHANCEMENT (40 items)

| # | Improvement | Impact | Complexity | Risk | Visible Value |
|---|-------------|--------|------------|------|---------------|
| 61 | **Add dark/light mode support** — respect system appearance | 2 | 3 | 2 | 3 |
| 62 | **Add accent color customization** — respect system accent color | 2 | 2 | 1 | 3 |
| 63 | **Add Touch Bar support** — MacBook Pro Touch Bar shortcuts | 2 | 2 | 1 | 2 |
| 64 | **Add window tab support** — multiple spaces in one window via tabs | 3 | 4 | 3 | 3 |
| 65 | **Add split view support within spaces** — side-by-side content | 3 | 4 | 3 | 3 |
| 66 | **Add custom app icon** — replace default SwiftUI icon | 3 | 1 | 1 | 4 |
| 67 | **Add custom SF Symbols composite icons** — unique icons for SUPRA-specific concepts | 2 | 2 | 1 | 3 |
| 68 | **Add onboarding flow** — first-launch tutorial for new users | 4 | 3 | 1 | 4 |
| 69 | **Add keyboard shortcut cheat sheet** — ⌘K command with "All Shortcuts" section | 3 | 1 | 1 | 4 |
| 70 | **Add smooth scrolling** — use `.animation()` on list content changes | 2 | 1 | 1 | 2 |
| 71 | **Add "go back" shortcut** — ⌘[ to navigate to previous space | 2 | 1 | 1 | 3 |
| 72 | **Add forward shortcut** — ⌘] to navigate forward | 2 | 1 | 1 | 3 |
| 73 | **Add floating action button** — quick action button in bottom-right corner | 2 | 2 | 1 | 3 |
| 74 | **Add ambient idle animation** — slow background gradient shift | 2 | 1 | 1 | 3 |
| 75 | **Add spring animation to panel expand/collapse** — smooth disclosure animations | 2 | 1 | 1 | 3 |
| 76 | **Add toast to all async operations** — confirmation on save, delete, complete | 3 | 1 | 1 | 4 |
| 77 | **Add optimistic UI updates** — update UI before server/async confirms | 3 | 3 | 2 | 4 |
| 78 | **Add pull-to-refresh** — on scrollable content areas | 2 | 1 | 1 | 3 |
| 79 | **Add infinite scroll** — for large lists (missions, decisions) | 2 | 2 | 1 | 2 |
| 80 | **Add item count badges to sidebar** — show count per space | 2 | 1 | 1 | 3 |
| 81 | **Add color-coded sidebar items** — each space gets an accent color | 2 | 1 | 1 | 3 |
| 82 | **Add icon animation on selection** — subtle icon transform when selected | 2 | 1 | 1 | 2 |
| 83 | **Add custom cursor for interactive areas** — pointing hand on clickable items | 2 | 1 | 1 | 3 |
| 84 | **Add drag-to-install mission** — drag mission from library to active list | 2 | 2 | 2 | 3 |
| 85 | **Add copy-paste support** — standard clipboard shortcuts | 2 | 1 | 1 | 3 |
| 86 | **Add markdown preview** — render markdown in mission descriptions | 3 | 2 | 1 | 4 |
| 87 | **Add code syntax highlighting** — for mission execution logs | 2 | 2 | 1 | 3 |
| 88 | **Add word count / character count** — in text fields | 1 | 1 | 1 | 1 |
| 89 | **Add auto-save indicators** — show "saved" / "saving..." status | 2 | 1 | 1 | 3 |
| 90 | **Add confirmation dialogs** — before destructive actions (delete, archive) | 3 | 1 | 1 | 4 |
| 91 | **Add sound effects** — optional, system-level feedback sounds | 2 | 2 | 1 | 3 |
| 92 | **Add haptic feedback** — on supported Macs (Force Touch trackpad) | 1 | 2 | 1 | 2 |
| 93 | **Add typography refinement** — use system font for body, rounded only for display | 2 | 1 | 1 | 3 |
| 94 | **Add dynamic type presets** — test at every accessibility text size | 3 | 2 | 1 | 4 |
| 95 | **Add VoiceOver custom actions** — swipe gestures for common actions | 3 | 3 | 2 | 3 |
| 96 | **Add Focus Mode** — hide non-essential UI elements during active work | 3 | 2 | 1 | 4 |
| 97 | **Add Session timeline** — visual timeline of user's current session | 2 | 2 | 1 | 3 |
| 98 | **Add easter eggs** — playful hidden interactions for user delight | 1 | 1 | 1 | 3 |
| 99 | **Add export functionality** — export missions, decisions, reports | 3 | 2 | 1 | 3 |
| 100 | **Add print support** — print mission reports, decision summaries | 2 | 2 | 1 | 2 |

---

## PRIORITY DISTRIBUTION

| Priority | Count | Effort Estimate |
|----------|-------|-----------------|
| **P0** | 10 | ~15-20 hours |
| **P1** | 20 | ~40-60 hours |
| **P2** | 30 | ~80-120 hours |
| **P3** | 40 | ~120-180 hours |
| **Total** | **100** | **~255-380 hours** |

## QUICK WINS (Top 10 by Impact/Effort Ratio)

These deliver maximum visible value with minimum effort:

1. **Add context menus** — #3 (P0, 2h)
2. **Add ⌘W, ⌘M, ⌘, shortcuts** — #6 (P0, 1h)
3. **Preserve sidebar selection** — #14 (P1, 1h)
4. **Add recents to sidebar** — #16 (P1, 2h)
5. **Add button press animation** — #19 (P1, 1h)
6. **Add hover highlight to cards** — #20 (P1, 2h)
7. **Add notification badge count** — #27 (P1, 1h)
8. **Make cockpit panels clickable** — #29 (P1, 2h)
9. **Add ⏎ to continue + ⌘⏎ skip boot** — #37-38 (P2, 2h)
10. **Add shimmer to skeletons** — #39 (P2, 1h)
