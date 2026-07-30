# SUPRA AI Lab — Architecture V1

## Objectif

Plateforme d'orchestration IA modulaire, multi-modèle, multi-agent.
Compatible OpenCode, Ollama, OpenAI, modèles locaux et gratuits.
Conçue pour le développement, l'audit et le refactoring de code Swift.

## Modules

---

### SUPRA-Router

| Propriété | Valeur |
|---|---|
| **Mission** | Aiguiller chaque mission vers le meilleur agent-modèle selon la tâche, la disponibilité et le coût. |
| **Responsabilités** | Analyse de la mission, consultation du Capability/Model Registry, affectation agent+modèle, équilibrage de charge, fallback. |
| **Entrées** | Mission (texte structuré + métadonnées), registres (agents, modèles, capacités). |
| **Sorties** | Plan d'affectation : liste `{agent, modèle, priorité, fallback}`. |
| **Dépendances** | SUPRA-AgentRegistry, SUPRA-ModelRegistry, SUPRA-CapabilityRegistry. |
| **Interfaces publiques** | `route(mission) → plan`, `health() → status` |
| **Extensibilité** | Plugins de routage personnalisés (cost-aware, latency-aware, random). |
| **Remplaçable** | OUI |

---

### SUPRA-Planner

| Propriété | Valeur |
|---|---|
| **Mission** | Décomposer une mission en étapes atomiques avec dépendances et ordonnancement. |
| **Responsabilités** | Analyse de la mission, génération de DAG, détection de parallélisation, estimation de ressources. |
| **Entrées** | Mission, contraintes (temps, budget, qualité). |
| **Sorties** | DAG de tâches : `{id, type, dépendances, agent_cible, priorité}`. |
| **Dépendances** | SUPRA-Router, SUPRA-Memory. |
| **Interfaces publiques** | `plan(mission, constraints) → dag` |
| **Extensibilité** | Stratégies de planification (topologique, greedy, ML-guided). |
| **Remplaçable** | OUI |

---

### SUPRA-Memory

| Propriété | Valeur |
|---|---|
| **Mission** | Stocker et retrouver le contexte, les décisions et les patterns des missions passées. |
| **Responsabilités** | Indexation vectorielle, recherche sémantique, stockage clé-valeur, gestion des versions. |
| **Entrées** | Requête (embedding + filtres), paire clé-valeur à stocker. |
| **Sorties** | Contexte pertinent : documents, décisions ADR, patterns, artefacts. |
| **Dépendances** | SUPRA-Learning (mise à jour), tous les modules (consommation). |
| **Interfaces publiques** | `store(namespace, key, value)`, `query(embedding, filter) → results`, `recall(context_id) → context` |
| **Extensibilité** | Backends de stockage (chroma, sqlite, redis, filesystem). |
| **Remplaçable** | OUI |

---

### SUPRA-AgentRegistry

| Propriété | Valeur |
|---|---|
| **Mission** | Catalogue central de tous les agents disponibles avec leurs capacités, permissions et état. |
| **Responsabilités** | Enregistrement, découverte, health-check, cycle de vie des agents. |
| **Entrées** | Définition d'agent (nom, rôle, permissions, modèle, outils). |
| **Sorties** | Fiche agent complète + état (disponible, occupé, dégradé). |
| **Dépendances** | SUPRA-CapabilityRegistry. |
| **Interfaces publiques** | `register(agent_def)`, `resolve(capability) → [agent]`, `status(agent_id) → state` |
| **Extensibilité** | Agents natifs OpenCode, agents personnalisés, agents distants. |
| **Remplaçable** | NON (cœur du système) |

---

### SUPRA-ModelRegistry

| Propriété | Valeur |
|---|---|
| **Mission** | Catalogue des modèles LLM disponibles avec leurs capacités, coûts et disponibilités. |
| **Responsabilités** | Détection automatique (Ollama), enregistrement manuel, health-check, roté de coûts. |
| **Entrées** | Modèle (provider, name, capabilities). |
| **Sorties** | Fiche modèle : capacités, coût/token, statut, latence moyenne. |
| **Dépendances** | Aucune. |
| **Interfaces publiques** | `register(model_def)`, `list(filters) → [model]`, `best_for(task) → model` |
| **Extensibilité** | Providers: Ollama, OpenAI, Anthropic, Google, locaux. |
| **Remplaçable** | NON (cœur du système) |

---

### SUPRA-CapabilityRegistry

| Propriété | Valeur |
|---|---|
| **Mission** | Graphe de correspondance entre tâches, agents et modèles. |
| **Responsabilités** | Classification des tâches, mapping tâche → compétence requise, scoring de confiance. |
| **Entrées** | Tâche ou besoin exprimé en langage naturel. |
| **Sorties** | Liste ordonnée des couples `(agent, modèle)` capables de traiter la tâche. |
| **Dépendances** | SUPRA-AgentRegistry, SUPRA-ModelRegistry. |
| **Interfaces publiques** | `find_capable(task) → [(agent, model, score)]` |
| **Extensibilité** | Règles déclaratives, classifieur ML, extraction par LLM. |
| **Remplaçable** | OUI |

---

### SUPRA-PromptRegistry

| Propriété | Valeur |
|---|---|
| **Mission** | Bibliothèque versionnée de prompts optimisés par tâche et par modèle. |
| **Responsabilités** | Stockage, versionnement, A/B testing, optimisation automatique via SUPRA-Learning. |
| **Entrées** | Prompt + métadonnées (version, tâche, modèle cible, score). |
| **Sorties** | Prompt versionné. |
| **Dépendances** | SUPRA-Learning, SUPRA-Builder. |
| **Interfaces publiques** | `get(task, model) → prompt`, `register(prompt, meta)`, `optimize(prompt_id, feedback)` |
| **Extensibilité** | Templates Jinja, injection de contexte dynamique. |
| **Remplaçable** | OUI |

---

### SUPRA-WorkflowEngine

| Propriété | Valeur |
|---|---|
| **Mission** | Ordonnancer et exécuter le pipeline complet de bout en bout. |
| **Responsabilités** | Exécution du DAG, parallélisation, gestion des erreurs, retry, timeouts, logging. |
| **Entrées** | DAG du Planner, modules disponibles. |
| **Sorties** | Résultat final de la mission + traces d'exécution. |
| **Dépendances** | Tous les modules. |
| **Interfaces publiques** | `execute(dag) → result`, `cancel(mission_id)`, `status(mission_id) → state` |
| **Extensibilité** | Hooks pré/post exécution, plugins de transformation. |
| **Remplaçable** | NON (cœur du système) |

---

### SUPRA-Comparator

| Propriété | Valeur |
|---|---|
| **Mission** | Comparer les sorties de plusieurs agents/modèles pour identifier divergences et consensus. |
| **Responsabilités** | Analyse sémantique, détection de conflits, scoring de confiance. |
| **Entrées** | Sorties multiples (code, texte, décisions). |
| **Sorties** | Matrice de comparaison, score de consensus, divergences classifiées. |
| **Dépendances** | SUPRA-FusionEngine, SUPRA-Router. |
| **Interfaces publiques** | `compare(outputs) → matrix` |
| **Extensibilité** | Stratégies de comparaison (textuelle, structurelle, sémantique). |
| **Remplaçable** | OUI |

---

### SUPRA-FusionEngine

| Propriété | Valeur |
|---|---|
| **Mission** | Fusionner des sorties multiples en un résultat unique cohérent. |
| **Responsabilités** | Vote majoritaire, weighted merge, synthèse, résolution de conflits. |
| **Entrées** | Sorties multiples + matrice de comparaison. |
| **Sorties** | Résultat fusionné. |
| **Dépendances** | SUPRA-Comparator. |
| **Interfaces publiques** | `fuse(outputs, matrix) → result` |
| **Extensibilité** | Stratégies: majority, weighted, llm-mediation, hierarchical. |
| **Remplaçable** | OUI |

---

### SUPRA-Validator

| Propriété | Valeur |
|---|---|
| **Mission** | Valider le résultat final contre les critères d'acceptation de la mission. |
| **Responsabilités** | Vérification formelle, tests, conformité, scoring qualité. |
| **Entrées** | Résultat fusionné, critères d'acceptation, tests. |
| **Sorties** | Rapport de validation : pass/fail, couverture, score. |
| **Dépendances** | SUPRA-FusionEngine, SUPRA-Benchmark. |
| **Interfaces publiques** | `validate(result, criteria) → report` |
| **Extensibilité** | Règles personnalisées, validateurs externes (SwiftLint, tests Xcode). |
| **Remplaçable** | OUI |

---

### SUPRA-Benchmark

| Propriété | Valeur |
|---|---|
| **Mission** | Évaluer les performances des modèles et agents sur des jeux de tests standardisés. |
| **Responsabilités** | Exécution de benchmarks, collecte de métriques, génération de rapports. |
| **Entrées** | Modèles/agents à tester, jeux de tests, métriques cibles. |
| **Sorties** | Scores de performance, classement, tendances. |
| **Dépendances** | SUPRA-ModelRegistry, SUPRA-Learning. |
| **Interfaces publiques** | `run(benchmark_suite) → scores`, `compare(model_a, model_b) → delta` |
| **Extensibilité** | Suites de benchmarks personnalisées, intégration CI/CD. |
| **Remplaçable** | OUI |

---

### SUPRA-Learning

| Propriété | Valeur |
|---|---|
| **Mission** | Améliorer les modules par rétroaction continue. |
| **Responsabilités** | Feedback loops, optimisation de prompts, fine-tuning, mise à jour des règles. |
| **Entrées** | Résultats, métriques, feedback utilisateur, échecs. |
| **Sorties** | Prompts optimisés, règles mises à jour, poids ajustés. |
| **Dépendances** | SUPRA-ModelRegistry, SUPRA-PromptRegistry. |
| **Interfaces publiques** | `learn_from(outcome, metrics)`, `optimize_prompt(prompt_id, feedback)` |
| **Extensibilité** | Reinforcement learning, online learning, hot-swap de stratégies. |
| **Remplaçable** | OUI |

---

### SUPRA-Metrics

| Propriété | Valeur |
|---|---|
| **Mission** | Collecter, agréger et exposer les métriques de tous les modules en temps réel. |
| **Responsabilités** | Instrumentation, tableaux de bord, alertes, export. |
| **Entrées** | Événements de tous les modules. |
| **Sorties** | Métriques temps réel, historiques, rapports. |
| **Dépendances** | Tous les modules (consommation d'événements). |
| **Interfaces publiques** | `record(event)`, `query(metric, window) → values`, `alert(rule)` |
| **Extensibilité** | Backends: stdout, Prometheus, Grafana, filesystem. |
| **Remplaçable** | OUI |

---

## Principes de communication

- Bus de messages asynchrone (pub/sub).
- Événements structurés en JSON.
- Modules isolés : pas d'appels directs.
- WorkflowEngine est le seul orchestrateur.

## Contraintes

- Aucun couplage fort entre modules.
- Chaque module expose des interfaces (ports) et consomme des interfaces (adapters).
- Compatible OpenCode (agents natifs), Ollama, OpenAI, modèles locaux.
- Priorité aux modèles gratuits et open-source.
