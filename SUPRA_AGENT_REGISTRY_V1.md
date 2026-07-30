# SUPRA Agent Registry — V1

## Agents

---

### SUPRA-Architect

| Propriété | Valeur |
|---|---|
| **Rôle** | Concevoir l'architecture du système, produire des ADR, valider la cohérence structurelle. |
| **Permissions** | read, grep, glob, lsp |
| **Modèle recommandé** | `anthropic/claude-sonnet-4-6` |
| **Modèles alternatifs gratuits** | `ollama/qwen2.5-coder:14b`, `ollama/deepseek-coder-v2:16b`, `ollama/mixtral:8x7b` |
| **Température** | 0.2 |
| **Outils nécessaires** | read, grep, glob, lsp, webfetch |

---

### SUPRA-Builder

| Propriété | Valeur |
|---|---|
| **Rôle** | Implémenter du code Swift à partir de spécifications, générer des artefacts. |
| **Permissions** | read, edit, bash, lsp |
| **Modèle recommandé** | `anthropic/claude-sonnet-4-6` |
| **Modèles alternatifs gratuits** | `ollama/qwen2.5-coder:14b`, `ollama/deepseek-coder-v2:16b`, `ollama/codellama:13b` |
| **Température** | 0.1 |
| **Outils nécessaires** | read, edit, bash, lsp, glob |

---

### SUPRA-Auditor

| Propriété | Valeur |
|---|---|
| **Rôle** | Analyser le code sans le modifier : conformité, sécurité, intégrité, cohérence. |
| **Permissions** | read, grep, glob, lsp |
| **Modèle recommandé** | `anthropic/claude-sonnet-4-6` |
| **Modèles alternatifs gratuits** | `ollama/qwen2.5-coder:14b`, `ollama/deepseek-coder-v2:16b`, `ollama/mixtral:8x7b` |
| **Température** | 0.1 |
| **Outils nécessaires** | read, grep, glob, lsp |

---

### SUPRA-Reviewer

| Propriété | Valeur |
|---|---|
| **Rôle** | Relecture de code : style, conventions, performance, suggestions. |
| **Permissions** | read, grep, glob, lsp |
| **Modèle recommandé** | `anthropic/claude-sonnet-4-6` |
| **Modèles alternatifs gratuits** | `ollama/qwen2.5-coder:14b`, `ollama/deepseek-coder-v2:16b` |
| **Température** | 0.3 |
| **Outils nécessaires** | read, grep, glob, lsp |

---

### SUPRA-Explorer

| Propriété | Valeur |
|---|---|
| **Rôle** | Naviguer dans le codebase, trouver des fichiers, comprendre des structures complexes. |
| **Permissions** | read, grep, glob, lsp, task |
| **Modèle recommandé** | `anthropic/claude-sonnet-4-6` |
| **Modèles alternatifs gratuits** | `ollama/qwen2.5-coder:14b`, `ollama/deepseek-coder-v2:16b`, `ollama/llama3.1:8b` |
| **Température** | 0.2 |
| **Outils nécessaires** | read, grep, glob, lsp, task |

---

### SUPRA-Refactor

| Propriété | Valeur |
|---|---|
| **Rôle** | Refactoring sécurisé du code sans altération fonctionnelle. |
| **Permissions** | read, edit, lsp |
| **Modèle recommandé** | `anthropic/claude-sonnet-4-6` |
| **Modèles alternatifs gratuits** | `ollama/qwen2.5-coder:14b`, `ollama/deepseek-coder-v2:16b` |
| **Température** | 0.1 |
| **Outils nécessaires** | read, edit, lsp, grep, glob |

---

### SUPRA-Research

| Propriété | Valeur |
|---|---|
| **Rôle** | Recherche d'information, documentation, investigation de bugs, exploration technique. |
| **Permissions** | read, grep, glob, lsp, webfetch, websearch |
| **Modèle recommandé** | `anthropic/claude-sonnet-4-6` |
| **Modèles alternatifs gratuits** | `ollama/qwen2.5:32b`, `ollama/mixtral:8x7b`, `ollama/llama3.1:70b` |
| **Température** | 0.4 |
| **Outils nécessaires** | read, grep, glob, webfetch, websearch |

---

### SUPRA-Runtime

| Propriété | Valeur |
|---|---|
| **Rôle** | Analyser le comportement runtime, diagnostiquer les crashs, valider les flux d'exécution. |
| **Permissions** | read, grep, glob, lsp, bash |
| **Modèle recommandé** | `anthropic/claude-sonnet-4-6` |
| **Modèles alternatifs gratuits** | `ollama/qwen2.5-coder:14b`, `ollama/deepseek-coder-v2:16b` |
| **Température** | 0.2 |
| **Outils nécessaires** | read, grep, glob, lsp, bash |

---

## Permissions communes

Chaque permission est un objet `{ action: "allow" | "ask" | "deny" }` ou un pattern.

Permissions disponibles : read, edit, glob, grep, list, bash, task, lsp, webfetch, websearch, todowrite, question.

## Cycle de vie

1. **Enregistrement** → dans SUPRA-AgentRegistry via `register(agent_def)`
2. **Découverte** → Router interroge le Registry pour trouver l'agent adapté
3. **Affectation** → WorkflowEngine assigne la tâche à l'agent
4. **Exécution** → L'agent exécute avec ses permissions
5. **Rapport** → Résultat renvoyé au Comparator/FusionEngine
6. **Désenregistrement** → `unregister(agent_id)` si l'agent n'est plus disponible
