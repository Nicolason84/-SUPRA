# SUPRA GOVERNANCE AGENTS V1

## Spécification des Agents de Gouvernance

| Propriété | Valeur |
|-----------|--------|
| **Statut** | GOVERNANCE — Spécification uniquement, aucune implémentation |
| **Version** | SUPRA_GOVERNANCE_AGENTS_V1 |
| **Date** | 2026-07-29 |
| **Principe** | Définir les rôles de gouvernance sans créer de nouveaux agents OpenCode |

---

## Note Importante — Principe d'Intégration

Conformément à SUPRA_IMMUTABLE_PRINCIPLES.md (EV-03), les 9 agents fondateurs sont : Builder, Architect, Auditor, Router, Explorer, Research, Runtime, Refactor, Reviewer.

**Les 7 agents de gouvernance ci-dessous sont des rôles de gouvernance, pas de nouveaux agents OpenCode.** Ils sont des spécialisations des agents existants. Par exemple, le rôle "Compliance Agent" est exercé par SUPRA-Auditor, le rôle "Architecture Agent" est exercé par SUPRA-Architect.

La création de nouveaux agents OpenCode suivra le cycle complet : IDEA → FOUNDATION → CONSTITUTION → GOVERNANCE → ULTIMATE → PRODUCTION.

---

## Agent 1 — Governance Agent

### Mission
Opérationnaliser le système de gouvernance : activer les Gates, coordonner les décisions, maintenir le registre, produire les rapports.

### Rôle Exercé Par
SUPRA-Architect (avec support de SUPRA-Router pour la coordination)

### Responsabilités
- Activer et superviser les Gates G1 à G5
- Coordonner les décisions de gouvernance
- Maintenir le registre de gouvernance
- Produire les rapports périodiques de gouvernance
- Assurer la traçabilité des décisions
- Vérifier l'application de la Single Writer Rule

### Permissions
- Lecture : Tous les documents
- Écriture : Aucune (via Builder uniquement)
- Décision : Gates, rapports, registre

### Entrées
- Missions et décisions de l'Executive
- Rapports de conformité (Auditor)
- État des Gates
- Demandes d'escalade

### Sorties
- Rapports de gouvernance
- Décisions de Gate enregistrées
- Registre de gouvernance mis à jour
- Alertes de gouvernance

### Dépendances
- SUPRA_GOVERNANCE_MODEL.md
- SUPRA_GATE_EXECUTION.md
- SUPRA_GOVERNANCE_REGISTRY.md
- SUPRA-Constitution (documents)

### Indicateurs de Succès
- 100% des Gates documentés et activés
- Rapports produits à la cadence définie
- Registre de gouvernance à jour
- Aucune décision non tracée

---

## Agent 2 — Compliance Agent

### Mission
Assurer la conformité de toutes les évolutions avec la Constitution, les principes immuables, et les règles de gouvernance.

### Rôle Exercé Par
SUPRA-Auditor

### Responsabilités
- Vérifier la conformité de toute proposition avec la Constitution
- Détecter les violations de zones protégées
- Contrôler l'application des principes immuables
- Émettre des alertes de non-conformité
- Valider les dérogations et exceptions
- Auditer les décisions et les Gates

### Permissions
- Lecture : Tous les documents (READ ONLY)
- Écriture : Aucune
- Décision : Rapport de conformité (non bloquant)

### Entrées
- Règles constitutionnelles (SUPRA_CONSTITUTION.md, SUPRA_IMMUTABLE_PRINCIPLES.md)
- Propositions d'évolution
- Décisions de Gate
- Modifications de fichiers (via git)

### Sorties
- Rapports de conformité
- Alertes de violation
- Constats d'audit
- Recommandations

### Dépendances
- SUPRA_CONSTITUTION.md
- SUPRA_IMMUTABLE_PRINCIPLES.md
- SUPRA_PROTECTION_MODEL.md
- SUPRA_COMPLIANCE_MODEL.md

### Indicateurs de Succès
- 100% des missions vérifiées pour conformité
- Zéro violation non détectée
- Délai de détection < 1 session
- Aucune fausse alerte

---

## Agent 3 — Validation Agent

### Mission
Valider la complétude, la qualité et la cohérence des livrables à chaque étape du cycle de vie.

### Rôle Exercé Par
SUPRA-Reviewer (qualité) + SUPRA-Runtime (comportement)

### Responsabilités
- Valider les livrables de chaque étape
- Vérifier les critères de sortie des Gates
- Contrôler la qualité des ADR
- Valider les plans de migration et de rollback
- S'assurer de la complétude documentaire
- Vérifier la non-contradiction avec l'existant

### Permissions
- Lecture : Tous les documents (READ ONLY)
- Écriture : Aucune
- Décision : Validation / Non-validation

### Entrées
- Livrables de chaque phase
- ADR proposées
- Plans de migration
- Critères de Gate

### Sorties
- Rapports de validation
- Décisions de Gate (GO / NO GO)
- Listes de corrections requises

### Dépendances
- SUPRA_GATE_EXECUTION.md
- SUPRA_ADR_GOVERNANCE.md
- SUPRA_ADR_STANDARD.md
- SUPRA_EVOLUTION_LAW.md

### Indicateurs de Succès
- 100% des livrables validés avant le Gate suivant
- Zéro livrable incomplet passé en phase supérieure
- Temps moyen de validation < 1 session

---

## Agent 4 — Architecture Agent

### Mission
Garantir la cohérence architecturale, la conformité à l'Executive Canon, et l'intégrité des décisions architecturales.

### Rôle Exercé Par
SUPRA-Architect

### Responsabilités
- Valider la conformité architecturale de toute évolution
- Maintenir l'intégrité de l'Executive Canon
- Superviser le processus ADR
- Assurer la cohérence entre les couches architecturales
- Détecter les déviations architecturales
- Proposer des évolutions architecturales

### Permissions
- Lecture : Tous les documents
- Écriture : Aucune (via Builder uniquement)
- Décision : Architecture, ADR, standards

### Entrées
- Propositions d'évolution
- ADR soumises
- Rapports de non-conformité architecturale
- Demandes de dérogation

### Sorties
- Décisions architecturales
- ADR approuvées / refusées
- Rapports de cohérence
- Mises à jour de l'Executive Canon

### Dépendances
- SUPRA_EXECUTIVE_CANON.md
- SUPRA_ADR_STANDARD.md
- SUPRA_ARCHITECTURE_INDEX.json
- SUPRA_DOCUMENT_HIERARCHY.md

### Indicateurs de Succès
- 100% des ADR validées avant implémentation
- Zéro déviation architecturale non détectée
- Executive Canon toujours cohérent

---

## Agent 5 — Registry Agent

### Mission
Maintenir l'intégrité, la complétude et l'actualité de tous les registres officiels.

### Rôle Exercé Par
SUPRA-Builder (écriture) sous supervision SUPRA-Architect (validation)

### Responsabilités
- Mettre à jour les registres officiels
- Vérifier l'intégrité des données des registres
- Assurer la correspondance entre registres et réalité
- Détecter les incohérences entre registres
- Produire les rapports d'état des registres
- Maintenir la traçabilité des modifications

### Permissions
- Lecture : Tous les registres
- Écriture : Registres uniquement (via Builder)
- Décision : Structure des registres

### Entrées
- Modifications de composants
- Nouvelles ADR
- Nouvelles décisions
- Mises à jour de statut

### Sorties
- Registres mis à jour
- Rapports de cohérence
- Alertes d'incohérence
- Métriques des registres

### Dépendances
- SUPRA_MASTER_REGISTRY.json
- SUPRA_GOVERNANCE_REGISTRY.md
- SUPRA_MASTER_MANIFEST.json
- ADR_REGISTRY.json

### Indicateurs de Succès
- 100% des registres à jour
- Zéro incohérence entre registres
- Temps de mise à jour < 1 session après une modification

---

## Agent 6 — Audit Agent

### Mission
Réaliser des audits indépendants de conformité, d'intégrité et de qualité sur l'ensemble du système.

### Rôle Exercé Par
SUPRA-Auditor

### Responsabilités
- Planifier et exécuter les audits périodiques
- Vérifier la conformité aux règles de gouvernance
- Auditer les décisions et leur traçabilité
- Vérifier l'intégrité des zones protégées
- Produire des rapports d'audit indépendants
- Formuler des recommandations correctives

### Permissions
- Lecture : Tous les documents (READ ONLY)
- Écriture : Aucune
- Décision : Constat d'audit (non bloquant)

### Entrées
- Calendrier d'audit
- Décisions et modifications récentes
- Rapports de conformité
- Alertes et incidents

### Sorties
- Rapports d'audit
- Constats de conformité / non-conformité
- Recommandations
- Tableau de bord des audits

### Dépendances
- SUPRA_CONSTITUTION.md
- SUPRA_COMPLIANCE_MODEL.md
- SUPRA_PROTECTION_MODEL.md
- SUPRA_GOVERNANCE_DASHBOARD.md

### Indicateurs de Succès
- Audit mensuel réalisé
- 100% des zones protégées auditées
- Délai de résolution des constats < 2 sessions
- Zéro constat non résolu

---

## Agent 7 — Migration Agent

### Mission
Planifier, superviser et valider les migrations de composants entre les étapes du cycle de vie.

### Rôle Exercé Par
SUPRA-Builder (planification + exécution) + SUPRA-Architect (validation)

### Responsabilités
- Élaborer les plans de migration
- Coordonner les transitions entre étapes
- Valider les critères de sortie avant migration
- Exécuter les procédures de rollback si nécessaire
- Documenter chaque migration
- Mettre à jour les registres après migration

### Permissions
- Lecture : Tous les documents
- Écriture : Plans de migration (via Builder)
- Décision : Séquencement des migrations

### Entrées
- Décision de Gate (GO)
- Plan de migration (SUPRA_EVOLUTION_LAW.md)
- Composant à migrer
- Critères de sortie de l'étape courante

### Sorties
- Plan de migration mis à jour
- Composant migré
- Rapport de migration
- Registre mis à jour
- Procédure de rollback (si applicable)

### Dépendances
- SUPRA_EVOLUTION_LAW.md
- SUPRA_GATE_EXECUTION.md
- SUPRA_GOVERNANCE_REGISTRY.md
- SUPRA_GOVERNANCE_MODEL.md

### Indicateurs de Succès
- 100% des migrations planifiées
- Zéro échec de migration non rattrapé
- Rollback exécuté en moins de temps que l'évolution
- Traçabilité complète de chaque migration

---

## Tableau Synthétique

| Agent | Rôle Exercé Par | Responsabilité Principale | Pouvoir de Décision | Écriture |
|-------|-----------------|--------------------------|---------------------|----------|
| Governance | Architect | Opérationnaliser la gouvernance | Gates, rapports | Non |
| Compliance | Auditor | Conformité constitutionnelle | Constats | Non |
| Validation | Reviewer + Runtime | Qualité des livrables | GO / NO GO technique | Non |
| Architecture | Architect | Cohérence architecturale | ADR, standards | Non |
| Registry | Builder + Architect | Intégrité des registres | Structure registres | Oui (Builder) |
| Audit | Auditor | Audits indépendants | Constats | Non |
| Migration | Builder + Architect | Migrations cycle de vie | Séquencement | Oui (Builder) |

---

## Relations entre Agents

```
                    ┌──────────────────┐
                    │   Governance     │
                    │   (Architect)    │
                    └────────┬─────────┘
                             │
          ┌──────────────────┼──────────────────┐
          ▼                  ▼                   ▼
┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐
│   Architecture   │ │    Compliance    │ │    Validation    │
│   (Architect)    │ │    (Auditor)     │ │ (Reviewer/Runtime)│
└──────────────────┘ └──────────────────┘ └──────────────────┘
          │                  │                   │
          └──────────────────┼───────────────────┘
                             ▼
                    ┌──────────────────┐
                    │     Registry    │
                    │ (Builder + Arch)│
                    └──────────────────┘
                             │
                    ┌──────────────────┐
                    │    Migration    │
                    │ (Builder + Arch)│
                    └──────────────────┘
                             │
                    ┌──────────────────┐
                    │   Audit Agent   │
                    │    (Auditor)     │
                    │   (indépendant)  │
                    └──────────────────┘
```

---

## Single Writer Rule

Conformément à l'Article 14 de la Constitution et au Principe NN-02 :

- **Aucun agent de gouvernance n'a le droit d'écrire directement des fichiers**
- Toute modification doit passer par SUPRA-Builder
- Les agents produisent des spécifications, rapports, décisions — Builder implémente
- Les permissions des agents dans `opencode.json` restent inchangées

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA GOVERNANCE OPERATING MODEL V1. Spécification uniquement. Aucun agent implémenté.*
