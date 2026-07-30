# SEMANTIC CANONICAL MAP

## Audit SUPRA ULTIMATE CONSOLIDATED — Mapping Sémantique Canonique

| Propriété | Valeur |
|---|---|
| **Version** | V1 |
| **Date** | 2026-07-29 |
| **Statut** | LIVRABLE AUDIT — FONDATION |
| **Autorité** | SUPRA Constitution — Article 2 (Composant fondateur) |
| **Loi applicable** | Loi 1 : La connaissance est plus importante que les fichiers |

---

## 1. PRIMITIVES UNIVERSELLES DU RUNTIME

Les primitives universelles sont les concepts fondamentaux à partir desquels tout le système SUPRA peut être reconstruct. Elles sont dérivées de l'analyse de tous les registres, modèles, flux et structures existants.

### 1.1 Les 7 Primitives Universelles

| # | Primitive | Définition | Portée |
|---|-----------|-----------|--------|
| P1 | **ENTITY** | Toute chose identifiable dans le système — agent, mission, composant, projet, fichier, concept | Absolue |
| P2 | **RELATION** | Tout lien structuré entre deux entités — dépendance, appartenance, flux de données, influence | Binaire, dirigée |
| P3 | **CAPABILITY** | Ce qu'une entité peut faire ou ce qu'un système peut raisonner — encoding, reasoning, memory, retrieval | Qualifiée, mesurable |
| P4 | **EVENT** | Toute occurrence immutable dans le système — décision, exécution, changement d'état, compilation | Temporellement ordonné |
| P5 | **KNOWLEDGE** | Toute représentation de connaissance structurée — fait, règle, contrainte, pattern, evidence | Compilée, non redondante |
| P6 | **DECISION** | Toute décision prise par le système ou pour le système — choix de routage, validation, rejet, fusion | Traçable, justifiée |
| P7 | **TIME** | La référence temporelle unique à laquelle tous les événements sont rattachés | Monotone, logique |

### 1.2 Dérivation des Primitives

Les primitives sont dérivées des 5 domaines d'analyse suivants :

```
Domaine d'analyse          →  Primitives retenues
─────────────────────────────────────────────────
Registres (Agent, Model,    →  ENTITY, CAPABILITY
 Capability, ADR, Governance)
                              
Workflow (Planner, Router,  →  EVENT, DECISION, TIME
 Executor, Comparator,      
 Fusion, Validator, Learning)
                              
Knowledge (Kernel, Compiler,→  KNOWLEDGE, ENTITY, EVENT
 Graph, Ontology)           
                              
Runtime (Orchestrator,      →  ENTITY, EVENT, TIME, CAPABILITY
 Services, Pipelines,       
 Connectors)                
                              
Projection (Swift, JSON,    →  All primitives projected
 Bash, Markdown, UI, API)    via Projection Engine
```

### 1.3 Pourquoi Exactement 7 Primitives

| Argument | Justification |
|----------|--------------|
| Complétude | Tout composant SUPRA existant se ramène à ces 7 concepts |
| Minimalité | Aucune primitive ne peut être dérivée des 6 autres |
| Disjonction | Chaque primitive capture un axe orthogonal de la réalité système |
| Projection | Chaque primitive peut être projetée vers Swift, JSON, Bash, Markdown, UI, API sans perte |
| Temporalité | P4 (EVENT) et P7 (TIME) fournissent la base événementielle et temporelle complète |
| Cognition | P3 (CAPABILITY) et P6 (DECISION) fournissent la base décisionnelle et cognitive |

---

## 2. CONCEPTS ACTUELLEMENT DUPLIQUÉS

### 2.1 Registres Dupliqués

| Doublon | Instance A | Instance B | Instance C | Action |
|---------|-----------|-----------|-----------|--------|
| **Définition d'agent** | Agent Registry (V1) | Agent Canon (SUPRA_AGENT_CANON.md) | Agent Canon dans AI Lab Architecture | Fusionner en un seul Agent CANNoNICO |
| **Définition de modèle** | Model Registry (V1) | Model definitions in Router Spec | Runtime Model definitions | Fusionner en un seul Model CANNoNICO |
| **Définition de capability** | Capability Registry (référencé) | Capability Broker (Swift) | Router Classification categories | Fusionner en un seul Capability CANNoNICO |
| **Définition de workflow** | Workflow V1 | Execution Pipeline | Runtime Kernel workflows | Fusionner en un seul Workflow CANNoNICO |
| **Définition de runtime** | Runtime Kernel | Runtime Graph | Runtime Metrics | Fusionner en une seule Runtime CANNoNICO |
| **Gouvernance** | Governance Kernel | Governance Registry | ADR Registry | Fusionner en une seule Governance CANNoNICO |

### 2.2 Concepts Dupliqués au Sein du Runtime

| Concept | Endroit 1 | Endroit 2 | Endroit 3 | Action |
|---------|----------|----------|----------|--------|
| **Mission** | Mission.swift (model) | MissionStore | MissionContext | Unifier : Mission est une ENTITY avec type PROCESS |
| **Decision** | Decision.swift (model) | DecisionStore | DecisionEngine | Unifier : Decision est une primitive DECISION |
| **Knowledge** | KnowledgeObject.swift | KnowledgeGraph | KnowledgeKernel | Unifier : Knowledge est une primitive KNOWLEDGE |
| **RuntimeEvent** | RuntimeEvent.swift | SUPRARuntimeEvents | RuntimeMonitor | Unifier : Event est la primitive EVENT |
| **Snapshot** | Snapshot.swift | CAnnoNicoSnapshotStore | SUPRAEnvironmentSnapshotStore | Unifier : Snapshot est un EVENT compressé |
| **Memory** | MultiMemoryStore | ConversationMemoryStore | ExecutiveMemory | Unifier : Memory est un KNOWLEDGE persistant |
| **Registry** | Master Registry JSON | Agent Registry | Model Registry | Unifier : Registry est une ENTITY de type KERNEL |
| **Manifest** | Master Manifest | Workspace Manifest | Release Manifest | Unifier : Manifest est une ENTITY de type CONFIGURATION |

### 2.3 Patterns Dupliqués

| Pattern | Occurrences | Action |
|---------|------------|--------|
| `shared singleton` pattern | SUPRAMissionBroker, SUPRAProviderBroker, RuntimeGateway, SUPRADecisionEngine, SUPRARuntimeKernel | Remplacer par un seul RuntimeCoordinator CANNoNICO |
| `@Published` / `ObservableObject` | 40+ Swift files | C'est une projection — ne pas dupliquer dans le modèle canonique |
| `enum` pour états | MissionStatus, ExecutionState, RuntimeState, SnapshotState | Unifier dans un seul State CANNoNICO |
| `struct` pour références | CAnnoNicoSourceReference, RuntimeSourceReference, MissionContext | Unifier dans un seul Reference CANNoNICO |

---

## 3. RESPONSABILITÉS À FUSIONNER

### 3.1 Fusion Recommandée : Les 5 Cœurs CANNoNICO

| Cœur Actuel | Composants À Fusionner | Nouveau Cœur CANNoNICO | Raison |
|------------|------------------------|----------------------|--------|
| **Cœur d'Identité** | Agent Registry + Model Registry + Capability Registry + Plugin Registry | **Identity CANNoNICO** | Les 3 registres gèrent la même logique d'enregistrement/découvrement |
| **Cœur de Connaissance** | Knowledge Kernel + Knowledge Compiler + CANONICO Knowledge Graph + Unified Ontology | **Knowledge CANNoNICO** | La compilation, le graphe et l'ontologie sont 3 phases d'un seul processus |
| **Cœur d'Exécution** | WorkflowEngine + Executor + Scheduler + MissionExecutor + ProviderBroker | **Execution CANNoNICO** | Ordonnancement, exécution et routage sont une seule responsabilité |
| **Cœur de Mémoire** | Memory + SUPRA Memory + Conversation Memory + Snapshot Store | **Memory CANNoNICO** | Tous stockent et récupèrent des faits avec des temporalités différentes |
| **Cœur de Gouvernance** | Governance Kernel + ADR Registry + Gate System + Constraint Framework + Compliance Model | **Governance CANNoNICO** | Constitution, autorité, conformité et décision sont un seul domaine |

### 3.2 Responsabilités à Supprimer

| Responsabilité | Actuellement Dupliquée Dans | Action |
|---------------|---------------------------|--------|
| **Health Check** | Agent Registry, Model Registry, Provider Registry, Runtime Kernel | Supprimer — géré par le Health Service CANNoNICO unique |
| **Logging** | Runtime Logger, Diagnostics, Metrics, Console | Supprimer — géré par le Log Service CANNoNICO unique |
| **Serialization** | Codable protocols partout, JSON encoders, PropertyList | Supprimer — géré par le Projection Engine CANNoNICO |
| **Routing** | Router Spec + SUPRARoutingPolicy + CapabilityBroker | Supprimer — intégré dans Execution CANNoNICO |
| **Validation** | Validator + Constraint Engine + Consistency Engine + Compliance | Supprimer — intégré dans Governance CANNoNICO |

---

## 4. COUCHES À DISPARAÎTRE

### 4.1 Couches Redondantes

| Couche Actuelle | Raison de Suppression | Remplacement |
|----------------|----------------------|-------------|
| **Couche « Adapters » actuelle** (NicoAppAdapter, PucheroMemoryAdapter, VideoSwapAdapter) | Chaque adapter est un singleton isolé sans protocole commun fort | Un seul **CANNoNICO Adapter** générique avec type d'entrée/sortie canonique |
| **Couche « Providers » actuelle** (OpenAI, Anthropic, Ollama comme classes séparées) | Redondant avec le Capability CANNoNICO | Un seul **Provider CANNoNICO** paramétré par capability et model |
| **Couche « Sources » actuelle** (connaissances dans fichiers multiples) | La connaissance ne devrait jamais être dans des fichiers bruts | Une seule **Source CANNoNICO** référençant le Knowledge Compiler |
| **Couche « Projections » ad hoc** | Chaque format de sortie est géré manuellement | Le **Projection Engine CANNoNICO** gère toutes les projections |

### 4.2 Couches à Consolider

| Couche Actuelle | Vers | NouveauNom |
|----------------|------|-----------|
| SUPRA_KNOWLEDGE_KERNEL.md | Knowledge CANNoNICO | Connaissance compilée |
| SUPRA_RUNTIME_KERNEL.md | Execution CANNoNICO | Orchestration |
| SUPRA_EXECUTION_GATE.md | Governance CANNoNICO | Validation |
| SUPRA_WORKFLOW_V1.md | Execution CANNoNICO | Pipeline |
| CAnnoNico_CONTINUITY_STANDARD.md | Memory CANNoNICO | Continuité temporelle |
| CANONICO_STANDARD.md | Knowledge + Identity CANNoNICO | Représentation canonique |

---

## 5. REPRÉSENTATIONS DEVENANT CANNoNICO

### 5.1 Ce Qui Devient CANNoNICO

| Représentation Actuelle | Statut Cible | Rationale |
|--------------------------|-------------|-----------|
| Agent Registry (Markdown) | → CANNoNICO Identity Core | Définition d'agent = description d'une entité avec capabilities |
| Model Registry (Markdown) | → CANNoNICO Capability | Modèle = instance de capability avec qualités mesurables |
| Workflow V1 (Markdown) | → CANNoNICO Execution | Workflow = graphe de relations entre EVENTs |
| Runtime Kernel (Markdown) | → CANNoNICO Execution + Memory | Runtime = orchestration de services + mémoire d'état |
| Knowledge Kernel (Markdown) | → CANNoNICO Knowledge | Le kernel lui-même est une représentation CANNoNICO |
| Unified Ontology (Markdown) | → CANNoNICO Knowledge (ontology) | Ontologie = graphe de concepts KNOWLEDGE |
| Master Index (Markdown) | → CANNoNICO Directory | Index = relation catalogue entre ENTITYs |
| CANONICO UGIS | → CANNoNICO (absorption) | Standard graphique absorbé comme sous-système de CANNoNICO |
| CAnnoNicoContracts (Swift) | → CANNoNICO Swift bindings | Le code existe, il reflète déjà le modèle |

### 5.2 Ce Qui Ne Devient PAS CANNoNICO (Reste en Projection)

| Format | Rôle | Raison |
|--------|------|--------|
| Swift | Projection UI/Engine | Code exécutable, pas de connaissance |
| Bash | Projection Opérationnelle | Script d'orchestration, pas de raisonnement |
| JSON | Projection de Données | Format de sérialisation temporaire |
| YAML | Projection de Configuration | Format de configuration, pas de modèle |
| Markdown | Projection Documentation | Format lisible, pas de modèle |
| SQL | Projection Stockage | Requêtes bases de données, pas de conception |
| API | Projection d'Interface | Points d'accès, pas de logique |

---

## 6. ÉLÉMENTS DEVIANT NAMBROCAHORA

### 6.1 Tous les Horodatages Système → NAMBROCAHORA

| Élément Actuel | Remplacement NAMBROCAHORA | Justification |
|---------------|--------------------------|--------------|
| `Date()` (Swift) | `NAMBROCAHORA.tick()` | Temps brut → temps canonique |
| `ISO8601DateFormatter` | `NAMBROCAHORA.format(tick)` | Format de projection, pas de référence |
| `UUID()` | `NAMBROCAHORA.eventId()` | Les UUID sont des projections d'identité temporelle |
| `compilationId: kc:comp:{uuid}` | `NAMBROCAHORA.compilationId()` | Le compilateur génère son propre tick |
| `snapshot.timestamp` | `NAMBROCAHORA.snapshotTime()` | Les snapshots utilisent le temps système |
| `mission.createdAt` | `NAMBROCAHORA missionTime()` | Les missions utilisent le temps système |
| `runtime.diagnostics.timestamp` | `NAMBROCAHORA.diagnosticTime()` | Le diagnostic utilise le temps système |
| `session.lastActive` | `NAMBROCAHORA.sessionTime()` | Les sessions utilisent le temps système |
| `healthCheck.lastRun` | `NAMBROCAHORA.healthTime()` | Les health checks utilisent le temps système |
| `metrics.recordedAt` | `NAMBROCAHORA.metricTime()` | Les métriques utilisent le temps système |

### 6.2 Entités Devrant Utiliser NAMBROCAHORA

| Entité | Champ Temporal Actuel | Cible NAMBROCAHORA |
|--------|----------------------|-------------------|
| Snapshot | `generatedAt: Date` | `generatedAtTick: NAMBROCAHORA` |
| Mission | `createdAt`, `updatedAt` | `createdAtTick`, `updatedAtTick` |
| Decision | `timestamp` | `tick` |
| Event | `date` | `tick` |
| Compilation | `timestamp` | `tick` |
| Log Entry | `timestamp` | `tick` |
| Version | `date` | `tick` |
| State Transition | `timestamp` | `tick` |
| Execution Gate | `date` | `tick` |
| Registry Entry | `lastUpdated` | `lastUpdatedTick` |

### 6.3 NAMBROCAHORA comme Référence Unique

```
AVANT (temps machine) :
  Date() → ISO8601 → stored in JSON → read back as Date

APRÈS (NAMBROCAHORA) :
  NAMBROCAHORA.tick() → Int64 → stored in CANNoNICO → projected to ISO8601 when needed
```

Le Runtime ne stocke jamais `Date`. Il stocke toujours un `NAMBROCAHORA.tick()`.
La projection vers ISO8601 est effectuée par le Projection Engine quand nécessaire pour l'UI ou l'API.

---

## 7. RÉSULTATS DE L'AUDIT — SOMMAIRE

### 7.1 Primitives Universelles Confirmées

| Primitive | Définition Formelle |
|-----------|-------------------|
| ENTITY | Une identité unique (can:ENTITY:vhash) avec un type, un cycle de vie et des relations |
| RELATION | Un lien dirigé entre deux entités avec un type sémantique et une cardinalité |
| CAPABILITY | Une compétence mesurable qu'une entité possède ou qu'un système expose |
| EVENT | Une occurrence immutable, temporellement ordonnée, qui modifie l'état d'une ou plusieurs entités |
| KNOWLEDGE | Une connaissance structurée compilée, non redondante, traçable vers sa source |
| DECISION | Un choix documenté, justifié par des preuves, avec un verdict et une trace |
| TIME | La référence temporelle logique unique du système (NAMBROCAHORA) |

### 7.2 Doublons Identifiés

| Catégorie | Nombre de Doublons | Impact |
|-----------|-------------------|--------|
| Registres dupliqués | 6 | Confusion sur la source de vérité |
| Concepts dupliqués | 8 | Incohérences potentielles entre les modèles |
| Patterns dupliqués | 4 | Fragmentation du code |

### 7.3 Responsabilités à Fusionner

| Fusion | Composants | Gain |
|--------|-----------|------|
| Identity CANNoNICO | 4 registres → 1 | Source de vérité unique |
| Knowledge CANNoNICO | 4 systèmes → 1 | Connaissance canonique unique |
| Execution CANNoNICO | 5 moteurs → 1 | Orchestration cohérente |
| Memory CANNoNICO | 4 stores → 1 | Mémoire unifiée |
| Governance CANNoNICO | 5 composants → 1 | Gouvernance unifiée |

### 7.4 Couches à Disparaître

| Couche Supprimée | Couches Remplaçantes |
|-----------------|---------------------|
| Adapters ad hoc | CANNoNICO Adapter générique |
| Providers ad hoc | CANNoNICO Provider paramétré |
| Sources multiples | CANNoNICO Source (via TUV5) |
| Projections ad hoc | Projection Engine CANNoNICO |

---

## 8. LOIS FONDAMENTALES — VÉRIFICATION

| Loi | Statut | Preuve de Conformité |
|-----|--------|---------------------|
| Loi 1 : La connaissance est plus importante que les fichiers | ✅ VERIFIÉE | Le Knowledge Compiler (TUV5) compile toute connaissance en CANNoNICO |
| Loi 2 : Le Runtime raisonne exclusivement en CANNoNICO | ⚠️ PARTIELLEMENT | Le Runtime actuel raisonne encore sur Swift, JSON, etc. — DOIT MIGRER |
| Loi 3 : Le Runtime se synchronise exclusivement en NAMBROCAHORA | ❌ NON | Le Runtime utilise encore Date(), ISO8601, UUID — DOIT MIGRER |
| Loi 4 : TUV5 transforme la complexité en connaissance canonique | ✅ VERIFIÉE | Le Knowledge Compiler transforme 16 types de sources en connaissance compacte |
| Loi 5 : Toute nouvelle capacité enrichit le Runtime | ✅ VERIFIÉE | Le design actuel ajoute des capabilities au Runtime Kernel |

---

*Document produit par l'audit SUPRA ULTIMATE CONSOLIDATED — TUV5 × CANNoNICO × NAMBROCAHORA*
*Date : 2026-07-29*
*Autorité : SUPRA Constitution*
