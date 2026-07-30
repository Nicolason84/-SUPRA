# NUCLEO CLASSIFICATION — V1

## Mission : NUCLEO_DISCOVERY_001

## Catégories

| Code | Catégorie | Définition |
|------|-----------|------------|
| **IMMUTABLE** | Système fondamental | Ne peut être modifié (NUCLEO CORE) |
| **CORE** | Composant primaire | Essentiel au fonctionnement, peut évoluer |
| **OPTIONAL** | Optionnel | Peut être désactivé sans briser le système |
| **PLUGIN** | Plugin externe | Module indépendant enfichable |
| **LEGACY** | Ancien | Remplacé mais conservé pour référence |
| **DEPRECATED** | Obsolète | À supprimer |
| **UNKNOWN** | Inconnu | Rôle ou utilité non déterminée |

---

## IMMUTABLE (NUCLEO CORE)

Ces composants sont le cœur du système — toute modification nécessite une mission NUCLEO formelle.

| Composant | Justification |
|-----------|---------------|
| **NOVAKnowledgeKernel** | Registre central de connaissances, singleton noyau |
| **RuntimeGateway** | Event bus central, tous les flux passent par lui |
| **RuntimeMonitor** | Monitoring runtime, délégation OpenCode |
| **RuntimeDataService** | Chargement des traces JSON depuis le bundle |
| **SUPRAMissionExecutor** | Exécution avec rollback, garantie d'intégrité |
| **SUPRAMissionProposalEngine** | Proposition de missions, modes auto/supervision/human |
| **SUPRAOperationalCoreApp** | @main actuel, point d'entrée unique (doit le rester) |
| **SUPRANucleoOrchestrator** | Orchestrateur NUCLEO, point d'entrée lifecycle |

---

## CORE (Composants primaires)

| Composant | Justification |
|-----------|---------------|
| **SUPRAResourceGovernor** | Monitoring CPU/RAM/disk, throttling essentiel |
| **SUPRAScheduler** | Ordonnancement priorisé des tâches |
| **SUPRADecisionEngine** | Évaluation evidence → verdict |
| **SUPRACanonicalWorldAccess** | Accès unifié état système |
| **MissionStore** | CRUD missions, stockage central |
| **MissionContext** | Préparation contexte mission |
| **Mission** | Modèle de données mission |
| **OpenCodeClient** | Client OpenCode multi-source |
| **OpenCodeBridge** | Pont BridgeCommand/Response |
| **SUPRAIntelligenceEngine** | Scoring santé/confiance |
| **SUPRAEvolutionEngine** | Auto-optimisation |
| **SUPRAResourceIntelligenceEngine** | Anomalies ressources |
| **SUPRAMissionObserver** | Observation conditions système |
| **AutoMissionQueue** | File missions automatiques |
| **SUPRASystemIntegrityLoader** | Vérification build + rollback |
| **SUPRAPassiveRefreshCoordinator** | Rafraîchissement passif UI |
| **SUPRACommandCenterState** | Hub central de commande (à refactorer) |
| **ContentView** | Vue principale (à refactorer — 3521 lignes) |
| **RuntimeModels** | Modèles RuntimeTrace, DelegationTrace, Metrics, ExecutionGraph, DashboardSnapshot |
| **RuntimeSourceProtocol** | Protocole source runtime |
| **JSONRuntimeSource** | Source runtime JSON |
| **OpenCodeRuntimeSource** | Source runtime OpenCode |
| **RuntimeConnectionState** | État connexion runtime |

---

## OPTIONAL (Peut être désactivé)

| Composant | Justification |
|-----------|---------------|
| **SUPRABackgroundScheduler** | Double emploi avec SUPRAScheduler, mais utile si activé séparément |
| **SUPRARecommendationEngine** | Recommandations non critiques |
| **SUPRAMissionEvidenceLoader** | Chargement preuves mission |
| **ExecutiveMemory** | Mémoire exécutive non référencée |
| **ContextEngine** | Moteur contexte non référencé |
| **SUPRADecisionAuthority** | Enum autorité |
| **DecisionStore** | Stockage décisions non critique |
| **SUPRAAutonomyControlView** | UI contrôle autonomie |
| **SUPRADecisionEngineView** | UI décisions |
| **SUPRAIntelligenceState** | État intelligence engine |
| **SUPRAEnvironmentAutoMissions** | Missions environnement |
| **MultiMemoryStore** | Store mémoire multi-sources |
| **ConversationMemoryStore** | Store mémoire conversations |
| **CAnnoNicoSnapshotStore** | Store snapshots |
| **SUPRATerminalMegabusBridge** | Pont MEGABUS inter-terminal, nécessaire seulement si multi-terminal |
| **SUPRAChatRuntimeAdapter** | Adaptateur chat → runtime |
| **SUPRAOptimizationCopilot** | Copilot optimisation |
| **SUPRAOSProductRootView** | Vue racine produit |

---

## PLUGIN (Modules enfichables indépendants)

| Composant | Justification |
|-----------|---------------|
| **SUPRADataTwin** | Jumeau données — module autonome |
| **SUPRAHardwareTwin** | Jumeau matériel — module autonome |
| **SUPRASoftwareTwin** | Jumeau logiciel — module autonome |
| **SUPRADeveloperTwin** | Jumeau développeur — module autonome |
| **SUPRAWorkerFabric** | Fabrique de workers — module autonome |
| **SUPRAWorldModel** | Modèle du monde — module autonome |
| **SUPRAEnvironmentWorldModel** | Modèle environnement — module autonome |
| **SUPRABusinessPlatform** | Plateforme métier — module autonome |
| **SUPRAMonetizationEngine** | Moteur monétisation — module autonome |
| **SUPRAGabrielConductorRuntime** | Runtime Gabriel — module autonome |

---

## LEGACY (Remplacé, conservé)

| Composant | Justification |
|-----------|---------------|
| **SUPRACommandCenterApp** | Ancien @main commenté, conservé pour compatibilité |

---

## DEPRECATED (À supprimer)

| Composant | Justification |
|-----------|---------------|
| **SUPRAApp** | Ancien @main commenté, plus aucun code ne l'utilise |

---

## UNKNOWN (Rôle incertain)

Aucun composant dans cette catégorie à l'issue de la mission.
