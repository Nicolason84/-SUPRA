# ZERO_COST_TOOLCHAIN_AUDIT

**Date**: 2026-07-24
**Mission**: SUPRA_ZERO_COST_MODULAR_AI_TOOLCHAIN_V1
**Phase**: 0 READ ONLY AUDIT
**System**: Mac mini M5 / 16 GB RAM / arm64

---

## System State

| # | Item | Value | Category | Status |
|---|------|-------|----------|--------|
| 1 | macOS | 26.5.2 (26B2132h) | System | local/free |
| 2 | Architecture | Apple Silicon arm64 | System | local/free |
| 3 | RAM Physical | 16,0 GB | Hardware | free |
| 4 | RAM Available | ~79 MB (system under load) | Hardware | free |
| 5 | Disk Available | ~27 GB (of 460 GB) | Hardware | free |
| 6 | Ollama Version | 0.32.3 | AI Tool | local/free |
| 7 | OpenCode Version | 1.18.4 | AI Tool | local/free |
| 8 | Ollama Models Installed | qwen3.6:latest (23 GB), qwen3:4b (2.5 GB) | AI Model | local/free |
| 9 | Models Currently Loaded | NONE (ollama ps returns empty) | AI Model | unused |
| 10 | OpenCode Config Location | /Users/nicolasalonso/Desktop/NOVA_OS/SUPRA/opencode.json | Config | found |
| 11 | OpenCode Provider Configured | NONE — no ollama/openai/anthropic section in config | Config | gap |
| 12 | Cloud Providers Configured | NONE — no API keys in opencode.json | Config | clean |
| 13 | Ollama API (OpenAI compat) | Active at http://localhost:11434/v1/models | Service | local |
| 14 | Ollama Port | 11434 LISTEN | Network | local |
| 15 | Ollama Process | PID 1050 /Applications/Ollama.app/Contents/Resources/ollama serve | Process | local |
| 16 | OpenCode Process | PID 42637 (running with ollama launch) | Process | mixed |
| 17 | Another OpenCode | PID 40042 (separate session) | Process | mixed |
| 18 | Bash Language Server | PID 47473 (LSP for shell) | Process | local |
| 19 | Metal/MLX Capability | Not queryable via sysctl on this macOS build | Hardware | unknown |
| 20 | "Free limit reached" Behavior | OpenCode Zen + Ling-3.0-flash = cloud free tier with quota | Symptom | observed |

---

## Critical Finding: Provider Reality

### What the interface claims
- PROVIDER=OpenCode Zen
- MODEL=Ling-3.0-flash Free
- Monthly cost: $0.00

### What actually happens
The opencode.json contains **no provider configuration for Ollama**. It has no:
- baseURL pointing to localhost:11434
- ollama model list
- provider override

OpenCode Zen with Ling-3.0-flash Free is a **cloud service with quotas**. The $0 cost display is misleading because:
1. It uses the free tier of a cloud API
2. Free tiers have usage limits ("Free limit reached")
3. The model is NOT running locally
4. Quota exhaustion blocks access even though nominal cost is zero

### Ollama verification
- `ollama ps` returns empty: no model currently loaded in RAM
- `curl http://localhost:11434/v1/models` returns both models registered
- Ollama server IS running on port 11434
- But OpenCode is NOT configured to use it

### Network connections
- Ollama (PID 1050) has no ESTABLISHED connections to remote hosts (listens only on localhost)
- OpenCode (PID 42637) network connections blocked by timeout — requires deeper inspection

---

## Cost Classification

| Item | Category | Monthly Cost | Notes |
|------|----------|-------------|-------|
| Ollama 0.32.3 | gratuit local | 0 EUR | Open source |
| OpenCode 1.18.4 | gratuit local | 0 EUR | Open source |
| qwen3.6:latest | gratuit local | 0 EUR | Downloaded, GGUF |
| qwen3:4b | gratuit local | 0 EUR | Downloaded, GGUF |
| Apple Silicon Metal | hardware | 0 EUR | Included |
| OpenCode Zen (cloud) | payant/free tier | 0 EUR nominal | subject to quota, not guaranteed |
| Ling-3.0-flash Free | payant/free tier | 0 EUR nominal | subject to quota blocking |
| Ollama API (OpenAI compat) | gratuit local | 0 EUR | built-in |
| CAnnoNicoContracts package | gratuit local | 0 EUR | local swift package |

---

## FREEZE PROOF Status

| Criterion | Verified? | Evidence |
|-----------|-----------|----------|
| PROVIDER=OLLAMA_LOCAL | NO | OpenCode uses Zen/Ling cloud |
| REMOTE_REQUESTS=0 | UNKNOWN | Could not trace network calls |
| CLOUD_MODEL=NONE | NO | Ling-3.0-flash is cloud |
| API_KEY_REQUIRED=NO | YES | No keys in config |
| MONTHLY_COST=0_EUR | MISLEADING | Free tier quotas exist |

---

## Gap Analysis

1. OpenCode not configured for Ollama
2. No provider routing configuration exists
3. Current "free" model is cloud, not local
4. Ollama models are installed but not connected to OpenCode
5. No memory pressure management for 16 GB constraint
6. No fallback mechanism if cloud quota exhausted
7. No modular engine federation — single monolithic OpenCode setup

---

## Recommended Next Steps (V2)

Per SUPRA_ZERO_COST_ENGINE_FEDERATION_AND_MIGRATION_V2:
1. Phase B: Prove local provider routing
2. Phase C: Create engine contracts + registry (no SUPRA file changes)
3. Phase D: Configure Ollama as FAST route in opencode.json
4. Phase J: Benchmark and freeze