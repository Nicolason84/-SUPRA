# SUPRA UX IMPLEMENTATION SPRINT II — PLAN

**Mission**: Transform SUPRA into a premium native macOS application
**Date**: 2026-07-29
**Status**: ACTIVE

---

## IMPLEMENTATION ORDER

Each phase builds on the previous. No phase begins until the previous is validated.

---

## PHASE 0: IMMEDIATE FIXES (Quick Wins)

| ID | Issue | File | Effort |
|----|-------|------|--------|
| F-01 | Remove "SPACES" label redundancy | ExecutiveWindow.swift | 5 min |
| F-02 | Fix animation damping inconsistency (0.9 → 0.85) | ExecutiveWindow.swift | 2 min |
| F-03 | Replace inline shadows with design tokens | ExecutiveWindow.swift | 5 min |
| F-04 | Fix "No critical notification" → positive framing | ExecutiveWindow.swift | 5 min |
| F-05 | Add accessibility labels to sidebar icons | ExecutiveWindow.swift | 5 min |
| F-06 | Add hover states to ExecutivePanel cards | ExecutiveWindow.swift | 10 min |

---

## PHASE 1: DESIGN LANGUAGE UNIFICATION

### 1.1 Corner Radius System
| Token | Value | Migrate From |
|-------|-------|-------------|
| `cornerRadiusTiny` | 6pt | 6pt (unchanged) |
| `cornerRadiusSmall` | 10pt | 10pt (unchanged) |
| `cornerRadius` | 16pt | 16pt (unchanged) |
| `cornerRadiusLarge` | 20pt | NEW — replaces 18, 20, 22, 24, 28 |

**Action**: Add `cornerRadiusLarge`. Audit all inline corner radii values 18, 20, 22, 24, 28 and replace with system tokens.

### 1.2 Animation System
| Token | Value | Notes |
|-------|-------|-------|
| `fast` | 0.15s easeOut | Hover states |
| `default` | 0.25s easeOut | General transitions |
| `slow` | 0.4s easeOut | Major transitions |
| `spring` | 0.35 response, 0.85 damping | Natural movement |
| `motionReveal` | 0.4s easeOut | Content appearing |
| `motionFocus` | 0.3s spring | Attention needed |
| `motionTransition` | 0.35s spring | Space navigation |
| `motionFeedback` | 0.15s easeOut | Button press, toggle |
| `motionProgress` | 1.0s linear/repeat | Loading |
| `motionAttention` | 0.5s spring/repeat | Status change |
| `motionCelebration` | 0.6s spring | Completion |

**Action**: Add motion vocabulary. Remove duplicate spring (0.9 damping). Ensure all views use design system tokens.

### 1.3 Shadow/Elevation System
| Token | Blur | Offset | Opacity |
|-------|------|--------|---------|
| `shadowTiny` | 2pt | 0,1 | 0.08 |
| `shadowSmall` | 4pt | 0,2 | 0.12 |
| `shadowMedium` | 12pt | 0,4 | 0.18 |
| `shadowLarge` | 28pt | 0,8 | 0.30 |

**Action**: Replace inline shadow definitions with system tokens.

### 1.4 Icon Sizing
| Context | Size | SF Symbol Weight |
|---------|------|-----------------|
| Sidebar | 14pt | regular/semibold |
| Card header | 16pt | semibold |
| Section header | 20pt | semibold |
| Hero/Page | 28pt | semibold |
| Badge | 9pt | bold |

**Action**: Enforce consistent icon sizing across all views.

---

## PHASE 2: APPLE HIG COMPLIANCE

### 2.1 Menu Bar
**Action**: Add `.commands` to `SUPRAOperationalCoreApp` with:
- File: New Mission (⌘N), Close Window (⌘W), Settings (⌘,)
- Edit: Undo (⌘Z), Redo (⌘⇧Z), Cut/Copy/Paste
- View: Toggle Sidebar (⌘S), Toggle Inspector (⌘I), Full Screen
- Window: Minimize (⌘M), Zoom, Cycle (⌘`)
- Help: Search

### 2.2 Standard Keyboard Shortcuts
| Shortcut | Action | Currently? |
|----------|--------|------------|
| ⌘W | Close window | ❌ |
| ⌘M | Minimize | ❌ |
| ⌘, | Settings | ❌ |
| ⌘F | Global search | ❌ |
| ⌘N | New mission | ❌ |
| ⌘Z / ⌘⇧Z | Undo/Redo | ❌ |
| ⌘R | Refresh | ❌ |
| ⌘` | Cycle windows | ❌ |
| Space | Quick Look | ❌ |

**Action**: Implement all missing standard shortcuts.

### 2.3 Window State Persistence
**Action**: Save/restore window frame, sidebar selection, inspector state using `UserDefaults` or `SceneStorage`.

### 2.4 Context Menus
**Action**: Add `.contextMenu` to:
- Sidebar items → Navigate, Copy Name
- Mission rows → Open, Duplicate, Archive
- Decision rows → Open, Copy
- Workspace items → Reveal in Finder, Copy Path
- KPI cards → No context menu (decorative)

---

## PHASE 3: MOTION SYSTEM

### 3.1 Button Press Animation
**Action**: Add `.pressAnimation()` modifier — 0.1s scale to 0.97 on press, return on release.

### 3.2 Card Hover Effects
**Action**: Add card lift on hover — 1.02 scale + shadow elevation increase.

### 3.3 Space Navigation Transition
**Action**: Implement cross-fade between spaces using matched geometry effect. Keep old content visible until new content is ready.

### 3.4 Micro-Interactions
| Interaction | Animation | Location |
|-------------|-----------|----------|
| Selection | Background fill 0→0.14 opacity | Sidebar, lists |
| Toggle | Slide + color transition | Switches |
| Status change | Fluid color transition | Badges |
| Loading → Loaded | Smooth cross-fade | All content areas |
| Error appear | Slide + shake | Feedback system |

### 3.5 KPI Value Animation
**Action**: Animate KPI values counting up from 0 on first load.

---

## PHASE 4: COGNITIVE LOAD REDUCTION

### 4.1 Sidebar Grouping
```
MONITOR
  ├── Cockpit
  ├── Runtime
  
WORK
  ├── Missions
  ├── Decisions
  ├── Workflows
  
EXPLORE
  ├── Knowledge Center
  ├── Discovery Center
  ├── Workspace
  
SYSTEM
  ├── Settings
```

**Action**: Add section headers to sidebar. Group items with DisclosureGroups or section dividers.

### 4.2 KPI Context
**Action**: Add trend indicators (↑↓→) and comparison values to KPI cards. "12 missions (+3 since yesterday)".

### 4.3 Badge Reduction
**Action**: Hide status badges when status is "pass" or "healthy". Show badge only when attention is needed.

### 4.4 Context Preservation
**Action**: Preserve scroll position, selected item, search query when navigating between spaces using `@SceneStorage`.

### 4.5 Recents
**Action**: Add "Recents" section at top of sidebar showing last 3 visited spaces.

---

## PHASE 5: ACCESSIBILITY

### 5.1 VoiceOver
**Action**: Add `.accessibilityLabel()` to all interactive elements. Add `.accessibilityHint()` where helpful. Ensure all icons have labels.

### 5.2 Dynamic Type
**Action**: Replace fixed font sizes with dynamic type where appropriate. Use `.dynamicTypeSize()` modifier. Ensure layout adapts to larger text.

### 5.3 Reduce Motion
**Action**: Wrap animations in `@Environment(\.accessibilityReduceMotion)` checks. Provide non-animated alternatives.

### 5.4 Increase Contrast
**Action**: Test all color combinations. Ensure minimum 4.5:1 contrast ratio for text. Add `.preferredColorScheme()` support.

### 5.5 Full Keyboard Access
**Action**: Ensure all interactive elements are reachable via Tab. Add focus rings. Support Space/Enter for activation.

---

## PHASE 6: EXECUTIVE PRESENCE

### 6.1 Ambient Idle Animations
**Action**: Add subtle gradient pulse on background. Soft shimmer effect. Status bar gentle pulse when idle.

### 6.2 Completion Celebrations
**Action**: When mission completes → brief success animation. Checkmark with scale + opacity.

### 6.3 Empty States
**Action**: 
- Animate empty states in with fade
- Add positive framing ("All systems nominal" not "No critical notifications")
- Show suggested next action with keyboard shortcut
- Add consistent illustration per space

### 6.4 Error States
**Action**:
- Add error recovery suggestions (Retry button)
- Add severity differentiation (warning vs error visual distinction)
- Persist errors in notification panel (not just toast)

### 6.5 Boot Flow
**Action**: Auto-boot on restored session. Show "Continue to Cockpit" immediately when continuity found. Make boot skippable with ⌘⏎.

---

## VALIDATION CHECKLIST

- [ ] All files compile without errors
- [ ] Design system tokens are used consistently
- [ ] Menu bar shows all standard macOS menus
- [ ] Keyboard shortcuts ⌘W, ⌘M, ⌘,, ⌘F, ⌘N work
- [ ] Window position is restored between launches
- [ ] Context menus appear on right-click
- [ ] VoiceOver reads all interactive elements
- [ ] Dynamic Type is respected
- [ ] Reduce Motion disables animations
- [ ] Tab navigation reaches all controls
- [ ] Hover states exist on all interactive surfaces
- [ ] Button press animations are visible
- [ ] Cards lift on hover
- [ ] Space transitions are smooth (cross-fade)
- [ ] Empty states are positive and suggest actions
- [ ] Error states offer recovery options
- [ ] KPI cards show trend context
- [ ] Sidebar has grouped sections
- [ ] Recents appear in sidebar
- [ ] Boot is skippable for returning users
- [ ] No legacy ContentView visual inconsistencies
