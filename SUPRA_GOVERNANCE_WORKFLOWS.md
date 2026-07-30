# SUPRA GOVERNANCE WORKFLOWS V1

## Workflows Opérationnels de la Gouvernance

| Propriété | Valeur |
|-----------|--------|
| **Statut** | GOVERNANCE — Workflows documentés |
| **Version** | SUPRA_GOVERNANCE_WORKFLOWS_V1 |
| **Date** | 2026-07-29 |
| **Principe** | Toute action de gouvernance suit un workflow défini |
| **Base** | SUPRA_GOVERNANCE_MODEL.md |

---

## 1. Workflow d'Évolution Complète

Le workflow principal qui couvre l'ensemble du cycle de vie d'un composant.

```
IDEA
  │
  ├── 1.1 Exprimer le besoin
  │     └── Note d'intention (max 1 page)
  │
  ├── 1.2 Gate G1 (Executive)
  │     ├── GO → FOUNDATION
  │     └── NO GO → Rejet ou attente
  │
  ▼
FOUNDATION
  │
  ├── 2.1 Définir l'objectif
  ├── 2.2 Justifier le besoin
  ├── 2.3 Analyser les impacts
  ├── 2.4 Identifier les dépendances
  ├── 2.5 Produire les preuves initiales
  ├── 2.6 Rédiger le plan de migration préliminaire
  │
  ├── 2.7 Gate G2 (Architect)
  │     ├── GO → CONSTITUTION
  │     └── NO GO → Retour FOUNDATION
  │
  ▼
CONSTITUTION
  │
  ├── 3.1 Rédiger l'ADR
  ├── 3.2 Définir l'architecture
  ├── 3.3 Spécifier les contrats
  ├── 3.4 Détailler le plan de migration
  ├── 3.5 Définir la stratégie de rollback
  ├── 3.6 Vérifier la conformité (Auditor)
  │
  ├── 3.7 Gate G3 (Architect + Auditor)
  │     ├── GO → GOVERNANCE
  │     └── NO GO → Retour CONSTITUTION
  │
  ▼
GOVERNANCE
  │
  ├── 4.1 Implémenter le composant
  ├── 4.2 Écrire les tests
  ├── 4.3 Mettre à jour la documentation
  ├── 4.4 Tester le rollback
  ├── 4.5 Review qualité (Reviewer)
  ├── 4.6 Vérification runtime (Runtime)
  │
  ├── 4.7 Gate G4 (Auditor + Reviewer + Runtime)
  │     ├── GO → ULTIMATE
  │     └── NO GO → Retour GOVERNANCE
  │
  ▼
ULTIMATE
  │
  ├── 5.1 Intégration finale
  ├── 5.2 Tests d'intégration
  ├── 5.3 Validation sécurité
  ├── 5.4 Production des release notes
  ├── 5.5 Validation Executive
  │
  ├── 5.6 Gate G5 (Executive)
  │     ├── GO → PRODUCTION
  │     └── NO GO → Retour ULTIMATE
  │
  ▼
PRODUCTION
  │
  ├── 6.1 Release officialisée
  ├── 6.2 Registres mis à jour
  ├── 6.3 Surveillance post-release
  └── 6.4 Support et maintenance
```

---

## 2. Workflow de Décision

### 2.1 Décision Standard

```
PROPOSITION
  │
  ├── Identifier le type de décision
  ├── Rédiger la proposition
  ├── Soumettre à l'autorité compétente
  │
  ▼
ÉVALUATION
  │
  ├── Analyser l'impact
  ├── Consulter les parties prenantes
  ├── Vérifier la conformité
  │
  ▼
DÉCISION
  │
  ├── APPROUVÉ → Enregistrer + communiquer
  ├── REFUSÉ → Justifier + enregistrer
  └── À RÉVISER → Retour à l'émetteur avec commentaires
  │
  ▼
EXÉCUTION (si approuvé)
  │
  ├── Assigner à Builder (Single Writer Rule)
  ├── Implémenter
  ├── Vérifier l'implémentation
  │
  ▼
CLÔTURE
  │
  ├── Enregistrer dans le registre
  ├── Mettre à jour les documents impactés
  └── Communiquer aux parties informées
```

### 2.2 Décision d'Urgence

```
URGENCE IDENTIFIÉE
  │
  ├── Executive notifié immédiatement
  ├── Décision prise sans cycle complet
  ├── Exécution immédiate
  │
  ▼
RATIFICATION
  │
  ├── ADR de ratification produite dans la session suivante
  ├── Si ratifiée → décision confirmée
  └── Si non ratifiée → décision annulée, rollback exécuté
```

---

## 3. Workflow d'Escalade

```
CONFLIT ENTRE AGENTS
  │
  ├── Tentative de résolution directe (Agent A ↔ Agent B)
  │     ├── Résolu → Décision enregistrée
  │     └── Non résolu → Escalade
  │
  ▼
TRIAGE (SUPRA-Router)
  │
  ├── Analyser le conflit
  ├── Déterminer le niveau d'escalade approprié
  ├── Transmettre à l'autorité compétente
  │
  ▼
ARBITRAGE TECHNIQUE (SUPRA-Architect)
  │
  ├── Audition des parties
  ├── Analyse des arguments
  ├── Décision technique
  │     ├── Acceptée → Enregistrement + clôture
  │     └── Contestée → Escalade Executive
  │
  ▼
DÉCISION FINALE (Executive)
  │
  ├── Dernier recours
  ├── Décision souveraine
  ├── Enregistrement obligatoire (ADR si applicable)
  └── Clôture du conflit
```

---

## 4. Workflow de Conformité

### 4.1 Contrôle de Conformité

```
DÉCLENCHEMENT (mission, gate, commit, cron)
  │
  ▼
IDENTIFICATION DES RÈGLES APPLICABLES
  │
  ├── Charger les règles (Constitution, Principes, Standards)
  ├── Filtrer par domaine et type
  │
  ▼
VÉRIFICATION
  │
  ├── Comparer l'état réel aux règles
  ├── Collecter les preuves
  │
  ▼
CONSTAT
  │
  ├── CONFORME → Enregistrer + clôturer
  ├── NON CONFORME → Ouvrir une alerte
  └── ALERTE → Notification immédiate
  │
  ▼
SUIVI (si non conforme)
  │
  ├── Ouvrir une action corrective
  ├── Assigner un responsable
  ├── Définir une échéance
  └── Suivre jusqu'à résolution
```

### 4.2 Gestion des Exceptions

```
DEMANDE D'EXCEPTION
  │
  ├── Rédiger la demande (qui, quoi, pourquoi, durée)
  ├── Soumettre à Architect
  │
  ▼
ÉVALUATION
  │
  ├── Analyse d'impact
  ├── Vérification de la nécessité
  │
  ▼
DÉCISION
  │
  ├── APPROUVÉE → Enregistrer dans le registre
  │     └── Exception active avec date d'expiration
  └── REFUSÉE → Justifier, informer le demandeur
  │
  ▼
SUIVI
  │
  ├── Surveillance de l'expiration
  ├── Renouvellement possible (1 fois)
  └── Expiration automatique → clôture
```

---

## 5. Workflow ADR

Détaillé dans SUPRA_ADR_GOVERNANCE.md. Résumé :

```
PROPOSED
  │
  ├── Rédaction conforme au standard
  ├── Soumission
  │
  ▼
REVIEW
  │
  ├── Vérification structure
  ├── Vérification conformité
  ├── Consultation parties prenantes
  │
  ├── ACCEPTED → Enregistrement + implémentation
  └── REJECTED → Justification + conservation
  │
  ▼
IMPLEMENTED → ACTIVE → (SUPERSEDED / DEPRECATED) → ARCHIVED
```

---

## 6. Workflow de Migration

```
DÉCISION DE MIGRATION (Gate GO)
  │
  ▼
PRÉPARATION
  │
  ├── Vérifier les critères de sortie de l'étape courante
  ├── Préparer l'environnement de destination
  ├── Notifier les parties impactées
  │
  ▼
EXÉCUTION
  │
  ├── Migrer les artefacts
  ├── Mettre à jour les registres
  ├── Mettre à jour la documentation
  │
  ▼
VALIDATION
  │
  ├── Vérifier l'intégrité post-migration
  ├── Vérifier les critères d'entrée de l'étape destination
  ├── Si OK → Migration réussie
  └── Si KO → Rollback
  │
  ▼
CLÔTURE
  │
  ├── Enregistrer la migration
  ├── Communiquer le succès
  └── Mettre à jour le dashboard
```

### 6.1 Workflow de Rollback

```
DÉCISION DE ROLLBACK
  │
  ├── Condition de déclenchement identifiée
  ├── Décision (automatique si planifié, ou Executive)
  │
  ▼
EXÉCUTION
  │
  ├── Exécuter le plan de rollback
  ├── Restaurer l'état précédent
  │
  ▼
VÉRIFICATION
  │
  ├── Vérifier le retour à l'état stable
  ├── Vérifier l'absence de perte de données
  │
  ▼
ENREGISTREMENT
  │
  ├── Tracer le rollback
  ├── Analyser la cause
  ├── Ouvrir une action préventive
  └── Mettre à jour le registre
```

---

## 7. Workflow de Rapport de Gouvernance

```
DÉCLENCHEMENT (cadence ou événement)
  │
  ▼
COLLECTE
  │
  ├── Rassembler les indicateurs (dashboard)
  ├── Collecter les décisions de la période
  ├── Collecter les événements de conformité
  │
  ▼
ANALYSE
  │
  ├── Calculer les métriques
  ├── Identifier les tendances
  ├── Détecter les anomalies
  │
  ▼
RÉDACTION
  │
  ├── Synthétiser les constats
  ├── Formuler les recommandations
  └── Préparer le rapport
  │
  ▼
VALIDATION
  │
  ├── Revue par Architect
  ├── Approbation par Executive
  │
  ▼
DIFFUSION
  │
  ├── Publier le rapport
  ├── Notifier les parties prenantes
  └── Archiver dans le registre
```

---

## 8. Workflow d'Audit

```
PLANIFICATION
  │
  ├── Définir le périmètre
  ├── Définir les critères d'audit
  ├── Notifier les parties concernées
  │
  ▼
EXÉCUTION
  │
  ├── Collecter les preuves
  ├── Vérifier point par point
  ├── Documenter les constats
  │
  ▼
RAPPORT
  │
  ├── Rédiger le rapport d'audit
  ├── Lister les non-conformités
  ├── Formuler les recommandations
  │
  ▼
PLAN D'ACTION
  │
  ├── Définir les actions correctives
  ├── Assigner les responsabilités
  ├── Définir les échéances
  │
  ▼
SUIVI
  │
  ├── Suivre l'avancement
  ├── Vérifier la correction
  ├── Clôturer l'audit
  └── Enregistrer dans le registre
```

---

## 9. Workflow de Mise à Jour des Registres

```
ÉVÉNEMENT DÉCLENCHEUR
  │
  ├── Décision de Gate
  ├── Nouvelle ADR
  ├── Modification de composant
  ├── Exception accordée
  └── Changement d'autorité
  │
  ▼
IDENTIFICATION DES REGISTRES IMPACTÉS
  │
  ├── GOVERNANCE_REGISTRY.json
  ├── ADR_REGISTRY.json
  ├── SUPRA_MASTER_MANIFEST.json
  ├── SUPRA_MASTER_REGISTRY.json
  └── Autres registres concernés
  │
  ▼
MISE À JOUR
  │
  ├── Builder modifie les registres
  ├── Vérification par Architect
  │
  ▼
VALIDATION
  │
  ├── Cohérence vérifiée
  ├── Sources canoniques respectées
  │
  ▼
COMMIT
  │
  ├── Commit avec message descriptif
  └── Notification aux parties informées
```

---

## 10. Correspondance avec le Pipeline OpenCode

### 10.1 Pipeline Standard

```
Mission → Executive → Architect → Router → Read Agents → Comparator → Fusion → Validator → Builder
```

### 10.2 Intégration des Workflows de Gouvernance

| Étape Pipeline | Workflow de Gouvernance Associé |
|----------------|---------------------------------|
| Mission | Workflow d'Évolution (IDEA) |
| Executive | Workflow de Décision (approbation) |
| Architect | Workflow ADR, Migration |
| Router | Routage vers les agents appropriés |
| Read Agents | Conformité, Audit |
| Comparator | Comparaison avec les règles |
| Fusion | Cohérence documentaire |
| Validator | Gate G3/G4/G5 selon l'étape |
| Builder | Exécution, registres |

---

## 11. Règles des Workflows

### W-01 : Séquentialité
Les étapes d'un workflow sont exécutées dans l'ordre. Aucune étape ne peut être sautée.

### W-02 : Traçabilité
Chaque transition entre étapes est tracée (date, auteur, décision).

### W-03 : Réversibilité
Toute étape peut être annulée si une étape ultérieure échoue (retour à l'étape précédente).

### W-04 : Délai
Chaque étape a un délai maximum. Passé ce délai, l'étape est escaladée.

### W-05 : Documentation
Chaque workflow produit des livrables documentés.

### W-06 : Exception
Une exception à un workflow peut être accordée par l'autorité compétente avec justification.

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA GOVERNANCE OPERATING MODEL V1. Workflows opérationnels de gouvernance.*
