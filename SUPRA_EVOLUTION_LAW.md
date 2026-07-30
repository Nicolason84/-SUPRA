# SUPRA EVOLUTION LAW V1

## Protocole Obligatoire pour Toute Évolution du Système SUPRA

| Propriété | Valeur |
|-----------|--------|
| **Statut** | CONSTITUTION — Protocole obligatoire |
| **Version** | SUPRA_EVOLUTION_LAW_V1 |
| **Date** | 2026-07-29 |
| **Principe** | Aucune évolution sans protocole. Aucune exception. |

---

## 1. Définitions

**Évolution** : Toute modification, ajout, dépréciation ou suppression d'un composant, d'une capacité, d'un contrat, d'un standard ou d'une règle de SUPRA.

**Ne sont pas des évolutions** (et ne nécessitent pas ce protocole) :
- Correction de bugs (hotfix)
- Mise à jour de documentation non normative
- Refactoring sans changement fonctionnel
- Changement cosmétique (UI uniquement)

---

## 2. Protocole d'Évolution

Toute évolution doit suivre les 8 étapes suivantes, dans l'ordre :

```
ÉTAPE 1 : OBJECTIF
    Définir clairement ce que l'évolution apporte.
    ──  Livrable : Énoncé d'objectif (1-3 phrases)
    
ÉTAPE 2 : JUSTIFICATION
    Prouver que l'évolution est nécessaire.
    ──  Livrable : Preuve du besoin (analyse, métrique, décision)
    
ÉTAPE 3 : IMPACTS
    Analyser les conséquences sur tous les composants.
    ──  Livrable : Analyse d'impact (matrice)
    
ÉTAPE 4 : DÉPENDANCES
    Identifier les prérequis et dépendances.
    ──  Livrable : Graphe de dépendances
    
ÉTAPE 5 : PREUVES
    Démontrer que l'évolution fonctionne.
    ──  Livrable : Prototype, test, ou démonstration
    
ÉTAPE 6 : PLAN DE MIGRATION
    Décrire comment passer de l'état actuel à l'état cible.
    ──  Livrable : Plan de migration détaillé
    
ÉTAPE 7 : STRATÉGIE DE ROLLBACK
    Définir comment revenir en arrière si nécessaire.
    ──  Livrable : Procédure de rollback
    
ÉTAPE 8 : VALIDATION FINALE
    Valider que l'évolution est complète et conforme.
    ──  Livrable : Rapport de validation
```

---

## 3. Détail des Étapes

### Étape 1 : Objectif

**Format** : Document structuré

**Champs obligatoires** :
- Titre de l'évolution
- Type (NOUVEAU / MODIFICATION / DÉPRÉCIATION / SUPPRESSION)
- Composant(s) concerné(s)
- Objectif (1-3 phrases)
- Critère de succès (mesurable)

**Validateur** : SUPRA-Architect

### Étape 2 : Justification

**Preuves acceptables** :
- Métrique montrant une dégradation (ex: temps de build, taux d'échec)
- Décision architecturale (ADR) existante
- Demande explicite de l'Executive
- Analyse comparative montrant la supériorité de la solution proposée

**Non acceptables** :
- "C'est mieux" sans preuve
- "Tout le monde le fait"
- Préférence personnelle non documentée

**Validateur** : SUPRA-Auditor

### Étape 3 : Impacts

**Matrice d'impact** :

| Dimension | Impact | Sévérité | Mitigation |
|-----------|--------|----------|------------|
| Architecture | [Description] | [Haute/Moyenne/Basse] | [Plan] |
| Contrats | [Description] | [Haute/Moyenne/Basse] | [Plan] |
| Performance | [Description] | [Haute/Moyenne/Basse] | [Plan] |
| Sécurité | [Description] | [Haute/Moyenne/Basse] | [Plan] |
| Réversibilité | [Description] | [Haute/Moyenne/Basse] | [Plan] |
| Tests | [Description] | [Haute/Moyenne/Basse] | [Plan] |
| Documentation | [Description] | [Haute/Moyenne/Basse] | [Plan] |

**Validateur** : SUPRA-Architect

### Étape 4 : Dépendances

**Graphe de dépendances** :

```
[Composant A] ──▶ [Composant B] ──▶ [Composant C]
      │                                      │
      └──────────[Composant D]────────────────┘
```

**Champs obligatoires** :
- Liste des prérequis (composants, capacités, documents)
- Liste des dépendants (composants impactés)
- Risque de blocage identifié

**Validateur** : SUPRA-Architect

### Étape 5 : Preuves

**Preuves acceptables** :
- Code fonctionnel (prototype)
- Tests passants
- Benchmark
- Validation utilisateur
- Preuve de concept

**Seuil** : Une preuve de concept est suffisante pour les phases FOUNDATION et CONSTITUTION. Une implémentation fonctionnelle est requise pour GOVERNANCE et ULTIMATE.

**Validateur** : SUPRA-Runtime (pour le runtime) / SUPRA-Auditor (pour la conformité)

### Étape 6 : Plan de Migration

**Format** :

| Phase | Action | Durée | Risque | Responsable |
|-------|--------|-------|--------|-------------|
| 1 | [Action préparatoire] | [Temps] | [Risque] | [Agent] |
| 2 | [Action principale] | [Temps] | [Risque] | [Agent] |
| 3 | [Validation] | [Temps] | [Risque] | [Agent] |
| 4 | [Nettoyage] | [Temps] | [Risque] | [Agent] |

**Validateur** : SUPRA-Builder

### Étape 7 : Stratégie de Rollback

**Format** :

| Condition | Action de Rollback | Responsable | Durée Max |
|-----------|-------------------|-------------|-----------|
| [Condition d'échec] | [Action pour revenir en arrière] | [Agent] | [Temps max] |

**Exigences** :
- Le rollback doit pouvoir être exécuté en moins de temps que l'évolution
- Le rollback ne doit pas générer de perte de données
- Le rollback doit être testé avant l'évolution

**Validateur** : SUPRA-Runtime

### Étape 8 : Validation Finale

**Checklist de validation** :

| Critère | Statut |
|---------|--------|
| Objectif atteint ? | __PASS / FAIL |
| Justification valide ? | __PASS / FAIL |
| Impacts maîtrisés ? | __PASS / FAIL |
| Dépendances résolues ? | __PASS / FAIL |
| Preuves suffisantes ? | __PASS / FAIL |
| Migration planifiée ? | __PASS / FAIL |
| Rollback prêt ? | __PASS / FAIL |
| Documentation mise à jour ? | __PASS / FAIL |
| ADR créée ? | __PASS / FAIL |
| Gate validé ? | __PASS / FAIL |

**Validateur** : SUPRA-Auditor (conformité) + SUPRA-Architect (architecture)

---

## 4. Seuils d'Activation

| Type de Changement | Protocole Complet | Protocole Allégé |
|--------------------|-------------------|-------------------|
| Nouveau composant | Obligatoire | - |
| Nouvelle capacité | Obligatoire | - |
| Nouvel agent | Obligatoire | - |
| Nouveau plugin | Obligatoire | - |
| Modification contrat | Obligatoire | - |
| Modification architecture | Obligatoire | - |
| Ajout ADR | Obligatoire | - |
| Correction bug | - | N/A (pas une évolution) |
| Refactoring | - | N/A (pas une évolution) |
| Documentation non normative | - | N/A (pas une évolution) |
| Dépréciation composant | Obligatoire | - |
| Suppression composant | Obligatoire + Décision Executive | - |

---

## 5. Correspondance avec le Cycle de Vie

| Étape du Protocole | Cycle de Vie |
|--------------------|--------------|
| Objectif + Justification | IDEA |
| Impacts + Dépendances | FOUNDATION |
| Preuves + Plan de migration | CONSTITUTION |
| Validation ADR | CONSTITUTION |
| Rollback + Validation finale | GOVERNANCE |
| Implémentation complète | ULTIMATE |
| Intégration | PRODUCTION |

---

## 6. Templates

### 6.1 Template d'Évolution

```markdown
# Évolution : [Titre]

## 1. Objectif
[1-3 phrases]

## 2. Justification
[Preuve du besoin]

## 3. Impacts
| Dimension | Impact | Sévérité | Mitigation |
|-----------|--------|----------|------------|
| ... | ... | ... | ... |

## 4. Dépendances
- Prérequis : [...]
- Dépendants : [...]

## 5. Preuves
[Prototype, test, ou démonstration]

## 6. Plan de Migration
| Phase | Action | Durée | Risque | Responsable |
|-------|--------|-------|--------|-------------|
| ... | ... | ... | ... | ... |

## 7. Stratégie de Rollback
| Condition | Action | Responsable | Durée |
|-----------|--------|-------------|-------|
| ... | ... | ... | ... |

## 8. Validation Finale
| Critère | Statut |
|---------|--------|
| ... | ... |
```

### 6.2 Template de Rollback

```markdown
## Rollback : [Évolution]

### Condition de déclenchement
[Quand exécuter le rollback]

### Étapes
1. [Étape 1]
2. [Étape 2]
3. [Étape 3]

### Vérification
[Comment vérifier que le rollback a réussi]

### Durée estimée
[Temps maximum]
```

---

## 7. Sanctions

| Violation | Sanction |
|-----------|----------|
| Évolution sans protocole | INVALIDATION — l'évolution est annulée |
| Protocole incomplet | SUSPENSION — l'évolution est bloquée jusqu'à complétion |
| Fausse justification | REJET — l'évolution est refusée |
| Plan de rollback absent | BLOCAGE — l'évolution ne peut pas commencer |
| Non-respect des validations | RÉVOCATION — l'évolution est annulée et revertée |

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA CONSTITUTION V1.*
