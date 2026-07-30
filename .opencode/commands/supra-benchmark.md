---
description: Exécuter un benchmark sur les modèles ou agents SUPRA.
agent: SUPRA-Router
---

Run a benchmark on SUPRA models and agents.

Benchmark configuration: $ARGUMENTS

1. Consult .opencode/benchmarks/ for benchmark definitions.
2. Consult .opencode/registry/model_registry.json for model targets.
3. Consult .opencode/registry/agent_registry.json for agent targets.
4. Execute the benchmark by testing each target against the task suite.
5. Collect metrics: latency, quality score, token usage, success rate.
6. Produce a comparative report.

Output a benchmark report with: target, task, latency_ms, quality_score, tokens_used, success, rank.
