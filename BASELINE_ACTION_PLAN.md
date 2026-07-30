# ALPHA-01 — Baseline Action Plan

## Principe

Ce plan ne lance aucune correction. Il ordonne les suites nécessaires en conservant la décision `READY FOR ALPHA-02`. Toute mutation reste soumise au pipeline Single Writer et à une mission explicite.

L’unique action d’hygiène déjà exécutée est le retrait de `default.profraw` (0 octet), artefact de profilage produit pendant le lancement ALPHA-01 ; elle n’affecte aucun fichier source.

| Priorité | Action | Owner | Échéance logique | Entrée | Validation attendue | Rollback |
|---:|---|---|---|---|---|---|
| 1 | Geler une référence Git attribuable de la baseline | Governance + SUPRA-Builder | Avant première mutation ALPHA-02 | HEAD `80ca2f…`, status initial, cinq rapports ALPHA-01 | manifeste des fichiers, hashes, diff et propriétaire ; 0 ambiguïté sur le delta ALPHA | revenir au snapshot documenté, sans reset destructif |
| 2 | Conserver un build smoke identique comme gate | Quality Gate Lead | Chaque mission ALPHA | commande de `BUILD_LOG.md` | code 0, 0 erreur, application produite | annuler uniquement le patch de la mission |
| 3 | Relancer la suite complète dans une session stable | Quality Gate Lead | Avant certification de toute modification Runtime | projet inchangé et DerivedData dédiée | suite terminée, code 0, résumé `.xcresult` archivé | aucune mutation produit ; supprimer seulement les caches temporaires si autorisé |
| 4 | Stabiliser le test fallback | Runtime owner + SUPRA-Builder | Avant ALPHA-04 | BL-006 et test isolé PASS | répétitions isolées et suite complète sans intermittence | revert du patch ciblé |
| 5 | Faire dériver l’état Executive de la vérité Runtime existante | Executive Surface owner | ALPHA-02, confirmé ALPHA-04 | BL-002 et BL-009 | aucun badge `OPERATIONAL` si snapshot absent/non publié | restaurer la projection précédente |
| 6 | Diagnostiquer le bootstrap et la publication Runtime | Runtime owner | ALPHA-04 | chaîne d’entrée de `RUNTIME_STATUS.md` | snapshot publié, horodaté, visible ; absence de crash | désactiver le raccord ciblé et revenir à l’état d’attente connu |
| 7 | Valider Memory sur le Runtime existant | Memory owner | ALPHA-05 | baseline runtime stabilisée | lecture/écriture contrôlées et preuve de persistance | restaurer le store/snapshot de test |
| 8 | Corriger le script d’installation | Tooling owner + SUPRA-Builder | Avant industrialisation/installation | BL-007 | `bash -n GO_SUPRA_INSTALL.sh` retourne 0 et smoke en environnement temporaire | revert du patch script |
| 9 | Résorber les warnings Swift 6 par lots atomiques | Owners des composants + SUPRA-Builder | Avant passage Swift 6 strict | BL-004 | aucun nouveau warning ; tests ciblés ; build complet | revert du lot concerné |
| 10 | Ajouter une preuve de logs persistants | Observability owner | ALPHA-08 | BL-011 | log corrélé mission/exécution, relisible après relance | désactiver le sink ajouté et conserver la console |
| 11 | Fournir l’AppIcon approuvé | UI owner + SUPRA-Builder | Après surface/navigation stabilisées | BL-008 | catalogue sans warning et rendu packaging | restaurer le catalogue précédent |
| 12 | Assainir les artefacts atypiques | Governance + SUPRA-Builder | Après snapshot de traçabilité | BL-012 | inventaire explicite, scripts robustes | restaurer les artefacts depuis le snapshot |

## Gates recommandés

- Avant ALPHA-02 : action 1 obligatoire pour attribuer proprement les futures mutations.
- Avant ALPHA-04 : actions 2 et 3 ; action 4 si la flakiness se reproduit.
- Avant ALPHA-06/07 : Runtime publié et état exécutif cohérent.
- Avant ALPHA-08 : définir la rétention et la corrélation des logs.
- Avant ALPHA-10 : suite complète terminée, warnings critiques traités ou acceptés explicitement, installation et rollback testés.

## Non-actions ALPHA-01

- Aucun correctif produit appliqué.
- Aucun Swift, Runtime, Xcode, Package, asset ou script modifié.
- Aucun problème non bloquant promu artificiellement au rang de BLOCKER.
