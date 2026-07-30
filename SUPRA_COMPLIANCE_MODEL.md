# SUPRA COMPLIANCE MODEL V1

## Moteur de Conformité — Règles, Contrôles, Audits, Alertes

| Propriété | Valeur |
|-----------|--------|
| **Statut** | GOVERNANCE — Modèle de conformité |
| **Version** | SUPRA_COMPLIANCE_MODEL_V1 |
| **Date** | 2026-07-29 |
| **Principe** | Toute évolution doit être conforme à la Constitution |
| **Base** | SUPRA_CONSTITUTION.md, SUPRA_IMMUTABLE_PRINCIPLES.md |

---

## 1. Définitions

| Terme | Définition |
|-------|------------|
| **Conformité** | Respect des règles constitutionnelles, des principes immuables, et des standards de gouvernance |
| **Règle obligatoire** | Prescription issue de la Constitution ou des Principes Immuables |
| **Exception** | Dispense temporaire accordée pour une règle spécifique |
| **Dérogation** | Dispense permanente accordée par ADR constitutionnelle |
| **Contrôle automatique** | Vérification programmée, exécutée sans intervention humaine |
| **Audit** | Examen systématique et indépendant de la conformité |
| **Alerte** | Notification déclenchée par une violation détectée |

---

## 2. Règles Obligatoires

### 2.1 Règles Constitutionnelles (Niveau 🔒)

Issues de SUPRA_IMMUTABLE_PRINCIPLES.md :

| ID | Règle | Source | Sanction |
|----|-------|--------|----------|
| C-01 | Unité d'Architecture — une seule architecture officielle | NN-01 | REFUS du composant |
| C-02 | Single Writer Rule — seul Builder écrit | NN-02 | INVALIDATION |
| C-03 | Réversibilité — toute évolution est réversible | NN-03 | BLOCAGE |
| C-04 | Source de Vérité Unique — un seul document par domaine | NN-04 | CORRECTION |
| C-05 | Cycle de Vie Obligatoire — 6 étapes, aucune sautée | NN-05 | INVALIDATION |
| C-06 | Traçabilité des Décisions — ADR obligatoire | NN-06 | REFUS |
| C-07 | Propreté du Workspace — 0 modified avant mission majeure | NN-07 | FAIL automatique |
| C-08 | Aucune Suppression Irréversible | NN-08 | ROLLBACK |
| C-09 | Propriété Unique — tout composant a un propriétaire | NN-09 | REFUS |
| C-10 | Cycle complet — IDEA→FOUNDATION→CONSTITUTION→GOVERNANCE→ULTIMATE→PRODUCTION | Art. 3 | INVALIDATION |
| C-11 | Gates obligatoires — aucune transition sans Gate | Art. 20 | BLOCAGE |
| C-12 | Hiérarchie documentaire — pas de contradiction | H-01 | CORRECTION |

### 2.2 Règles Évolutives (Niveau 🛡️)

| ID | Règle | Source | Validateur |
|----|-------|--------|------------|
| E-01 | Pipeline d'exécution respecté | EV-01 | Architect |
| E-02 | Format documentaire (MD/JSON/Swift) | EV-02 | Architect |
| E-03 | Nombre d'agents — 9 fondateurs | EV-03 | Router |
| E-04 | Fréquence des Gates respectée | EV-04 | Architect |

### 2.3 Règles Opérationnelles (Niveau ⚖️)

| ID | Règle | Source | Validateur |
|----|-------|--------|------------|
| O-01 | Proposition documentée avant implémentation | Art. 10 | Architect |
| O-02 | ADR conforme au standard | SUPRA_ADR_STANDARD.md | Architect |
| O-03 | Plan de rollback avant implémentation | EV-03 | Runtime |
| O-04 | Registres mis à jour après modification | SUPRA_GOVERNANCE_REGISTRY.md | Auditor |
| O-05 | Mission tracée de bout en bout | Art. 7 | Auditor |
| O-06 | Zones protégées respectées | SUPRA_PROTECTION_MODEL.md | Auditor |
| O-07 | Tests passants avant Gate G4 | SUPRA_GATE_EXECUTION.md | Runtime |

---

## 3. Exceptions et Dérogations

### 3.1 Procédure d'Exception (Temporaire)

1. **Demande** : Formulaire d'exception (qui, quoi, pourquoi, durée)
2. **Évaluation** : Analyse d'impact par Architect
3. **Décision** : Executive approuve ou refuse
4. **Enregistrement** : Exception enregistrée dans le registre de gouvernance
5. **Expiration** : L'exception expire automatiquement à la date indiquée
6. **Renouvellement** : Possible une fois, puis dérogation permanente requise

### 3.2 Procédure de Dérogation (Permanente)

1. **ADR** : ADR de niveau CONSTITUTION justifiant la dérogation
2. **Revue** : Revue par Architect + Auditor
3. **Approbation** : Executive approuve
4. **Enregistrement** : Dérogation enregistrée dans les règles de conformité
5. **Réversibilité** : La dérogation doit être réversible

### 3.3 Types d'Exceptions

| Type | Durée Max | Renouvelable | Décideur |
|------|-----------|--------------|----------|
| Technique | 1 mission | 1 fois | Architect |
| Temporelle | 1 semaine | 1 fois | Architect |
| Stratégique | 1 mois | 1 fois | Executive |
| Urgence | 24h | 0 | Executive |

### 3.4 Registre des Exceptions

Toutes les exceptions et dérogations sont enregistrées dans `GOVERNANCE_REGISTRY.json` :

```json
{
  "exceptions": [
    {
      "id": "EXC-001",
      "rule": "C-07",
      "description": "Workspace sale autorisé pour consolidation",
      "granted_by": "Executive",
      "date": "2026-07-29",
      "expires": "2026-08-29",
      "status": "ACTIVE"
    }
  ],
  "derogations": [
    {
      "id": "DER-001",
      "rule": "E-03",
      "description": "Ajout agent SUPRA-Governance comme spécialisation Architect",
      "adr": "ADR-00X",
      "status": "ACTIVE"
    }
  ]
}
```

---

## 4. Contrôles Automatiques

### 4.1 Liste des Contrôles

| ID | Contrôle | Cible | Fréquence | Déclencheur |
|----|----------|-------|-----------|-------------|
| CA-01 | Conformité Constitution | Toute mission | À chaque mission | Début de mission |
| CA-02 | État du workspace | Git status | À chaque Gate | Ouverture Gate |
| CA-03 | Intégrité registres | Registres JSON | Quotidien | Cron |
| CA-04 | Cohérence documentaire | Documents liés | À chaque édition | Commit |
| CA-05 | Protection zones | Fichiers protégés | À chaque modification | Pré-commit |
| CA-06 | Cycle de vie | Composants | Hebdomadaire | Rapport |
| CA-07 | ADR Registry | ADR_REGISTRY.json | À chaque ADR | Nouvelle ADR |
| CA-08 | Gates status | Tableau des Gates | À chaque décision Gate | Décision |

### 4.2 Procédure de Contrôle Automatique

```
1. DÉCLENCHEMENT
   ── Événement : début mission, gate, commit, cron
   
2. VÉRIFICATION
   ── Comparaison de l'état réel avec les règles
   ── Sources : fichiers, registres, git, manifests
   
3. CONSTAT
   ── Résultat : CONFORME / NON CONFORME / ALERTE
   ── Détail : règle violée, gravité, composant concerné
   
4. NOTIFICATION
   ── Si CONFORME : rien
   ── Si NON CONFORME : alerte à l'agent responsable
   ── Si ALERTE : notification Executive + Architect
   
5. SUIVI
   ── Enregistrement dans le registre des contrôles
   ── Si non conforme : ouverture d'une action corrective
```

### 4.3 Seuils d'Alerte

| Niveau | Gravité | Action |
|--------|---------|--------|
| 🔴 Critique | Violation d'une règle immuable | Blocage immédiat + notification Executive |
| 🟠 Élevée | Violation d'une règle protégée | Alerte Architect + action corrective obligatoire |
| 🟡 Moyenne | Violation d'une règle gouvernée | Notification Architect + correction recommandée |
| 🔵 Faible | Non-respect d'une recommandation | Information + suivi au prochain rapport |

---

## 5. Audits

### 5.1 Types d'Audit

| Type | Périmètre | Fréquence | Durée | Effectué Par |
|------|-----------|-----------|-------|-------------|
| **Conformité constitutionnelle** | Ensemble du système | Mensuel | 2 sessions | Auditor |
| **Intégrité des registres** | Tous les registres | Hebdomadaire | 1 session | Auditor |
| **Protection des zones** | Fichiers protégés | Hebdomadaire | 1 session | Auditor |
| **Traçabilité des décisions** | ADR, Gates, décisions | Mensuel | 2 sessions | Auditor |
| **Qualité des livrables** | Missions récentes | Par mission | 1 session | Reviewer |
| **Runtime** | Comportement système | Mensuel | 2 sessions | Runtime |
| **Complet (tous domaines)** | Tout le système | Trimestriel | 4 sessions | Auditor + Architect |

### 5.2 Procédure d'Audit

```
1. PLANIFICATION
   ── Définition du périmètre, des critères, du calendrier
   ── Notification des parties concernées

2. EXÉCUTION
   ── Collecte des preuves (fichiers, registres, logs, métriques)
   ── Vérification de conformité point par point
   ── Entretiens avec les agents responsables si nécessaire

3. RAPPORT
   ── Constats (conformes / non conformes)
   ── Preuves à l'appui
   ── Recommandations

4. PLAN D'ACTION
   ── Actions correctives définies
   ── Responsables et délais assignés
   ── Suivi dans le registre des audits

5. CLÔTURE
   ── Validation des actions correctives
   ── Rapport d'audit final
   ── Enregistrement dans le registre des audits
```

### 5.3 Format du Rapport d'Audit

```markdown
# Rapport d'Audit : [Date]

## Périmètre
[Domaine(s) audité(s)]

## Résumé
- Conforme : [N] / [Total]
- Non conforme : [N] / [Total]
- Alerte : [N] / [Total]

## Constats
| ID | Règle | Statut | Preuve | Recommandation |
|----|-------|--------|--------|----------------|
| [ID] | [Règle] | ✅/❌/⚠️ | [Lien] | [Action] |

## Actions Correctives
| ID | Action | Responsable | Échéance | Statut |
|----|--------|-------------|----------|--------|
| [ID] | [Action] | [Agent] | [Date] | [Statut] |

## Conclusion
Approuvé par : [Auditor]
Date de clôture : [Date]
```

---

## 6. Alertes

### 6.1 Types d'Alerte

| Type | Canal | Destinataire | Délai |
|------|-------|-------------|-------|
| **🔴 Critique** | Message immédiat | Executive + Architect | Immédiat |
| **🟠 Élevée** | Rapport de session | Architect | Fin de session |
| **🟡 Moyenne** | Rapport hebdomadaire | Architect + Auditor | Hebdomadaire |
| **🔵 Faible** | Rapport mensuel | Tous | Mensuel |

### 6.2 Contenu d'une Alerte

```json
{
  "alert_id": "ALT-001",
  "type": "CRITICAL",
  "rule": "C-05",
  "description": "Tentative de contournement du cycle de vie",
  "component": "example-component",
  "detected_by": "Compliance Agent",
  "detected_at": "2026-07-29T10:00:00Z",
  "evidence": "Le composant est passé directement en PRODUCTION sans Gate G4",
  "action_required": "Bloquer + retour en GOVERNANCE",
  "assigned_to": "SUPRA-Architect",
  "deadline": "2026-07-30T10:00:00Z"
}
```

### 6.3 Actions sur Alerte

| Type | Action Immédiate | Action Corrective | Escalade |
|------|-----------------|-------------------|----------|
| 🔴 Critique | Blocage du composant | ADR corrective + retour étape antérieure | Executive |
| 🟠 Élevée | Suspension de la modification | Correction + re-validation | Architect |
| 🟡 Moyenne | Notification au responsable | Plan de correction | Architect |
| 🔵 Faible | Enregistrement pour suivi | Inclusion au prochain rapport | - |

---

## 7. Tableau de Bord de la Conformité

### 7.1 Indicateurs

| Indicateur | Cible | Mesure | Fréquence |
|------------|-------|--------|-----------|
| Taux de conformité global | > 95% | Conforme / total contrôles | Hebdomadaire |
| Taux de violations critiques | 0 | Nombre d'alertes 🔴 | En continu |
| Temps de détection | < 1 session | Date violation → détection | Mensuel |
| Temps de résolution | < 2 sessions | Date détection → résolution | Mensuel |
| Couverture d'audit | 100% zones protégées | Zones auditées / total | Mensuel |
| Dette de conformité | < 5 actions | Actions correctives ouvertes | Hebdomadaire |

### 7.2 Format du Rapport de Conformité

```markdown
# Rapport de Conformité — [Date]

## Vue d'Ensemble
- Conformité globale : [XX]%
- Alertes critiques : [N]
- Actions correctives : [N] ouvertes / [N] fermées

## Détail par Domaine
| Domaine | Conforme | Non Conforme | Taux |
|---------|----------|--------------|------|
| Constitution | N | N | XX% |
| Architecture | N | N | XX% |
| Registres | N | N | XX% |
| Gates | N | N | XX% |
| ADR | N | N | XX% |

## Top Violations
| Règle | Nb Violations | Gravité |
|-------|---------------|---------|
| [ID] | [N] | [🔴/🟠/🟡/🔵] |

## Actions Correctives en Cours
| ID | Action | Responsable | Échéance | Statut |
|----|--------|-------------|----------|--------|
| [ID] | [Description] | [Agent] | [Date] | [Statut] |
```

---

## 8. Cycle d'Amélioration Continue

```
┌─────────────────────────────────────────────────────────┐
│                AMÉLIORATION CONTINUE                     │
│                                                          │
│  Contrôle → Constat → Correction → Vérification →       │
│  ↑                                       │              │
│  └───────────────────────────────────────┘              │
│                                                          │
│  Chaque cycle :                                          │
│  1. Contrôler (automatique ou manuel)                   │
│  2. Analyser le constat                                 │
│  3. Corriger la non-conformité                          │
│  4. Vérifier la correction                              │
│  5. Ajuster les règles si nécessaire (ADR)              │
└─────────────────────────────────────────────────────────┘
```

---

## 9. Intégration avec les Autres Documents

| Document | Liaison avec Compliance |
|----------|------------------------|
| SUPRA_CONSTITUTION.md | Source de toutes les règles |
| SUPRA_IMMUTABLE_PRINCIPLES.md | Règles non négociables (C-01 à C-09) |
| SUPRA_PROTECTION_MODEL.md | Règles de protection des zones |
| SUPRA_GATE_EXECUTION.md | Contrôle des Gates |
| SUPRA_ADR_GOVERNANCE.md | Conformité des ADR |
| SUPRA_GOVERNANCE_REGISTRY.md | Registre des exceptions et dérogations |
| SUPRA_GOVERNANCE_DASHBOARD.md | Indicateurs de conformité |
| SUPRA_GOVERNANCE_AGENTS.md | Rôle Compliance Agent (Auditor) |

---

## 10. Contradictions Résolues

| Document | Contradiction Potentielle | Résolution |
|----------|--------------------------|------------|
| SUPRA_PROTECTION_MODEL.md | Règle P-01 : "Non-Rétrogradation" des niveaux de protection | Confirmé : les exceptions ne sont pas des rétrogradations mais des dispenses temporaires |
| SUPRA_IMMUTABLE_PRINCIPLES.md (TP-01) | Workspace sale toléré → contredit C-07 | Résolu : TP-01 est une exception temporaire enregistrée dans le registre des exceptions |
| SUPRA_AUTHORITY_MODEL.md | Auditor a un rôle de conformité mais pas de sanction | Confirmé : Auditor constate, Architect/Executive sanctionne |

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA GOVERNANCE OPERATING MODEL V1. Aucune fonctionnalité développée.*
