# SUPRA Decision Engine

## Rôle

Le Decision Engine est le cœur de SUPRA. Il ne connaît :
- **Aucun** provider
- **Aucun** modèle
- **Aucune** API
- **Aucun** LLM

Il décide uniquement :
- **Quoi faire**
- **Dans quel ordre**
- **Avec quelles capacités**

## Architecture

```
Mission (titre + prompt)
  ↓
SUPRADecisionEngine.decide()
  ↓
1. understand() → SUPRAUnderstanding
   - Extrait l'intention du prompt
   - Détecte les besoins : vision, tools, streaming, JSON, embeddings, large context, reasoning, planning, memory, search
   - Évalue la priorité et l'urgence
  ↓
2. planSteps() → [SUPRAOrchestrationStep]
   - Ordonnance les actions : reason, generate, search, remember, validate
   - Assigne les capacités nécessaires à chaque étape
   - Définit les dépendances entre étapes
  ↓
3. calculateComplexity()
  ↓
SUPRAOrchestrationDecision
```

## Structures clés

### SUPRAUnderstanding
Comprend l'intention, les besoins (tools, vision, streaming, JSON, embeddings, large context, reasoning, planning, memory, search), la priorité, et l'urgence.

### SUPRAOrchestrationStep
Une étape atomique avec action (analyze, generate, plan, search, remember, reason, transform, validate, execute, delegate), capacités requises, timeout, dépendances, et criticité.

### SUPRAOrchestrationDecision
La décision complète incluant la compréhension, les étapes ordonnancées, le raisonnement, la complexité estimée, et les flags fallback/learning.

## Principe zéro dépendance

Le fichier `SUPRADecisionEngine.swift` ne contient :
- ✅ ZERO référence à Ollama
- ✅ ZERO référence à OpenAI  
- ✅ ZERO référence à Anthropic
- ✅ ZERO référence à Gemini
- ✅ ZERO référence à un modèle spécifique
- ✅ ZERO enum de providers
- ✅ ZERO URL d'API
- ✅ ZERO clé API

Le Decision Engine travaille uniquement avec des `String` comme identifiants de capacités. Il ne sait pas ce qu'est un LLM, il sait seulement qu'une étape nécessite la capacité `"reasoning"`.

## Flux de décision

```
Input: "Bonjour SUPRA, code une fonction Swift"
  ↓
understand()
  intent: "coding"
  requiresReasoning: true
  requiresPlanning: false
  priority: 0
  isTimeSensitive: false
  ↓
planSteps()
  Step 1: reason [reasoning] (critique, 60s)
  Step 2: generate [conversation, reasoning, coding] (critique, 60s)
  Step 3: validate [reasoning] (critique, 15s, dépend de step 2)
  ↓
Décision: 3 étapes, complexité 5, fallback activé, learning activé
```

## Extension

Pour ajouter un nouveau type d'action :
1. Ajouter un cas à `SUPRAOrchestrationAction`
2. Ajouter la détection dans `extractIntent()` et `planSteps()`

Aucune modification du Kernel, des Providers, ou des Modèles.
