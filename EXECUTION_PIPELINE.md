# Execution Pipeline

> **DRAFT — PLAN STRUCTURÉ MAIS PARTIEL — NOT READY FOR IMPLEMENTATION**
>
> [FACT] `EXECUTIVE_EVENT_MODEL.md`, `RUNTIME_LAWS.md` et `UI_PHILOSOPHY.md` sont absents des sources autorisées. **G0 est rouge.**
> [EVIDENCE] Base exclusive: `ULTIMATE_CONSOLIDATION_REPORT.md`, `SUPRA_CANON.md`, `EXECUTIVE_RUNTIME.md`, `EXECUTIVE_OBJECT_MODEL.md`, `AGENTS.md`, `DEPENDENCY_MAP.md`.
> [PROPOSAL] Toute sortie produit décrite ici est future. Aucun contrat manquant n’est inventé.

## Evidence manifest

`Evidence/<ID>/`: `before.status`, `before.sha256`, `allowlist.txt` (un chemin relatif par ligne), `plan.md`, `change.patch`, `inverse.patch`, `commands.log` (commande, exit, timestamp), `tests.log`, `after.sha256`, `audit.md`, `certificate.md`, `manifest.sha256`. SHA-256 est calculé sur chaque artefact; status est capturé avant/après; aucun secret ni chemin hors dépôt.

| Gate | Entrée | Sortie | Preuves | Rollback | Autorité |
|---|---|---|---|---|---|
| READY | fiche, owner, durée, deps | G0/deps évalués | readiness.md + source hashes | aucune mutation | Router |
| PLAN | READY ou SOURCE-BLOCKED documentable | allowlist/critères/risque fermés | allowlist.txt + plan.md | supprimer seulement plan non signé | Architect |
| PRECHECK | PLAN signé | status attribuable, hashes/tests before verts | before.status, before.sha256, tests.log | STOP; aucun changement | Auditor |
| IMPLEMENT | G0 vert + PRECHECK vert | patch allowlisté appliqué une fois | change.patch + commands.log | inverse.patch chemin-par-chemin | Builder |
| VERIFY | patch présent | diff-check et hors-allowlist = zéro | after.sha256 + diff report | inverse.patch | Reviewer |
| TEST | VERIFY vert | test domaine exit 0 + parité | tests.log/xcresult | inverse.patch puis même test | Runtime |
| AUDIT | TEST vert | Single Writer/Canon/parité PASS | audit.md | retour CORRECTION | Auditor |
| SNAPSHOT | AUDIT PASS | bundle complet/hashé | manifest.sha256 | invalider bundle incomplet | Builder |
| CERTIFY | snapshot complet | PASS/FAIL binaire | certificate.md | FAIL → correction | Auditor |
| FREEZE | CERTIFY PASS + doctrines applicables présentes | manifest immutable référencé | freeze manifest + hashes | aucun FREEZE si SOURCE-BLOCKED | Architect + human gate |
| NEXT | FREEZE PASS | successeurs recalculés | queue status patch | revenir au dernier freeze valide | Router |

## Stop / correction

STOP immédiat si G0 rouge pour une mutation, overlap dirty, chemin hors allowlist, hash before manquant, test before rouge, commande non zéro, doctrine contradictoire ou writer autre que Builder. Deux corrections maximum; chacune recrée patch/hashes/tests. Troisième échec: rollback au before, escalade humaine, état SOURCE-BLOCKED. FREEZE n’a aucune opération de « défreeze »: un changement ultérieur exige nouvelle mission/ADR et nouveau freeze.

