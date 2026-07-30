---
description: Router une mission vers le meilleur agent et modèle SUPRA.
agent: SUPRA-Router
---

Analyze the following mission and route it to the best SUPRA agent and model.

Mission: $ARGUMENTS

1. Classify the task type (architecture, swift, refactoring, analysis, research, documentation, debugging, review, runtime).
2. Consult the agent registry at .opencode/registry/agent_registry.json.
3. Consult the model registry at .opencode/registry/model_registry.json.
4. Consult the capability registry at .opencode/registry/capability_registry.json.
5. Consult the routing rules at .opencode/runtime/routing_rules.json.
6. Produce a routing plan with primary and fallback assignments.

Output a JSON routing plan with: task_type, primary_agent, primary_model, fallback_agent, fallback_model, strategy.
