# ENGINE CONTRACTS

**Mission**: SUPRA_ZERO_COST_ENGINE_FEDERATION_AND_MIGRATION_V2
**Format**: JSON Schema versionné

---

## EngineDescriptorV1

```json
{
  "$schema": "engine-descriptor-v1",
  "engine_id": "string",
  "engine_role": "InferenceEngine|CodeEngine|ReasoningEngine|VisionEngine|EmbeddingEngine|RetrievalEngine|ValidationEngine",
  "provider": "string",
  "model": "string",
  "local": true,
  "capabilities": ["completion","tools","thinking","vision","code","embedding"],
  "context_limit": 16384,
  "memory_estimate_mb": 4096,
  "input_schema": {},
  "output_schema": {},
  "health": "http://localhost:11434/api/health",
  "cost_policy": "LOCAL_STRICT|FREE_TIER_ALLOWED|PAID_DISABLED",
  "fallbacks": ["string"]
}
```

## EngineCapabilityV1

```json
{
  "$schema": "engine-capability-v1",
  "engine_id": "string",
  "capability": "code|vision|embedding|reasoning|completion|tools|structured_output",
  "confidence": 0.0,
  "context_limit": 0,
  "supports_tools": false,
  "supports_structured_output": false,
  "supports_vision": false,
  "max_tokens_output": 4096
}
```

## EngineRequestV1

```json
{
  "$schema": "engine-request-v1",
  "request_id": "uuid",
  "mission_id": "uuid",
  "engine_id": "string",
  "task": "string",
  "context_pack": "MICRO|MODULE|PROJECT|RECOVERY",
  "input": "string",
  "expected_output_schema": {},
  "max_tokens": 4096,
  "temperature": 0.1,
  "timeout_seconds": 120
}
```

## EngineResultV1

```json
{
  "$schema": "engine-result-v1",
  "request_id": "uuid",
  "mission_id": "uuid",
  "engine_id": "string",
  "provider": "string",
  "model": "string",
  "local": true,
  "started_at": "iso8601",
  "completed_at": "iso8601",
  "input_hash": "sha256",
  "output": "string",
  "artifacts": [],
  "tool_calls": [],
  "warnings": [],
  "validation": "PENDING|VALIDATED|REJECTED",
  "cost_eur": 0.0,
  "memory_peak_mb": 0,
  "tokens_input": 0,
  "tokens_output": 0,
  "tokens_per_second": 0.0
}
```

## EngineHealthV1

```json
{
  "$schema": "engine-health-v1",
  "engine_id": "string",
  "status": "REGISTERED|AVAILABLE|BUSY|DEGRADED|OFFLINE|QUARANTINED",
  "last_check": "iso8601",
  "response_time_ms": 0,
  "memory_mb": 0,
  "error": "string|null"
}
```

## EngineBenchmarkV1

```json
{
  "$schema": "engine-benchmark-v1",
  "engine_id": "string",
  "task": "string",
  "first_token_ms": 0,
  "tokens_per_second": 0.0,
  "total_duration_ms": 0,
  "peak_memory_mb": 0,
  "cpu_percent": 0.0,
  "quality_score": 0.0,
  "compilable_patches": 0,
  "hallucinations": 0,
  "stability": "PASS|FAIL"
}
```

## EngineRoutingDecisionV1

```json
{
  "$schema": "engine-routing-decision-v1",
  "task": "string",
  "selected_engine_id": "string",
  "why_selected": "string",
  "alternatives": [],
  "rejection_reasons": [],
  "expected_ram_mb": 0,
  "expected_cost_eur": 0.0,
  "expected_context_tokens": 0,
  "timestamp": "iso8601"
}
```