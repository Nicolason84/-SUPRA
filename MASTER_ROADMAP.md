# Master Roadmap

> **DRAFT — PLAN STRUCTURÉ MAIS PARTIEL — NOT READY FOR IMPLEMENTATION**
>
> [FACT] `EXECUTIVE_EVENT_MODEL.md`, `RUNTIME_LAWS.md` et `UI_PHILOSOPHY.md` sont absents des sources autorisées. **G0 est rouge.**
> [EVIDENCE] Base exclusive: `ULTIMATE_CONSOLIDATION_REPORT.md`, `SUPRA_CANON.md`, `EXECUTIVE_RUNTIME.md`, `EXECUTIVE_OBJECT_MODEL.md`, `AGENTS.md`, `DEPENDENCY_MAP.md`.
> [PROPOSAL] Toute sortie produit décrite ici est future. Aucun contrat manquant n’est inventé.

## Lots et trajectoire

| Étape | Lot / missions | Durée effort | Entrée | Sortie mesurable |
|---|---|---:|---|---|
| Aujourd’hui→Consolidation | LOT 1 Architecture: A01–A11 | 44 h | aucune | A11 certificate PASS |
| Executive Runtime | LOT 2 Runtime: R01–R17 | 68 h | A11 | R17 certificate PASS |
| Executive OS | LOT 3 Mission: M01–M06 | 24 h | R17 | M06 certificate PASS |
| Executive OS | LOT 4 Knowledge: K01–K06 | 20 h | R17 | K06 certificate PASS |
| Executive OS | LOT 5 Decision: D01–D05 | 15 h | R17,M03 | D05 certificate PASS |
| Executive OS | LOT 6 Workspace: W01–W06 | 18 h | R17 | W06 certificate PASS |
| Executive OS | LOT 7 UI: U01–U10 | 30 h | R17 | U10 certificate PASS |
| Executive OS | LOT 8 Provider: P01–P05 | 15 h | R17 | P05 certificate PASS |
| Executive OS | LOT 9 Developer: V01–V04 | 12 h | R17,P05 | V04 certificate PASS |
| Version Ultime | LOT 10 Industrialisation: I01–I08 | 24 h | U10,V04 | I08 certificate PASS |

Total effort: **270 h**; calendrier non certifiable avant G0 et capacité Builder.

## Checkpoints avec seuils

| CP | Mission | Preuves/path | Captures | Tests/commande et seuil | Audit/validation |
|---|---|---|---|---|---|
| CP0 | A11 | Evidence/A11/* + ADR hashes | graphe cible lisible | liens brisés=0; 78 IDs uniques | Architect+Auditor+human PASS |
| CP1 | R17 | Evidence/R17/* | Runtime nominal/dégradé/stale | build exit 0; source concurrente=0; publication atomique PASS | Runtime+Auditor+human |
| CP2 | W06 | Evidence/W06/* | Explorer vide/nominal/erreur | test Workspace exit 0; parité PASS | Auditor+human |
| CP3 | M06 | Evidence/M06/* | liste/détail/timeline/graphe | transitions illégales=0; test exit 0 | Auditor+human |
| CP4 | K06 | Evidence/K06/* | objets/relations/lineage | provenance manquante=0; test exit 0 | Auditor+human |
| CP5 | U10 | Evidence/U10/* | 12 espaces + erreur/empty | shell actif=1; navigation parallèle=0; tests exit 0 | Reviewer+Auditor+human |
| CP6 | I07 | Evidence/I07/* | parcours E2E et recovery | références shells retirés=0; suite exit 0; rollback rehearsal PASS | audit indépendant+human |

## Index de traçabilité

Pour chaque mission `X`: fiche `EXECUTION_BACKLOG.md#x` → risque `RISK_MATRIX.md#RK-X` (ligne RK-X) → composants `KEEP_MATRIX.md` colonne Mission → checkpoint ci-dessus → gates `EXECUTION_PIPELINE.md`. [PROPOSAL] `Evidence/X/manifest.sha256` matérialise cette chaîne.

