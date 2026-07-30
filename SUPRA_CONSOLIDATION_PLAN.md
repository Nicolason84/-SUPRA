# SUPRA CONSOLIDATION PLAN V1

## Plan de Consolidation de SUPRA Ultimate Consolidated

| Propriété | Valeur |
|-----------|--------|
| **Statut** | CORE — Plan de consolidation permanent |
| **Version** | SUPRA_CONSOLIDATION_PLAN_V1 |
| **Date** | 2026-07-29 |
| **Principe** | Réutiliser avant de créer. Consolider avant d'étendre. |

---

## 1. Principes de Consolidation

1. **Un composant, une responsabilité** — Pas de chevauchement
2. **Un document, un domaine** — Pas de redondance documentaire
3. **Un registre, une source de vérité** — Pas de registres concurrents
4. **Un contrat, une interaction** — Pas de couplage caché
5. **Une spécification, une implémentation** — Pas de spécifications orphelines

---

## 2. Work Streams de Consolidation

### WS-1: Consolidation Documentaire (Priorité: HAUTE)

**Objectif**: Réduire le nombre de documents redondants ou obsolètes de ~40 à ~10

| Action | Documents | Effort | Responsible |
|--------|-----------|--------|-------------|
| WS1-A1 | Archiver CANONICO_*.md (25+ fichiers) dans _ARCHIVES/ | Faible | Architect |
| WS1-A2 | Archiver les rapports de mission terminés (EXECUTION_*, RUNTIME_*, *.md) dans _ARCHIVES/ | Faible | Architect |
| WS1-A3 | Archiver SUPRA_WORKSPACE_*.md (13 fichiers) consolidés en 1 document | Moyen | Architect |
| WS1-A4 | Supprimer SUPRA_CANON.md (redondant avec EXECUTIVE_CANON) | Très faible | Builder |
| WS1-A5 | Archiver SUPRA_ALPHA_*.md et SUPRA_ALIVE_*.md | Faible | Architect |
| WS1-A6 | Geler SUPRA_FOUNDATION_*.md (ne plus modifier, conserver comme référence) | Très faible | Architect |

**Résultat attendu**: ~30 fichiers archivés, documents canoniques clairement identifiés

### WS-2: Consolidation des Registres (Priorité: HAUTE)

**Objectif**: Un seul registre par domaine

| Action | Registres | Effort | Responsible |
|--------|-----------|--------|-------------|
| WS2-A1 | Fusionner les registres JSON en un SUPRA_MASTER_REGISTRY.json unique | Moyen | Builder |
| WS2-A2 | Éliminer les registres dupliqués (MODULE_REGISTRY.json, PACKAGE_REGISTRY.json, PROJECT_REGISTRY.json, CANONICAL_REGISTRY.json) | Moyen | Builder |
| WS2-A3 | Standardiser le format des registres (même schéma, même validation) | Moyen | Architect |

**Résultat attendu**: 1 registre maître + registres spécifiques par domaine (agents, modèles, ADR)

### WS-3: Consolidation des Contrats (Priorité: HAUTE)

**Objectif**: Toutes les interactions entre composants sont contractualisées

| Action | Contrats | Effort | Responsible |
|--------|----------|--------|-------------|
| WS3-A1 | Définir le contrat L4.EXECUTIVE_RUNTIME ↔ L4.TWIN_UNIVERSE (TD-40) | Faible | Architect |
| WS3-A2 | Définir le contrat L4.EVENT_BUS ↔ L4.CONTROL_TOWER (TD-41) | Faible | Architect |
| WS3-A3 | Définir le contrat L5.COMPOSITION_ROOT (TD-42) | Faible | Architect |
| WS3-A4 | Migrer les appels directs providers vers L5.PROVIDER_KERNEL (TD-61) | Moyen | Builder |
| WS3-A5 | Bloquer l'accès direct aux docs historiques (TD-62) | Faible | Auditor |

**Résultat attendu**: 40 contrats définis, 0 interaction implicite

### WS-4: Implémentation des Composants Manquants (Priorité: MOYENNE)

**Objectif**: Passer de SPECIFIED à IMPLEMENTED pour les composants critiques

| Action | Composant | Effort | Dépend de |
|--------|-----------|--------|-----------|
| WS4-A1 | L4.EVENT_BUS — Implémentation Swift native | Moyen | Rien |
| WS4-A2 | L4.WORKFLOW_ENGINE — Implémentation Swift DAG | Élevé | WS4-A1 |
| WS4-A3 | L4.PLANNER — Décomposition de mission | Moyen | WS4-A2 |
| WS4-A4 | L4.ROUTER — Routage natif Swift | Moyen | WS4-A2 |
| WS4-A5 | L4.COMPARATOR — Comparaison de sorties | Moyen | WS4-A2 |
| WS4-A6 | L4.FUSION_ENGINE — Fusion de résultats | Moyen | WS4-A5 |
| WS4-A7 | L4.VALIDATOR — Validation de résultats | Moyen | WS4-A6 |

**Résultat attendu**: Pipeline runtime complet implémenté en Swift

### WS-5: Résolution des Dépendances (Priorité: MOYENNE)

**Objectif**: Éliminer les 10 dépendances non résolues

| Action | Dépendance | Effort |
|--------|-----------|--------|
| WS5-A1 | Résoudre D-01 à D-10 (Workflow → Router/Comparator/Fusion/Validator) | Élevé |
| WS5-A2 | Résoudre D-06 à D-10 (Pipeline runtime complet) | Élevé |

**Résultat attendu**: 0 dépendance non résolue bloquante

---

## 3. Calendrier de Consolidation

```
Semaine 1-2:  WS-1 (Consolidation documentaire)
              WS-2 (Consolidation des registres)
              WS-3 (Consolidation des contrats)
              
Semaine 3-4:  WS-5 (Résolution des dépendances)
              WS-4-A1 (Event Bus implémentation)
              
Semaine 5-8:  WS-4-A2 à WS-4-A7 (Pipeline runtime)
              
Semaine 9-10: Validation finale
              SUPRA_CONSOLIDATION_REPORT.md
```

---

## 4. Définition of Done (DoD) pour la Consolidation

| Critère | Description | Vérification |
|---------|-------------|--------------|
| DoD-1 | Tous les documents redondants archivés | Nombre de fichiers racine < 200 |
| DoD-2 | Registres consolidés en 1 maître + N spécifiques | Registre unique par domaine |
| DoD-3 | Tous les contrats inter-composants définis | 40 contrats dans SUPRA_COMPONENT_CONTRACTS.md |
| DoD-4 | Pipeline runtime implémenté | L4.WORKFLOW_ENGINE + L4.PLANNER + L4.ROUTER |
| DoD-5 | Zéro dépendance non résolue bloquante | Toutes les dépendances D-* résolues |
| DoD-6 | Toute décision tracée en ADR | ADR index > 30 entrées |

---

## 5. Risques de Consolidation

| Risque | Impact | Probabilité | Mitigation |
|--------|--------|-------------|------------|
| Perte d'information lors de l'archivage | Élevé | Faible | Vérification avant archivage, backup git |
| Rupture de contrat entre composants | Critique | Faible | Tests d'intégration avant chaque consolidation |
| Résistance au changement (documents supprimés) | Moyen | Moyen | Communication, traçabilité git |
| Surcharge de travail (tout consolider en une fois) | Élevé | Moyen | Priorisation, phasage sur 10 semaines |

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA ULTIMATE CONSOLIDATED PHASE 2. Plan de consolidation.*
