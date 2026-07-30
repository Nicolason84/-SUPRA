# Architecture Provider — Souveraine et Extensible

## Principes architecturaux

1. **Souveraineté** — Le kernel ne dépend d'aucun provider externe
2. **Plugins** — Chaque provider est un plugin interchangeable
3. **Sélection par capacité** — Le Provider Broker choisit par capacité, pas par nom
4. **Fallback** — Chaîne de fallback automatique en cas d'échec
5. **Timeout** — 30s standard, 60s pour les modèles reasoning

## Architecture en couches

```
┌──────────────────────────────────────┐
│           SUPRAProviderProtocols     │  ← Foundation
│   SUPRAProvider (protocol)           │
│   SUPRAExecutor (protocol)           │
│   SUPRAProviderType (enum)           │
│   SUPRACapability (enum)             │
└──────────────────┬───────────────────┘
                   │ conforme
┌──────────────────▼───────────────────┐
│           SUPRAOllamaProvider        │  ← Plugin
│   HTTP POST /api/generate            │
│   Health check périodique            │
│   Timeout configurable               │
│   Modèle configurable                │
└──────────────────┬───────────────────┘
                   │ enregistré dans
┌──────────────────▼───────────────────┐
│           SUPRAProviderRegistry      │  ← Registry
│   register(provider)                 │
│   provider(for:)                     │
│   activeProvider                     │
└──────────────────┬───────────────────┘
                   │ utilisé par
┌──────────────────▼───────────────────┐
│           SUPRAProviderBroker        │  ← Broker
│   execute(request)                   │
│   Fallback chain                     │
│   Timeout management                 │
│   Health check                       │
└──────────────────────────────────────┘
```

## Extension à un nouveau provider

```swift
final class SUPRAOpenAIProvider: SUPRAProvider {
    var type: SUPRAProviderType { .openai }
    var isAvailable: Bool { /* check API key */ }
    var supportedModels: [String] { ["gpt-4", "gpt-4o"] }
    var capabilities: [SUPRACapability] { [.reasoning, .conversation, .analysis, .coding] }

    func execute(_ request: SUPRAExecutionRequest) async throws -> SUPRAProviderResponse {
        // Appel API OpenAI
    }
}
```

Puis dans SUPRAAliveDemo.bootstrap() :
```swift
providerRegistry.register(SUPRAOpenAIProvider())
```

Aucune modification du kernel requise.

## Types de providers supportés

| Provider | Status |
|----------|--------|
| Ollama (localhost) | Implémenté |
| OpenAI | Extensible |
| Anthropic | Extensible |
| Google Gemini | Extensible |
| AWS Bedrock | Extensible |
| Azure OpenAI | Extensible |
| HuggingFace | Extensible |
