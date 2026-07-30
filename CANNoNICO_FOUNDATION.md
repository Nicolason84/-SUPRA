# CANNoNICO — FOUNDATION

## Fondation de la Représentation Canonique du Runtime

| Propriété | Valeur |
|---|---|
| **Nom** | CANNoNICO — Canonical Runtime Representation |
| **Version** | CANNoNICO_V1 |
| **Date** | 2026-07-29 |
| **Statut** | LIVRABLE AUDIT — FONDATION |
| **Autorité** | SUPRA Constitution — Article 2 |
| **Loi applicable** | Loi 2 : Le Runtime raisonne exclusivement en CANNoNICO |

---

## 1. PHILOSOPHIE CANNoNICO

CANNoNICO n'est pas un format de données.
CANNoNICO n'est pas un schéma.
CANNoNICO n'est pas une API.

CANNoNICO est la **Représentation Canonique Runtime** — le seul modèle de pensée autorisé pour le Runtime SUPRA.

Le Runtime ne raisonne JAMAIS directement sur :
- Swift
- Bash
- JSON
- YAML
- Markdown
- SQL
- API
- UI

Ces formats ne sont que des **projections**.

Le Runtime raisonne **uniquement** sur des structures CANNoNICO.

---

## 2. PRINCIPES FONDATEURS CANNoNICO

### 2.1 Les 5 Loi de CANNoNICO

| # | Principe | Énoncé |
|---|----------|--------|
| C1 | **Unicité** | Il existe une seule représentation CANNoNICO pour chaque réalité système |
| C2 | **Canonicalité** | CANNoNICO est la seule source de vérité pour le Runtime |
| C3 | **Projection-only** | Les formats externes (Swift, JSON, etc.) ne sont que des projections de CANNoNICO |
| C4 | **Immuabilité** | Une fois publié en CANNoNICO, le modèle ne peut être modifié que par une nouvelle compilation TUV5 |
| C5 | **Traçabilité** | Chaque élément CANNoNICO est traçable vers sa source via TUV5 |

### 2.2 Ce que CANNoNICO Remplace

| Actuellement | Remplacé Par | Raison |
|-------------|-------------|--------|
| 4 registres dupliqués (Agent, Model, Capability, Plugin) | CANNoNICO Identity Core | Source de vérité unique |
| Connaissances fragmentées (Kernel, Compiler, Ontology, Graph) | CANNoNICO Knowledge Core | Connaissance canonique unique |
| Runtime kernel + Workflow + Pipelines + Services | CANNoNICO Execution Core | Orchestration cohérente |
| 4 stores mémoire dupliqués | CANNoNICO Memory Core | Mémoire unifiée |
| Gouvernance fragmentée (Kernel, ADR, Gates, Compliance) | CANNoNICO Governance Core | Gouvernance unifiée |
| Projections ad hoc (Swift/JSON/Bash/MD) | Projection Engine CANNoNICO | Système de projection unique |

---

## 3. STRUCTURE CANNoNICO

### 3.1 Modèle Fondamental

CANNoNICO est un modèle à 3 niveaux :

```
Niveau 1 : IDENTITY
  └── Chaque entité a un CANONICAL ID unique
      Format : can:<type>:<hash>
      Exemple : can:agent:a1b2c3d4...

Niveau 2 : RELATION
  └── Chaque relation est un arc dirigé entre deux IDENTITYs
      Format : can:<relation_type>:<source→target>
      Exemple : can:depends:compiler→runtime

Niveau 3 : STATE
  └── Chaque entité a un état qui évolue dans le temps NAMBROCAHORA
      Format : can:<state_type>:<entity_id>@<nambrohora_tick>
      Exemple : can:active:agent:a1b2c3d4@1234567890
```

### 3.2 Les 10 Domaines CANNoNICO

| Domaine | Préfixe CANNoNICO | Description |
|---------|-------------------|-------------|
| Identity | `can:identity:` | Définitions d'entités avec types et cycles de vie |
| Relation | `can:relation:` | Liens entre entités : dépendance, appartenance, flux |
| Capability | `can:capability:` | Compétences mesurables qu'une entité expose |
| Event | `can:event:` | Occurrences immutables qui modifient l'état |
| Knowledge | `can:knowledge:` | Connaissance structurée compilée |
| Decision | `can:decision:` | Choix documentés, justifiés, traçables |
| Time | `can:time:` | Référence temporelle NAMBROCAHORA |
| Constraint | `can:constraint:` | Règles et limites du système |
| Evidence | `can:evidence:` | Preuves et chaînes de justification |
| Projection | `can:projection:` | Vues dérivées vers les formats externes |

### 3.3 Représentation Canonique d'une Entité

```json
{
  "canId": "can:agent:sha256:abc123...",
  "canType": "agent",
  "canVersion": "V1",
  "canName": "SUPRA-Builder",
  "canRole": "Implementation and code generation",
  "canCapabilities": [
    "can:capability:swift_generation",
    "can:capability:artifact_generation",
    "can:capability:edit_operations"
  ],
  "canRelations": {
    "can:depends_on": ["can:agent:sha256:def456..."],
    "can:uses": ["can:knowledge:sha256:789abc..."],
    "can:produces": ["can:artifact:sha256:fedcba..."]
  },
  "canState": {
    "can:status": "active",
    "can:activeSince": "NAMBROCAHORA_TICK",
    "can:lastSeen": "NAMBROCAHORA_TICK"
  },
  "canEvidence": {
    "can:source": "tuv5:comp:uuid",
    "can:compiledAt": "NAMBROCAHORA_TICK",
    "can:trace": ["tuv5:trace:step1", "tuv5:trace:step2"]
  }
}
```

### 3.4 Représentation Canonique d'une Décision

```json
{
  "canId": "can:decision:sha256:...",
  "canType": "decision",
  "canVersion": "V1",
  "canSubject": "Architecture decision",
  "canContext": {
    "can:mission": "can:mission:sha256:...",
    "can:runtimeState": "NAMBROCAHORA_TICK"
  },
  "canOptions": [
    {
      "can:id": "opt_A",
      "can:description": "Option A description",
      "can:score": 0.85
    },
    {
      "can:id": "opt_B",
      "can:description": "Option B description",
      "can:score": 0.72
    }
  ],
  "canChosen": "opt_A",
  "canRationale": "Evidence-based reasoning",
  "canEvidence": ["can:evidence:sha256:...", "can:evidence:sha256:..."],
  "canConstraints": ["can:constraint:sha256:..."],
  "canAuthoritative": true,
  "canCompiledAt": "NAMBROCAHORA_TICK",
  "canSource": "tuv5:comp:uuid"
}
```

---

## 4. CANNoNICO ET LE RUNTIME

### 4.1 Le Runtime Ne Raisonne Que en CANNoNICO

```
┌─────────────────────────────────────────────────────┐
│                  RUNTIME SUPRA                          │
│                                                         │
│  ┌───────────────────────────────────────────────┐  │
│  │           CANNoNICO CORE                        │  │
│  │                                                   │  │
│  │  Identity Core  ──  Knowledge Core              │  │
│  │  Execution Core  ──  Memory Core               │  │
│  │  Governance Core                                   │  │
│  │                                                   │  │
│  │  ⚡ Le Runtime raisonne EXCLUSIVEMENT ici       │  │
│  └───────────────────────────────────────────────┘  │
│                         │                               │
│              ┌──────────┼──────────┐                 │
│              ▼          ▼          ▼                  │
│  ┌────────────┐ ┌─────────┐ ┌──────────┐           │
│  │ Projection  │ │Project. │ │Project.  │           │
│  │ Engine      │ │→ Swift  │ │→ JSON    │           │
│  │             │ │→ Bash   │ │→ Markdown│           │
│  │             │ │→ UI     │ │→ API     │           │
│  └────────────┘ └─────────┘ └──────────┘           │
└─────────────────────────────────────────────────────┘
```

### 4.2 Flux CANNoNICO dans le Runtime

```
1. TUV5 compile la connaissance brute → CANNoNICO
2. Le Runtime consomme CANNoNICO
3. Le Runtime prend des décisions en CANNoNICO
4. Le Runtime stocke les résultats en CANNoNICO (via NAMBROCAHORA)
5. Le Projection Engine projette vers les formats externes
   - Swift pour le code
   - JSON pour les API
   - Bash pour l'orchestration
   - Markdown pour la documentation
   - UI pour l'interface
```

### 4.3 Interdictions CANNoNICO pour le Runtime

Le Runtime NE DOIT JAMAIS :
- [ ] Raisonner directement sur du code Swift source
- [ ] Parser du JSON comme source de vérité (il est une projection)
- [ ] Utiliser des timestamps système directement
- [ ] Accéder à des fichiers comme source de connaissance
- [ ] Créer de nouvelles représentations internes
- [ ] Maintenir des états non traçables vers CANNoNICO
- [ ] Stocker des décisions sans référence à une preuve CANNoNICO
- [ ] Exposer des modèles internes non canoniques

---

## 5. CANNoNICO PRIMITIVES (Détail)

### 5.1 Identity Primitives

| Primitive | Format | Exemple |
|-----------|--------|---------|
| Agent ID | `can:agent:<sha256>` | `can:agent:a1b2c3...` |
| Knowledge ID | `can:knowledge:<sha256>` | `can:knowledge:...` |
| Event ID | `can:event:<sha256>` | `can:event:...` |
| Decision ID | `can:decision:<sha256>` | `can:decision:...` |
| Constraint ID | `can:constraint:<sha256>` | `can:constraint:...` |
| Relation ID | `can:relation:<sha256>` | `can:relation:...` |
| Projection ID | `can:projection:<sha256>` | `can:projection:...` |

### 5.2 Relation Primitives

| Relation Type | Direction | Sémantique |
|--------------|-----------|-----------|
| `depends_on` | A → B | A dépend de B pour exister |
| `uses` | A → B | A utilise B comme resource |
| `produces` | A → B | A produit B |
| `constrains` | A → B | A limite le comportement de B |
| `projects_to` | CANNoNICO → Format | CANNoNICO se projette vers ce format |
| `compiles_from` | CANNoNICO ← Source | CANNoNICO dérive de cette source TUV5 |
| `references` | A → B | A référence B |
| `precedes` | A → B | A précède B dans le temps NAMBROCAHORA |
| `causes` | A → B | A cause B |
| `validates` | A → B | A prouve B |

### 5.3 State Primitives

| State | Valeurs | Description |
|-------|---------|-------------|
| `can:status` | `active`, `inactive`, `deprecated`, `error` | État de vie d'une entité |
| `can:mode` | `normal`, `degraded`, `fallback`, `maintenance` | Mode de fonctionnement |
| `can:phase` | `detect`, `ingest`, `process`, `validate`, `compile`, `publish` | Phase du cycle TUV5 |
| `can:verdict` | `pass`, `fail`, `retry`, `defer` | Verdict de décision |
| `can:severity` | `critical`, `error`, `warning`, `info` | Niveau de gravité |

---

## 6. PROJECTION ENGINE CANNoNICO

Le Projection Engine transforme le CANNoNICO en formats externes :

```
CANNoNICO Core
     │
     ├──→ Projection → Swift (code executable)
     │                    ├── Agent definitions
     │                    ├── Service implementations
     │                    ├── Runtime bindings
     │                    └── UI components
     │
     ├──→ Projection → JSON (API responses, data exchange)
     │                    ├── Registry responses
     │                    ├── Graph queries
     │                    └── Event streams
     │
     ├──→ Projection → Bash (orchestration scripts)
     │                    ├── Build scripts
     │                    ├── Deployment commands
     │                    └── Lifecycle scripts
     │
     ├──→ Projection → Markdown (documentation)
     │                    ├── Architecture docs
     │                    ├── ADR documents
     │                    └── Runbooks
     │
     └──→ Projection → UI (SwiftUI views)
                          ├── Dashboards
                          ├── Runtime monitors
                          └── Decision panels
```

---

## 7. CANNoNICO × LES LOIS FONDAMENTALES

| Loi | Application CANNoNICO |
|-----|--------------------------|
| Loi 1 : La connaissance > les fichiers | CANNoNICO est la connaissance compilée ; les fichiers ne sont que des véhicules temporaires |
| Loi 2 : Le Runtime raisonne en CANNoNICO | CANNoNICO est la représentation unique du Runtime |
| Loi 3 : Le Runtime synchronise en NAMBROCAHORA | CANNoNICO utilise NAMBROCAHORA pour toute temporalité |
| Loi 4 : TUV5 transforme complexité → connaissance | TUV5 compile vers CANNoNICO |
| Loi 5 : Nouvelles capacités enrichissent le Runtime | CANNoNICO est la capacité d'enrichissement par excellence |

---

## 8. PIPELINE CANONIQUE — POSITION DE CANNoNICO

```
Connaissance brute
  │
  ▼
TUV5 (Knowledge Compiler)
  │  Compile et normalise
  ▼
CANNoNICO ◄── CANNoNICO est la représentation canonique résultante
  │
  ▼
Runtime (raisonne exclusivement en CANNoNICO)
  │
  ▼
NAMBROCAHORA ◄── fournit la référence temporelle unique
  │
  ▼
Projection Engine
  │  Projette CANNoNICO vers formats externes
  ▼
Swift / JSON / Bash / Markdown / UI / API
```

---

## 9. CANNoNICO × AUTRES FONDATIONS

```
TUV5 (Knowledge Compiler)
  │
  ├──→ Produit du CANNoNICO
  │       │
  │       ▼
  │    CANNoNICO Foundation (ce document)
  │       │
  │       ▼
  │    Runtime consomme CANNoNICO
  │       │
  │       ▼
  │    NAMBROCAHORA fournit le temps
  │       │
  │       ▼
  │    Projection Engine projette vers formats externes
  │
  └──→ Le cycle complet :
       Raw Knowledge → TUV5 → CANNoNICO → Runtime → NAMBROCAHORA → Projections
```

---

*CANNoNICO Foundation V1 — SUPRA ULTIMATE CONSOLIDATED*
*Audit exécuté le 2026-07-29*
