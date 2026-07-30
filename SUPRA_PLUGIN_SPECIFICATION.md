# Plugin Specification SUPRA

## Principes

1. **Plugin First** — Toute fonctionnalité externe est un plugin
2. **Contrat** — Chaque plugin implémente un protocole Swift
3. **Découverte automatique** — Les plugins sont découverts au démarrage
4. **Aucune modification du Kernel** pour ajouter un plugin

## Protocoles

### SUPRAPlugin (plugin générique)

```swift
protocol SUPRAPlugin: AnyObject {
    var pluginID: String { get }
    var pluginVersion: String { get }
    var pluginCapabilities: [String] { get }
    func onRegister() async
    func onUnregister() async
    func healthCheck() async -> Bool
}
```

### SUPRAProviderPlugin (plugin provider LLM)

```swift
protocol SUPRAProviderPlugin: SUPRAPlugin {
    var declaration: SUPRAProviderPluginDeclaration { get }
    var models: [SUPRAProviderModelDeclaration] { get }
    func execute(prompt: String, systemPrompt: String, modelID: String,
                 maxTokens: Int, temperature: Double) async throws -> String
}
```

## Déclarations

### SUPRAProviderPluginDeclaration

| Propriété | Type | Description |
|-----------|------|-------------|
| pluginID | String | Identifiant unique du plugin |
| providerID | String | Identifiant du provider |
| providerName | String | Nom affiché |
| providerVersion | String | Version |
| capabilities | [String] | Capacités supportées |
| supportsVision | Bool | Vision supportée |
| supportsTools | Bool | Function calling supporté |
| supportsStreaming | Bool | Streaming supporté |
| supportsJSON | Bool | JSON mode supporté |
| supportsEmbeddings | Bool | Embeddings supportés |
| contextWindow | Int | Taille max du contexte |
| maxTokens | Int | Tokens max en sortie |
| isLocal | Bool | Tourne en local |
| costPer1KTokens | Double | Coût pour 1K tokens |
| priority | Int | Priorité (défaut: 0) |
| healthEndpoint | String? | URL health check |

### SUPRAProviderModelDeclaration

| Propriété | Type | Description |
|-----------|------|-------------|
| modelID | String | Identifiant du modèle |
| modelName | String | Nom affiché |
| providerID | String | Provider parent |
| capabilities | [String] | Capacités |
| contextWindow | Int | Contexte max |
| maxTokens | Int | Tokens max |
| supportsVision | Bool | Vision |
| supportsTools | Bool | Tools |
| supportsJSON | Bool | JSON |
| supportsStreaming | Bool | Streaming |
| supportsEmbeddings | Bool | Embeddings |
| isLocal | Bool | Local |
| speed | Int | Vitesse (0-100) |
| costPer1KTokens | Double | Coût |

## Registres

### SUPRAPluginRegistry
- `register(_:)` — Enregistre un plugin générique
- `unregister(_:)` — Désenregistre
- `plugins(capability:)` — Filtre par capacité
- `allHealthy()` — Vérifie la santé de tous

### SUPRAProviderPluginRegistry
- `register(_:)` — Enregistre un plugin provider
- `plugins(capability:)` — Filtre par capacité
- `plugins(local:)` — Filtre local/cloud

### SUPRAPluginDiscovery
- `discoverAll()` — Découvre et enregistre tous les plugins disponibles
- Sources : builtin, bundle, network, configuration

## Ajouter un nouveau provider

1. Créer une classe conforme à `SUPRAProviderPlugin`
2. Déclarer les modèles supportés dans `models`
3. Implémenter `execute(prompt:systemPrompt:modelID:maxTokens:temperature:)`
4. Le plugin est automatiquement découvert au prochain `discoverAll()`

Aucune modification du Kernel. Aucune modification du Decision Engine. Aucune modification du Routing Policy.

## Providers supportés

| Provider | Plugin ID | Status |
|----------|-----------|--------|
| Ollama | ollama | Implémenté |
| OpenAI | openai | Extensible (aucune modif kernel) |
| Anthropic | anthropic | Extensible (aucune modif kernel) |
| Gemini | gemini | Extensible (aucune modif kernel) |
| LM Studio | lmstudio | Extensible (aucune modif kernel) |
| OpenRouter | openrouter | Extensible (aucune modif kernel) |
| vLLM | vllm | Extensible (aucune modif kernel) |
