# SUPRA — EXECUTIVE LOT 1 REPORT

Date: 2026-07-27
Status: BLOCKED — NOT FROZEN

## Architecture avant

Les services Runtime, stores et monitor existaient déjà, avec des points d’accès singleton historiques et une composition partiellement dispersée dans l’interface.

## Architecture après

'SUPRACompositionRoot' est la source canonique de résolution pour 'RuntimeDataService', 'MissionStore', 'DecisionStore', 'RuntimeMonitor', 'SUPRARuntimeEvents' et 'ControlTowerState'. 'SUPRAOperationalCoreApp' injecte ces instances dans SwiftUI.

## Composants fusionnés

- Les responsabilités de composition des services ciblés sont regroupées dans 'SUPRACompositionRoot'.
- Aucun moteur fonctionnel n’a été réécrit.

## Composants supprimés

Aucun. Aucun composant validé n’a été supprimé.

## Composants conservés

Runtime, stores, monitor, Event Bus, Control Tower, SwiftUI et autorités historiques restent en place.

## Qualité et preuves

- Pre-matching : PASS
- Governance validator : PASS (33 PASS, 0 WARN, 0 FAIL)
- JSON registries : PASS
- Syntaxe du validator : PASS
- Build Xcode Debug macOS : BUILD SUCCEEDED
- Smoke : PASS (SUPRA_SmokeTests.testModuleImports)
- Tests : FAIL — SUPRARuntimeProviderProofTests.testFallbackScenario(), SUPRAConversationMemoryAsyncTests.testINDEX_FILE_EXCLUDED_FROM_SCAN(), SUPRAConversationMemoryAsyncTests.testUNCHANGED_FILES_NOT_REPARSED()

## Dette technique restante

- Singletons historiques à migrer progressivement.
- Observabilité d’injection et métriques de pipeline à formaliser.
- Autorités globales hors Root à traiter par un lot séparé et validé.

## Risques

Le risque principal est la migration prématurée des autorités historiques. Elle est explicitement reportée afin de préserver le comportement validé.

Les échecs de tests sont antérieurs au périmètre documentaire de ce lot et aucun correctif métier n’a été introduit. Le freeze est volontairement refusé jusqu’à résolution et revalidation de ces tests.

## Recommandations

1. Exécuter 'Governance/validate_governance.sh' avant chaque build.
2. Ajouter les futures dépendances au Root uniquement.
3. Préparer un lot séparé pour les autorités historiques, avec tests et smoke dédiés.
