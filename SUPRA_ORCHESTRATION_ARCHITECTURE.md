# SUPRA Orchestration Architecture

## Principes Fondateurs

1. **SUPRA ne dépend d'aucun provider** — Ollama, DeepSeek, OpenAI, Anthropic, Gemini, LM Studio, OpenRouter, vLLM sont tous des plugins interchangeables
2. **SUPRA ne dépend d'aucun modèle** — Les modèles sont des ressources déclarées par les plugins
3. **SUPRA dépend uniquement de contrats** — Protocols Swift, rien d'autre
4. **Le Kernel est indépendant** — Aucune référence à un provider ou modèle dans le noyau

## Architecture Cible

```
Mission
  ↓
Understanding (SUPRADecisionEngine)
  ↓
Planning (SUPRAExecutionPlanner)
  ↓
Decision Engine (SUPRADecisionEngine)
  ↓
Execution Planner (SUPRAExecutionPlanner)
  ↓
Capability Broker (SUPRACapabilityBroker)
  ↓
Routing Policy (SUPRARoutingPolicy)
  ↓
Provider Broker (SUPRAProviderBroker v2 — applique, ne décide pas)
  ↓
Provider Registry (SUPRAProviderPluginRegistry)
  ↓
Provider Plugin (SUPRAProviderPlugin)
  ↓
Model Registry (intégré dans chaque plugin)
  ↓
Model (SUPRAProviderModelDeclaration)
  ↓
Execution
  ↓
Validation (SUPRAExecutionPlanner)
  ↓
Memory (SUPRALearningEngine)
  ↓
Learning (SUPRALearningEngine)
  ↓
UI Refresh
```

## Architecture en couches

```
┌─────────────────────────────────────────────────────┐
│                 COUCHE DÉCISION                      │
│  SUPRADecisionEngine                                │
│  SUPRAUnderstanding + SUPRAOrchestrationDecision     │
└───────────────────────┬─────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│                 COUCHE PLANIFICATION                 │
│  SUPRAExecutionPlanner                              │
│  SUPRAExecutionPlan + SUPRAExecutionTask             │
└───────────────────────┬─────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│                 COUCHE ROUTAGE                       │
│  SUPRARoutingPolicy                                 │
│  SUPRARoutingRequirements + SUPRAProviderSelection   │
│  SUPRAScheduler + SUPRAFallbackEngine                │
└───────────────────────┬─────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│                 COUCHE PLUGINS                       │
│  SUPRAPluginRegistry + SUPRAProviderPluginRegistry   │
│  SUPRAPluginDiscovery                               │
│  SUPRAPlugin (protocol) + SUPRAProviderPlugin        │
└───────────────────────┬─────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│                 COUCHE PROVIDER                      │
│  SUPRAOllamaProvider (exemple de plugin concret)     │
│  OpenAIProvider (extensible)                         │
│  AnthropicProvider (extensible)                      │
└───────────────────────┬─────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│                 COUCHE OBSERVABILITÉ                 │
│  SUPRARuntimeRegistry (fusion de tous les registres) │
│  SUPRARuntimeGraph (graphe vivant)                   │
│  SUPRARuntimeMetrics (métriques temps réel)          │
│  SUPRARuntimeEvents (événements runtime)             │
│  SUPRARuntimeLogger (logging pipeline)               │
│  SUPRALearningEngine (apprentissage automatique)     │
└─────────────────────────────────────────────────────┘
```

## Fichiers créés (12 nouveaux)

| Fichier | Couche | Rôle |
|---------|--------|------|
| SUPRADecisionEngine.swift | Décision | Analyse, compréhension, décision d'orchestration |
| SUPRAExecutionPlanner.swift | Planification | Plan d'exécution, graphe de dépendances |
| SUPRARoutingPolicy.swift | Routage | Sélection provider/modèle par politique |
| SUPRAFallbackEngine.swift | Routage | Fallback automatique multi-providers |
| SUPRAScheduler.swift | Routage | Ordonnancement des tâches d'exécution |
| SUPRAPluginRegistry.swift | Plugins | Registre générique de plugins |
| SUPRAPluginDiscovery.swift | Plugins | Découverte automatique au démarrage |
| SUPRARuntimeRegistry.swift | Fusion | Fusion de tous les registres |
| SUPRARuntimeGraph.swift | Observabilité | Graphe vivant du runtime |
| SUPRARuntimeMetrics.swift | Observabilité | Métriques temps réel |
| SUPRARuntimeEvents.swift | Observabilité | Système d'événements |
| SUPRALearningEngine.swift | Apprentissage | Mémorisation et optimisation |

## Fichiers refactorisés (2)

| Fichier | Changement |
|---------|-----------|
| SUPRAOllamaProvider.swift | Refactorisé en SUPRAProviderPlugin (conforme au nouveau protocole) |
| SUPRAAliveDemo.swift | Utilise le nouveau pipeline d'orchestration |

## Flux d'exécution complet

```
1. bootstrap() → SUPRAPluginDiscovery.discoverAll() → enregistre tous les plugins
2. decide(missionTitle:prompt:) → SUPRADecisionEngine décide les étapes d'orchestration
3. plan(decision:) → SUPRAExecutionPlanner transforme la décision en plan
4. selectProvider(for:) → SUPRARoutingPolicy sélectionne le meilleur provider/modèle
5. executeWithFallback(...) → SUPRAFallbackEngine exécute avec fallback automatique
6. SUPRARuntimeMetrics enregistre les métriques
7. SUPRALearningEngine met à jour les scores
8. SUPRARuntimeEvents émet les événements
9. SUPRARuntimeGraph met à jour le graphe
```

## Zéro dépendance — Preuve

Le fichier SUPRADecisionEngine.swift contient :
- ZERO référence à Ollama
- ZERO référence à OpenAI
- ZERO référence à un modèle spécifique
- ZERO enum de providers

Le Kernel ne connaît que des contrats (String-based identifiers).
