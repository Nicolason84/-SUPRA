# SUPRA COMPONENT CANONICAL MODEL V1

## Modèle Canonique des Composants Permanents de la Plateforme

| Propriété | Valeur |
|-----------|--------|
| **Statut** | CORE — Schéma canonique permanent |
| **Version** | SUPRA_CANONICAL_MODEL_V1 |
| **Date** | 2026-07-29 |
| **Principe** | Tout composant permanent suit ce modèle. Aucune exception. |
| **Application** | SUPRA_EXECUTIVE_PLATFORM_REGISTRY.json (machine-readable) |

---

## 1. Structure Canonique

```
Component {
  id:            String          // Identifiant permanent unique
  name:          String          // Nom du composant
  layer:         String          // Couche architecturale (L0-L6, AGENT, CROSS)
  mission:       String          // Mission unique du composant
  responsibilities: [String]     // Responsabilités (2-5)
  domain:        String          // Domaine fonctionnel
  owner:         String          // Agent/Équipe responsable
  version:       String          // Version semver
  maturity:      String          // PRODUCTION | ULTIMATE | GOVERNANCE | CONSTITUTION | FOUNDATION | IDEA
  state:         String          // CANONICAL | ACTIVE | SPECIFIED | EXPERIMENTAL | PLANNED

  // Interface
  inputs:        [Interface]     // Entrées consommées
  outputs:       [Interface]     // Sorties produites

  // Contrats
  contracts_consumed: [String]   // CIDs des contrats consommés
  contracts_published: [String]  // CIDs des contrats publiés

  // Relations
  dependencies:  [String]        // IDs des composants dépendants (amont)
  dependents:    [String]        // IDs des composants qui dépendent de celui-ci (aval)

  // Architecture
  invariants:    [String]        // Propriétés invariantes
  events:        [String]        // Événements émis/consommés
  api:           [API]           // API publiques exposées

  // Observabilité
  health:        HealthSpec      // Métriques de santé
  observability: ObservabilitySpec // Métriques d'observabilité
  tests:         [String]        // Tests associés

  // Traçabilité
  adrs:          [String]        // ADR IDs associés
  related_components: [String]   // IDs des composants liés (non-dépendance)

  // Runtime
  runtime:       RuntimeSpec     // Spécification runtime
  lifecycle:     LifecycleSpec   // Cycle de vie, transitions, états

  // Implémentation
  implementation: ImplementationSpec // Références d'implémentation
}
```

---

## 2. Définition des Champs

### 2.1 Identité

| Champ | Type | Requis | Description |
|-------|------|--------|-------------|
| `id` | String | OUI | Identifiant permanent unique (ex: `L2.KNOWLEDGE_COMPILER`) |
| `name` | String | OUI | Nom lisible du composant (ex: `SUPRA Knowledge Compiler`) |
| `layer` | Enum | OUI | `L0` / `L1` / `L2` / `L3` / `L4` / `L5` / `L6` / `AGENT` / `CROSS` |
| `mission` | String | OUI | Phrase unique décrivant la mission (max 100 chars) |
| `responsibilities` | [String] | OUI | 2 à 5 responsabilités clés |
| `domain` | String | OUI | Domaine fonctionnel |
| `owner` | String | OUI | Entité responsable (ex: `SUPRA-Architect`) |
| `version` | String | OUI | Version semver (ex: `1.0.0`) |
| `maturity` | Enum | OUI | Niveau de maturité |
| `state` | Enum | OUI | État actuel |

**Maturity levels**: `PRODUCTION` > `ULTIMATE` > `GOVERNANCE` > `CONSTITUTION` > `FOUNDATION` > `IDEA`

**State values**: `CANONICAL` (immuable), `ACTIVE` (opérationnel), `SPECIFIED` (défini, non implémenté), `EXPERIMENTAL` (en cours), `PLANNED` (futur)

### 2.2 Interface

```
Interface {
  name:        String            // Nom de l'entrée/sortie
  type:        String            // Type (ex: GraphState, Mission, AdrDoc)
  format:      String            // Format (ex: JSON, Markdown, Swift)
  description: String            // Description
  optional:    Boolean           // Optionnel ou obligatoire
}
```

### 2.3 API

```
API {
  name:        String            // Nom de l'API
  signature:   String            // Signature (ex: `compile(source, options) -> result`)
  description: String            // Description
  stability:   String            // STABLE / DRAFT / EXPERIMENTAL
  visibility:  String            // PUBLIC / INTERNAL / PRIVATE
}
```

### 2.4 HealthSpec

```
HealthSpec {
  checks:     [String]           // Points de contrôle de santé
  metrics:    [String]           // Métriques clés (ex: success_rate, latency_ms)
  frequency:  String             // Fréquence de vérification
  critical:   Boolean            // Santé critique pour le système
}
```

### 2.5 ObservabilitySpec

```
ObservabilitySpec {
  events:     [String]           // Événements tracés
  logs:       Boolean            // Logging activé
  metrics:    Boolean            // Métriques exposées
  traces:     Boolean            // Traces activées
  dashboard:  String             // ID du dashboard associé
}
```

### 2.6 RuntimeSpec

```
RuntimeSpec {
  executable: Boolean            // Composant exécutable (Swift code)
  location:   String             // Chemin ou référence dans le dépôt
  entrypoint: String             // Point d'entrée (ex: `SUPRACompositionRoot.swift`)
  stateful:   Boolean            // Maintient un état
  lifecycle:  String             // Cycle de vie Runtime (BOOTING, IDLE, ACTIVE, ERROR, SHUTDOWN)
}
```

### 2.7 LifecycleSpec

```
LifecycleSpec {
  stages:     [String]           // Étapes du cycle de vie
  transitions: [Transition]       // Transitions autorisées
  gates:      [String]           // Gates associées
}
```

### 2.8 ImplementationSpec

```
ImplementationSpec {
  language:   String             // Langage d'implémentation
  files:      [String]           // Fichiers sources
  tests:      [String]           // Fichiers de test
  documentation: [String]        // Documentation associée
}
```

---

## 3. Règles de Validation du Modèle

| Règle | Description | Sanction |
|-------|-------------|----------|
| R-01 | Tout composant doit avoir un `id` unique | Rejet à l'enregistrement |
| R-02 | Tout composant doit avoir au moins 1 responsabilité | Rejet à l'enregistrement |
| R-03 | Tout composant doit avoir au moins 1 contrat consommé OU publié | Avertissement |
| R-04 | `mission` ne peut pas dépasser 200 caractères | Troncature |
| R-05 | `version` doit suivre le format semver | Rejet |
| R-06 | Les `dependencies` doivent référencer des `id` existants | Validation croisée |
| R-07 | Les `adrs` doivent référencer des ADR IDs existants | Validation croisée |
| R-08 | Les `contracts_consumed` / `contracts_published` doivent référencer des CID existants | Validation croisée |
| R-09 | Un composant EXECUTABLE doit avoir au moins 1 `implementation.files` | Avertissement |
| R-10 | Un composant ACTIVE doit avoir `maturity >= GOVERNANCE` | Règle de promotion |

---

## 4. Cycle de Vie d'un Composant

```
                    ┌──────────────────────┐
                    │  IDEA (Conception)    │
                    │  State: PLANNED       │
                    └──────────┬───────────┘
                               │ Gate G1: Concept validé
                               ▼
                    ┌──────────────────────┐
                    │ FOUNDATION (Spec)    │
                    │ State: SPECIFIED     │
                    └──────────┬───────────┘
                               │ Gate G2: ADR signé
                               ▼
                    ┌──────────────────────┐
                    │ CONSTITUTION (ADR)   │
                    │ State: SPECIFIED     │
                    └──────────┬───────────┘
                               │ Gate G3: Contrats définis
                               ▼
                    ┌──────────────────────┐
                    │ GOVERNANCE (Impl)    │
                    │ State: ACTIVE        │
                    └──────────┬───────────┘
                               │ Gate G4: Tests validés
                               ▼
                    ┌──────────────────────┐
                    │ ULTIMATE (Validé)    │
                    │ State: CANONICAL     │
                    └──────────┬───────────┘
                               │ Gate G5: Audit PASS
                               ▼
                    ┌──────────────────────┐
                    │ PRODUCTION (Live)    │
                    │ State: CANONICAL     │
                    └──────────────────────┘
```

---

## 5. Transitions d'État

| De | Vers | Gate | Critères |
|----|------|------|----------|
| PLANNED | SPECIFIED | G1 | Concept documenté, mission définie |
| SPECIFIED | ACTIVE | G2 | ADR signé, contrats définis, implémentation commencée |
| ACTIVE | CANONICAL | G3 | Tests passés, documentation complète, audit OK |
| CANONICAL | CANONICAL | G4 | Mise en production, monitoring actif |

---

## 6. Exemple: Composant au Format Canonique

```json
{
  "id": "L4.ROUTER",
  "name": "SUPRA Router",
  "layer": "L4",
  "mission": "Aiguiller chaque mission vers le meilleur couple (agent, modèle)",
  "responsibilities": [
    "Classification des missions",
    "Scoring des couples (agent, modèle)",
    "Sélection du meilleur couple",
    "Gestion des fallbacks"
  ],
  "domain": "Orchestration",
  "owner": "SUPRA-Router",
  "version": "1.0.0",
  "maturity": "GOVERNANCE",
  "state": "ACTIVE",
  "inputs": [
    {"name": "Mission", "type": "Mission", "format": "JSON", "description": "Mission à router"},
    {"name": "Registries", "type": "RegistryState", "format": "JSON", "description": "État des registres agents/modèles"}
  ],
  "outputs": [
    {"name": "RoutingPlan", "type": "Plan", "format": "JSON", "description": "Plan d'affectation"}
  ],
  "contracts_consumed": ["C-003", "C-019", "C-020", "C-021"],
  "contracts_published": ["C-003", "C-040"],
  "dependencies": ["L1.AGENT_REGISTRY", "L1.MODEL_REGISTRY", "L1.CAPABILITY_REGISTRY"],
  "dependents": ["L4.WORKFLOW_ENGINE", "L4.PLANNER"],
  "invariants": [
    "Toute mission est routée vers exactement un agent",
    "Le fallback est toujours défini avant l'exécution"
  ],
  "events": ["mission.routed", "mission.fallback", "router.health_changed"],
  "api": [
    {"name": "route", "signature": "route(mission) -> Plan", "description": "Router une mission", "stability": "STABLE", "visibility": "PUBLIC"},
    {"name": "health", "signature": "health() -> Status", "description": "Santé du routeur", "stability": "STABLE", "visibility": "PUBLIC"}
  ],
  "health": {
    "checks": ["registry_accessible", "routing_engine_ready"],
    "metrics": ["routing_latency_ms", "success_rate", "fallback_rate"],
    "frequency": "30s",
    "critical": true
  },
  "observability": {
    "events": ["mission.routed", "mission.fallback"],
    "logs": true,
    "metrics": true,
    "traces": true,
    "dashboard": "L6.EXECUTIVE_DASHBOARD"
  },
  "tests": ["test_routing_basic", "test_routing_fallback"],
  "adrs": ["ADR-014", "ADR-022"],
  "related_components": ["L5.EXECUTIVE_KERNEL", "L5.GOVERNANCE_KERNEL"],
  "runtime": {
    "executable": true,
    "location": "SUPRA/SUPRARoutingPolicy.swift",
    "entrypoint": "SUPRACompositionRoot.shared",
    "stateful": true,
    "lifecycle": "IDLE"
  },
  "lifecycle": {
    "stages": ["IDEA", "FOUNDATION", "CONSTITUTION", "GOVERNANCE", "ULTIMATE"],
    "transitions": [{"from": "IDEA", "to": "FOUNDATION", "gate": "G1"}],
    "gates": ["G1", "G2", "G3"]
  },
  "implementation": {
    "language": "Swift",
    "files": ["SUPRA/SUPRARoutingPolicy.swift"],
    "tests": ["SUPRATests/SUPRARoutingPolicyTests.swift"],
    "documentation": ["SUPRA_ROUTER_SPECIFICATION_V1.md"]
  }
}
```

---

## 7. Validation Automatique

Ce modèle est conçu pour être validé automatiquement :

- **JSON Schema**: Contre le schéma canonique (à définir dans `schemas/component.schema.json`)
- **Cross-validation**: Vérification des références (IDs, CIDs, ADRs)
- **Health check**: Validation des métriques de santé
- **Contract check**: Vérification que tout contrat référencé existe

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA ULTIMATE CONSOLIDATED PHASE 5. Modèle canonique des composants permanents. Ce document est un standard architectural, pas un document conceptuel.*
