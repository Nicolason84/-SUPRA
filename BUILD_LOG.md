# ALPHA-01 — Build Evidence Log

## Exécution certifiée

```sh
xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx -derivedDataPath /private/tmp/SUPRA_ALPHA01_DERIVED build > /private/tmp/SUPRA_ALPHA01_BUILD.log 2>&1
```

| Élément | Valeur |
|---|---|
| Projet | `SUPRA.xcodeproj` |
| Scheme | `SUPRA` |
| Configuration | `Debug` |
| SDK | `macosx` |
| DerivedData | `/private/tmp/SUPRA_ALPHA01_DERIVED` |
| Code de sortie | `0` |
| Résultat | `BUILD SUCCEEDED` |
| Ligne de succès | 2168 |
| Erreurs | 0 |
| Occurrences `warning:` | 64 |
| Log brut | `/private/tmp/SUPRA_ALPHA01_BUILD.log` |
| SHA-256 log | `d641472e97d2e6cf68093b91ea6091159650aaec3e22adff19ff219fe5787f5e` |
| App | `/private/tmp/SUPRA_ALPHA01_DERIVED/Build/Products/Debug/SUPRA.app` |

L’empreinte initialement relevée pour l’exécutable a été consignée sous forme abrégée `cfd9…`; faute d’empreinte complète conservée dans le jeu de preuves transmis, elle n’est pas déclarée comme preuve cryptographique complète. Le log de build et la capture runtime disposent, eux, d’empreintes complètes.

Le lancement instrumenté a généré à la racine `default.profraw`, vide (0 octet). Cet artefact de profilage temporaire a été retiré avant la certification Git finale.

## Dépendances observées

La résolution et l’édition de liens locales ont réussi. Les quatre modules CAnnoNico présents dans la ligne de link SUPRA sont :

- `CAnnoNicoContracts`
- `PucheroMemoryAdapter`
- `NicoAppAdapter`
- `VideoSwapAdapter`

Aucun diff `Package.swift` ou `Package.resolved` n’a été observé dans la photographie initiale. Aucune dépendance n’a été ajoutée.

## Avertissements critiques pour évolution Swift 6

Les messages suivants sont explicitement annoncés comme erreurs dans le mode Swift 6 :

- Captures concurrentes de `self` : `SUPRABackgroundScheduler.swift:48,140`, `SUPRAPassiveRefreshCoordinator.swift:43`, `SUPRAResourceGovernor.swift:83`, `SUPRAResourceIntelligenceEngine.swift:58`, `SUPRAResourceIntelligenceView.swift:39`, `ContentView.swift:3128`.
- Accès non isolé à des propriétés `@MainActor` : `SUPRACanonicalWorldAccess.swift:242`, `WorkspaceDiscovery.swift:17`, `MissionContext.swift:36`, `ExecutiveCockpitFoundation.swift:80`, `ExecutiveSearch.swift:46`, `RuntimeDataService.swift:424,425,429`.
- Conformances isolées utilisées hors isolation : `ConversationMemoryStore.swift:574,583,698,828`.

Les autres warnings concernent principalement des valeurs inutilisées, résultats ignorés, interpolation optionnelle et API dépréciées. Ils ne font pas échouer la configuration actuelle.

## Essais

La suite complète a été interrompue avec code `130` après 113 tests passés. Elle n’est donc pas certifiée PASS.

Rerun ciblé :

```sh
xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx -derivedDataPath /private/tmp/SUPRA_ALPHA01_DERIVED -only-testing:SUPRATests/SUPRARuntimeProviderProofTests/testFallbackScenario test > /private/tmp/SUPRA_ALPHA01_FALLBACK_TEST.log 2>&1
```

| Élément | Valeur |
|---|---|
| Code de sortie | `0` |
| Résultat | `TEST SUCCEEDED` |
| SHA-256 | `85b639b5a8ede3566b64b072403d2ac914ab5e65ccae4804cbd92f45b0a8b3dd` |

## Incident environnemental initial

Une première construction confinée a échoué avec le code `74` sur des permissions de cache/environnement. L’exécution autorisée de la même construction a réussi. L’incident n’est pas classé comme erreur de compilation du produit.
