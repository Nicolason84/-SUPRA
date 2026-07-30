# SUPRA FOUNDATION — Rules

## Base Industrielle — Standards, Politiques, Contrats, Schémas, Templates, SDK

| Propriété | Valeur |
|-----------|--------|
| **Statut** | CANONIQUE |
| **Version** | SUPRA_FOUNDATION_V1 |
| **Date** | 2026-07-29 |
| **Principe** | Référentiel unique pour la base industrielle |

---

## 1. Standards

### Mission
Définir les standards de codage, nommage et architecture pour garantir la cohérence du codebase.

### Existants (80%)
| Standard | Source | Statut |
|----------|--------|--------|
| Swift coding conventions | Implicite dans le codebase | À extraire |
| Architecture principles | SUPRA_AI_LAB_ARCHITECTURE_V1.md | CANONIQUE |
| Executive Object Model | EXECUTIVE_OBJECT_MODEL.md | CANONIQUE |
| Naming conventions | Implicite | À formaliser |
| Architecture conventions | SUPRA_EXECUTIVE_CANON.md | CANONIQUE |

### À Créer
- Coding standards document (extraire du code Swift existant)
- Reference architecture document (version officielle)

---

## 2. Policies

### Mission
Définir les politiques de sécurité, gouvernance et routage.

### Existants (70%)
| Politique | Source | Statut |
|-----------|--------|--------|
| Routing Policy | .opencode/runtime/routing_policy.json | ACTIVE |
| Governance | Governance/ directory | ACTIVE |
| Security | Implicite (macOS permission architecture) | Implicite |
| Validation Protocol | VALIDATION_PROTOCOL.md | CANONIQUE |
| Workflow Policy | SUPRA_WORKFLOW_V1.md | CANONIQUE |

### À Créer
- Formal security policy document

---

## 3. Contracts

### Mission
Définir les contrats entre composants : providers, plugins, services.

### Existants (40%)
| Contrat | Source | Statut |
|---------|--------|--------|
| Provider Protocols | SUPRAProviderProtocols.swift | ACTIF |
| Service Contracts | Implicite dans le runtime | Partiel |
| Transmission Contract | SUPRATransmissionContract.swift | ACTIF |

### À Créer
- Provider Contracts (formal service contracts)
- Plugin Contracts (défini dans SUPRA_PLUGIN_SDK_SPEC.md)
- Formal service contracts

---

## 4. Schemas

### Mission
Définir les schémas JSON pour manifests, états, runtime.

### Existants (70%)
| Schéma | Source | Statut |
|--------|--------|--------|
| Manifest Schema | WORKSPACE_MANIFEST.json (implicite) | Implicite |
| State Schema | SUPRA_STATE.json (implicite) | Implicite |
| Runtime Schema | RUNTIME_STATUS.json (implicite) | Implicite |
| Decision Schema | Implicite dans le code | Implicite |
| UDCL Spec | UDCL_SPECIFICATION.md | CANONIQUE |

### À Créer
- Formal JSON schemas for manifests, states, runtime
- Formal schema for plugin manifests

---

## 5. Templates

### Mission
Fournir des templates pour composants, workflows, missions.

### Existants (50%)
| Template | Source | Statut |
|----------|--------|--------|
| Mission Templates | Implicite (Mission.swift model) | Implicite |
| Workflow Templates | Executive workflow patterns | Implicite |
| Session Report | SESSION_CONTINUITY_REPORT.md pattern | ACTIF |
| Snapshot Template | SESSION_SNAPSHOT_*.json pattern | ACTIF |

### À Créer
- Formal mission template
- Formal workflow template
- Component creation template

---

## 6. SDK

### Mission
Fournir les SDK pour providers, plugins et twins.

### Existants (20%)
| SDK | Source | Statut |
|-----|--------|--------|
| Provider SDK | Implicite (Provider protocols) | Partiel |
| Plugin SDK | SUPRA_PLUGIN_SDK_SPEC.md | SPÉCIFIÉ |
| Twin SDK | Implicite (Twin protocols) | Partiel |

### À Créer
- Formal Provider SDK (extraire des protocoles existants)
- Plugin SDK implementation (Phase 2b)
- Formal Twin SDK

---

## 7. Agents

### Mission
Définir les agents, capacités et règles de routage.

### Existants (100%)
| Élément | Source | Statut |
|---------|--------|--------|
| Agent Definitions | AGENTS.md | CANONIQUE |
| Agent Permissions | opencode.json | CANONIQUE |
| Agent Registry | SUPRA_AGENT_REGISTRY_V1.md | CANONIQUE |
| Agent Canon | SUPRA_AGENT_CANON.md | CANONIQUE |
| Routing Rules | SUPRA_ROUTER_SPECIFICATION_V1.md | CANONIQUE |

---

## 8. Plugins

### Mission
Définir les interfaces et points d'extension des plugins.

### Existants (100% spécifié)
| Élément | Source | Statut |
|---------|--------|--------|
| Plugin Interfaces | SUPRA_PLUGIN_SDK_SPEC.md | SPÉCIFIÉ |
| Plugin Contracts | SUPRA_PLUGIN_SDK_SPEC.md | SPÉCIFIÉ |
| Extension Points | SUPRA_PLUGIN_SDK_SPEC.md | SPÉCIFIÉ |

---

## 9. Guides

### Mission
Fournir les guides pour développeurs, opérateurs et intégration.

### Existants (80%)
| Guide | Source | Statut |
|-------|--------|--------|
| Install Guide | GO_SUPRA_INSTALL.sh, GO_SUPRA_INSTALL_AUDIT.md | ACTIF |
| Bootstrap Guide | SUPRA_BOOTSTRAP_V3.sh | ACTIF |
| Runtime Guide | SUPRA_RUNTIME.sh | ACTIF |
| Node Guide | SUPRA_NODE_STATUS.sh | ACTIF |
| Development Guide | CAnnoNico_DEVELOPMENT_GUIDE.md | CANONIQUE |
| Workflow Guide | CAnnoNico_WORKFLOW_STANDARD.md | CANONIQUE |
| Continuity Guide | CAnnoNico_CONTINUITY_STANDARD.md | CANONIQUE |

---

## 10. Rules

### Mission
Définir les règles de validation, linting et business.

### Existants (60%)
| Règle | Source | Statut |
|-------|--------|--------|
| Routing Rules | .opencode/runtime/routing_rules.json | ACTIVE |
| Validation Rules | Implicite (audit matrices) | Partiel |
| Business Rules | Workflow implementations | Partiel |

### À Créer
- Formal validation rule set
- Formal business rule set

---

## 11. Conventions

### Mission
Définir les conventions git, review et release.

### Existants (100%)
| Convention | Source | Statut |
|------------|--------|--------|
| Git Hygiene Plan | GIT_CLEANUP_PLAN.md | CANONIQUE |
| Workflow Standard | SUPRA_WORKFLOW_V1.md | CANONIQUE |
| Continuity Standard | CAnnoNico_CONTINUITY_STANDARD.md | CANONIQUE |
| Development Guide | CAnnoNico_DEVELOPMENT_GUIDE.md | CANONIQUE |
| Workflow Standard | CAnnoNico_WORKFLOW_STANDARD.md | CANONIQUE |

---

## 12. Registries

### Mission
Catalogue central de tous les registres avec source canonique par catégorie.

### Existants (60% consolidé)
| Registre | Source Canonique | Statut |
|----------|-----------------|--------|
| Master Registry | SUPRA_MASTER_REGISTRY.json | CANONIQUE |
| Agent Registry | SUPRA_AGENT_REGISTRY_V1.md | CANONIQUE |
| Model Registry | SUPRA_MODEL_REGISTRY_V1.md | CANONIQUE |
| Router Spec | SUPRA_ROUTER_SPECIFICATION_V1.md | CANONIQUE |
| Plugin Registry | SUPRA_PLUGIN_SDK_SPEC.md | SPÉCIFIÉ |
| Provider Registry | .opencode/runtime/provider_registry.json | PARTIEL |

---

## 13. Reuse Assessment

| Domaine | Existant | À Créer | Priorité |
|---------|----------|---------|----------|
| Standards | 80% | Coding standards, architecture doc | MEDIUM |
| Policies | 70% | Security policy | LOW |
| Contracts | 40% | Provider contracts, plugin contracts | HIGH |
| Schemas | 70% | Formal JSON schemas | MEDIUM |
| Templates | 50% | Mission/workflow templates | LOW |
| SDK | 20% | Provider SDK, Plugin SDK | HIGH |
| Agents | 100% | Rien | - |
| Plugins | 100% (spécifié) | Implementation (Phase 2b) | MEDIUM |
| Guides | 80% | Integration guide | LOW |
| Rules | 60% | Validation rules | MEDIUM |
| Conventions | 100% | Rien | - |
| Registries | 100% (consolidé) | Rien | - |

---

## 14. Gap Analysis

### Gaps Critiques
1. Plugin implementation (registry + loader) — bloqué par Phase 2b
2. Provider contracts formels — nécessaire pour runtime activation
3. Plugin contracts — spécifié mais pas implémenté

### Gaps Importants
4. Coding standards document — extraire du code Swift
5. Formal JSON schemas — extraire des structures existantes
6. Provider SDK formel — extraire des protocoles

### Gaps Mineurs
7. Security policy document
8. Integration guide
9. Mission/workflow templates

---

## 15. Migration Plan

1. **Extraire** les patterns existants en documents formels (sans nouveau contenu)
2. **Référencer** les fichiers existants plutôt que les dupliquer
3. **Créer** uniquement les éléments manquants (plugin-related)
4. **Lier** tous les documents depuis le master registry
5. **Conserver** tous les originaux en place — l'Industrial Base est une vue logique

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA FOUNDATION V1.*
