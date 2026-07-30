# COGNITIVE LOAD REPORT

**Date**: 2026-07-29  
**Council**: Cognitive Psychologist, Information Architect, UX Researcher  
**Focus**: Mental effort required to use SUPRA

---

## EXECUTIVE SUMMARY

SUPRA imposes **moderate-to-high cognitive load** on the user. The application requires conscious effort to navigate, interpret, and operate. This is the primary reason SUPRA does not disappear — the user must constantly think about the tool rather than their work.

---

## COGNITIVE LOAD DIMENSIONS

### 1. Visual Noise

**Score: 5/10** — Moderate noise

| Source | Severity | Detail |
|--------|----------|--------|
| Status badges everywhere | HIGH | PASS, WARN, FAIL, RUNNING, ACTIVE, WAIT badges appear on every card, every row, every panel. Each badge demands a split-second of visual processing. |
| Color coding without legend | MEDIUM | Green/orange/red semantic colors are used but never explained. The user must infer meaning. |
| Multiple visual languages | HIGH | Legacy ContentView and ExecutiveWindow use different spacing, padding, corner radii, and colors. The brain detects these inconsistencies subconsciously, adding cognitive friction. |
| KPI cards without context | MEDIUM | Numbers appear without comparison. "Missions: 12" — the brain must decide if 12 is good, bad, or expected. |

### 2. Information Density

**Score: 5/10** — Moderate density

The cockpit presents 6 KPI cards, 4 panel sections (health, missions, knowledge, discovery), alerts, and a timeline — all on one scrollable page. Each panel contains labeled data.

The Mission Center shows a mode picker, a search bar, a filter toolbar, and a list of missions. Each mission row shows 4-5 data points (status, priority, category, owner).

**Problem**: Information is presented at uniform visual weight. Nothing is emphasized. The brain must process everything to find relevance.

### 3. Decision Fatigue

**Score: 6/10** — Low-to-moderate fatigue

SUPRA's autonomous decision-making actually helps here. The system handles routine decisions automatically, reducing the number of choices the user must make.

**However**:
- The sidebar presents 9 equally-weighted options at all times
- The cockpit presents ~15 information elements simultaneously
- Empty states force the user to decide what to do next without guidance

### 4. Attention Switching

**Score: 5/10** — High switching cost

| Switch | Cost | Detail |
|--------|------|--------|
| Between sidebar spaces | HIGH | Context is not preserved. Switching from Cockpit to Missions resets the view. Returning to Cockpit requires re-scanning. |
| Between modes | HIGH | Mission Center's "Supervision" vs "Mission Library" mode forces the user to maintain two mental models. |
| Between panels | MEDIUM | Each panel in the cockpit is independent. The user builds a fragmented mental model. |

**Recommended**: When the user returns to a space, the last state should be restored (scroll position, selected item, expanded sections).

### 5. Reading Rhythm

**Score: 5/10** — Interrupted rhythm

The reading flow is interrupted by:
- Mixed typography (10pt captions next to 26pt titles)
- Varied spacing (different padding values between sections)
- Multiple visual styles (some cards with icons, some without)
- Status badges breaking text flow

### 6. Eye Movement

**Score: 4/10** — Inefficient scanning

The cockpit layout requires the eye to travel in an Z-pattern across the header, then jump to the KPI grid (2 rows × 3 columns), then scan down the left column (health, missions) and right column (knowledge, discovery, decisions, alerts, timeline).

**Problem**: The irregular grid does not create a predictable scanning pattern. The eye cannot find a rhythm.

**Fix**: Consider a 2-column layout with consistent card heights. Or a single-column layout with clear visual hierarchy.

### 7. Hierarchy Clarity

**Score: 6/10** — Partially clear

The design system's typography scale creates clear hierarchy (largeTitle → title → title2 → title3 → body → caption). Colors distinguish primary from secondary text.

**Problem**: Within content areas, hierarchy collapses. In Mission Detail view, objectives, tasks, dependencies, timeline, and status all appear at the same visual level. The brain cannot prioritize.

### 8. Scanning Speed

**Score: 5/10** — Slow scanning

To find a specific piece of information (e.g., "what is the status of mission X?"), the user must:
1. Navigate to Mission Center (1 click/shortcut)
2. Scan the mission list
3. Read each row's status, priority, category, owner
4. Click the mission
5. Scan the detail view
6. Find the status section

This is 6 cognitive steps for a simple question. Ideally, it should be 2-3.

### 9. Memory Load

**Score: 4/10** — High memory load

| Memory burden | Detail |
|---------------|--------|
| 9 sidebar spaces | User must remember what each space contains |
| Multiple filter states | Mission Center has search, filter, and mode |
| No recents | Cannot quickly return to previous context |
| No bookmarks | Cannot save frequently accessed locations |
| No history | Navigation history is not tracked |

### 10. Task Continuity

**Score: 6/10** — Moderate continuity

Missions provide task continuity — the user can return to a mission and continue. The autonomous system maintains context across sessions.

**Break points**:
- Switching spaces resets the view
- No "go back" shortcut
- Navigation feels like "starting over" each time
- No breadcrumb trail

### 11. Context Preservation

**Score: 3/10** — Poor context preservation

| Context | Preserved? | Detail |
|---------|-----------|--------|
| Scroll position | ❌ | Lost on navigation |
| Selected item | ❌ | Lost on navigation |
| Expand/collapse state | ❌ | Lost on navigation |
| Search query | ❌ | Cleared on navigation |
| Window position | ❌ | Not saved between launches |
| Sidebar selection | ❌ | Not persisted to disk |
| Inspector state | ❌ | Not persisted to disk |

---

## COGNITIVE LOAD HEAT MAP

```
┌─────────────────────────────────────────────────────┐
│  HEADER                                             │
│  Version Badge │ Status Badge │ Bell │ Inspector    │  ← MODERATE LOAD
├─────────────────────────────────────────────────────┤
│  SIDEBAR │  MAIN CONTENT AREA           │ INSPECTOR │
│           │                            │           │
│  9 items  │  KPI grid (6 cards)        │ Context   │  ← HIGH LOAD
│  at same  │  Panels (4-5 sections)     │ info      │
│  level    │  Alerts                    │           │
│           │  Timeline                  │           │
│           │                            │           │
│  Each     │  Each section has          │           │
│  requires │  its own layout,           │ 60% empty │
│  decision │  spacing, visual weight    │           │
└───────────┴────────────────────────────┴───────────┘
                     │
                     ▼
            COGNITIVE BOTTLENECK:
            User must process ~20 elements
            simultaneously to understand state
```

---

## THE THREE COGNITIVE PEAKS

SUPRA imposes three peaks of cognitive demand during normal use:

### Peak 1: Launch
**Cognitive cost**: HIGH
```
1. See boot screen
2. Read status message
3. Wait for boot steps
4. Click "Continue to Cockpit"
5. Orient to the cockpit layout (15+ elements)
6. Decide where to navigate
```
**Solution**: Auto-boot for returning users. Zero-click entry.

### Peak 2: Navigation Decision
**Cognitive cost**: MEDIUM
```
1. Decide what to do next
2. Scan 9 sidebar items
3. Recall what each contains
4. Navigate
5. Re-orient to new space layout
```
**Solution**: Group sidebar items. Add recents. Preserve context.

### Peak 3: Information Processing
**Cognitive cost**: HIGH
```
1. Look at a panel or list
2. Identify what each data point means
3. Determine its relevance
4. Remember it or act on it
5. Switch to next panel
6. Repeat
```
**Solution**: Add visual priority. Use color and size to indicate importance. Show the answer, not the data.

---

## THE COGNITIVE LOAD INDEX

| Factor | Current Score | Target Score |
|--------|--------------|--------------|
| Visual noise | 5 | 8 |
| Information density | 5 | 7 |
| Decision fatigue | 6 | 8 |
| Attention switching cost | 5 | 7 |
| Reading rhythm | 5 | 8 |
| Eye movement efficiency | 4 | 7 |
| Hierarchy clarity | 6 | 8 |
| Scanning speed | 5 | 7 |
| Memory load | 4 | 7 |
| Task continuity | 6 | 8 |
| Context preservation | 3 | 8 |
| **Average** | **4.9** | **7.5** |

---

## RECOMMENDATIONS

### Immediate (High Impact, Low Effort)

1. **Add recents to sidebar** — last 3 visited spaces at the top
2. **Preserve scroll position** — when returning to a space, restore scroll
3. **Group sidebar items** — reduce 9 flat items to 3 groups of 2-3
4. **Add KPI context** — show trend arrows or min/max ranges next to numbers
5. **Reduce badge noise** — show status badges only when status is not "pass"

### Medium Term (High Impact, Medium Effort)

6. **Add global search** (⌘F) — one search box finds anything everywhere
7. **Add breadcrumb navigation** — show current location path
8. **Unified layout system** — consistent card heights, predictable grids
9. **Context-aware UI** — hide irrelevant spaces, show suggested next actions
10. **Add bookmarks/favorites** — user marks frequently accessed items

### Long Term (High Impact, High Effort)

11. **Predictive navigation** — sidebar highlights the space most relevant to current context
12. **Progressive disclosure** — show summary first, expand on demand
13. **Natural language query bar** — "show me missions that completed yesterday"
14. **Adaptive visual density** — power user mode shows more detail, novice mode shows less
15. **Unified activity stream** — replace 5 separate data sources with one canonical timeline
