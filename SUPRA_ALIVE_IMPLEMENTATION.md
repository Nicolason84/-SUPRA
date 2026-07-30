# SUPRA ALIVE — Implémentation du Pipeline Vivant

## Résumé
Mission SUPRA_ALIVE_IMPLEMENT_005 : rendre SUPRA capable d'exécuter une mission complète — requête utilisateur → LLM → réponse → UI.

## Architecture du pipeline

```
User Prompt
    ↓
SUPRAMissionBroker      — Résout titre + prompt → SUPRAExecutionPlan
    ↓
SUPRACapabilityBroker   — Analyse le prompt → besoin de capacité
    ↓
SUPRAModelRegistry      — Trouve le meilleur modèle pour la capacité
    ↓
SUPRAProviderBroker     — Sélectionne un provider capable du modèle
    ↓
SUPRAOllamaProvider     — Exécute l'appel HTTP au LLM
    ↓
SUPRAExecutor           — Orchestre tout, produit SUPRAExecutionContext
    ↓
SUPRAExecutionPipeline  — Intègre décision + mémoire + logger
    ↓
UI / Réponse
```

## Fichiers créés (11)

| Fichier | Rôle |
|---------|------|
| SUPRAProviderProtocols.swift | Protocoles fondation : Provider, Executor, types |
| SUPRAModelRegistry.swift | Registre de modèles (9 modèles pré-chargés) |
| SUPRACapabilityBroker.swift | Résolution de capacité depuis le prompt |
| SUPRAProviderRegistry.swift | Registre des providers plugins |
| SUPRAProviderBroker.swift | Sélection + exécution + fallback + timeout |
| SUPRAMissionBroker.swift | Routage mission → plan d'exécution |
| SUPRAExecutor.swift | Orchestrateur central du pipeline |
| SUPRAOllamaProvider.swift | Plugin provider Ollama (localhost:11434) |
| SUPRARuntimeLogger.swift | Logger observabilité 10 stages |
| SUPRAExecutionPipeline.swift | Pipeline unifié intégrant tous les composants |
| SUPRAAliveDemo.swift | Démo et bootstrap du système |

## Fichiers modifiés (2)

| Fichier | Modification |
|---------|-------------|
| SUPRAOperationalCoreApp.swift | Appel SUPRAAliveDemo.bootstrap() au démarrage |
| SUPRAMissionExecutor.swift | Méthode executeAsync() déléguant au pipeline |

## Principe zéro dépendance
- Aucun fichier du kernel ne référence Ollama, OpenAI, ou tout autre provider
- SUPRAOllamaProvider est le seul plugin qui nomme Ollama
- Provider Broker sélectionne par capacité, jamais par nom de provider
- Model Registry stocke par ID, pas de hardcode de modèle dans le kernel
