# Critical Path

> **DRAFT — PLAN STRUCTURÉ MAIS PARTIEL — NOT READY FOR IMPLEMENTATION**
>
> [FACT] `EXECUTIVE_EVENT_MODEL.md`, `RUNTIME_LAWS.md` et `UI_PHILOSOPHY.md` sont absents des sources autorisées. **G0 est rouge.**
> [EVIDENCE] Base exclusive: `ULTIMATE_CONSOLIDATION_REPORT.md`, `SUPRA_CANON.md`, `EXECUTIVE_RUNTIME.md`, `EXECUTIVE_OBJECT_MODEL.md`, `AGENTS.md`, `DEPENDENCY_MAP.md`.
> [PROPOSAL] Toute sortie produit décrite ici est future. Aucun contrat manquant n’est inventé.

## DAG

```text
A01→…→A11→R01→…→R17
                    ├→M01→M02→M03→M04→M05→M06─┐
                    ├→K01→…→K06──────────────┐  │
                    ├→W01→…→W06───────────┐  │  │
                    ├→P01→…→P05───────┐   │  │  ├→U03/U04
                    ├→V01→…→V04───────┼───┼──┼──┐
                    ├→D01 (attend M03)→…→D05──────┤
                    └→U01→U02; U03 join M06,D05; U04 join W06,K06; U05 join P05; U10
U10 + V04 → I01→…→I08
```

## Arêtes de jointure

| Successeur | Prédécesseurs obligatoires | Motif |
|---|---|---|
| D01 | R17, M03 | Action/Execution doit être cadré |
| U03 | U02, M06, D05 | Dashboard après domaines Mission/Decision |
| U04 | U03, W06, K06 | projection Workspace/Knowledge certifiée |
| U05 | U04, P05 | projection Provider après certificat |
| V01 | R17, P05 | diagnostics Provider disponibles |
| I01 | U10, V04 | industrialisation après UI et Developer |

[PROPOSAL] A et R restent séquentiels. Après R17, M/K/W/P et préparation U01 peuvent avancer en analyses read-only; D attend M03; V attend P05; mutations restent sérialisées par Builder. Chemin critique temporel exact sera recalculé après G0; 270 h est l’effort, pas la durée calendaire.

## Commande de contrôle du DAG

`rg '^### [A-Z][0-9]{2} —' EXECUTION_BACKLOG.md | sort` doit produire 78 IDs uniques; chaque dépendance doit référencer un ID antérieur ou une jointure ci-dessus. Exit attendu 0.
