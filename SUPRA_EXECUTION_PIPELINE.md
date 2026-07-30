# SUPRA EXECUTION PIPELINE — V1

## Mission : SUPRA_ALIVE_BOOTSTRAP_004

## Spécification de la chaîne d'exécution

---

### Étape 1 : Utilisateur → Mission

**Flux :**
1. L'utilisateur soumet une requête via l'UI SwiftUI (ContentView, MissionCenterView, ou SUPRACompanionView)
2. La vue appelle `MissionStore.create(from: userInput)`
3. `MissionStore` crée une `Mission` avec `status: .planned`

**Entrée :** `String` (requête utilisateur)
**Sortie :** `Mission` avec `id`, `title`, `status: .planned`
**Responsable :** `MissionStore` (existant)

**Interface :**
```swift
extension MissionStore {
    func create(from text: String, priority: Mission.Priority = .medium) -> Mission
}
```

**État :** Existant — MissionStore a déjà les méthodes de CRUD.

---

### Étape 2 : Mission → Kernel

**Flux :**
1. La Mission est enrichie par `MissionContext.prepare(for:)`
2. `NOVAKnowledgeKernel` fournit le contexte pertinent (objets, relations, sources)
3. Le contexte enrichi est passé au Mission Broker

**Entrée :** `Mission`
**Sortie :** `MissionContext` avec données du Kernel
**Responsable :** `MissionContext` + `NOVAKnowledgeKernel`

**Interface :**
```swift
extension MissionContext {
    func prepare(for mission: Mission, from kernel: NOVAKnowledgeKernel) async -> PreparedMission
}
```

**État :** Existant — MissionContext.prepare() et Kernel existent.

---

### Étape 3 : Mission Broker (À CRÉER)

**Flux :**
1. Le `SUPRAMissionBroker` reçoit une `PreparedMission`
2. Il analyse la mission pour déterminer :
   - Le type d'exécution (simple, recherche, analyse, action)
   - Le provider approprié (Ollama, OpenAI, etc.)
   - Le modèle approprié (deepseek, gpt-4, claude, etc.)
3. Il construit un `ExecutionRequest` structuré

**Entrée :** `PreparedMission`
**Sortie :** `ExecutionRequest`
**Responsable :** `SUPRAMissionBroker` (NOUVEAU)

**Interface proposée :**
```swift
struct PreparedMission {
    let mission: Mission
    let context: MissionContext
    let kernelSnapshot: KnowledgeSnapshot
}

struct ExecutionRequest {
    let id: UUID
    let prompt: String
    let systemPrompt: String
    let preferredProvider: ProviderType?
    let preferredModel: String?
    let maxTokens: Int
    let temperature: Double
    let requiresTools: Bool
}

@MainActor
final class SUPRAMissionBroker: ObservableObject {
    static let shared = SUPRAMissionBroker()
    
    func route(_ mission: PreparedMission) async -> ExecutionRequest
    func selectProvider(for request: ExecutionRequest) -> ProviderType
    func selectModel(for request: ExecutionRequest) -> String
}
```

**État :** NOUVEAU — À CRÉER (1 fichier Swift)

---

### Étape 4 : Provider Broker (À CRÉER)

**Flux :**
1. Le `SUPRAProviderBroker` reçoit un `ExecutionRequest`
2. Il sélectionne le provider configuré pour ce type de requête
3. Il appelle le provider (Ollama, OpenAI, etc.)
4. Il retourne la réponse brute

**Entrée :** `ExecutionRequest`
**Sortie :** `ProviderResponse`
**Responsable :** `SUPRAProviderBroker`

**Interface proposée :**
```swift
enum ProviderType: String, Codable, CaseIterable {
    case ollama
    case openAI
    case anthropic
    case gemini
    case codex
    case lmStudio
    case openRouter
    case vLLM
}

struct ProviderResponse {
    let content: String
    let model: String
    let provider: ProviderType
    let durationMs: Int
    let tokensIn: Int
    let tokensOut: Int
    let raw: Data?
}

protocol SUPRAProvider: AnyObject {
    var type: ProviderType { get }
    var isAvailable: Bool { get }
    func execute(request: ExecutionRequest) async throws -> ProviderResponse
    func checkHealth() async -> Bool
}

@MainActor
final class SUPRAProviderBroker: ObservableObject {
    static let shared = SUPRAProviderBroker()
    
    func register(_ provider: SUPRAProvider)
    func execute(request: ExecutionRequest) async throws -> ProviderResponse
    func availableProviders() -> [ProviderType]
}
```

**État :** NOUVEAU — À CRÉER (1 protocole + 1 broker + N providers)

---

### Étape 5 : Providers LLM (À CRÉER)

Chaque provider implémente `SUPRAProvider` :

| Provider | Type | Transport | Configuration |
|----------|------|-----------|---------------|
| SUPRAOllamaProvider | `.ollama` | HTTP localhost:11434 | Modèle par défaut: deepseek-r1 |
| SUPRAOpenAIProvider | `.openAI` | HTTPS api.openai.com | API key + modèle |
| SUPRAAnthropicProvider | `.anthropic` | HTTPS api.anthropic.com | API key + modèle |
| SUPRAGeminiProvider | `.gemini` | HTTPS generativeai.google.com | API key + modèle |
| SUPRACodexProvider | `.codex` | Local | Intégration macOS native |
| SUPRALMStudioProvider | `.lmStudio` | HTTP localhost:1234 | Endpoint configurable |
| SUPRAOpenRouterProvider | `.openRouter` | HTTPS openrouter.ai | API key + modèle |
| SUPRAvLLMProvider | `.vLLM` | HTTP configurable | Endpoint configurable |

**Tous les providers sont des plugins interchangeables.**
Le Kernel n'a aucune connaissance du provider utilisé.

**État :** NOUVEAU — À CRÉER (N fichiers, 1 par provider)

---

### Étape 6 : Executor → LLM (MODIFIER SUPRAMissionExecutor)

**Flux :**
1. `SUPRAMissionExecutor` reçoit un `ExecutionRequest` validé
2. Il appelle `SUPRAProviderBroker.execute(request:)`
3. Il reçoit une `ProviderResponse`
4. Il crée un `ExecutionRecord` avec le résultat

**Entrée :** `ExecutionRequest`
**Sortie :** `ExecutionRecord` + `ProviderResponse`
**Responsable :** `SUPRAMissionExecutor` (existant, à modifier)

**Modification :**
```swift
// Actuellement : SUPRAMissionExecutor.execute() est une coquille vide
// Qui ne fait que vérifier les autorisations sans rien exécuter

// Nouveau comportement :
func execute(_ proposal: MissionProposal) async -> ExecutionRecord {
    // 1. Vérifier autorisation (existant)
    // 2. Construire ExecutionRequest via MissionBroker
    // 3. Appeler ProviderBroker.execute()
    // 4. Enregistrer le résultat
    // 5. Retourner l'ExecutionRecord
}
```

**État :** MODIFICATION — SUPRAMissionExecutor.execute() doit être implémenté

---

### Étape 7 : Réponse → Decision

**Flux :**
1. La `ProviderResponse` est évaluée par `SUPRADecisionEngine.evaluate(evidence:)`
2. Le verdict est enregistré dans `DecisionStore`
3. Si le verdict est `autoExecute`, l'action est exécutée automatiquement
4. Si le verdict est `supervised` ou `humanRequired`, l'UI est notifiée

**Entrée :** `ProviderResponse`
**Sortie :** `DecisionVerdict`
**Responsable :** `SUPRADecisionEngine` (existant)

**Interface :**
```swift
extension SUPRADecisionEngine {
    static func evaluate(response: ProviderResponse, mission: Mission) -> DecisionVerdict
}

extension DecisionStore {
    func record(_ verdict: DecisionVerdict, for mission: Mission)
}
```

**État :** Existant — DecisionEngine + DecisionAuthority + DecisionStore sont complets

---

### Étape 8 : Decision → Memory

**Flux :**
1. Après décision, le résultat est stocké dans la mémoire
2. `MultiMemoryStore.rebuild()` est déclenché
3. `CAnnoNicoSnapshotStore.refreshAsync()` est déclenché
4. `ExecutiveMemory.build(from:)` est mis à jour

**Entrée :** `DecisionVerdict` + `ProviderResponse`
**Sortie :** Mise à jour des stores mémoire
**Responsable :** `MultiMemoryStore`, `CAnnoNicoSnapshotStore`

**État :** Existant — les stores mémoire ont déjà les méthodes nécessaires

---

### Étape 9 : Memory → UI

**Flux :**
1. Les @Published properties des stores mémoire sont automatiquement propagées
2. Les vues SwiftUI observent ces changements via `@StateObject` / `@ObservedObject`
3. L'interface utilisateur se met à jour automatiquement

**Entrée :** Événements Combine des stores
**Sortie :** Mise à jour UI
**Responsable :** SwiftUI Combine (existant)

**État :** Existant — l'architecture Combine/SwiftUI gère déjà ce flux

---

### Résumé des créations/modifications

| # | Composant | Action | Fichier |
|---|-----------|--------|---------|
| 1 | SUPRAMissionBroker | CRÉER | SUPRA/SUPRAMissionBroker.swift |
| 2 | SUPRAProviderProtocol | CRÉER | SUPRA/SUPRAProviderProtocol.swift |
| 3 | SUPRAProviderBroker | CRÉER | SUPRA/SUPRAProviderBroker.swift |
| 4 | SUPRAOllamaProvider | CRÉER | SUPRA/SUPRAOllamaProvider.swift |
| 5 | SUPRAOpenAIProvider | CRÉER | SUPRA/SUPRAOpenAIProvider.swift |
| 6 | SUPRAMissionExecutor | MODIFIER | SUPRA/SUPRAMissionExecutor.swift |
| 7 | ProviderResponse model | CRÉER | (dans RuntimeModels ou fichier dédié) |
| 8 | ExecutionRequest model | CRÉER | (dans RuntimeModels ou fichier dédié) |

**Total :** 6 créations, 1 modification — c'est le minimum vital pour la boucle.
