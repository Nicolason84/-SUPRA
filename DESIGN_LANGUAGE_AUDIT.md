# DESIGN LANGUAGE AUDIT — One Language, One Voice

**Date**: 2026-07-29  
**Council**: Visual Designer, Information Architect, SwiftUI Design System Architect  
**Focus**: Consistency of visual language across all surfaces

---

## EXECUTIVE SUMMARY

SUPRA has made significant progress toward a unified design language. The `SUPRAOSDesignSystem` defines colors, typography, spacing, corner radii, shadows, and animations. Reusable components (`SUPRAOSCard`, `SUPRAOSStatCard`, `SUPRAOSBadge`, `ExecutivePanel`) enforce consistency.

**However**, the design language is not yet a single voice. Two parallel visual systems coexist: the new `ExecutiveWindow` architecture with the dark `supraBackground` theme, and the legacy `ContentView` with `NSColor.windowBackgroundColor`. Elements from both bleed into each other.

---

## THE ONE LANGUAGE CHECKLIST

### Spacing System

| Token | Value | Consistency |
|-------|-------|-------------|
| `spacingMini` | 4pt | ✅ Used everywhere spacing is needed |
| `spacingTiny` | 8pt | ✅ Consistent |
| `spacingSmall` | 12pt | ⚠️ Some views use 10pt or 14pt |
| `spacing` | 20pt | ⚠️ Used as default but some sections use 18pt or 24pt |
| `paddingMini` | 6pt | ✅ Consistent |
| `paddingTiny` | 10pt | ⚠️ Some views use 8pt |
| `paddingSmall` | 16pt | ✅ Consistent |
| `padding` | 24pt | ⚠️ `.padding(28)` appears in ContentView |

**Verdict**: Good foundation with minor drift. Some legacy views use ad-hoc values.

### Typography System

| Token | Definition | Issues |
|-------|------------|--------|
| `largeTitle` (32pt) | Used for page titles | ✅ |
| `title` (26pt) | Used for section headers | ✅ |
| `title2` (22pt) | Used for card titles | ✅ |
| `title3` (18pt) | Used for panel titles | ⚠️ |
| `body` (13pt) | Used for content text | ⚠️ Mixed with 12pt in some views |
| `caption` (10pt) | Used for metadata | ⚠️ Some views use 9pt |
| `badge` (9pt) | Used for status badges | ✅ |
| `monospace` (12pt) | Used for code/paths | ⚠️ Some views use 11pt |

**Verdict**: The scale exists but is not enforced. Some views set font directly: `.font(.caption2.weight(.black))`, `.font(.system(size: 13))`.

### Icon Language

SUPRA uses SF Symbols exclusively. This is correct for a macOS application — consistent with Apple's ecosystem.

**Issues**:

1. **Inconsistent use of fill variants**. Some icons use `.fill` variant (`checkmark.circle.fill`), others use outline (`circle`). This creates visual inconsistency in the sidebar.

2. **Missing accessibility labels**. No `accessibilityLabel()` on any decorative icon. VoiceOver reads "square.grid.2x2.fill" instead of "Workspace".

3. **Icon sizes vary**. Some icons use `.title2`, others use `.system(size: 14)`. The icon size should be a fixed value (14pt for sidebar, 16pt for cards, 20pt for headers).

### Color System

The color palette is well-defined:

| Category | Colors | Consistency |
|----------|--------|-------------|
| Backgrounds | `supraBackground`, `supraSurface`, `supraSurfaceLight`, `supraGlass` | ✅ Used in ExecutiveWindow |
| Accent | `supraAccent`, `supraAccentSecondary`, `supraAccentTertiary` | ✅ Consistent |
| Semantic | `supraGreen`, `supraOrange`, `supraRed`, `supraYellow`, `supraPurple`, `supraTeal`, `supraBlue`, `supraPink` | ✅ Consistent |
| Text | `supraText`, `supraTextSecondary`, `supraTextTertiary`, `supraTextQuaternary` | ✅ Consistent |
| Borders | `supraBorder`, `supraBorderLight`, `supraBorderFocused` | ✅ Consistent |

**Critical Issue**: `ContentView.swift` uses `Color(nsColor: .windowBackgroundColor)` and `Color(nsColor: .controlBackgroundColor)` — these are the light-mode system colors that clash with the dark `supraBackground` theme. This view is still present in the codebase.

### Corner Radius System

| Token | Value | Issues |
|-------|-------|--------|
| `cornerRadiusTiny` | 6pt | ✅ |
| `cornerRadiusSmall` | 10pt | ⚠️ Some views use 8pt, 12pt or 14pt |
| `cornerRadius` | 16pt | ⚠️ Inconsistent — values range from 10 to 28 |

**Issue**: ContentView uses `cornerRadius: 18`, `cornerRadius: 20`, `cornerRadius: 22`, `cornerRadius: 24`, `cornerRadius: 28`. This is 5 different values where the design system defines 3.

### Shadow/Elevation System

| Token | Definition | Usage |
|-------|------------|-------|
| `shadowSmall` | 4pt blur, 2pt offset | Used sparingly |
| `shadowMedium` | 12pt blur, 4pt offset | Used on command palette |

**Issue**: Custom shadow values appear in line: `shadow(color: .black.opacity(0.3), radius: 28, y: 8)` in `CommandPalette`, `shadow(color: .black.opacity(0.2), radius: 16, y: 6)` in `ToastView`. These should reference design system tokens.

### Motion Language

Defined in `SUPRAOSDesignSystem.Animation`:

| Token | Value | Consistency |
|-------|-------|-------------|
| `fast` | 0.15s | ✅ Used for hover states |
| `defaultDuration` | 0.25s | ⚠️ Some transitions use 0.3s, 0.35s |
| `slow` | 0.4s | ✅ Used for major transitions |
| `spring` | 0.35 response, 0.85 damping | ⚠️ Multiple spring definitions exist |

**Issue**: `ExecutiveWindow` defines its own spring: `.spring(response: 0.35, dampingFraction: 0.9)` which differs from the design system's `.spring(response: 0.35, dampingFraction: 0.85)`. The `.smooth` animation (0.3s easeOut) is defined but not used.

### Border/Stroke Language

| Style | Consistency |
|-------|-------------|
| `.stroke(Color.supraBorder)` | ✅ Used on cards, panels, command palette |
| `.stroke(Color.supraBorderLight)` | ⚠️ Rarely used |
| `.stroke(Color.supraBorderFocused)` | ❌ Never used |
| Custom borders | ❌ `VStack { Divider().overlay(Color.supraBorder) }` is inconsistent — sometimes `Divider()` without overlay |

---

## VISUAL INCONSISTENCIES BY COMPONENT

### ExecutivePanel vs SUPRAOSCard

| Aspect | ExecutivePanel | SUPRAOSCard |
|--------|---------------|-------------|
| Background | `Color.supraSurface` | `Color.supraSurface` |
| Corner radius | 10pt (`cornerRadiusSmall`) | 10pt (`cornerRadiusSmall`) |
| Border | `.stroke(Color.supraBorder)` | `.stroke(Color.supraBorder)` |
| Padding | 16pt (`paddingSmall`) | 16pt (`paddingSmall`) |
| Icon style | `Label(title, systemImage: icon)` | Custom HStack with icon in rounded square |
| Title font | `Fonts.section` (14pt semibold) | `Fonts.body` (13pt) semibold |
| **Verdict** | Two different card styles | Should be unified |

### MissionRow vs SidebarItem

| Aspect | MissionRow | SidebarItem |
|--------|-----------|-------------|
| Selection style | Default list selection | Custom accent background |
| Height | Dynamic | Fixed 34pt |
| Hover | Default | Custom opacity |
| **Verdict** | Different interaction models | Inconsistent feel |

### ExecutiveStatusBar vs Other Status Areas

The status bar uses pulsing indicators and compact labels. Some views (Cockpit header, Mission Center) have their own status indicators that look different. Status information should come from one canonical component.

---

## INFORMATION ARCHITECTURE AUDIT

### Navigation Model

The current navigation is a flat list of 9 spaces in the sidebar. This creates:

| Problem | Impact |
|---------|--------|
| No grouping | User must scan all 9 items to find what they need |
| No hierarchy | All items appear equally important |
| No recents | User cannot quickly return to previous space |
| No favorites | User cannot customize their navigation |

**Recommended Structure**:

```
MONITOR
  ├── Cockpit (overview, alerts, health)
  ├── Runtime (live system status)
  
WORK
  ├── Missions (active and past missions)
  ├── Decisions (decision history and inbox)
  ├── Workflows (automated execution)
  
EXPLORE
  ├── Knowledge Center (canonical knowledge graph)
  ├── Discovery Center (capabilities, opportunities)
  ├── Workspace (file system, modules)
  
SYSTEM
  ├── Settings
```

### Content Layout

Three distinct layout patterns exist:

1. **Scroll + panels** (Cockpit): Full-width scroll with card panels
2. **NavigationSplitView** (Mission Center): Sidebar + detail
3. **Custom sidebar + workspace** (ExecutiveWindow): Custom sidebar + content area + inspector

Each pattern is valid for its use case, but the visual language between them should be consistent.

---

## ONE LANGUAGE VERDICT

| System | Score | Verdict |
|--------|-------|---------|
| Spacing | 7/10 | Defined, some drift |
| Typography | 6/10 | Defined, inconsistently applied |
| Iconography | 5/10 | SF Symbols only, no custom assets, no accessibility |
| Colors | 7/10 | Identified legacy conflict |
| Shadows | 4/10 | Defined but not enforced |
| Motion | 5/10 | Multiple competing definitions |
| Corner Radius | 5/10 | Defined but 8+ values in use |
| Borders | 5/10 | Partially inconsistent using Divider |
| Components | 4/10 | Parallel card systems |
| Navigation | 4/10 | Flat hierarchy, no grouping |

## SPECIFIC VIOLATIONS

1. **Legacy ContentView exists** with old color scheme — must be removed
2. **`DashboardView`** uses old color scheme — must migrate to `supraBackground`
3. **Two app entry points** — `SUPRAOperationalCoreApp` (@main) and `SUPRACommandCenterApp` (commented-out) suggest architecture ambiguity
4. **Multiple corner radii** — 22 values between 6 and 28, should be 4 (6, 10, 16, 20)
5. **Two spring animation definitions** — design system says 0.85 damping, ExecutiveWindow says 0.9
6. **`ContentView.swift` uses `.font(.largeTitle)` directly** — bypasses design system
7. **`.padding(28)`** in ContentView — bypasses design system padding tokens
8. **Inline shadow values** — command palette defines `radius: 28, y: 8` instead of using `shadowMedium`
9. **`Divider()` without `.overlay(Color.supraBorder)`** — inconsistent border rendering
10. **Status indicators vary** — some use `Circle().fill()`, some use `Label` with systemImage, some use custom `StatusBadge` component
