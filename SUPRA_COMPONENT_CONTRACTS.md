# SUPRA COMPONENT CONTRACTS V1

## Contrats d'Interface entre les Composants Permanents de SUPRA Ultimate Consolidated

| Propriété | Valeur |
|-----------|--------|
| **Statut** | CORE — Contrats canoniques inter-composants |
| **Version** | SUPRA_COMPONENT_CONTRACTS_V1 |
| **Date** | 2026-07-29 |
| **Principe** | Aucune interaction implicite. Aucun couplage caché. |

---

## Master Contract Table

| CID | Source | Target | Type | Severity | Stability |
|-----|--------|--------|------|----------|-----------|
| C-001 | Executive | All Components | Authority | CRITICAL | STABLE |
| C-002 | SUPRA-Architect | SUPRA-Builder | Specification | CRITICAL | STABLE |
| C-003 | SUPRA-Router | All Agents | Routing | CRITICAL | STABLE |
| C-004 | SUPRA-Planner | SUPRA-Router | Planning | HIGH | DRAFT |
| C-005 | SUPRA-Router | SUPRA-WorkflowEngine | Assignment | CRITICAL | DRAFT |
| C-006 | SUPRA-WorkflowEngine | Agents | Execution | CRITICAL | DRAFT |
| C-007 | Agents | SUPRA-Comparator | Comparison | HIGH | DRAFT |
| C-008 | SUPRA-Comparator | SUPRA-FusionEngine | Fusion | HIGH | DRAFT |
| C-009 | SUPRA-FusionEngine | SUPRA-Validator | Validation | HIGH | DRAFT |
| C-010 | SUPRA-Validator | SUPRA-Learning | Feedback | MEDIUM | DRAFT |
| C-011 | SUPRA-Learning | SUPRA-Memory | Storage | MEDIUM | DRAFT |
| C-012 | SUPRA-Memory | All Components | Context | HIGH | DRAFT |
| C-013 | SUPRA-KnowledgeCompiler | All Graphs | Publication | CRITICAL | STABLE |
| C-014 | SUPRA-ExecutiveKernel | All Kernels | Directive | CRITICAL | STABLE |
| C-015 | SUPRA-GovernanceKernel | All Components | Compliance | CRITICAL | STABLE |
| C-016 | SUPRA-ProviderKernel | Providers | Abstraction | CRITICAL | STABLE |
| C-017 | SUPRA-PluginSDK | Plugins | Extension | HIGH | DRAFT |
| C-018 | SUPRA-WorkflowEngine | SUPRA-Planner | Feedback | MEDIUM | DRAFT |
| C-019 | SUPRA-Router | SUPRA-ModelRegistry | Discovery | HIGH | STABLE |
| C-020 | SUPRA-Router | SUPRA-AgentRegistry | Discovery | HIGH | STABLE |
| C-021 | SUPRA-Router | SUPRA-CapabilityRegistry | Matching | HIGH | STABLE |
| C-022 | SUPRA-MasterGraph | All Components | Navigation | CRITICAL | STABLE |
| C-023 | SUPRA-MasterIndex | All Components | Discovery | CRITICAL | STABLE |
| C-024 | SUPRA-CoreAPI | All Components | Gateway | CRITICAL | STABLE |
| C-025 | SUPRA-ExecutiveCockpit | SUPRA-Runtime | Read | HIGH | STABLE |
| C-026 | SUPRA-MissionKernel | SUPRA-Planner | Lifecycle | HIGH | STABLE |
| C-027 | SUPRA-RuntimeKernel | All Runtime | State | CRITICAL | STABLE |
| C-028 | SUPRA-TwinUniverse | All Components | Twins | MEDIUM | STABLE |
| C-029 | SUPRA-ControlTower | All Components | Monitoring | MEDIUM | STABLE |
| C-030 | SUPRA-EventBus | All Components | Events | MEDIUM | EXPERIMENTAL |
| C-031 | SUPRA-KnowledgeKernel | New Components | Source | CRITICAL | STABLE |
| C-032 | SUPRA-ExecutiveOS | All Layers | Orchestration | HIGH | EXPERIMENTAL |
| C-033 | SUPRA-CoreAPI | SUPRA-ExecutiveKernel | Public API | CRITICAL | STABLE |
| C-034 | SUPRA-CoreAPI | SUPRA-MissionKernel | Public API | CRITICAL | STABLE |
| C-035 | SUPRA-CoreAPI | SUPRA-GovernanceKernel | Public API | CRITICAL | STABLE |
| C-036 | L2.Ingestion | L2.KnowledgeCompiler | Data Flow | HIGH | DRAFT |
| C-037 | L2.KnowledgeCompiler | L2.Graphs | Publication | CRITICAL | STABLE |
| C-038 | L5.ProductKernel | L6.Presentation | Products | MEDIUM | EXPERIMENTAL |
| C-039 | AGENT.Router | AGENT.All | Assignment | CRITICAL | STABLE |
| C-040 | L4.Router | L4.WorkflowEngine | Plan | HIGH | DRAFT |

---

## Contract Details

### C-001: Executive → All Components (Authority Flow)

```
Executive (Décideur Suprême) → Tous les composants
```

| Propriété | Valeur |
|-----------|--------|
| **CID** | C-001 |
| **Type** | AUTHORITY |
| **Severity** | CRITICAL |
| **Stability** | STABLE |
| **Protocol** | Direct (chaîne d'autorité) |

- **Consumes**: Décision exécutive, validation, orientation stratégique
- **Produces**: Directives, objectifs, KPIs, décisions
- **Guarantees**: Dernier ressort décisionnel, non-contradiction
- **Forbids**: Contournement de la chaîne d'autorité, décision sans preuve
- **Error**: Toute décision non tracée est nulle

### C-002: SUPRA-Architect → SUPRA-Builder (Specification → Implementation)

```
SUPRA-Architect → SUPRA-Builder
```

| Propriété | Valeur |
|-----------|--------|
| **CID** | C-002 |
| **Type** | SPECIFICATION |
| **Severity** | CRITICAL |
| **Stability** | STABLE |

- **Consumes**: Spécification architecturale complète, ADR validée
- **Produces**: Code implémenté, artefacts générés
- **Guarantees**: Conformité à la spécification, traçabilité
- **Forbids**: Implémentation sans spécification, modification non autorisée
- **Error**: Spec incomplète → STOP (retour à l'Architect)

### C-003: SUPRA-Router → All Agents (Routing)

```
SUPRA-Router → Tous les agents spécialisés
```

| Propriété | Valeur |
|-----------|--------|
| **CID** | C-003 |
| **Type** | ROUTING |
| **Severity** | CRITICAL |
| **Stability** | STABLE |

- **Consumes**: Mission classifiée + registres (agents, modèles, capacités)
- **Produces**: Plan d'affectation {agent, modèle, priorité, fallback}
- **Guarantees**: Meilleur couple (agent, modèle) pour chaque tâche
- **Forbids**: Affectation sans capacité vérifiée, routage sans fallback
- **Error**: Fallback systématique si l'agent primaire est indisponible

### C-004: SUPRA-Planner → SUPRA-Router (Planning → Routing)

```
SUPRA-Planner → SUPRA-Router
```

| Propriété | Valeur |
|-----------|--------|
| **CID** | C-004 |
| **Type** | DATA FLOW |
| **Severity** | HIGH |
| **Stability** | DRAFT |

- **Consumes**: Mission brute (texte structuré + métadonnées)
- **Produces**: DAG de tâches {id, type, dépendances, agent_cible}
- **Guarantees**: Décomposition atomique, dépendances explicites
- **Forbids**: Tâches sans dépendance explicite, parallélisme implicite

### C-005: SUPRA-Router → SUPRA-WorkflowEngine (Assignment → Execution)

```
SUPRA-Router → SUPRA-WorkflowEngine
```

| Propriété | Valeur |
|-----------|--------|
| **CID** | C-005 |
| **Type** | DATA FLOW |
| **Severity** | CRITICAL |
| **Stability** | DRAFT |

- **Consumes**: Plan d'affectation + DAG du Planner
- **Produces**: Exécution ordonnancée des tâches
- **Guarantees**: Ordre topologique, dépendances respectées
- **Forbids**: Exécution sans plan, parallélisation non autorisée

### C-006: SUPRA-WorkflowEngine → Agents (Execution)

```
SUPRA-WorkflowEngine → Agents (Builder, Auditor, Research, etc.)
```

| Propriété | Valeur |
|-----------|--------|
| **CID** | C-006 |
| **Type** | EXECUTION |
| **Severity** | CRITICAL |
| **Stability** | DRAFT |

- **Consumes**: Tâche à exécuter + contexte + modèle assigné
- **Produces**: Résultat d'exécution (code, rapport, analyse)
- **Guarantees**: Exécution dans le timeout, résultat structuré
- **Forbids**: Exécution hors périmètre, modification non autorisée

### C-007: Agents → SUPRA-Comparator (Output Comparison)

```
Agents → SUPRA-Comparator (mode consensus uniquement)
```

| Propriété | Valeur |
|-----------|--------|
| **CID** | C-007 |
| **Type** | DATA FLOW |
| **Severity** | HIGH |
| **Stability** | DRAFT |

- **Consumes**: Sorties multiples d'une même étape
- **Produces**: Matrice de comparaison + score de consensus
- **Guarantees**: Alignement sémantique, divergences classifiées
- **Forbids**: Comparaison sans métrique, jugement non justifié

### C-008: SUPRA-Comparator → SUPRA-FusionEngine

```
SUPRA-Comparator → SUPRA-FusionEngine
```

| Propriété | Valeur |
|-----------|--------|
| **CID** | C-008 |
| **Type** | DATA FLOW |
| **Severity** | HIGH |
| **Stability** | DRAFT |

- **Consumes**: Matrice de comparaison + sorties multiples
- **Produces**: Résultat fusionné unique
- **Guarantees**: Fusion cohérente, résolution de conflits
- **Forbids**: Perte d'information, décision non tracée

### C-009: SUPRA-FusionEngine → SUPRA-Validator

```
SUPRA-FusionEngine → SUPRA-Validator
```

| Propriété | Valeur |
|-----------|--------|
| **CID** | C-009 |
| **Type** | DATA FLOW |
| **Severity** | HIGH |
| **Stability** | DRAFT |

- **Consumes**: Résultat fusionné + critères d'acceptation
- **Produces**: Rapport de validation (PASS/FAIL, score, checks)
- **Guarantees**: Vérification exhaustive des critères
- **Forbids**: Validation partielle, critères ignorés

### C-010: SUPRA-Validator → SUPRA-Learning

```
SUPRA-Validator → SUPRA-Learning
```

| Propriété | Valeur |
|-----------|--------|
| **CID** | C-010 |
| **Type** | FEEDBACK |
| **Severity** | MEDIUM |
| **Stability** | DRAFT |

- **Consumes**: Résultat de validation (succès/échec + métriques)
- **Produces**: Modèles mis à jour, prompts optimisés
- **Guarantees**: Apprentissage continu, pas de régression
- **Forbids**: Apprentissage sur données non validées

### C-013: SUPRA-KnowledgeCompiler → All Graphs (Publication)

```
SUPRA-KnowledgeCompiler → Knowledge Graph
SUPRA-KnowledgeCompiler → Constraint Graph
SUPRA-KnowledgeCompiler → Evidence Graph
SUPRA-KnowledgeCompiler → Consistency Graph
SUPRA-KnowledgeCompiler → Executive Graph
```

| Propriété | Valeur |
|-----------|--------|
| **CID** | C-013 |
| **Type** | PUBLICATION |
| **Severity** | CRITICAL |
| **Stability** | STABLE |

- **Consumes**: Informations compilées et validées
- **Produces**: Graphes mis à jour (append-only)
- **Guarantees**: La publication n'intervient qu'après validation complète
- **Forbids**: Publication sans validation de cohérence
- **Protocol**: Append-only, versionné, tracé

### C-014: SUPRA-ExecutiveKernel → All Kernels (Direction)

```
SUPRA-ExecutiveKernel → Mission, Governance, Knowledge, Runtime, Product, Provider Kernels
```

| Propriété | Valeur |
|-----------|--------|
| **CID** | C-014 |
| **Type** | DIRECTIVE |
| **Severity** | CRITICAL |
| **Stability** | STABLE |

- **Consumes**: Vision, mission, objectifs du système
- **Produces**: Contexte exécutif pour tous les kernels
- **Guarantees**: Vision cohérente, objectifs alignés
- **Forbids**: Contradiction entre kernels sur les objectifs

### C-015: SUPRA-GovernanceKernel → All Components (Compliance)

```
SUPRA-GovernanceKernel → Tout composant
```

| Propriété | Valeur |
|-----------|--------|
| **CID** | C-015 |
| **Type** | COMPLIANCE |
| **Severity** | CRITICAL |
| **Stability** | STABLE |

- **Consumes**: Demandes de gate, propositions d'ADR, requêtes compliance
- **Produces**: Décision de gate, rapport de compliance, validation ADR
- **Guarantees**: Conformité à la Constitution, gates respectés
- **Forbids**: Transition sans gate, décision sans ADR

### C-016: SUPRA-ProviderKernel → Providers (Abstraction)

```
SUPRA-ProviderKernel → L1.OLLAMA_PROVIDER, L1.OPENAI_PROVIDER, etc.
```

| Propriété | Valeur |
|-----------|--------|
| **CID** | C-016 |
| **Type** | ABSTRACTION |
| **Severity** | CRITICAL |
| **Stability** | STABLE |

- **Consumes**: Requête d'exécution modèle (input + paramètres)
- **Produces**: Réponse modèle (output + métriques)
- **Guarantees**: Interface unifiée, fallback transparent
- **Forbids**: Appel direct aux providers sans passer par le Kernel
- **Error**: Fallback → second provider → mode dégradé

### C-022: SUPRA-MasterGraph → All Components (Navigation)

```
SUPRA-MasterGraph → Tout nouveau composant
```

| Propriété | Valeur |
|-----------|--------|
| **CID** | C-022 |
| **Type** | NAVIGATION |
| **Severity** | CRITICAL |
| **Stability** | STABLE |

- **Consumes**: Requête de navigation dans l'architecture
- **Produces**: Relations, dépendances, autorités du système
- **Guarantees**: Graphe unique, à jour, sans cycle
- **Forbids**: Navigation alternative, graphes concurrents

### C-023: SUPRA-MasterIndex → All Components (Discovery)

```
SUPRA-MasterIndex → Tout nouveau composant
```

| Propriété | Valeur |
|-----------|--------|
| **CID** | C-023 |
| **Type** | DISCOVERY |
| **Severity** | CRITICAL |
| **Stability** | STABLE |

- **Consumes**: Requête de découverte documentaire
- **Produces**: Localisation et statut des documents canoniques
- **Guarantees**: Un seul index, point d'entrée unique
- **Forbids**: Accès direct aux documents historiques (ZERO, FOUNDATION)

### C-024: SUPRA-CoreAPI → All Components (Gateway)

```
SUPRA-CoreAPI → Tout composant externe
```

| Propriété | Valeur |
|-----------|--------|
| **CID** | C-024 |
| **Type** | GATEWAY |
| **Severity** | CRITICAL |
| **Stability** | STABLE |

- **Consumes**: Requêtes API (REST-like)
- **Produces**: Réponses API structurées
- **Guarantees**: Interface stable, versionnée
- **Forbids**: Accès direct aux kernels sans passer par l'API

### C-025: SUPRA-ExecutiveCockpit → SUPRA-Runtime (Read)

```
SUPRA-ExecutiveCockpit → Fichiers JSON du Runtime
```

| Propriété | Valeur |
|-----------|--------|
| **CID** | C-025 |
| **Type** | READ ONLY |
| **Severity** | HIGH |
| **Stability** | STABLE |

- **Consumes**: Fichiers JSON (runtime_trace, delegation_trace, runtime_metrics, agent_execution)
- **Produces**: Visualisation, interface utilisateur
- **Guarantees**: Read-only strict, aucune écriture
- **Forbids**: Modification des fichiers Runtime, duplication de logique métier

### C-027: SUPRA-RuntimeKernel → All Runtime Components

```
SUPRA-RuntimeKernel → L4.EXECUTIVE_RUNTIME, L4.TWIN_UNIVERSE, L4.CONTROL_TOWER, etc.
```

| Propriété | Valeur |
|-----------|--------|
| **CID** | C-027 |
| **Type** | STATE |
| **Severity** | CRITICAL |
| **Stability** | STABLE |

- **Consumes**: Événements runtime, changements d'état
- **Produces**: État consolidé du runtime
- **Guarantees**: État cohérent, observable en temps réel
- **Forbids**: État contradictoire, perte d'événements

### C-031: SUPRA-KnowledgeKernel → New Components

```
SUPRA-KnowledgeKernel → Theory Engine, Sherpa, Cortex, Plugin SDK, Executive OS
```

| Propriété | Valeur |
|-----------|--------|
| **CID** | C-031 |
| **Type** | SOURCE |
| **Severity** | CRITICAL |
| **Stability** | STABLE |

- **Consumes**: ZERO, FOUNDATION, registres, manifests, knowledge maps
- **Produces**: Contexte consolidé pour nouveaux composants
- **Guarantees**: Accès exclusif aux données historiques via ce kernel
- **Forbids**: Lecture directe des documents historiques par les nouveaux composants

### C-037: L2.KnowledgeCompiler → L2.Graphs (Publication)

```
L2.KNOWLEDGE_COMPILER → L2.KNOWLEDGE_GRAPH
L2.KNOWLEDGE_COMPILER → L2.CONSTRAINT_GRAPH
L2.KNOWLEDGE_COMPILER → L2.EVIDENCE_GRAPH
L2.KNOWLEDGE_COMPILER → L2.CONSISTENCY_GRAPH
L2.KNOWLEDGE_COMPILER → L2.EXECUTIVE_GRAPH
```

| Propriété | Valeur |
|-----------|--------|
| **CID** | C-037 |
| **Type** | PUBLICATION |
| **Severity** | CRITICAL |
| **Stability** | STABLE |

- **Consumes**: Informations compilées (concepts, relations, patterns)
- **Produces**: Graphes typés avec traçabilité complète
- **Guarantees**: Publication atomique (tout ou rien), append-only
- **Forbids**: Publication partielle, graphe non tracé

---

## Implicit Interaction Elimination

Les interactions implicites suivantes doivent être éliminées ou explicitées :

| # | Interaction Implicite | Composants Concernés | Plan d'Élimination |
|---|----------------------|---------------------|-------------------|
| I-01 | Accès direct aux fichiers JSON du Runtime | Executive Cockpit | Déjà explicité (C-025) — read-only contract défini |
| I-02 | Appel direct aux providers sans passer par le ProviderKernel | Builder, Runtime | Remplacer par C-016 (ProviderKernel abstraction) |
| I-03 | Lecture directe des documents historiques | Nouveaux composants | Remplacer par C-031 (KnowledgeKernel obligatoire) |
| I-04 | Décisions architecturales non tracées en ADR | Tous | Rendre C-015 obligatoire pour toute décision |
| I-05 | Dépendances non déclarées entre composants Swift | L6 vues, L5 stores | Audit du composition root, explicitation |
| I-06 | Communication inter-composants sans EventBus | Runtime, ControlTower | Migration vers pub/sub via C-030 |

---

## Contract Rules

### R-01: Contract Completeness
Tout composant doit avoir au moins un contrat entrant et un contrat sortant.

### R-02: No Null Contracts
Un contrat ne peut pas avoir "NONE" comme consommation ou production.

### R-03: Contract Versioning
Tout contrat modifié doit être versionné avec justification (ADR).

### R-04: Severity Mapping
- CRITICAL: La violation bloque le fonctionnement du système
- HIGH: La violation dégrade significativement le système
- MEDIUM: La violation a un impact limité
- LOW: La violation est cosmétique

### R-05: Stability Meaning
- STABLE: Contract validé, gelé, modification nécessite ADR
- DRAFT: Contract en cours de définition, sujet à changement
- DEPRECATED: Contract à remplacer, plus de nouveaux consommateurs autorisés

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA ULTIMATE CONSOLIDATED PHASE 2. Contrats d'interface entre tous les composants permanents.*
