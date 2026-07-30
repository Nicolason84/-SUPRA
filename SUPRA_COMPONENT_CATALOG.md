# SUPRA COMPONENT CATALOG V1

## Catalogue Complet des Composants Permanents de SUPRA Ultimate Consolidated

| Propriété | Valeur |
|-----------|--------|
| **Statut** | CORE — Catalogue canonique permanent |
| **Version** | SUPRA_COMPONENT_CATALOG_V1 |
| **Date** | 2026-07-29 |
| **Autorité** | SUPRA Platform Registry — extension détaillée |

---

## Layer L0 — Industrial Base

### L0.STANDARD_FRAMEWORK — SUPRA Standard Framework
- **Mission**: Définir et maintenir les standards, conventions et schémas de la plateforme
- **Responsabilités**: Nommage, organisation des fichiers, formats documentaires, templates SDK
- **Entrées**: Besoins de standardisation des couches supérieures
- **Sorties**: Standards publiés, conventions validées, templates
- **Interfaces**: `get_standard(id) → standard`, `validate_conformance(doc) → report`
- **Dépendances**: Aucune (autonome)
- **Invariants**: Un seul standard par domaine, pas de contradiction inter-standards
- **Constraints**: Rétrocompatibilité obligatoire
- **Lifecycle**: PRODUCTION
- **Validation**: Conformité de tous les documents aux standards définis
- **Remplaçable**: PARTIEL

### L0.REGISTRY_SYSTEM — SUPRA Registry System
- **Mission**: Gérer l'ensemble des registres canoniques de la plateforme
- **Responsabilités**: Enregistrement, validation, découverte, cycle de vie
- **Entrées**: Définitions de registre, mises à jour
- **Sorties**: Registres validés, état des registres
- **Interfaces**: `register(schema, data) → entry`, `query(filters) → [entry]`, `validate(registry) → report`
- **Dépendances**: L0.STANDARD_FRAMEWORK
- **Invariants**: Chaque domaine a exactement un registre source de vérité
- **Constraints**: Format JSON, validation de schéma obligatoire
- **Lifecycle**: PRODUCTION
- **Validation**: Tous les registres valides, pas de duplications
- **Remplaçable**: PARTIEL

### L0.DOCUMENT_HIERARCHY — SUPRA Document Hierarchy
- **Mission**: Définir la hiérarchie officielle des documents
- **Responsabilités**: Classification, préséance, règles de mise à jour
- **Entrées**: Nouveaux types de documents
- **Sorties**: Hiérarchie à jour, règles de préséance
- **Interfaces**: `classify(document) → category`, `get_precedence(doc_a, doc_b) → precedence`
- **Dépendances**: L0.STANDARD_FRAMEWORK
- **Invariants**: Catégorisation unique, pas de conflit de préséance
- **Lifecycle**: ULTIMATE
- **Remplaçable**: OUI

### L0.ADR_STANDARD — SUPRA ADR Standard
- **Mission**: Définir le format et le cycle de vie des Architecture Decision Records
- **Responsabilités**: Template ADR, niveaux, règles de validation
- **Entrées**: Décisions architecturales
- **Sorties**: ADR formatées, validées
- **Interfaces**: `create_adr(decision, context) → adr`, `validate_adr(adr) → report`
- **Dépendances**: L0.STANDARD_FRAMEWORK
- **Invariants**: Toute décision architecturale produit une ADR
- **Lifecycle**: ULTIMATE
- **Remplaçable**: NON

### L0.GATE_SYSTEM — SUPRA Gate System
- **Mission**: Contrôler les transitions entre étapes du cycle de vie
- **Responsabilités**: Définition des gates, critères de validation, process
- **Entrées**: Demande de transition
- **Sorties**: Décision PASS/BLOCK, rapport de gate
- **Interfaces**: `validate_gate(component, from, to) → decision`, `get_gate_criteria(gate_id) → criteria`
- **Dépendances**: L0.EVOLUTION_LAW
- **Invariants**: Aucune transition sans validation de gate
- **Lifecycle**: ULTIMATE
- **Remplaçable**: NON

### L0.EVOLUTION_LAW — SUPRA Evolution Law
- **Mission**: Définir le protocole d'évolution du système
- **Responsabilités**: Processus d'évolution, règles de réversibilité
- **Entrées**: Proposition d'évolution
- **Sorties**: Protocole validé
- **Dépendances**: L0.CONSTITUTION
- **Invariants**: Toute évolution est réversible
- **Lifecycle**: ULTIMATE
- **Remplaçable**: NON

### L0.PROTECTION_MODEL — SUPRA Protection Model
- **Mission**: Définir les zones protégées et les règles de protection
- **Responsabilités**: Identification des zones critiques, règles d'accès
- **Entrées**: Composants à protéger
- **Sorties**: Zones protégées, permissions
- **Dépendances**: L0.AUTHORITY_MODEL
- **Invariants**: Les zones protégées nécessitent une décision constitutionnelle pour modification
- **Lifecycle**: ULTIMATE
- **Remplaçable**: NON

### L0.AUTHORITY_MODEL — SUPRA Authority Model
- **Mission**: Définir le modèle d'autorité et la chaîne de commandement
- **Responsabilités**: Rôles, permissions, délégation
- **Entrées**: Définitions de rôles
- **Sorties**: Modèle d'autorité
- **Dépendances**: L0.CONSTITUTION
- **Invariants**: Unicité de l'autorité par domaine
- **Lifecycle**: ULTIMATE
- **Remplaçable**: NON

### L0.CANONICAL_ID — SUPRA Canonical ID System
- **Mission**: Définir le système d'identification unique pour tous les composants
- **Responsabilités**: Format d'ID, résolution, cycle de vie des identifiants
- **Entrées**: Nouveaux composants
- **Sorties**: Identifiants uniques
- **Dépendances**: L0.REGISTRY_SYSTEM
- **Invariants**: Unicité permanente, pas de réutilisation
- **Lifecycle**: PRODUCTION
- **Remplaçable**: NON

### L0.IMMUTABLE_PRINCIPLES — SUPRA Immutable Principles
- **Mission**: Énoncer les principes non négociables du système
- **Responsabilités**: Définition, mise à jour (amendement constitutionnel uniquement)
- **Entrées**: Principes fondateurs
- **Sorties**: Principes publiés
- **Dépendances**: L0.CONSTITUTION
- **Invariants**: Les principes sont immuables sans amendement constitutionnel
- **Lifecycle**: PRODUCTION
- **Remplaçable**: NON

---

## Layer L1 — Providers + Plugins

### L1.PROVIDER_FRAMEWORK — SUPRA Provider Framework
- **Mission**: Abstraire l'accès aux modèles IA et providers externes
- **Responsabilités**: Interface unifiée, contrat provider, health check, fallback
- **Entrées**: Requêtes modèle, statut provider
- **Sorties**: Réponses modèle, rapport de santé
- **Interfaces**: `execute(model, input) → output`, `health() → status`, `list_providers() → [provider]`
- **Dépendances**: L1.MODEL_REGISTRY, L0.STANDARD_FRAMEWORK
- **Invariants**: Interface uniforme pour tous les providers
- **Lifecycle**: GOVERNANCE
- **Remplaçable**: OUI
- **Implémentations Swift**: SUPRAOllamaProvider, OpenCodeClient

### L1.PLUGIN_SDK — SUPRA Plugin SDK
- **Mission**: Permettre l'extension du système par des plugins externes
- **Responsabilités**: SDK, points d'extension, contrat plugin
- **Entrées**: Définition de plugin
- **Sorties**: Plugin enregistré, hooks activés
- **Interfaces**: `register_plugin(plugin_def) → plugin_id`, `get_hooks(event) → [plugin]`
- **Dépendances**: L0.STANDARD_FRAMEWORK, L4.RUNTIME_KERNEL
- **Invariants**: Les plugins ne modifient pas le noyau
- **Lifecycle**: CONSTITUTION
- **Remplaçable**: OUI

### L1.MODEL_REGISTRY — SUPRA Model Registry
- **Mission**: Catalogue central des modèles LLM disponibles
- **Responsabilités**: Enregistrement, détection automatique (Ollama), health check, scoring
- **Entrées**: Définition de modèle, découverte Ollama
- **Sorties**: Fiche modèle, meilleur modèle pour tâche
- **Interfaces**: `register(model_def)`, `list(filters) → [model]`, `best_for(task) → model`, `health() → status`
- **Dépendances**: Aucune
- **Invariants**: Chaque modèle a un ID unique
- **Lifecycle**: GOVERNANCE
- **Remplaçable**: NON
- **Implémentations Swift**: SUPRAModelRegistry

### L1.AGENT_REGISTRY — SUPRA Agent Registry
- **Mission**: Catalogue central de tous les agents disponibles
- **Responsabilités**: Enregistrement, découverte, health check, cycle de vie
- **Entrées**: Définition d'agent
- **Sorties**: Fiche agent, état
- **Interfaces**: `register(agent_def)`, `resolve(capability) → [agent]`, `status(agent_id) → state`
- **Dépendances**: L1.CAPABILITY_REGISTRY
- **Invariants**: Chaque agent a un rôle unique
- **Lifecycle**: GOVERNANCE
- **Remplaçable**: NON

### L1.CAPABILITY_REGISTRY — SUPRA Capability Registry
- **Mission**: Graphe de correspondance entre tâches, agents et modèles
- **Responsabilités**: Classification des tâches, mapping, scoring
- **Entrées**: Tâche ou besoin
- **Sorties**: Couples (agent, modèle) capables
- **Interfaces**: `find_capable(task) → [(agent, model, score)]`
- **Dépendances**: L1.AGENT_REGISTRY, L1.MODEL_REGISTRY
- **Invariants**: Classification reproductible
- **Lifecycle**: GOVERNANCE
- **Remplaçable**: OUI

### L1.PROMPT_REGISTRY — SUPRA Prompt Registry
- **Mission**: Bibliothèque versionnée de prompts optimisés
- **Responsabilités**: Stockage, versionnement, A/B testing
- **Entrées**: Prompt + métadonnées
- **Sorties**: Prompt versionné
- **Interfaces**: `get(task, model) → prompt`, `register(prompt, meta)`, `optimize(prompt_id, feedback)`
- **Dépendances**: L3.LEARNING_ENGINE
- **Lifecycle**: FOUNDATION
- **Remplaçable**: OUI

### L1.OLLAMA_PROVIDER — SUPRA Ollama Provider
- **Mission**: Fournir l'accès aux modèles Ollama locaux
- **Responsabilités**: Interface avec l'API Ollama, détection des modèles
- **Entrées**: Requêtes modèle
- **Sorties**: Réponses, statut
- **Dépendances**: L1.PROVIDER_FRAMEWORK
- **Lifecycle**: GOVERNANCE
- **Remplaçable**: OUI
- **Implémentations Swift**: SUPRAOllamaProvider

---

## Layer L2 — Theory + Knowledge

### L2.KNOWLEDGE_COMPILER — SUPRA Knowledge Compiler
- **Mission**: Point d'entrée unique pour toute la connaissance dans SUPRA
- **Responsabilités**: Ingestion, processing, publication de toute information
- **Entrées**: Sources (documents, code, git, logs, etc.)
- **Sorties**: Graphes (knowledge, constraint, evidence, consistency, executive)
- **Interfaces**: `compile(source, options) → result`, `status(compilation_id) → state`
- **Dépendances**: L2.ONTOLOGY_ENGINE, L2.CONSTRAINT_ENGINE, L2.CONSISTENCY_ENGINE, L2.EVIDENCE_ENGINE
- **Invariants**: Aucune information ne contourne le Compiler
- **Cycle**: DETECT → MERGE → NORMALIZE → VALIDATE → COMPILE → PUBLISH
- **Lifecycle**: ULTIMATE
- **Remplaçable**: PARTIEL

### L2.ONTOLOGY_ENGINE — SUPRA Ontology Engine
- **Mission**: Aligner les concepts extraits avec l'ontologie unifiée
- **Responsabilités**: Alignment des concepts, résolution des conflits ontologiques
- **Entrées**: Concepts extraits
- **Sorties**: Ontologie alignée
- **Interfaces**: `align([Concept]) → AlignedOntology`
- **Dépendances**: L2.UNIFIED_ONTOLOGY
- **Lifecycle**: ULTIMATE
- **Remplaçable**: OUI

### L2.CONSTRAINT_ENGINE — SUPRA Constraint Engine
- **Mission**: Valider toutes les contraintes, détecter les violations
- **Responsabilités**: Validation SAT, détection de violations
- **Entrées**: État du graphe
- **Sorties**: Violations détectées
- **Interfaces**: `validate(GraphState) → [Violation]`
- **Dépendances**: L2.CONSTRAINT_LIBRARY
- **Lifecycle**: ULTIMATE
- **Remplaçable**: OUI

### L2.CONSISTENCY_ENGINE — SUPRA Consistency Engine
- **Mission**: Détecter toutes les formes d'incohérence
- **Responsabilités**: Vérification multi-dimensionnelle
- **Entrées**: État du graphe
- **Sorties**: Rapport de cohérence
- **Interfaces**: `check(GraphState) → ConsistencyReport`
- **Dépendances**: L2.CONSTRAINT_ENGINE
- **Lifecycle**: ULTIMATE
- **Remplaçable**: OUI

### L2.EVIDENCE_ENGINE — SUPRA Evidence Engine
- **Mission**: Suivre les chaînes de preuve, vérifier l'exhaustivité
- **Responsabilités**: Traçabilité des preuves, vérification
- **Entrées**: Preuves
- **Sorties**: Résultats de vérification
- **Interfaces**: `verify([Evidence]) → [VerificationResult]`
- **Dépendances**: L2.KNOWLEDGE_COMPILER
- **Lifecycle**: ULTIMATE
- **Remplaçable**: OUI

### L2.TRUST_ENGINE — SUPRA Trust Engine
- **Mission**: Calculer et propager les scores de confiance
- **Responsabilités**: Scoring de confiance, propagation
- **Entrées**: État du graphe
- **Sorties**: Scores de confiance
- **Interfaces**: `compute(GraphState) → TrustScores`
- **Dépendances**: L2.EVIDENCE_ENGINE
- **Lifecycle**: ULTIMATE
- **Remplaçable**: OUI

### L2.ROOT_CAUSE_ENGINE — SUPRA Root Cause Engine
- **Mission**: Tracer les violations jusqu'à leurs causes profondes
- **Responsabilités**: Analyse backward, détection de cause racine
- **Entrées**: Violation
- **Sorties**: Cause racine
- **Interfaces**: `trace(Violation) → RootCause`
- **Dépendances**: L2.CONSTRAINT_ENGINE
- **Lifecycle**: ULTIMATE
- **Remplaçable**: OUI

### L2.REPAIR_ENGINE — SUPRA Repair Engine
- **Mission**: Proposer des corrections minimales
- **Responsabilités**: Génération de propositions de correction
- **Entrées**: Violation + cause racine
- **Sorties**: Propositions de correction
- **Interfaces**: `repair(Violation) → [Proposal]`
- **Dépendances**: L2.ROOT_CAUSE_ENGINE
- **Lifecycle**: ULTIMATE
- **Remplaçable**: OUI

### L2.PATTERN_ENGINE — SUPRA Pattern Engine
- **Mission**: Détecter et appliquer les patterns structurels
- **Responsabilités**: Détection de patterns, application
- **Entrées**: AST normalisé
- **Sorties**: Patterns détectés
- **Interfaces**: `extract(NormalizedAST) → [Pattern]`
- **Dépendances**: L2.PATTERN_LIBRARY
- **Lifecycle**: ULTIMATE
- **Remplaçable**: OUI

### L2.PROJECTION_ENGINE — SUPRA Projection Engine
- **Mission**: Générer des projections validées (vues read-only)
- **Responsabilités**: Génération de vues typées
- **Entrées**: État du graphe + type de projection
- **Sorties**: Projection
- **Interfaces**: `project(GraphState, Type) → Projection`
- **Dépendances**: L2.KNOWLEDGE_COMPILER
- **Lifecycle**: ULTIMATE
- **Remplaçable**: OUI

### L2.EXECUTIVE_ENGINE — SUPRA Executive Engine
- **Mission**: Produire des résumés et graphes décisionnels
- **Responsabilités**: Extraction de faits, agrégation de risques
- **Entrées**: Tous les graphes compilés
- **Sorties**: Graphe exécutif
- **Interfaces**: `compile(graphs) → ExecutiveGraph`, `current() → ExecutiveGraph`
- **Dépendances**: Tous les engines L2
- **Lifecycle**: ULTIMATE
- **Remplaçable**: PARTIEL

---

## Layer L3 — Sherpa + Cortex

### L3.SHERPA — SUPRA Sherpa
- **Mission**: Sélectionner le contexte pertinent pour chaque mission
- **Responsabilités**: Analyse du contexte, sélection des sources
- **Entrées**: Mission, contexte disponible
- **Sorties**: Contexte sélectionné
- **Dépendances**: L5.KNOWLEDGE_KERNEL, L4.MISSION_KERNEL, L5.EXECUTIVE_KERNEL
- **Lifecycle**: IDEA
- **Remplaçable**: OUI

### L3.CORTEX — SUPRA Cortex
- **Mission**: Assurer la mémoire persistante et l'apprentissage
- **Responsabilités**: Mémoire, décisions, apprentissage
- **Entrées**: Résultats de mission, feedback
- **Sorties**: Mémoire mise à jour, patterns appris
- **Dépendances**: L5.KNOWLEDGE_KERNEL, L4.MISSION_KERNEL, L4.RUNTIME_KERNEL
- **Lifecycle**: IDEA
- **Remplaçable**: OUI

### L3.LEARNING_ENGINE — SUPRA Learning Engine
- **Mission**: Améliorer les modules par rétroaction continue
- **Responsabilités**: Feedback loops, optimisation de prompts
- **Entrées**: Résultats, métriques, feedback
- **Sorties**: Prompts optimisés, règles mises à jour
- **Interfaces**: `learn_from(outcome, metrics)`, `optimize_prompt(prompt_id, feedback)`
- **Dépendances**: L1.MODEL_REGISTRY, L1.PROMPT_REGISTRY
- **Lifecycle**: FOUNDATION
- **Remplaçable**: OUI

### L3.DECISION_ENGINE — SUPRA Decision Engine
- **Mission**: Gérer le cycle de vie des décisions
- **Responsabilités**: Proposition, évaluation, décision, suivi
- **Entrées**: Décision proposée
- **Sorties**: Décision tracée
- **Dépendances**: L5.GOVERNANCE_KERNEL
- **Lifecycle**: FOUNDATION
- **Remplaçable**: OUI
- **Implémentations Swift**: DecisionStore

---

## Layer L4 — Runtime + Workspace

### L4.EXECUTIVE_RUNTIME — SUPRA Executive Runtime
- **Mission**: Orchestrer et exécuter les missions
- **Responsabilités**: Ordonnancement, exécution, monitoring
- **Entrées**: Mission planifiée
- **Sorties**: Résultat d'exécution
- **Dépendances**: Tous les composants L4
- **Lifecycle**: GOVERNANCE
- **Remplaçable**: PARTIEL

### L4.WORKFLOW_ENGINE — SUPRA Workflow Engine
- **Mission**: Ordonnancer et exécuter le pipeline complet
- **Responsabilités**: Exécution du DAG, parallélisation, erreurs
- **Entrées**: DAG du Planner
- **Sorties**: Résultat final + traces
- **Interfaces**: `execute(dag) → result`, `cancel(mission_id)`, `status(mission_id) → state`
- **Dépendances**: Tous les modules
- **Lifecycle**: CONSTITUTION
- **Remplaçable**: NON

### L4.PLANNER — SUPRA Planner
- **Mission**: Décomposer une mission en étapes atomiques
- **Responsabilités**: Analyse, génération de DAG, détection de parallélisation
- **Entrées**: Mission + contraintes
- **Sorties**: DAG de tâches
- **Interfaces**: `plan(mission, constraints) → dag`
- **Dépendances**: L4.ROUTER, L3.CORTEX
- **Lifecycle**: CONSTITUTION
- **Remplaçable**: OUI

### L4.ROUTER — SUPRA Router
- **Mission**: Aiguiller chaque mission vers le meilleur couple (agent, modèle)
- **Responsabilités**: Classification, scoring, sélection
- **Entrées**: Mission + registres
- **Sorties**: Plan d'affectation
- **Interfaces**: `route(mission) → plan`, `health() → status`
- **Dépendances**: L1.AGENT_REGISTRY, L1.MODEL_REGISTRY, L1.CAPABILITY_REGISTRY
- **Lifecycle**: GOVERNANCE
- **Remplaçable**: OUI

### L4.COMPARATOR — SUPRA Comparator
- **Mission**: Comparer les sorties de plusieurs agents/modèles
- **Responsabilités**: Analyse sémantique, détection de conflits
- **Entrées**: Sorties multiples
- **Sorties**: Matrice de comparaison
- **Interfaces**: `compare(outputs) → matrix`
- **Dépendances**: L4.FUSION_ENGINE, L4.ROUTER
- **Lifecycle**: CONSTITUTION
- **Remplaçable**: OUI

### L4.FUSION_ENGINE — SUPRA Fusion Engine
- **Mission**: Fusionner des sorties multiples en un résultat unique
- **Responsabilités**: Vote, weighted merge, synthèse
- **Entrées**: Sorties + matrice
- **Sorties**: Résultat fusionné
- **Interfaces**: `fuse(outputs, matrix) → result`
- **Dépendances**: L4.COMPARATOR
- **Lifecycle**: CONSTITUTION
- **Remplaçable**: OUI

### L4.VALIDATOR — SUPRA Validator
- **Mission**: Valider le résultat contre les critères d'acceptation
- **Responsabilités**: Vérification, tests, conformité
- **Entrées**: Résultat + critères
- **Sorties**: Rapport de validation
- **Interfaces**: `validate(result, criteria) → report`
- **Dépendances**: L4.FUSION_ENGINE, L4.BENCHMARK
- **Lifecycle**: CONSTITUTION
- **Remplaçable**: OUI

### L4.BENCHMARK — SUPRA Benchmark
- **Mission**: Évaluer les performances des modèles et agents
- **Responsabilités**: Exécution de benchmarks, collecte de métriques
- **Entrées**: Modèles/agents + tests
- **Sorties**: Scores, classement
- **Interfaces**: `run(benchmark_suite) → scores`, `compare(model_a, model_b) → delta`
- **Dépendances**: L1.MODEL_REGISTRY, L3.LEARNING_ENGINE
- **Lifecycle**: CONSTITUTION
- **Remplaçable**: OUI

### L4.METRICS_ENGINE — SUPRA Metrics Engine
- **Mission**: Collecter, agréger et exposer les métriques
- **Responsabilités**: Instrumentation, tableaux de bord, alertes
- **Entrées**: Événements de tous les modules
- **Sorties**: Métriques, historiques, rapports
- **Interfaces**: `record(event)`, `query(metric, window) → values`, `alert(rule)`
- **Dépendances**: Tous les modules (consommation)
- **Lifecycle**: FOUNDATION
- **Remplaçable**: OUI

### L4.WORKSPACE_MANAGER — SUPRA Workspace Manager
- **Mission**: Gérer l'espace de travail et ses ressources
- **Responsabilités**: Indexation, découverte, structure
- **Entrées**: Événements workspace
- **Sorties**: État du workspace
- **Dépendances**: L5.KNOWLEDGE_KERNEL
- **Lifecycle**: GOVERNANCE
- **Remplaçable**: OUI

### L4.MISSION_KERNEL — SUPRA Mission Kernel
- **Mission**: Gérer le cycle de vie des missions
- **Responsabilités**: États, transitions, handover, preuve
- **Entrées**: Mission créée
- **Sorties**: Mission tracée
- **Dépendances**: L5.EXECUTIVE_KERNEL
- **Lifecycle**: GOVERNANCE
- **Remplaçable**: PARTIEL

### L4.RUNTIME_KERNEL — SUPRA Runtime Kernel
- **Mission**: Gérer l'état du runtime, les services, les pipelines
- **Responsabilités**: État, orchestration, services
- **Entrées**: Événements runtime
- **Sorties**: État du runtime
- **Dépendances**: L5.PROVIDER_KERNEL
- **Lifecycle**: GOVERNANCE
- **Remplaçable**: PARTIEL
- **Implémentations Swift**: SUPRARuntimeMetrics, RuntimeEvent, RuntimeSourceProtocol

### L4.TWIN_UNIVERSE — SUPRA Twin Universe
- **Mission**: Gérer les jumeaux numériques des composants
- **Responsabilités**: Registre des twins, synchronisation, cycle de vie
- **Entrées**: État des composants
- **Sorties**: État des twins
- **Dépendances**: L4.RUNTIME_KERNEL
- **Lifecycle**: GOVERNANCE
- **Remplaçable**: OUI
- **Implémentations Swift**: TwinUniverse, TwinRegistry, TwinFactory, TwinSynchronizer, TwinLifecycle, TwinIdentity

### L4.CONTROL_TOWER — SUPRA Control Tower
- **Mission**: Surveiller et contrôler l'état du système
- **Responsabilités**: Monitoring, alertes, état global
- **Entrées**: Événements de tous les composants
- **Sorties**: État global, alertes
- **Dépendances**: L4.METRICS_ENGINE, L4.EVENT_BUS
- **Lifecycle**: GOVERNANCE
- **Remplaçable**: OUI
- **Implémentations Swift**: ControlTowerState

### L4.EVENT_BUS — SUPRA Event Bus
- **Mission**: Distribuer les événements entre composants
- **Responsabilités**: Publication, souscription, routage d'événements
- **Entrées**: Événements
- **Sorties**: Événements distribués
- **Dépendances**: Aucune
- **Lifecycle**: FOUNDATION
- **Remplaçable**: OUI

---

## Layer L5 — Executive + Products

### L5.EXECUTIVE_KERNEL — SUPRA Executive Kernel
- **Mission**: Définir et maintenir la vision, mission et objectifs du système
- **Responsabilités**: Vision, mission, objectifs, interfaces publiques
- **Entrées**: Directives exécutives
- **Sorties**: Vision, objectifs, KPIs
- **Interfaces**: `get_vision()`, `get_mission()`, `get_objectives()`, `get_kpis()`
- **Dépendances**: L5.CONSTITUTION
- **Invariants**: Vision cohérente, objectifs mesurables
- **Lifecycle**: ULTIMATE
- **Remplaçable**: NON

### L5.GOVERNANCE_KERNEL — SUPRA Governance Kernel
- **Mission**: Assurer la gouvernance du système
- **Responsabilités**: Constitution, gates, compliance, ADR
- **Entrées**: Demandes de gate, ADR, compliance
- **Sorties**: Décisions de gate, rapports de compliance
- **Interfaces**: `validate_gate(component, transition) → decision`, `check_compliance(component) → report`
- **Dépendances**: L0.GATE_SYSTEM, L0.ADR_STANDARD
- **Lifecycle**: ULTIMATE
- **Remplaçable**: NON

### L5.KNOWLEDGE_KERNEL — SUPRA Knowledge Kernel
- **Mission**: Centraliser l'accès à toute la connaissance du système
- **Responsabilités**: ZERO, FOUNDATION, registres, manifests, maps
- **Entrées**: Requêtes de connaissance
- **Sorties**: Contexte, registres, manifests
- **Dépendances**: L2.KNOWLEDGE_COMPILER
- **Lifecycle**: ULTIMATE
- **Remplaçable**: PARTIEL

### L5.PRODUCT_KERNEL — SUPRA Product Kernel
- **Mission**: Gérer les relations entre CORE, Runtime et Produits
- **Responsabilités**: Mapping CORE/Produits
- **Entrées**: Définitions de produits
- **Sorties**: Relations produit
- **Dépendances**: Tous les kernels L5
- **Lifecycle**: GOVERNANCE
- **Remplaçable**: OUI

### L5.PROVIDER_KERNEL — SUPRA Provider Kernel
- **Mission**: Abstraire l'accès aux providers
- **Responsabilités**: Contrats, résilience, fallback
- **Entrées**: Requêtes provider
- **Sorties**: Réponses provider
- **Dépendances**: L1.PROVIDER_FRAMEWORK
- **Lifecycle**: GOVERNANCE
- **Remplaçable**: PARTIEL

### L5.EXECUTIVE_OS — SUPRA Executive OS
- **Mission**: Orchestrer, gouverner et décider
- **Responsabilités**: Orchestration, gouvernance, décision
- **Entrées**: État du système
- **Sorties**: Décisions, actions
- **Dépendances**: Tous les kernels L5, L4.RUNTIME_KERNEL
- **Lifecycle**: FOUNDATION
- **Remplaçable**: NON

### L5.COMPOSITION_ROOT — SUPRA Composition Root
- **Mission**: Point d'entrée unique du système applicatif
- **Responsabilités**: Injection de dépendances, configuration, bootstrap
- **Entrées**: Configuration système
- **Sorties**: Système initialisé
- **Dépendances**: Tous les composants
- **Lifecycle**: GOVERNANCE
- **Remplaçable**: NON
- **Implémentations Swift**: SUPRACompositionRoot

### L5.DECISION_AUTHORITY — SUPRA Decision Authority
- **Mission**: Gérer l'autorité décisionnelle
- **Responsabilités**: Règles de décision, délégation
- **Entrées**: Requête de décision
- **Sorties**: Décision
- **Dépendances**: L0.AUTHORITY_MODEL
- **Lifecycle**: GOVERNANCE
- **Remplaçable**: PARTIEL
- **Implémentations Swift**: SUPRADecisionAuthority

### L5.CAPABILITY_BROKER — SUPRA Capability Broker
- **Mission**: Négocier les capacités entre agents et ressources
- **Responsabilités**: Matching, allocation
- **Dépendances**: L1.CAPABILITY_REGISTRY
- **Lifecycle**: FOUNDATION
- **Remplaçable**: OUI
- **Implémentations Swift**: SUPRACapabilityBroker

### L5.MISSION_BROKER — SUPRA Mission Broker
- **Mission**: Gérer le cycle de vie avancé des missions
- **Dépendances**: L4.MISSION_KERNEL
- **Lifecycle**: GOVERNANCE
- **Remplaçable**: OUI
- **Implémentations Swift**: SUPRAMissionBroker, SUPRAMissionProposalEngine

### L5.INTELLIGENCE_ENGINE — SUPRA Intelligence Engine
- **Mission**: Coordonner l'intelligence du système
- **Dépendances**: Tous les composants
- **Lifecycle**: FOUNDATION
- **Remplaçable**: OUI
- **Implémentations Swift**: SUPRAIntelligenceEngine, SUPRAIntelligenceGraph

---

## Layer L6 — Presentation

### L6.EXECUTIVE_DASHBOARD — SUPRA Executive Dashboard
- **Mission**: Tableau de bord exécutif du système
- **Implémentations Swift**: DashboardView

### L6.MISSION_CENTER — SUPRA Mission Center
- **Mission**: Centre de gestion des missions
- **Implémentations Swift**: MissionCenterView

### L6.RUNTIME_VIEW — SUPRA Runtime View
- **Mission**: Visualisation du runtime
- **Implémentations Swift**: RuntimeView

### L6.MISSION_GRAPH_VIEW — SUPRA Mission Graph View
- **Mission**: Visualisation du DAG des missions
- **Implémentations Swift**: MissionGraphView

### L6.EVIDENCE_EXPLORER — SUPRA Evidence Explorer
- **Mission**: Exploration des preuves
- **Implémentations Swift**: EvidenceExplorerView

### L6.SETTINGS_VIEW — SUPRA Settings View
- **Mission**: Configuration du système
- **Implémentations Swift**: SettingsView

---

## Agents — Cross-Cutting

| ID | Composant | Mission | Permissions | Modèle | Temp |
|----|-----------|---------|-------------|--------|------|
| AGENT.ARCHITECT | SUPRA-Architect | Concevoir l'architecture, produire des ADR, valider la cohérence | read, grep, glob, lsp | claude-sonnet-4-6 | 0.2 |
| AGENT.BUILDER | SUPRA-Builder | Implémenter du code, générer des artefacts | read, edit, bash, lsp | claude-sonnet-4-6 | 0.1 |
| AGENT.AUDITOR | SUPRA-Auditor | Analyser la conformité, sécurité, intégrité | read, grep, glob, lsp | claude-sonnet-4-6 | 0.1 |
| AGENT.ROUTER | SUPRA-Router | Router les missions vers le meilleur agent-modèle | read, grep, glob, lsp, task, webfetch | claude-sonnet-4-6 | 0.2 |
| AGENT.EXPLORER | SUPRA-Explorer | Naviguer le codebase, comprendre les structures | read, grep, glob, lsp, task | claude-sonnet-4-6 | 0.2 |
| AGENT.RESEARCH | SUPRA-Research | Recherche d'information, documentation | read, grep, glob, lsp, webfetch, websearch | claude-sonnet-4-6 | 0.4 |
| AGENT.RUNTIME | SUPRA-Runtime | Analyser le comportement runtime, diagnostiquer | read, grep, glob, lsp, bash | claude-sonnet-4-6 | 0.2 |
| AGENT.REFACTOR | SUPRA-Refactor | Refactoring sécurisé du code | read, edit, lsp | claude-sonnet-4-6 | 0.1 |
| AGENT.REVIEWER | SUPRA-Reviewer | Relecture de code, style, conventions | read, grep, glob, lsp | claude-sonnet-4-6 | 0.3 |

---

## Cross-Cutting Components

| ID | Composant | Mission | Statut |
|----|-----------|---------|--------|
| CROSS.EXECUTIVE_CANON | SUPRA Executive Canon | Constitution opérationnelle et architecture 7 couches | CANONICAL |
| CROSS.MASTER_INDEX | SUPRA Master Index | Point d'entrée documentaire unique | CANONICAL |
| CROSS.MASTER_GRAPH | SUPRA Master Graph | Graphe officiel des relations, dépendances, autorités | CANONICAL |
| CROSS.MASTER_MANIFEST | SUPRA Master Manifest | Manifeste maître du système | CANONICAL |
| CROSS.MASTER_REGISTRY | SUPRA Master Registry | Registre maître de tous les composants | CANONICAL |
| CROSS.CORE_API | SUPRA Core API | API publique du CORE (spécification) | SPECIFIED |
| CROSS.CORE_API_SWIFT | SUPRA Core API (Swift) | API publique en Swift | ACTIVE |

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA ULTIMATE CONSOLIDATED PHASE 2. Catalogue complet des composants permanents.*
