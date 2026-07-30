# LOCAL_PROVIDER_PROOF

**Date**: 2026-07-24
**Mission**: SUPRA_ZERO_COST_ENGINE_FEDERATION_AND_MIGRATION_V2
**Purpose**: Prove which provider/motor is actually responding to requests

---

## CONSTAT IMMÉDIAT

### OpenCode configuration (/Users/nicolasalonso/Desktop/NOVA_OS/SUPRA/opencode.json)

```
Top keys: $schema, instructions, default_agent, lsp, skills, agent, command, references
Provider: NONE configured
Ollama section: ABSENT
baseURL: ABSENT
models: ABSENT
```

Ouvrir la session avec :

- PROVIDER=OpenCode Zen
- MODEL=Ling-3.0-flash Free
- COST affiché=0 $

### Ce que cela signifie

- OpenCode est bien installé et en cours dexécution (PID 42637, PID 40042)
- Ollama est bien en cours dexécution (PID 1050, port 11434)
- MAIS OpenCode est connecté au cloud OpenCode Zen, pas à Ollama local
- Le modèle Ling-3.0-flash Free est un modèle cloud avec quota gratuit
- La mention "0 €" est trompeuse — c'est un quota gratuit, pas une absence de coût

### Preuve Ollama local fonctionne

```
curl http://localhost:11434/api/tags → 2 modèles enregistrés
curl http://localhost:11434/v1/models → réponses OpenAI compatibles OK
ollama list → qwen3.6:latest (23 GB), qwen3:4b (2.5 GB)
ollama ps → AUCUN modèle chargé en RAM
```

### Preuve pas de configuration locale dans OpenCode

- Aucun "ollama" dans opencode.json
- Aucun "baseURL" pour Ollama
- Aucun "provider" section
- Aucune clé API → aucune connexion cloud explicite
- Mais OpenCode utilise le provider Zen par défaut (cloud)

### Preuve réseau

- Ollama (PID 1050) : écoute localhost:11434 uniquement
- Aucune connexion ESTABLISHED distante pour Ollama
- OpenCode (PID 42637) : connexions réseau non inspectables directement (timeout)

---

## VERDICT LOCAL_ONLY

| Critère | Résultat |
|---------|----------|
| PROVIDER=OLLAMA_LOCAL | **NON** — Provider=OpenCode Zen (Cloud) |
| REMOTE_REQUESTS=0 | **INCONNU** — impossible de tracer sans configuration explicite |
| CLOUD_MODEL=NONE | **NON** — Ling-3.0-flash est cloud |
| API_KEY_REQUIRED=NO | **OUI** — aucune clé dans le config |
| MONTHLY_COST=0_EUR | **MISLEADING** — free tier avec quota |
| OLLAMA_RUNNING | **OUI** — port 11434 actif |
| OLLAMA_MODELS_AVAILABLE | **OUI** — qwen3.6 + qwen3:4b |
| OLLAMA_CONNECTED_TO_OPENCODE | **NON** — pas configuré |
| MODELE_LOCAL_CHARGÉ | **NON** — ollama ps retourne vide |
| MODELO_CLOUD_QUOTA_LIMITED | **OUI** — risque "Free limit reached" |

---

## CONCLUSION PHASE B

Le routage local nest PAS prouvé. Le système utilise par défaut le cloud OpenCode Zen.
Ollama est disponible localement comme moteur potentiel mais nest PAS branché à OpenCode.

### Action requise pour Phase D
Configurer OpenCode pour utiliser Ollama comme provider local FAST :
- baseURL: http://localhost:11434/v1
- model: qwen3:4b (pour FAST)
- Pas de clé API requise
- Test de validation après configuration

### Risk: "Free limit reached"
Le comportement qui a provoqué la détection de ce problème était lié au quota gratuit du provider cloud Zen. Ce risque disparaît uniquement si tous les appels passent par Ollama local.