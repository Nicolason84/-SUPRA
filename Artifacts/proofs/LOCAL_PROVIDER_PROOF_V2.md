# LOCAL_PROVIDER_PROOF_V2

**Date**: 2026-07-24
**Mission**: SUPRA_LOCAL_ENGINE_ROUTING_PHASE_D_V1
**Status**: ACTIVE_PROVIDER_CONFIRMED

---

## ACTIVE_PROVIDER

```
OLLAMA_LOCAL
```

**Not** OpenCode Zen, not Ling-3.0-flash Free, not any cloud provider.

## Active Model

```
qwen3:4b (Q4_K_M, 2.5 GB installed, ~3.2 GB loaded in GPU memory)
```

## Ollama PS Result

```
NAME        ID              SIZE      PROCESSOR    CONTEXT    UNTIL
qwen3:4b    359d7dd4bcda    3.2 GB    100% GPU     4096       4 minutes from now
```

Model is actively loaded on GPU, processing locally.

## Network Destination

```
http://localhost:11434/v1
```

Verified via:
- `curl http://localhost:11434/v1/models` → returns both models
- `curl http://localhost:11434/api/health` → healthy
- Ollama process (PID 1050) listens only on localhost:11434
- No ESTABLISHED remote connections for Ollama process

## Remote Requests

```
REMOTE_REQUESTS=0
```

Ollama serves exclusively on localhost. No outbound connections for inference.

## Cost

```
COST=0_EUR
```

No API keys, no subscriptions, no cloud usage, no quotas.

## OpenCode Configuration

**File**: `~/.config/opencode/opencode.jsonc` (modified)
**Backup**: `~/.config/opencode/opencode.jsonc.bak.20260724`

Provider config added:
- Provider name: `OLLAMA_LOCAL`
- BaseURL: `http://localhost:11434/v1`
- API Key: empty (not required)
- Model: `qwen3:4b` (FAST tier)
- Model also available: `qwen3.6:latest` (DEEP tier — too large for 16GB, not active)

## Proof Methodology

1. `ollama list` → qwen3:4b registered
2. `ollama ps` after inference → qwen3:4b loaded on GPU, 100% processor
3. `curl /v1/models` → both models listed (local endpoint only)
4. `curl /v1/chat/completions` → returns locally (no remote destination)
5. Ollama process network → localhost only, no external connections

## PASS STATUS

| Criterion | Value | VERDICT |
|-----------|-------|---------|
| ACTIVE_PROVIDER | OLLAMA_LOCAL | ✅ PASS |
| OLLAMA_PS shows active model | qwen3:4b on GPU | ✅ PASS |
| REMOTE_REQUESTS | 0 | ✅ PASS |
| COST | 0_EUR | ✅ PASS |
| API_KEY_REQUIRED | NO | ✅ PASS |
| CLOUD_MODEL | NONE | ✅ PASS |

## CONFIGURATION CHANGES

Only file modified: `~/.config/opencode/opencode.jsonc`
This is tooling configuration, not SUPRA business code.
CAnnoNico Bridge: untouched. SwiftUI: untouched. Runtime: untouched. SUPRA metier: untouched.

## NEXT PHASE

Phase 5 FREEZE — SUPRA_ZERO_COST_LOCAL_ROUTING_V1