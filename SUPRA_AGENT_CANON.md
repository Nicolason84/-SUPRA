# SUPRA AGENT CANON

## Architecture Durable des Agents SUPRA

| Propriété | Valeur |
|-----------|--------|
| **Statut** | CANONIQUE |
| **Version** | SUPRA_FOUNDATION_V1 |
| **Date** | 2026-07-29 |
| **Référence** | AGENTS.md + opencode.json + SUPRA_AGENT_REGISTRY_V1.md |
| **Single Writer** | SUPRA-Builder (seul agent autorisé à écrire) |

---

## 1. Architecture des Agents

```
                    GLOBAL (Machine-level)
                    ├── SUPRA-Architect
                    ├── SUPRA-Auditor
                    └── SUPRA-Research
                    
                    PROJECT (Workspace-level)
                    ├── SUPRA-Builder      ← SEUL ÉCRIVAIN
                    ├── SUPRA-Explorer
                    ├── SUPRA-Runtime
                    ├── SUPRA-Refactor
                    ├── SUPRA-Reviewer
                    └── SUPRA-Router
                    
                    DYNAMIC (Mission-delegated)
                    ├── SUPRA-MissionExecutor
                    └── SUPRA-WorkflowRunner
                    
                    FUTURE (Phase 2)
                    ├── SUPRA-Sherpa
                    ├── SUPRA-Cortex
                    ├── SUPRA-Theory
                    ├── SUPRA-Governance
                    ├── SUPRA-Product
                    └── SUPRA-Plugin
```

---

## 2. Agents Fondation (Actuels)

### 2.1 SUPRA-Builder

| Propriété | Valeur |
|-----------|--------|
| **Mode** | subagent |
| **Permissions** | read, edit, bash, lsp, glob, grep |
| **Rôle** | Implementation and code generation |
| **Peut écrire** | OUI (seul agent) |
| **Modèle** | Configurable via opencode.json |

### 2.2 SUPRA-Architect

| Propriété | Valeur |
|-----------|--------|
| **Mode** | subagent |
| **Permissions** | read, grep, glob, lsp, webfetch |
| **Rôle** | System architecture, ADR production, structural validation |
| **Peut écrire** | NON (READ ONLY) |
| **Portée** | GLOBAL |

### 2.3 SUPRA-Auditor

| Propriété | Valeur |
|-----------|--------|
| **Mode** | subagent |
| **Permissions** | read, grep, glob, lsp |
| **Rôle** | Compliance and integrity validation only |
| **Peut écrire** | NON (READ ONLY) |
| **Portée** | GLOBAL |

### 2.4 SUPRA-Explorer

| Propriété | Valeur |
|-----------|--------|
| **Mode** | subagent |
| **Permissions** | read, grep, glob, lsp |
| **Rôle** | Codebase navigation and structure understanding |
| **Peut écrire** | NON (READ ONLY) |
| **Portée** | PROJET |

### 2.5 SUPRA-Research

| Propriété | Valeur |
|-----------|--------|
| **Mode** | subagent |
| **Permissions** | read, grep, glob, lsp, webfetch, websearch |
| **Rôle** | Technical research and documentation |
| **Peut écrire** | NON (READ ONLY) |
| **Portée** | GLOBAL |

### 2.6 SUPRA-Runtime

| Propriété | Valeur |
|-----------|--------|
| **Mode** | subagent |
| **Permissions** | read, grep, glob, lsp, bash |
| **Rôle** | Runtime behavior analysis and diagnostic |
| **Peut écrire** | NON (READ ONLY) |
| **Portée** | PROJET |

### 2.7 SUPRA-Refactor

| Propriété | Valeur |
|-----------|--------|
| **Mode** | subagent |
| **Permissions** | read, grep, glob, lsp |
| **Rôle** | Safe refactoring without functional alteration |
| **Peut écrire** | NON (READ ONLY — missions via BUILDER) |
| **Portée** | PROJET |

### 2.8 SUPRA-Reviewer

| Propriété | Valeur |
|-----------|--------|
| **Mode** | subagent |
| **Permissions** | read, grep, glob, lsp |
| **Rôle** | Code review: style, conventions, performance, suggestions |
| **Peut écrire** | NON (READ ONLY) |
| **Portée** | PROJET |

### 2.9 SUPRA-Router

| Propriété | Valeur |
|-----------|--------|
| **Mode** | subagent |
| **Permissions** | read, grep, glob, lsp, task, webfetch |
| **Rôle** | Task routing to optimal agents/models |
| **Peut écrire** | NON (READ ONLY) |
| **Portée** | PROJET |

---

## 3. Nouveaux Agents (Spécifiés, Non Implémentés)

| Agent | Rôle | Dépend de | Priorité |
|-------|------|-----------|----------|
| SUPRA-Sherpa | Context selection, theory navigation | Theory Engine | HIGH |
| SUPRA-Cortex | Persistent memory management | Theory Engine | HIGH |
| SUPRA-Theory | Knowledge/theory management | Foundation | HIGH |
| SUPRA-Governance | Policy enforcement | Foundation | MEDIUM |
| SUPRA-Product | Product/business decisions | Foundation | MEDIUM |
| SUPRA-Plugin | Plugin lifecycle management | Plugin SDK | LOW |

---

## 4. Single Writer Rule

**SUPRA-Builder** est le SEUL agent autorisé à modifier les fichiers.

Tous les autres agents sont STRICTEMENT READ ONLY.

Aucun agent READ ONLY ne peut créer, modifier ou supprimer des fichiers.

Exceptions possibles uniquement avec autorisation explicite de mission.

### Workflow Pipeline
```
Mission → Executive → Architect → Router → Read Agents → Comparator → Fusion → Validator → Builder (WRITE)
```

---

## 5. Matrice des Permissions

| Ressource | Builder | Architect | Auditor | Explorer | Runtime | Router | Refactor | Reviewer | Research |
|-----------|---------|-----------|---------|----------|---------|--------|----------|----------|----------|
| Source files | RW | R | R | R | R | - | R | R | - |
| Config (.opencode) | RW | R | R | R | - | R | - | - | - |
| Tests | RW | R | R | R | R | - | R | R | - |
| Runtime state | RW | R | R | R | R | - | - | - | - |
| Knowledge graph | RW | R | R | R | - | - | - | - | R |
| Agent definitions | RW | R | R | - | - | R | - | - | - |
| Plugin manifests | RW | R | R | - | - | - | - | - | - |
| Mission queue | RW | R | R | - | R | R | - | - | - |
| Web/Recherche | - | webfetch | - | - | - | webfetch | - | - | webfetch+search |
| Bash | OUI | - | - | - | OUI | OUI | - | - | - |

---

## 6. Règles de Routage

| Type de Tâche | Agent Principal | Agent Fallback |
|---------------|-----------------|----------------|
| Décision architecture | SUPRA-Architect | SUPRA-Research |
| Implémentation code | SUPRA-Builder | SUPRA-Refactor |
| Relecture code | SUPRA-Reviewer | SUPRA-Auditor |
| Diagnostic bug | SUPRA-Runtime | SUPRA-Research |
| Refactoring | SUPRA-Refactor → Builder | SUPRA-Builder |
| Recherche | SUPRA-Research | SUPRA-Explorer |
| Requête connaissance | SUPRA-Theory (future) | SUPRA-Research |
| Requête mémoire | SUPRA-Cortex (future) | SUPRA-Runtime |
| Sélection contexte | SUPRA-Sherpa (future) | SUPRA-Router |
| Gestion plugins | SUPRA-Plugin (future) | SUPRA-Builder |

---

## 7. Cycle de Vie des Agents

```
REGISTRATION → DISCOVERY → ASSIGNMENT → EXECUTION → REPORTING → DEREGISTRATION
```

1. **Enregistrement** : Déclaration dans AGENTS.md + opencode.json
2. **Découverte** : Router interroge le Registry pour trouver l'agent adapté
3. **Affectation** : WorkflowEngine assigne la tâche à l'agent
4. **Exécution** : L'agent exécute avec ses permissions
5. **Rapport** : Résultat renvoyé au pipeline
6. **Désenregistrement** : Si l'agent n'est plus disponible

---

## 8. Compatibilité OpenCode

Les agents SUPRA sont compatibles avec le système d'agents OpenCode :

| Concept OpenCode | Équivalent SUPRA |
|-----------------|------------------|
| `agent.role` | Rôle défini dans AGENTS.md |
| `agent.mode` | subagent (tous) |
| `agent.permission` | Permissions READ ONLY sauf Builder |
| `.opencode/agents/` | Agents projet |
| `~/.opencode/agents/` | Agents globaux (Architect, Auditor, Research) |

---

## 9. Convention de Configuration

### Ajout d'un nouvel agent

1. Définir l'agent dans `AGENTS.md` avec rôle et permissions
2. Ajouter la configuration dans `opencode.json` sous `agent.`
3. Si global : ajouter dans `~/.opencode/agents/`
4. Si projet : ajouter dans `.opencode/agents/`
5. Mettre à jour SUPRA_AGENT_CANON.md

### Modification d'un agent existant

1. Modifier `AGENTS.md` (via Builder)
2. Modifier `opencode.json` (via Builder)
3. Mettre à jour SUPRA_AGENT_CANON.md

---

## 10. Migration

### De l'état actuel (9 agents) à l'état cible (15 agents)

1. ✅ 9 agents Foundation : actifs et validés
2. 🟡 Ajouter SUPRA-Sherpa, SUPRA-Cortex, SUPRA-Theory (Phase 2)
3. 🟡 Ajouter SUPRA-Governance, SUPRA-Product (Phase 2)
4. 🟡 Ajouter SUPRA-Plugin (Phase 2b)
5. 🟢 Déplacer Architect, Auditor, Research en globaux (quand prêt)

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA FOUNDATION V1.*
