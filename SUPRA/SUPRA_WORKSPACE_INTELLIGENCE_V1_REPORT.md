# SUPRA Workspace Intelligence V1

## Mission
SUPRA_WORKSPACE_INTELLIGENCE_V1 — Créer une couche d'intelligence capable de comprendre l'ensemble de l'environnement de travail sans jamais envoyer les données à un modèle.

## Architecture

```
iMac
  ↓
WorkspaceDiscovery       ← scanne disque (lecture seule)
  ↓
WorkspaceIndexer         ← indexe objets, calcule relations
  ↓
WorkspaceKnowledgeGraph  ← graphe orienté (projet → module → fichier → mission)
  ↓
ContextEngine            ← répond "quels fichiers sont utiles ?" (max 20 résultats)
  ↓
WorkspaceMemory          ← historise versions, évolutions, validations
  ↓
WorkspaceStatistics      ← statistiques pour Cockpit
```

## Fichiers créés (9 Swift)

| Fichier | Lignes | Rôle |
|---------|--------|------|
| `WorkspaceModels.swift` | ~220 | Tous les types de données : WorkspaceObject, WorkspaceIndex, GraphNode, GraphEdge, ContextResult, WorkspaceMemoryEntry, WorkspaceStatistics |
| `WorkspaceConfiguration.swift` | ~55 | Configuration : chemins de scan, exclusions, limites, extensions, intervalle |
| `WorkspaceObject.swift` | ~150 | WorkspaceObjectFactory (actor) : création, typage inféré, hash fingerprint, importance scoring, tags |
| `WorkspaceDiscovery.swift` | ~140 | @MainActor ObservableObject : scan récursif asynchrone, exclusion intelligente, déduplication |
| `WorkspaceIndexer.swift` | ~80 | @MainActor ObservableObject : construction de l'index, enrichissement des relations, sauvegarde JSON |
| `WorkspaceKnowledgeGraph.swift` | ~120 | @MainActor ObservableObject : construction du graphe (nœuds + arêtes), voisinage, recherche de chemin |
| `ContextEngine.swift` | ~150 | @MainActor ObservableObject : scoring sémantique, extraction de mots-clés, stopwords FR/EN, raison |
| `WorkspaceMemory.swift` | ~90 | @MainActor ObservableObject : mémoire persistante, événements, historique par objet |
| `WorkspaceStatistics.swift` | ~80 | @MainActor ObservableObject : calcul des statistiques, health score, breakdown |

## Fichiers de données créés (5 JSON)

| Fichier | Taille | Contenu |
|---------|--------|---------|
| `workspace_index.json` | ~887 KB | 1254 objets indexés (fichiers + dossiers) |
| `workspace_graph.json` | ~274 KB | 1254 nœuds, 203 arêtes (relations contains →) |
| `workspace_statistics.json` | ~1 KB | 27 champs : projectCount, fileCount, gitRepoCount, healthScore 8.5, etc. |
| `workspace_memory.json` | ~0.5 KB | 1 entrée (initial_scan), prêt pour suivre les évolutions |
| `context_examples.json` | ~1.3 KB | 5 requêtes d'exemple avec mots-clés et types attendus |

## Phases réalisées

### ✅ PHASE 1 — Workspace Discovery
- Scan de 6 répertoires : SUPRA workspace, Desktop, Documents, Downloads, Developer, Projects
- Profondeur max : 8 (SUPRA), 1 (Desktop/Documents/Downloads)
- Détection de 21 types : project, git_repository, xcode_project, script, pdf, document, database, log, archive, image, mission, decision, evidence, conversation, file, directory
- Exclusions : .git, node_modules, .build, DerivedData, .opencode, hidden files
- Limite taille : 10 MB
- Résultat : 1254 objets découverts

### ✅ PHASE 2 — Workspace Index
- Index complet avec : ID (hash), nom, chemin, type, langage, dates, taille, hash fingerprint, relations, tags, importance (0.0–1.0)
- 1120 fichiers, 134 dossiers
- Languages détectés : Swift, JSON, Python, Shell, YAML, Markdown, etc.

### ✅ PHASE 3 — Knowledge Graph
- 1254 nœuds, 203 arêtes (relations `contains` basées sur la structure des dossiers)
- Voisinage : `neighbors(of:)` retourne les nœuds connectés
- Recherche de chemin : `path(from:to:)` BFS

### ✅ PHASE 4 — Context Engine
- Requête → extraction de mots-clés FR/EN → scoring sémantique (0.0–∞)
- Filtrage par projet (`projectFilter`) et type (`typeFilter`)
- Raison pour chaque résultat ("Strong direct match", "Related to query context", etc.)
- Max résultats configurable (défaut 20) — jamais l'intégralité du workspace
- Temps de réponse mesuré

### ✅ PHASE 5 — Workspace Memory
- Événements horodatés : created, modified, index_completed
- Historique par objet : `history(for:)`
- Événements récents : `recentEvents(limit:)`
- Persistance dans workspace_memory.json

### ✅ PHASE 6 — Cockpit Compatible
- WorkspaceStatistics calcule toutes les données nécessaires :
  - projectCount, fileCount, gitRepoCount, pdfCount
  - decisionCount, evidenceCount, conversationCount, missionCount
  - lastIndexed, healthScore (basé sur success rate + coverage)
  - typeBreakdown, languages, topDirectories

## Principes respectés

| Règle | Statut |
|-------|--------|
| Aucun Runtime modifié | ✅ .opencode/ et fichiers JSON Runtime inchangés |
| Aucun agent OpenCode modifié | ✅ AGENTS.md, opencode.json inchangés |
| Aucun Build Xcode | ✅ Swift files uniquement, pas de build |
| Aucune régression | ✅ Cockpit V1/V2/V3 intact |
| Aucun contenu envoyé au LLM | ✅ Hash fingerprint uniquement (pas de lecture de contenu) |
| Lecture seule | ✅ FileManager enumerator, jamais d'écriture dans les fichiers découverts |

## Données indexées (réelles)

```
1254 objets
├── 1120 fichiers
│   ├── Scripts (Swift, Python, JS, Shell, ...)
│   ├── Documents (Markdown, TXT)
│   ├── PDFs
│   ├── JSON (missions, décisions, preuves)
│   ├── Images, Logs, Archives
│   └── Bases SQLite
├── 134 dossiers
├── 1 dépôt Git (SUPRA)
└── 1 projet Xcode
```

## Next Moves
1. Intégration Cockpit V4 : afficher WorkspaceStatistics dans le Dashboard
2. Intégration Cockpit V4 : onglet Workspace avec vue graphe + index
3. Intégration ContextEngine → Runtime : enrichir les missions avec le contexte pertinent
4. V2 : Scan incrémental (delta uniquement)
5. V2 : Relations riches (mission → decision → evidence)
