# SUPRA Model Registry — V1

## Objectif

Catalogue central des modèles LLM disponibles. Fournit les métadonnées nécessaires au Router pour la sélection automatique.

## Modèles supportés

### Providers

| Provider | Type | Détection automatique | Coût |
|---|---|---|---|
| **Anthropic Claude** | API payante | Non | $ |
| **Ollama** | Local / gratuit | Oui (`ollama list`) | Gratuit |
| **OpenAI** | API payante | Non | $$ |
| **Google Gemini** | API gratuite/payante | Non | Gratuit / $ |
| **Groq** | API gratuite | Non | Gratuit |
| **Together** | API gratuite/payante | Non | Gratuit / $ |
| **Mistral AI** | API payante | Non | $ |
| **DeepSeek** | API gratuite/payante | Non | Gratuit / $ |

### Modèles recommandés par usage

#### Architecture & Design

| Modèle | Provider | Score | Contexte | Coût |
|---|---|---|---|---|
| `claude-sonnet-4-6` | Anthropic | 9.5/10 | 200K | $$ |
| `qwen2.5-coder:14b` | Ollama | 7.5/10 | 32K | Gratuit |
| `deepseek-coder-v2:16b` | Ollama | 7.0/10 | 128K | Gratuit |

#### Génération Swift

| Modèle | Provider | Score | Contexte | Coût |
|---|---|---|---|---|
| `claude-sonnet-4-6` | Anthropic | 9.5/10 | 200K | $$ |
| `qwen2.5-coder:14b` | Ollama | 8.0/10 | 32K | Gratuit |
| `deepseek-coder-v2:16b` | Ollama | 7.5/10 | 128K | Gratuit |
| `codellama:13b` | Ollama | 6.5/10 | 16K | Gratuit |

#### Audit & Analyse

| Modèle | Provider | Score | Contexte | Coût |
|---|---|---|---|---|
| `claude-sonnet-4-6` | Anthropic | 9.0/10 | 200K | $$ |
| `mixtral:8x7b` | Ollama | 7.0/10 | 32K | Gratuit |
| `qwen2.5-coder:14b` | Ollama | 7.5/10 | 32K | Gratuit |

#### Recherche & Documentation

| Modèle | Provider | Score | Contexte | Coût |
|---|---|---|---|---|
| `claude-sonnet-4-6` | Anthropic | 9.0/10 | 200K | $$ |
| `llama3.1:70b` | Ollama | 8.0/10 | 128K | Gratuit |
| `qwen2.5:32b` | Ollama | 7.5/10 | 32K | Gratuit |
| `gemini-2.0-flash` | Google | 7.5/10 | 1M | Gratuit |

#### Debugging & Runtime

| Modèle | Provider | Score | Contexte | Coût |
|---|---|---|---|---|
| `claude-sonnet-4-6` | Anthropic | 9.0/10 | 200K | $$ |
| `deepseek-coder-v2:16b` | Ollama | 7.5/10 | 128K | Gratuit |
| `qwen2.5-coder:14b` | Ollama | 7.0/10 | 32K | Gratuit |

## Fiche modèle type

Chaque modèle enregistré expose ces métadonnées :

```json
{
  "id": "ollama/qwen2.5-coder:14b",
  "provider": "ollama",
  "name": "Qwen 2.5 Coder 14B",
  "capabilities": [
    "swift", "architecture", "code_generation",
    "code_review", "refactoring", "analysis"
  ],
  "context_window": 32768,
  "cost_per_token": 0,
  "latency_ms_avg": 4500,
  "quality_scores": {
    "swift": 8.0,
    "architecture": 7.5,
    "refactoring": 7.5,
    "analysis": 7.5,
    "review": 7.0
  },
  "status": "available",
  "last_health_check": "2026-07-23T22:00:00Z"
}
```

## Détection automatique (Ollama)

Le Registry interroge Ollama pour détecter les modèles disponibles localement :

```bash
ollama list
```

Chaque modèle détecté est automatiquement enregistré avec ses métadonnées par défaut. Si le modèle a déjà été enregistré manuellement avec des métadonnées personnalisées, les valeurs manuelles sont conservées.

## Politique de fallback

Lorsqu'un modèle est indisponible (timeout, erreur API, saturation) :

1. **Fallback immédiat** : modèle alternatif défini dans le plan du Router
2. **Fallback secondaire** : modèle gratuit le mieux noté pour la tâche
3. **Fallback dégradé** : tout modèle disponible (mode dégradé)
4. **Échec** : la mission est mise en file d'attente

## Cycle de vie

1. **Enregistrement** : manuel ou automatique (Ollama)
2. **Health check** : périodique (toutes les 5 min)
3. **Mise à jour** : scores, latence, disponibilité
4. **Désactivation** : si indisponible pendant plus de 3 checks consécutifs
5. **Suppression** : manuelle uniquement

## Interfaces

| Méthode | Description |
|---|---|
| `register(model_def)` | Enregistrer un modèle manuellement |
| `list(filters)` | Lister les modèles avec filtres (provider, capacité, statut) |
| `best_for(task)` | Meilleur modèle disponible pour une tâche donnée |
| `health()` | Statut de tous les modèles |
| `refresh()` | Forcer la détection Ollama |
| `scores(model_id)` | Scores de qualité par catégorie |
