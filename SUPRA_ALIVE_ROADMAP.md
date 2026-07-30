# SUPRA ALIVE ROADMAP — V1

## Mission : SUPRA_ALIVE_BOOTSTRAP_004

## Feuille de route d'activation

### Principe

Chaque phase rend SUPRA plus vivant. On ne sort de la phase N que quand elle produit un résultat démontrable.

---

## PHASE 1 : SUPRA répond à une mission simple

**Objectif :** Un utilisateur envoie un message → SUPRA répond via Ollama (LLM local).

### Composants à créer (6 fichiers Swift)

| Fichier | Contenu | Dépend de |
|---------|---------|-----------|
| `SUPRAProviderProtocol.swift` | Protocole `SUPRAProvider` + types `ProviderType`, `ExecutionRequest`, `ProviderResponse` | Rien |
| `SUPRAProviderBroker.swift` | Broker singleton : register, execute, fallback, health check | Protocole |
| `SUPRAOllamaProvider.swift` | Provider Ollama : HTTP POST vers localhost:11434/api/generate | Protocole |
| `SUPRAMissionBroker.swift` | Broker mission : traduit PreparedMission → ExecutionRequest | Kernel |
| `SUPRAFallbackProvider.swift` | Provider de dernier recours : réponses templates en local | Protocole |

### Composants à modifier (1 fichier Swift)

| Fichier | Modification |
|---------|-------------|
| `SUPRAMissionExecutor.swift` | `execute()` devient async, appelle ProviderBroker, retourne réponse |

### Test de validation

```
Entrée : "Quelle est l'utilisation CPU actuelle ?"
Pipeline : Utilisateur → MissionStore → MissionBroker → ProviderBroker → OllamaProvider → Réponse
Sortie attendue : Réponse textuelle avec la métrique CPU (via contexte Kernel → prompt enrichi)
```

### Code minimal de SUPRAOllamaProvider

```swift
final class SUPRAOllamaProvider: SUPRAProvider {
    let type: ProviderType = .ollama
    var isAvailable: Bool = false
    private let session = URLSession.shared
    private let baseURL = URL(string: "http://localhost:11434")!
    
    func execute(request: ExecutionRequest) async throws -> ProviderResponse {
        let body = OllamaRequest(model: request.preferredModel ?? "deepseek-r1",
                                 prompt: request.prompt,
                                 system: request.systemPrompt,
                                 options: ["num_predict": request.maxTokens,
                                           "temperature": request.temperature])
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent("api/generate"))
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = try JSONEncoder().encode(body)
        let start = Date()
        let (data, _) = try await session.data(for: urlRequest)
        let duration = Date().timeIntervalSince(start)
        let response = try JSONDecoder().decode(OllamaResponse.self, from: data)
        return ProviderResponse(content: response.response, model: response.model,
                                provider: .ollama, durationMs: Int(duration * 1000),
                                tokensIn: 0, tokensOut: response.tokensEvaluated ?? 0, raw: data)
    }
}
```

### Critère de succès PHASE 1

✅ Une mission simple produit une réponse textuelle.
✅ Ollama est le provider par défaut (souveraineté locale).
✅ Aucune dépendance cloud.

---

## PHASE 2 : SUPRA mémorise

**Objectif :** Les réponses LLM sont stockées en mémoire et réutilisables.

### Travaux

| Action | Composant |
|--------|-----------|
| Connecter `SUPRAMissionExecutor` → `DecisionStore.record()` | 1 modification |
| Connecter `DecisionStore` → `MultiMemoryStore.rebuild()` | 1 modification |
| Connecter `MultiMemoryStore` → `ExecutiveMemory.build(from:)` | 1 modification |
| Connecter `SUPRANucleoOrchestrator` → `RuntimeGateway` notification | 1 modification |
| Ajouter l'historique des missions dans l'UI | Interface existante |

### Test de validation

```
Entrée : "Rappelle-moi la réponse à la question CPU"
Pipeline : Mission → MemoryStore → ExecutiveMemory.query() → Réponse
Sortie : La réponse précédente est retrouvée
```

### Critère de succès PHASE 2

✅ Les réponses sont persistées.
✅ Les réponses sont retrouvables par requête.
✅ L'historique est visible dans l'UI.

---

## PHASE 3 : SUPRA décide

**Objectif :** Le système évalue les réponses LLM et décide d'agir automatiquement ou de demander validation.

### Travaux

| Action | Composant |
|--------|-----------|
| Connecter `ProviderResponse` → `SUPRADecisionEngine.evaluate()` | 1 modification |
| Connecter le verdict → `SUPRAMissionExecutor` | 1 modification |
| Ajouter le niveau d'autonomie dans l'UI | UI existante |
| Implémenter la file supervision/human dans l'UI | UI existante (SUPRAAutonomyControlView) |

### Test de validation

```
Entrée : Mission à auto-exécuter (ex: "Nettoyer la corbeille")
Pipeline : ProviderResponse → DecisionEngine.evaluate() → verdict .autoExecute → execution réelle
Sortie : La corbeille est vidée sans intervention humaine
```

### Critère de succès PHASE 3

✅ Les décisions sont évaluées automatiquement.
✅ Les missions simples sont auto-exécutées.
✅ Les missions complexes sont redirigées vers supervision/humain.
✅ L'utilisateur peut configurer le niveau d'autonomie.

---

## PHASE 4 : SUPRA orchestre plusieurs modèles

**Objectif :** Le système route chaque mission vers le meilleur modèle/provider.

### Travaux

| Action | Composant |
|--------|-----------|
| Implémenter OpenAI provider | `SUPRAOpenAIProvider.swift` |
| Implémenter Anthropic provider | `SUPRAAnthropicProvider.swift` |
| Implémenter Gemini provider | `SUPRAGeminiProvider.swift` |
| Ajouter le routage intelligent dans MissionBroker | `SUPRAMissionBroker.selectProvider()` |
| Ajouter le fallback automatique | `SUPRAProviderBroker` |
| UI de configuration des providers | Nouvelle vue ou existante |

### Logique de routage

```
Mission simple / locale      → Ollama (deepseek-r1)
Mission code / technique     → Codex ou Ollama
Mission complexe / créative  → OpenAI (gpt-4) ou Anthropic (claude)
Mission recherche            → Gemini ou OpenRouter
Fallback si indisponible     → Provider suivant dans la liste
Dernier recours              → SUPRAFallbackProvider
```

### Critère de succès PHASE 4

✅ Au moins 3 providers fonctionnent simultanément.
✅ Le routage choisit le bon provider par type de mission.
✅ Le fallback fonctionne (si Ollama down → OpenAI, etc.).
✅ L'utilisateur peut configurer ses providers.

---

## PHASE 5 : SUPRA apprend

**Objectif :** Le système améliore ses réponses au fil du temps via feedback et mémoire.

### Travaux

| Action | Composant |
|--------|-----------|
| Feedback utilisateur sur les réponses | UI + store |
| Amélioration des prompts système | ContextEngine |
| Détection d'échecs et correction | IntelligenceEngine |
| Évolution automatique des templates | EvolutionEngine |
| Métriques de qualité des réponses | SUPRAIntelligenceState |

### Critère de succès PHASE 5

✅ Le système s'améliore avec l'usage.
✅ Les échecs sont détectés et corrigés.
✅ Les prompts système évoluent automatiquement.

---

## Estimation globale

| Phase | Fichiers à créer | Fichiers à modifier | Effort estimé |
|-------|-----------------|---------------------|---------------|
| PHASE 1 | 5 | 1 | 2-3 jours |
| PHASE 2 | 0 | 4 | 1 jour |
| PHASE 3 | 0 | 3 | 0.5 jour |
| PHASE 4 | 3-5 | 2 | 2-3 jours |
| PHASE 5 | 0 | 4 | 1-2 jours |
| **Total** | **8-10** | **14** | **6.5-9.5 jours** |

## Dépendances entre phases

```
PHASE 1 ──→ PHASE 2 ──→ PHASE 3
                │              │
                └──→ PHASE 4 ──┘
                            │
                            └──→ PHASE 5
```

PHASE 1 est le seul pré-requis bloquant. Les phases 2, 3, 4 peuvent être parallélisées après.
