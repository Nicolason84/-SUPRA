# SUPRA Router — Spécification V1

## Objectif

Router aiguille chaque mission vers le meilleur couple (agent, modèle) en fonction du type de tâche, de la disponibilité des modèles, du coût et des performances historiques.

## Architecture

```
Mission
  │
  ▼
┌─────────────────────────────────────────────────┐
│                  Router                          │
│                                                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────────┐  │
│  │Classifier│→│  Scorer  │→│  Selector    │  │
│  └──────────┘  └──────────┘  └──────────────┘  │
│       │              │              │            │
│       ▼              ▼              ▼            │
│  Capability     ModelRegistry   AgentRegistry    │
│  Registry                                       │
└─────────────────────────────────────────────────┘
                          │
                          ▼
                  Plan d'affectation
```

## Pipeline de routage

### 1. Classification de la mission

Le **Classifier** analyse la mission et détermine sa catégorie principale :

| Catégorie | Détection | Exemple |
|---|---|---|
| `architecture` | Contient "architecture", "design", "structure", "ADR" | "Proposer une architecture pour le module X" |
| `swift` | Contient "Swift", "implémenter", "créer", fichier `.swift` | "Implémenter la classe DashboardViewModel" |
| `refactoring` | Contient "refactor", "renommer", "extraire", "simplifier" | "Refactorer la méthode calculate()" |
| `analysis` | Contient "analyser", "audit", "vérifier", "conformité" | "Auditer le module de logging" |
| `research` | Contient "rechercher", "documentation", "comment", "pourquoi" | "Comment fonctionne le DI container ?" |
| `documentation` | Contient "documenter", "README", "commentaire", "wiki" | "Documenter l'API publique" |
| `debugging` | Contient "bug", "crash", "erreur", "issue", "plantage" | "Corriger le crash sur l'écran de login" |
| `review` | Contient "review", "relecture", "vérifier le code" | "Reviewer la PR #42" |
| `runtime` | Contient "runtime", "trace", "performance", "mémoire" | "Analyser la fuite mémoire" |

### 2. Scoring

Le **Scorer** calcule un score pour chaque couple (agent, modèle) disponible :

```
score = (task_match * 0.4) + (model_quality * 0.3) + (availability * 0.2) + (cost_efficiency * 0.1)
```

- `task_match`: correspondance entre la tâche et les capacités de l'agent (0-1)
- `model_quality`: score de performance du modèle sur ce type de tâche (0-1)
- `availability`: disponibilité actuelle du modèle (0-1, 0 = indisponible)
- `cost_efficiency`: ratio qualité/coût (0-1)

### 3. Sélection

Le **Selector** choisit le meilleur couple selon la stratégie active :

| Stratégie | Comportement | Quand l'utiliser |
|---|---|---|
| `default` | Meilleur score absolu | Usage général |
| `cost_optimized` | Meilleur ratio qualité/coût | Budget limité |
| `fastest` | Latence minimale | Missions urgentes |
| `consensus` | Top 3 exécutés en parallèle | Décisions critiques |
| `fallback` | Second meilleur si le premier échoue | Résilience |

## Modèle de routage par catégorie

| Catégorie | Agent primaire | Modèle primaire | Fallback agent | Fallback modèle |
|---|---|---|---|---|
| `architecture` | SUPRA-Architect | Claude Sonnet 4-6 | SUPRA-Research | Qwen 2.5 Coder 14b |
| `swift` | SUPRA-Builder | Claude Sonnet 4-6 | SUPRA-Refactor | DeepSeek Coder V2 16b |
| `refactoring` | SUPRA-Refactor | Claude Sonnet 4-6 | SUPRA-Builder | Qwen 2.5 Coder 14b |
| `analysis` | SUPRA-Auditor | Claude Sonnet 4-6 | SUPRA-Reviewer | Mixtral 8x7b |
| `research` | SUPRA-Research | Claude Sonnet 4-6 | SUPRA-Explorer | Llama 3.1 70b |
| `documentation` | SUPRA-Builder | Claude Sonnet 4-6 | SUPRA-Research | Qwen 2.5 32b |
| `debugging` | SUPRA-Runtime | Claude Sonnet 4-6 | SUPRA-Research | DeepSeek Coder V2 16b |
| `review` | SUPRA-Reviewer | Claude Sonnet 4-6 | SUPRA-Auditor | Qwen 2.5 Coder 14b |
| `runtime` | SUPRA-Runtime | Claude Sonnet 4-6 | SUPRA-Auditor | Mixtral 8x7b |

## Algorithmes de routage disponibles

| Algorithme | Description | Implémentation |
|---|---|---|
| **RoundRobin** | Distribution équitable entre agents disponibles | `routing/round_robin` |
| **WeightedRandom** | Sélection aléatoire pondérée par le score | `routing/weighted_random` |
| **LeastLoaded** | Agent avec le moins de tâches en cours | `routing/least_loaded` |
| **HistoryAware** | Favorise les agents ayant réussi des tâches similaires | `routing/history_aware` |
| **CostAware** | Minimise le coût total | `routing/cost_aware` |
| **Consensus** | Exécute plusieurs agents en parallèle, compare les résultats | `routing/consensus` |

## Interfaces

### Entrée

```json
{
  "mission": "string",
  "context": {
    "project": "SUPRA",
    "files": ["path/to/file.swift"],
    "urgency": "low" | "medium" | "high" | "critical",
    "budget_tokens": number,
    "preferred_models": ["model_id", "..."],
    "routing_strategy": "default" | "cost_optimized" | "fastest" | "consensus"
  }
}
```

### Sortie

```json
{
  "plan": [
    {
      "step_id": "string",
      "agent": "SUPRA-Builder",
      "model": "anthropic/claude-sonnet-4-6",
      "fallback_agent": "SUPRA-Refactor",
      "fallback_model": "ollama/qwen2.5-coder:14b",
      "task": "string",
      "priority": 1,
      "parallel": false
    }
  ],
  "strategy": "default",
  "estimated_cost_tokens": 5000
}
```

## Extensibilité

- Plugins de classification personnalisés
- Stratégies de routage additionnelles
- Intégration de nouveaux providers (Google, Mistral, Groq, Together)
- Règles de routage déclaratives dans un fichier de configuration
