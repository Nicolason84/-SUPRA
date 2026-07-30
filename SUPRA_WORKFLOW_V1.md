# SUPRA Workflow — V1

## Pipeline complet

```
Utilisateur
    │
    ▼
┌────────────────────────────────────────────────────┐
│ ① SUPRA-Planner                                   │
│   - Analyse la mission                            │
│   - Décompose en DAG de tâches                     │
│   - Détecte les dépendances et parallélismes       │
└──────────────────────┬─────────────────────────────┘
                        │ DAG
                        ▼
┌────────────────────────────────────────────────────┐
│ ② SUPRA-Router                                    │
│   - Consulte CapabilityRegistry                   │
│   - Consulte ModelRegistry                        │
│   - Consulte AgentRegistry                        │
│   - Produit le plan d'affectation                  │
└──────────────────────┬─────────────────────────────┘
                        │ Plan
                        ▼
┌────────────────────────────────────────────────────┐
│ ③ SUPRA-WorkflowEngine                            │
│   - Ordonnance l'exécution du DAG                  │
│   - Gère la parallélisation                        │
│   - Gère les dépendances                           │
└──────────────────────┬─────────────────────────────┘
                        │
          ┌─────────────┼─────────────┐
          ▼             ▼             ▼
   ┌──────────┐  ┌──────────┐  ┌──────────┐
   │ Agent 1  │  │ Agent 2  │  │ Agent N  │
   │ (étape A)│  │ (étape B)│  │ (étape C)│
   │          │  │          │  │          │
   │ Modèle X │  │ Modèle Y │  │ Modèle Z │
   └────┬─────┘  └────┬─────┘  └────┬─────┘
        │             │             │
        └─────────────┼─────────────┘
                      │ Sorties multiples
                      ▼
┌────────────────────────────────────────────────────┐
│ ④ SUPRA-Comparator                                 │
│   - Compare les sorties des agents                 │
│   - Calcule la matrice de comparaison              │
│   - Détecte les divergences et consensus           │
└──────────────────────┬─────────────────────────────┘
                        │ Matrice
                        ▼
┌────────────────────────────────────────────────────┐
│ ⑤ SUPRA-FusionEngine                               │
│   - Fusionne les résultats selon stratégie         │
│     (majority, weighted, llm-mediation)            │
│   - Résout les conflits                            │
└──────────────────────┬─────────────────────────────┘
                        │ Résultat fusionné
                        ▼
┌────────────────────────────────────────────────────┐
│ ⑥ SUPRA-Validator                                  │
│   - Valide contre les critères d'acceptation       │
│   - Exécute les tests                              │
│   - Produit le rapport de validation               │
└──────────────────────┬─────────────────────────────┘
                        │
                    ┌───┴───┐
                    │       │
                   FAIL    PASS
                    │       │
                    │       ▼
                    │   ┌─────────────────────────────────┐
                    │   │ ⑦ SUPRA-Learning                │
                    │   │   - Enregistre le résultat      │
                    │   │   - Optimise les prompts        │
                    │   │   - Met à jour les scores       │
                    │   └────────────┬────────────────────┘
                    │                │
                    │                ▼
                    │         ┌─────────────────────────────────┐
                    │         │ ⑧ SUPRA-Memory                  │
                    │         │   - Stocke le contexte          │
                    │         │   - Indexe les décisions ADR    │
                    │         │   - Archive les artefacts       │
                    │         └────────────┬────────────────────┘
                    │                      │
                    │                      ▼
                    │                 Résultat final
                    │
                    ▼
            Retour au Planner
            (re-planification si FAIL)

```

## Détail des étapes

### ① Planner

- **Entrée**: Mission utilisateur brute (texte)
- **Traitement**:
  1. Extraction de l'intention
  2. Décomposition en sous-tâches atomiques
  3. Identification des dépendances entre tâches
  4. Détection des parallélismes possibles
  5. Estimation du coût (temps, tokens)
- **Sortie**: DAG de tâches au format JSON

```json
{
  "mission_id": "uuid",
  "dag": {
    "nodes": [
      {"id": "task_1", "type": "analysis", "depends_on": [], "agent": null},
      {"id": "task_2", "type": "implementation", "depends_on": ["task_1"], "agent": null},
      {"id": "task_3", "type": "audit", "depends_on": ["task_2"], "agent": null}
    ],
    "parallel_groups": [["task_2"], ["task_3"]]
  },
  "estimated_cost_tokens": 15000
}
```

### ② Router

- **Entrée**: DAG du Planner
- **Traitement**:
  1. Pour chaque nœud, classifier la tâche
  2. Consulter AgentRegistry, ModelRegistry, CapabilityRegistry
  3. Calculer le score pour chaque couple (agent, modèle)
  4. Sélectionner le meilleur couple selon la stratégie
  5. Ajouter les fallbacks
- **Sortie**: Plan d'affectation

```json
{
  "assignments": [
    {
      "task_id": "task_1",
      "agent": "SUPRA-Auditor",
      "model": "anthropic/claude-sonnet-4-6",
      "fallback": {"agent": "SUPRA-Research", "model": "ollama/qwen2.5-coder:14b"},
      "priority": 1,
      "parallel": false
    }
  ]
}
```

### ③ WorkflowEngine

- **Entrée**: DAG + Plan d'affectation
- **Traitement**:
  1. Résoudre l'ordre d'exécution (topological sort)
  2. Lancer les tâches sans dépendance en parallèle
  3. Attendre les dépendances avant de lancer les suivantes
  4. Gérer les erreurs (retry, fallback, timeout)
  5. Collecter les sorties
- **Sortie**: Sorties brutes de chaque agent

### ④ Comparator

- **Entrée**: Sorties multiples d'une même étape (si routage en mode consensus)
- **Traitement**:
  1. Alignement sémantique des sorties
  2. Calcul des similarités/différences
  3. Classification des divergences (mineures, majeures, contradictoires)
  4. Calcul du score de consensus
- **Sortie**: Matrice de comparaison

```json
{
  "step_id": "task_2",
  "outputs": [
    {"agent": "SUPRA-Builder", "model": "claude-sonnet-4-6", "content": "..."},
    {"agent": "SUPRA-Refactor", "model": "qwen2.5-coder:14b", "content": "..."}
  ],
  "comparison": {
    "consensus_score": 0.85,
    "divergences": [
      {"type": "minor", "description": "Différence de nommage", "sources": ["agent_1", "agent_2"]}
    ],
    "agreements": [
      {"description": "Structure identique", "confidence": 0.95}
    ]
  }
}
```

### ⑤ FusionEngine

- **Entrée**: Sorties + Matrice de comparaison
- **Traitement**:
  1. Si consensus_score > 0.8 → prendre la sortie la mieux notée
  2. Si 0.5 < consensus_score < 0.8 → weighted merge
  3. Si consensus_score < 0.5 → LLM-mediation (modèle plus fort synthétise)
- **Sortie**: Résultat fusionné

### ⑥ Validator

- **Entrée**: Résultat fusionné + Critères d'acceptation
- **Traitement**:
  1. Vérification formelle (structure, syntaxe, types)
  2. Exécution des tests si applicables
  3. Vérification des critères de qualité
  4. Scoring (0-100)
- **Sortie**: Rapport de validation

```json
{
  "mission_id": "uuid",
  "result": "PASS",
  "score": 92,
  "checks": [
    {"name": "compilation", "status": "PASS"},
    {"name": "tests_unitaires", "status": "PASS", "coverage": 87},
    {"name": "conformité_swiftlint", "status": "PASS", "warnings": 3},
    {"name": "critères_acceptation", "status": "PASS"}
  ],
  "artifacts": ["path/to/generated/file.swift"]
}
```

### ⑦ Learning

- **Entrée**: Résultat de la mission + Métriques + Feedback
- **Traitement**:
  1. Enregistrer le succès/échec
  2. Mettre à jour les scores des modèles pour cette catégorie de tâche
  3. Optimiser les prompts utilisés (A/B testing)
  4. Ajuster les poids du Router
- **Sortie**: Métadonnées de feedback, prompts optimisés

### ⑧ Memory

- **Entrée**: Contexte de la mission, décisions, artefacts
- **Traitement**:
  1. Indexation vectorielle du contexte
  2. Stockage des décisions architecturales (ADR)
  3. Archivage des artefacts produits
  4. Mise à jour des patterns réutilisables
- **Sortie**: Contexte stocké, index mis à jour

## Modes d'exécution

| Mode | Description | Utilisation |
|---|---|---|
| **Sequential** | Une étape après l'autre, pas de parallélisme | Missions simples, debugging |
| **Parallel** | Tâches indépendantes exécutées en parallèle | Missions complexes |
| **Consensus** | Chaque tâche exécutée par N agents en parallèle | Décisions critiques |
| **Iterative** | Boucle validation → correction jusqu'à PASS | Missions qualité stricte |
| **Fallback** | Exécution séquentielle avec fallback sur échec | Résilience maximale |

## Gestion des erreurs

| Erreur | Action | Fallback |
|---|---|---|
| Timeout agent | Retry 1x, puis fallback | Second agent |
| Erreur API modèle | Fallback immédiat | Modèle alternatif |
| Échec validation | Retour au Planner pour re-planification | Itération corrective |
| Crash WorkflowEngine | Snapshots périodiques, reprise au dernier état stable | Redémarrage |
| Indisponibilité totale | File d'attente, notification utilisateur | Mode dégradé |

## Logging & Observabilité

- Chaque événement du pipeline est loggé avec timestamp, step_id, agent, modèle.
- Les métriques sont exposées via SUPRA-Metrics.
- Traçabilité complète : de la mission au fichier généré.
