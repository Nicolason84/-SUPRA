# SUPRA FLOW MARKER V1
## Existing capabilities distributed across nodes and edges — no new engine

DATE=2026-09-21
AUTHORITY=NICOLAS
STATUS=CANONICAL_CONTRACT

NO_NEW_ENGINE=YES
NO_NEW_BRIDGE=YES
NO_NEW_RUNTIME=YES

## 1. PRINCIPLE

SUPRA must not create another orchestration engine.

Existing engines, workers, capabilities, runtimes and connectors are attached to canonical nodes and edges.

The only new element is a lightweight FLOW MARKER carried with observable work.

The marker does not execute anything.
It only makes circulation measurable and attributable.

## 2. TOPOLOGY

NODE
= canonical responsibility / capability owner / operational station.

EDGE
= real circulation between two nodes.

EXAMPLES:

WORLD → FRANCE
FRANCE → EVIDENCE
EVIDENCE → CANNONICO
CANNONICO → DECISION
DECISION → MISSIONS
MISSIONS → RUNTIME
RUNTIME → RESULT
RESULT → MEMORY
MEMORY → CANNONICO

PUBLIC_PRESENCE → COMMERCIAL
COMMERCIAL → REVENUE
REVENUE → FINANCE
FINANCE → ACCOUNTING
ACCOUNTING → PATRIMONY

INPI → LEGAL
LEGAL → CONTROL
CONTROL → HUMAN_GATE
HUMAN_GATE → MISSION_RESUME

## 3. EXISTING CAPABILITY DISTRIBUTION

Do not duplicate capabilities.

Attach existing components to the node where their responsibility is canonical.

Examples:

SUPRAChatRuntimeAdapter
→ CHAT / bounded conversational execution edge

SUPRAGrandeMissionRunner
→ MISSIONS

SUPRAProcessObservatory
→ RUNTIME / observation

SUPRAGabrielConductorRuntime
→ RUNTIME worker pool / parallel read-only-reversible work

Decision Twin outputs
→ CONTROL

INPIOfficialConnector
→ INPI

XOfficialConnector
→ PUBLIC_PRESENCE

CAnnoNicoIntegrationBridge
→ CANNONICO

ArtifactReader historical sources
→ PATRIMONY/HISTORICAL only, not current health

## 4. FLOW MARKER

Every observable work unit may carry:

flow_id
trace_id
span_id
parent_span_id
mission_id
phase_id
node_id
previous_node_id
edge_id
source_ref
authority
human_gate
created_at
entered_at
started_at
finished_at
queue_ms
service_ms
wait_ms
status
outcome
retry_count
evidence_refs
memory_return
canon_return

No secret may be embedded.

## 5. MARKER LIFECYCLE

CREATE once at flow origin.

PROPAGATE through every node/edge.

FORK when work fans out in parallel:
same flow_id
same trace_id
new span_id per branch
parent_span_id preserved

JOIN when branches converge:
aggregate child spans
do not invent completion until all required children resolve.

STOP when:
- explicit human gate
- hard blocker
- failed dependency
- authority boundary
- terminal result

RESUME:
same flow_id
same trace_id
new span_id
link to blocked span

## 6. FLUIDITY METRICS

Measured from marker timestamps only.

Per edge:
- queue latency
- service latency
- total transit time
- retry count
- error count
- throughput
- backpressure
- idle time
- blocked time

Per node:
- inflow
- outflow
- work in progress
- oldest item age
- completion rate
- failure rate
- human-gate age

Per flow:
- end-to-end latency
- materialization rate
- number of hops
- blocked duration
- evidence-return completeness
- memory-return completeness
- canon-return completeness

## 7. FLUIDITY STATES

FREE_FLOW
PROGRESSING
CONGESTED
STALLED
BLOCKED
DEGRADED
RECOVERING
COMPLETE

Rules:

FREE_FLOW
= sustained forward movement, low queueing, no unresolved blocker.

PROGRESSING
= forward movement with normal queueing.

CONGESTED
= queue/wait time rising faster than service completion.

STALLED
= no meaningful forward event beyond threshold.

BLOCKED
= explicit dependency or human gate.

DEGRADED
= rising errors/retries/drift with reduced throughput.

RECOVERING
= movement resumed after blocked/stalled/degraded state.

COMPLETE
= terminal result plus required memory/canon return.

No decorative state.

## 8. EDGE MARKERS

Every canonical edge should have a visible marker:

SOURCE_NODE
→ TARGET_NODE

with:

current_flow_count
throughput_per_minute
median_transit_ms
p95_transit_ms when enough samples exist
blocked_count
oldest_blocked_age
last_material_event
fluidity_state

## 9. DISTRIBUTION LAW

When a mission arrives:

1. resolve canonical owner node
2. reuse existing capability at that node
3. if independent subtasks exist, distribute to existing workers
4. attach child markers
5. preserve Single Writer Rule for canonical writes
6. merge results at the owning node
7. continue along the canonical edge
8. return evidence + memory + canon

No arbitrary worker receives a write just because capacity exists.

## 10. FAST SAFE

Parallelism is allowed only when:
- tasks are independent
- work is read-only or reversible
- canonical writer is not contested
- evidence-return contract is preserved

The marker lets Runtime observe whether extra parallelism actually improves flow.

If queueing/retries rise:
reduce concurrency.

If throughput rises with stable error rate:
maintain or increase within bounded limit.

This is adaptive routing, not a new engine.

## 11. HUMAN GATE

At a human gate:

marker.status=BLOCKED
marker.outcome=AWAITING_NICOLAS

The marker records:
decision_question
options
evidence_refs
blocked_since

When Nicolas answers:
same flow_id resumes
new span_id
parent_span_id points to blocked span

## 12. VISUALIZATION

In the NOVA ERA organism:

node size
= current relevant work volume

edge intensity
= measured throughput

edge pulse speed
= observed transit velocity

orange accumulation
= congestion/bottleneck

violet stop
= Nicolas required

green continuation
= machine can continue

dimmed edge
= stale/no recent evidence

broken edge
= disconnected/failed

Every visual must be derivable from marker data.

## 13. ACCEPTANCE

PASS only if:

- zero new engine/runtime/bridge created
- existing capabilities are mapped to canonical nodes
- marker propagates across mission/runtime/result/memory path
- fork/join lineage is preserved
- human-gate pause/resume preserves same trace
- node/edge fluidity can be computed from real timestamps
- no fake score
- no loss of evidence lineage
- Single Writer Rule remains intact
