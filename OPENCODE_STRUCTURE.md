# OPENCODE_STRUCTURE.md

## Configuration OpenCode - SUPRA AI LAB

**Version:** 1.0
**Date:** 2026-07-28
**Config:** `opencode.json` (racine du projet)
**Schéma:** https://opencode.ai/config.json

---

## 1. Structure Globale

```
.opencode/
├── .gitignore
├── agent_permissions.json
├── agent_registry_runtime.json
├── builder_guard.json
├── delegation_rules.json
├── execution_pipeline.json
├── execution_runtime.json
├── execution_state.json
├── job_history.json
├── job_queue.json
├── job_scheduler.json
├── mission_archive.json
├── mission_center.json
├── mission_dashboard.json
├── mission_history.json
├── mission_queue.json
├── package.json
├── package-lock.json
├── parallel_strategy.json
├── priority_engine.json
├── provider_runtime.json
├── resource_manager.json
├── runtime_bindings.json
├── worker_pool.json
├── agents/                    # Définitions des 9 agents SUPRA
├── commands/                  # 8 commandes slash personnalisées
├── registry/                  # 4 registres (agents, capabilities, models, workflows)
├── runtime/                   # 10 fichiers de runtime routing/provider
├── skills/                    # (vide - pas de skills custom)
├── workflows/                 # 6 workflows prédéfinis
└── node_modules/              # Dépendances npm (zod)
```

---

## 2. Configuration Principale: `opencode.json`

### Provider & Modèles

```json
{
  "provider": {
    "OLLAMA_LOCAL": {
      "npm": "@ai-sdk/openai-compatible",
      "options": { "baseURL": "http://127.0.0.1:11434/v1" },
      "models": {
        "qwen3-coder": {
          "id": "qwen3-coder:latest",
          "options": { "reasoningEffort": "none" },
          "limit": { "context": 16384, "output": 2048 }
        }
      }
    }
  },
  "model": "OLLAMA_LOCAL/qwen3-coder",
  "small_model": "OLLAMA_LOCAL/qwen3-coder"
}
```

### Instructions & Agent Par Défaut

```json
{
  "instructions": ["AGENTS.md"],
  "default_agent": "build"
}
```

### LSP & Skills

```json
{
  "lsp": true,
  "skills": {
    "paths": [".opencode/skills", ".opencode/workflows"]
  }
}
```

---

## 3. Agents SUPRA (9 agents)

Tous en mode `subagent` avec permissions différenciées:

| Agent | Mode | Edit | Bash | Rôle |
|-------|------|------|------|------|
| **SUPRA-Architect** | subagent | deny | deny | Architecture, ADR, validation structurelle |
| **SUPRA-Builder** | subagent | allow | allow | Implémentation Swift, génération artefacts |
| **SUPRA-Auditor** | subagent | deny | deny | Conformité, sécurité, intégrité (READ ONLY) |
| **SUPRA-Reviewer** | subagent | deny | deny | Relecture code: style, perf, suggestions |
| **SUPRA-Explorer** | subagent | deny | deny | Navigation codebase, recherche, compréhension |
| **SUPRA-Research** | subagent | deny | deny | Recherche technique, documentation |
| **SUPRA-Runtime** | subagent | deny | allow | Analyse comportement runtime, diagnostic |
| **SUPRA-Refactor** | subagent | deny | deny | Refactoring sécurisé (READ ONLY → via Builder) |
| **SUPRA-Router** | subagent | deny | allow | Routage missions vers agent/modèle optimal |

### Fichiers Agents (`.opencode/agents/*.md`)

Chaque agent a un fichier Markdown détaillant:
- Description
- Instructions spécifiques
- Permissions effectives
- Modèles préférés
- Exemples d'usage

---

## 4. Commandes Slash (8 commandes)

| Commande | Agent | Description |
|----------|-------|-------------|
| `/supra-audit` | SUPRA-Auditor | Audit complet du code SUPRA |
| `/supra-build` | SUPRA-Builder | Implémentation/génération Swift |
| `/supra-benchmark` | SUPRA-Router | Benchmark modèles/agents |
| `/supra-review` | SUPRA-Reviewer | Relecture structurée |
| `/supra-router` | SUPRA-Router | Routage mission optimal |
| `/supra-runtime` | SUPRA-Runtime | Analyse comportement runtime |
| `/supra-search` | SUPRA-Explorer | Recherche code/docs |
| `/supra-status` | SUPRA-Router | État complet laboratoire |

---

## 5. Registres (`.opencode/registry/`)

### `agent_registry.json`
Registre runtime des agents disponibles avec statut, capacités, métriques.

### `capability_registry.json`
Catalogue des capacités techniques par agent (Swift, SwiftUI, Architecture, etc.)

### `model_registry.json`
Modèles LLM disponibles avec limites (contexte, output, reasoning).

### `workflow_registry.json`
Workflows enregistrés avec étapes, agents, conditions de transition.

---

## 6. Runtime & Routing (`.opencode/runtime/`)

| Fichier | Rôle |
|---------|------|
| `router.json` | Configuration routeur principal |
| `routing_policy.json` | Politiques de routage (coût, latence, capacité) |
| `routing_rules.json` | Règles de décision (task → agent/modèle) |
| `router_history.json` | Historique décisions routage |
| `router_learning.json` | Apprentissage continu du routeur |
| `router_memory.json` | Mémoire persistante routage |
| `router_scores.json` | Scores performance par agent/modèle |
| `provider_registry.json` | Registre providers LLM (Ollama, etc.) |
| `provider_health.json` | Santé providers (latence, erreurs, dispo) |
| `provider_capabilities.json` | Capacités par provider/modèle |
| `provider_statistics.json` | Statistiques d'usage |
| `fallbacks.json` | Chaînes de fallback modèles |

---

## 7. Workflows (`.opencode/workflows/`)

| Workflow | Fichier | Description |
|----------|---------|-------------|
| **Single Agent** | `single_agent.json` | Exécution agent unique |
| **Parallel** | `parallel.json` | Exécution parallèle multi-agents |
| **Fallback** | `fallback.json` | Chaîne de fallback sur échec |
| **Benchmark** | `benchmark.json` | Benchmark comparatif |
| **Review** | `review.json` | Workflow relecture code |
| **Consensus** | `consensus.json` | Consensus multi-agents |

---

## 8. État d'Exécution (Fichiers JSON dynamiques)

| Fichier | Contenu |
|---------|---------|
| `execution_state.json` | État courant pipeline |
| `execution_pipeline.json` | Pipeline d'exécution configuré |
| `execution_runtime.json` | Runtime d'exécution actif |
| `job_queue.json` | File d'attente jobs |
| `job_history.json` | Historique jobs exécutés |
| `job_scheduler.json` | Ordonnanceur jobs |
| `worker_pool.json` | Pool workers disponibles |
| `priority_engine.json` | Moteur de priorisation |
| `resource_manager.json` | Gestion ressources (CPU, RAM, tokens) |
| `runtime_bindings.json` | Liaisons runtime agents/providers |
| `parallel_strategy.json` | Stratégie parallélisation |
| `delegation_rules.json` | Règles délégation inter-agents |
| `mission_queue.json` | File missions |
| `mission_history.json` | Historique missions |
| `mission_center.json` | Centre de contrôle missions |
| `mission_dashboard.json` | Dashboard missions |
| `mission_archive.json` | Archive missions terminées |

---

## 9. Guards & Sécurité

| Fichier | Rôle |
|---------|------|
| `builder_guard.json` | Garde-fou Builder (seul writer autorisé) |
| `agent_permissions.json` | Matrice permissions par agent |
| `agent_registry_runtime.json` | Registre agents à l'exécution |

---

## 10. Références Externes (dans `opencode.json`)

| Ref | Fichier | Description |
|-----|---------|-------------|
| `lab-architecture` | `SUPRA_AI_LAB_ARCHITECTURE_V1.md` | Architecture complète lab |
| `agent-registry` | `SUPRA_AGENT_REGISTRY_V1.md` | Registre agents + permissions |
| `router-spec` | `SUPRA_ROUTER_SPECIFICATION_V1.md` | Spec routeur SUPRA |
| `model-registry` | `SUPRA_MODEL_REGISTRY_V1.md` | Registre modèles LLM |
| `workflow` | `SUPRA_WORKFLOW_V1.md` | Pipeline & workflows |

---

## 11. Pipeline SUPRA (Workflow Principal)

```
Mission → Executive → Architect → Router → Read Agents (READ ONLY)
                                                ↓
        Builder (WRITE ONLY) ← Comparator ← Fusion ← Validator
```

### Principe Single Writer
- **SUPRA-Builder** = SEUL agent autorisé à modifier des fichiers
- Tous les autres agents = **STRICTEMENT READ ONLY**
- Validation → Comparaison → Fusion → Builder écrit

---

## 12. Dépendances NPM (`.opencode/package.json`)

```json
{
  "dependencies": {
    "zod": "^3.22.0"  // Validation schémas (utilisé par workflows/runtime)
  }
}
```

- `node_modules/zod/` - Schémas de validation TypeScript/JavaScript
- Utilisé pour: validation registres, workflows, routing rules, provider configs

---

## 13. Fichiers de Config à la Racine

| Fichier | Rôle |
|---------|------|
| `opencode.json` | Config principale (ce doc) |
| `opencode.json.bak` | Backup précédent |
| `opencode.json.backup.20260724_164351` | Backup daté |
| `AGENTS.md` | Documentation agents (référencée dans config) |

---

## 14. Métriques Structure

- **Agents définis:** 9
- **Commandes slash:** 8
- **Workflows:** 6
- **Registres:** 4
- **Fichiers runtime:** 10
- **Fichiers état exécution:** 17
- **Fichiers guards/sécurité:** 3
- **Références externes:** 5
- **Dépendances npm:** 1 (zod)
- **Skills custom:** 0 (utilise workflows)

---

## 15. Points Clés d'Intégration SUPRA

1. **AGENTS.md** source de vérité pour définitions agents
2. **Single Writer Rule** appliqué via `builder_guard.json`
3. **Router** décide agent/modèle optimal par tâche
4. **Workflows** orchestrent missions complexes
5. **Runtime state** persistant dans `.opencode/*.json`
6. **Providers** gérés dynamiquement (Ollama local)
7. **LSP** activé pour navigation code Swift

---

*Généré automatiquement lors de CAMP_BASE_01_EXECUTION*
*Basé sur l'analyse de `.opencode/` et `opencode.json`*