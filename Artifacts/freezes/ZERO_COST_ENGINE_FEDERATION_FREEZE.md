# ZERO_COST_ENGINE_FEDERATION_AND_MIGRATION_V2 — FREEZE

**Date**: 2026-07-24
**FREEZE Tag**: `SUPRA_ZERO_COST_ENGINE_FEDERATION_V2`
**Build**: Build not required — configuration only (no SUPRA file modifications)
**CAnnoNicoBridge**: Intact, no modifications

---

## PHASE A — READ ONLY AUDIT : COMPLETE ✅

### System state
| # | Item | Value | Category |
|---|------|-------|----------|
| 1 | macOS | 26.5.2 | local/free |
| 2 | Arch | arm64 Apple Silicon | local/free |
| 3 | RAM | 16 GB (Free physical RAM ~79 MB under load) | local/free |
| 4 | Disk | 27 GB free (of 460 GB) | local/free |
| 5 | Ollama | 0.32.3 | local/free |
| 6 | OpenCode | 1.18.4 | local/free |
| 7 | Models installed | qwen3.6:latest (23 GB), qwen3:4b (2.5 GB) | local/free |
| 8 | Models loaded | NONE (ollama ps empty) | unused |
| 9 | Port 11434 | LISTEN, no remote connections | local |
| 10 | OpenCode provider | OpenCode Zen / Ling-3.0-flash Free (cloud) | CLOUD/QUOTA |
| 11 | API keys in config | NONE | clean |
| 12 | Free limit risk | YES — observed | cloud |

### CRITICAL FINDING
OpenCode displays `PROVIDER=OpenCode Zen / MODEL=Ling-3.0-flash Free`.
The opencode.json contains **no Ollama provider configuration**:
- No baseURL pointing to localhost:11434
- No ollama model list
- No provider override

The "$0.00 cost" is misleading — it uses the cloud free tier with quota limits.
**ZERO COST IS NOT PROVEN** until OpenCode is reconfigured for Ollama local.

### Ollama verification
- `curl http://localhost:11434/api/tags` → 2 models registered ✅
- `curl http://localhost:11434/v1/models` → OpenAI compatible response ✅
- `ollama ps` → no models loaded (RAM) — models available but not active
- Ollama server listening on localhost:11434, no remote connections ✅

---

## PHASE B — LOCAL ROUTING PROVEN : IN PROGRESS ⏳

### Finding: local routing NOT yet active for OpenCode
- OpenCode is calling cloud provider (Zen/Ling)
- Ollama local is available but not wired to OpenCode
- Phase B requires: configure opencode.json to point to Ollama
- After config change: re-validate with `curl` and `ollama ps`

### Reversal test planned
```
1. Launch Ollama → confirm models available (DONE)
2. Configure OpenCode ollama provider → baseURL http://localhost:11434/v1
3. Run `opencode` → check ollama ps shows model loaded
4. Check network → confirm NO remote connections for OpenCode
5. If model appears in ollama ps + no remote → LOCAL_ONLY_VERDICT=PROVEN
6. If model NOT in ollama ps → reconfigure step 2
```

---

## PHASE C — CONTRACTS AND REGISTRY : COMPLETE ✅

### Files produced (outside SUPRA, in Artifacts/)
- `ENGINE_CONTRACTS.md` — 8 JSON schemas (EngineDescriptorV1, EngineCapabilityV1, EngineRequestV1, EngineResultV1, EngineHealthV1, EngineBenchmarkV1, EngineMigrationPlanV1, EngineRoutingDecisionV1)
- `ENGINE_REGISTRY.json` — 4 registered engines (ollama.qwen3-fast, ollama.qwen3-deep, shell-validation, sourcekit-validation) + 3 engines not yet installed (embeddinggemma, deepseek-coder-v2-lite, gemma3-4b)
- `ENGINE_ROUTING_MATRIX.tsv` — 8 routing decisions with engine_id, RAM estimate, cost (0 EUR), why_selected, fallback

---

## PHASE D — CONFIGURE LOCAL FAST ROUTE : PENDING (requires OpenCode config edit)

### Planned
1. Backup current opencode.json → opencode.json.bak.20260724
2. Add provider ollama section to opencode.json:
   ```json
   {
     "provider": {
       "ollama": {
         "url": "http://localhost:11434/v1",
         "models": ["qwen3:4b", "qwen3.6:latest"]
       }
     },
     "model": "qwen3:4b"
   }
   ```
3. Test with `opencode` — verify ollama ps shows model loaded
4. Verify no remote connections from OpenCode process

### STOP CONDITIONS per mission
- ❌ no modification of SUPRA files
- ✅ Only opencode.json outside SUPRA directory will be modified
- opencode.json is NOT a SUPRA file (it is in the dotfiles/config layer)

---

## PHASE E-J : EXECUTION PLAN

| Phase | Action | Status |
|-------|--------|--------|
| E | Test local FAST route with ollama qwen3:4b | PENDING (needs config) |
| F | Add CODE route (qwen3.6:latest) | PENDING |
| G | Add VISION route (qwen3.6:latest has vision) | PENDING |
| H | Add MEMORY route (embeddinggemma — not yet downloaded) | PENDING |
| I | Composition + migration protocol | PENDING |
| J | Benchmark + FREEZE | PENDING |

---

## MANDATORY MONTHLY COST

MANDATORY_MONTHLY_COST = 0_EUR

This is contingent on Phase D completing the OpenCode → Ollama wiring. Until then, the actual cost is UNKNOWN (free tier cloud with quota).

---

## ARTIFACTS PRODUCED

1. Artifacts/ZERO_COST_TOOLCHAIN_AUDIT.md — Phase 0 audit
2. Artifacts/LOCAL_PROVIDER_PROOF.md — provider routing verification
3. Artifacts/ENGINE_FEDERATION_ARCHITECTURE.md — 7-layer architecture
4. Artifacts/ENGINE_CONTRACTS.md — 8 JSON schema contracts
5. Artifacts/ENGINE_REGISTRY.json — canonical engine registry
6. Artifacts/ENGINE_ROUTING_MATRIX.tsv — routing decision matrix
7. Artifacts/ZERO_COST_ENGINE_FEDERATION_FREEZE.md — this document

---

## VALIDATION CHECKLIST (when complete)

- [ ] every engine functions independently
- [ ] every engine can be replaced (adapter pattern)
- [ ] consumers depend on contracts only
- [ ] engines can be combined (sequential/parallel/ensemble)
- [ ] no direct provider calls from UI
- [ ] no hard dependency on OpenCode Zen
- [ ] no hard dependency on Ollama
- [ ] Ollama is initial local impl, not the canon
- [ ] migration proven in shadow mode
- [ ] rollback tested
- [ ] monthly cost = 0 EUR
- [ ] offline mode validated
- [ ] SUPRA metier intact
- [ ] CAnnoNico Bridge intact

---

## FREEZE

**SUPRA_ZERO_COST_ENGINE_FEDERATION_V2**

Next action required: Phase D — configure OpenCode to use Ollama local provider.