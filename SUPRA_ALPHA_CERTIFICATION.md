# SUPRA Alpha Certification

## Verdict actuel

# NOT READY

**FACT:** cette mission produit uniquement un plan documentaire. Elle ne démontre pas le fonctionnement du produit.

**EVIDENCE:** les six documents Alpha définissent la cible, le Done, la roadmap, le triage, les dix missions et le protocole de certification.

**HYPOTHESIS:** les composants existants pourront être consolidés sans nouveau moteur, store, Runtime ou shell. Cette hypothèse doit être vérifiée mission par mission.

**PROPOSAL:** exécuter l’ordre canonique ALPHA-01 Certification Baseline, ALPHA-02 Executive Surface, ALPHA-03 Navigation, ALPHA-04 Runtime, ALPHA-05 Memory, ALPHA-06 Codex Bridge, ALPHA-07 Mission Runner, ALPHA-08 Logs & Evidence, ALPHA-09 End-to-End Mission, ALPHA-10 Alpha Certification. ALPHA-06 est NO-GO si le bridge Codex est placeholder ou incomplet.

## Continuité et autorité des actifs

Le Consolidation Report, le Canon, l’Executive Runtime, l’Object Model, le Master Plan, l’Execution Backlog, le Pipeline et les documents associés restent des actifs fondateurs. La certification Alpha vérifie leur respect; elle ne les recrée, ne les remplace ni ne les déclassifie.

La Master Engineering Specification est reportée, non abandonnée. Son statut exact est `DEFERRED UNTIL ALPHA OPERATIONAL`. Sa reprise est autorisée uniquement après le verdict Alpha `READY`, avec les preuves d’usage réel comme entrées.

## Matrice Done → test → preuve

| Done | Test requis | Preuve attendue |
|---|---|---|
| DONE-01 Application unique | Lancement et parcours complet | Capture fenêtre + journal de lancement |
| DONE-02 Navigation unique | Visiter toutes les destinations Alpha | Captures + checklist de routes |
| DONE-03 Runtime unique | Comparer les états projetés | Logs/snapshots concordants |
| DONE-04 Memory unique | Écrire, relancer, relire | Trace avant/après relance |
| DONE-05 Executive Surface | Vérifier les huit blocs | Capture annotée |
| DONE-06 Codex piloté | Exécution réelle depuis Mission | Entrée, sortie, statut et preuve |
| DONE-07 Missions | Ouvrir mission et agenda réels | Capture et identifiants réels |
| DONE-08 Preuves | Ouvrir une preuve reliée | Chaîne mission→preuve |
| DONE-09 Runtime visible | Observer activité et état | Capture + log correspondant |
| DONE-10 Erreurs visibles | Provoquer un échec sûr | Message UI + log |
| DONE-11 Décisions visibles | Ouvrir une décision réelle | Capture + relation mission |
| DONE-12 Stabilité réelle | Sessions longues et relance | Journal de session, crash logs absents, contrôle idempotence |
| DONE-13 Workspace | Ouvrir puis restaurer un workspace NOVA OS réel | Capture avant/après relance + identité du workspace |
| DONE-14 Recherche | Rechercher et ouvrir un résultat réel | Requête, résultat et destination ouverte |
| DONE-15 Historique | Reprendre une exécution depuis l’historique | Trace de sélection et contexte restauré |
| DONE-16 Logs | Corréler une exécution et ses logs | Identifiant d’exécution + extrait de log |
| DONE-17 Health | Observer les états sain et dégradé | Captures et signal Runtime corrélé |

## Protocole obligatoire

- Utiliser un workspace NOVA OS réel.
- Achever trois sessions d’au moins deux heures ou une journée d’au moins six heures avant ALPHA-10.
- Traiter ces longues sessions comme observation passive externe; elles ne comptent pas dans la fenêtre active de 2–4 h d’ALPHA-10.
- Observer zéro crash.
- Observer zéro perte de contexte.
- Observer zéro double exécution.
- Fermer et relancer l’application au moins une fois.
- Résoudre au précheck puis exécuter les commandes officielles de build et tests applicables.
- Conserver captures, logs, résultats et identifiants de preuves.
- Interdire les données factices comme preuve du parcours critique.
- Vérifier un rollback ciblé ou démontrer sa procédure réversible pour chaque mission.

## Gates

| Gate | PASS | NO-GO |
|---|---|---|
| Baseline | Lançable et attribuable | Baseline inconnue ou non lançable |
| Shell | Une application/navigation | Interface supplémentaire |
| Runtime/Memory | Sources canoniques existantes | Duplication ou nouveau store |
| Codex | Bridge réel complet | Placeholder, incomplet ou double lancement |
| Usage réel | Durée et workspace respectés | Démo courte ou fixtures |
| Stabilité | Zéro crash/perte/doublon | Un seul incident critique |
| Preuves | Chaîne complète | Élément non prouvé |
| Continuité | Actifs fondateurs respectés | Actif recréé, remplacé ou déclassé |

Le fallback Codex externe est permis comme continuité de travail, mais il ne satisfait jamais DONE-06; dans ce cas le verdict reste `NOT READY`.

## Traçabilité complète des MUST

| MUST HAVE | DONE | Mission | Test | Preuve |
|---|---|---|---|---|
| Mission active | DONE-07 | ALPHA-07 | Ouvrir/restaurer mission réelle | Identifiant + captures |
| Agenda d’exécution | DONE-07 | ALPHA-07 | Lire étapes et prochaine action | Capture agenda |
| État Runtime | DONE-03, DONE-09 | ALPHA-04 | Comparer projections | Logs/snapshots concordants |
| Pilotage Codex | DONE-06 | ALPHA-06 | Exécuter Codex réel | Entrée/sortie/statut |
| Historique | DONE-15 | ALPHA-05 | Reprendre depuis historique | Trace de reprise |
| Evidence | DONE-08 | ALPHA-08 | Ouvrir preuve reliée | Chaîne mission→preuve |
| Logs | DONE-16 | ALPHA-08 | Corréler exécution/log | ID + extrait |
| Memory | DONE-04 | ALPHA-05 | Écrire, relancer, relire | Trace avant/après |
| Recherche | DONE-14 | ALPHA-05 | Rechercher et ouvrir | Requête + destination |
| Navigation | DONE-02 | ALPHA-03 | Visiter destinations Alpha | Checklist + captures |
| Health | DONE-17 | ALPHA-04, ALPHA-09 | Observer sain/dégradé | Captures + signal |
| Workspace | DONE-13 | ALPHA-05 | Ouvrir/restaurer workspace réel | Identité + captures |
| Decisions | DONE-11 | ALPHA-08 | Ouvrir décision réelle | Relation mission |
| Progression | DONE-05 | ALPHA-02, ALPHA-07 | Vérifier progression projetée | Capture annotée |
| Blocage courant | DONE-05 | ALPHA-02, ALPHA-07 | Afficher un blocage réel | Capture + source |
| Action suivante | DONE-05 | ALPHA-02, ALPHA-07 | Afficher next action | Capture + agenda |
| Erreurs visibles | DONE-10 | ALPHA-04, ALPHA-08, ALPHA-09 | Provoquer échec sûr | UI + log |
| Recovery/relaunch | DONE-12 | ALPHA-09 | Fermer, relancer, reprendre | Journal + contrôle doublon |
| Executive Surface | DONE-05 | ALPHA-02 | Vérifier huit blocs | Capture annotée |

Zéro capacité `MUST HAVE` de `FEATURE_CLASSIFICATION.md` n’est orpheline. Les notifications sont `SHOULD HAVE / BETA` et restent hors gate Alpha.

## Intégrité Git et attribution

La baseline globale est préexistante et dirty: son intégrité complète reste **NON CERTIFIABLE**. Les six nouveaux chemins ci-dessous sont attribués à cette mission. Une comparaison avec la baseline capturée ne détecte aucune nouvelle mutation hors de cette allowlist; cette assertion ne certifie pas les changements antérieurs de la worktree.

- `SUPRA_PRODUCT_TARGET.md`
- `SUPRA_ALPHA_DEFINITION.md`
- `SUPRA_ALPHA_ROADMAP.md`
- `FEATURE_CLASSIFICATION.md`
- `ALPHA_IMPLEMENTATION_PLAN.md`
- `SUPRA_ALPHA_CERTIFICATION.md`

Aucun statut `READY` ne peut être prononcé à partir de ces documents seuls. Il exige les preuves d’exécution et d’usage réel définies ci-dessus.

Les SHA256 et horodatages doivent être calculés après la dernière mutation documentaire et conservés dans la preuve externe de certification. Ils ne sont pas auto-inscrits ici, car leur inscription modifierait les fichiers et invaliderait leurs propres empreintes.
