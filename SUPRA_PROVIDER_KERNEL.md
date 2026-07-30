# SUPRA PROVIDER KERNEL V1

## Abstraction Providers — Interfaces, Contrats, Politiques de Bascule, Résilience

| Propriété | Valeur |
|-----------|--------|
| **Statut** | CORE — Provider Kernel |
| **Version** | SUPRA_PROVIDER_KERNEL_V1 |
| **Date** | 2026-07-29 |
| **Autorité** | CORE — Préparation aux futures intégrations sans implémentation |
| **Sources absorbées** | SUPRA_PROVIDER_ARCHITECTURE.md, SUPRA_PROVIDER_RUNTIME_REPORT.md, protocoles existants |

---

## 1. Principes Fondamentaux

| Principe | Description |
|----------|-------------|
| **Souveraineté** | Le kernel ne dépend d'aucun provider externe |
| **Interchangeabilité** | Chaque provider est interchangeable via contrat |
| **Sélection par capacité** | Le Provider Broker choisit par capacité, pas par nom |
| **Résilience** | Chaîne de fallback automatique en cas d'échec |
| **Abstraction** | Les providers sont des plugins du système |

---

## 2. Architecture du Provider Kernel

```
┌─────────────────────────────────────────────────────────────────────┐
│                       PROVIDER KERNEL                                │
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │                    PROVIDER INTERFACES                        │   │
│  │  Protocoles abstraits pour tous les types de providers       │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                           │                                          │
│          ┌────────────────┼────────────────┐                        │
│          ▼                ▼                ▼                        │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐                │
│  │    LLM       │ │  EMBEDDING   │ │   TOOLS      │                │
│  │  PROVIDERS   │ │  PROVIDERS   │ │  PROVIDERS   │                │
│  └──────────────┘ └──────────────┘ └──────────────┘                │
│          │                │                │                        │
│          └────────────────┼────────────────┘                        │
│                           ▼                                          │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │                     PROVIDER BROKER                           │   │
│  │  Routage, fallback, health check, timeouts                   │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                           │                                          │
│                           ▼                                          │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │                    PROVIDER REGISTRY                          │   │
│  │  Enregistrement, découverte, statut des providers            │   │
│  └──────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 3. Interfaces de Provider

### 3.1 Provider Protocol (Abstrait)

```swift
protocol SUPRAProvider {
    var type: SUPRAProviderType { get }
    var isAvailable: Bool { get }
    var supportedModels: [String] { get }
    var capabilities: [SUPRACapability] { get }
    
    func execute(_ request: SUPRAExecutionRequest) async throws -> SUPRAProviderResponse
    func health() async -> SUPRAHealthStatus
}
```

### 3.2 Types de Provider

| Type | Description | Capacités |
|------|-------------|-----------|
| LLM | Modèles de langage | reasoning, conversation, analysis, coding |
| Embedding | Modèles d'embedding | semantic_search, similarity |
| Tools | Outils spécialisés | code_execution, web_search, file_ops |
| Vision | Modèles de vision | image_analysis, ocr |
| Audio | Modèles audio | speech_to_text, text_to_speech |

### 3.3 Capacités

| Capacité | Description |
|----------|-------------|
| reasoning | Raisonnement logique avancé |
| conversation | Dialogue interactif |
| analysis | Analyse de données et code |
| coding | Génération et compréhension de code |
| semantic_search | Recherche sémantique |
| similarity | Calcul de similarité |
| code_execution | Exécution de code |
| web_search | Recherche web |
| file_ops | Opérations fichier |
| image_analysis | Analyse d'images |
| ocr | Reconnaissance optique |
| speech_to_text | Transcription vocale |
| text_to_speech | Synthèse vocale |

---

## 4. Provider Broker

### 4.1 Responsabilités

| Responsabilité | Description |
|----------------|-------------|
| Routage | Sélectionner le meilleur provider pour une requête |
| Fallback | Chaîne de fallback automatique |
| Health Check | Vérification périodique de la disponibilité |
| Timeout | Gestion des timeouts par type de requête |
| Rate Limiting | Gestion des limites de taux |
| Load Balancing | Répartition de charge entre providers |

### 4.2 Algorithme de Sélection

```
1. Analyser la requête → Identifier les capacités requises
2. Filtrer les providers → Garder ceux qui supportent les capacités
3. Trier par priorité → Score de capacité, disponibilité, coût
4. Sélectionner le meilleur → Premier de la liste triée
5. Exécuter → Avec fallback configuré
6. En cas d'échec → Passer au suivant dans la chaîne de fallback
```

### 4.3 Chaîne de Fallback

```json
{
  "primary": "provider-a",
  "fallback_chain": ["provider-b", "provider-c", "provider-d"],
  "timeout_primary": 30,
  "timeout_fallback": 60,
  "max_retries": 3,
  "circuit_breaker": {
    "failure_threshold": 5,
    "reset_timeout": 300
  }
}
```

### 4.4 Timeouts

| Type de Requête | Timeout Standard | Timeout Max |
|-----------------|-----------------|-------------|
| LLM Standard | 30s | 60s |
| LLM Reasoning | 60s | 120s |
| Embedding | 10s | 30s |
| Tools | 30s | 60s |
| Vision | 30s | 60s |
| Audio | 60s | 120s |

---

## 5. Provider Registry

### 5.1 Structure d'Enregistrement

```json
{
  "provider_id": "ollama-local",
  "type": "LLM",
  "models": ["qwen2.5-coder:14b", "llama3.1:8b"],
  "capabilities": ["reasoning", "conversation", "coding"],
  "status": "ACTIVE",
  "health": {
    "last_check": "2026-07-29T10:00:00Z",
    "available": true,
    "latency_ms": 150
  },
  "contract": {
    "max_concurrent": 10,
    "timeout_default": 30,
    "timeout_reasoning": 60
  }
}
```

### 5.2 Opérations du Registry

| Opération | Description |
|-----------|-------------|
| register(provider) | Enregistrer un nouveau provider |
| unregister(providerId) | Désenregistrer un provider |
| provider(for:) | Trouver un provider par capacité |
| activeProviders() | Liste des providers actifs |
| healthCheck() | Vérifier la santé de tous les providers |

---

## 6. Contrats de Provider

### 6.1 Contrat de Service

| Propriété | Obligation |
|-----------|------------|
| Disponibilité | Health check obligatoire |
| Temps de réponse | Respect des timeouts définis |
| Capacités | Déclarées dans le registre |
| Modèles | Liste des modèles supportés |
| Résilience | Chaîne de fallback configurée |

### 6.2 Contrat de Qualité

| Métrique | Standard | Premium |
|----------|----------|---------|
| Disponibilité | > 99% | > 99.9% |
| Latence | < 2s | < 500ms |
| Taux d'erreur | < 5% | < 1% |
| Précision | Standard | Optimale |

### 6.3 Contrat de Résilience

| Mécanisme | Description |
|-----------|-------------|
| Retry | 3 tentatives max, backoff exponentiel |
| Fallback | Minimum 1 provider de fallback |
| Circuit Breaker | Coupure après N échecs consécutifs |
| Timeout | Limite stricte par type de requête |
| Degraded Mode | Fonctionnalité réduite si provider principal indisponible |

---

## 7. Providers Supportés (Sans Implémentation)

| Provider | Type | Statut |
|----------|------|--------|
| Ollama (localhost) | LLM | Implémenté (référence) |
| OpenAI | LLM | Interface définie |
| Anthropic | LLM | Interface définie |
| Google Gemini | LLM | Interface définie |
| AWS Bedrock | LLM | Extensible |
| Azure OpenAI | LLM | Extensible |
| HuggingFace | LLM | Extensible |
| Local Embedding | Embedding | Interface définie |
| Remote Embedding | Embedding | Extensible |

---

## 8. Politiques de Bascule (Failover)

### 8.1 Bascule Automatique

| Condition | Action |
|-----------|--------|
| Provider indisponible | Fallback immédiat au suivant |
| Timeout dépassé | Retry 1x, puis fallback |
| Erreur 5xx | Fallback immédiat |
| Rate limit atteint | Attente + retry, puis fallback |
| Résultat invalide | Retry 1x, puis fallback |

### 8.2 Bascule Manuelle

| Action | Déclencheur | Effet |
|--------|-------------|-------|
| Désactiver provider | Executive / Architect | Provider retiré du pool actif |
| Promouvoir fallback | Executive / Architect | Provider fallback devient primary |
| Réinitialiser circuit | Executive / Architect | Circuit breaker reset |

### 8.3 Stratégies de Bascule

| Stratégie | Description |
|-----------|-------------|
| Fail-Fast | Échouer immédiatement si provider indisponible |
| Failover | Basculer automatiquement sur le fallback |
| Fallback Chain | Chaîne de fallbacks ordonnés par priorité |
| Circuit Breaker | Couper après N échecs, réessayer après timeout |

---

## 9. Règles du Provider Kernel

| ID | Règle | Description |
|----|-------|-------------|
| PR-01 | Souveraineté du kernel | Pas de dépendance directe à un provider |
| PR-02 | Interchangeabilité | Tout provider peut être remplacé |
| PR-03 | Sélection par capacité | Pas par nom ou fournisseur |
| PR-04 | Résilience obligatoire | Fallback configuré pour toute requête |
| PR-05 | Contrat explicite | Tout provider a un contrat enregistré |
| PR-06 | Health check obligatoire | Vérification périodique de disponibilité |
| PR-07 | Pas d'implémentation dans ce Kernel | Modèle canonique uniquement |

---

## 10. Extensions Futures

### 10.1 Ajout d'un Nouveau Provider

```
1. Implémenter le protocole SUPRAProvider
2. Définir les capacités supportées
3. Enregistrer dans le Provider Registry
4. Configurer la chaîne de fallback
5. Valider le health check
6. Mettre à jour les politiques de routage
```

### 10.2 Nouveaux Types de Providers (Futurs)

| Type | Description | Quand |
|------|-------------|-------|
| Database | Stockage et requêtes | Phase 3 |
| Cache | Cache distribué | Phase 3 |
| Search | Moteur de recherche | Phase 3 |
| Monitoring | Monitoring externe | Phase 3 |
| Identity | Authentification | Phase 3 |

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA ULTIMATE CORE V1. Modèle canonique des providers — abstraction uniquement.*
