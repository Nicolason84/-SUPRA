# SUPRA Knowledge Graph V2 — Rapport de Construction

## Résumé

Knowledge Graph V2 est un système de graphe de connaissance unifié qui indexe et relie l'ensemble des artefacts SUPRA : git, workspace, rapports, artéfacts, freezes, missions et décisions. Il fournit un socle sémantique pour le Context Engine et le cockpit décisionnel.

---

## Fichiers générés

| Fichier | Taille | Description |
|---|---|---|
| `knowledge_graph.json` | 622 KB | 838 objets, version 2.0.0 |
| `knowledge_relations.json` | 303 KB | 1307 relations typées |
| `knowledge_statistics.json` | 894 B | Métriques de santé |
| `knowledge_context_examples.json` | 2.2 KB | 5 exemples de requêtes |

---

## Statistiques

**Objets :** 838
**Relations :** 1307
**Score de santé :** 9.2 / 10

### Répartition par source

| Source | Objets |
|---|---|
| workspace | 744 |
| report | 30 |
| git | 29 |
| artifact | 14 |
| freeze | 11 |
| decision | 10 |

### Répartition par type

- 17 types distincts : git_repository, git_branch, git_commit, git_tag, script, document, pdf, mission, decision, evidence, xcode_project, database, archive, report, audit, validation, artifact_result, freeze, freeze_manifest

### Distribution d'autorité

- **Haute (≥ 0.8) :** 513 objets
- **Moyenne (0.5-0.8) :** 325 objets
- **Faible (< 0.5) :** 0 objet
- **Confiance moyenne :** 0.95
- **Autorité moyenne :** 0.85

---

## Architecture des providers

| Provider | Source | Rôle |
|---|---|---|
| GitKnowledgeProvider | git | Référentiel, branches, commits, tags |
| WorkspaceIndex | workspace_index.json | Fichiers du workspace (1254 objets, 744 importants) |
| ReportKnowledgeProvider | Fichiers REPORT/AUDIT/VALIDATION | Rapports de mission |
| DecisionKnowledgeProvider | workspace_index + .opencode + freezes | Décisions et preuves |
| FreezeKnowledgeProvider | FREEZE_* directories | Snapshots et manifests |
| ArtifactKnowledgeProvider | agent_results/ | Artéfacts d'exécution |

---

## Types de relations (30)

belongs_to, depends_on, implements, references, relates_to, reports_to, validated_by, supersedes, derived_from, version_of, part_of, follows, precedes, analyzes, documents, configures, extends, supports, contains, parent_of, child_of, equivalent_to, similar_to, replaces, merges_with, splits_into, conflicts_with, resolves, contributes_to, blocks

---

## Context Engine (V2)

5 exemples de requêtes contextuelles intégrées couvrant :
1. RuntimeMonitor — 16 objets attendus (8 Swift, 2 commits, 1 décision, 1 rapport, 3 conversations, 1 PDF, 2 freezes)
2. Workspace Intelligence — justification d'existence (8 objets)
3. Commits liés au Cockpit — 12 objets
4. Freezes SUPRA — 10 objets (5 freezes + manifests + tags)
5. Provider Runtime — 6 objets (rapports + décisions + preuves)

---

## Construction

1. **Phase 1 — Git :** récupération de 9 branches, 16 commits, 3 tags via `git log --all --format=...`
2. **Phase 2 — Workspace :** filtrage de 1254 objets workspace_index.json, rétention de 744 objets importants
3. **Phase 3 — Artéfacts :** 30 rapports, 14 artéfacts d'agents, 11 objets de freeze (6 dirs + 5 manifests)
4. **Phase 4 — Missions :** 10 missions/décisions issues du workspace_index
5. **Phase 5 — Relations :** 1307 relations dont cross-source project links, commit-file references, report-module links, freeze-tag links
6. **Phase 6 — Sérialisation :** écriture JSON avec déduplication

---

## Prochaines étapes

1. Nettoyer `generate_knowledge_data.swift` (script utilitaire)
2. Intégrer les données dans le ContextEngine Swift (KnowledgeContextEngine.swift)
3. Valider les requêtes contextuelles
4. Étendre aux sources : conversations ChatGPT, PDFs, décisions `.opencode`
