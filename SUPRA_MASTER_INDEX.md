# SUPRA MASTER INDEX V1

## Index Canonique Unique de SUPRA CORE

| Propriété | Valeur |
|-----------|--------|
| **Statut** | CORE — Point d'entrée documentaire unique |
| **Version** | SUPRA_MASTER_INDEX_V1 |
| **Date** | 2026-07-29 |
| **Principe** | Un seul index pour tout le système |
| **Autorité** | SUPRA CORE — tout composant futur lit cet index |

---

## 1. SUPRA CORE — Kernels

Les 7 Kernels constituent le socle opérationnel unique. Tout composant futur (Theory Engine, Sherpa, Cortex, Plugin SDK, Executive OS) lit exclusivement ces Kernels.

| Kernel | Fichier | Responsabilité |
|--------|---------|----------------|
| Executive Kernel | SUPRA_EXECUTIVE_KERNEL.md | Vision, mission, objectifs, interfaces publiques |
| Mission Kernel | SUPRA_MISSION_KERNEL.md | Cycle de vie des missions, états, handover |
| Governance Kernel | SUPRA_GOVERNANCE_KERNEL.md | Constitution, gouvernance, gates, compliance, ADR, autorité |
| Knowledge Kernel | SUPRA_KNOWLEDGE_KERNEL.md | ZERO, FOUNDATION, registres, manifests, knowledge maps |
| Runtime Kernel | SUPRA_RUNTIME_KERNEL.md | Runtime, providers, services, orchestration |
| Product Kernel | SUPRA_PRODUCT_KERNEL.md | Relations CORE / Runtime / Produits / Applications |
| Provider Kernel | SUPRA_PROVIDER_KERNEL.md | Abstraction providers, interfaces, contrats, résilience |

---

## 2. Documents Canoniques Ancestraux (Absorbés dans CORE)

Ces documents ne sont plus lus directement par les nouveaux composants. Ils sont intégrés dans les Kernels ci-dessus. Ils restent accessibles comme mémoire historique.

### 2.1 SUPRA ZERO (Mémoire historique)

| Document | Rôle |
|----------|------|
| SUPRA_ZERO_EXECUTIVE_REPORT.md | Rapport exécutif de l'état zéro |
| SUPRA_ZERO_MASTER_MAP.md | Cartographie complète de l'écosystème |
| SUPRA_ZERO_DESKTOP_CARTOGRAPHY.md | Classification logique du Desktop |
| SUPRA_ZERO_ACTIVE_PROJECTS.md | Inventaire des projets actifs vs frozen |
| SUPRA_ZERO_CAMP_BASE_MASTER.md | Générations CAMP_BASE et master |
| SUPRA_ZERO_CONTINUITY_MASTER.md | Chaîne de continuité consolidée |
| SUPRA_ZERO_DUPLICATE_ANALYSIS.md | Détection des doublons et plan d'action |
| SUPRA_ZERO_INDUSTRIAL_BASE.md | Structure de la base industrielle |
| SUPRA_ZERO_PLUGIN_ARCHITECTURE.md | Architecture des plugins et points d'extension |
| SUPRA_ZERO_AGENT_ARCHITECTURE.md | Analyse des agents et architecture cible |
| SUPRA_ZERO_ULTIMATE_ARCHITECTURE.md | Architecture cible SUPRA ULTIMATE |
| SUPRA_ZERO_PHASE2_READINESS.md | Diagnostic de readiness Phase 2 |

### 2.2 SUPRA FOUNDATION (Référence d'origine)

| Document | Rôle |
|----------|------|
| SUPRA_EXECUTIVE_CANON.md | Constitution opérationnelle, architecture 7 couches |
| SUPRA_FOUNDATION_RULES.md | Standards, politiques, contrats, schémas, templates, SDK |
| SUPRA_AGENT_CANON.md | Architecture des agents SUPRA |
| SUPRA_FOUNDATION_ROADMAP.md | Roadmap officielle |
| SUPRA_FOUNDATION_EXECUTIVE_REPORT.md | Rapport exécutif Foundation |
| SUPRA_FOUNDATION_VALIDATION_REPORT.md | Rapport de validation canonique |
| SUPRA_COMPOSITION_ROOT_V2_1_REPORT.md | Rapport de composition |

### 2.3 SUPRA CONSTITUTION (Source des invariants)

| Document | Rôle |
|----------|------|
| SUPRA_CONSTITUTION.md | Constitution du système |
| SUPRA_IMMUTABLE_PRINCIPLES.md | Principes non négociables |
| SUPRA_AUTHORITY_MODEL.md | Modèle d'autorité |
| SUPRA_DOCUMENT_HIERARCHY.md | Hiérarchie documentaire |
| SUPRA_EVOLUTION_LAW.md | Loi d'évolution |
| SUPRA_GATE_SYSTEM.md | Système de gates |
| SUPRA_ADR_STANDARD.md | Standard des ADR |
| SUPRA_PROTECTION_MODEL.md | Modèle de protection |

### 2.4 SUPRA GOVERNANCE (Source des processus)

| Document | Rôle |
|----------|------|
| SUPRA_GOVERNANCE_MODEL.md | Modèle opérationnel de gouvernance |
| SUPRA_GOVERNANCE_AGENTS.md | Spécification des agents de gouvernance |
| SUPRA_GOVERNANCE_WORKFLOWS.md | Workflows opérationnels de gouvernance |
| SUPRA_GATE_EXECUTION.md | Processus exécutable des gates |
| SUPRA_COMPLIANCE_MODEL.md | Moteur de conformité |
| SUPRA_ADR_GOVERNANCE.md | Gouvernance du cycle de vie des ADR |
| SUPRA_GOVERNANCE_REGISTRY.md | Registre de gouvernance |
| SUPRA_GOVERNANCE_DASHBOARD.md | Tableau de bord de gouvernance |

---

## 3. Registres Canoniques

| Registre | Fichier | Statut |
|----------|---------|--------|
| Master Registry | SUPRA_MASTER_REGISTRY.json | CANONIQUE |
| Master Manifest | SUPRA_MASTER_MANIFEST.json | CANONIQUE |
| Agent Registry | SUPRA_AGENT_REGISTRY_V1.md | CANONIQUE |
| Model Registry | SUPRA_MODEL_REGISTRY_V1.md | CANONIQUE |
| ADR Registry | ADR_REGISTRY.json | ACTIF |
| Governance Registry | GOVERNANCE_REGISTRY.json | ACTIF |
| Plugin Registry | SUPRA_PLUGIN_SDK_SPEC.md | SPÉCIFIÉ |
| Provider Registry | .opencode/runtime/provider_registry.json | PARTIEL |
| Workspace Manifest | WORKSPACE_MANIFEST.json | ACTIF |
| Architecture Index | SUPRA_ARCHITECTURE_INDEX.json | CANONIQUE |

---

## 4. Manifests

| Manifest | Fichier | Statut |
|----------|---------|--------|
| Master Manifest | SUPRA_MASTER_MANIFEST.json | CANONIQUE |
| Workspace Manifest | WORKSPACE_MANIFEST.json | ACTIF |
| Release Manifest | RELEASE_MANIFEST.json | ACTIF |
| Module Registry | MODULE_REGISTRY.json | ACTIF |
| Package Registry | PACKAGE_REGISTRY.json | ACTIF |
| Project Registry | PROJECT_REGISTRY.json | ACTIF |
| Canonical Registry | CANONICAL_REGISTRY.json | ACTIF |

---

## 5. Policies

| Politique | Source | Statut |
|-----------|--------|--------|
| Workflow | SUPRA_WORKFLOW_V1.md | CANONIQUE |
| Router | SUPRA_ROUTER_SPECIFICATION_V1.md | CANONIQUE |
| Validation | VALIDATION_PROTOCOL.md | CANONIQUE |
| Desktop | DESKTOP_GOVERNANCE.md | CANONIQUE |
| Protection | SUPRA_PROTECTION_MODEL.md | CONSTITUTION |
| Compliance | SUPRA_COMPLIANCE_MODEL.md | GOVERNANCE |
| Gate Execution | SUPRA_GATE_EXECUTION.md | GOVERNANCE |
| ADR Governance | SUPRA_ADR_GOVERNANCE.md | GOVERNANCE |
| Governance Model | SUPRA_GOVERNANCE_MODEL.md | GOVERNANCE |
| Governance Agents | SUPRA_GOVERNANCE_AGENTS.md | GOVERNANCE |
| Governance Workflows | SUPRA_GOVERNANCE_WORKFLOWS.md | GOVERNANCE |
| Governance Dashboard | SUPRA_GOVERNANCE_DASHBOARD.md | GOVERNANCE |
| Governance Readiness | SUPRA_GOVERNANCE_READINESS.md | EXPÉRIMENTAL |
| Routing Policy | .opencode/runtime/routing_policy.json | ACTIVE |
| Routing Rules | .opencode/runtime/routing_rules.json | ACTIVE |

---

## 6. Standards

| Standard | Source | Statut |
|----------|--------|--------|
| Foundation Rules | SUPRA_FOUNDATION_RULES.md | CANONIQUE |
| Executive Canon | SUPRA_EXECUTIVE_CANON.md | CANONIQUE |
| Document Hierarchy | SUPRA_DOCUMENT_HIERARCHY.md | CONSTITUTION |
| ADR Standard | SUPRA_ADR_STANDARD.md | CONSTITUTION |
| Evolution Law | SUPRA_EVOLUTION_LAW.md | CONSTITUTION |
| Gate System | SUPRA_GATE_SYSTEM.md | CONSTITUTION |
| Immutable Principles | SUPRA_IMMUTABLE_PRINCIPLES.md | CONSTITUTION |
| Authority Model | SUPRA_AUTHORITY_MODEL.md | CONSTITUTION |
| Continuity Standard | CAnnoNico_CONTINUITY_STANDARD.md | CANONIQUE |
| Development Guide | CAnnoNico_DEVELOPMENT_GUIDE.md | CANONIQUE |
| Workflow Standard | CAnnoNico_WORKFLOW_STANDARD.md | CANONIQUE |
| Executive Object Model | EXECUTIVE_OBJECT_MODEL.md | CANONIQUE |
| Executive Runtime | EXECUTIVE_RUNTIME.md | CANONIQUE |
| Router Specification | SUPRA_ROUTER_SPECIFICATION_V1.md | CANONIQUE |
| Agent Canon | SUPRA_AGENT_CANON.md | CANONIQUE |
| Agent Registry | SUPRA_AGENT_REGISTRY_V1.md | CANONIQUE |
| Model Registry | SUPRA_MODEL_REGISTRY_V1.md | CANONIQUE |
| Workflow | SUPRA_WORKFLOW_V1.md | CANONIQUE |
| UDCL Spec | UDCL_SPECIFICATION.md | CANONIQUE |

---

## 7. Architecture

| Document | Source | Statut |
|----------|--------|--------|
| Architecture Index | SUPRA_ARCHITECTURE_INDEX.json | CANONIQUE |
| AI Lab Architecture | SUPRA_AI_LAB_ARCHITECTURE_V1.md | CANONIQUE |
| Lab Architecture | SUPRA_LAB_ARCHITECTURE_V1.md | CANONIQUE |
| Provider Architecture | SUPRA_PROVIDER_ARCHITECTURE.md | ACTIF |
| Orchestration Architecture | SUPRA_ORCHESTRATION_ARCHITECTURE.md | ACTIF |
| Executive Mission Control | SUPRA_EXECUTIVE_MISSION_CONTROL_V1_ARCHITECTURE.md | ACTIF |

---

## 8. Produits

| Document | Source | Statut |
|----------|--------|--------|
| Roadmap Foundation | SUPRA_FOUNDATION_ROADMAP.md | CANONIQUE |
| Product Target | SUPRA_PRODUCT_TARGET.md | ACTIF |
| Alpha Definition | SUPRA_ALPHA_DEFINITION.md | ACTIF |
| Alpha Roadmap | SUPRA_ALPHA_ROADMAP.md | ACTIF |
| Alpha Certification | SUPRA_ALPHA_CERTIFICATION.md | ACTIF |
| Product Freeze Report | SUPRA_PRODUCT_FREEZE_V1_REPORT.md | CANONIQUE |
| Alive Roadmap | SUPRA_ALIVE_ROADMAP.md | ACTIF |
| Alive Implementation | SUPRA_ALIVE_IMPLEMENTATION.md | ACTIF |
| Alive Runtime | SUPRA_ALIVE_RUNTIME.md | ACTIF |

---

## 9. Runtime

| Document | Source | Statut |
|----------|--------|--------|
| Runtime Status | RUNTIME_STATUS.json | ACTIF |
| System State | SUPRA_STATE.json | CANONIQUE |
| Runtime Graph | SUPRA_RUNTIME_GRAPH.md | ACTIF |
| Runtime Proof | SUPRA_RUNTIME_PROOF_V002.md | ACTIF |
| Runtime Gaps | SUPRA_RUNTIME_GAPS.md | ACTIF |
| Runtime Integration Report | RUNTIME_INTEGRATION_REPORT.md | ACTIF |
| Runtime Consolidation Report | RUNTIME_CONSOLIDATION_REPORT.md | ACTIF |

---

## 10. Plugins

| Document | Source | Statut |
|----------|--------|--------|
| Plugin SDK Spec | SUPRA_PLUGIN_SDK_SPEC.md | SPÉCIFIÉ |
| Plugin Specification | SUPRA_PLUGIN_SPECIFICATION.md | SPÉCIFIÉ |
| Zero Plugin Architecture | SUPRA_ZERO_PLUGIN_ARCHITECTURE.md | HISTORIQUE |

---

## 11. Workspace

| Document | Source | Statut |
|----------|--------|--------|
| Workspace Manifest | WORKSPACE_MANIFEST.json | ACTIF |
| Workspace Structure | WORKSPACE_STRUCTURE.md | ACTIF |
| Workspace Index | workspace_index.json | ACTIF |
| Workspace Memory | workspace_memory.json | ACTIF |

---

## 12. Rapports et Évidence

| Document | Source | Statut |
|----------|--------|--------|
| Executive Summary | EXECUTIVE_SUMMARY.md | ACTIF |
| Executive Report | SUPRA_EXECUTION_REPORT.md | ACTIF |
| Executive Composition Root | EXECUTIVE_COMPOSITION_ROOT.md | ACTIF |
| Executive Certification | EXECUTIVE_CERTIFICATION_REPORT.md | ACTIF |
| Executive Cockpit | SUPRA_EXECUTIVE_COCKPIT_REPORT.md | ACTIF |
| Global Audit | SUPRA_GLOBAL_AUDIT.md | ACTIF |
| Master Execution Report | EXECUTION_MASTER_REPORT.md | ACTIF |
| Handoff | SUPRA_HANDOFF_FOR_OPENCODE.md | ACTIF |
| Continuity Pack | SUPRA_CONTINUITY_PACK.md | ACTIF |
| Baseline Certification | BASELINE_CERTIFICATION_REPORT.md | ACTIF |
| Camp Base Certification | CAMP_BASE01_CERTIFICATION_REPORT.md | ACTIF |
| Critical Path | CRITICAL_PATH.md | ACTIF |
| Final Report | FINAL_REPORT.md | ACTIF |

---

## 13. Configuration

| Fichier | Rôle | Statut |
|---------|------|--------|
| opencode.json | Configuration OpenCode | PROTÉGÉ |
| AGENTS.md | Définitions des agents | GOUVERNÉ |
| .opencode/ | Répertoire de configuration OpenCode | ACTIF |

---

## 14. Graphes et Données Structurées

| Fichier | Rôle | Statut |
|---------|------|--------|
| SUPRA_MASTER_GRAPH.md | Graphe officiel CORE | CORE |
| knowledge_graph.json | Graphe de connaissance | ACTIF |
| knowledge_relations.json | Relations de connaissance | ACTIF |
| knowledge_authority.json | Autorités de connaissance | ACTIF |
| dependency_graph.json | Graphe de dépendances | ACTIF |
| execution_graph.json | Graphe d'exécution | ACTIF |
| global_graph.json | Graphe global | ACTIF |
| mission_graph.json | Graphe des missions | ACTIF |
| universe_graph.json | Graphe univers | ACTIF |
| workspace_graph.json | Graphe du workspace | ACTIF |

---

## 15. Règle d'Or

**Tout nouveau composant (Theory Engine, Sherpa, Cortex, Plugin SDK, Executive OS, produits, runtime) lit exclusivement ce SUPRA_MASTER_INDEX.md pour naviguer dans le système.**

Aucun accès direct aux documents historiques (ZERO, FOUNDATION, CONSTITUTION, GOVERNANCE) n'est autorisé pour les nouveaux composants.

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA ULTIMATE CORE V1. Index canonique unique du système SUPRA.*
