# SUPRA CORE API V1

## Interfaces Publiques — Tous les Composants Futurs Communiquent Exclusivement via ces Interfaces

| Propriété | Valeur |
|-----------|--------|
| **Statut** | CORE — API publique |
| **Version** | SUPRA_CORE_API_V1 |
| **Date** | 2026-07-29 |
| **Principe** | Aucun accès direct aux documents historiques |
| **Règle** | Tout composant futur passe par CORE API |

---

## 1. Principe Fondateur

**Tout composant futur — Theory Engine, Sherpa, Cortex, Plugin SDK, Executive OS, Produits, Runtime — doit communiquer exclusivement via les interfaces définies dans ce document.**

Aucun accès direct aux documents historiques (SUPRA_ZERO_*, SUPRA_FOUNDATION_*, SUPRA_CONSTITUTION.md, SUPRA_GOVERNANCE_*) n'est autorisé.

---

## 2. Architecture de l'API

```
                    ┌──────────────────────────────────────┐
                    │          COMPOSANTS FUTURS            │
                    │  (Theory Engine, Sherpa, Cortex, etc.)│
                    └──────────────┬───────────────────────┘
                                   │
                                   ▼
                    ┌──────────────────────────────────────┐
                    │           SUPRA CORE API              │
                    │  Point d'entrée unique                │
                    └──────────────┬───────────────────────┘
                                   │
              ┌────────────────────┼────────────────────┐
              │                    │                    │
              ▼                    ▼                    ▼
    ┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐
    │    KERNEL API     │ │    QUERY API     │ │   COMMAND API    │
    │  (Lecture kernel) │ │  (Recherche)     │ │  (Écriture)      │
    └──────────────────┘ └──────────────────┘ └──────────────────┘
```

---

## 3. Kernel API (Lecture)

### 3.1 Executive Kernel

```
GET /kernel/executive/vision       → Vision du système
GET /kernel/executive/mission      → Mission du système
GET /kernel/executive/objectives   → Objectifs fondamentaux
GET /kernel/executive/principles   → Principes du CORE
GET /kernel/executive/architecture → Architecture canonique (couches L0-L6)
GET /kernel/executive/authority    → Chaîne d'autorité
```

### 3.2 Mission Kernel

```
GET /kernel/mission/{id}           → Détail d'une mission
GET /kernel/mission/active         → Missions actives
GET /kernel/mission/history        → Historique des missions
GET /kernel/mission/states         → États possibles d'une mission
GET /kernel/mission/pipeline       → Pipeline d'exécution standard
```

### 3.3 Governance Kernel

```
GET /kernel/governance/constitution    → Principes immuables
GET /kernel/governance/gates           → Définition des gates
GET /kernel/governance/gate/{id}       → Détail d'un gate
GET /kernel/governance/compliance      → Règles de conformité
GET /kernel/governance/adr/{id}        → Détail d'une ADR
GET /kernel/governance/adr/list        → Liste des ADR
GET /kernel/governance/authority       → Matrice des autorités
GET /kernel/governance/protection      → Niveaux de protection
GET /kernel/governance/hierarchy       → Hiérarchie documentaire
```

### 3.4 Knowledge Kernel

```
GET /kernel/knowledge/registry/{id}    → Contenu d'un registre
GET /kernel/knowledge/manifest/{id}    → Contenu d'un manifest
GET /kernel/knowledge/graph/{id}       → Contenu d'un graphe
GET /kernel/knowledge/state            → État du système
GET /kernel/knowledge/standards        → Standards et conventions
GET /kernel/knowledge/history          → État historique (ZERO)
GET /kernel/knowledge/components       → Composants et leurs états
GET /kernel/knowledge/decisions        → Décisions architecturales
```

### 3.5 Runtime Kernel

```
GET /kernel/runtime/status             → Statut du runtime
GET /kernel/runtime/services           → Services disponibles
GET /kernel/runtime/workflows          → Workflows définis
GET /kernel/runtime/pipelines          → Pipelines disponibles
GET /kernel/runtime/connectors         → Connecteurs disponibles
GET /kernel/runtime/metrics            → Métriques système
```

### 3.6 Product Kernel

```
GET /kernel/product/list               → Liste des produits
GET /kernel/product/{id}               → Détail d'un produit
GET /kernel/product/relations          → Relations CORE → Produits
GET /kernel/product/contracts          → Contrats produit-CORE
```

### 3.7 Provider Kernel

```
GET /kernel/provider/list              → Liste des providers
GET /kernel/provider/{id}              → Détail d'un provider
GET /kernel/provider/capabilities      → Capacités disponibles
GET /kernel/provider/contracts         → Contrats des providers
GET /kernel/provider/status            → Statut des providers
```

---

## 4. Index API (Navigation)

```
GET /index                            → Master Index complet
GET /index/kernels                    → Liste des kernels
GET /index/registries                 → Liste des registres
GET /index/manifests                  → Liste des manifests
GET /index/policies                   → Liste des policies
GET /index/standards                  → Liste des standards
GET /index/products                   → Liste des produits
GET /index/architecture               → Liste des documents d'architecture

GET /graph                            → Master Graph complet
GET /graph/relations/{component}      → Relations d'un composant
GET /graph/dependencies/{component}   → Dépendances d'un composant
GET /graph/path/{from}/{to}           → Chemin entre deux composants
```

---

## 5. Query API (Recherche)

```
GET /query/search?q={query}           → Recherche dans toute la connaissance
GET /query/resolve?ref={reference}    → Résolution de référence
GET /query/browse?path={path}         → Navigation dans l'arbre de connaissance
GET /query/history?entity={id}        → Historique d'une entité
```

---

## 6. Command API (Écriture)

### 6.1 Missions

```
POST   /mission                           → Créer une mission
PATCH  /mission/{id}                      → Mettre à jour une mission
POST   /mission/{id}/gate                 → Valider un gate pour une mission
POST   /mission/{id}/evidence             → Ajouter une preuve à une mission
POST   /mission/{id}/complete             → Marquer une mission comme complétée
POST   /mission/{id}/fail                  → Marquer une mission comme échouée
```

### 6.2 ADR

```
POST   /adr                               → Proposer une ADR
PATCH  /adr/{id}                          → Mettre à jour une ADR
POST   /adr/{id}/review                   → Soumettre une ADR en review
POST   /adr/{id}/accept                   → Accepter une ADR
POST   /adr/{id}/reject                   → Rejeter une ADR
POST   /adr/{id}/implement                → Marquer une ADR comme implémentée
```

### 6.3 Governance

```
POST   /governance/gate/{id}/validate     → Valider une décision de gate
POST   /governance/compliance/check       → Déclencher un contrôle de conformité
POST   /governance/exception              → Demander une exception
POST   /governance/escalate               → Escalader un conflit
```

### 6.4 Evidence

```
POST   /evidence                          → Enregistrer une preuve
GET    /evidence/{id}                     → Lire une preuve
GET    /evidence/mission/{missionId}      → Preuves d'une mission
```

### 6.5 Runtime

```
PATCH  /runtime/status                    → Mettre à jour le statut runtime
POST   /runtime/metrics                   → Enregistrer des métriques
POST   /runtime/event                     → Enregistrer un événement runtime
```

---

## 7. Health API

```
GET    /health                            → Statut général du CORE
GET    /health/kernels                    → Statut des 7 kernels
GET    /health/registries                 → Statut des registres
GET    /health/services                   → Statut des services
```

---

## 8. Versioning

### 8.1 Version de l'API

| Propriété | Valeur |
|-----------|--------|
| Version actuelle | v1 |
| Format | `/core/v1/{resource}` |
| Stabilité | STABLE — aucune breaking change sans ADR |
| Dép récation | Annoncée 3 versions à l'avance |

### 8.2 Règles de Versioning

| Règle | Description |
|-------|-------------|
| V-01 | Les breaking changes nécessitent une ADR |
| V-02 | Les endpoints dépréciés restent actifs 3 versions |
| V-03 | Les ajouts non-breaking sont autorisés sans ADR |
| V-04 | Chaque version est documentée |
| V-05 | Les changements sont tracés dans le registre |

---

## 9. Exemples d'Utilisation

### 9.1 Theory Engine lit la connaissance

```
GET /core/v1/kernel/knowledge/registry/master
GET /core/v1/kernel/knowledge/standards
GET /core/v1/kernel/executive/vision
```

### 9.2 Sherpa sélectionne le contexte

```
GET /core/v1/kernel/mission/active
GET /core/v1/kernel/executive/objectives
GET /core/v1/kernel/knowledge/state
```

### 9.3 Cortex persiste la mémoire

```
POST /core/v1/evidence
GET /core/v1/evidence/mission/{id}
GET /core/v1/kernel/knowledge/graph/knowledge
```

### 9.4 Executive OS orchestre

```
GET /core/v1/kernel/executive/mission
GET /core/v1/kernel/governance/gates
GET /core/v1/kernel/runtime/services
POST /core/v1/mission
```

---

## 10. Règles de l'API

| ID | Règle | Sanction |
|----|-------|----------|
| API-01 | Tout accès passe par CORE API | Pas de lecture directe des historiques |
| API-02 | Les réponses sont stables | Pas de breaking change sans ADR |
| API-03 | Les erreurs sont documentées | Chaque endpoint documente ses erreurs |
| API-04 | L'API est versionnée | v1 actuelle, dépréciation progressive |
| API-05 | Les endpoints sont cohérents | Conventions de nommage uniformes |
| API-06 | L'authentification est optionnelle | Phase actuelle : accès libre |

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA ULTIMATE CORE V1. API publique unique pour tous les composants futurs.*
