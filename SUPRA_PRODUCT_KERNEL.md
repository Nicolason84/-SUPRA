# SUPRA PRODUCT KERNEL V1

## Relations entre CORE, Runtime, Produits, Applications et Services

| Propriété | Valeur |
|-----------|--------|
| **Statut** | CORE — Product Kernel |
| **Version** | SUPRA_PRODUCT_KERNEL_V1 |
| **Date** | 2026-07-29 |
| **Autorité** | CORE — Définit la relation produits-système |
| **Sources absorbées** | SUPRA_FOUNDATION_ROADMAP.md, SUPRA_PRODUCT_TARGET.md, SUPRA_ALPHA_*, SUPRA_ALIVE_*, SUPRA_PRODUCT_FREEZE_V1_REPORT.md |

---

## 1. Arbre des Relations Produits

```
                    ┌──────────────────────────────────────┐
                    │          SUPRA CORE                   │
                    │  (Socle opérationnel unique)          │
                    └──────────────────────────────────────┘
                                      │
            ┌─────────────────────────┼─────────────────────────┐
            │                         │                         │
            ▼                         ▼                         ▼
┌─────────────────────┐   ┌─────────────────────┐   ┌─────────────────────┐
│   SUPRA RUNTIME     │   │  THEORY ENGINE      │   │   EXECUTIVE OS      │
│   (L4)              │   │  (L2)               │   │   (L5)              │
│   Exécution         │   │  Connaissance       │   │   Orchester.        │
└─────────────────────┘   └─────────────────────┘   └─────────────────────┘
            │                         │                         │
            └─────────────────────────┼─────────────────────────┘
                                      │
                                      ▼
┌──────────────────────────────────────────────────────────────────────┐
│                         PRODUITS SUPRA                                │
│                                                                       │
│  ┌────────────────────┐  ┌────────────────────┐  ┌────────────────┐  │
│  │  SUPRA ALIVE       │  │  SUPRA ALPHA       │  │  AUTRES        │  │
│  │  (Executive OS)    │  │  (Platform)        │  │  (Futurs)      │  │
│  └────────────────────┘  └────────────────────┘  └────────────────┘  │
│                                                                       │
│  ┌────────────────────┐  ┌────────────────────┐  ┌────────────────┐  │
│  │  SUPRA DASHBOARD   │  │  SUPRA LAB         │  │  SUPRA CLI     │  │
│  │  (Monitoring)      │  │  (Research)        │  │  (Interface)   │  │
│  └────────────────────┘  └────────────────────┘  └────────────────┘  │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 2. Définitions

| Terme | Définition |
|-------|------------|
| **CORE** | Socle opérationnel unique. Point d'entrée de toute l'architecture. |
| **Runtime** | Moteur d'exécution. Services, workflows, pipelines. |
| **Produit** | Capacité livrable à un utilisateur. S'appuie sur CORE + Runtime. |
| **Application** | Interface utilisateur d'un produit (UI, CLI, API). |
| **Service** | Capacité réutilisable exposée par le Runtime. |
| **Plugin** | Extension interchangeable du système. |

---

## 3. Relations Fondamentales

### 3.1 CORE → Runtime

```
CORE fournit : Vision, Mission, Règles, Gouvernance, Connaissance
Runtime fournit : Exécution, Services, Pipelines, Connecteurs
```

### 3.2 Runtime → Produits

```
Runtime fournit : Services d'exécution, Workflows, Métriques
Produits utilisent : Services du Runtime via interfaces définies
```

### 3.3 CORE → Produits

```
CORE fournit : Objectifs, Contraintes, Validation
Produits respectent : Règles CORE, Gates, Cycle de vie
```

### 3.4 Produits → Applications

```
Produit définit : Capacité, Contrat, Interface
Application implémente : UI/UX, API publique
```

### 3.5 CORE → Plugins

```
CORE définit : Contrats, Points d'extension, Validation
Plugin implémente : Capacité spécifique, Interchangeable
```

---

## 4. Cycle de Vie d'un Produit

```
IDEA ──[G1]──▶ FOUNDATION ──[G2]──▶ CONSTITUTION ──[G3]──▶ GOVERNANCE ──[G4]──▶ ULTIMATE ──[G5]──▶ PRODUCTION
  │              │                     │                    │              │                  │
  ▼              ▼                     ▼                    ▼              ▼                  ▼
Note        Dossier               ADR +               Implémentation   Intégration       Release
d'intention  Foundation           Architecture         + Tests         finale             officielle
```

Chaque produit suit ce cycle. Aucun produit ne peut être en PRODUCTION sans avoir passé G5.

---

## 5. Produits Existants

### 5.1 SUPRA ALIVE

| Propriété | Valeur |
|-----------|--------|
| **Statut** | ACTIF |
| **Type** | Executive OS |
| **Couche** | L5 |
| **Dépend de** | CORE, Runtime |
| **Roadmap** | SUPRA_ALIVE_ROADMAP.md |
| **Implémentation** | SUPRA_ALIVE_IMPLEMENTATION.md |
| **Runtime** | SUPRA_ALIVE_RUNTIME.md |

### 5.2 SUPRA ALPHA

| Propriété | Valeur |
|-----------|--------|
| **Statut** | ACTIF |
| **Type** | Platform |
| **Couche** | L4-L5 |
| **Certification** | SUPRA_ALPHA_CERTIFICATION.md |
| **Définition** | SUPRA_ALPHA_DEFINITION.md |
| **Roadmap** | SUPRA_ALPHA_ROADMAP.md |

### 5.3 SUPRA LAB

| Propriété | Valeur |
|-----------|--------|
| **Statut** | ACTIF |
| **Type** | Research |
| **Couche** | L2 |
| **Architecture** | SUPRA_AI_LAB_ARCHITECTURE_V1.md |
| **Lab Architecture** | SUPRA_LAB_ARCHITECTURE_V1.md |

### 5.4 SUPRA DASHBOARD

| Propriété | Valeur |
|-----------|--------|
| **Statut** | PARTIEL |
| **Type** | Monitoring |
| **Couche** | L6 |

### 5.5 SUPRA CLI

| Propriété | Valeur |
|-----------|--------|
| **Statut** | PARTIEL |
| **Type** | Interface |
| **Couche** | L6 |

---

## 6. Produits Futurs (Phase 2+)

| Produit | Couche | Dépend de | Priorité |
|---------|--------|-----------|----------|
| Theory Engine | L2 | Knowledge Kernel | HAUTE |
| Sherpa | L3 | Theory Engine | HAUTE |
| Cortex | L3 | Knowledge Kernel | HAUTE |
| Plugin SDK | L1 | Provider Kernel | MOYENNE |
| Executive Dashboard | L6 | Runtime, CORE | MOYENNE |
| SUPRA Marketplace | L6 | Plugin SDK | FUTURE |
| SUPRA Analytics | L6 | Runtime | FUTURE |

---

## 7. Contrats Produit ↔ CORE

### 7.1 Ce qu'un Produit DOIT

| Obligation | Description |
|------------|-------------|
| Lire le CORE | Passer par SUPRA_MASTER_INDEX.md pour naviguer |
| Respecter la gouvernance | Suivre le Governance Kernel |
| Passer les Gates | G1 à G5 obligatoires |
| Produire des preuves | Evidence de chaque phase |
| Être traçable | Toute décision documentée |
| Être réversible | Rollback plan défini |

### 7.2 Ce qu'un Produit PEUT

| Droit | Description |
|-------|-------------|
| Lire les 7 Kernels | Accès en lecture à tous les Kernels |
| Utiliser le Runtime | Accès aux services du Runtime |
| S'enregistrer | Déclaration dans le registre des produits |
| Étendre | Via plugins (contrats définis) |
| Évoluer | Via le cycle de vie standard |

### 7.3 Ce qu'un Produit NE PEUT PAS

| Interdiction | Sanction |
|-------------|----------|
| Contourner le CORE | REFUS |
| Sauter un Gate | BLOCAGE |
| Accéder directement aux documents historiques | INVALIDATION |
| Créer une architecture parallèle | REFUS |
| Supprimer des données irréversiblement | ROLLBACK |

---

## 8. Matrice de Correspondance

| Produit | Kernel Principal | Kernel Secondaire | Runtime Service |
|---------|-----------------|-------------------|----------------|
| Theory Engine | Knowledge | Executive, Governance | Knowledge Service |
| Sherpa | Knowledge | Mission, Executive | Context Service |
| Cortex | Knowledge | Mission, Runtime | Memory Service |
| Executive OS | Executive | Governance, Mission, Runtime | Orchestration Service |
| Plugin SDK | Provider | Runtime, Governance | Provider Service |
| Dashboard | Runtime | Executive, Product | Metrics Service |
| CLI | Runtime | Executive | Execution Service |

---

## 9. Règles du Product Kernel

| ID | Règle | Description |
|----|-------|-------------|
| PK-01 | Tout produit dépend du CORE | Pas de produit sans référence CORE |
| PK-02 | Tout produit suit le cycle de vie | IDEA → PRODUCTION obligatoire |
| PK-03 | Tout produit a un propriétaire | Propriété unique |
| PK-04 | Tout produit est enregistré | Entrée dans le registre des produits |
| PK-05 | Tout produit a un contrat | Interface définie et documentée |
| PK-06 | Les produits futurs lisent via CORE API | Pas d'accès direct aux historiques |
| PK-07 | Les relations CORE-Produit sont stables | Pas de breaking change sans ADR |

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA ULTIMATE CORE V1. Kernel des relations produits-système.*
