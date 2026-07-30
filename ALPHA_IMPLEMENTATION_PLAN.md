# Alpha Implementation Plan

## Contrat

Les dix missions suivent l’ordre canonique imposé. Chacune dure strictement de deux à quatre heures, réemploie uniquement l’existant et produit un résultat visible. Les commandes exactes de build et de test sont résolues au PRECHECK depuis les mécanismes officiels du dépôt; elles ne sont pas inventées ici.

Chaque PRECHECK vérifie la compatibilité avec le Consolidation Report, le Canon, l’Executive Runtime, l’Object Model, le Master Plan, l’Execution Backlog, le Pipeline et leurs documents associés. Aucun actif n’est recréé, remplacé ou déclassé. La Master Engineering Specification reste `DEFERRED UNTIL ALPHA OPERATIONAL`.

## ALPHA-01 — Certification Baseline

- **Durée:** 2–3 h.
- **Objectif:** établir une baseline exécutable et attribuable.
- **Dépendances:** aucune.
- **Composants existants:** application, scripts officiels, tests existants.
- **Périmètre inclus:** état Git, lancement, parcours minimal, erreurs connues.
- **Hors périmètre:** correction fonctionnelle et tout nettoyage global de la worktree, explicitement interdit.
- **Procédure:** capturer la baseline; résoudre les commandes officielles; lancer build/tests applicables; ouvrir l’application; consigner les écarts.
- **Résultat visible:** baseline lancée, captures horodatées et fiche d’écarts.
- **Validation et preuves:** sorties de commandes, statut Git attribuable, captures.
- **Rollback:** aucune mutation produit; retirer seulement les preuves temporaires autorisées.
- **STOP:** baseline non lançable, cible ambiguë ou attribution impossible.

## ALPHA-02 — Executive Surface

- **Durée:** 3–4 h.
- **Objectif:** afficher les huit informations exécutives sur la surface existante la plus mature.
- **Dépendances:** ALPHA-01.
- **Composants existants:** Executive Cockpit et projections existantes.
- **Périmètre inclus:** mission, blocage, prochaine action, Runtime, preuves, progression, santé, décisions.
- **Hors périmètre:** nouveau dashboard, logique métier dans la vue, nouvelle source.
- **Procédure:** sélectionner la surface existante; composer les huit projections; rendre les états vides explicites.
- **Résultat visible:** une page répond à « Que dois-je faire maintenant ? ».
- **Validation et preuves:** huit blocs visibles, captures des états nominal et vide.
- **Rollback:** restaurer la composition précédente.
- **STOP:** donnée simulée, ownership ambigu ou quatrième interface.

## ALPHA-03 — Navigation

- **Durée:** 2–4 h.
- **Objectif:** fournir une application, un shell et une navigation cohérente.
- **Dépendances:** ALPHA-02.
- **Composants existants:** shell et navigation les plus matures.
- **Périmètre inclus:** point d’entrée et destinations Alpha.
- **Hors périmètre:** nouveau shell, nouvelle application, nouveau dashboard.
- **Procédure:** confirmer les routes au PRECHECK; conserver une entrée; relier les destinations Alpha; vérifier clavier/souris et relance.
- **Résultat visible:** parcours Alpha complet depuis une navigation.
- **Validation et preuves:** checklist des routes, captures, relance identique.
- **Rollback:** restaurer les routes précédentes.
- **STOP:** changement Xcode, destination concurrente ou duplication du shell.

## ALPHA-04 — Runtime

- **Durée:** 2–4 h.
- **Objectif:** rendre Runtime, Health et état d’erreur visibles depuis la source canonique existante.
- **Dépendances:** ALPHA-03.
- **Composants existants:** Runtime Dashboard, Runtime et Health existants.
- **Périmètre inclus:** projection de l’état, santé et erreurs.
- **Hors périmètre:** nouveau Runtime, engine, snapshot ou store.
- **Procédure:** confirmer la source canonique; réutiliser ses projections; comparer les états entre surfaces; provoquer un échec sûr.
- **Résultat visible:** Runtime cohérent, états sain/dégradé et erreur actionnable.
- **Validation et preuves:** snapshots/logs concordants et captures corrélées.
- **Rollback:** restaurer les projections précédentes.
- **STOP:** sources divergentes ou mutation du contrat Runtime requise.

## ALPHA-05 — Memory

- **Durée:** 2–4 h.
- **Objectif:** restaurer contexte, workspace, recherche et historique depuis les capacités existantes.
- **Dépendances:** ALPHA-04.
- **Composants existants:** Memory, Workspace V5, recherche et historique existants.
- **Périmètre inclus:** ouverture d’un workspace NOVA OS réel, recherche ouvrable, historique et reprise.
- **Hors périmètre:** nouveau store, nouvel index, nouveau moteur ou migration destructive.
- **Procédure:** confirmer les owners; ouvrir le workspace; rechercher et ouvrir un résultat; écrire un contexte; relancer et reprendre.
- **Résultat visible:** workspace et contexte réels restaurés.
- **Validation et preuves:** traces avant/après, requête/résultat, identité du workspace.
- **Rollback:** retirer les nouvelles liaisons sans toucher aux données.
- **STOP:** perte de données, mémoire concurrente ou nouvel index nécessaire.

## ALPHA-06 — Codex Bridge

- **Durée:** 3–4 h.
- **Objectif:** lancer et suivre une interaction Codex réelle depuis SUPRA.
- **Dépendances:** ALPHA-05.
- **Composants existants:** bridge ou launcher Codex existant.
- **Périmètre inclus:** invocation réelle, statut, sortie, erreur et contrôle de duplication.
- **Hors périmètre:** faux chat, mock opérationnel, nouveau provider ou bridge de remplacement.
- **Procédure:** auditer le bridge au PRECHECK; connecter une action réelle; afficher statut/sortie/erreur; tester l’échec sûr.
- **Résultat visible:** exécution Codex réelle et traçable.
- **Validation et preuves:** entrée, sortie, statut, log et preuve reliée.
- **Rollback:** désactiver l’entrée intégrée et utiliser le fallback externe.
- **STOP:** bridge placeholder/incomplet, double lancement ou résultat non attribuable. Le fallback permet de travailler, mais Alpha reste `NOT READY`.

## ALPHA-07 — Mission Runner

- **Durée:** 3–4 h.
- **Objectif:** rendre la mission active, l’agenda et l’action suivante exécutables via le bridge validé.
- **Dépendances:** ALPHA-06.
- **Composants existants:** Mission, agenda, progression et runner existants.
- **Périmètre inclus:** lecture, sélection, action suivante, progression et lancement.
- **Hors périmètre:** nouveau MissionEngine, store, scheduler ou modèle.
- **Procédure:** confirmer l’owner; relier Mission au bridge; exécuter une étape; vérifier progression, blocage et reprise.
- **Résultat visible:** mission réelle lancée et suivie.
- **Validation et preuves:** identifiant Mission, agenda, exécution et progression corrélés.
- **Rollback:** retirer les liaisons ajoutées et conserver les données.
- **STOP:** deux missions actives, double exécution ou persistance concurrente.

## ALPHA-08 — Logs & Evidence

- **Durée:** 2–4 h.
- **Objectif:** rendre logs, preuves et décisions consultables et corrélés à l’exécution.
- **Dépendances:** ALPHA-07.
- **Composants existants:** logs Runtime, Evidence et Decisions existants.
- **Périmètre inclus:** corrélation mission→exécution→log→preuve→décision.
- **Hors périmètre:** nouveau store, nouveau modèle canonique ou migration.
- **Procédure:** relier les vues existantes; ouvrir log, preuve et décision réels; tester une erreur actionnable.
- **Résultat visible:** chaîne de traçabilité consultable.
- **Validation et preuves:** identifiants corrélés, captures et extraits.
- **Rollback:** retirer uniquement les nouvelles liaisons.
- **STOP:** preuve factice, owner multiple ou perte de données.

## ALPHA-09 — End-to-End Mission

- **Durée:** 3–4 h.
- **Objectif:** exécuter le parcours quotidien complet et durcir UX/recovery.
- **Dépendances:** ALPHA-08.
- **Composants existants:** design system, Recovery et surfaces consolidées.
- **Périmètre inclus:** parcours mission→Codex→Runtime→logs/preuves, états vide/dégradé, relance et reprise.
- **Hors périmètre:** redesign complet, nouveau système de notification ou architecture.
- **Procédure:** lancer une mission réelle; suivre son exécution; consulter les preuves; provoquer un échec sûr; relancer; vérifier contexte et idempotence.
- **Résultat visible:** mission E2E stable et lisible.
- **Validation et preuves:** journal E2E, captures, zéro perte et zéro double exécution ciblée.
- **Rollback:** revenir à la dernière mission certifiée.
- **STOP:** crash, perte de contexte, double exécution ou récupération destructive.

## ALPHA-10 — Alpha Certification

- **Durée active:** 2–4 h strictement.
- **Objectif:** produire le verdict binaire à partir des preuves déjà disponibles.
- **Dépendances:** ALPHA-01 à ALPHA-09.
- **Précondition passive hors durée:** trois sessions ≥2 h ou une journée ≥6 h sont achevées avant la fenêtre active; cette observation externe ne compte pas dans les 2–4 h.
- **Composants existants:** application consolidée, tests et preuves existants.
- **Périmètre inclus:** build/tests officiels, contrôles ciblés, examen des preuves passives et DONE-01 à DONE-17.
- **Hors périmètre:** session longue dans la fenêtre active, correction non isolée ou démo factice.
- **Procédure:** exécuter les commandes résolues; rejouer les contrôles; examiner les journaux longs; vérifier relance, erreur, authenticité et non-duplication.
- **Résultat visible:** paquet de preuves et verdict `READY` ou `NOT READY`.
- **Validation et preuves:** DONE-01 à DONE-17 tous `PASS` pour `READY`.
- **Rollback:** revenir à ALPHA-09, enregistrer les gates échoués et garder `NOT READY`.
- **STOP:** preuve manquante, Codex non réel, crash, perte, doublon ou worktree non attribuable.
