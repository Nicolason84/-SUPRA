# G1 Architecture Discovery Report

**Date**: 2026-07-29
**Phase**: 1 — Architecture Discovery
**Status**: COMPLETE
**Purpose**: Complete understanding of existing codebase before any implementation begins.

---

## 1. CommandCenterView (Existing)

**Location**: `SUPRA/CommandCenterView.swift`
**Purpose**: The primary operational dashboard — main user-facing view for the Command Center.
**State**: Consumes `SUPRACommandCenterState` via `@EnvironmentObject`.
**Layout**:
- Header: title, Live indicator, subtitle "Operational dashboard — read-only"
- Body: `LazyVGrid` with adaptive columns (min 260pt), containing:
  - `HealthView()` — system health, CPU/RAM/disk, projects, capabilities, agents
  - `RuntimeView()` — runtime connection, agents, active missions, last sync, gateway status
  - `MemoryView()` — CAnnoNico Memory sources, references, age
  - `MissionView()` — mission stats (total/active/blocked/completed), recent missions
  - `MultiMemoryView()` — multi-source memory view
  - `IntelligenceView()` — health score ring, anomaly count, insights, next action

**Key observations**:
- All views are `@EnvironmentObject` consumers of `SUPRACommandCenterState`
- Views are purely additive — no modification to Foundation
- The view is already a "dashboard" but lacks unified structure, navigation, and consolidated indicators
- Currently integrates G2 HealthMonitorView (already present in grid via HealthView)

---

## 2. DashboardView (Existing Legacy)

**Location**: `SUPRA/DashboardView.swift`
**Purpose**: Executive dashboard — older view using `RuntimeDataService`.
**State**: Uses `@ObservedObject var service: RuntimeDataService` (legacy data service).
**Layout**:
- Skeleton loading state
- Header with "EXECUTIVE DASHBOARD" title and status badges
- Stat cards grid (Missions, Runtime State, Providers, Agents, Quality, Success Rate)
- Execution Summary group box (pipeline duration, dispatched/completed/failed)
- Agent Summary group box (agent list with state indicators)

**Key observations**:
- This is a legacy view that predates SUPRACommandCenterState
- Uses RuntimeDataService which predates the Runtime Contract V1 and SUPRAEnvironmentResolver
- The existing CommandCenterView supersedes this view in the current architecture
- G1 should NOT modify this view — it is legacy and separate from the Command Center

---

## 3. ContentView (Top-Level)

**Location**: `SUPRA/ContentView.swift`
**Purpose**: Top-level app navigation with `NavigationSplitView`.
**State**: Uses `SUPRAExecutiveStore`, `@StateObject var store`.
**Navigation**: Sidebar navigation to different sections (workspace, command center, etc.).
**Key observation**: The `selection` state variable (`SUPRASection.ID?`) controls which view is displayed, including the Command Center section where G1 Dashboard will integrate.

---

## 4. SUPRACommandCenterState (Central State)

**Location**: `SUPRA/SUPRACommandCenterState.swift`
**Pattern**: `@MainActor`, `final class`, `ObservableObject`, singleton (`shared`).
**Dependencies** (all resolved via `SUPRAEnvironmentResolver` or direct singleton access):
- `SUPRAResourceGovernor.shared` — CPU, RAM, disk usage
- `SUPRAScheduler.shared` — background task scheduling
- `CAnnoNicoSnapshotStore.shared` — memory sources
- `RuntimeGateway.shared` — gateway connection status
- `SUPRACompositionRoot.shared.missionStore` — missions
- `MultiMemoryStore.shared` — multi-memory
- `SUPRAIntelligenceEngine.shared` — health score, insights
- `SUPRAMissionProposalEngine.shared` — copilot proposals
- `SUPRACompositionRoot.shared.runtimeMonitor` — runtime health

**Sections** (all `@Published private(set)`):
| Section | Type | Source |
|---------|------|--------|
| Health | CommandCenterSystemHealth | TowerSystemHealth |
| Missions | CommandCenterMissions | MissionStore |
| Resources | CommandCenterResources | SUPRAResourceGovernor + SUPRAScheduler |
| Cannonico | CommandCenterCannonico | CAnnoNicoSnapshotStore |
| Runtime | CommandCenterRuntime | RuntimeMonitor + RuntimeGateway |
| MultiMemory | CommandCenterMultiMemory | MultiMemoryStore |
| Intelligence | CommandCenterIntelligence | SUPRAIntelligenceEngine |
| Decision | CommandCenterDecision | MissionStore |
| Copilot | CommandCenterCopilot | SUPRAMissionObserver/ProposalEngine/Executor |
| Actions | CommandCenterActions | TowerStatus |

**Key observation**: This is the single source of truth for the Command Center. G1 DashboardView consumes this same state object — no new data models needed.

---

## 5. SUPRAEnvironmentResolver (Runtime Root)

**Location**: `SUPRA/SUPRAEnvironmentResolver.swift`
**Pattern**: `final class`, `ObservableObject`, singleton (`shared`).
**Key properties**:
- `projectRoot: String` — workspace root via `path(for: "workspaceRoot")`
- `workspaceRoot: String` — workspace root
- `gabrielConductorRoot: String` — Gabriel Conductor root
- `path(for:)` — canonical path resolution
- `state(for:)` — source state
- `resolve()` — resolves all 10+ environment identifiers

**Key observation**: G1 Dashboard views consume this resolver for any path-related needs. No hardcoded paths needed.

---

## 6. SUPRAOSDesignSystem (Design Tokens)

**Location**: `SUPRA/SUPRAOSDesignSystem.swift`
**Key tokens**:
| Token | Value | Purpose |
|-------|-------|---------|
| `spacingMini` | 4 | Tight spacing |
| `spacingTiny` | 8 | Small spacing |
| `spacingSmall` | 12 | Medium-small spacing |
| `spacing` | 20 | Standard spacing |
| `spacingLarge` | 24 | Large spacing |
| `paddingMini` | 6 | Tight padding |
| `paddingTiny` | 10 | Small padding |
| `paddingSmall` | 16 | Medium-small padding |
| `padding` | 24 | Standard padding |
| `paddingLarge` | 28 | Large padding |
| `cardHeight` | 200 | Default card height |
| `sidebarWidth` | 240 | Sidebar width |
| `minimumWindowWidth` | 1100 | Min window width |
| `minimumWindowHeight` | 680 | Min window height |
| `supraAccent` | blue-ish | Primary accent color |
| `supraBackground` | dark | Background color |
| `supraSurface` | dark | Surface color |
| `supraSurfaceLight` | dark-light | Light surface |
| `supraBorder` | white/0.08 | Border color |
| Colors | supraGreen, Red, Orange, Purple, Teal, Blue | Semantic colors |
| `Fonts.body` / `bodySmall` | Typography | Font sizes |

---

## 7. Reusable Components Inventory

### Reusable Views (existing, ready to compose)
| View | File | Consumes | Purpose |
|------|------|----------|---------|
| `HealthView` | HealthView.swift | SUPRACommandCenterState | System health, CPU/RAM/disk, projects, capabilities |
| `RuntimeView` | RuntimeView.swift | SUPRACommandCenterState | Runtime connection, agents, missions, sync |
| `MemoryView` | MemoryView.swift | SUPRACommandCenterState | CAnnoNico Memory sources and references |
| `MissionView` | MissionView.swift | SUPRACommandCenterState | Mission stats and recent missions |
| `MultiMemoryView` | MultiMemoryView.swift | SUPRACommandCenterState | Multi-source memory |
| `IntelligenceView` | IntelligenceView.swift | SUPRACommandCenterState | Health score ring, insights, next action |
| `HealthMonitorView` | HealthMonitorView.swift | RuntimeMonitor | G2 health alerts (already integrated) |

### Reusable State Models (existing, ready to consume)
| Model | File | Source |
|-------|------|--------|
| `CommandCenterSystemHealth` | SUPRACommandCenterState.swift | TowerSystemHealth |
| `CommandCenterMissions` | SUPRACommandCenterState.swift | MissionStore |
| `CommandCenterResources` | SUPRACommandCenterState.swift | SUPRAResourceGovernor |
| `CommandCenterRuntime` | SUPRACommandCenterState.swift | RuntimeMonitor + RuntimeGateway |
| `CommandCenterIntelligence` | SUPRACommandCenterState.swift | SUPRAIntelligenceEngine |
| `CommandCenterSnapshot` | SUPRACommandCenterState.swift | Aggregate of all sections |
| `SUPRACommandCenterState` | SUPRACommandCenterState.swift | Singleton `shared` |

### Reusable UI Components (existing, ready to use)
| Component | File | Purpose |
|-----------|------|---------|
| `SUPRAOSCard` | SUPRAOSDesignSystem.swift | Card container with title, subtitle, icon, color |
| `SUPRAOSStatCard` | SUPRAOSDesignSystem.swift | Stat card with label, value, icon, color |
| `DarkGroupBoxStyle` | DashboardView.swift | Dark group box style (reusable) |
| `StatusBadge` | DashboardView.swift | Status badge component |
| `StatusPill` | various views | Status pill component |
| `resourcePill` | various views | Resource usage pill |
| `statRow` | various views | Stat row helper |
| `statPill` | various views | Stat pill helper |
| `scoreRing` | IntelligenceView.swift | Circular score ring |
| `statBlock` | MemoryView.swift | Stat block component |

### Reusable Design System (existing, ready to reference)
| Token | Purpose |
|-------|---------|
| `SUPRAOSDesignSystem.cardHeight` | 200pt — standard card height |
| `SUPRAOSDesignSystem.padding` | 24pt — standard padding |
| `SUPRAOSDesignSystem.paddingSmall` | 16pt — small padding |
| `SUPRAOSDesignSystem.spacing` | 20pt — standard spacing |
| `SUPRAOSDesignSystem.spacingSmall` | 12pt — small spacing |
| `SUPRAOSDesignSystem.spacingMini` | 4pt — tight spacing |
| `SUPRAOSDesignSystem.cornerRadiusSmall` | 10pt — card corner radius |
| `SUPRAOSDesignSystem.cornerRadius` | 16pt — standard corner radius |
| `SUPRAOSDesignSystem.Fonts.body` | Body typography |
| `SUPRAOSDesignSystem.Fonts.bodySmall` | Small body typography |
| `SUPRAOSDesignSystem.Fonts.section` | Section header typography |
| `SUPRAOSDesignSystem.colors.*` | All semantic colors |
| `SUPRAOSDesignSystem.shadows.*` | Shadow definitions |
| `SUPRAOSDesignSystem.motion.*` | Animation constants |

### Existing Runtime Services Consumed
| Service | Access Pattern | Role |
|---------|---------------|------|
| SUPRACommandCenterState.shared | `@EnvironmentObject` | Central state for all dashboard views |
| SUPRAEnvironmentResolver.shared | Direct access | Runtime path resolution |
| SUPRAResourceGovernor.shared | Via SUPRACommandCenterState | CPU/RAM/disk metrics |
| SUPRAScheduler.shared | Via SUPRACommandCenterState | Background task scheduling |
| RuntimeMonitor | Via SUPRACommandCenterState | Runtime health and events |
| RuntimeGateway | Via SUPRACommandCenterState | Gateway connection status |
| RuntimeHealth | Via RuntimeMonitor | Health state (connection, sync, errors) |
| ControlTowerState | Via SUPRACommandCenterState | Control tower status |

---

## 8. Key Architectural Patterns

### Pattern 1: @EnvironmentObject for State
All existing views in the Command Center consume `SUPRACommandCenterState` via `@EnvironmentObject`. This is the established pattern. G1 DashboardView must follow this same pattern.

### Pattern 2: LazyVGrid for Card Layout
CommandCenterView uses `LazyVGrid(columns: [GridItem(.adaptive(minimum: 260))])` for responsive card layout. G1 DashboardView should use the same approach.

### Pattern 3: SUPRAOSCard for Card Containers
All existing views wrap their content in `SUPRAOSCard(title:subtitle:icon:color:)`. G1 DashboardView should use this component.

### Pattern 4: SUPRAOSDesignSystem Tokens
All spacing, padding, colors, fonts, and shadows reference `SUPRAOSDesignSystem.*` properties. No hardcoded values.

### Pattern 5: Additive Integration
New views are added to the grid — never replacing existing views. All changes are additive.

---

## 9. Architecture Findings

1. **CommandCenterView already contains all dashboard views** — HealthView, RuntimeView, MemoryView, MissionView, MultiMemoryView, IntelligenceView — plus HealthMonitorView (G2). G1 is about restructuring and enhancing these into a unified dashboard, not replacing them.

2. **SUPRACommandCenterState is the single source of truth** — all views consume it. No new state models needed.

3. **SUPRAOSCard and SUPRAOSStatCard are the reusable UI primitives** — no need to create new card components.

4. **The existing DashboardView is legacy** — it uses RuntimeDataService which predates the current architecture. G1 should not touch it.

5. **The Command Center header is already "dashboard-like"** but lacks unified navigation, consolidated status indicators, and section organization. G1 adds these.

6. **Zero Foundation components need modification** — all existing views, state, and design tokens are reusable as-is.

---

## 10. Reuse Summary

| Category | Count | Reuse Action |
|----------|-------|-------------|
| Views to compose | 6 | Reuse directly in DashboardView |
| State models | 10 | Reuse — consume SUPRACommandCenterState |
| UI components | 8 | Reuse — SUPRAOSCard, SUPRAOSStatCard, etc. |
| Design tokens | 30+ | Reference — SUPRAOSDesignSystem |
| Runtime services | 9 | Consume only — no modification |
| Design system | 6 categories | Reference — colors, fonts, spacing, shadows, motion |
| Existing patterns | 5 | Follow same patterns |

**Total new code required**: Only DashboardView.swift (G1_DashboardView.swift) and optional G1_DashboardModels.swift.
