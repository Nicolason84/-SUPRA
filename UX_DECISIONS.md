# UX DECISIONS — SUPRA UX SPRINT 01

**Date**: 2026-07-29
**Authority**: SUPRA Executive
**Mission**: UX SPRINT 01 — From Runtime to Product

---

## DESIGN DECISIONS

### D01 — Boot Flow: Opt-In, Then Automatic
**Decision**: The boot screen shows a "Start Executive Boot" button, then automatically progresses through all steps, then shows "Continue to Cockpit".

**Rationale**: The button gives the user a sense of initiation. After that, automation conveys that the system is in control. The "Continue" button at the end lets the user choose when to enter the cockpit.

**Trade-off**: Adds one extra click. Benefit: user feels in control of the launch.

### D02 — Skeleton Design: Shapes, Not Ghost Text
**Decision**: Use geometric shapes (rounded rectangles, circles) for skeletons rather than ghost text or shimmering text lines.

**Rationale**: Shapes more honestly represent "data is loading" without pretending to be real content. Apple's HIG recommends showing structure before content.

### D03 — Animation Timing: 0.25s Default
**Decision**: All standard transitions use 0.25s ease-out. Spring animations use 0.35s response with 0.85 damping.

**Rationale**: 0.25s is fast enough to feel instant, slow enough to perceive. Springs add a slight "life" feel without being bouncy.

### D04 — Staggered Reveal: 0.05s Offset
**Decision**: Sections reveal with 0.05s staggered delay, starting from the top.

**Rationale**: Creates a cascading effect that guides the eye downward. Short enough to not feel slow, long enough to perceive each section.

### D05 — Dark Theme Only (No Light Mode)
**Decision**: Continue with the existing dark theme without adding light mode support.

**Rationale**: SUPRA is a runtime monitoring tool. Dark theme is appropriate for monitoring tools. Adding light mode would double the QA surface.

### D06 — No New Colors, Only Extension
**Decision**: Extended the existing `Color.supra*` namespace rather than creating a new theme system.

**Rationale**: The existing colors were well-chosen. They just needed more variety (surfaceLight, surfaceHighlight, textQuaternary, etc.).

### D07 — Keyboard Shortcuts: macOS Conventions
**Decision**: ⌘1-⌘9 for navigation (matching Finder tab behavior), ⌘I for inspector (matching Xcode), ⌘K for command palette (matching Slack/VS Code).

**Rationale**: Users expect these shortcuts from other macOS apps. No need to invent new conventions.

### D08 — Feedback as Overlay, Not Inline
**Decision**: Feedback appears as a floating overlay at the top of the window rather than inline in the content.

**Rationale**: Overlays don't disrupt the content layout. The user can continue working while seeing feedback. Auto-dismiss ensures it doesn't persist.

### D09 — Inspector: Show Loading, Then Context
**Decision**: When data is loading, show a loading indicator. When loaded, show contextual help text specific to the current space.

**Rationale**: The inspector should never be blank. If no real data is available, it should still provide value through context.

### D10 — Sidebar Width: 240pt (Not 280pt)
**Decision**: Reduced sidebar from 280pt to 240pt with new compact mode at 56pt.

**Rationale**: 280pt was too wide for navigation-only content. 240pt is more standard for macOS sidebars. The compact mode (56pt) saves space for power users.

---

## REJECTED ALTERNATIVES

### R01 — Launch Animation Video
**Rejected**: A video/animated logo at launch.
**Reason**: Would delay first interaction. Not appropriate for a developer tool.

### R02 — Skeleton Text Lines
**Rejected**: Using gray text boxes that look like content.
**Reason**: Can confuse users who think content has loaded. Shapes are more honest.

### R03 — Light Mode Support
**Rejected**: Would require extensive color system redesign.
**Reason**: Out of scope for this sprint. SUPRA is a monitoring tool where dark mode is standard.

### R04 — Custom Window Chrome
**Rejected**: Removing title bar for custom chrome.
**Reason**: Would break macOS expectations. Native title bar provides standard window management.

### R05 — Sound Effects
**Rejected**: Adding audio feedback to interactions.
**Reason**: Inappropriate for a developer tool. Would distract in open-plan offices.

---

## FUTURE CONSIDERATIONS

- Light mode could be added in a future sprint if user demand exists
- Customizable keyboard shortcuts could be exposed in Settings
- The boot animation could be skippable for power users
- Additional micro-interactions could be added (haptic feedback, more pulse states)
