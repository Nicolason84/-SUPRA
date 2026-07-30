# CANNoNICO PRIMITIVES

## Primitives Canoniques de la Représentation Runtime

| Propriété | Valeur |
|---|---|
| **Version** | CANNoNICO_PRIMITIVES_V1 |
| **Date** | 2026-07-29 |
| **Statut** | LIVRABLE AUDIT — FONDATION |
| **Autorité** | SUPRA Constitution |
| **Loi** | Loi 2 : Le Runtime raisonne exclusivement en CANNoNICO |

---

## 1. LES 14 PRIMITIVES CANNoNICO

Les primitives sont les briques élémentaires à partir desquelles tout le modèle Runtime peut être reconstruct. Elles sont dérivées de l'analyse exhaustive du codebase et de l'audit sémantique.

### 1.1 Primitives d'Identité

| # | Primitive | Type | Définition Canonique |
|---|-----------|------|---------------------|
| P1 | **CAN_ID** | Identity | Identifiant canonique immuable d'une entité. Format : `can:<type>:<sha256>` |
| P2 | **CAN_TYPE** | Identity | Le type d'entité auquel appartient le CAN_ID. Définit la catégorie sémantique |
| P3 | **CAN_VERSION** | Identity | Version canonique de la représentation. Toujours `V1` pour la version actuelle |
| P4 | **CAN_NAME** | Identity | Nom lisible de l'entité. Non unique — le CAN_ID est l'unique identifiant |

### 1.2 Primitives de Connaissance

| # | Primitive | Type | Définition Canonique |
|---|-----------|------|---------------------|
| P5 | **CAN_KNOWLEDGE** | Knowledge | Unité de connaissance structurée, compilée par TUV5, non redondante |
| P6 | **CAN_RELATION** | Knowledge | Arc dirigé entre deux CAN_IDs avec un type sémantique et une cardinalité |
| P7 | **CAN_CAPABILITY** | Knowledge | Compétence mesurable qu'une entité expose ou qu'un système peut effectuer |
| P8 | **CAN_CONSTRAINT** | Knowledge | Règle ou limite qui borne le comportement d'une entité ou d'un système |

### 1.3 Primitives d'Événement et Temps

| # | Primitive | Type | Définition Canonique |
|---|-----------|------|---------------------|
| P9 | **CAN_EVENT** | Event | Occurrence immutable datée de NAMBROCAHORA qui modifie l'état d'une ou plusieurs entités |
| P10 | **CAN_TIME** | Time | Référence temporelle logique unique du système. Remplace tous les timestamps système |
| P11 | **CAN_SEQUENCE** | Time | Ordre total des événements. Dérivé de CAN_TIME, garantit la causalité |

### 1.4 Primitives de Décision et État

| # | Primitive | Type | Définition Canonique |
|---|-----------|------|---------------------|
| P12 | **CAN_DECISION** | Decision | Choix documenté avec rationale, evidence, contraintes et verdict |
| P13 | **CAN_STATE** | Decision | Ensemble des propriétés d'une entité à un instant NAMBROCAHORA donné |
| P14 | **CAN_TRANSITION** | Decision | Changement d'état d'une entité entre deux ticks NAMBROCAHORA |

---

## 2. DÉRIVATION DES PRIMITIVES

### 2.1 De quoi chaque primitive est dérivée

```
P1  CAN_ID     ← TUV5 Entity Resolution + Identity Resolution
P2  CAN_TYPE   ← Unified Ontology (ENTITY types)
P3  CAN_VERSION ← Constitution (version immuable)
P4  CAN_NAME   ← TUV5 Concept Extraction (nom lisible)
P5  CAN_KNOWLEDGE ← TUV5 Knowledge Graph + CANONICO Ontology
P6  CAN_RELATION  ← TUV5 Relation Resolver + CANONICO Edge Model
P7  CAN_CAPABILITY ← Agent Registry + Model Registry + Capability Registry
P8  CAN_CONSTRAINT ← CANONICO Constraint Library + Constraint Engine
P9  CAN_EVENT   ← Runtime Events + TUV5 Event Engine
P10 CAN_TIME    ← NAMBROCAHORA (voir NAMBROCAHORA_FOUNDATION.md)
P11 CAN_SEQUENCE ← NAMBROCAHORA ordering + TUV5 Consistency Engine
P12 CAN_DECISION ← SUPRA Decision Engine + TUV5 Evidence Engine
P13 CAN_STATE   ← Runtime State + TUV5 Memory Engine
P14 CAN_TRANSITION ← TUV5 Consistency Engine + Runtime Events
```

### 2.2 Pourquoi 14 Primitives Exactement

| Argument | Justification |
|----------|--------------|
| Complétude fonctionnelle | Les 7 modèles existants (Agent, Model, Workflow, Runtime, Knowledge, Governance, Memory) se ramènent à ces 14 primitives |
| Minimalité | Aucune primitive ne peut être dérivée des 13 autres |
| Orthodoxie | Les 7 domaines (Identity, Knowledge, Relation, Capability, Constraint, Event, Time, Decision, State, Transition) sont couverts |
| Projection | Chaque primitive se projette vers Swift, JSON, Bash, Markdown sans perte |
| Temporalité | P9-P11 fournissent la base événementielle et temporelle |
| Cognition | P12-P14 fournissent la base décisionnelle |

---

## 3. DÉFINITIONS FORMELLES

### 3.1 CAN_ID

```
CAN_ID ::= "can:" CAN_TYPE ":" SHA256

CAN_TYPE ::= "agent" | "knowledge" | "event" | "decision" | "constraint"
           | "relation" | "capability" | "projection" | "memory"
           | "runtime" | "workflow" | "service" | "connector" | "manifest"

SHA256 ::= hex64  (64 caractères hexadécimaux)
```

Propriétés :
- **Immutable** : Le CAN_ID ne change jamais
- **Content-addressed** : Le hash est dérivé du contenu canonicisé
- **Unique** : Deux entités différentes ont toujours des CAN_IDs différents
- **Traceable** : Le CAN_ID permet de retrouver la source TUV5 de compilation

### 3.2 CAN_KNOWLEDGE

```
CAN_KNOWLEDGE ::= {
  canId: CAN_ID,                           -- obligatoire
  canType: "knowledge",                    -- obligatoire
  canVersion: CAN_VERSION,                 -- obligatoire
  canName: STRING,                         -- obligatoire
  canContent: CANONICAL_CONTENT,           -- le contenu compilé
  canSource: [TUV5_COMPILE_REF],           -- références aux sources TUV5
  canEvidence: [CAN_ID],                   -- preuves soutenant cette connaissance
  canConfidence: FLOAT [0.0..1.0],         -- degré de certitude
  canCompiledAt: CAN_TIME,                 -- tick NAMBROCAHORA de compilation
  canState: CAN_STATE_REF,                 -- référence à l'état actuel
  canRelations: [CAN_RELATION_REF],        -- relations avec d'autres connaissances
  canConstraints: [CAN_ID],                -- contraintes applicables
  canProjections: [CAN_PROJECTION_REF],    -- projections vers formats externes
  canTrace: [CAN_ID],                      -- chaîne de traçabilité TUV5
  canValidated: BOOLEAN,                   -- si la connaissance a passé la validation TUV5
  canRejected: BOOLEAN,                    -- si la connaissance a été rejetée
  canRejectionReason: STRING | NULL        -- raison du rejet si applicable
}
```

### 3.3 CAN_RELATION

```
CAN_RELATION ::= {
  canId: CAN_ID,                           -- obligatoire
  canType: "relation",                     -- obligatoire
  canSource: CAN_ID,                       -- l'entité source
  canTarget: CAN_ID,                       -- l'entité cible
  canRelationType: RELATION_TYPE,          -- la nature du lien
  canDirection: "directed" | "bidirectional",
  canWeight: FLOAT [0.0..1.0],             -- force de la relation
  canEvidence: [CAN_ID],                   -- preuves de cette relation
  canCompiledAt: CAN_TIME,
  canValidated: BOOLEAN
}

RELATION_TYPE ::= "depends_on" | "uses" | "produces" | "constrains"
                | "projects_to" | "compiles_from" | "references"
                | "precedes" | "causes" | "validates"
                | "belongs_to" | "extends" | "implements"
                | "replaces" | "supersedes" | "derives_from"
                | "communicates_with" | "syncs_with" | "triggers"
                | "monitors" | "controls" | "observes"
```

### 3.4 CAN_CAPABILITY

```
CAN_CAPABILITY ::= {
  canId: CAN_ID,                           -- obligatoire
  canType: "capability",                   -- obligatoire
  canName: STRING,                         -- nom lisible
  canDescription: STRING,                  -- description fonctionnelle
  canEntity: CAN_ID,                       -- l'entité qui possède cette capacité
  canQuality: {                             -- qualité mesurable
    can:accuracy: FLOAT [0.0..1.0],
    can:latency_ms: INT,
    can:availability: FLOAT [0.0..1.0],
    can:throughput: FLOAT,
    can:reliability: FLOAT [0.0..1.0]
  },
  canRequirements: [CAN_ID],               -- prérequis pour cette capacité
  canLimitations: [CAN_CONSTRAINT_REF],    -- limites de cette capacité
  canEvidence: [CAN_ID],
  canCompiledAt: CAN_TIME,
  canValidated: BOOLEAN
}
```

### 3.5 CAN_EVENT

```
CAN_EVENT ::= {
  canId: CAN_ID,                           -- obligatoire
  canType: "event",                        -- obligatoire
  canName: STRING,                         -- nom de l'événement
  canCategory: EVENT_CATEGORY,             -- type catégoriel
  canTick: CAN_TIME,                       -- instant NAMBROCAHORA
  canEntity: CAN_ID,                       -- entité concernée
  canPayload: CANONICAL_PAYLOAD,           -- données de l'événement
  canPreviousState: CAN_STATE_REF | NULL,  -- état avant l'événement
  canNextState: CAN_STATE_REF | NULL,      -- état après l'événement
  canSource: CAN_ID,                       -- ce qui a provoqué l'événement
  canEvidence: [CAN_ID],
  canCompiledAt: CAN_TIME,
  canImmutable: BOOLEAN                    -- un Event ne peut être modifié
}

EVENT_CATEGORY ::= "creation" | "mutation" | "validation" | "compilation"
                 | "decision" | "execution" | "error" | "recovery"
                 | "health_check" | "projection" | "migration"
```

### 3.6 CAN_DECISION

```
CAN_DECISION ::= {
  canId: CAN_ID,                           -- obligatoire
  canType: "decision",                     -- obligatoire
  canSubject: STRING,                      -- sujet de la décision
  canContext: {                             -- contexte de la décision
    can:mission: CAN_ID | NULL,
    can:runtimeState: CAN_TIME,
    can:availableOptions: [CAN_ID]
  },
  canOptions: [CAN_DECISION_OPTION],       -- options envisagées
  canChosen: STRING,                       -- l'option choisie
  canRationale: STRING,                    -- justification
  canEvidence: [CAN_ID],                   -- preuves soutenant le choix
  canConstraints: [CAN_ID],                -- contraintes respectées
  canAuthoritative: BOOLEAN,               -- si c'est une décision finale
  canVerdict: DECISION_VERDICT,           -- pass/fail/retry/defer
  canCompiledAt: CAN_TIME,
  canSource: CAN_ID,                       -- le TUV5 compilation qui a produit cette décision
  canTrace: [CAN_ID],                      -- chaîne de traçabilité
  canValidated: BOOLEAN,                   -- si validée par le Governance Core
  canGovernanceRef: CAN_ID | NULL          -- référence à la governance si applicable
}

DECISION_VERDICT ::= "pass" | "fail" | "retry" | "defer" | "escalate"
```

---

## 4. INTERDICTIONS DE CANNoNICO

Ce qui n'est PAS une primitive CANNoNICO :

| Non-Primitive | Raison |
|---------------|--------|
| `Date` (Swift) | C'est un temps machine, pas NAMBROCAHORA |
| `UUID` | C'est un identifiant technique, pas un CAN_ID |
| `String` libre | Ce n'est pas une représentation canonique structurée |
| `Array` brut | C'est une structure de données, pas un modèle CANNoNICO |
| `Dictionary` brut | C'est une structure de données, pas un modèle CANNoNICO |
| Code Swift source | C'est une projection, pas du CANNoNICO |
| Fichier path | C'est une référence technique, pas du CANNoNICO |
| Log brut | C'est une projection événementielle brute, pas du CANNoNICO |
| JSON non canonique | C'est un format de sérialisation temporaire |
| YAML config | C'est un format de configuration, pas du CANNoNICO |

---

## 5. CANNoNICO PRIMITIVES × LA PIPELINE CANONIQUE

```
Connaissance brute
  │
  ▼
TUV5
  │  Utilise les primitives suivantes :
  │  P1-CAN_ID, P2-CAN_TYPE, P4-CAN_NAME
  │  P5-CAN_KNOWLEDGE (production)
  │  P6-CAN_RELATION (production)
  │  P10-CAN_TIME, P11-CAN_SEQUENCE
  │
  ▼
Connaissance compacte (CANNoNICO)
  │  Contient tous les éléments CANNoNICO :
  │  P1-P4 (Identity)
  │  P5-P8 (Knowledge)
  │  P9-P11 (Event/Time)
  │  P12-P14 (Decision/State)
  │
  ▼
Runtime
  │  Le Runtime consomme et raisonne uniquement via :
  │  CAN_ID (identification)
  │  CAN_KNOWLEDGE (connaissance)
  │  CAN_EVENT (occurrences)
  │  CAN_DECISION (choix)
  │  CAN_STATE (états)
  │  CAN_TIME (temporalité)
  │
  ▼
NAMBROCAHORA
  │  Fournit P10-CAN_TIME et P11-CAN_SEQUENCE
  │
  ▼
Projection Engine
  │  Projette CANNoNICO vers :
  │  Swift, JSON, Bash, Markdown, UI, API
```

---

## 7. CANNoNICO PRIMITIVES × LES LOIS FONDAMENTALES

| Loi | Application Primitives |
|-----|--------------------------|
| Loi 1 : La connaissance > les fichiers | Les primitives CANNoNICO transforment la connaissance brute en modèles structurés |
| Loi 2 : Le Runtime raisonne en CANNoNICO | Les 14 primitives sont les seuls modèles autorisés pour le Runtime |
| Loi 3 : Le Runtime synchronise en NAMBROCAHORA | P10-CAN_TIME et P11-CAN_SEQUENCE sont les primitives temporelles NAMBROCAHORA |
| Loi 4 : TUV5 transforme complexité → connaissance | P5-CAN_KNOWLEDGE et P6-CAN_RELATION sont produites par TUV5 |
| Loi 5 : Nouvelles capacités enrichissent le Runtime | Toute nouvelle capacité s'exprime via les primitives CANNoNICO |

---

## 8. PIPELINE CANONIQUE — POSITION DES PRIMITIVES

```
Connaissance brute
  │
  ▼
TUV5
  │  Compile et produit les primitives CANNoNICO
  ▼
CANNoNICO Primitives (P1-P14) ◄── Les primitives définissent CANNoNICO
  │
  ▼
Runtime
  │  Le Runtime raisonne exclusivement via les primitives P1-P14
  │
  ▼
NAMBROCAHORA ◄── P10 et P11 fournissent la référence temporelle unique
  │
  ▼
Projection Engine
  │  Projette les primitives CANNoNICO vers Swift, JSON, Bash, MD, UI, API
  ▼
Formats externes
```

---

## 9. TABLEAU DE CONCORDANCE CANNoNICO PRIMITIVES × EXISTANT

| Primitive | Existant dans SUPRA | Remplace |
|-----------|---------------------|----------|
| P1 CAN_ID | CAnnoNicoContracts.swift (CAnnoNicoSourceReference.id) | UUID-based identifiers |
| P2 CAN_TYPE | Multiple entity types (agent, mission, runtime...) | Ad-hoc type strings |
| P3 CAN_VERSION | version.json, various version strings | Scattered version fields |
| P4 CAN_NAME | Name fields in all models | Various naming conventions |
| P5 CAN_KNOWLEDGE | KnowledgeObject, KnowledgeGraph, KnowledgeKernel | Unified into one primitive |
| P6 CAN_RELATION | KnowledgeRelation, KnowledgeRelationship, DependencyGraph | Unified into one primitive |
| P7 CAN_CAPABILITY | SUPRACapabilityBroker, CapabilityRegistry | Unified into one primitive |
| P8 CAN_CONSTRAINT | SUPRA_CONSTRAINT_FRAMEWORK, CANONICO_CONSTRAINT | Unified into one primitive |
| P9 CAN_EVENT | RuntimeEvent, SUPRARuntimeEvents | Unified into one primitive |
| P10 CAN_TIME | Date(), ISO8601, various timestamps | Unified → NAMBROCAHORA |
| P11 CAN_SEQUENCE | N/A (not existing) | New primitive |
| P12 CAN_DECISION | Decision.swift, SUPRADecisionEngine | Unified into one primitive |
| P13 CAN_STATE | RuntimeState, MultiMemoryState, etc. | Unified into one primitive |
| P14 CAN_TRANSITION | N/A (not existing) | New primitive |

---

*CANNoNICO Primitives V1 — SUPRA ULTIMATE CONSOLIDATED*
*Audit exécuté le 2026-07-29*
