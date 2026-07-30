# SUPRA PROTECTION MODEL V1

## Modèle de Protection — Zones Protégées et Droits d'Évolution

| Propriété | Valeur |
|-----------|--------|
| **Statut** | CONSTITUTION |
| **Version** | SUPRA_PROTECTION_MODEL_V1 |
| **Date** | 2026-07-29 |
| **Principe** | Tout composant a un niveau de protection. Tout niveau a des droits d'évolution définis. |

---

## 1. Définitions

### 1.1 Zone Protégée

Une zone protégée est un ensemble de composants soumis à des règles d'évolution spécifiques.

### 1.2 Niveau de Protection

Chaque composant a un niveau de protection qui détermine :
- Qui peut le modifier
- Sous quelles conditions
- Avec quelle procédure

### 1.3 Droit d'Évolution

Le droit d'évolution est l'ensemble des actions autorisées sur un composant selon son niveau de protection.

---

## 2. Niveaux de Protection

| Niveau | Code | Statut | Exemples |
|--------|------|--------|----------|
| **IMMUABLE** | 🔒 | Ne peut jamais être modifié | SUPRA_CONSTITUTION.md, SUPRA_IMMUTABLE_PRINCIPLES.md |
| **PROTÉGÉ** | 🛡️ | Modification possible uniquement avec ADR + Gate | SUPRA_EXECUTIVE_CANON.md, SUPRA_MASTER_MANIFEST.json |
| **GOUVERNÉ** | ⚖️ | Modification possible avec validation architecturale | SUPRA_AGENT_CANON.md, AGENTS.md |
| **EXPÉRIMENTAL** | 🧪 | Modification libre mais sous surveillance | SUPRA_THEORY_READINESS.md, SUPRA_PLUGIN_SDK_SPEC.md |
| **LIBRE** | 📝 | Modification libre | Documentation, rapports, logs |

---

## 3. Matrice des Niveaux

### 3.1 Composants Immuables (🔒)

| Composant | Justification | Sanction si Modification |
|-----------|--------------|--------------------------|
| SUPRA_CONSTITUTION.md | Constitution du système | Amendement constitutionnel requis |
| SUPRA_IMMUTABLE_PRINCIPLES.md | Principes non négociables | Amendement constitutionnel requis |
| SUPRA_AUTHORITY_MODEL.md | Modèle d'autorité | Amendement constitutionnel requis |
| SUPRA_DOCUMENT_HIERARCHY.md | Hiérarchie documentaire | Amendement constitutionnel requis |
| SUPRA_EVOLUTION_LAW.md | Loi d'évolution | Amendement constitutionnel requis |
| SUPRA_GATE_SYSTEM.md | Système de gates | Amendement constitutionnel requis |
| SUPRA_ADR_STANDARD.md | Standard ADR | Amendement constitutionnel requis |
| SUPRA_PROTECTION_MODEL.md | Modèle de protection | Amendement constitutionnel requis |

**Droits d'Évolution** :
- Lecture : Tout le monde
- Écriture : Personne (sauf amendement constitutionnel)
- Suppression : Impossible
- Dépréciation : Impossible

**Procédure d'Amendement** :
1. ADR de niveau CONSTITUTION
2. Validation par SUPRA-Architect
3. Approbation par Executive
4. Enregistrement dans git
5. Mise à jour de tous les documents impactés

### 3.2 Composants Protégés (🛡️)

| Composant | Justification |
|-----------|--------------|
| SUPRA_EXECUTIVE_CANON.md | Canon exécutif — architecture officielle |
| SUPRA_MASTER_MANIFEST.json | Manifeste maître — autorité unique |
| SUPRA_MASTER_REGISTRY.json | Registre maître — sources de vérité |
| SUPRA_FOUNDATION_RULES.md | Règles de la base industrielle |
| SUPRA_PHASE2_GATE.md | Gate officiel Phase 2 |
| SUPRA_FOUNDATION_ROADMAP.md | Roadmap officielle |
| SUPRA_FOUNDATION_VALIDATION_REPORT.md | Rapport de validation canonique |
| SUPRA_FOUNDATION_EXECUTIVE_REPORT.md | Rapport exécutif canonique |
| opencode.json | Configuration OpenCode |

**Droits d'Évolution** :
- Lecture : Tout le monde
- Écriture : Builder uniquement, avec ADR validée
- Suppression : Impossible
- Dépréciation : ADR + validation Executive

**Procédure de Modification** :
1. ADR de niveau ARCHITECTURE ou STANDARD
2. Validation par SUPRA-Architect
3. Approbation par Executive
4. Gate G2 validé
5. Implémentation par Builder
6. Mise à jour du registre

### 3.3 Composants Gouvernés (⚖️)

| Composant | Justification |
|-----------|--------------|
| AGENTS.md | Définitions des agents |
| SUPRA_AGENT_CANON.md | Architecture des agents |
| SUPRA_AGENT_REGISTRY_V1.md | Registre des agents |
| SUPRA_MODEL_REGISTRY_V1.md | Registre des modèles |
| SUPRA_ROUTER_SPECIFICATION_V1.md | Spécification du routeur |
| SUPRA_WORKFLOW_V1.md | Pipeline de workflow |
| SUPRA_AI_LAB_ARCHITECTURE_V1.md | Architecture du lab |
| VALIDATION_PROTOCOL.md | Protocole de validation |
| DESKTOP_GOVERNANCE.md | Gouvernance Desktop |
| CAnnoNico_* | Standards éditoriaux |
| SUPRA_ZERO_* | Archives historiques ZERO |
| ADR/* | Architecture Decision Records |
| FREEZE_* | Artifacts frozen |
| WORKSPACE_MANIFEST.json | Manifeste workspace |
| RUNTIME_STATUS.json | Statut runtime |
| SUPRA_STATE.json | État du système |

**Droits d'Évolution** :
- Lecture : Tout le monde
- Écriture : Builder avec validation architecturale
- Suppression : Impossible
- Dépréciation : Validation Architect

**Procédure de Modification** :
1. ADR de niveau STANDARD ou COMPONENT (si applicable)
2. Validation par SUPRA-Architect
3. Implémentation par Builder
4. Mise à jour des documents liés

### 3.4 Composants Expérimentaux (🧪)

| Composant | Justification |
|-----------|--------------|
| SUPRA_PLUGIN_SDK_SPEC.md | Spécification SDK (en attendant implémentation) |
| SUPRA_THEORY_READINESS.md | Préparation Theory (en attendant Phase 2c) |
| SUPRA_GOVERNANCE_READINESS.md | Préparation Governance (post-Constituion) |
| Tout composant en phase IDEA ou FOUNDATION | En cours de définition |

**Droits d'Évolution** :
- Lecture : Tout le monde
- Écriture : Builder, modification libre
- Suppression : Avec validation Architect
- Dépréciation : Sans restriction

**Procédure de Modification** :
- Modification libre, sans validation préalable
- Notification à SUPRA-Architect si changement de périmètre

### 3.5 Composants Libres (📝)

| Composant | Justification |
|-----------|--------------|
| Rapports de session | SESSION_SNAPSHOT_*.json |
| Rapports d'audit | *_REPORT.md (non canoniques) |
| Logs | Logs/* |
| Métriques temporaires | metrics.json, runtime_metrics.json |
| Missions terminées | Missions/* |
| Documents de travail | Inbox/, Outbox/ |

**Droits d'Évolution** :
- Lecture : Tout le monde
- Écriture : Tout agent autorisé
- Suppression : Avec précaution, pas de suppression irréversible
- Dépréciation : Sans restriction

---

## 4. Cartographie des Zones Protégées

```
┌─────────────────────────────────────────────────────────────┐
│                    WORKSPACE SUPRA                           │
│                                                              │
│  🔒 IMMUABLE (8 fichiers)                                    │
│  ┌───────────────────────────────────────────────────────┐   │
│  │ SUPRA_CONSTITUTION.md et 7 documents constitutionnels │   │
│  └───────────────────────────────────────────────────────┘   │
│                                                              │
│  🛡️ PROTÉGÉ (8 fichiers)                                    │
│  ┌───────────────────────────────────────────────────────┐   │
│  │ SUPRA_EXECUTIVE_CANON.md                               │   │
│  │ SUPRA_MASTER_MANIFEST.json / REGISTRY.json             │   │
│  │ SUPRA_FOUNDATION_RULES.md, ROADMAP.md                  │   │
│  │ SUPRA_FOUNDATION_*REPORT.md, SUPRA_PHASE2_GATE.md      │   │
│  │ opencode.json                                          │   │
│  └───────────────────────────────────────────────────────┘   │
│                                                              │
│  ⚖️ GOUVERNÉ (~20 fichiers)                                 │
│  ┌───────────────────────────────────────────────────────┐   │
│  │ AGENTS.md, SUPRA_AGENT_CANON.md                        │   │
│  │ SUPRA_AGENT_REGISTRY_V1.md, MODEL_REGISTRY_V1.md       │   │
│  │ SUPRA_ROUTER_SPECIFICATION_V1.md, WORKFLOW_V1.md       │   │
│  │ SUPRA_AI_LAB_ARCHITECTURE_V1.md, VALIDATION_PROTOCOL   │   │
│  │ DESKTOP_GOVERNANCE.md, CAnnoNico_*, SUPRA_ZERO_*       │   │
│  │ ADR/*, FREEZE_*, WORKSPACE_MANIFEST.json               │   │
│  │ RUNTIME_STATUS.json, SUPRA_STATE.json                  │   │
│  └───────────────────────────────────────────────────────┘   │
│                                                              │
│  🧪 EXPÉRIMENTAL (3+ fichiers)                              │
│  ┌───────────────────────────────────────────────────────┐   │
│  │ SUPRA_PLUGIN_SDK_SPEC.md, THEORY_READINESS.md         │   │
│  │ SUPRA_GOVERNANCE_READINESS.md                          │   │
│  └───────────────────────────────────────────────────────┘   │
│                                                              │
│  📝 LIBRE (nombreux fichiers)                                │
│  ┌───────────────────────────────────────────────────────┐   │
│  │ Rapports, Logs, Métriques, Missions archives          │   │
│  └───────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## 5. Règles de Protection

### Règle P-01 : Non-Rétrogradation

Un composant ne peut jamais passer à un niveau de protection inférieur. Les transitions sont unidirectionnelles vers le haut :
`LIBRE → EXPÉRIMENTAL → GOUVERNÉ → PROTÉGÉ → IMMUABLE`

### Règle P-02 : Héritage

Un composant qui dépend d'un composant protégé hérite automatiquement de son niveau de protection minimum.

### Règle P-03 : Dérivation

Un document dérivé (ex: rapport généré depuis un registre) peut avoir un niveau de protection inférieur à sa source.

### Règle P-04 : Exception

Une exception temporaire à un niveau de protection peut être accordée par l'Executive, avec durée et périmètre définis.

### Règle P-05 : Audit

Toute modification d'un composant PROTÉGÉ ou GOUVERNÉ doit être auditée par SUPRA-Auditor.

### Règle P-06 : Réversibilité

Toute modification d'un composant non LIBRE doit être réversible.

---

## 6. Droits d'Évolution par Rôle

| Rôle | 🔒 Immuable | 🛡️ Protégé | ⚖️ Gouverné | 🧪 Experimental | 📝 Libre |
|------|-------------|-------------|--------------|-----------------|----------|
| Executive | Amendement | Approuve | Approuve | Informé | Informé |
| Architect | Propose amendement | Valide ADR | Valide | Notifié | - |
| Builder | - | Écrit avec ADR | Écrit | Écrit librement | Écrit |
| Auditor | Vérifie | Vérifie | Vérifie | - | - |
| Reviewer | - | Revue | Revue | - | - |
| Router | - | - | - | - | - |
| Research | - | - | - | - | - |
| Explorer | - | - | - | - | Lit |
| Runtime | - | - | - | - | - |
| Refactor | - | - | Lecture | Lecture | - |

---

## 7. Procédure de Changement de Niveau

Un composant peut changer de niveau de protection selon les règles suivantes :

| Transition | Condition | Validateur |
|------------|-----------|------------|
| 📝 → 🧪 | Décision de l'agent responsable | Architect |
| 🧪 → ⚖️ | Validation architecturale + ADR | Architect + Executive |
| ⚖️ → 🛡️ | ADR + Gate G3 validé | Architect + Auditor |
| 🛡️ → 🔒 | Amendement constitutionnel | Executive |
| Toute rétrogradation | INTERDITE (sauf décision Executive exceptionnelle) | Executive |

---

## 8. Registre des Niveaux

| Fichier | Niveau | Statut |
|---------|--------|--------|
| SUPRA_CONSTITUTION.md | 🔒 IMMUABLE | ACTIF |
| SUPRA_IMMUTABLE_PRINCIPLES.md | 🔒 IMMUABLE | ACTIF |
| SUPRA_AUTHORITY_MODEL.md | 🔒 IMMUABLE | ACTIF |
| SUPRA_DOCUMENT_HIERARCHY.md | 🔒 IMMUABLE | ACTIF |
| SUPRA_EVOLUTION_LAW.md | 🔒 IMMUABLE | ACTIF |
| SUPRA_GATE_SYSTEM.md | 🔒 IMMUABLE | ACTIF |
| SUPRA_ADR_STANDARD.md | 🔒 IMMUABLE | ACTIF |
| SUPRA_PROTECTION_MODEL.md | 🔒 IMMUABLE | ACTIF |
| SUPRA_EXECUTIVE_CANON.md | 🛡️ PROTÉGÉ | CANONIQUE |
| SUPRA_MASTER_MANIFEST.json | 🛡️ PROTÉGÉ | CANONIQUE |
| SUPRA_MASTER_REGISTRY.json | 🛡️ PROTÉGÉ | CANONIQUE |
| SUPRA_FOUNDATION_RULES.md | 🛡️ PROTÉGÉ | CANONIQUE |
| SUPRA_PHASE2_GATE.md | 🛡️ PROTÉGÉ | CANONIQUE |
| SUPRA_FOUNDATION_ROADMAP.md | 🛡️ PROTÉGÉ | CANONIQUE |
| opencode.json | 🛡️ PROTÉGÉ | ACTIF |
| AGENTS.md | ⚖️ GOUVERNÉ | ACTIF |
| SUPRA_AGENT_CANON.md | ⚖️ GOUVERNÉ | CANONIQUE |
| SUPRA_PLUGIN_SDK_SPEC.md | 🧪 EXPÉRIMENTAL | SPÉCIFIÉ |
| SUPRA_THEORY_READINESS.md | 🧪 EXPÉRIMENTAL | PRÉPARATION |
| SUPRA_GOVERNANCE_READINESS.md | 🧪 EXPÉRIMENTAL | PRÉPARATION |
| Rapports | 📝 LIBRE | VARIABLE |
| Logs | 📝 LIBRE | VARIABLE |

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA CONSTITUTION V1.*
