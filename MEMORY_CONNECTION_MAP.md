# MEMORY_CONNECTION_MAP.md

**Mission**: SUPRA_MEMORY_LINK_DISCOVERY_V1  
**Date**: 2026-07-24  
**Mode**: READ ONLY — Aucune modification  
**Objectif**: Prouver exactement ce qui est disponible pour connecter la mémoire conversationnelle à l'écosystème SUPRA.

---

## 1. CONVERSATIONS.JSON

| Attribut | Valeur |
|----------|--------|
| Fichier existant | **NON** — aucun `conversations.json` dans le workspace |
| Emplacement attendu | `~/NOVA_OS/SUPRA/` ou `~/NOVA_OS/SUPRA/SUPRA/` |
| Importateur existant | **ConversationMemoryStore.swift** (créé mission SUPRA_CONVERSATION_MEMORY_TWIN_V1) |
| Parser existant | Oui — ChatGPT export JSON format (mapping → messages par UUID) |
| Indexeur existant | Oui — date, titre, messages, tags, projets, décisions, missions, freezes, preuves |
| Stockage | `~/NOVA_OS/SUPRA/SUPRA_Conversations/ConversationMemoryIndex.json` |

### CONCLUSION conversations.json
> **MANCANT** : le fichier source `conversations.json` n'existe pas encore dans le workspace. L'infrastructure de parsing et d'indexation existe dans `ConversationMemoryStore.swift`. Il suffit de placer un export ChatGPT JSON à la racine du projet pour que le système le détecte.

---

## 2. ARTIFACTS EXISTANTS

### 2.1 Rapports SUPRA (mémoire textuelle)

| Source | Fichier | Type | Adapter Existant | Destination | Format | Risque | Manque |
|--------|---------|------|------------------|-------------|--------|--------|--------|
| Mission report | `SUPRA_EXECUTIVE_COCKPIT_V1_REPORT.md` | Markdown | `ConversationKnowledgeProvider.discover()` | KnowledgeGraph (objet `report`) | Markdown → KnowledgeObject | Faible — déjà indexé | Indexation du contenu texte |
| Mission report | `SUPRA_EXECUTIVE_COCKPIT_V2_REPORT.md` | Markdown | Même provider | idem | idem | Idem | Idem |
| Mission report | `SUPRA_EXECUTIVE_COCKPIT_V3_REPORT.md` | Markdown | Même provider | idem | idem | Idem | Idem |
| Mission report | `SUPRA_WORKSPACE_INTELLIGENCE_V1_REPORT.md` | Markdown | Même provider | idem | idem | Idem | Idem |

### 2.2 Snapshots runtime (données structurées)

| Source | Fichier | Type | Adapter Existant | Destination | Format | Risque | Manque |
|--------|---------|------|------------------|-------------|--------|--------|--------|
| Runtime data | `CONTROL_TOWER_STATUS.json` | JSON | `ControlTowerState.load()` | SUPRAEnvironmentWorldModel | JSON → CompleteEnvironmentState | Faible | Pas de lien vers conversations |
| Runtime metrics | `metrics.json` | JSON | `RuntimeMetrics` (existe) | DashboardView | JSON → StatCard | Faible | Pas de lien vers mémoire |
| Agent execution | `agent_execution.json` | JSON | `AgentExecution` (existe) | RuntimeView | JSON → agent tracking | Faible | Pas de lien conversationnel |
| Queue metrics | `queue_metrics.json` | JSON | `MissionStore` | MissionCenter | JSON → mission queue | Faible | Pas de lien conversationnel |
| Dependency graph | `SUPRA_DEPENDENCY_GRAPH.json` | JSON | `ArtifactReader` | Build système | JSON → module graph | N/A | Outil, pas mémoire |
| Environment twin metrics | `Artifacts/SUPRA_ENVIRONMENT_TWIN_METRICS.json` | JSON | `SUPRAEnvironmentResolver` | Twin views | JSON → stat cards | Faible | Pas de lien conversationnel |
| Top-level metrics | `metrics.json` | JSON | `ArtifactReader` | Divers | JSON → métriques | Faible | Pas de lien conversationnel |
| Routing trace | `routing_trace.json` | JSON | `SUPRARouter` | Logs | JSON → trace | N/A | Pas mémoire |
| Consensus | `consensus_report.json` | JSON | `AgentRegistry` | Preuve décision | JSON → rapport | Faible | Pas de lien conversationnel |

### 2.3 Freezes / Preuves (mémoire pérenne)

| Source | Fichier | Type | Adapter Existant | Destination | Format | Risque | Manque |
|--------|---------|------|------------------|-------------|--------|--------|--------|
| Freeze architecture | `FREEZE_REGISTRY.json` | JSON | `FREEZE_SUPRA_FUNCTIONAL_AUTHORITY_*` | Décisions | JSON → index | N/A — structure de registry | Aucun lien vers conversations |
| Freeze architecture | `FREEZE_SUPRA_ARCHITECTURE_INDEX_20260723T104017Z/` | JSON | Même pattern | Décisions | JSON → archive | N/A — archive gel | Aucun lien vers conversations |
| Freeze rapport | `FREEZE_SUPRA_RUNTIME_PROOF_20260723T120605Z/` | JSON | Même pattern | Preuve runtime | JSON → preuve | N/A — preuve gel | Aucun lien vers conversations |
| Freeze exécution | `SUPRA_FUNCTIONAL_AUTHORITY_RECONCILED.json` | JSON | Même pattern | Décisions | JSON → versionnage | N/A — versionnage gel | Aucun lien vers conversations |

### 2.4 Config / Références

| Source | Fichier | Type | Adapter Existant | Destination | Format | Risque | Manque |
|--------|---------|------|------------------|-------------|--------|--------|--------|
| Autorité connaissance | `knowledge_authority.json` | JSON | `KnowledgeAuthority` conçu pour | KG / décision | JSON → autorité | Faible — pas connecté au store | Aucun parseur d'export ChatGPT |
| Identité connaissance | `knowledge_identity.json` | JSON | `KnowledgeIdentity` conçu pour | KG / identité | JSON → identité | Idem | Idem |
| Lignage connaissance | `knowledge_lineage.json` | JSON | `KnowledgeLineage` conçu pour | KG / relations | JSON → lignage | Idem | Idem |
| Kernel connaissance | `knowledge_kernel.json` | JSON | `NOVAKnowledgeKernel` (existe) | Toute la mémoire | JSON → noyau | Faible — pas lié aux conversations | Index conversationnel absent |
| Foundation mémoire | `_FOUNDATION_MEMORY/FOUNDATION_MEMORY.md` | Markdown | Aucun — documentation | Référence | Texte → aucun parseur | Aucun parseur activé | Idem |
| Architecture mémoire | `_FOUNDATION_MEMORY/ARCHITECTURE_MAP.md` | Markdown | Aucun — documentation | Référence | Texte → aucun parseur | Idem | Idem |
| Système topology | `_FOUNDATION_MEMORY/SYSTEM_TOPOLOGY.md` | Markdown | Aucun — documentation | Référence | Idem | Idem | Idem |

---

## 3. MEMORY MODULES EXISTANTS

### 3.1 ConversationMemoryStore (créé V1)

| Attribut | Valeur |
|----------|--------|
| Fichier | `SUPRA/SUPRA/ConversationMemoryStore.swift` |
| Rôle | Import, parse, index de conversations ChatGPT |
| Entrées | `conversations.json` (export ChatGPT) |
| Sorties | `[ConversationRecord]` indexé, `ConversationMemoryIndex.json` |
| Format | JSON Codable (`ConversationRecord`, `ConversationMessage`, `ConversationSummary`) |
| Connextions | `KnowledgeGraph` (via `connectToKnowledgeGraph()`), `SUPRAPassiveRefreshCoordinator` (auto-refresh 90s) |
| Statut | **Opérationnel** — import et index fonctionnels |
| Risque | Aucun écrasement — versionnage automatique |

### 3.2 MultiMemoryStore

| Attribut | Valeur |
|----------|--------|
| Fichier | `SUPRA/MultiMemoryStore.swift` |
| Rôle | Agrégateur de 5 sources mémoire (CAnnoNico, Projects, Runtime, Missions, FileSystem) |
| Entrées | `PROJECT_REGISTRY.json`, `ENVIRONMENT_INDEX.json`, `CAnnoNicoSnapshotStore`, `MissionStore` |
| Sorties | `MultiMemorySnapshot` (@Published) |
| Format | JSON → `MultiMemorySnapshot(memories: [MemorySourceInfo])` |
| Connexions | `CAnnoNicoSnapshotStore.$state`, `MissionStore.$missions` (Combine sinks) |
| Statut | **Opérationnel** |
| Risque | Aucun — read-only agrégateur |

### 3.3 WorkspaceMemoryStore

| Attribut | Valeur |
|----------|--------|
| Fichier | `SUPRA/WorkspaceMemory.swift` |
| Rôle | Historique des événements workspace (scan, création, modification) |
| Entrées | `WorkspaceObject`, `WorkspaceIndex` events |
| Sorties | `workspace_memory.json` |
| Format | JSON Codable (`WorkspaceMemory`, `WorkspaceMemoryEntry`) |
| Connexions | `WorkspaceObject` events (recordEvent, recordScan) |
| Statut | **Opérationnel** |
| Risque | Aucun — écriture append-only |
| Manque | **Aucune connexion aux conversations** — WorkspaceMemory et ConversationMemory sont des silos indépendants |

### 3.4 ExecutiveMemory

| Attribut | Valeur |
|----------|--------|
| Fichier | `SUPRA/ExecutiveMemory.swift` |
| Rôle | Mémoire structurée du cockpit exécutif |
| Entrées | `MemoryQuery` (filtrer/rechercher) |
| Sorties | `MemoryEntry[]` |
| Format | Codable struct |
| Connexions | `ExecutiveSearch`, `ExecutiveCockpitFoundation` |
| Statut | **Opérationnel** |
| Risque | Aucun |
| Manque | **Aucune connexion aux conversations** |

### 3.5 Memory View

| Attribut | Valeur |
|----------|--------|
| Fichier | `SUPRA/MemoryView.swift` |
| Rôle | Vue UI pour CAnnoNico Memory |
| Titre | "CAnnoNico Memory" |
| Connexions | `SUPRAOSCard` (DesignSystem) |
| Statut | **Opérationnel** |
| Manque | **Aucun lien avec ConversationMemoryStore** — affiche uniquement CAnnoNico sources |

---

## 4. KNOWLEDGE MODULES EXISTANTS

### 4.1 KnowledgeGraph

| Attribut | Valeur |
|----------|--------|
| Fichier | `SUPRA/KnowledgeGraph.swift` |
| Rôle | Graphe d'objets de connaissance avec relations |
| Types d'objets | `KnowledgeObjectType` inclut déjà `.conversation` et `.message` |
| Types de sources | `KnowledgeSourceType` inclut déjà `.conversation` |
| Connexions | `KnowledgeProvider` protocol (5 providers), `KnowledgeRelation` (28 types dont `conversationAbout`, `decisionFor`, `evidenceFor`, `freezeOf`...) |
| Format | `@Published var objects: [KnowledgeObject]`, `@Published var relations: [KnowledgeRelation]` |
| Statut | **Opérationnel** |
| Manque | **Pas encore connecté à ConversationMemoryStore** — `connectToKnowledgeGraph()` est prévu mais n'est pas appelée au lancement |

### 4.2 ConversationKnowledgeProvider

| Attribut | Valeur |
|----------|--------|
| Fichier | `SUPRA/ConversationKnowledgeProvider.swift` |
| Rôle | Provider de connaissances — scanne les fichiers de conversation locaux |
| Entrées | `~/Library/Application Support/com.openai.chat`, `SUPRA_*.md`, fichiers avec marqueurs CHAT/conversation |
| Sorties | `KnowledgeObject[]` (conversations trouvées + reports SUPRA) |
| Tags utilisés | `chatgpt`, `conversation`, `openai`, `report`, `mission`, `supra` |
| Connexions | `KnowledgeGraph` (via `registerProvider`) |
| Statut | **Partiellement opérationnel** — scanne mais ne lit pas le contenu des conversations (metadonnées uniquement) |
| Manque | **Aucun lien avec `ConversationMemoryStore`** — utilise le même principe de découverte mais ne partage pas les données indexées |

### 4.3 KnowledgeObject (type conversation)

| Attribut | Valeur |
|----------|--------|
| `type: .conversation` | Existe dans `KnowledgeObjectType` |
| `source: "conversation"` | Existe dans `KnowledgeSourceType` |
| `ConversationKnowledgeProvider` | Produit déjà des objets `type: .conversation` |
| `KnowledgeGraph.objects` | Peut contenir des objets conversation — `connectToKnowledgeGraph()` est le pont manquant |

---

## 5. CANONICO (CAnnoNico) PATTERNS

### 5.1 CAnnoNico Contracts (Package)

| Attribut | Valeur |
|----------|--------|
| Package | `CAnnoNicoIntegrationPackage` (5 cibles) |
| Contracts | `CAnnoNicoContracts.swift` — protocol `CAnnoNicoAdapter` + structs `CAnnoNicoSourceReference`, `CAnnoNicoIntegrationSnapshot` |
| Adapter pattern | Chaque adapter implémente `snapshot() -> CAnnoNicoSourceReference` avec `id`, `role`, `path`, `state`, `inputs`, `outputs`, `capabilities` |
| Règle clé | `NO_DATA_DUPLICATION`, `NO_ENGINE_RECREATION` — lecture seule uniquement |
| Connexions existantes | `CAnnoNicoSnapshotStore`, `CAnnoNicoIntegrationBridge`, mémoires MultiMemoryStore |
| Statut | **Stable et contractuel** |

### 5.2 Adapters existants

| Adapter | ID | Rôle | Inputs | Outputs | Entrées mémoire |
|---------|-----|------|--------|---------|-----------------|
| `PucheroMemoryAdapter` | `puchero.memory` | READ_ONLY_MEMORY_AND_LINEAGE | canonical_queries, evidence_requests | memory_references, proof_lineage | **Oui** — READ EXISTING MEMORY |
| `NicoAppAdapter` | `nico.app` | HUMAN_INTERFACE_AND_PERSONAL_CONTEXT | human_context, case_selection, decision_requests | human_views, case_context, decision_feedback | Non |
| `VideoSwapAdapter` | `video.swap` | MEDIA_TRANSFORMATION_MODULE | video, face_reference, creative_prompt | rendered_video, render_proof, job_history | Non |

### 5.3 CAnnoNicoObject (type conversation)

| Attribut | Valeur |
|----------|--------|
| `CAnnoNicoType.conversation` | Existe dans `CAnnoNicoObject.swift:42` |
| `CAnnoNicoSource.conversation` | Existe dans `CAnnoNicoSource.swift:53` |
| `CAnnoNicoSnapshotStore` | Stocke les références avec `source: .conversation` possible |
| Connexion | `CAnnoNicoIntegrationBridge` → `snapshot()` combine les 3 adapters |
| Manque | **ConversationMemoryStore ne passe pas par CAnnoNico contracts** — c'est un store séparé |

---

## 6. REGISTRIES

### 6.1 Registres existants utilisables pour la connexion mémoire

| Registry | Fichier | Adapter Existant | Format | Usage possible | Risque | Manque |
|----------|---------|------------------|--------|----------------|--------|--------|
| MODULE_REGISTRY | `MODULE_REGISTRY.json` | ModuleRegistrar (existant) | JSON | Indexer les conversations comme modules | Faible | Pas de champ `conversation` dans modules |
| CANONICAL_WORKERS | `CANONICAL_WORKERS.json` | WorkerRegistry (existant) | JSON | Référencer ConversationMemoryStore comme worker | Moyen — nécessite nouvel worker ID | Aucun worker mémoire conversationnel |
| PROJECT_REGISTRY | `PROJECT_REGISTRY.json` | MultiMemoryStore.loadRegistries() | JSON | Associer conversations à projets existants | Faible | Pas de champ conversation |
| SUPRA_Workspace_Registry | `SUPRA_Workspace_Registry.json` | Existe | JSON | Métadonnées workspace | Idem | Idem |
| twin_registry | `twin_registry.json` | TwinRegistry (existant) | JSON | Référencer conversations comme twins | Moyen | Aucun twin conversationnel |
| UNIVERSE_REGISTRY | `universe_registry.json` | Existe | JSON | Idem | Idem | Idem |
| DUPLICATE_REGISTRY | `DUPLICATE_REGISTRY.json` | Existe | JSON | Non pertinent | N/A | N/A |
| FREEZE_REGISTRY | `FREEZE_REGISTRY.json` | Existe | JSON | Non pertinent pour connexion active | N/A | N/A |
| PACKAGE_REGISTRY | `PACKAGE_REGISTRY.json` | Existe | JSON | Non pertinent | N/A | N/A |

---

## 7. SYNTHÈSE DES CONNEXIONS EXISTANTES

### Ce qui EST connecté (réutilisable)

```
ConversationMemoryStore
  ├── SUPRAPassiveRefreshCoordinator (auto-refresh 90s, déjà intégré)
  ├── KnowledgeGraph (connectToKnowledgeGraph() existe mais non appelée au boot)
  ├── ConversationKnowledgeProvider (même principe de scan, pas de partage)
  └── ConversationTwinView (UI déjà construite)

ConversationKnowledgeProvider
  ├── KnowledgeGraph (via registerProvider())
  └── Scanne fichiers locaux (pas de partage avec ConversationMemoryStore)

CAnnoNicoContracts
  ├── CAnnoNicoAdapter protocol (READ_ONLY, stable)
  ├── CAnnoNicoSnapshotStore (connecté à MultiMemoryStore)
  └── Conventions de source-reference (réutilisables pour conversations)

CAnnoNicoSnapshotStore
  ├── MultiMemoryStore (sink Combine)
  └── CAnnoNicoIntegrationBridge (snapshot)
```

### Connecteurs MANQUANTS (points de fusion nécessaires)

| # | Manque | Source | Destination | Solution Existent | Risque | Priorité |
|---|--------|--------|-------------|-------------------|--------|----------|
| 1 | ConversationMemoryStore ne partage pas ses données avec KnowledgeGraph au boot | `ConversationMemoryStore` | `KnowledgeGraph` | `connectToKnowledgeGraph()` existe dans le store — il suffit de l'appeler au `start()` | Faible | **Critique** |
| 2 | ConversationMemoryStore ne s'enregistre pas comme KnowledgeProvider | `ConversationMemoryStore` | `KnowledgeGraph.registerProvider()` | Créer un `ConversationKnowledgeProvider` qui délègue à `ConversationMemoryStore` — pas de nouveau moteur | Moyen | **Haute** |
| 3 | ConversationKnowledgeProvider ne partage pas ses découvertes avec ConversationMemoryStore | `ConversationKnowledgeProvider` | `ConversationMemoryStore` | `ConversationKnowledgeProvider` lit les mêmes fichiers — fusionner les deux en un seul scanner | Faible | **Moyenne** |
| 4 | MultiMemoryStore ne connaît pas les conversations | `ConversationMemoryStore` | `MultiMemoryStore` | Ajouter un `conversation` MemorySourceInfo dans `rebuild()` — réutilise le pattern existant | Faible | **Moyenne** |
| 5 | MemoryView n'affiche pas les conversations | `MemoryView` | `ConversationMemoryStore` | Connecter `MemoryView` à `@ObservedObject var store = ConversationMemoryStore.shared` | Faible | **Basse** |
| 6 | WorkspaceMemoryStore et ConversationMemoryStore sont silos | `WorkspaceMemoryStore` | `ConversationMemoryStore` | Aucun connecteur — mais pas critique car ils sont complémentaires (workspace events vs conversations) | N/A | Basse |
| 7 | ExecutiveMemory n'est pas connecté aux conversations | `ConversationMemoryStore` | `ExecutiveMemory` | Aucun connecteur — mais les conversations peuvent enrichir ExecutiveMemory via tags | N/A | Basse |
| 8 | CAnnoNicoContracts ne gère pas les conversations comme adapter | `CAnnoNicoContracts` | `ConversationMemoryStore` | Créer un `ConversationAdapter` implémentant `CAnnoNicoAdapter` — réutilise le pattern existant | Moyen | **Moyenne** |
| 9 | conversations.json source externe non détectée automatiquement | Fichier externe | `ConversationMemoryStore` | Le store cherche déjà `conversations.json` dans `SUPRA_Conversations/` — mais ne scanne pas le desktop utilisateur | Faible | **Moyenne** |
| 10 | Pas de pont vers CAnnoNicoIntegrationBridge | `ConversationMemoryStore` | CAnnoNico patterns | Suivre la convention READ_ONLY + snapshot() comme PucheroMemoryAdapter | Moyen | **Basse** |

---

## 8. FORMATS

| Format | Utilisé par | Adapter Existant | Exemple |
|--------|-------------|------------------|---------|
| JSON (ChatGPT export) | `ConversationMemoryStore.parseChatGPTExport()` | Oui — JSONDecoder | `conversations.json` |
| JSON (mémoire indexée) | `ConversationMemoryStore.saveIndex()` | Oui — JSONEncoder | `ConversationMemoryIndex.json` |
| JSON (snapshot runtime) | `CAnnoNicoSnapshotStore`, `ControlTowerState` | Oui — `CAnnoNicoSourceReference` | `CONTROL_TOWER_STATUS.json` |
| JSON (registry) | Multiples registres | Oui — pattern identique | `MODULE_REGISTRY.json` |
| Markdown (rapports) | `ConversationKnowledgeProvider` | Oui — scan de fichiers | `SUPRA_EXECUTIVE_COCKPIT_*.md` |
| Markdown (foundation) | `_FOUNDATION_MEMORY/` | **Aucun** — aucun parseur | `ARCHITECTURE_MAP.md` |
| Codable struct (Swift) | Tous les stores | Protocol natif Swift | `ConversationRecord: Codable` |
| Combine sink | `MultiMemoryStore`, `ConversationMemoryStore` | Oui — `@Published` + `sink` | Pattern standard |

---

## 9. CONCLUSIONS

### Ce qui est DÉJÀ disponible pour connecter la mémoire

1. **Infrastructure d'import** : `ConversationMemoryStore` possède un parseur ChatGPT complet
2. **Auto-refresh** : 90s via `SUPRAPassiveRefreshCoordinator` déjà connecté
3. **Indexation** : date, titre, messages, tags, projets, décisions, missions, freezes, preuves — tout est en place
4. **KnowledgeGraph integration** : `connectToKnowledgeGraph()` existe dans le store (ligne ~284)
5. **Pattern CAnnoNico contracts** : Le standard `READ_ONLY + snapshot() + CAnnoNicoSourceReference` existe et est stable
6. **MultiMemoryStore pattern** : Le pattern `rebuild()` + `MemorySourceInfo` existe pour ajouter de nouvelles sources
7. **ConversationKnowledgeProvider** : Déjà scanne les fichiers de conversation locaux en arrière-plan
8. **Conventions de stockage** : `~/NOVA_OS/SUPRA/SUPRA_Conversations/` pour les indices, export JSON

### Ce qui manque pour une connexion complète

1. **Le pont boot** : `ConversationMemoryStore` n'est pas appelé au démarrage de l'app via `SUPRAOperationalCoreApp.onAppear`
2. **Le pont KnowledgeGraph** : `connectToKnowledgeGraph()` existe mais n'est pas invoquée au boot
3. **Le pont MultiMemoryStore** : Pas de `conversation` source dans `rebuild()`
4. **Le pont CAnnoNico** : Pas de `ConversationAdapter` implémentant `CAnnoNicoAdapter`
5. **Le pont MemoryView** : `MemoryView` n'affiche pas les conversations de `ConversationMemoryStore`
6. **Détection auto de conversations.json** : Le store cherche dans son propre répertoire mais pas sur le Desktop ou `~/Library`
7. **Partage de scan** : `ConversationKnowledgeProvider` et `ConversationMemoryStore` scannent les mêmes fichiers indépendamment

### Risque global

| Risque | Niveau | Mitigation existante |
|--------|--------|---------------------|
| Écrasement de données conversations | **Nul** — import versionné, aucun écrasement | `importVersion` increment |
| Régression UI | **Nul** — ConversationMemoryStore est une `ObservableObject` isolée, aucun effet sur views existantes | `@Published` pattern |
| Impact CPU | **Nul** — auto-refresh 90s avec `SUPRAResourceGovernor` check existant | PassiveRefreshCoordinator |
| Conflit mémoire | **Faible** — deux silos indépendants (WorkspaceMemory, ConversationMemory) | Complémentaires, pas concurrents |
| Connexion incomplète au KnowledgeGraph | **Moyen** — `connectToKnowledgeGraph()` non appelée | Ligne de code dans le store, suffit de l'invoquer |

---

## 10. ADAPTERS EXISTANTS À RÉUTILISER

### Adapter: `PucheroMemoryAdapter` → Modèle pour ConversationAdapter

Le `PucheroMemoryAdapter` est le modèle exact pour créer un `ConversationAdapter`:

| PucheroMemoryAdapter | → | ConversationAdapter (à créer) |
|---------------------|---|-------------------------------|
| `sourcePath` = NOVA_OS/PUCHERO | → | `sourcePath` = NOVA_OS/SUPRA/SUPRA_Conversations |
| `role` = READ_ONLY_MEMORY_AND_LINEAGE | → | `role` = READ_ONLY_CONVERSATION_MEMORY |
| `inputs` = canonical_queries, evidence_requests | → | `inputs` = conversation_queries, tag_search, date_range |
| `outputs` = memory_references, proof_lineage | → | `outputs` = conversation_records, message_index, summary_context |
| `capabilities` = READ_EXISTING_MEMORY, RESOLVE_PROOF_REFERENCES | → | `capabilities` = CHAT_IMPORT, INDEX_CONVERSATIONS, SEARCH_MESSAGES |

### Adapter Pattern: `CAnnoNicoAdapter` (protocol existant)

```
protocol CAnnoNicoAdapter: Sendable {
    static var adapterID: String { get }
    func snapshot() -> CAnnoNicoSourceReference
}
```
> Ce protocol est stable, en lecture seule, et parfait pour la connexion mémoire conversationnelle sans créer de nouveau moteur.

---

*Fin du MEMORY_CONNECTION_MAP.md*
