# PROPOSITION D'ARCHITECTURE — Transition vers le Système Cognitif Gouverné

| Propriété | Valeur |
|---|---|
| **Document** | Architecture Transition V1 |
| **Date** | 2026-07-29 |
| **Statut** | PROPOSITION — À valider avant implémentation |
| **Autorité** | SUPRA Constitution — Article 2 |
| **Référence** | Manifeste Fondateur — Cycle Fondamental — Système Cognitif Gouverné |
| **Loi applicable** | Knowledge First, Canon Before Code |

---

## 1. LES QUATRE FACULTÉS FONDAMENTALES

La nouvelle architecture est organisée autour de quatre facultés cognitives permanentes. Les services et composants existants sont rattachés à ces facultés, non plus les uns aux autres.

```
MISSION
  │
  ├── FACULTÉ 1 — TUV5 — COMPRENDRE
  │     Ingestion, extraction, analyse, fusion, déduplication, structuration
  │     Question fondamentale : Que savons-nous réellement ?
  │
  ├── FACULTÉ 2 — PUCHERO — MÛRIR
  │     Confrontation, rapprochement, détection des contradictions, consolidation,
  │     enrichissement, accumulation des preuves
  │     Question fondamentale : Cette connaissance est-elle suffisamment mûre pour être canonisée ?
  │
  ├── FACULTÉ 3 — CANNoNICO — CANONISER
  │     Identité canonique, définition, responsabilités, relations, contraintes,
  │     preuves, historique
  │     Question fondamentale : Quelle est la représentation officielle de cette connaissance ?
  │
  └── FACULTÉ 4 — RUNTIME — EXÉCUTER
        Orchestration, décisions, exécution, génération, synchronisation, projection
        Question fondamentale : Comment cette connaissance devient-elle une action concrète ?
```

---

## 2. LES CAPACITÉS ASSOCIÉES À CHAQUE FACULTÉ

### 2.1 TUV5 — COMPRENDRE

| Capacité | Description | Priorité |
|---|---|---|
| TUV5.INGESTION | Parser et normaliser les sources hétérogènes (Swift, Bash, JSON, YAML, Markdown, SQL, API, UI, conversations) | ESSENTIELLE |
| TUV5.EXTRACTION | Extraire les concepts, entités et relations de toute source | ESSENTIELLE |
| TUV5.FUSION | Fusionner les concepts équivalents, dédupliquer la connaissance | ESSENTIELLE |
| TUV5.NORMALIZATION | Aligner la terminologie avec l'ontologie unifiée, standardiser les timestamps NAMBROCAHORA | ESSENTIELLE |
| TUV5.VALIDATION | Vérifier l'intégrité structurale, valider les contraintes, détecter les contradictions | ESSENTIELLE |
| TUV5.COMPILATION | Intégrer dans le graphe canonique, mettre à jour les graphes de contraintes et de preuves | ESSENTIELLE |
| TUV5.PUBLICATION | Persister la connaissance canonique, générer les projections | ESSENTIELLE |
| TUV5.PROJECTION | Générer les projections vers Swift, JSON, Bash, Markdown, YAML, API, UI | ESSENTIELLE |

### 2.2 PUCHERO — MÛRIR

| Capacité | Description | Priorité |
|---|---|---|
| PUCHERO.CONFRONTATION | Confronter les concepts issus de sources multiples pour détecter les divergences | ESSENTIELLE |
| PUCHERO.CONSOLIDATION | Fusionner les connaissances partielles en concepts cohérents | ESSENTIELLE |
| PUCHERO.CONTRADICTION_DETECTION | Détecter les contradictions logiques entre propositions | ESSENTIELLE |
| PUCHERO.EVIDENCE_ACCUMULATION | Accumuler les preuves qui soutiennent ou réfutent chaque concept | ESSENTIELLE |
| PUCHERO.COHERENCE_SCORING | Calculer un score de cohérence pour chaque concept | ESSENTIELLE |
| PUCHERO.ENRICHMENT | Enrichir progressivement les concepts avec des relations et contraintes supplémentaires | ESSENTIELLE |
| PUCHERO.MATURITY_GATE | Déterminer si un concept a atteint le niveau de maturité suffisant pour être canonisé | ESSENTIELLE |
| PUCHERO.REPAIR | Proposer les corrections minimales pour les concepts incohérents | COMPLÉMENTAIRE |

### 2.3 CANNoNICO — CANONISER

| Capacité | Description | Priorité |
|---|---|---|
| CANNoNICO.IDENTITY_CORE | Générer et gérer les identités canoniques (can:<type>:<sha256>) | ESSENTIELLE |
| CANNoNICO.KNOWLEDGE_CORE | Stocker la connaissance structurée compilée, non redondante | ESSENTIELLE |
| CANNoNICO.RELATION_CORE | Gérer les arcs dirigés entre identités avec types sémantiques | ESSENTIELLE |
| CANNoNICO.TEMPORAL_CORE | Fournir le temps canonique NAMBROCAHORA pour tout raisonnement | ESSENTIELLE |
| CANNoNICO.DECISION_CORE | Prendre des décisions documentées avec rationale et preuves | ESSENTIELLE |
| CANNoNICO.STATE_CORE | Gérer les états et les transitions des entités canoniques | ESSENTIELLE |
| CANNoNICO.CONSTRAINT_CORE | Valider les contraintes actives sur les entités et relations | ESSENTIELLE |
| CANNoNICO.MEMORY_CORE | Mémoire unifiée remplaçant les stores multiples | ESSENTIELLE |
| CANNoNICO.GOVERNANCE_CORE | Gouvernance unifiée : règles, principes immuables, conformité | ESSENTIELLE |
| CANNoNICO.PROJECTION_ENGINE | Transformer le CANNoNICO en projections (Swift, JSON, Bash, Markdown, UI, API) | ESSENTIELLE |

### 2.4 RUNTIME — EXÉCUTER

| Capacité | Description | Priorité |
|---|---|---|
| RUNTIME.ORCHESTRATION | Ordonnancer et coordonner l'exécution des tâches | ESSENTIELLE |
| RUNTIME.MISSION_EXECUTION | Gérer le cycle de vie des missions | ESSENTIELLE |
| RUNTIME.WORKFLOW_ENGINE | Définir et exécuter les workflows (DAG, parallélisation) | ESSENTIELLE |
| RUNTIME.TASK_EXECUTION | Exécuter les tâches atomiques | ESSENTIELLE |
| RUNTIME.DECISION_ENGINE | Évaluer les propositions et produire des décisions CANNoNICO | ESSENTIELLE |
| RUNTIME.PROJECTION | Générer les artefacts techniques (code, docs, API, UI) | ESSENTIELLE |
| RUNTIME.SYNC | Synchroniser les projections avec le modèle canonique | ESSENTIELLE |
| RUNTIME.PROVIDER_BRIDGE | Connecter les providers externes (Ollama, OpenAI, Anthropic) via contrats | COMPLÉMENTAIRE |
| RUNTIME.CONNECTOR | Connecter les systèmes externes (Git, fichiers, plugins) | COMPLÉMENTAIRE |
| RUNTIME.OBSERVABILITY | Métriques, events, logging, tracing | COMPLÉMENTAIRE |

---

## 3. LES SERVICES EXISTANTS RATTACHÉS À CES CAPACITÉS

### 3.1 Mapping des 9 Services Runtime

| Service | Faculté | Capacité(s) | Justification |
|---|---|---|---|
| **Workspace** | RUNTIME | RUNTIME.ORCHESTRATION, RUNTIME.PROJECTION | Organise les artefacts comme projections du modèle canonique. Gère les chemins officiels comme projections CANNoNICO. |
| **Storage** | TUV5 | TUV5.INGESTION, TUV5.FUSION | Surveille l'espace disque et détecte les doublons — c'est une fonction d'ingestion et de fusion de la connaissance du système de fichiers. |
| **Provider** | RUNTIME | RUNTIME.PROVIDER_BRIDGE | Inventorie les providers IA et sélectionne le meilleur — c'est un pont vers l'exécution. |
| **Build** | RUNTIME | RUNTIME.WORKFLOW_ENGINE, RUNTIME.TASK_EXECUTION | Centralise les builds et gère les caches — c'est l'exécution d'un workflow technique. |
| **Diagnostics** | PUCHERO | PUCHERO.CONFRONTATION, PUCHERO.CONTRADICTION_DETECTION, PUCHERO.REPAIR | Exécute des diagnostics, produit des preuves, explique les anomalies — c'est la confrontation et la réparation de la connaissance système. |
| **Health** | RUNTIME | RUNTIME.OBSERVABILITY | Mesure l'état global et détecte les dégradations — observabilité du Runtime. |
| **Snapshot** | CANNoNICO | CANNoNICO.STATE_CORE, CANNoNICO.TEMPORAL_CORE | Gère les snapshots avec cohérence et timestamps NAMBROCAHORA — c'est la gestion d'état canonique. |
| **Recovery** | RUNTIME | RUNTIME.ORCHESTRATION, RUNTIME.MISSION_EXECUTION | Restaure un état cohérent et garantit la continuité — c'est l'orchestration de récupération. |
| **Governance** | CANNoNICO | CANNoNICO.GOVERNANCE_CORE | Applique les politiques du Runtime et contrôle les services — c'est la gouvernance canonique. |

### 3.2 Mapping des Composants NUCLEO (92 composants)

| Composant | Faculté | Capacité | Classification NUCLEO |
|---|---|---|---|
| SUPRANucleoOrchestrator | RUNTIME | RUNTIME.ORCHESTRATION | CORE |
| SUPRAResourceGovernor | RUNTIME | RUNTIME.OBSERVABILITY | CORE |
| RuntimeGateway | RUNTIME | RUNTIME.PROJECTION | IMMUTABLE |
| RuntimeMonitor | RUNTIME | RUNTIME.OBSERVABILITY | CORE |
| RuntimeDataService | RUNTIME | RUNTIME.SYNC | CORE |
| MissionStore | RUNTIME | RUNTIME.MISSION_EXECUTION | CORE |
| MissionContext | TUV5 | TUV5.INGESTION | CORE |
| SUPRAScheduler | RUNTIME | RUNTIME.WORKFLOW_ENGINE | CORE |
| SUPRADecisionEngine | RUNTIME | RUNTIME.DECISION_ENGINE | CORE |
| SUPRAMissionExecutor | RUNTIME | RUNTIME.TASK_EXECUTION | CORE |
| NOVAKnowledgeKernel | TUV5 | TUV5.EXTRACTION, TUV5.FUSION | CORE |
| SUPRACanonicalWorldAccess | CANNoNICO | CANNoNICO.KNOWLEDGE_CORE | CORE |
| OpenCodeClient | RUNTIME | RUNTIME.PROVIDER_BRIDGE | CORE |
| OpenCodeBridge | RUNTIME | RUNTIME.PROJECTION | IMMUTABLE |
| SUPRABackgroundScheduler | RUNTIME | RUNTIME.WORKFLOW_ENGINE | OPTIONAL |
| SUPRAIntelligenceEngine | PUCHERO | PUCHERO.COHERENCE_SCORING | OPTIONAL |
| SUPRAEvolutionEngine | PUCHERO | PUCHERO.REPAIR | OPTIONAL |
| SUPRARecommendationEngine | PUCHERO | PUCHERO.ENRICHMENT | OPTIONAL |
| SUPRAResourceIntelligenceEngine | PUCHERO | PUCHERO.CONTRADICTION_DETECTION | OPTIONAL |
| SUPRAMissionObserver | RUNTIME | RUNTIME.OBSERVABILITY | OPTIONAL |
| SUPRAMissionProposalEngine | RUNTIME | RUNTIME.MISSION_EXECUTION | OPTIONAL |
| ExecutiveMemory | CANNoNICO | CANNoNICO.MEMORY_CORE | OPTIONAL |
| ContextEngine | TUV5 | TUV5.EXTRACTION | OPTIONAL |
| DecisionStore | CANNoNICO | CANNoNICO.DECISION_CORE | OPTIONAL |
| ExecutiveCockpitFoundation | RUNTIME | RUNTIME.PROJECTION (UI) | OPTIONAL |
| SUPRAOSFoundation | RUNTIME | RUNTIME.PROJECTION | OPTIONAL |
| TwinUniverse | TUV5 | TUV5.INGESTION | OPTIONAL |
| MultiMemoryStore | CANNoNICO | CANNoNICO.MEMORY_CORE | OPTIONAL |
| CAnnoNicoSnapshotStore | CANNoNICO | CANNoNICO.STATE_CORE | OPTIONAL |
| ConversationMemoryStore | TUV5 | TUV5.INGESTION | OPTIONAL |
| SUPRAPassiveRefreshCoordinator | RUNTIME | RUNTIME.SYNC | PLUGIN |
| SUPRATerminalMegabusBridge | RUNTIME | RUNTIME.CONNECTOR | PLUGIN |
| SUPRAChatRuntimeAdapter | RUNTIME | RUNTIME.PROJECTION | PLUGIN |
| SUPRAGabrielConductorRuntime | RUNTIME | RUNTIME.ORCHESTRATION | PLUGIN |
| CAnnoNicoIntegrationBridge | CANNoNICO | CANNoNICO.IDENTITY_CORE | PLUGIN |
| SUPRAEnvironmentAutoMissions | RUNTIME | RUNTIME.MISSION_EXECUTION | LEGACY |
| ControlTowerState | CANNoNICO | CANNoNICO.GOVERNANCE_CORE | LEGACY |
| SUPRACommandCenterState | CANNoNICO | CANNoNICO.STATE_CORE | LEGACY |
| ArtifactReader | TUV5 | TUV5.INGESTION | LEGACY |
| SUPRACommandCenterApp | — | — | DEPRECATED |
| SUPRAApp | — | — | DEPRECATED |

### 3.3 Mapping des Composants NUCLEO par Faculté

**TUV5 — COMPRENDRE (7 composants)**
- NOVAKnowledgeKernel (CORE)
- ContextEngine (OPTIONAL)
- MissionContext (CORE)
- TwinUniverse (OPTIONAL)
- ConversationMemoryStore (OPTIONAL)
- ArtifactReader (LEGACY)
- CAnnoNicoIntegrationBridge (PLUGIN)

**PUCHERO — MÛRIR (4 composants)**
- SUPRAIntelligenceEngine (OPTIONAL)
- SUPRAResourceIntelligenceEngine (OPTIONAL)
- SUPRAEvolutionEngine (OPTIONAL)
- SUPRARecommendationEngine (OPTIONAL)

**CANNoNICO — CANONISER (8 composants)**
- SUPRACanonicalWorldAccess (CORE)
- ExecutiveMemory (OPTIONAL)
- CAnnoNicoSnapshotStore (OPTIONAL)
- DecisionStore (OPTIONAL)
- MultiMemoryStore (OPTIONAL)
- ControlTowerState (LEGACY)
- SUPRACommandCenterState (LEGACY)
- CAnnoNicoIntegrationBridge (PLUGIN)

**RUNTIME — EXÉCUTER (65 composants)**
- Tous les autres composants (SUPRANucleoOrchestrator, RuntimeGateway, RuntimeMonitor, RuntimeDataService, MissionStore, SUPRAScheduler, SUPRADecisionEngine, SUPRAMissionExecutor, OpenCodeClient, OpenCodeBridge, SUPRABackgroundScheduler, SUPRAMissionObserver, SUPRAMissionProposalEngine, SUPRAOSFoundation, ExecutiveCockpitFoundation, SUPRAPassiveRefreshCoordinator, SUPRATerminalMegabusBridge, SUPRAChatRuntimeAdapter, SUPRAGabrielConductorRuntime, SUPRAEnvironmentAutoMissions, etc.)

---

## 4. LES REDONDANCES DÉTECTÉES

### 4.1 Redondances Confirmées (Vrais Doublons)

| # | Redondance | Composants Impliqués | Gravité | Action Recommandée |
|---|---|---|---|---|
| R1 | **Double Scheduler** | SUPRAScheduler + SUPRABackgroundScheduler | ÉLEVÉE | Fusionner en une seule capacité de planification sous RUNTIME. SUPRABackgroundScheduler devient un mode (background) de SUPRAScheduler. |
| R2 | **Double Intelligence** | SUPRAIntelligenceEngine + SUPRAEvolutionEngine + SUPRARecommendationEngine + SUPRAResourceIntelligenceEngine | ÉLEVÉE | Les 4 partagent la même base : analyse environnementale scoring. Consolidation en une seule capacité PUCHERO.COHERENCE_SCORING avec spécialisations internes. |
| R3 | **Double Knowledge** | NOVAKnowledgeKernel + CANONICO KnowledgeGraph + knowledge_graph.json + knowledge_kernel.json | MOYENNE | NOVAKnowledgeKernel est une projection Swift du KnowledgeGraph canonique. Unifier sous CANNoNICO.KNOWLEDGE_CORE uniquement. |
| R4 | **Double Runtime** | RuntimeKernel (doc) + RuntimeGateway + RuntimeMonitor + RuntimeDataService + RuntimeStatus | MOYENNE | RuntimeKernel est le modèle canonique — ne pas implémenter. RuntimeGateway/Monitor/DataService sont des projections d'exécution du modèle. |
| R5 | **Double Time** | NAMBROCAHORA (doc) + ticks implicites dans RuntimeTrace/RuntimeMetrics/RuntimeData + Date() dans certains fichiers Swift | ÉLEVÉE | TOUT timestamp système doit être converti en NAMBROCAHORA tick. Éliminer les Date() system storage dans les modèles Runtime. |
| R6 | **Double ID System** | CAN_ID (can:<type>:<sha256>) + SUPRAComponentID + NUCLEO classification paths | MOYENNE | Unifier sous CANNoNICO.IDENTITY_CORE. Tous les identifiants doivent être des CAN_ID. |

### 4.2 Fausses Positifs (Spécialisations Légitimes)

| # | Composants | Nature | Statut |
|---|---|---|---|
| FP1 | MultiMemoryStore + ConversationMemoryStore + CAnnoNicoSnapshotStore + ExecutiveMemory | RESPONSABILITÉS DISTINCTES | Conforme — pas de duplication |
| FP2 | SUPRAOperationalCoreApp + SUPRACommandCenterApp + SUPRAApp | POINTS D'ENTRÉE DISTINCTS | Conforme — modes UI différents |
| FP3 | SUPRADecisionEngine + SUPRADecisionAuthority + DecisionStore + SUPRACanonicalWorldAccess | ÉTAPES DIFFÉRENTES DE LA DÉCISION | Conforme — chacune a un rôle unique |
| FP4 | SUPRAScheduler + SUPRABackgroundScheduler | SPÉCIALISATION (vrai doublon partiel) | À fusionner comme modes d'une seule capacité |

### 4.3 Redondances de Registres

| # | Registre | Fichier(s) | Action |
|---|---|---|---|
| RD1 | CANONICAL_REGISTRY.json + CANONICAL_SERVICES.json + CANONICAL_WORKERS.json + CANONICAL_PACKAGES.json + CANONICAL_MODULES.json + CANONICAL_BRIDGES.json + CANONICAL_ADAPTERS.json + CANONICAL_PROJECTS.json | 8 fichiers JSON | Consolidation en un seul CANONICAL_REGISTRY.json avec sous-domaines |
| RD2 | CANNoNICO_FOUNDATION.md + CANNoNICO_PRIMITIVES.md + CANON_ONTOLOGY.md + CANONICO_NODE_MODEL.md + CANONICO_EDGE_MODEL.md + CANONICO_KNOWLEDGE_GRAPH.md + CANONICO_GRAPH_KERNEL.md + CANONICO_GRAPH_RUNTIME.md + CANONICO_STANDARD.md + CANONICO_VALIDATION_MODEL.md + CANONICO_CONSTRAINT_MODEL.md + CANONICO_PATTERN_CONSTRAINTS.md + CANONICO_PATTERN_LIBRARY.md + CANONICO_INCONSISTENCY_MODEL.md + CANONICO_EDGE_MODEL.md | 15+ fichiers | Consolidation en un CANNoNICO CORE avec modules thématiques (comme CAnnoNico le fait partiellement) |
| RD3 | TUV5_KNOWLEDGE_COMPILER.md + SUPRA_KNOWLEDGE_COMPILER.md + NOVAKnowledgeKernel + ContextEngine + KnowledgeGraph | 5+ sources | Confusion entre spec TUV5 et implémentation. La spec est canonique, l'implémentation est une projection. |

---

## 5. LES CONCEPTS MANQUANTS

### 5.1 Concepts Absents du Modèle Canonique

| # | Concept Manquant | Faculté | Impact | Urgence |
|---|---|---|---|---|
| CM1 | **PUCHERO — Knowledge Maturation Engine** | PUCHERO | Aucun service dédié à la maturation de la connaissance. La confrontation, la consolidation et la détection de contradictions sont distribuées entre Diagnostics, IntelligenceEngine et EvolutionEngine sans coordination centrale. | CRITIQUE |
| CM2 | **Projection Engine** | CANNoNICO + RUNTIME | Le modèle CANNoNICO définit la projection comme une capacité, mais aucun Projection Engine explicite n'existe. Les projections sont ad hoc (CAnnoNicoCircuitBoardView.swift est un cas). | CRITIQUE |
| CM3 | **TUV5 Ingestion Pipeline** | TUV5 | La spécification TUV5 est complète (6 étapes), mais aucune implémentation pipeline n'existe encore. Les fichiers sont ingérés manuellement. | CRITIQUE |
| CM4 | **CANNoNICO Runtime Engine** | CANNoNICO | Le Runtime raisonne en CANNoNICO mais n'a pas de moteur d'exécution CANNoNICO dédié. Il utilise des contrats Swift qui sont des projections, pas du CANNoNICO pur. | ÉLEVÉE |
| CM5 | **Knowledge Graph Query Interface** | TUV5 + CANNoNICO | Aucune interface de requête du graphe de connaissance n'est formalisée. NOVAKnowledgeKernel.search(query:) est l'unique mécanisme, mais il n'est pas CANNoNICO-native. | ÉLEVÉE |
| CM6 | **Canonicalization State Machine** | CANNoNICO | Le pipeline canonique (DETECT → GROUP → COMPARE → CANONICALIZE → LINK → PROVE → MIGRATE) n'a pas de machine à états d'implémentation. | MOYENNE |
| CM7 | **NAMBROCAHORA Runtime Integration** | TUV5 + RUNTIME | NAMBROCAHORA est spécifié mais pas intégré au Runtime. Les modèles Swift (RuntimeTrace, RuntimeMetrics, RuntimeData) utilisent encore des timestamps système. | ÉLEVÉE |
| CM8 | **Canonical Evidence Chain** | PUCHERO + CANNoNICO | Les preuves existent dans des fichiers JSON épars (consensus_trace.json, routing_trace.json, execution_trace.json) mais pas de chaîne de preuve canonique unifiée. | MOYENNE |
| CM9 | **Canonical Memory Core** | CANNoNICO | MémoireMultiple stores (MultiMemoryStore, ConversationMemoryStore, CAnnoNicoSnapshotStore, ExecutiveMemory) devraient être unifiés sous CANNoNICO.MEMORY_CORE. | MOYENNE |
| CM10 | **Canonical Governance Core** | CANNoNICO | La gouvernance est fragmentée (Governance Service, CANONICAL_REGISTRY, SUPRA_GOVERNANCE_*, SUPRA_CONSTITUTION.md) sans noyau unifié. | MOYENNE |

### 5.2 Concepts Redondants à Fusionner

| # | Concept | Fusion En | Raison |
|---|---|---|---|
| CR1 | Agent Registry + Model Registry + Capability Registry + Plugin Registry | CANNoNICO.IDENTITY_CORE | Les 4 registres sont des projections du même concept : une identité avec un type, des capacités et des relations |
| CR2 | KnowledgeKernel + KnowledgeGraph + KnowledgeRelations + KnowledgeSources | CANNoNICO.KNOWLEDGE_CORE | Tous décrivent la connaissance du système sous des formats différents |
| CR3 | RuntimeKernel + RuntimeGraph + RuntimeStatus + RuntimeMetrics + RuntimeTrace | RUNTIME.OBSERVABILITY + CANNoNICO.STATE_CORE | Le RuntimeKernel est le modèle, les autres sont des projections |
| CR4 | Workflow + Pipeline + TaskGraph + ParallelGroup | RUNTIME.WORKFLOW_ENGINE | Tous sont des spécialisations d'un même concept d'exécution structurée |
| CR5 | SUPRA-Architect + SUPRA-Builder + SUPRA-Router + SUPRA-Reviewer + SUPRA-Refactor + SUPRA-Auditor + SUPRA-Explorer + SUPRA-Research + SUPRA-Runtime | TUV5 + RUNTIME.AGENT_POOL | Les agents SUPRA sont des projections CANNoNICO de capacités |

---

## 6. LES MIGRATIONS NÉCESSAIRES

### 6.1 Migration : Temps Système → NAMBROCAHORA

| Étape | Action | Composants Impactés |
|---|---|---|
| M1 | Intégrer NAMBROCAHORA dans les modèles Swift (RuntimeTrace, RuntimeMetrics, RuntimeData) | RuntimeModels.swift, RuntimeEvent.swift |
| M2 | Créer NAMBROCAHORA.tick() comme source unique de temporalité | Nouveau module NAMBROCAHORA |
| M3 | Migrer tous les Date() system storage vers NAMBROCAHORA tick | CAnnoNicoSnapshotStore, DecisionStore, MultiMemoryStore |
| M4 | Créer le Projection Engine pour tick → ISO8601 / Unix ms | Nouveau module ProjectionEngine |
| M5 | Supprimer les timestamps système dans les JSON de trace | runtime_trace.json, delegation_trace.json, runtime_metrics.json |

### 6.2 Migration : Registres Dupliqués → CANNoNICO.IDENTITY_CORE

| Étape | Action | Fichiers Impactés |
|---|---|---|
| M6 | Consolidation des 8 registres CANONICAL_* en un seul | CANONICAL_REGISTRY.json (absorbe CANONICAL_SERVICES.json, etc.) |
| M7 | Déprécier les fichiers de registre individuels | CANONICAL_SERVICES.json, CANONICAL_WORKERS.json, etc. |
| M8 | Créer CANNoNICO.IDENTITY_CORE comme unique registre d'identités | Nouveau module IdentityCore |
| M9 | Migrer tous les CAN_ID vers le format can:<type>:<sha256> | Tous les files JSON |

### 6.3 Migration : Mémoires Multiples → CANNoNICO.MEMORY_CORE

| Étape | Action | Composants Impactés |
|---|---|---|
| M10 | Unifier MultiMemoryStore + ConversationMemoryStore + CAnnoNicoSnapshotStore + ExecutiveMemory | 4 fichiers Swift |
| M11 | Créer CANNoNICO.MEMORY_CORE comme unique mémoire | Nouveau module MemoryCore |
| M12 | Migrer les données des 4 stores vers le MemoryCore | Toutes les données JSON |
| M13 | Déprécier les stores individuels | MultiMemoryStore.swift, ConversationMemoryStore.swift, etc. |

### 6.4 Migration : Modèles Runtime → CANNoNICO.Layer 2

| Étape | Action | Fichiers Impactés |
|---|---|---|
| M14 | Réécrire RuntimeModels pour utiliser uniquement CANNoNICO primitives | RuntimeModels.swift |
| M15 | Supprimer les projections ad hoc de RuntimeStatus, RuntimeHealth, RuntimeConnectionState | RuntimeGateway.swift (partiel) |
| M16 | Migrer les 21 types Runtime vers CANNoNICO entities | TOUT le runtime Swift |

### 6.5 Migration : Gouvernance Fragmentée → CANNoNICO.GOVERNANCE_CORE

| Étape | Action | Documents Impactés |
|---|---|---|
| M17 | Consolidation de SUPRA_GOVERNANCE_* en un seul noyau | Governance/*.md |
| M18 | Créer CANNoNICO.GOVERNANCE_CORE comme unique source de gouvernance | Nouveau module GovernanceCore |
| M19 | Migrer les règles de gouvernance du Runtime Service vers CANNoNICO.GOVERNANCE_CORE | services.json |

---

## 7. LES PROJECTIONS GÉNÉRÉES À PARTIR DU MODÈLE CANONIQUE

### 7.1 Projections Swift

| Composant Swift | Concept Canonique | Capacité | Type de Projection |
|---|---|---|---|
| SUPRANucleoOrchestrator | RUNTIME.ORCHESTRATION | Orchestration | Projection d'exécution |
| RuntimeGateway | CANNoNICO.DECISION_CORE + NAMBROCAHORA | Décision + Temps | Projection d'observabilité |
| RuntimeMonitor | RUNTIME.OBSERVABILITY | Observabilité | Projection de métriques |
| RuntimeDataService | CANNoNICO.STATE_CORE + NAMBROCAHORA | État + Temporal | Projection de données |
| MissionStore | RUNTIME.MISSION_EXECUTION | Mission | Projection de cycle de vie |
| SUPRAScheduler | RUNTIME.WORKFLOW_ENGINE | Planification | Projection de DAG |
| SUPRADecisionEngine | RUNTIME.DECISION_ENGINE | Décision | Projection d'évaluation |
| SUPRAMissionExecutor | RUNTIME.TASK_EXECUTION | Exécution | Projection de tâche |
| NOVAKnowledgeKernel | CANNoNICO.KNOWLEDGE_CORE | Connaissance | Projection de registre |
| SUPRACanonicalWorldAccess | CANNoNICO.KNOWLEDGE_CORE + CANNoNICO.STATE_CORE | Accès canonique | Projection d'accès |
| CAnnoNicoCircuitBoardView | CANNoNICO.IDENTITY_CORE + CANNoNICO.RELATION_CORE | Visualisation | Projection UI |
| OpenCodeBridge | RUNTIME.PROVIDER_BRIDGE | Connexion | Projection de pont |
| CAnnoNicoSnapshotStore | CANNoNICO.STATE_CORE | État snapshot | Projection de cache |
| ExecutiveMemory | CANNoNICO.MEMORY_CORE + CANNoNICO.DECISION_CORE | Mémoire + Décision | Projection de requête |

### 7.2 Projections JSON/Registry

| Fichier JSON | Concept Canonique | Type de Projection |
|---|---|---|
| CANONICAL_RUNTIME.json | RUNTIME + CANNoNICO | Projection des types runtime |
| CANONICAL_REGISTRY.json | CANNoNICO.IDENTITY_CORE | Projection des identités |
| CANONICAL_SERVICES.json (→ déprécié) | RUNTIME.SERVICES | Projection des services (à fusionner) |
| knowledge_graph.json | CANNoNICO.KNOWLEDGE_CORE | Projection du graphe de connaissance |
| knowledge_identity.json | CANNoNICO.IDENTITY_CORE | Projection des identités de connaissance |
| knowledge_relations.json | CANNoNICO.RELATION_CORE | Projection des relations de connaissance |
| runtime_trace.json | RUNTIME.OBSERVABILITY + NAMBROCAHORA | Projection des traces (à migrer vers NAMBROCAHORA) |
| delegation_trace.json | RUNTIME.OBSERVABILITY + NAMBROCAHORA | Projection des délégations (à migrer) |
| runtime_metrics.json | RUNTIME.OBSERVABILITY | Projection des métriques |
| CANNoNICO_REGISTRY.json | CANNoNICO.IDENTITY_CORE | Projection du registre CANNoNICO |
| CANONICAL_PACKAGES.json | TUV5.INGESTION | Projection des packages |
| CANONICAL_MODULES.json | TUV5.INGESTION | Projection des modules |
| CANONICAL_BRIDGES.json | RUNTIME.CONNECTOR | Projection des connecteurs |
| CANONICAL_ADAPTERS.json | RUNTIME.CONNECTOR | Projection des adaptateurs |
| CANONICAL_PROJECTS.json | TUV5.INGESTION | Projection des projets |
| CANONICAL_WORKERS.json | RUNTIME.TASK_EXECUTION | Projection des workers |
| services.json | RUNTIME.ORCHESTRATION + RUNTIME.PROJECTION | Projection des services |
| runtime_diagnostics.json | PUCHERO.CONTRADICTION_DETECTION | Projection des diagnostics |
| router_decision.json | RUNTIME.DECISION_ENGINE | Projection des décisions de routage |
| consensus_trace.json | PUCHERO.CONSOLIDATION | Projection de la consistance |

### 7.3 Projections Bash/Scripts

| Script | Concept Canonique | Type de Projection |
|---|---|---|
| GO_SUPRA_GLOBAL_AUDIT.sh | PUCHERO.CONTRADICTION_DETECTION + RUNTIME.OBSERVABILITY | Audit de cohérence |
| GO_SUPRA_BUILD_MATRIX.sh | RUNTIME.WORKFLOW_ENGINE | Exécution de build |
| SUPRA_RUNTIME.sh | RUNTIME.ORCHESTRATION | Orchestration runtime |
| GO_SUPRA_RUNTIME_DOCTOR_V1.sh | PUCHERO.REPAIR | Diagnostic système |
| GO_SUPRA_RECOVERY.sh | RUNTIME.MISSION_EXECUTION (Recovery) | Récupération |
| GO_SUPRA_MEMORY_RECONNECT.sh | CANNoNICO.MEMORY_CORE | Reconnexion mémoire |
| GO_SUPRA_FIND_ACTIVE_PROJECT.sh | TUV5.INGESTION | Ingestion de projet |
| GO_SUPRA_STORAGE_AUDIT_V1.sh | TUV5.FUSION | Audit de stockage |
| GO_SUPRA_INSTALL.sh | TUV5.COMPILATION | Installation/compilation |
| GO_SUPRA_VALIDATE.sh | PUCHERO.MATURITY_GATE | Validation de maturité |
| SUPRA_NODE_STATUS.sh | CANNoNICO.STATE_CORE + NAMBROCAHORA | État du nœud |

### 7.4 Projections Markdown/Documentation

| Document | Concept Canonique | Type de Projection |
|---|---|---|
| TUV5_KNOWLEDGE_COMPILER.md | TUV5 (entier) | Spécification canonique |
| CANNoNICO_FOUNDATION.md | CANNoNICO (entier) | Spécification canonique |
| NAMBROCAHORA_FOUNDATION.md | NAMBROCAHORA (entier) | Spécification canonique |
| RUNTIME_CANONICAL_MODEL.md | RUNTIME + CANNoNICO (entier) | Modèle canonique |
| SUPRA_COMPONENT_CATALOG.md | CANNoNICO.IDENTITY_CORE | Catalogue d'identités |
| SUPRA_CAPABILITY_CONTRACTS.md | CANNoNICO (entier) | Contrats de capacité |
| SUPRA_COMPONENT_CONTRACTS.md | CANNoNICO (entier) | Contrats inter-composants |
| NOVA_KNOWLEDGE_OS_FOUNDATION_V1_REPORT.md | TUV5 + CANNoNICO + RUNTIME | Rapport fondation |
| CANNoNICO_ONTOLOGY.md | CANNoNICO.KNOWLEDGE_CORE | Ontologie canonique |
| CANONICO_CONSTRAINT_LIBRARY.md | CANNoNICO.CONSTRAINT_CORE | Bibliothèque de contraintes |
| CANONICO_PATTERN_LIBRARY.md | CANNoNICO.KNOWLEDGE_CORE | Modèles canoniques |

### 7.5 Projections UI (SwiftUI Views)

| View | Concept Canonique | Type de Projection |
|---|---|---|
| CAnnoNicoCircuitBoardView | CANNoNICO.IDENTITY_CORE + CANNoNICO.RELATION_CORE | Visualisation du graphe canonique |
| SUPRAStructureNavigatorView | CANNoNICO.KNOWLEDGE_CORE | Navigation dans la connaissance |
| RuntimeView (RT-017) | RUNTIME.OBSERVABILITY + NAMBROCAHORA | Vue runtime |
| ExecutiveCockpitFoundation | RUNTIME.PROJECTION + CANNoNICO.GOVERNANCE_CORE | Tableau de bord exécutif |

---

## SYNTHÈSE : ÉTAT ACTUEL VS. ARCHITECTURE CIBLE

### Composition Actuelle

| Dimension | Count | Observations |
|---|---|---|
| Services Runtime | 9 | Tous actifs, pas tous rattachés à une faculté |
| Composants NUCLEO | 92 | Classification existante mais non alignée avec les 4 facultés |
| Types Runtime CANNoNICO | 21 | Tous actifs |
| Fichiers CANONICAL_* JSON | 17 | Registres dupliqués (RD1) |
| Docs CANNoNICO/CANONICO | 15+ | Fragmentation élevée (RD2) |
| Mémoires multiples | 4 | MultiMemory, ConversationMemory, SnapshotStore, ExecutiveMemory |
| Timestamps système dispersés | N/A | Violations de NAMBROCAHORA (R5) |
| Régimes d'ID | 3+ | CAN_ID + ComponentID + NUCLEO paths (R6) |

### Composition Cible (après migration)

| Dimension | Count | Observations |
|---|---|---|
| Facultés | 4 | TUV5, PUCHERO, CANNoNICO, RUNTIME |
| Capacités par faculté | 8-10 | Total ~36 capacités |
| Services Runtime | 9 | Reclassés sous les facultés |
| Composants NUCLEO | 92 | Reclassés sous les facultés |
| CANNoNICO Core | 1 | Unique noyau de représentation |
| TUV5 Pipeline | 1 | Unique compilateur |
| NAMBROCAHORA | 1 | Unique référence temporelle |
| Projections | 7 catégories | Swift, JSON, Bash, Markdown, YAML, UI, API |

### Gap Analysis

| Gap | Severity | Faculté Manquante |
|---|---|---|
| PUCHERO n'a pas d'engine dédié | CRITIQUE | PUCHERO |
| Pas de Projection Engine | CRITIQUE | CANNoNICO + RUNTIME |
| Pas de pipeline TUV5 implementé | CRITIQUE | TUV5 |
| Pas de CANNoNICO Runtime Engine | ÉLEVÉE | CANNoNICO |
| Pas de Knowledge Graph Query Interface | ÉLEVÉE | TUV5 + CANNoNICO |
| Pas de canonicalization state machine | MOYENNE | CANNoNICO |
| NAMBROCAHORA non intégré au Runtime | ÉLEVÉE | TUV5 + RUNTIME |
| Pas de canonical evidence chain | MOYENNE | PUCHERO + CANNoNICO |
| Mémoires non unifiées | MOYENNE | CANNoNICO |
| Gouvernance fragmentée | MOYENNE | CANNoNICO |

---

## RECOMMANDATIONS D'EXÉCUTION

### Phase 1 — Canonicalization (Priorité CRITIQUE)
1. Implémenter TUV5 Ingestion Pipeline (M3)
2. Créer le PUCHERO Knowledge Maturation Engine (CM1)
3. Implémenter le Projection Engine (CM2)
4. Unifier les mémoires sous CANNoNICO.MEMORY_CORE (M10)

### Phase 2 — Migration (Priorité ÉLEVÉE)
5. Migrer les timestamps vers NAMBROCAHORA (M1)
6. Fusionner les schedulers (R1)
7. Fusionner les intelligence engines (R2)
8. Consolidider les registres dupliqués (RD1)
9. Migrer les modèles Runtime vers CANNoNICO (M14)

### Phase 3 — Gouvernance (Priorité MOYENNE)
10. Unifier la gouvernance sous CANNoNICO.GOVERNANCE_CORE (M17)
11. Créer la canonicalization state machine (CM6)
12. Créer le Knowledge Graph Query Interface (CM5)

### Phase 4 — Optimisation (Priorité BASSE)
13. Déprécier les composants legacy
14. Déprécier les fichiers de registre individuels
15. Atteindre le critère de maturité : reconstruction complète depuis la connaissance canonique seule

---

## CONFORMITÉ AUX LOIS SUPRA

| Loi | Conformité | Mécanisme |
|---|---|---|
| Loi 1 : Connaissance > fichiers | ✅ | Tous les fichiers sont des projections du modèle canonique |
| Loi 2 : Runtime raisonne en CANNoNICO | ✅ (en cours) | CANNoNICO Core défini, migration en cours (Phase 2) |
| Loi 3 : Runtime synchronise en NAMBROCAHORA | ✅ (en cours) | Spec définie, migration des timestamps en cours (Phase 2) |
| Loi 4 : TUV5 transforme complexité → connaissance | ✅ | Spec TUV5 complète, implémentation en Phase 1 |
| Loi 5 : Nouvelles capacités enrichissent le Runtime | ✅ | Chaque capacité ajoutée est rattachée à une faculté |
| Nouvelle Loi : Un artefact ne peut être la source de vérité | ✅ | Seule la connaissance canonique est la source de vérité |

---

## CRITÈRE DE MATURITÉ

SUPRA atteint le premier niveau de maturité lorsque :

> Si l'ensemble du dépôt Git disparaissait aujourd'hui, le Runtime serait capable de reconstruire progressivement les Runtime Services, les projections Swift, les scripts Bash, les Manifest, la documentation et les interfaces à partir de la seule connaissance canonique.

**État actuel :** NON ATTEINT (2/7 projections non implémentées, TUV5 pipeline non opérationnel, PUCHERO engine absent)

**Critères de validation :**
1. Le CANNoNICO Core contient toutes les identités, relations, contraintes et preuves
2. Le TUV5 Pipeline est opérationnel (can compile tout source en CANNoNICO)
3. Le PUCHERO Engine est opérationnel (peut évaluer la maturité de toute connaissance)
4. Le Projection Engine génère toutes les projections (Swift, JSON, Bash, Markdown, YAML, UI, API)
5. Le NAMBROCAHORA est intégré au Runtime (aucun Date() système dans les modèles)
6. La Memory Core est unifiée (4 stores → 1)
7. Les 14 primitives CANNoNICO suffisent à reconstruct tous les composants

---

*Proposition d'architecture — SUPRA Système Cognitif Gouverné*
*Document produit le 2026-07-29 dans le cadre de l'Execution Gate : Transition vers le Système Cognitif Gouverné*
*Autorité : SUPRA Constitution — Article 2*
