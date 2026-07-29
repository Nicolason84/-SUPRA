# G1 Gap Analysis

**Date**: 2026-07-29
**Document**: Phase 3 of G1 Architecture Discovery
**Status**: PLANNED — pending validation

---

## 1. Existing Capabilities (Already Present)

| Element | Location | Status | Reuse Action |
|---------|----------|--------|-------------|
| `SUPRACommandCenterState` | SUPRACommandCenterState.swift | EXISTING | Consume as-is — single source of truth |
| `CommandCenterView` | CommandCenterView.swift | EXISTING | Extend by adding DashboardView to grid |
| `HealthView` | HealthView.swift | EXISTING | Reuse — no changes needed |
| `RuntimeView` | RuntimeView.swift | EXISTING | Reuse — no changes needed |
| `MemoryView` | MemoryView.swift | EXISTING | Reuse — no changes needed |
| `MissionView` | MissionView.swift | EXISTING | Reuse — no changes needed |
| `MultiMemoryView` | MultiMemoryView.swift | EXISTING | Reuse — no changes needed |
| `IntelligenceView` | IntelligenceView.swift | EXISTING | Reuse — no changes needed |
| `HealthMonitorView` | HealthMonitorView.swift | EXISTING (G2) | Reuse — include in dashboard grid |
| `SUPRAOSCard` | SUPRAOSDesignSystem.swift | EXISTING | Reuse — card container for new components |
| `SUPRAOSStatCard` | SUPRAOSDesignSystem.swift | EXISTING | Reuse — stat card component |
| `SUPRAEnvironmentResolver` | SUPRAEnvironmentResolver.swift | EXISTING | Consume — projectRoot for any needs |
| `SUPRAOSDesignSystem` tokens | SUPRAOSDesignSystem.swift | EXISTING | Reference — all design tokens |
| `SUPRAOSDesignSystem.Fonts` | SUPRAOSDesignSystem.swift | EXISTING | Reference — typography |
| `SUPRAOSDesignSystem.colors` | SUPRAOSDesignSystem.swift | EXISTING | Reference — all semantic colors |
| LazyVGrid pattern | CommandCenterView.swift | EXISTING | Replicate — same grid layout |
| @EnvironmentObject pattern | Existing views | EXISTING | Replicate — same state injection |
| Header pattern | CommandCenterView.swift | EXISTING | Replicate — similar header with Live indicator |

---

## 2. Reusable Patterns (Can Be Applied Without New Abstractions)

| Pattern | Source | Application | Abstraction Needed? |
|---------|--------|-------------|---------------------|
| LazyVGrid adaptive columns | CommandCenterView.swift | Dashboard grid layout | NO — reuse directly |
| SUPRAOSCard with title/subtitle/icon/color | SUPRAOSDesignSystem.swift | Dashboard section cards | NO — reuse directly |
| SUPRAOSStatCard for metric display | SUPRAOSDesignSystem.swift | Indicator bar metrics | NO — reuse directly |
| @EnvironmentObject for state | Existing views | DashboardView state injection | NO — reuse directly |
| @StateObject for store | ContentView.swift | Dashboard navigation state | NO — use @State |
| ScrollView with padding | CommandCenterView.swift | Dashboard scroll container | NO — reuse directly |
| DarkGroupBoxStyle | DashboardView.swift | Dashboard section grouping | NO — reuse directly |
| StatusBadge component | DashboardView.swift | Header status indicators | NO — reuse directly |
| resourcePill stat helper | HealthView.swift (inline) | Indicator bar pills | NO — replicate inline |
| statPill helper | MissionView.swift (inline) | Metric pills | NO — replicate inline |
| scoreRing helper | IntelligenceView.swift (inline) | Health indicator ring | NO — replicate inline |
| .onAppear fade-in animation | DashboardView.swift | Dashboard loading transitions | NO — reuse directly |
| .supraCardStyle() modifier | SUPRAOSDesignSystem.swift | Card styling | NO — reuse directly |
| .cardHoverEffect() modifier | SUPRAOSDesignSystem.swift | Card hover | NO — reuse directly |
| .supraAccessibility() modifier | SUPRAOSDesignSystem.swift | Accessibility | NO — reuse directly |

---

## 3. Requires Extension (Minor Adaptations of Existing Patterns)

| Element | Current State | Required Extension | Reason | Abstraction Needed? |
|---------|--------------|-------------------|--------|---------------------|
| DashboardHeaderView | No consolidated header for unified dashboard needed | New view that wraps existing Header pattern with additional indicator strip | CommandCenterView header has no indicator bar | NO — new view, no new abstraction |
| DashboardNavigationView | CommandCenterView has no sidebar navigation | New view for section quick-navigation | Dashboard needs to let users jump to sections | NO — simple NavigationLink list |
| DashboardIndicatorsBar | No single-row consolidated indicators exist | New view that aggregates key metrics from RuntimeHealth and TowerSystemHealth | Needed for "at a glance" status | NO — composition of existing stat helpers |
| DashboardActionsBar | No quick-action bar exists | New view with Refresh, Acknowledge Alerts, and View All actions | Dashboard needs actionable controls | NO — simple HStack with buttons |
| G1_DashboardModels.swift | No dashboard layout configuration exists | Simple layout configuration model (grid columns, section ordering) | Needed for M1 milestone | MINIMAL — lightweight struct, no new abstraction |
| DashboardView integration into CommandCenterView | CommandCenterView does not reference DashboardView | Add DashboardView to CommandCenterView grid | G1 requires DashboardView to be part of Command Center | NO — additive change only |

---

## 4. New Implementation (Must Be Created)

| Element | Purpose | Size Estimate | Dependency |
|---------|---------|---------------|------------|
| `G1_DashboardView.swift` | Main unified dashboard view | ~100 lines | All existing views composed |
| `G1_DashboardModels.swift` | Layout configuration, grid specs, section ordering | ~40 lines | None |
| `DashboardModels.swift` (part of G1_DashboardModels.swift) | Grid column config, section definitions | ~40 lines | G1_DashboardModels.swift |
| Integration into `CommandCenterView.swift` | Add DashboardView to LazyVGrid | ~10 lines modification | G1_DashboardView.swift |
| `IMPLEMENTATION_DOSSIER_G1.md` | Full implementation plan | ~150 lines | All above |

---

## 5. Gap Summary

| Category | Count | Details |
|----------|-------|---------|
| Existing (reuse) | 15+ | Views, state models, UI components, design tokens, runtime services, patterns |
| Reusable patterns | 15+ | Grid layout, cards, stat cards, state injection, animations, modifiers |
| Requires extension | 6 | Header, navigation, indicators bar, actions bar, layout config, integration |
| New implementation | 5 | DashboardView, DashboardModels, CommandCenterView integration, dossier |
| New abstractions | 0 | No new frameworks, protocols, or services needed |
| Foundation modifications | 0 | No Runtime component changes |
| Hardcoded paths needed | 0 | All paths via SUPRAEnvironmentResolver |

---

## 6. Key Finding

The gap between the existing codebase and G1 Unified Dashboard is entirely within **UI composition**. Every data model, every state source, every UI component, every design token, and every runtime service is already present and functioning. The only new elements are:

1. A new `DashboardView` that composes existing views into a unified layout
2. A `DashboardHeaderView` with consolidated indicators
3. A `DashboardNavigationView` for quick section access
4. A `DashboardIndicatorsBar` for at-a-glance status
5. A `DashboardActionsBar` for quick-access actions
6. Integration wiring to add DashboardView to CommandCenterView

No new architectures, abstractions, protocols, services, or Foundation modifications are required.
