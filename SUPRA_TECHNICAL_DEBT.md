# SUPRA TECHNICAL DEBT V1

## Analyse de la Dette Technique de SUPRA Ultimate Consolidated

| Propriété | Valeur |
|-----------|--------|
| **Statut** | CORE — Analyse permanente de la dette technique |
| **Version** | SUPRA_TECHNICAL_DEBT_V1 |
| **Date** | 2026-07-29 |
| **Principe** | Identifier, mesurer, prioriser, éliminer |

---

## 1. Résumé Exécutif

| Métrique | Valeur |
|----------|--------|
| Documents analysés | ~462 fichiers |
| Composants identifiés | 89 |
| Documents redondants | ~40 estimés |
| Dépendances non résolues | 10 |
| Contrats manquants | 3 |
| Chevauchements | 7 domaines |
| Spécifications non implémentées | 7 composants |
| Priorité | CONSOLIDATION avant EXPANSION |

---

## 2. Catégories de Dette

| Catégorie | Impact | Effort | Priorité |
|-----------|--------|--------|----------|
| Documents redondants | Moyen | Faible | HAUTE |
| Chevauchements de responsabilités | Élevé | Moyen | HAUTE |
| Composants non implémentés | Critique | Élevé | HAUTE |
| Contrats absents | Élevé | Moyen | MOYENNE |
| Interfaces incomplètes | Moyen | Moyen | MOYENNE |
| Dépendances non résolues | Critique | Élevé | HAUTE |
| Couplage caché | Élevé | Moyen | HAUTE |

---

## 3. Documents Redondants

| # | Document | Raison | Action |
|---|----------|--------|--------|
| TD-01 | SUPRA_CANON.md | Redondant avec SUPRA_EXECUTIVE_CANON.md | SUPPRIMER |
| TD-02 | EXECUTIVE_OBJECT_MODEL.md | Absorbé dans les Kernels | ARCHIVER |
| TD-03 | EXECUTIVE_RUNTIME.md | Absorbé dans SUPRA_RUNTIME_BLUEPRINT.md | ARCHIVER |
| TD-04 | SUPRA_ORCHESTRATION_ARCHITECTURE.md | Fonctionnalité dispersée dans L4 | CONSOLIDER |
| TD-05 | SUPRA_EXECUTIVE_MISSION_CONTROL_V1_ARCHITECTURE.md | Obsolète, remplacé par MissionKernel | ARCHIVER |
| TD-06 | SUPRA_WORKSPACE_*.md (13 fichiers) | Redondances après consolidation workspace | CONSOLIDER en 1 |
| TD-07 | SUPRA_ZERO_*.md (12 fichiers) | Historique — ne plus référencer directement | GELER (déjà fait) |
| TD-08 | CANONICO_*.md (25+ fichiers) | Absorbé dans Knowledge Compiler | ARCHIVER |
| TD-09 | CAnnoNico_*.md | Conventions absorbées dans L0.Standard | ARCHIVER |
| TD-10 | SUPRA_ALPHA_*.md (4 fichiers) | Mission terminée, valeur historique | ARCHIVER |
| TD-11 | SUPRA_ALIVE_*.md (3 fichiers) | Mission terminée, valeur historique | ARCHIVER |
| TD-12 | SUPRA_FOUNDATION_*.md (7 fichiers) | Déjà absorbé dans les Kernels | GELER |
| TD-13 | SUPRA_CONSTITUTION_*.md (8 fichiers) | Documents constitutifs — à conserver | CONSERVER |
| TD-14 | SUPRA_GOVERNANCE_*.md (8 fichiers) | Documents de gouvernance — à conserver | CONSERVER |
| TD-15 | FR EEZE_*.md / FR EEZE_* (6 dossiers) | Backups — valeur historique | GELER |
| TD-16 | EXECUTION_*.md, RUNTIME_*.md (multiples) | Rapport d'étape — valeur historique | ARCHIVER |

---

## 4. Chevauchements de Responsabilités

| # | Composant A | Composant B | Chevauchement | Action |
|---|-------------|-------------|---------------|--------|
| TD-20 | L5.EXECUTIVE_KERNEL | L5.EXECUTIVE_OS | Vision, mission dupliquées | CLARIFIER: Kernel = définition, OS = orchestration |
| TD-21 | L5.GOVERNANCE_KERNEL | L5.DECISION_AUTHORITY | Décisions vs Gouvernance | CLARIFIER: Kernel = règles, Authority = exécution |
| TD-22 | L4.MISSION_KERNEL | L5.MISSION_BROKER | Cycle de vie des missions | CLARIFIER: Kernel = état, Broker = orchestration |
| TD-23 | L2.MISSION_ENGINE_KC | L4.MISSION_KERNEL | Mapping mission vs exécution | CLARIFIER: KC = connaissance, Kernel = cycle de vie |
| TD-24 | L2.MEMORY_ENGINE_KC | L3.CORTEX | Persistance mémoire | CLARIFIER: KC = compilation, Cortex = runtime |
| TD-25 | L4.CONTROL_TOWER | L6.EXECUTIVE_DASHBOARD | Monitoring vs affichage | CLARIFIER: Tower = backend, Dashboard = frontend |
| TD-26 | L4.TWIN_UNIVERSE | L4.RUNTIME_KERNEL | État des composants | CLARIFIER: Twins = abstractions, Kernel = runtime réel |

---

## 5. Composants Non Implémentés (SPECIFIED → Nécessite implémentation)

| ID | Composant | Priorité | Dépendances |
|----|-----------|----------|-------------|
| TD-30 | L4.WORKFLOW_ENGINE | CRITIQUE | Bloque tout le pipeline |
| TD-31 | L4.PLANNER | HAUTE | Dépend de WORKFLOW_ENGINE |
| TD-32 | L4.COMPARATOR | HAUTE | Mode consensus |
| TD-33 | L4.FUSION_ENGINE | HAUTE | Dépend de COMPARATOR |
| TD-34 | L4.VALIDATOR | HAUTE | Dépend de FUSION_ENGINE |
| TD-35 | L4.EVENT_BUS | HAUTE | Découplage nécessaire |
| TD-36 | L1.PLUGIN_SDK | MOYENNE | Dépend de PROVIDER_KERNEL |
| TD-37 | L3.LEARNING_ENGINE | MOYENNE | Boucle de rétroaction |

---

## 6. Contrats Absents

| # | Source | Target | Risque |
|---|--------|--------|--------|
| TD-40 | L4.EXECUTIVE_RUNTIME | L4.TWIN_UNIVERSE | Synchronisation non contractuelle |
| TD-41 | L4.EVENT_BUS | L4.CONTROL_TOWER | Monitoring sans contrat formel |
| TD-42 | L5.COMPOSITION_ROOT | Tous composants | Injection sans contrat explicite |

---

## 7. Dépendances Non Résolues (Critiques)

| # | Dépendance | De | Vers | Statut | Bloque | Priorité |
|---|-----------|----|------|--------|--------|----------|
| TD-50 | Workflow → Router | L4.WORKFLOW_ENGINE | L4.ROUTER | SPECIFIED | Pipeline | CRITIQUE |
| TD-51 | Workflow → Comparator | L4.WORKFLOW_ENGINE | L4.COMPARATOR | SPECIFIED | Consensus | HAUTE |
| TD-52 | Workflow → Fusion | L4.WORKFLOW_ENGINE | L4.FUSION_ENGINE | SPECIFIED | Consensus | HAUTE |
| TD-53 | Workflow → Validator | L4.WORKFLOW_ENGINE | L4.VALIDATOR | SPECIFIED | Pipeline | HAUTE |
| TD-54 | Sherpa → Theory | L3.SHERPA | L2.KNOWLEDGE_COMPILER | NOT_STARTED | L3 | MOYENNE |
| TD-55 | Cortex → Knowledge | L3.CORTEX | L5.KNOWLEDGE_KERNEL | PARTIAL | L3 | MOYENNE |
| TD-56 | Plugin → Provider | L1.PLUGIN_SDK | L5.PROVIDER_KERNEL | SPECIFIED | Plugins | MOYENNE |
| TD-57 | EventBus → Tous | L4.EVENT_BUS | All | PARTIAL | Découplage | HAUTE |

---

## 8. Couplage Caché

| # | Description | Composants | Risque | Plan |
|---|-------------|------------|--------|------|
| TD-60 | Cockpit lit directement les fichiers JSON du Runtime | L6, L4 | La modification du format JSON casse le Cockpit | Remplacer par C-025 (contrat read-only + validation de format) |
| TD-61 | Builder appelle directement les providers | AGENT.BUILDER, L1 | Contourne L5.PROVIDER_KERNEL | Remplacer par C-016 (ProviderKernel obligatoire) |
| TD-62 | Nouveaux composants lisent les docs historiques | Tous nouveaux | Contourne C-031 (KnowledgeKernel) | Auditer et bloquer |
| TD-63 | Décisions non tracées en ADR | Tous | Perte de traçabilité | Rendre C-015 obligatoire |
| TD-64 | Registres JSON non synchronisés | L0.REGISTRY | Incohérence entre registres | Consolider |

---

## 9. Métriques de Dette

| Métrique | Valeur |
|----------|--------|
| Dette totale estimée (composants critiques) | 7 composants |
| Dette totale estimée (documents redondants) | ~40 fichiers |
| Dette totale estimée (contrats manquants) | 3 |
| Dette totale estimée (dépendances non résolues) | 10 |
| Score de santé (1-10) | 6/10 |
| Priorité #1 | L4.WORKFLOW_ENGINE |
| Priorité #2 | Consolidation documents |
| Priorité #3 | Contrats explicites |

---

## 10. Plan d'Élimination Prioritaire

| Ordre | Action | Catégorie | Effort | Gain |
|-------|--------|-----------|--------|------|
| 1 | Consolider SUPRA_WORKSPACE_* en 1 document | Redondance | Faible | Moyen |
| 2 | Archiver CANONICO_* (25+ fichiers) | Redondance | Faible | Élevé |
| 3 | Archiver les rapports de mission terminés | Redondance | Faible | Moyen |
| 4 | Supprimer SUPRA_CANON.md | Redondance | Très faible | Faible |
| 5 | Clarifier TD-20 à TD-26 (chevauchements) | Design | Moyen | Élevé |
| 6 | Ajouter contrats TD-40 à TD-42 | Contrats | Faible | Moyen |
| 7 | Implémenter L4.EVENT_BUS | Composant | Moyen | Élevé |
| 8 | Implémenter L4.WORKFLOW_ENGINE | Composant | Élevé | Critique |

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA ULTIMATE CONSOLIDATED PHASE 2. Analyse de la dette technique.*
