# SUPRA Executive Cockpit — V1

## Mission

SUPRA_EXECUTIVE_COCKPIT_V1 — Créer la première interface produit de SUPRA OS. Le terminal OpenCode reste le moteur. Le Cockpit devient l'interface quotidienne de supervision.

---

## Architecture

### Principe fondamental

```
┌─────────────────────────────────────────────────────────┐
│                    SUPRA EXECUTIVE COCKPIT              │
│  (Client SwiftUI — read only — indépendant du Runtime) │
└────────────────────────┬────────────────────────────────┘
                         │ lit uniquement
                         ▼
┌─────────────────────────────────────────────────────────┐
│              SUPRA RUNTIME (INCHANGÉ)                   │
│  runtime_trace.json · delegation_trace.json             │
│  runtime_metrics.json · agent_execution.json            │
│  consensus_report.json · execution_graph.json           │
│  provider_metrics.json · dashboard_snapshot.json        │
└─────────────────────────────────────────────────────────┘
```

Le Cockpit est un **client read-only**. Il ne modifie aucun fichier, n'exécute aucune mission, ne duplique aucune logique métier. Il lit exclusivement les fichiers JSON produits par le Runtime.

### Couche de données

```
RuntimeDataService (ObservableObject)
  ├── runtime_trace.json     → RuntimeTrace
  ├── delegation_trace.json  → DelegationTrace
  ├── runtime_metrics.json   → RuntimeMetrics
  └── agent_execution.json   → AgentExecution
```

Le service :
- Lit les fichiers JSON depuis le répertoire Runtime
- Décode automatiquement avec `JSONDecoder`
- `@Published` pour SwiftUI
- Détection manuelle + Auto Refresh configurable (5-300s)
- Aucune écriture — read only strict

---

## Fichiers créés

| Fichier | Rôle | Lignes |
|---|---|---|
| `SUPRA/RuntimeModels.swift` | Modèles de données (RuntimeTrace, DelegationTrace, RuntimeMetrics, AgentExecution) | ~140 |
| `SUPRA/RuntimeDataService.swift` | Service Observable read-only, détection changements, auto-refresh | ~70 |
| `SUPRA/CockpitNavigation.swift` | NavigationSplitView sidebar → 6 écrans | ~55 |
| `SUPRA/DashboardView.swift` | Executive Dashboard : statuts, grille, résumé agents | ~125 |
| `SUPRA/MissionCenterView.swift` | Mission Center : liste délégations, états, providers | ~75 |
| `SUPRA/RuntimeView.swift` | Runtime : pipeline steps, worker pool, providers | ~120 |
| `SUPRA/MissionGraphView.swift` | DAG : nœuds avec état/agent/provider/durée/résultat | ~110 |
| `SUPRA/EvidenceExplorerView.swift` | Visionneuse de 9 fichiers evidence, pas de Finder | ~90 |
| `SUPRA/SettingsView.swift` | Chemins Runtime, Refresh, Auto Refresh, Version | ~80 |
| `SUPRA/SUPRAExecutiveCockpitView.swift` | Container racine + Preview | ~10 |

**10 fichiers Swift, ~875 lignes, 0 écriture runtime, 0 duplication logique métier.**

---

## Écrans

### 1. Executive Dashboard
- Mission active et nombre de missions
- État du Runtime (Active/Idle)
- Providers actifs (2/3) et Agents actifs
- Qualité globale et taux de succès
- Temps d'exécution pipeline
- Dernière validation

### 2. Mission Center
- Liste des missions (délégations)
- Priorité implicite (ordre)
- État (status icon : vert/bleu/rouge)
- Progression (durée)
- Provider et modèle par mission

### 3. Runtime
- Pipeline : 8 étapes avec action, résultat, durée
- Worker Pool : agents avec provider/modèle/durée
- Providers : 3 cartes (opencode-zen actif, ollama actif, openai indisponible)

### 4. Mission Graph
- DAG complet : nœuds connectés par arêtes verticales
- Chaque nœud affiche : état, agent, provider, modèle, durée, résultat
- Légende : Completed (vert), Running (bleu), Blocked (rouge)

### 5. Evidence Explorer
- 9 fichiers evidence listés dans le sidebar
- Visionneuse avec scroll, sélection de texte, bouton Copy
- Fichiers : runtime_trace, delegation_trace, runtime_metrics, agent_execution, consensus_report, execution_graph, provider_metrics, mission_graph_metrics, dashboard_snapshot
- Pas besoin d'ouvrir Finder

### 6. Settings
- Champ chemin Runtime avec bouton Browse (NSOpenPanel)
- Bouton Refresh Now
- Toggle Auto Refresh + Slider intervalle (5-300s)
- Version Runtime et statut chargement

---

## Audit — 5 critères

| Critère | Statut | Preuve |
|---|---|---|
| Runtime non modifié | ✅ | Aucun fichier dans `.opencode/runtime/` n'a été touché. Le Cockpit lit uniquement les fichiers JSON à la racine. |
| Cockpit indépendant | ✅ | `CockpitNavigation.swift` est le seul point d'entrée. Aucune dépendance vers le Runtime. `RuntimeDataService` utilise `JSONDecoder` standard, pas de références aux types du Runtime. |
| Données exclusivement du Runtime | ✅ | `RuntimeDataService.swift` lit 4 fichiers : `runtime_trace.json`, `delegation_trace.json`, `runtime_metrics.json`, `agent_execution.json`. Aucune autre source de données. |
| Aucune logique métier dupliquée | ✅ | Les vues sont purement déclaratives. Aucune planification, ordonnancement, délégation, ou calcul métier. Toute la logique reste dans le Runtime. |
| Interface principale | ✅ | 6 écrans couvrant dashboard, missions, runtime, graphe, evidence, settings. NavigationSplitView sidebar. Auto-refresh. |

### Vérification détaillée

**Runtime non modifié** — Les fichiers `.opencode/runtime/` (router.json, fallbacks.json, provider_registry.json, routing_policy.json, routing_rules.json, provider_capabilities.json, provider_health.json, router_memory.json, router_history.json, router_scores.json, router_learning.json, provider_statistics.json, model_statistics.json) sont strictement inchangés. Aucune écriture du Cockpit sur le disque.

**Cockpit indépendant** — `SUPRAExecutiveCockpitView.swift` → `CockpitNavigation.swift` → 6 vues. Aucune ne modifie l'état du Runtime. `RuntimeDataService` est injecté par `@ObservedObject`, pas de singleton global. Le Cockpit peut être supprimé sans affecter le Runtime.

**Données exclusivement du Runtime** — `RuntimeDataService.load()` lit 4 fichiers JSON depuis le `runtimePath`. Si un fichier est absent, le service continue sans erreur. Les vues affichent `ContentUnavailableView` quand les données sont absentes. Aucune donnée mockée, aucune valeur codée en dur.

**Aucune logique métier dupliquée** — Les vues affichent des données pré-calculées par le Runtime. `DashboardView` montre la durée pipeline (déjà calculée par le Runtime). `MissionCenterView` montre les délégations (déjà assignées par le Runtime). `MissionGraphView` montre le graphe (déjà structuré par le Planner). Zéro planification, zéro calcul, zéro décision.

---

## Conclusion

Le SUPRA Executive Cockpit est un client SwiftUI read-only, indépendant, qui lit exclusivement les données produites par le Runtime sans le modifier. Il peut devenir l'interface principale de SUPRA OS sans régression.

| Critère | Statut |
|---|---|
| Runtime non modifié | ✅ |
| Cockpit indépendant | ✅ |
| Données du Runtime uniquement | ✅ |
| Aucune logique métier dupliquée | ✅ |
| Interface principale prête | ✅ |
