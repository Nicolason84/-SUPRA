# SUPRA ZERO — Agent Architecture

## Current State: AGENTS.md + opencode.json

The current agent system has **9 agents** defined in `AGENTS.md` and `opencode.json`:

| Agent | Mode | Can Edit? | Can Bash? | Role |
|-------|------|-----------|-----------|------|
| SUPRA-Architect | subagent | No | No | System architecture, ADR, structural validation |
| SUPRA-Builder | subagent | **Yes** | **Yes** | Implementation and code generation |
| SUPRA-Auditor | subagent | No | No | Compliance and integrity validation (READ ONLY) |
| SUPRA-Reviewer | subagent | No | No | Code review: style, conventions, performance |
| SUPRA-Explorer | subagent | No | No | Codebase navigation and structure understanding |
| SUPRA-Research | subagent | No | No | Technical research and documentation |
| SUPRA-Runtime | subagent | No | **Yes** | Runtime behavior analysis and diagnostic |
| SUPRA-Refactor | subagent | No | No | Safe refactoring without functional alteration |
| SUPRA-Router | subagent | No | **Yes** | Task routing to optimal agents/models |

## Actual Usage Analysis

| Agent | How Often Used | Effective? | Notes |
|-------|---------------|------------|-------|
| SUPRA-Builder | Most frequent | High | Primary writer |
| SUPRA-Architect | Moderate | High | ADR, structure decisions |
| SUPRA-Auditor | Frequent (past) | High | Compliance audits |
| SUPRA-Explorer | Moderate | High | Codebase discovery |
| SUPRA-Runtime | Moderate | Medium | Diagnostics |
| SUPRA-Reviewer | Low | Medium | Reviews are useful but not enforced |
| SUPRA-Research | Low | High | Web research when needed |
| SUPRA-Refactor | Low | Medium | Refactoring missions |
| SUPRA-Router | Low | Low | Overhead for simple tasks |

## Gaps Identified

| Missing Agent | Required For | Priority |
|---------------|-------------|----------|
| SUPRA-Sherpa | Context selection, theory navigation | HIGH |
| SUPRA-Cortex | Persistent memory management | HIGH |
| SUPRA-Theory | Knowledge/theory management | HIGH |
| SUPRA-Governance | Policy enforcement | MEDIUM |
| SUPRA-Product | Product/business decisions | MEDIUM |
| SUPRA-Plugin | Plugin lifecycle management | LOW |

## Global vs Project Agents

### Global Agents (Machine-wide, `~/.opencode/agents/`)
These should be available across all NOVA projects:
- SUPRA-Architect (architecture principles are universal)
- SUPRA-Auditor (compliance standards are universal)
- SUPRA-Research (web research is universal)

### Project Agents (Workspace-level, `.opencode/agents/`)
These are specific to the SUPRA workspace:
- SUPRA-Builder (SUPRA-specific code generation)
- SUPRA-Explorer (SUPRA-specific codebase)
- SUPRA-Runtime (SUPRA-specific runtime)
- SUPRA-Refactor (SUPRA-specific refactoring)
- SUPRA-Reviewer (SUPRA-specific review)
- SUPRA-Router (SUPRA-specific routing)
- SUPRA-Sherpa (SUPRA theory engine)
- SUPRA-Cortex (SUPRA memory)
- SUPRA-Theory (SUPRA theory library)

## Proposed Agent Architecture

```
GLOBAL (machine-level)
├── SUPRA-Architect     (read + webfetch)
├── SUPRA-Auditor       (read only)
├── SUPRA-Research      (read + webfetch + websearch)
└── SUPRA-Governance    (read only, policies)

PROJECT (workspace-level)
├── SUPRA-Builder       (read + edit + bash)     ← Single Writer
├── SUPRA-Explorer      (read)
├── SUPRA-Runtime       (read + bash)
├── SUPRA-Reviewer      (read)
├── SUPRA-Refactor      (read)
├── SUPRA-Router        (read + task + webfetch)
├── SUPRA-Sherpa        (read + theory)          ← NEW
├── SUPRA-Cortex        (read + memory)          ← NEW
├── SUPRA-Theory        (read + knowledge)       ← NEW
├── SUPRA-Plugin        (read)                   ← NEW
└── SUPRA-Product       (read + research)        ← NEW

DYNAMIC (mission-delegated)
├── SUPRA-MissionExecutor (ephemeral, per mission)
└── SUPRA-WorkflowRunner  (ephemeral, per workflow)
```

## Single Writer Rule

**SUPRA-Builder** remains the **ONLY** agent authorized to write files.
All other agents are strictly READ ONLY.

Exceptions require explicit mission authorization.

## Routing Rules

| Task Type | Router Decision | 
|-----------|----------------|
| Architecture decision | Route to SUPRA-Architect → SUPRA-Research |
| Code implementation | Route to SUPRA-Builder |
| Code review | Route to SUPRA-Reviewer |
| Bug diagnosis | Route to SUPRA-Runtime |
| Refactoring | Route to SUPRA-Refactor → SUPRA-Builder |
| Research | Route to SUPRA-Research |
| Knowledge query | Route to SUPRA-Theory |
| Memory query | Route to SUPRA-Cortex |
| Context selection | Route to SUPRA-Sherpa |
| Plugin management | Route to SUPRA-Plugin |

## Permissions Matrix

| Resource | Builder | Architect | Auditor | Explorer | Runtime | Router | Theory | Sherpa | Cortex |
|----------|---------|-----------|---------|----------|---------|--------|--------|--------|--------|
| Source files | **RW** | R | R | R | R | - | - | - | - |
| Config (.opencode) | **RW** | R | R | R | - | R | - | - | - |
| Tests | **RW** | R | R | R | R | - | - | - | - |
| Runtime state | **RW** | R | R | R | R | - | - | - | R |
| Knowledge graph | **RW** | R | R | R | - | - | R | R | R |
| Agent definitions | **RW** | R | R | - | - | R | - | - | - |
| Plugin manifests | **RW** | R | R | - | - | - | - | - | - |
| Mission queue | **RW** | R | R | - | R | R | - | R | R |

## Migration

1. Add the 3 new agents (Sherpa, Cortex, Theory) to AGENTS.md and opencode.json
2. Add SUPRA-Plugin and SUPRA-Product as optional
3. Decide which agents become global (architect, auditor, research)
4. No behavior changes during SUPRA ZERO — only definitions
