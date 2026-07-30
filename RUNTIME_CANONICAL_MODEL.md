# RUNTIME CANONICAL MODEL

## Modèle Canonique du Runtime SUPRA

| Propriété | Valeur |
|---|---|
| **Version** | RUNTIME_CANONICAL_MODEL_V1 |
| **Date** | 2026-07-29 |
| **Statut** | LIVRABLE AUDIT — FONDATION |
| **Autorité** | SUPRA Constitution — Article 2 |
| **Loi applicable** | Loi 2 + Loi 3 |

---

## 1. PRINCIPLE

Le Runtime SUPRA raisonne exclusivement en CANNoNICO.
Le Runtime se synchronise exclusivement en NAMBROCAHORA.
Le Runtime consomme uniquement le CANNoNICO produit par TUV5.

Toute connaissance, décision, état et temporalité du Runtime est représentée sous CANNoNICO et référenciée par NAMBROCAHORA.

---

## 2. COUCHES DU RUNTIME CANONICAL

Le Runtime est organisé en 4 couches canoniques, qui remplacent les 6+ couches existantes :

```
┌─────────────────────────────────────────────────────┐
│  COUCHE 4 : PROJECTION                               │
│  ┌─────────────────────────────────────────────┐  │
│  │  ProjectionEngine                            │  │
│  │  ← CANNoNICO → Swift, JSON, Bash, MD, UI, API  │  │
│  └─────────────────────────────────────────────┘  │
├─────────────────────────────────────────────────────┤
│  COUCHE 3 : EXÉCUTION                               │
│  ┌─────────────────────────────────────────────┐  │
│  │  ExecutionCore                               │  │
│  │  ├── MissionOrchestrator                     │  │
│  │  ├── WorkflowEngine                           │  │
│  │  ├── DecisionEngine                           │  │
│  │  └── TaskExecutor                             │  │
│  └─────────────────────────────────────────────┘  │
├─────────────────────────────────────────────────────┤
│  COUCHE 2 : CONNAISSANCE                            │
│  ┌─────────────────────────────────────────────┐  │
│  │  KnowledgeCore                               │  │
│  │  ├── IdentityCore (CAN_ID, CAN_TYPE)         │  │
│  │  ├── KnowledgeGraph (CAN_KNOWLEDGE)          │  │
│  │  ├── RelationGraph (CAN_RELATION)            │  │
│  │  ├── TemporalCore (CAN_TIME, CAN_SEQUENCE)   │  │
│  │  ├── DecisionCore (CAN_DECISION)             │  │
│  │  └── StateCore (CAN_STATE, CAN_TRANSITION)   │  │
│  └─────────────────────────────────────────────┘  │
├─────────────────────────────────────────────────────┤
│  COUCHE 1 : FONDATIONS                             │
│  ┌───────────┐  ┌───────────┐  ┌──────────────┐ │
│  │ TUV5       │  │ CANNoNICO  │  │ NAMBROCAHORA │ │
│  │ Compiler   │  │ Runtime    │  │ Time Ref     │ │
│  └───────────┘  └───────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────┘
```

---

## 3. COUCHE 1 — FONDATIONS

### 3.1 TUV5 (Knowledge Compiler)
- Entrée : Connaissance brute (16 formats)
- Sortie : Connaissance compacte CANNoNICO
- Cycle : Detect → Merge → Normalize → Validate → Compile → Publish
- Utilise NAMBROCAHORA pour tous ses timestamps

### 3.2 CANNoNICO (Runtime Representation)
- Entrée : TUV5 compilation output
- Sortie : Modèle interne CANNoNICO
- Rôle : Représentation unique pour tout raisonnement Runtime
- Contient les 14 primitives CANNoNICO

### 3.3 NAMBROCAHORA (Temporal Reference)
- Entrée : Temps machine (converti par TUV5)
- Sortie : INT64 ticks logiques
- Rôle : Référence temporelle unique de tout le Runtime
- Remplace Date(), ISO8601, Unix timestamps

---

## 4. COUCHE 2 — CONNAISSANCE CANONICAL

### 4.1 IdentityCore

| Responsabilité | Implémentation CANNoNICO |
|----------------|---------------------------|
| Générer les CAN_IDs | `can:<type>:<sha256>` |
| Résoudre les identités | Entity resolution via CAN_ID |
| Valider les identités | Checksum + type validation |
| Stocker les identités | CANNoNICO Identity Graph |

### 4.2 KnowledgeCore

| Responsabilité | Implémentation CANNoNICO |
|----------------|---------------------------|
| Stocker la connaissance | CAN_KNOWLEDGE entities |
| Gérer les relations | CAN_RELATION edges |
| Aligner les ontologies | Unified Ontology alignment |
| Compiler la connaissance | TUV5 pipeline |
| Versionner la connaissance | CAN_VERSION field |

### 4.3 TemporalCore

| Responsabilité | Implémentation CANNoNICO |
|----------------|---------------------------|
| Fournir le temps | NAMBROCAHORA ticks |
| Ordonner les événements | CAN_SEQUENCE |
| Garantir la causalité | Monotone tick ordering |
| Projeter le temps | ISO8601 / Unix via Projection Engine |

### 4.4 DecisionCore

| Responsabilité | Implémentation CANNoNICO |
|----------------|---------------------------|
| Prendre des décisions | CAN_DECISION entities |
| Justifier les décisions | CAN_Evidence links |
| Valider les décisions | Governance Core |
| Tracer les décisions | CAN_TRACE chain |

### 4.5 StateCore

| Responsabilité | Implémentation CANNoNICO |
|----------------|---------------------------|
| Gérer les états | CAN_STATE entities |
| Gérer les transitions | CAN_TRANSITION events |
| Persister les états | CANNoNICO Memory Store |
| Restaurer les états | Snapshot + tick recovery |

---

## 5. COUCHE 3 — EXÉCUTION CANONICAL

### 5.1 MissionOrchestrator

```
Mission (CANNoNICO Entity)
  │
  ▼
MissionOrchestrator
  │  ├── Prépare la mission via KnowledgeCore
  │  ├── Routage via DecisionCore
  │  ├── Exécution via TaskExecutor
  │  ├── Fusion des résultats via KnowledgeCore
  │  └── Validation via Governance Core
  │
  ▼
MissionResult (CANNoNICO Entity)
```

### 5.2 WorkflowEngine

```
Workflow (CANNoNICO Entity)
  │
  ▼
WorkflowEngine
  │  ├── DAG resolution via TemporalCore (CAN_SEQUENCE)
  │  ├── Parallel execution via ExecutionCore
  │  ├── Dependency tracking via CAN_RELATION
  │  ├── Error handling via DecisionCore
  │  └── State tracking via StateCore
  │
  ▼
WorkflowResult (CANNoNICO Entity)
```

### 5.3 TaskExecutor

```
Task (CANNoNICO Entity)
  │
  ▼
TaskExecutor
  │  ├── Charge la connaissance CANNoNICO
  │  ├── Exécute la capacité CANNoNICO
  │  ├── Produit un événement CANNoNICO (CAN_EVENT)
  │  ├── Met à jour l'état CANNoNICO (CAN_STATE)
  │  └── Enregistre le tick NAMBROCAHORA
  │
  ▼
TaskResult (CANNoNICO Entity)
```

### 5.4 DecisionEngine

```
Proposition (CANNoNICO Entity)
  │
  ▼
DecisionEngine
  │  ├── Charge les connaissances CANNoNICO pertinents
  │  ├── Évalue via CapabilityCore
  │  │  └── Sélection par scoring CANNoNICO
  │  ├── Produit une décision CANNoNICO (CAN_DECISION)
  │  ├── Enregistre le tick NAMBROCAHORA
  │  └── Publie la décision via KnowledgeCore
  │
  ▼
DecisionResult (CANNoNICO Entity)
```

---

## 6. COUCHE 4 — PROJECTION CANONICAL

### 6.1 ProjectionEngine

Le Projection Engine transforme le CANNoNICO en formats externes :

```
CANNoNICO Core (Couche 2)
  │
  ├──→ ProjectionEngine → Swift
  │     ├── Agent definitions (Swift structs)
  │     ├── Service implementations (Swift code)
  │     ├── Runtime bindings (Swift protocols)
  │     └── UI components (SwiftUI views)
  │
  ├──→ ProjectionEngine → JSON
  │     ├── API responses (REST)
  │     ├── WebSocket events
  │     └── Data exchange formats
  │
  ├──→ ProjectionEngine → Bash
  │     ├── Build scripts
  │     ├── Deployment commands
  │     └── Lifecycle scripts
  │
  ├──→ ProjectionEngine → Markdown
  │     ├── Architecture documentation
  │     ├── ADR documents
  │     └── Runbooks
  │
  └──→ ProjectionEngine → UI
        ├── Dashboard views
        ├── Runtime monitors
        └── Decision panels
```

### 6.2 Règles de Projection

| Règle | Description |
|-------|-------------|
| PR-01 | La projection ne modifie jamais le modèle CANNoNICO |
| PR-02 | La projection est toujours dérivée (pas autoritaire) |
| PR-03 | La projection est traçable vers sa source CANNoNICO |
| PR-04 | La projection utilise NAMBROCAHORA ticks pour la temporalité |
| PR-05 | La projection est générée à la demande, pas stockée comme autorité |
| PR-06 | La projection peut être lossy mais jamais créatrice de faux |

---

## 7. LE CANONICAL RUNTIME MODEL — COMPACTION DES EXISTANTS

### 7.1 Ce qui est absorbé

| Composant Existant | Absorbé Dans | Raison |
|--------------------|--------------|--------|
| SUPRA_RUNTIME_KERNEL.md | Couche 2-3 | Knowledge + Execution Core |
| SUPRA_WORKFLOW_V1.md | WorkflowEngine | Exécution CANNoNICO |
| SUPRA_ROUTER_SPECIFICATION_V1.md | DecisionEngine | Décision CANNoNICO |
| SUPRA_AI_LAB_ARCHITECTURE_V1.md | Couche 1-3 | Fondations + Connaissance |
| SUPRA_KNOWLEDGE_KERNEL.md | KnowledgeCore | Connaissance CANNoNICO |
| SUPRA_KNOWLEDGE_COMPILER.md | TUV5 (Couche 1) | Compilation |
| SUPRA_UNIFIED_ONTOLOGY.md | KnowledgeCore ontology alignment | Ontologie CANNoNICO |
| CANONICO_EXECUTIVE_REPORT.md | KnowledgeCore + IdentityCore | Identité + Graphe |
| CAnnoNicoContracts Swift | IdentityCore | Identité CANNoNICO |
| CAnnoNicoSnapshotStore | StateCore | État CANNoNICO |
| SUPRA_EXECUTION_PIPELINE.md | ExecutionCore | Pipeline CANNoNICO |
| SUPRA_GATE_SYSTEM.md | Governance Core | Gouvernance CANNoNICO |
| SUPRA_GOVERNANCE_* | Governance Core | Gouvernance CANNoNICO |
| SUPRA_RUNTIME_GRAPH.md | KnowledgeCore + TemporalCore | Graphe temporel CANNoNICO |
| SUPRA_EXECUTION_GATE.md | Couche 1-4 | Validation TUV5 + CANNoNICO |
| SUPRA_AGENT_REGISTRY_V1.md | IdentityCore | Agents comme identités CANNoNICO |
| SUPRA_MODEL_REGISTRY_V1.md | KnowledgeCore | Modèles comme connaissances CANNoNICO |
| CANONICO_ONTOLOGY.md | KnowledgeCore | Ontologie CANNoNICO |
| CAnnoNico_CONTINUITY_STANDARD.md | StateCore + TemporalCore | Continuité CANNoNICO |
| SUPRA_MASTER_INDEX.md | IdentityCore + KnowledgeCore | Index CANNoNICO |
| SUPRA_EXECUTION_GATE.md | Governance Core | Validation CANNoNICO |

### 7.2 Ce qui disparaît

| Composant Disparu | Raison |
|-------------------|--------|
| Registres dupliqués (Agent, Model, Capability, Plugin) | Remplacés par IdentityCore CANNoNICO |
| Projections ad hoc multiples | Remplacées par ProjectionEngine CANNoNICO |
| Timestamps système dispersés | Remplacés par NAMBROCAHORA |
| Adapters isolés (NicoApp, PucheroMemory, VideoSwap) | Remplacés par CANNoNICO Adapter générique |
| States éparses (MissionStatus, RuntimeState, etc.) | Remplacés par StateCore CANNoNICO |
| Décisions sans trace CANNoNICO | Remplacées par DecisionCore CANNoNICO |
| Mémoires multiples (MultiMemory, ConversationMemory, ExecutiveMemory) | Remplacées par MemoryCore CANNoNICO |

---

## 8. MODÈLE CANONIQUE — SCHÉMA GLOBAL

```
┌─────────────────────────────────────────────────────────────┐
│                    SUPRA CANONICAL RUNTIME                      │
│                                                                    │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │  COUCHE 4 : PROJECTION                                    │ │
│  │  ProjectionEngine → Swift / JSON / Bash / MD / UI / API │ │
│  └─────────────────────────────────────────────────────────┘ │
│                              ▲                                     │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │  COUCHE 3 : EXÉCUTION CANONICAL                          │ │
│  │  MissionOrchestrator + WorkflowEngine + TaskExecutor     │ │
│  │  + DecisionEngine + Governance Core                       │ │
│  └─────────────────────────────────────────────────────────┘ │
│                              ▲                                     │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │  COUCHE 2 : CONNAISSANCE CANONICAL                       │ │
│  │  IdentityCore | KnowledgeCore | RelationCore            │ │
│  │  TemporalCore (NAMBROCAHORA) | DecisionCore             │ │
│  │  StateCore | MemoryCore | ConstraintCore                │ │
│  └─────────────────────────────────────────────────────────┘ │
│                              ▲                                     │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │  COUCHE 1 : FONDATIONS                                    │ │
│  │  TUV5 (Knowledge Compiler)                               │ │
│  │  CANNoNICO (Canonical Runtime Representation)            │ │
│  │  NAMBROCAHORA (Canonical Time Reference)                 │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                                    │
│  ─────────────────────────────────────────────────────────────   │
│  Flux unique :                                                     │
│  Connaissance brute → TUV5 → CANNoNICO → Runtime → NAMBROCAHORA │
│                              ↓                                     │
│                       Projection Engine → Formats externes     │
│  ─────────────────────────────────────────────────────────────   │
└─────────────────────────────────────────────────────────────┘
```

---

## 9. LOIS FONDAMENTALES — CONFORMITÉ DU MODÈLE

| Loi | Conformité du Modèle | Mécanisme |
|-----|----------------------|-----------|
| Loi 1 : La connaissance > les fichiers | ✅ | TUV5 compile les fichiers en connaissance CANNoNICO |
| Loi 2 : Runtime raisonne en CANNoNICO | ✅ | Couche 2 = CANNoNICO exclusivement |
| Loi 3 : Runtime synchronise en NAMBROCAHORA | ✅ | TemporalCore = NAMBROCAHORA exclusivement |
| Loi 4 : TUV5 transforme complexité → connaissance | ✅ | TUV5 = Couche 1, premier maillon |
| Loi 5 : Nouvelles capacités enrichissent le Runtime | ✅ | Ajout de CANNoNICO entities, pas de nouvelles couches |

---

*Runtime Canonical Model V1 — SUPRA ULTIMATE CONSOLIDATED*
*Audit exécuté le 2026-07-29*
