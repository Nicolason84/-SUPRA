# ALPHA-01 — Baseline Certification Report

## Décision

**READY FOR ALPHA-02**

Cette décision porte exclusivement sur les critères ALPHA-01 : compilation et lancement minimal. Elle ne certifie ni l’intégrité historique globale du dépôt, ni la complétude fonctionnelle du Runtime, ni l’ensemble de la suite de tests.

**VALIDATION :** La baseline est ignorée car la branche `develop` contient +12 commits et 13 fichiers suivis modifiés de manière incohérente avec un cycle de release propre.

**GATE REMARQUE :** La baseline est **IGNORÉE** et non **CERTIFIÉE**. Conformément au préfixe strict "PREMATCH FIRST", le dépôt doit établir une référence Git propre et attribuable avant le lancement d'ALPHA-02.

## Périmètre et référence

- Mission : `ALPHA-01_BASELINE_CERTIFICATION`
- Branche observée : `develop`, 12 commits devant `origin/develop`
- HEAD observé : `80ca2f19aa2e1cbf5f8183fb993c2b96abc177ea`
- État initial capturé : 13 fichiers suivis modifiés, 949 chemins non suivis avec `-uall`, 518 entrées de premier niveau, 0 changement indexé.
- Diff suivi préexistant : 11 fichiers Swift, `SUPRA.xcodeproj/project.pbxproj` et `DEPENDENCY_MAP.md`.
- Diff Package observé : aucun.
- Correction ALPHA-01 appliquée : aucune, car aucun BLOCKER de compilation ou de lancement n’a été observé.
- Hygiène de certification : `default.profraw`, artefact de profilage vide généré par le lancement ALPHA-01, a été retiré avant la photographie Git finale.

La baseline est fortement dirty et ne permet pas d’attribuer globalement les changements antérieurs. Cet état existait avant ALPHA-01 et constitue un risque de traçabilité CRITIQUE, pas un BLOCKER d’exécution minimale.

## Matrice READY

| Critère | Résultat | Preuve |
|---|---:|---|
| Le projet compile | PASS | `xcodebuild` retourne 0 ; `** BUILD SUCCEEDED **` ligne 2168 |
| L’application démarre | PASS | processus PID 16000 persistant et fenêtre intitulée `SUPRA` |
| Aucun crash bloquant immédiat | PASS | processus encore présent pendant l’observation ; fenêtre rendue |
| Dépendances cohérentes pour le build | PASS | résolution locale ; quatre modules CAnnoNico liés |
| Erreurs restantes documentées | PASS | `BASELINE_ISSUES.md` |
| BLOCKERS levés | PASS | aucun BLOCKER détecté ; aucune correction nécessaire |

## Preuves de build

Commande exacte :

```sh
xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx -derivedDataPath /private/tmp/SUPRA_ALPHA01_DERIVED build > /private/tmp/SUPRA_ALPHA01_BUILD.log 2>&1
```

- Code de sortie : `0`
- Log : `/private/tmp/SUPRA_ALPHA01_BUILD.log`
- SHA-256 du log : `d641472e97d2e6cf68093b91ea6091159650aaec3e22adff19ff219fe5787f5e`
- Erreurs de compilation : `0`
- Occurrences `warning:` : `64`
- Succès : ligne 2168
- Application : `/private/tmp/SUPRA_ALPHA01_DERIVED/Build/Products/Debug/SUPRA.app`
- Exécutable certifié lors de la capture initiale : SHA-256 `cfd9…` (empreinte complète non conservée dans les preuves transmises ; ne pas utiliser comme ancre cryptographique complète).
- Modules locaux liés : `CAnnoNicoContracts`, `PucheroMemoryAdapter`, `NicoAppAdapter`, `VideoSwapAdapter`.

Une première tentative confinée a retourné `74` à cause des permissions d’environnement/cache. La même construction, exécutée avec les permissions nécessaires, a réussi. Ce premier échec est donc classé environnemental et non comme défaut produit.

## Preuves de lancement

- Processus observé : PID `16000`
- Processus persistant pendant la fenêtre d’observation
- Fenêtre observée : `SUPRA`
- Capture : `/private/tmp/SUPRA_ALPHA01_RUNTIME_LAUNCH.png`
- SHA-256 : `7a27926899fbf913b18944e5d21b569412dc17c2a4e0412f86eb2f490090b281`
- Signature : ad hoc ; identifiant d’application confirmé par `codesign`.
- Crash immédiat : aucun observé.

La capture prouve le rendu minimal, mais montre un Runtime dégradé : `WAITING FOR DATA`, `Standby`, `Health SYNC`, `awaiting publication`, alors qu’un badge affiche `OPERATIONAL`. Cette contradiction est documentée et n’empêche pas ALPHA-02.

## Tests

La suite complète n’a pas terminé : interruption avec code `130` après 113 tests passés. Un échec transitoire a été observé sur le scénario fallback. Son exécution isolée a ensuite réussi :

- Test : `SUPRARuntimeProviderProofTests/testFallbackScenario`
- Résultat isolé : `TEST SUCCEEDED`, code `0`
- Log : `/private/tmp/SUPRA_ALPHA01_FALLBACK_TEST.log`
- SHA-256 : `85b639b5a8ede3566b64b072403d2ac914ab5e65ccae4804cbd92f45b0a8b3dd`

Ce résultat ne transforme pas la suite complète en PASS. La complétude des tests reste un risque MAJEUR, sans être un BLOCKER selon les critères explicites ALPHA-01.

## Intégrité des mutations

ALPHA-01 n’a modifié aucun Swift, Runtime, projet Xcode, Package, asset, script ou document Alpha. Les seuls fichiers créés par la mission sont :

1. `BASELINE_CERTIFICATION_REPORT.md`
2. `BASELINE_ISSUES.md`
3. `BASELINE_ACTION_PLAN.md`
4. `BUILD_LOG.md`
5. `RUNTIME_STATUS.md`

L’intégrité globale du dépôt demeure non certifiable à cause de la baseline dirty préexistante. La non-attribution globale ne remet pas en cause la preuve de build et de lancement de l’état photographié.

## Conclusion binaire

**READY FOR ALPHA-02**
