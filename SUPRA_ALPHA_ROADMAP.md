# SUPRA Alpha Roadmap

## Règle de priorité

Seule la Phase A est prioritaire. Les phases suivantes décrivent des horizons, pas une autorisation d’implémentation.

## Continuité des actifs

Le Consolidation Report, le Canon, l’Executive Runtime, l’Object Model, le Master Plan, l’Execution Backlog, le Pipeline et leurs documents associés restent la fondation gouvernante. La roadmap Alpha les consomme sans les recréer, les remplacer ou les déclasser.

La Master Engineering Specification conserve le statut `DEFERRED UNTIL ALPHA OPERATIONAL`. Elle reprendra après la certification Alpha, enrichie par les preuves du produit réel.

## Phase A — SUPRA Alpha Operational

**Objectifs.** Assembler les composants existants en une application, une navigation, un Runtime et une Memory; rendre le parcours quotidien réel opérationnel.

**Livrables.** Executive Surface, mission active, agenda, Codex réel, Runtime et santé visibles, workspace/recherche, mémoire, preuves, décisions, erreurs, reprise et certification E2E.

**Ordre canonique d’exécution.** ALPHA-01 Certification Baseline → ALPHA-02 Executive Surface → ALPHA-03 Navigation → ALPHA-04 Runtime → ALPHA-05 Memory → ALPHA-06 Codex Bridge → ALPHA-07 Mission Runner → ALPHA-08 Logs & Evidence → ALPHA-09 End-to-End Mission → ALPHA-10 Alpha Certification.

**Entrée.** Baseline documentée; composants existants identifiés par précheck; rollback possible; aucun besoin de nouveau moteur/store/Runtime/shell.

**Sortie.** DONE-01 à DONE-17 `PASS`; seuil d’usage réel atteint; build et tests applicables réussis; preuves archivées.

**Après sortie.** Ouvrir la reprise gouvernée de la Master Engineering Specification, sans retarder la certification Alpha elle-même.

**Risques.** Bridge Codex incomplet; baseline globale dirty; sources concurrentes; double exécution; régression de navigation.

**Rollback.** Revenir mission par mission aux composants et routes préexistants, sans migration destructive. Un échec Codex impose NO-GO.

## Phase B — SUPRA Beta

**Objectifs.** Durcir l’usage multi-session, améliorer l’ergonomie et réduire les frictions observées en Alpha.

**Livrables.** Notifications affinées, historique enrichi, providers mieux exposés, rapports utiles intégrés et corrections issues de la télémétrie locale autorisée.

**Entrée.** Alpha certifiée et utilisée réellement.

**Sortie.** Parcours récurrents stables, défauts critiques corrigés, critères Beta approuvés avant exécution.

**Risques.** Gonflement du périmètre et optimisation prématurée.

**Rollback.** Conserver Alpha certifiée comme baseline gelée.

## Phase C — SUPRA Production

**Objectifs.** Industrialiser fiabilité, sécurité, distribution et support.

**Livrables.** Politique de release, récupération durcie, exigences sécurité validées, tests de non-régression et certification de production.

**Entrée.** Beta stable et métriques d’usage disponibles.

**Sortie.** Release reproductible et gouvernée, critères Production approuvés et satisfaits.

**Risques.** Dette d’exploitation et exigences sécurité tardives.

**Rollback.** Retour à la dernière Beta certifiée.

## Phase D — SUPRA Ultimate

**Objectifs.** Évaluer les capacités avancées uniquement après maturité produit.

**Livrables.** À définir par besoins réels validés; aucun engagement Alpha.

**Entrée.** Production stable et justification produit démontrée.

**Sortie.** Critères futurs explicitement approuvés.

**Risques.** Vision spéculative, complexité et dilution du produit.

**Rollback.** Maintien de la Production certifiée.

## Mesure de progression

La progression va de critères Done vérifiés vers l’usage réel, et non du nombre de documents ou de composants créés.
