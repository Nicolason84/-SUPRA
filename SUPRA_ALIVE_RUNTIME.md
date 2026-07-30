# SUPRA ALIVE RUNTIME — V1

## Mission : SUPRA_ALIVE_BOOTSTRAP_004

## État actuel de la chaîne d'exécution

### Pipeline cible

```
Utilisateur → Mission → Kernel → Mission Broker → Provider Broker → Executor → LLM → Réponse → Decision → Memory → UI
```

### État de chaque maillon

| # | Maillon | Existe ? | État | Action |
|---|---------|----------|------|--------|
| 1 | Utilisateur | ✓ | Interface SwiftUI | Connecter au Mission Broker |
| 2 | Mission | ✓ | Modèle + Store + Context | Complété |
| 3 | Kernel | ✓ | NOVAKnowledgeKernel | Fournit le contexte |
| 4 | Mission Broker | ✗ | **MANQUANT** | **À CRÉER** |
| 5 | Provider Broker | ✗ | **MANQUANT** | **À CRÉER** |
| 6 | Executor | ◐ | SUPRAMissionExecutor (coquille vide) | Ne fait rien — ne contacte pas de LLM |
| 7 | LLM | ✗ | **MANQUANT** | **À INTÉGRER** via Provider Broker |
| 8 | Réponse | ✗ | **MANQUANT** | **À CRÉER** |
| 9 | Decision | ✓ | SUPRADecisionEngine + Store | Connecter au pipeline |
| 10 | Memory | ✓ | MultiMemoryStore + CAnnoNicoSnapshotStore | Connecter au pipeline |
| 11 | UI | ✓ | ContentView + 63 autres vues | Connecter aux événements |

### Existant et fonctionnel

#### Mission layer — COMPLÈTE
```
MissionStore         → Charge les missions depuis JSON (SUPRA_TERMINAL_MEGABUS_V1/INBOX)
Mission              → Modèle avec statut, priorité, objectifs, tâches, dépendances
MissionContext       → Préparation du contexte
SUPRAMissionExecutor → Machine d'état : pending → approved → executed → failed → rolledBack
AutoMissionQueue     → File de missions automatiques
```

#### Décision layer — COMPLÈTE
```
SUPRADecisionEngine        → evaluate(evidence:) → DecisionVerdict (enum statique)
SUPRADecisionAuthority     → Types : authority, impact, catégorie, verdict, evidence
DecisionStore              → Chargement/filtrage décisions depuis JSON
```

#### Runtime layer — PARTIEL
```
RuntimeGateway  → Event bus + HTTP bridge + BridgeRequest/Response
OpenCodeBridge  → Pont de commandes haut niveau
OpenCodeClient  → Client multi-source
RuntimeMonitor  → Monitoring
RuntimeDataService → Chargement traces JSON
```

#### Memory layer — COMPLÈTE
```
MultiMemoryStore        → Agrégateur 5 sources
ConversationMemoryStore → Stockage conversations
CAnnoNicoSnapshotStore  → Cache TTL
ExecutiveMemory         → Mémoire vectorisée depuis Kernel
```

#### Kernel layer — COMPLET
```
NOVAKnowledgeKernel → Registre central de connaissances
ExecutiveMemory     → Mémoire exécutive
ContextEngine       → Moteur de recherche contextuelle
```

#### UI layer — COMPLÈTE (64 vues)
```
ContentView (3521 lignes — à refactorer)
SUPRAOSProductRootView
SUPRAAutonomyControlView
SUPRADecisionEngineView
MissionCenterView, MissionDetailView, MissionGraphView, MissionTimelineView
+ 57 autres vues
```

### Ce qui manque pour la boucle minimale

| Composant | Priorité | Effort estimé |
|-----------|----------|---------------|
| SUPRAProviderBroker | CRITIQUE | 1 fichier Swift |
| SUPRAProviderProtocol | CRITIQUE | 1 protocole Swift |
| SUPRAOllamaProvider | CRITIQUE | 1 fichier Swift (plugin) |
| SUPRAOpenAIProvider | HAUTE | 1 fichier Swift (plugin) |
| SUPRAMissionBroker | CRITIQUE | 1 fichier Swift |
| SUPRALLMExecutor | CRITIQUE | Remplacement de SUPRAMissionExecutor.execute() |
| SUPRAResponse | HAUTE | Modèle + handler |
| SUPRAFeedbackLoop | MOYENNE | Connexion décision → mémoire |

### Architecture de la boucle vivante

```
┌──────────┐     ┌──────────┐     ┌────────────┐
│ Utilisateur │────▶│ Mission  │────▶│    Mission  │
│  (SwiftUI)  │     │  Store   │     │   Broker    │
└──────────┘     └──────────┘     └─────┬──────┘
                                        │
                                        ▼
                               ┌────────────────┐
                               │  NOVAKnowledge │
                               │    Kernel      │
                               └───────┬────────┘
                                        │ contexte
                                        ▼
                               ┌────────────────┐
                               │  Mission Exec │ ←───────── Provider Broker
                               │  (LLM Exec)   │ ←── Ollama, OpenAI, etc.
                               └───────┬────────┘
                                        │ réponse LLM
                                        ▼
                               ┌────────────────┐     ┌──────────┐
                               │   Decision     │────▶│ Decision │
                               │   Engine       │     │  Store   │
                               └───────┬────────┘     └──────────┘
                                        │ verdict
                                        ▼
                               ┌────────────────┐
                               │    Memory      │
                               │   Stores       │
                               └───────┬────────┘
                                        │ état
                                        ▼
                               ┌────────────────┐
                               │   UI (SwiftUI) │────▶ Utilisateur
                               └────────────────┘
```

### Règles d'exécution

1. **Provider Broker** est le seul point d'entrée pour les appels LLM
2. **Aucun** composant ne peut appeler un LLM directement
3. **Tous** les providers implémentent `SUPRAProviderProtocol`
4. **Mission Broker** traduit les missions en requêtes exécutables
5. **La boucle est synchrone** en phase 1, asynchrone en phase 3+
6. **Le verdict décisionnel** est toujours enregistré avant la mémoire
7. **La mémoire** est toujours mise à jour avant la mise à jour UI
