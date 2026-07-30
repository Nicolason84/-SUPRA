# NUCLEO DUPLICATES — V1

## Mission : NUCLEO_DISCOVERY_001

## Groupe 1 : Schedulers

| Composant | Fichier | Responsabilité | Singleton |
|-----------|---------|----------------|-----------|
| **SUPRAScheduler** | SUPRA/SUPRAScheduler.swift | Ordonnancement priorisé haute priorité | Oui |
| **SUPRABackgroundScheduler** | SUPRA/SUPRABackgroundScheduler.swift | Ordonnancement basse priorité | Oui |

**Analyse :** Deux singletons avec quasi la même responsabilité. Le BackgroundScheduler pourrait être un mode de fonctionnement du Scheduler principal.

**Proposition :** Fusionner en `SUPRAScheduler` avec une option `priority: .background`.

---

## Groupe 2 : Intelligence Engines

| Composant | Fichier | Responsabilité | Singleton |
|-----------|---------|----------------|-----------|
| **SUPRAIntelligenceEngine** | SUPRA/SUPRAIntelligenceEngine.swift | Insights + scoring santé/confiance | Oui |
| **SUPRAEvolutionEngine** | SUPRA/SUPRAEvolutionEngine.swift | Auto-optimisation poste | Oui |
| **SUPRARecommendationEngine** | SUPRA/SUPRARecommendationCenter.swift | Recommandations système | Oui |
| **SUPRAResourceIntelligenceEngine** | SUPRA/SUPRAResourceIntelligenceEngine.swift | Anomalies ressources + gaspillage | Oui |

**Analyse :** Quatre singletons "intelligence" qui semblent faire de l'analyse système. Des responsabilités qui se chevauchent (scoring, optimisation, recommandations, anomalies).

**Proposition :** Fusionner en un `SUPRAIntelligenceHub` avec sous-modules spécialisés, ou au minimum formaliser les interfaces pour éviter le chevauchement.

---

## Groupe 3 : Memory Stores

| Composant | Fichier | Responsabilité | Singleton |
|-----------|---------|----------------|-----------|
| **MultiMemoryStore** | SUPRA/MultiMemoryStore.swift | Store multi-sources mémoire | Oui |
| **ConversationMemoryStore** | SUPRA/ConversationMemoryStore.swift | Mémoire conversations | Oui |
| **CAnnoNicoSnapshotStore** | SUPRA/CAnnoNicoSnapshotStore.swift | Store snapshots CAnnoNico | Oui |
| **ExecutiveMemory** | SUPRA/ExecutiveMemory.swift | Mémoire exécutive | Non |

**Analyse :** Quatre stores mémoire avec des responsabilités proches. `ExecutiveMemory` semble abandonné (0 dépendances).

**Proposition :** Consolider en un `MemoryHub` avec stores spécialisés, ou au minimum un protocole commun `MemoryStore` que tous implémentent.

---

## Groupe 4 : Entry Points

| Composant | Fichier | Responsabilité | Statut |
|-----------|---------|----------------|--------|
| **SUPRAOperationalCoreApp** | SUPRA/SUPRAOperationalCoreApp.swift | @main actuel | ACTIF |
| **SUPRACommandCenterApp** | SUPRA/SUPRACommandCenterApp.swift | @main commenté | LEGACY |
| **SUPRAApp** | SUPRA/SUPRAApp.swift | @main commenté | DEPRECATED |

**Analyse :** Trois @main dans le projet, mais un seul actif. Les deux autres sont commentés mais toujours dans le code.

**Proposition :** Supprimer `SUPRAApp.swift` (DEPRECATED). Conserver `SUPRACommandCenterApp.swift` comme LEGACY pour référence.

---

## Groupe 5 : Decision Systems

| Composant | Fichier | Responsabilité | Singleton |
|-----------|---------|----------------|-----------|
| **SUPRADecisionEngine** | SUPRA/SUPRADecisionEngine.swift | Évaluation evidence → verdict | Oui |
| **SUPRADecisionAuthority** | SUPRA/SUPRADecisionAuthority.swift | Enum autorité | Non |
| **DecisionStore** | SUPRA/DecisionStore.swift | Stockage décisions | Non |
| **SUPRACanonicalWorldAccess** | SUPRA/SUPRACanonicalWorldAccess.swift | Accès unifié état système | Oui |

**Analyse :** Groupe cohérent mais `SUPRACanonicalWorldAccess` a une responsabilité différente (lecture état vs évaluation décision). Devrait être séparé.

**Proposition :** Renommer `SUPRACanonicalWorldAccess` en `SUPRAWorldStateProvider` pour clarifier sa responsabilité.

---

## Groupe 6 : Bridges / Adapters

| Composant | Fichier | Responsabilité | Singleton |
|-----------|---------|----------------|-----------|
| **SUPRATerminalMegabusBridge** | SUPRA/Infrastructure/SUPRATerminalMegabusBridge.swift | Pont MEGABUS inter-terminal | Non |
| **SUPRAChatRuntimeAdapter** | SUPRA/SUPRAChatRuntimeAdapter.swift | Adaptateur chat → runtime | Non |
| **OpenCodeBridge** | SUPRA/OpenCodeBridge.swift | Pont BridgeCommand/Response | Oui |
| **RuntimeGateway** | SUPRA/RuntimeGateway.swift | Event bus + BridgeRequest/Response | Oui |

**Analyse :** Quatre mécanismes de pont/adaptateur/bus. `RuntimeGateway` joue le rôle de hub central, les trois autres sont des adaptateurs spécifiques. Leurs responsabilités sont distinctes mais leur architecture pourrait être harmonisée.

**Proposition :** Formaliser un protocole `Bridge` commun. `RuntimeGateway` devient le `BridgeManager`.

---

## Résumé des doublons

| Groupe | Nb composants | Action recommandée | Priorité |
|--------|---------------|-------------------|----------|
| 1. Schedulers | 2 | Fusionner | Moyenne |
| 2. Intelligence Engines | 4 | Refactorer en hub | Haute |
| 3. Memory Stores | 4 | Consolider | Haute |
| 4. Entry Points | 3 | Nettoyer | Haute |
| 5. Decision Systems | 4 | Clarifier responsabilités | Basse |
| 6. Bridges/Adapters | 4 | Harmoniser architecture | Moyenne |
