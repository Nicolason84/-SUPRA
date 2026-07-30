# SUPRA — EXECUTIVE COMPOSITION ROOT

## Autorité canonique

'SUPRA/SUPRACompositionRoot.swift' est l’unique point de composition pour les dépendances Runtime consolidées.

Responsabilités actuelles :

- résolution de 'RuntimeDataService'
- création de 'MissionStore'
- création de 'DecisionStore'
- création de 'RuntimeMonitor'
- résolution de 'SUPRARuntimeEvents'
- création de 'ControlTowerState'
- exposition des instances à SwiftUI

## Injection SwiftUI

'SUPRA/SUPRAOperationalCoreApp.swift' possède le seul '@main' actif et injecte les instances du Root via 'environmentObject'.

App → SUPRACompositionRoot.shared → environmentObject → Views / States

## Invariants

1. Aucun View ne construit directement un store ou un monitor.
2. Aucun service ciblé ne construit un autre service ciblé.
3. Toute nouvelle dépendance doit être ajoutée au Root avant son injection.
4. Le Root ne remplace aucun Runtime ou pipeline existant.
5. Les singletons historiques sont réutilisés uniquement comme compatibilité.

## Périmètre

Ce Root consolide les dépendances validées du LOT 1. Les autres autorités ('SUPRANucleoOrchestrator', 'SUPRAResourceGovernor', snapshot store et boot manager) restent des composants existants, conservés sans duplication ni migration risquée dans ce lot.
