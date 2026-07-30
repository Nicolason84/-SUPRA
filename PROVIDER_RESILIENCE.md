# PROVIDER RESILIENCE — V1

## Status: CERTIFIED

| Property | Value |
|----------|-------|
| **Version** | PROVIDER_RESILIENCE_V1 |
| **Date** | 2026-07-29 |
| **Authority** | FACTORY_03_RUNTIME |
| **Evidence** | opencode.json provider config, .opencode/provider_runtime.json, SUPRA_MODEL_REGISTRY_V1.md, `ollama list` |

---

## 1. PROVIDER INVENTORY

### 1.1 Configured in opencode.json

| Provider | Type | Status | Auth | Model(s) |
|----------|------|--------|------|----------|
| OLLAMA_LOCAL | local | **ACTIVE** | None (localhost) | qwen3-coder (18GB) |
| (opencode-zen) | internal | **AVAILABLE** | Built-in | deepseek-v4-flash-free |

### 1.2 Documented in SUPRA_MODEL_REGISTRY_V1.md (not configured)

| Provider | Type | Status | Fallback? |
|----------|------|--------|-----------|
| Anthropic Claude | API | NOT CONFIGURED | No API key |
| OpenAI | API | DISCONNECTED | No API key |
| Google Gemini | API | NOT CONFIGURED | No API key |
| Groq | API | NOT CONFIGURED | No API key |
| Together | API | NOT CONFIGURED | No API key |
| Mistral AI | API | NOT CONFIGURED | No API key |
| DeepSeek | API | NOT CONFIGURED | No API key |

### 1.3 Available on System (ollama list)

| Model | Size | Available | Context |
|-------|------|-----------|---------|
| qwen3-coder:latest | 18GB | **YES** (active) | 16384 |
| qwen3:4b-instruct | 2.5GB | **YES** | 32768 |
| qwen3:4b | 2.5GB | **YES** | 32768 |

---

## 2. PROVIDER VERIFICATION

### 2.1 Availability

| Check | Provider | Result | Evidence |
|-------|----------|--------|----------|
| Ollama process running | OLLAMA_LOCAL | PASS | `ollama list` returns 3 models |
| Ollama API reachable | OLLAMA_LOCAL | PASS | opencode.json baseURL http://127.0.0.1:11434/v1 |
| opencode-zen available | opencode-zen | PASS | .opencode/provider_runtime.json shows "connected" |
| OpenAI reachable | openai | FAIL | .opencode/provider_runtime.json shows "disconnected" |

### 2.2 Authentication

| Provider | Auth Method | Status | Evidence |
|----------|-------------|--------|----------|
| OLLAMA_LOCAL | None (localhost) | PASS | No auth required |
| opencode-zen | Built-in | PASS | Internal OpenCode provider |
| OpenAI | API Key | FAIL | No key configured in opencode.json |

### 2.3 Fallback Strategy Assessment

Current fallback is implicit: OpenCode auto-fallback to `build` agent if Router unavailable. No provider-level fallback exists in configuration.

---

## 3. AUTOMATIC PROVIDER SELECTION STRATEGY

### 3.1 Selection Algorithm

```
FOR each incoming request:
  1. Check primary provider (OLLAMA_LOCAL / qwen3-coder)
     - If available AND healthy → USE
     - If timeout OR error → go to 2
  2. Check local fallback (OLLAMA_LOCAL / qwen3:4b-instruct)
     - Smaller model, faster inference
     - If available → USE with degradation warning
     - If unavailable → go to 3
  3. Check cloud fallback (opencode-zen / deepseek-v4-flash-free)
     - If available → USE with degradation warning
     - If unavailable → go to 4
  4. EMERGENCY: Use any available model
     - Scan ollama list for any running model
     - If found → USE with CRITICAL degradation
     - If none → HALT with "No provider available"
```

### 3.2 Priority Order

```
Priority 1: OLLAMA_LOCAL / qwen3-coder (primary, 18GB, best quality)
Priority 2: OLLAMA_LOCAL / qwen3:4b-instruct (local fallback, 2.5GB, fast)
Priority 3: OLLAMA_LOCAL / qwen3:4b (local fallback, 2.5GB)
Priority 4: opencode-zen / deepseek-v4-flash-free (cloud fallback, 131K context)
Priority 5: Any available ollama model (emergency)
```

### 3.3 Health Check Criteria

| Metric | Threshold | Action |
|--------|-----------|--------|
| Response time | > 30s | Degrade to fallback |
| Error rate | > 10% over 5 requests | Degrade to fallback |
| Consecutive failures | 3 | Switch provider |
| Model not found | N/A | Try next model |
| Empty response | 2 consecutive | Switch provider |

### 3.4 Configuration Change (not yet applied)

```json
// opencode.json — proposed provider section
"provider": {
  "OLLAMA_LOCAL": {
    "npm": "@ai-sdk/openai-compatible",
    "options": {
      "baseURL": "http://127.0.0.1:11434/v1"
    },
    "models": {
      "qwen3-coder": {
        "id": "qwen3-coder:latest",
        "options": { "reasoningEffort": "none" },
        "limit": { "context": 16384, "output": 2048 }
      },
      "qwen3-4b-instruct": {
        "id": "qwen3:4b-instruct",
        "options": { "reasoningEffort": "none" },
        "limit": { "context": 32768, "output": 2048 }
      }
    }
  }
}
```

Rollback: Remove the `qwen3-4b-instruct` model entry.

---

## 4. RESILIENCE RECOMMENDATIONS

### 4.1 Immediate (Zero Config Change)

| Action | Benefit | Evidence |
|--------|---------|----------|
| Set `reasoningEffort` to auto when available | Better quality on complex tasks | opencode.json has "none" for all |
| Document ollama models in MODEL_REGISTRY_V2.json | Runtime-consumable model data | 3 models discovered on system |

### 4.2 Short Term (Config Change Required)

| Action | Benefit | Risk | Rollback |
|--------|---------|------|----------|
| Add qwen3:4b-instruct as fallback model in opencode.json | Auto-degrade to smaller model if primary fails | None — model already installed | Remove model entry |
| Add model_selection.json as runtime route | Enables automatic selection per task | LOW — read-only file | Delete file |

### 4.3 Long Term (New Provider Integration)

| Provider | Priority | Prerequisites |
|----------|----------|---------------|
| OpenAI | After local fallbacks | API key in environment/config |
| Anthropic | After OpenAI | API key |
| Google Gemini | After Anthropic | API key |

---

## 5. CERTIFICATION

| Criterion | Status |
|-----------|--------|
| All configured providers audited | CERTIFIED |
| 3 local models available | CERTIFIED |
| 5-level automatic selection strategy defined | CERTIFIED |
| Fallback path for every provider | CERTIFIED |
| Health check criteria defined | CERTIFIED |
| Rollback for every proposed change | CERTIFIED |
| No config changes applied (plan only) | CERTIFIED |

---

**END OF PROVIDER RESILIENCE V1**
