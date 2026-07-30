# SUPRA PHASE 2 READINESS MATRIX V1

## Matrice GO / GO WITH CONDITIONS / NO GO — Theory Engine, Sherpa, Cortex, Plugin SDK, Executive OS

| Propriété | Valeur |
|-----------|--------|
| **Statut** | CORE — Matrice de readiness Phase 2 |
| **Version** | SUPRA_PHASE2_READINESS_MATRIX_V1 |
| **Date** | 2026-07-29 |
| **Principe** | Décision basée sur les dépendances réelles et l'état du CORE |
| **Autorité** | SUPRA CORE — cette matrice détermine l'ordre de développement |

---

## 1. Résumé Exécutif

| Capacité | Décision | Justification | Ordre Recommandé |
|----------|----------|--------------|------------------|
| **Theory Engine** | ✅ **GO** | Knowledge Kernel complet, aucune dépendance externe | 1 |
| **Executive OS** | ✅ **GO** | Tous les Kernels consommés sont COMPLETS | 2 |
| **Plugin SDK** | ✅ **GO WITH CONDITIONS** | Provider Kernel complet mais Plugin Loader à implémenter | 3 |
| **Cortex** | ✅ **GO WITH CONDITIONS** | Evidence API définie mais mécanisme de persistance à définir | 4 |
| **Sherpa** | ✅ **GO WITH CONDITIONS** | Nécessite Theory Engine fonctionnel | 5 |

---

## 2. Grille d'Évaluation

Chaque critère est noté :
- ✅ = REMPLI — aucune action requise
- ⚠️ = PARTIEL — condition à remplir avant ou pendant le développement
- ❌ = NON REMPLI — blocant

---

## 3. Theory Engine — ✅ GO

### 3.1 Évaluation Détaillée

| Critère | Note | Commentaire |
|---------|------|-------------|
| Knowledge Kernel lisible | ✅ | Contenu complet, interfaces définies |
| Executive Kernel lisible | ✅ | Vision, mission, objectifs définis |
| Governance Kernel lisible | ✅ | Règles, principes, contraintes définis |
| Master Index disponible | ✅ | Point d'entrée unique |
| Master Graph disponible | ✅ | Navigation des relations |
| CORE API définie | ✅ | Tous les endpoints de lecture disponibles |
| Dépendances techniques | ✅ | Aucune dépendance externe |
| Contrat d'intégration défini | ✅ | SUPRA_CAPABILITY_CONTRACTS.md §2 |
| Pas d'accès direct aux historiques | ✅ | Via CORE API uniquement |

### 3.2 Décision

**GO** — Theory Engine peut commencer immédiatement.

### 3.3 Justification

Theory Engine ne dépend que de Kernels COMPLETS (Knowledge, Executive, Governance) et de la CORE API. Aucune implémentation préalable n'est nécessaire. Le Knowledge Kernel a spécifiquement été conçu pour être lu par Theory Engine (KK-01 : « Théorie lit exclusivement ce Kernel »).

### 3.4 Prérequis Avant Démarrage

| # | Prérequis | Statut |
|---|-----------|--------|
| 1 | Knowledge Kernel validé | ✅ |
| 2 | CORE API disponible | ✅ |
| 3 | Contrat d'intégration approuvé | ✅ |
| 4 | Ressources allouées | ⚠️ À CONFIRMER |

### 3.5 Risques Identifiés

| Risque | Probabilité | Impact | Mitigation |
|--------|------------|--------|------------|
| Périmètre mal défini | Faible | Moyen | Contrat d'intégration détaillé |
| Dépendance à des registres incomplets | Faible | Élevé | Validation préalable des registres |
| Performance des lectures | Moyen | Moyen | Timeouts définis dans le contrat |

---

## 4. Executive OS — ✅ GO

### 4.1 Évaluation Détaillée

| Critère | Note | Commentaire |
|---------|------|-------------|
| Executive Kernel consommable | ✅ | Vision, mission, objectifs définis |
| Mission Kernel consommable | ✅ | Cycle de vie, états, API d'écriture définis |
| Governance Kernel consommable | ✅ | Gates, compliance, ADR définis |
| Runtime Kernel consommable | ✅ | Services, workflows, pipelines définis |
| Product Kernel consommable | ✅ | Relations produits définies |
| CORE API endpoints d'écriture | ✅ | POST /mission, POST /adr, etc. définis |
| CORE API endpoints de lecture | ✅ | Tous les GET définis |
| Contrat d'intégration défini | ✅ | SUPRA_CAPABILITY_CONTRACTS.md §6 |
| Pas d'accès direct aux historiques | ✅ | Via CORE API uniquement |

### 4.2 Décision

**GO** — Executive OS peut commencer immédiatement.

### 4.3 Justification

Executive OS consomme 5 Kernels sur 7, tous COMPLETS. La CORE API définit l'ensemble des endpoints nécessaires (lecture + écriture). Executive OS est l'orchestrateur central — son développement peut démarrer en parallèle des autres capacités.

### 4.4 Prérequis Avant Démarrage

| # | Prérequis | Statut |
|---|-----------|--------|
| 1 | 5 Kernels validés | ✅ |
| 2 | CORE API endpoints d'écriture validés | ✅ |
| 3 | Contrat d'intégration approuvé | ✅ |
| 4 | Ressources allouées | ⚠️ À CONFIRMER |

### 4.5 Risques Identifiés

| Risque | Probabilité | Impact | Mitigation |
|--------|------------|--------|------------|
| Complexité d'orchestration | Élevée | Élevé | Architecture modulaire, phases incrémentales |
| Dépendance au Runtime non implémenté | Moyenne | Élevé | Runtime Kernel suffisant pour l'interface |
| Conflit avec Single Writer Rule | Faible | Moyen | Missions déléguées à Builder |

---

## 5. Plugin SDK — ✅ GO WITH CONDITIONS

### 5.1 Évaluation Détaillée

| Critère | Note | Commentaire |
|---------|------|-------------|
| Provider Kernel consommable | ✅ | Interfaces, contrats, fallback définis |
| Runtime Kernel consommable | ✅ | Services, connecteurs définis |
| Governance Kernel consommable | ✅ | Gates, compliance définis |
| CORE API endpoints de lecture | ✅ | GET /kernel/provider/*, /kernel/runtime/* |
| Spécification SDK existante | ✅ | SUPRA_PLUGIN_SDK_SPEC.md (388 lignes) |
| Plugin Loader | ❌ | NON IMPLÉMENTÉ — à créer |
| Plugin Registry | ⚠️ | SPÉCIFIÉ mais non implémenté |
| Contrat d'intégration défini | ✅ | SUPRA_CAPABILITY_CONTRACTS.md §5 |
| Pas d'accès direct aux historiques | ✅ | Via CORE API uniquement |

### 5.2 Décision

**GO WITH CONDITIONS** — Plugin SDK peut commencer sous réserve que le Plugin Loader et le Plugin Registry soient implémentés en Phase 2a.

### 5.3 Conditions

| # | Condition | Échéance | Responsable |
|---|-----------|----------|-------------|
| 1 | Implémenter le Plugin Loader (chargement depuis manifeste) | Phase 2a | Builder |
| 2 | Implémenter le Plugin Registry (enregistrement, découverte) | Phase 2a | Builder |
| 3 | Valider le Plugin Loader avec au moins un provider de test | Phase 2a | Architect + Builder |

### 5.4 Justification

Le Provider Kernel est complet et définit toutes les interfaces nécessaires. La spécification du SDK est détaillée (SUPRA_PLUGIN_SDK_SPEC.md). Les deux conditions (Loader, Registry) sont des implémentations techniques qui ne remettent pas en cause la conception.

### 5.5 Risques Identifiés

| Risque | Probabilité | Impact | Mitigation |
|--------|------------|--------|------------|
| Plugin Loader complexe | Moyenne | Élevé | Spécification détaillée existante |
| Sécurité des plugins | Moyenne | Critique | Sandboxing, permissions |
| Rétrocompatibilité | Faible | Moyen | Versioning dès la conception |

---

## 6. Cortex — ✅ GO WITH CONDITIONS

### 6.1 Évaluation Détaillée

| Critère | Note | Commentaire |
|---------|------|-------------|
| Knowledge Kernel consommable | ✅ | Graphes, état du système disponibles |
| Mission Kernel consommable | ✅ | Historique, preuves disponibles |
| Runtime Kernel consommable | ✅ | Statut runtime disponible |
| Evidence API définie | ✅ | POST /evidence, GET /evidence défini |
| Mécanisme de persistance | ❌ | NON DÉFINI — à concevoir |
| Contrat d'intégration défini | ✅ | SUPRA_CAPABILITY_CONTRACTS.md §4 |
| Pas d'accès direct aux historiques | ✅ | Via CORE API uniquement |

### 6.2 Décision

**GO WITH CONDITIONS** — Cortex peut commencer sous réserve qu'un mécanisme de persistance soit défini et validé.

### 6.3 Conditions

| # | Condition | Échéance | Responsable |
|---|-----------|----------|-------------|
| 1 | Définir le mécanisme de persistance (file system, base de données, ou CORE) | Phase 2a | Architect |
| 2 | Valider le schéma de stockage des preuves | Phase 2a | Architect + Auditor |
| 3 | Implémenter le service de persistance minimum | Phase 2a | Builder |

### 6.4 Justification

L'Evidence API est complètement définie dans SUPRA_CORE_API.md (§6.4). Ce qui manque est le mécanisme de persistance sous-jacent — un choix technique qui ne remet pas en cause l'interface. Plusieurs options existent : fichier JSON, SQLite, ou intégration CORE.

### 6.5 Risques Identifiés

| Risque | Probabilité | Impact | Mitigation |
|--------|------------|--------|------------|
| Choix de persistance inadapté | Moyenne | Élevé | Prototype rapide avant décision finale |
| Performance en écriture | Moyenne | Moyen | File d'attente asynchrone |
| Volume de données | Faible | Moyen | Rotation et archivage des preuves |

---

## 7. Sherpa — ✅ GO WITH CONDITIONS

### 7.1 Évaluation Détaillée

| Critère | Note | Commentaire |
|---------|------|-------------|
| Knowledge Kernel consommable | ✅ | Contexte disponible |
| Mission Kernel consommable | ✅ | Missions actives accessibles |
| Executive Kernel consommable | ✅ | Objectifs, priorités définis |
| CORE API endpoints de lecture | ✅ | Tous les GET nécessaires définis |
| Theory Engine fonctionnel | ❌ | NON DÉMARRÉ — dépendance critique |
| Contrat d'intégration défini | ✅ | SUPRA_CAPABILITY_CONTRACTS.md §3 |
| Pas d'accès direct aux historiques | ✅ | Via CORE API uniquement |

### 7.2 Décision

**GO WITH CONDITIONS** — Sherpa peut commencer la phase de conception mais dépend de Theory Engine pour l'exécution.

### 7.3 Conditions

| # | Condition | Échéance | Responsable |
|---|-----------|----------|-------------|
| 1 | Theory Engine fonctionnel (au moins MVP) | Phase 2a | Builder |
| 2 | Interface Theory Engine → Sherpa validée | Phase 2a | Architect |
| 3 | Contexte théorique disponible via CORE API | Phase 2a | Architect + Builder |

### 7.4 Justification

Sherpa est en couche L3, directement au-dessus de Theory Engine (L2). Sans Theory Engine, Sherpa n'a pas de contexte théorique à sélectionner. Cependant, la phase de conception (spécification, architecture) peut commencer immédiatement car les interfaces sont toutes définies.

### 7.5 Risques Identifiés

| Risque | Probabilité | Impact | Mitigation |
|--------|------------|--------|------------|
| Theory Engine retardé | Élevée | Élevé | Spécification Sherpa en parallèle |
| Interface Theory mal définie | Moyenne | Élevé | Contrat d'intégration détaillé |
| Périmètre mal compris | Faible | Moyen | Définition claire dans le contrat |

---

## 8. Matrice Synthétique

### 8.1 Vue d'Ensemble

| Critère | Theory Engine | Executive OS | Plugin SDK | Cortex | Sherpa |
|---------|:---:|:---:|:---:|:---:|:---:|
| **Décision** | ✅ GO | ✅ GO | ⚠️ GWC | ⚠️ GWC | ⚠️ GWC |
| **Ordre recommandé** | 1 | 2 | 3 | 4 | 5 |
| **Kernels consommés** | 3 | 5 | 3 | 3 | 3 |
| **Dépendances externes** | 0 | 0 | 2 | 1 | 1 |
| **CORE API endpoints** | 16 | 30+ | 6 | 7 | 7 |
| **Risque global** | Faible | Moyen | Moyen | Moyen | Élevé |
| **Spécification détaillée** | ✅ | ✅ | ✅ | ⚠️ | ⚠️ |

### 8.2 Dépendances entre Capacités

```
Theory Engine (GO)
    │
    ▼
Sherpa (GWC — attend Theory Engine)
    │
    ▼
Cortex (GWC — attend persistance)
    │
    ▼
Plugin SDK (GWC — attend Loader + Registry)
    │
    ▼
Executive OS (GO — peut commencer immédiatement)
```

### 8.3 Blocages et Déblocages

| Capacité | Bloqué Par | Débloqué Par |
|----------|-----------|--------------|
| Theory Engine | Rien | Démarrage immédiat |
| Executive OS | Rien | Démarrage immédiat |
| Plugin SDK | Plugin Loader, Plugin Registry | Implémentation Phase 2a |
| Cortex | Mécanisme de persistance | Décision architecturale Phase 2a |
| Sherpa | Theory Engine | Theory Engine MVP |

---

## 9. Feuille de Route Priorisée (Phase 2)

Basée sur l'analyse des dépendances réelles, l'ordre de développement recommandé est :

### Vague 1 — Immédiat (Phase 2a, Lot 1)

| Ordre | Capacité | Durée Estimée | Dépendances |
|-------|----------|---------------|-------------|
| 1 | **Theory Engine** MVP | 1-2 sessions | Aucune |
| 2 | **Executive OS** noyau | 2-3 sessions | Aucune |
| 3 | **Plugin Loader + Registry** | 1 session | Provider Kernel |

### Vague 2 — Préparatoire (Phase 2a, Lot 2)

| Ordre | Capacité | Durée Estimée | Dépendances |
|-------|----------|---------------|-------------|
| 4 | **Mécanisme de persistance** Cortex | 1 session | Décision architecturale |
| 5 | **Plugin SDK** implémentation | 1-2 sessions | Plugin Loader |
| 6 | **Cortex** MVP | 1 session | Persistance |

### Vague 3 — Finalisation (Phase 2b)

| Ordre | Capacité | Durée Estimée | Dépendances |
|-------|----------|---------------|-------------|
| 7 | **Sherpa** MVP | 1-2 sessions | Theory Engine |
| 8 | **Executive OS** complet | 1 session | Toutes capacités |
| 9 | **Theory Engine** complet | 1 session | Feedback Cortex |

### 9.1 Dépendances Temporelles

```
Semaine 1-2 : Theory Engine MVP + Executive OS noyau
                  │
                  ▼
Semaine 2-3 : Plugin Loader + Persistance + Plugin SDK
                  │
                  ▼
Semaine 3-4 : Cortex MVP + Executive OS extension
                  │
                  ▼
Semaine 4-5 : Sherpa MVP + Intégration finale
```

---

## 10. Critères de Validation Globaux

### 10.1 Validation du Démarrage

| Critère | Description | Applicable À |
|---------|-------------|--------------|
| Contrat d'intégration approuvé | Le contrat est signé par Architect | Toutes |
| Kernels consommes COMPLETS | Tous les kernels nécessaires sont verts | Toutes |
| CORE API endpoints définis | Les endpoints nécessaires existent | Toutes |
| Pas de blocage technique | Aucune dépendance non résolue | GO uniquement |

### 10.2 Validation de Complétion

| Critère | Description |
|---------|-------------|
| Tous les critères de validation du contrat sont remplis |
| Aucun accès direct aux documents historiques |
| Les tests d'intégration CORE API passent |
| La documentation est mise à jour dans le Master Index |

---

## 11. Risques et Atténuations

### 11.1 Risques Identifiés

| Risque | Capacité(s) Concernée(s) | Probabilité | Impact | Atténuation |
|--------|-------------------------|-------------|--------|-------------|
| Theory Engine trop théorique | Theory Engine, Sherpa | Faible | Élevé | MVP minimal, focus sur cas d'usage concret |
| Executive OS trop complexe | Executive OS | Moyen | Élevé | Architecture modulaire, phases incrémentales |
| Plugin Loader sécurité | Plugin SDK | Moyen | Critique | Sandboxing, permissions minimales |
| Persistance non adaptée | Cortex | Moyen | Moyen | Prototype rapide, plusieurs options |
| Dépendances circulaires | Toutes | Faible | Critique | Détection automatique, graphe de dépendances |

### 11.2 Plan d'Atténuation Global

| Action | Responsable | Échéance |
|--------|-------------|----------|
| Valider les décisions architecturales avant chaque démarrage | Architect | Phase 2a |
| Implémenter les prérequis techniques (Loader, Registry, Persistance) en premier | Builder | Phase 2a |
| Produire des preuves de validation à chaque étape | Builder + Auditor | Continu |
| Revoir la matrice de readiness après chaque livraison | Executive + Architect | Fin de chaque lot |

---

## 12. Conclusion

| Capacité | Décision | Prochaine Action |
|----------|----------|------------------|
| **Theory Engine** | ✅ **GO** | Démarrer le MVP immédiatement |
| **Executive OS** | ✅ **GO** | Démarrer le noyau d'orchestration |
| **Plugin SDK** | ⚠️ **GO WITH CONDITIONS** | Implémenter Plugin Loader et Registry |
| **Cortex** | ⚠️ **GO WITH CONDITIONS** | Définir le mécanisme de persistance |
| **Sherpa** | ⚠️ **GO WITH CONDITIONS** | Spécification en parallèle de Theory Engine |

**Aucun NO GO.** Les 5 capacités sont prêtes ou conditionnellement prêtes pour la Phase 2. Les conditions identifiées sont des implémentations techniques, pas des problèmes de conception.

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA ULTIMATE CORE V1. Matrice de readiness pour le démarrage de la Phase 2.*
