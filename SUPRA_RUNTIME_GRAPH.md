# Runtime Graph SUPRA

## Graphe vivant du système d'orchestration

Le SUPRARuntimeGraph est un graphe orienté qui relie tous les composants du runtime SUPRA en temps réel.

## Structure du graphe

```
                    ┌─────────────────┐
                    │  Decision Engine│
                    └────────┬────────┘
                             │ plans
                             ↓
                    ┌─────────────────┐
                    │Execution Planner│
                    └────────┬────────┘
                             │ routes
                             ↓
                    ┌─────────────────┐
                    │  Routing Policy │
                    └────────┬────────┘
                    ┌────────┴────────┐
                    │                 │
                    ↓                 ↓
           ┌──────────────┐  ┌──────────────┐
           │Capability    │  │  Scheduler   │
           │Broker        │  │              │
           └──────────────┘  └──────┬───────┘
                    │               │ executes
                    ↓               ↓
           ┌──────────────┐  ┌──────────────┐
           │  Plugin[1]   │  │  Plugin[N]   │
           │  Ollama      │  │  OpenAI      │
           └──────┬───────┘  └──────┬───────┘
                  │                 │
           ┌──────┴──────┐   ┌──────┴──────┐
           │Model[1..N]  │   │Model[1..N]  │
           └──────┬──────┘   └──────┬──────┘
                  │                 │
           ┌──────┴─────────────────┴──────┐
           │      Capabilities              │
           │  reasoning, coding, vision...  │
           └──────────────┬────────────────┘
                          │ feeds
                          ↓
           ┌──────────────────────────────┐
           │      Learning Engine         │
           └──────────────┬───────────────┘
                          │ trains
                          ↓
           ┌──────────────────────────────┐
           │        Routing Policy        │
           └──────────────────────────────┘
```

## Types de nœuds

| Type | Description |
|------|-------------|
| `mission` | Mission en cours d'exécution |
| `decision` | Composant de décision/orchestration |
| `capability` | Capacité fonctionnelle (reasoning, coding, etc.) |
| `provider` | Plugin provider enregistré |
| `model` | Modèle déclaré par un provider |
| `plugin` | Plugin (générique ou provider) |
| `memory` | Composant de mémoire/apprentissage |
| `learning` | Moteur d'apprentissage |
| `executor` | Exécuteur (scheduler, fallback) |
| `validation` | Validation |

## Métriques du graphe

Le graphe expose en temps réel :
- Nombre de nœuds et d'arêtes
- Statut de santé de chaque nœud
- Relations entre composants
- Dernière mise à jour

## Rafraîchissement

`SUPRARuntimeGraph.shared.refresh()` reconstruit le graphe à partir des registres actuels. Appelé automatiquement après le bootstrap et après chaque changement de registre.

## Visualisation

Le graphe peut être exporté en texte via `graphDescription()` pour le débogage, et peut être utilisé par des vues SwiftUI pour une visualisation temps réel.
