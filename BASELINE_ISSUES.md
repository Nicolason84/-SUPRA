# ALPHA-01 — Baseline Issues

## Règles de classement

`BLOCKER` empêche la compilation ou le lancement minimal. `CRITIQUE` menace la gouvernance ou l’intégrité sans empêcher le lancement constaté. `MAJEUR` affecte une capacité importante ou une validation future. `MINEUR` affecte la cohérence ou la qualité. `INFO` consigne une limite observable.

## Registre

| ID | Sévérité | Description | Impact | Cause probable | Fichiers concernés | Preuve | Correctif proposé | Statut |
|---|---|---|---|---|---|---|---|---|
| BL-001 | CRITIQUE | Baseline Git fortement dirty et non attribuable globalement | Rollback et attribution des régressions difficiles | Accumulation antérieure à ALPHA-01 | 13 suivis modifiés et 949 chemins non suivis | Branche `develop` +12 ; 0 staged ; 11 Swift + pbxproj + Dependency Map suivis modifiés | Établir un snapshot signé et une baseline propriétaire avant les mutations produit | OUVERT, non bloquant ALPHA-02 |
| BL-002 | MAJEUR | Le Runtime affiché attend ses données | Les états opérationnels ne sont pas exploitables | Chemin de publication ou source Runtime non alimenté | Runtime et sources à localiser pendant ALPHA-04 | Capture : `WAITING FOR DATA`, `Standby`, `Health SYNC`, `awaiting publication` | Diagnostiquer le chemin existant sans réécrire le Runtime | OUVERT |
| BL-003 | MAJEUR | Le boot manager ne semble pas déclencher la publication attendue | L’UI démarre mais reste en attente | Bootstrap existant non déclenché ou publication non reçue ; cause à confirmer | `SUPRAApp.swift`, `ExecutiveBootManager.swift` et chaîne observée | Fenêtre rendue, état inchangé en attente pendant l’observation | Instrumenter puis valider le bootstrap existant dans ALPHA-04 | OUVERT |
| BL-004 | MAJEUR | Avertissements de concurrence incompatibles avec le futur mode Swift 6 strict | Risque de compilation future et de races | Isolement d’acteurs et captures concurrentes non alignés | `SUPRABackgroundScheduler.swift:48,140`; `SUPRACanonicalWorldAccess.swift:242`; `WorkspaceDiscovery.swift:16,17`; `MissionContext.swift:36`; `SUPRAPassiveRefreshCoordinator.swift:43`; `SUPRAResourceGovernor.swift:83`; `SUPRAResourceIntelligenceEngine.swift:58`; `SUPRAResourceIntelligenceView.swift:39`; `ContentView.swift:3128`; `ConversationMemoryStore.swift:574,583,698,828`; `ExecutiveCockpitFoundation.swift:80`; `ExecutiveSearch.swift:46`; `RuntimeDataService.swift:424,425,429` | Messages « this is an error in the Swift 6 language mode » dans le log | Traiter par lots ciblés avec tests, sans refactor global | OUVERT |
| BL-005 | MAJEUR | Suite complète non certifiée | Régressions potentielles non exclues | Exécution interrompue, code 130 | Cible `SUPRATests` | 113 tests passés avant interruption ; un fallback transitoirement en échec | Relancer la suite dans une session stable et archiver le `.xcresult` | OUVERT |
| BL-006 | MAJEUR | Scénario fallback transitoirement instable | Flakiness possible du Runtime provider | Timing ou état partagé à confirmer | `SUPRARuntimeProviderProofTests/testFallbackScenario` | Échec dans la suite, puis rerun isolé PASS code 0, log SHA-256 `85b639…` | Répéter isolé et en suite, identifier les préconditions | OUVERT, isolé PASS |
| BL-007 | MAJEUR | Script d’installation syntaxiquement invalide | Installation automatisée impossible par ce script | Accolade inattendue | `GO_SUPRA_INSTALL.sh:98` | `bash -n` retourne 2, syntax error near `}` | Corriger sous mission script dédiée puis valider `bash -n` | OUVERT |
| BL-008 | MINEUR | AppIcon sans image | Identité visuelle/packaging incomplets | Catalogue réduit à `Contents.json` | `SUPRA/Assets.xcassets/AppIcon.appiconset` | Répertoire sans fichier image | Fournir les assets approuvés lors d’une mission UI/packaging | OUVERT |
| BL-009 | MINEUR | Badge `OPERATIONAL` contradictoire avec l’état d’attente | Risque de fausse lecture opérateur | Badge non dérivé de la même vérité d’état | Executive Surface existante | Capture runtime : badge `OPERATIONAL` et `WAITING FOR DATA` simultanés | Dériver le badge du snapshot canonique dans ALPHA-02/04 | OUVERT |
| BL-010 | MINEUR | Warnings de variables inutilisées, résultats ignorés et API dépréciées | Bruit de build et défauts masqués | Dette locale | Plusieurs sources, dont `SUPRACompanionView.swift:102` et fichiers listés dans `BUILD_LOG.md` | 64 occurrences `warning:` | Réduction progressive avec seuil de non-régression | OUVERT |
| BL-011 | INFO | Aucun fichier de log Runtime persistant identifié pendant l’observation | Diagnostic post-mortem limité | Logger actuel orienté console ou stockage non activé | `SUPRARuntimeLogger.swift` et configuration associée | Aucun artefact de log persistant établi dans la preuve | Définir une preuve de persistance pour ALPHA-08 | OUVERT |
| BL-012 | INFO | Artefacts atypiques : fichier/répertoire `{` et éléments EOF/vides signalés | Bruit d’inventaire, risque pour scripts naïfs | Génération antérieure | Racine et artefacts | Entrée top-level `{` visible dans l’état Git | Classifier, archiver ou retirer sous mission gouvernée | OUVERT |

## Synthèse

L’artefact temporaire vide `default.profraw`, généré pendant le lancement ALPHA-01, a été retiré avant certification et ne constitue pas une issue produit.

| Sévérité | Nombre |
|---|---:|
| BLOCKER | 0 |
| CRITIQUE | 1 |
| MAJEUR | 6 |
| MINEUR | 3 |
| INFO | 2 |

Aucun problème observé n’empêche la compilation ou le lancement minimal. Aucun correctif n’a donc été appliqué dans ALPHA-01.
