# SUPRA CAPABILITY CONTRACTS V1

## Contrats d'Intégration pour Theory Engine, Sherpa, Cortex, Plugin SDK, Executive OS

| Propriété | Valeur |
|-----------|--------|
| **Statut** | CORE — Contrats d'intégration |
| **Version** | SUPRA_CAPABILITY_CONTRACTS_V1 |
| **Date** | 2026-07-29 |
| **Principe** | Définir les interfaces avant tout développement |
| **Règle** | Aucune capacité ne consomme directement les documents historiques |

---

## 1. Principe Fondateur

Chaque contrat définit :
- **Kernel(s) consommé(s)** : quels Kernels la capacité lit
- **API(s) utilisée(s)** : endpoints CORE API utilisés
- **Dépendances** : prérequis techniques et fonctionnels
- **Contraintes** : limites, obligations, règles à respecter
- **Critères de validation** : conditions pour considérer l'intégration réussie

---

## 2. Theory Engine — Contrat d'Intégration

### 2.1 Description

Moteur de théorie et de connaissance. Consomme la connaissance canonique du système pour produire des inférences, des recommandations et des prédictions.

### 2.2 Kernels Consommés

| Kernel | Usage | Type d'Accès |
|--------|-------|-------------|
| Knowledge Kernel | Lecture des registres, manifests, graphes, état du système | Lecture seule |
| Executive Kernel | Vision, mission, objectifs fondamentaux | Lecture seule |
| Governance Kernel | Règles, principes immuables, contraintes | Lecture seule |

### 2.3 API Utilisées

```
GET /core/v1/kernel/knowledge/registry/{id}
GET /core/v1/kernel/knowledge/manifest/{id}
GET /core/v1/kernel/knowledge/graph/{id}
GET /core/v1/kernel/knowledge/state
GET /core/v1/kernel/knowledge/standards
GET /core/v1/kernel/knowledge/history
GET /core/v1/kernel/knowledge/components
GET /core/v1/kernel/knowledge/decisions
GET /core/v1/kernel/executive/vision
GET /core/v1/kernel/executive/mission
GET /core/v1/kernel/executive/objectives
GET /core/v1/kernel/governance/constitution
GET /core/v1/index
GET /core/v1/graph
GET /core/v1/query/search?q={query}
GET /core/v1/query/resolve?ref={reference}
```

### 2.4 Dépendances

| Dépendance | Type | Statut |
|------------|------|--------|
| Knowledge Kernel | Fonctionnelle | ✅ COMPLET |
| Executive Kernel | Fonctionnelle | ✅ COMPLET |
| Governance Kernel | Fonctionnelle | ✅ COMPLET |
| Master Index | Navigation | ✅ COMPLET |
| Master Graph | Navigation | ✅ COMPLET |
| CORE API | Interface | ✅ COMPLET |

### 2.5 Contraintes

| ID | Contrainte | Source |
|----|-----------|--------|
| TC-01 | Theory Engine ne lit que via CORE API | API-01 |
| TC-02 | Theory Engine ne modifie aucun fichier | NN-02 (Single Writer) |
| TC-03 | Theory Engine ne persiste pas d'état (lecture seule) | Architecture L2 |
| TC-04 | Les réponses sont non-cachees par défaut | Cohérence |
| TC-05 | Timeout max par requête : 30s | RK-05 |

### 2.6 Critères de Validation

| Critère | Description |
|---------|-------------|
| Lecture Knowledge Kernel | Theory Engine peut lire tous les registres canoniques |
| Résolution de référence | Theory Engine peut résoudre n'importe quelle référence CORE |
| Recherche | Theory Engine peut chercher dans la connaissance |
| Aucun accès direct | Theory Engine n'accède à aucun document historique |
| Performance | Temps de réponse < 500ms par requête |

---

## 3. Sherpa — Contrat d'Intégration

### 3.1 Description

Sélecteur de contexte et guide. Utilise la connaissance du système et les missions actives pour fournir le contexte approprié à chaque interaction.

### 3.2 Kernels Consommés

| Kernel | Usage | Type d'Accès |
|--------|-------|-------------|
| Knowledge Kernel | Contexte du système, état courant | Lecture seule |
| Mission Kernel | Missions actives, états, historique | Lecture seule |
| Executive Kernel | Objectifs courants, priorités | Lecture seule |

### 3.3 API Utilisées

```
GET /core/v1/kernel/knowledge/state
GET /core/v1/kernel/knowledge/components
GET /core/v1/kernel/mission/active
GET /core/v1/kernel/mission/{id}
GET /core/v1/kernel/mission/history
GET /core/v1/kernel/executive/vision
GET /core/v1/kernel/executive/objectives
GET /core/v1/kernel/executive/principles
GET /core/v1/query/search?q={query}
GET /core/v1/query/browse?path={path}
```

### 3.4 Dépendances

| Dépendance | Type | Statut |
|------------|------|--------|
| Knowledge Kernel | Fonctionnelle | ✅ COMPLET |
| Mission Kernel | Fonctionnelle | ✅ COMPLET |
| Executive Kernel | Fonctionnelle | ✅ COMPLET |
| Theory Engine | Fonctionnelle (contexte théorique) | ❌ NON DÉMARRÉ |
| CORE API | Interface | ✅ COMPLET |

### 3.5 Contraintes

| ID | Contrainte | Source |
|----|-----------|--------|
| SC-01 | Sherpa lit uniquement via CORE API | API-01 |
| SC-02 | Sherpa nécessite Theory Engine fonctionnel | Dépendance L2→L3 |
| SC-03 | Sherpa ne modifie aucun fichier | NN-02 |
| SC-04 | Le contexte sélectionné est traçable | NN-06 |
| SC-05 | Timeout max par sélection : 15s | Performance |

### 3.6 Critères de Validation

| Critère | Description |
|---------|-------------|
| Context Selection | Sherpa sélectionne le contexte approprié pour une mission |
| Mission Awareness | Sherpa connaît l'état des missions actives |
| Theory Integration | Sherpa utilise Theory Engine pour le contexte théorique |
| Aucun accès direct | Sherpa n'accède à aucun document historique |
| Traçabilité | Chaque sélection de contexte est enregistrée |

---

## 4. Cortex — Contrat d'Intégration

### 4.1 Description

Mémoire persistante et apprentissage. Stocke et récupère les preuves, les décisions et les états du système pour assurer la continuité entre les sessions.

### 4.2 Kernels Consommés

| Kernel | Usage | Type d'Accès |
|--------|-------|-------------|
| Knowledge Kernel | Graphes de connaissance, état du système | Lecture seule |
| Mission Kernel | Historique des missions, preuves | Lecture/Écriture |
| Runtime Kernel | État du runtime, services | Lecture seule |

### 4.3 API Utilisées

```
GET  /core/v1/kernel/knowledge/graph/{id}
GET  /core/v1/kernel/knowledge/state
GET  /core/v1/kernel/mission/history
GET  /core/v1/kernel/runtime/status
POST /core/v1/evidence
GET  /core/v1/evidence/{id}
GET  /core/v1/evidence/mission/{missionId}
GET  /core/v1/kernel/knowledge/components
```

### 4.4 Dépendances

| Dépendance | Type | Statut |
|------------|------|--------|
| Knowledge Kernel | Fonctionnelle | ✅ COMPLET |
| Mission Kernel | Fonctionnelle | ✅ COMPLET |
| Runtime Kernel | Fonctionnelle | ✅ COMPLET |
| Evidence API | Interface | ✅ COMPLET (définie dans CORE API) |
| Mécanisme de persistance | Technique | ⚠️ À DÉFINIR |

### 4.5 Contraintes

| ID | Contrainte | Source |
|----|-----------|--------|
| CX-01 | Cortex écrit uniquement via Evidence API | API-01, NN-02 |
| CX-02 | Cortex ne supprime jamais de preuve | NN-08 |
| CX-03 | Les preuves sont immutables après écriture | Traçabilité |
| CX-04 | Cortex nécessite un mécanisme de persistance | À définir en Phase 2 |
| CX-05 | Timeout max par écriture : 10s | Performance |

### 4.6 Critères de Validation

| Critère | Description |
|---------|-------------|
| Evidence Storage | Cortex peut stocker une preuve via Evidence API |
| Evidence Retrieval | Cortex peut récupérer une preuve par ID |
| Mission Evidence | Cortex peut lister les preuves d'une mission |
| Graph Reading | Cortex peut lire les graphes de connaissance |
| Aucun accès direct | Cortex n'accède à aucun document historique |
| Persistence | Les preuves survivent à un redémarrage |

---

## 5. Plugin SDK — Contrat d'Intégration

### 5.1 Description

SDK de développement de plugins. Permet d'étendre SUPRA avec des capacités tierces via des contrats d'interface standardisés.

### 5.2 Kernels Consommés

| Kernel | Usage | Type d'Accès |
|--------|-------|-------------|
| Provider Kernel | Contrats de provider, interfaces | Lecture/Spécification |
| Runtime Kernel | Services runtime, connecteurs | Lecture |
| Governance Kernel | Gates, validation, compliance | Lecture |

### 5.3 API Utilisées

```
GET  /core/v1/kernel/provider/list
GET  /core/v1/kernel/provider/{id}
GET  /core/v1/kernel/provider/capabilities
GET  /core/v1/kernel/provider/contracts
GET  /core/v1/kernel/provider/status
GET  /core/v1/kernel/runtime/services
GET  /core/v1/kernel/runtime/connectors
GET  /core/v1/kernel/governance/gates
GET  /core/v1/kernel/governance/compliance
POST /core/v1/governance/gate/{id}/validate
```

### 5.4 Dépendances

| Dépendance | Type | Statut |
|------------|------|--------|
| Provider Kernel | Fonctionnelle | ✅ COMPLET |
| Runtime Kernel | Fonctionnelle | ✅ COMPLET |
| Governance Kernel | Fonctionnelle | ✅ COMPLET |
| Plugin Loader | Technique | ❌ NON IMPLÉMENTÉ |
| Plugin Registry | Technique | ⚠️ SPÉCIFIÉ |

### 5.5 Contraintes

| ID | Contrainte | Source |
|----|-----------|--------|
| PS-01 | Tout plugin implémente SUPRAProviderProtocol | PR-01 |
| PS-02 | Tout plugin a un manifeste et un contrat | PR-05 |
| PS-03 | Les plugins sont interchangeables | PR-02 |
| PS-04 | Les plugins passent les Gates G1-G3 | GK-02 |
| PS-05 | Les plugins ne modifient pas le CORE | NN-02 |
| PS-06 | Les plugins sont sandboxés par permissions | Sécurité |

### 5.6 Critères de Validation

| Critère | Description |
|---------|-------------|
| Plugin Loader | Le SDK peut charger un plugin depuis un manifeste |
| Contract Compliance | Le plugin respecte son contrat déclaré |
| Provider Integration | Le plugin peut être utilisé comme provider |
| Gate Validation | Le plugin passe les gates de validation |
| Aucun accès direct | Le plugin n'accède à aucun document historique |
| Isolation | Le plugin ne peut pas modifier le CORE |

---

## 6. Executive OS — Contrat d'Intégration

### 6.1 Description

Système d'orchestration central. Coordonne les missions, applique la gouvernance, orchestre le runtime et gère les produits.

### 6.2 Kernels Consommés

| Kernel | Usage | Type d'Accès |
|--------|-------|-------------|
| Executive Kernel | Vision, mission, objectifs | Lecture |
| Mission Kernel | Création, suivi, validation des missions | Lecture/Écriture |
| Governance Kernel | Gates, compliance, ADR | Lecture/Écriture |
| Runtime Kernel | Services, workflows, pipelines | Lecture |
| Product Kernel | Produits, relations, contrats | Lecture |

### 6.3 API Utilisées

```
GET  /core/v1/kernel/executive/vision
GET  /core/v1/kernel/executive/mission
GET  /core/v1/kernel/executive/objectives
GET  /core/v1/kernel/executive/architecture
GET  /core/v1/kernel/mission/active
GET  /core/v1/kernel/mission/{id}
GET  /core/v1/kernel/mission/states
GET  /core/v1/kernel/governance/gates
GET  /core/v1/kernel/governance/gate/{id}
GET  /core/v1/kernel/governance/compliance
GET  /core/v1/kernel/governance/authority
GET  /core/v1/kernel/runtime/status
GET  /core/v1/kernel/runtime/services
GET  /core/v1/kernel/runtime/workflows
GET  /core/v1/kernel/runtime/pipelines
GET  /core/v1/kernel/product/list
GET  /core/v1/kernel/product/{id}
GET  /core/v1/kernel/product/relations
POST /core/v1/mission
PATCH /core/v1/mission/{id}
POST /core/v1/mission/{id}/gate
POST /core/v1/mission/{id}/evidence
POST /core/v1/adr
PATCH /core/v1/adr/{id}
POST /core/v1/adr/{id}/review
POST /core/v1/adr/{id}/accept
POST /core/v1/governance/gate/{id}/validate
POST /core/v1/governance/compliance/check
POST /core/v1/governance/escalate
POST /core/v1/evidence
GET  /core/v1/health
GET  /core/v1/health/kernels
```

### 6.4 Dépendances

| Dépendance | Type | Statut |
|------------|------|--------|
| Executive Kernel | Fonctionnelle | ✅ COMPLET |
| Mission Kernel | Fonctionnelle | ✅ COMPLET |
| Governance Kernel | Fonctionnelle | ✅ COMPLET |
| Runtime Kernel | Fonctionnelle | ✅ COMPLET |
| Product Kernel | Fonctionnelle | ✅ COMPLET |
| CORE API | Interface | ✅ COMPLET |

### 6.5 Contraintes

| ID | Contrainte | Source |
|----|-----------|--------|
| EO-01 | Executive OS orchestre via CORE API uniquement | API-01 |
| EO-02 | Executive OS ne lit pas les documents historiques | CP-10 |
| EO-03 | Toute décision est tracée via ADR ou mission | NN-06 |
| EO-04 | Les gates sont validés dans l'ordre | G-01, GK-02 |
| EO-05 | Executive OS respecte la Single Writer Rule | NN-02 |
| EO-06 | Executive OS peut créer des missions (délégué Executive) | Autorisation |

### 6.6 Critères de Validation

| Critère | Description |
|---------|-------------|
| Mission Creation | Executive OS peut créer une mission via CORE API |
| Gate Management | Executive OS peut valider un gate |
| Governance Application | Executive OS applique les règles de gouvernance |
| Runtime Orchestration | Executive OS orchestre le runtime |
| Aucun accès direct | Executive OS n'accède à aucun document historique |
| Traçabilité | Toute action de l'Executive OS est tracée |
| Health Monitoring | Executive OS peut vérifier la santé du CORE |

---

## 7. Contrats Transverses

### 7.1 Règle d'Or Commune

**Toute capacité listée ci-dessus lit exclusivement via SUPRA CORE API.**

Aucun accès direct aux documents suivants n'est autorisé :
- SUPRA_ZERO_* (12 documents)
- SUPRA_FOUNDATION_* (Foundation Rules, Executive Canon, etc.)
- SUPRA_CONSTITUTION.md
- SUPRA_GOVERNANCE_* (Model, Agents, Workflows, etc.)

### 7.2 Chemins de Lecture Autorisés

```
Composant → CORE API → Kernel → Document CORE
Composant → CORE API → Index/Graphe → Référence CORE
```

### 7.3 Matrice des Dépendances entre Capacités

```
Theory Engine ──▶ Knowledge Kernel, Executive Kernel, Governance Kernel
                      │
                      ▼
Sherpa ──▶ Theory Engine, Knowledge Kernel, Mission Kernel, Executive Kernel
              │
              ▼
Cortex ──▶ Knowledge Kernel, Mission Kernel, Runtime Kernel, Evidence API
              │
              ▼
Plugin SDK ──▶ Provider Kernel, Runtime Kernel, Governance Kernel
                    │
                    ▼
Executive OS ──▶ Executive Kernel, Mission Kernel, Governance Kernel,
                Runtime Kernel, Product Kernel
```

### 7.4 Contrat de Non-Régression

| Règle | Description |
|-------|-------------|
| NR-01 | Aucun contrat ne réduit les interfaces existantes |
| NR-02 | Aucune capacité ne brise le Single Source of Truth |
| NR-03 | Aucune capacité ne crée de dépendance circulaire |
| NR-04 | Toute nouvelle capacité passe par les Gates G1-G5 |
| NR-05 | Toute nouvelle capacité produit des preuves de validation |

---

## 8. Validation des Contrats

### 8.1 Processus de Validation

```
1. VÉRIFICATION DES DÉPENDANCES
   ── Chaque dépendance listée existe et est COMPLETE
   
2. VÉRIFICATION DES API
   ── Chaque endpoint API est défini dans SUPRA_CORE_API.md
   
3. VÉRIFICATION DES CONTRAINTES
   ── Chaque contrainte est compatible avec les règles CORE
   
4. VÉRIFICATION DE L'ABSORPTION
   ── Aucune dépendance directe aux documents historiques
   
5. VALIDATION FINALE
   ── Contrat approuvé par SUPRA-Architect
```

### 8.2 Statut des Contrats

| Capacité | Contrat | Dépendances | Validation |
|----------|---------|-------------|------------|
| Theory Engine | ✅ DÉFINI | ✅ 0 dépendance manquante | ✅ PRÊT |
| Sherpa | ✅ DÉFINI | ⚠️ Theory Engine requis | ⏸️ BLOQUÉ |
| Cortex | ✅ DÉFINI | ⚠️ Persistance à définir | ⏸️ BLOQUÉ |
| Plugin SDK | ✅ DÉFINI | ⚠️ Plugin Loader à implémenter | ⏸️ BLOQUÉ |
| Executive OS | ✅ DÉFINI | ✅ 0 dépendance manquante | ✅ PRÊT |

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA ULTIMATE CORE V1. Contrats d'intégration pour les capacités Phase 2.*
