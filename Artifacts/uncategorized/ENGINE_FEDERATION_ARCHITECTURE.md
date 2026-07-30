# ENGINE FEDERATION ARCHITECTURE

**Mission**: SUPRA_ZERO_COST_ENGINE_FEDERATION_AND_MIGRATION_V2
**Date**: 2026-07-24
**Status**: ARCHITECTURE PROPOSÉE

---

## Principe fondateur

Fédération canonique de moteurs indépendants, migrables, remplaçables et interconnectables.
Aucun moteur ne devient une dépendance absolue.
L'orchestrateur ne contient pas l'intelligence métier.
Les fournisseurs sont des adapters remplaçables.

---

## Seven Layers

### LAYER 1 — HUMAN / SUPRA

```
Mission → Intention → Contraintes → Validation → Permissions
```

SUPRA définit :
- ce qui doit être fait (mission)
- pourquoi (intention)
- limites (contraintes)
- qui approuve (validation)
- qui a le droit (permissions)

### LAYER 2 — ORCHESTRATOR (OpenCode)

OpenCode agit uniquement comme :
- interface terminal
- gestionnaire de session
- lecteur de dépôt
- exécuteur autorisé
- coordinateur de tâches

OpenCode ne devient PAS :
- le moteur canonique
- la mémoire canonique
- le routeur propriétaire
- une dépendance irréversible

### LAYER 3 — ENGINE CONTRACTS

Contrats indépendants avec interfaces canoniques :

| Contrat | Rôle | Capacités clés |
|---------|------|---------------|
| InferenceEngine | Génération de texte | completion, tools, thinking |
| CodeEngine | Code Swift/SwiftUI | code-gen, patch, compile-validate |
| ReasoningEngine | Analyse et déduction | chain-of-thought, comparison |
| VisionEngine | Analyse visuelle | screenshot, UX analysis, docs |
| EmbeddingEngine | Vectors et recherche | embeddings, semantic-search |
| RetrievalEngine | Récupération contexte | chunk-retrieval, re-ranking |
| ValidationEngine | Vérification | compile-check, lint, diff |

Chaque contrat expose :
- ENGINE_ID
- ENGINE_ROLE
- PROVIDER
- MODEL
- LOCAL (bool)
- CAPABILITIES (set)
- CONTEXT_LIMIT (int tokens)
- MEMORY_ESTIMATE (MB)
- INPUT_SCHEMA (JSON schema)
- OUTPUT_SCHEMA (JSON schema)
- HEALTH (endpoint)
- COST_POLICY (LOCAL_STRICT / FREE_TIER / PAID_BLOCKED)
- FALLBACKS (list d'engine_id)

### LAYER 4 — ENGINE ADAPTERS

Aujourd'hui :
- OllamaInferenceAdapter → qwen3:4b (FAST), qwen3.6:latest (DEEP)

Demain (sans modifier les consommateurs) :
- MLXAdapter → modèles MLX natifs Apple Silicon
- LlamaCppAdapter → modèles GGUF via llama.cpp
- LMStudioAdapter → LMStudio local server
- NativeSUPRAAdapter → moteur intéré SUPRA

Le pattern : Resolver → Source state → Adapter → Canonical result → Store → UI

### LAYER 5 — ENGINE REGISTRY

Registry canonique :
- découvrir les moteurs disponibles
- enregistrer leurs capacités
- publier leur état (REGISTERED/AVAILABLE/BUSY/DEGRADED/OFFLINE/QUARANTINED)
- sélectionner un moteur compatible
- refuser les moteurs non conformes
- ne jamais télécharger silencieusement
- ne jamais sélectionner un moteur cloud automatiquement

### LAYER 6 — ROUTER

Routeur déterministe et explicable par capacité :

| Tâche | Capacités requises | Route |
|-------|-------------------|-------|
| SWIFT_MICRO_FIX | CODE + TOOL_USE + 16K_CONTEXT | local.code.primary |
| SCREENSHOT_ANALYSIS | VISION | local.vision.primary |
| CONVERSATION_RETRIEVAL | EMBEDDING + RETRIEVAL | local.memory.primary |
| QUICK_READ | FAST + SHORT_CONTEXT | local.fast.primary |
| ARCHITECTURE_REVIEW | DEEP + LONG_CONTEXT | local.deep.primary |

Pour chaque sélection enregistrer :
- WHY_SELECTED
- ALTERNATIVES
- REJECTION_REASONS
- EXPECTED_RAM
- EXPECTED_COST (=0 EUR)
- EXPECTED_CONTEXT

### LAYER 7 — EVENT BUS / INTERCONNECTION

Les moteurs ne s'appellent pas directement entre eux.
Communication par contrats, événements, artefacts, résultats structurés, identifiants de corrélation.

Flux canonique :
```
MissionRequested → RouteResolved → EngineExecutionRequested → EngineResultProduced → ValidationRequested → ValidationResultProduced → MissionCompleted
```

---

## Migration Protocol (10 étapes)

1. INVENTORY — identifier source et cible
2. CONTRACT MATCH — comparer capacités/contexte/outils/formats
3. ADAPTER — créer/sélectionner l'adapter cible
4. SHADOW MODE — même tâche aux deux moteurs sans mutations
5. COMPARISON — résultat, exactitude, coût, temps, RAM, compilation, contraintes
6. CANARY — 5% des tâches admissibles
7. PROMOTION — si seuil validé
8. ROLLBACK — retour immédiat si régression
9. DEPRECATION — marquer DEPRECATED, ne pas supprimer
10. FREEZE — preuve de migration

---

## Hybridation Contrôlée

Autorisé :
- SEQUENTIAL (un moteur prépare, un autre approfondit, un validateur vérifie)
- PARALLEL (lecture seule, comparateur choisit)
- ENSEMBLE (fusion si schéma compatible)
- SPECIALIZED (chaque moteur reçoit sa portion)

Interdit :
- plusieurs agents modifiant les mêmes fichiers simultanément
- fusion automatique de patchs concurrents
- partage implicite d'état mutable
- orchestration opaque
- chargement simultané de modèles lourds sur 16 Go

---

## Zero Cost Policy

### POLICY_LOCAL_STRICT (production)
- moteurs locaux uniquement
- aucun fallback réseau
- aucune clé ni authentification
- aucun cloud
- coût obligatoire = 0 EUR

### POLICY_FREE_TIER_ALLOWED (consentement humain)
- fournisseurs gratuits autorisés
- quotas possibles
- jamais valeur par défaut
- consentement humain avant usage

### POLICY_PAID_DISABLED
- tous les fournisseurs payants bloqués
- aucune demande automatique d'abonnement
- aucune clé chargée

---

## ContextPackager modulaire

Ne jamais envoyer les 155 414 tokens complets à chaque moteur.
Produire 4 niveaux de contexte :

| Niveau | Contenu | Usage |
|--------|---------|-------|
| MICRO_CONTEXT | Fichier courant + erreur | micro-corrections |
| MODULE_CONTEXT | Fichiers du module + contrats | modificateurs de module |
| PROJECT_CONTEXT | Dépôt pertinent + historique | analyses transversales |
| RECOVERY_CONTEXT | Dernière état validé + erreurs | récupération de session |

---

## ResourceAdmissionController

Avant chaque lancement de moteur :
1. lire pression mémoire
2. lire RAM disponible
3. lire modèles déjà chargés
4. estimer mémoire du modèle demandé
5. accepter, différer ou substituer

États : ADMITTED / DEFERRED / SUBSTITUTED / REJECTED

Règles :
- un seul moteur génératif lourd chargé à la fois
- embedding léger autorisé si budget disponible
- aucun lancement si swap ou pression critique
- unload explicite après période inactive
- Xcode et SUPRA restent prioritaires
- contexte réduit avant changement de modèle