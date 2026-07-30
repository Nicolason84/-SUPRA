# SUPRA — PREMATCH LOT 1

Date: 2026-07-27
Mode: READ-ONLY DISCOVERY COMPLETED

## EXISTE

- 'SUPRA/SUPRACompositionRoot.swift': unique 'SUPRACompositionRoot', '@MainActor', singleton canonique.
- 'SUPRA/SUPRAOperationalCoreApp.swift': unique active '@main'; injecte les dépendances du Root dans SwiftUI.
- 'RuntimeDataService': service de données Runtime existant, avec singleton historique réutilisé par le Root.
- 'MissionStore', 'DecisionStore': stores existants, construits par le Root.
- 'RuntimeMonitor': monitor existant, construit par le Root avec 'RuntimeDataService'.
- 'SUPRARuntimeEvents': Event Bus existant, singleton réutilisé par le Root.
- 'ControlTowerState': état de contrôle existant, construit par le Root avec le service et le monitor.
- 'Governance/validate_governance.sh': gate statique LOT 0 déjà exécutable.

## MANQUANT

- Une chaîne d’exécution build/test/smoke automatisée persistée comme artefact LOT 1.
- Une métrique Runtime formalisée pour les injections et services actifs.
- Une migration complète des autorités historiques vers le Root (hors périmètre sûr de ce lot).

## DUPLIQUÉ

- Aucun doublon de déclaration 'SUPRACompositionRoot'.
- Aucun second '@main' actif.
- Aucun doublon détecté pour les constructions 'MissionStore', 'DecisionStore', 'RuntimeMonitor' ou 'RuntimeDataService' hors exceptions canoniques.
- Des singletons historiques existent ('RuntimeDataService.shared', Event Bus et autres autorités), mais ne constituent pas une seconde construction dans le Root.

## OBSOLÈTE

- Les anciennes déclarations '@main' sont commentées et non actives.
- Les registres historiques à la racine restent des sources d’audit, pas des moteurs d’exécution.

## À FUSIONNER

- Les futures dépendances d’interface doivent être ajoutées au Root avant injection SwiftUI.
- Les contrôles de gouvernance LOT 0 doivent précéder tout build de lot.
- Les métriques d’exécution peuvent être raccordées au Event Bus et au Runtime Monitor existants.

## À PROTÉGER

- 'FREEZE_V1.md' et les freezes existants.
- 'SUPRA/SUPRACompositionRoot.swift'.
- 'SUPRA/SUPRAOperationalCoreApp.swift'.
- 'Governance/*'.
- Le comportement des stores, du monitor, du service Runtime et de l’Event Bus.

## Décision de pré-matching

'REUSE' + 'CANONIZE' + 'ADAPTER'. Aucun nouveau Runtime, Scheduler, Store, pipeline ou moteur n’est autorisé par ce lot.
