# SUPRA GOVERNANCE DASHBOARD V1

## Spécification des Indicateurs Officiels de Gouvernance

| Propriété | Valeur |
|-----------|--------|
| **Statut** | GOVERNANCE — Spécification uniquement, aucune implémentation graphique |
| **Version** | SUPRA_GOVERNANCE_DASHBOARD_V1 |
| **Date** | 2026-07-29 |
| **Principe** | Ce qui se mesure s'améliore. Ce qui se gouverne se mesure. |

---

## 1. Principes du Dashboard

### 1.1 Objectifs
- Donner une vision claire de l'état de la gouvernance
- Détecter les anomalies et blocages
- Suivre la progression des composants dans le cycle de vie
- Mesurer l'efficacité du système de gouvernance

### 1.2 Non-Objectifs
- Interface graphique (UI/UX) — aucune implémentation
- Dashboard en temps réel (données statiques suffisantes)
- Outil de décision automatique (décision humaine toujours requise)

### 1.3 Format
Les indicateurs sont produits sous forme de données structurées (JSON) pouvant être :
- Intégrées dans un rapport Markdown
- Visualisées par un outil externe
- Utilisées par les agents pour la décision

---

## 2. Indicateurs de Conformité

### 2.1 Taux de Conformité Global

| Propriété | Valeur |
|-----------|--------|
| **ID** | M-C-01 |
| **Nom** | Taux de conformité global |
| **Description** | Pourcentage de contrôles de conformité passés |
| **Formule** | (Contrôles conformes / Total contrôles) × 100 |
| **Cible** | > 95% |
| **Seuil alerte** | < 90% |
| **Fréquence** | Hebdomadaire |
| **Source** | SUPRA_COMPLIANCE_MODEL.md |

### 2.2 Taux de Violations par Gravité

| Propriété | Valeur |
|-----------|--------|
| **ID** | M-C-02 |
| **Nom** | Violations par gravité |
| **Description** | Nombre de violations par niveau de gravité |
| **Mesures** | 🔴 Critiques, 🟠 Élevées, 🟡 Moyennes, 🔵 Faibles |
| **Cible** | 0 🔴, 0 🟠 |
| **Fréquence** | En continu |

### 2.3 Temps de Détection des Violations

| Propriété | Valeur |
|-----------|--------|
| **ID** | M-C-03 |
| **Nom** | Temps de détection |
| **Description** | Délai entre la violation et sa détection |
| **Cible** | < 1 session |
| **Fréquence** | Mensuelle |

### 2.4 Temps de Résolution

| Propriété | Valeur |
|-----------|--------|
| **ID** | M-C-04 |
| **Nom** | Temps de résolution |
| **Description** | Délai entre la détection et la résolution |
| **Cible** | < 2 sessions |
| **Fréquence** | Mensuelle |

---

## 3. Indicateurs de Couverture

### 3.1 Couverture des Contrôles

| Propriété | Valeur |
|-----------|--------|
| **ID** | M-K-01 |
| **Nom** | Couverture des contrôles |
| **Description** | Pourcentage des règles effectivement contrôlées |
| **Formule** | (Règles contrôlées / Règles totales) × 100 |
| **Cible** | 100% |
| **Fréquence** | Hebdomadaire |

### 3.2 Couverture des Audits

| Propriété | Valeur |
|-----------|--------|
| **ID** | M-K-02 |
| **Nom** | Couverture des audits |
| **Description** | Zones et composants audités vs. total |
| **Cible** | 100% zones protégées auditées par mois |
| **Fréquence** | Mensuelle |

### 3.3 Couverture des ADR

| Propriété | Valeur |
|-----------|--------|
| **ID** | M-K-03 |
| **Nom** | Couverture ADR |
| **Description** | Décisions architecturales documentées vs. total |
| **Cible** | 100% |
| **Fréquence** | Mensuelle |

### 3.4 Couverture Documentaire

| Propriété | Valeur |
|-----------|--------|
| **ID** | M-K-04 |
| **Nom** | Couverture documentaire |
| **Description** | Documents à jour vs. documents totaux |
| **Cible** | 100% documents canoniques à jour |
| **Fréquence** | Mensuelle |

---

## 4. Indicateurs de Maturité

### 4.1 Maturité des Composants

| Propriété | Valeur |
|-----------|--------|
| **ID** | M-M-01 |
| **Nom** | Maturité par composant |
| **Description** | Phase du cycle de vie de chaque composant |
| **Mesures** | IDEA, FOUNDATION, CONSTITUTION, GOVERNANCE, ULTIMATE, PRODUCTION |
| **Fréquence** | Hebdomadaire |

### 4.2 Progression dans le Cycle de Vie

```json
{
  "maturity": {
    "IDEA": {"count": 0, "components": []},
    "FOUNDATION": {"count": 0, "components": []},
    "CONSTITUTION": {"count": 0, "components": []},
    "GOVERNANCE": {"count": 0, "components": []},
    "ULTIMATE": {"count": 0, "components": []},
    "PRODUCTION": {"count": 3, "components": ["SUPRA ZERO", "SUPRA FOUNDATION", "SUPRA CONSTITUTION"]}
  }
}
```

### 4.3 Maturité des Couches Architecturales

| Propriété | Valeur |
|-----------|--------|
| **ID** | M-M-02 |
| **Nom** | Maturité par couche |
| **Description** | % de complétion par couche L0-L6 |
| **Source** | SUPRA_MASTER_MANIFEST.json |
| **Fréquence** | Hebdomadaire |

### 4.4 Maturité du Système de Gouvernance

| Propriété | Valeur |
|-----------|--------|
| **ID** | M-M-03 |
| **Nom** | Maturité gouvernance |
| **Description** | % d'activation des composants de gouvernance |
| **Mesures** | Gates activés, registre actif, agents définis, etc. |
| **Cible** | 100% |

---

## 5. Indicateurs de Dette

### 5.1 Dette de Conformité

| Propriété | Valeur |
|-----------|--------|
| **ID** | M-D-01 |
| **Nom** | Dette de conformité |
| **Description** | Nombre d'actions correctives ouvertes |
| **Cible** | < 5 |
| **Seuil alerte** | > 10 |
| **Fréquence** | Hebdomadaire |

### 5.2 Dette Documentaire

| Propriété | Valeur |
|-----------|--------|
| **ID** | M-D-02 |
| **Nom** | Dette documentaire |
| **Description** | Nombre de documents en retard de mise à jour |
| **Cible** | 0 |
| **Fréquence** | Mensuelle |

### 5.3 Dette Technique

| Propriété | Valeur |
|-----------|--------|
| **ID** | M-D-03 |
| **Nom** | Dette technique |
| **Description** | Nombre d'ADR non implémentées, tests en échec, etc. |
| **Fréquence** | Mensuelle |

---

## 6. Indicateurs de Risques

### 6.1 Risques Actifs

| Propriété | Valeur |
|-----------|--------|
| **ID** | M-R-01 |
| **Nom** | Risques actifs |
| **Description** | Nombre de risques identifiés non résolus |
| **Mesures** | Critique, Élevé, Moyen, Faible |
| **Fréquence** | Hebdomadaire |

### 6.2 Blocages

| Propriété | Valeur |
|-----------|--------|
| **ID** | M-R-02 |
| **Nom** | Blocages |
| **Description** | Nombre de composants ou missions bloqués |
| **Cible** | 0 |
| **Fréquence** | En continu |

### 6.3 Exceptions Actives

| Propriété | Valeur |
|-----------|--------|
| **ID** | M-R-03 |
| **Nom** | Exceptions actives |
| **Description** | Nombre d'exceptions temporaires en cours |
| **Cible** | < 3 |
| **Fréquence** | Hebdomadaire |

---

## 7. Indicateurs de Santé du Système

### 7.1 Santé Globale

| Propriété | Valeur |
|-----------|--------|
| **ID** | M-H-01 |
| **Nom** | Santé du système |
| **Description** | Indice composite de santé |
| **Composantes** | Conformité, couverture, maturité, dette, risques, blocages |
| **Format** | Score / 10 |
| **Fréquence** | Hebdomadaire |

**Calcul de l'indice** :
```
Santé = (
  (conformité × 0.25) +
  (couverture × 0.20) +
  (maturité × 0.15) +
  ((10 - dette_ratio) × 0.15) +
  ((10 - risque_ratio) × 0.15) +
  ((10 - blocage_ratio) × 0.10)
) × 10
```

Où chaque ratio est normalisé entre 0 et 1.

### 7.2 Intégrité des Registres

| Propriété | Valeur |
|-----------|--------|
| **ID** | M-H-02 |
| **Nom** | Intégrité des registres |
| **Description** | % de registres cohérents et à jour |
| **Cible** | 100% |
| **Fréquence** | Quotidienne |

### 7.3 État du Workspace

| Propriété | Valeur |
|-----------|--------|
| **ID** | M-H-03 |
| **Nom** | Propreté du workspace |
| **Description** | Nombre de fichiers modifiés non commités |
| **Cible** | 0 (sauf exceptions actives) |
| **Fréquence** | À chaque mission |

---

## 8. Indicateurs de Progression des Gates

### 8.1 Progression par Composant

| Propriété | Valeur |
|-----------|--------|
| **ID** | M-G-01 |
| **Nom** | Progression Gates |
| **Description** | Pour chaque composant, son Gate actuel et le prochain |
| **Format** | Tableau composant × Gate |
| **Fréquence** | À chaque décision de Gate |

### 8.2 Temps de Passage par Gate

| Propriété | Valeur |
|-----------|--------|
| **ID** | M-G-02 |
| **Nom** | Temps par Gate |
| **Description** | Durée entre l'ouverture et la décision du Gate |
| **Cible** | < durée max définie dans SUPRA_GATE_EXECUTION.md |
| **Fréquence** | Par Gate |

### 8.3 Taux de Réussite par Gate

| Propriété | Valeur |
|-----------|--------|
| **ID** | M-G-03 |
| **Nom** | Taux de réussite |
| **Description** | % de GO vs total par Gate |
| **Cible** | G1: > 50%, G2: > 70%, G3: > 80%, G4: > 70%, G5: > 90% |
| **Fréquence** | Mensuelle |

### 8.4 Goulots d'Étranglement

| Propriété | Valeur |
|-----------|--------|
| **ID** | M-G-04 |
| **Nom** | Goulots d'étranglement |
| **Description** | Gates où le temps de passage ou le taux d'échec est anormal |
| **Détection** | Temps > 2× durée max ou taux échec > 2× cible |
| **Fréquence** | Mensuelle |

---

## 9. Format du Rapport de Dashboard

### 9.1 Structure JSON

```json
{
  "dashboard": {
    "date": "2026-07-29",
    "period": "WEEKLY",
    "generated_by": "SUPRA-Architect",
    "health_score": 8.5,
    "indicators": {
      "compliance": {
        "overall_rate": 98.5,
        "violations": {"critical": 0, "high": 1, "medium": 2, "low": 5},
        "detection_time": 0.5,
        "resolution_time": 1.2
      },
      "coverage": {
        "controls": 95.0,
        "audits": 100.0,
        "adr": 100.0,
        "documentation": 92.0
      },
      "maturity": {
        "components": {
          "IDEA": 0,
          "FOUNDATION": 0,
          "CONSTITUTION": 0,
          "GOVERNANCE": 0,
          "ULTIMATE": 0,
          "PRODUCTION": 3
        },
        "governance": 100.0
      },
      "debt": {
        "compliance": 3,
        "documentation": 1,
        "technical": 2
      },
      "risks": {
        "active": {"critical": 0, "high": 1, "medium": 2, "low": 3},
        "blockers": 0,
        "exceptions": 3
      },
      "gates": {
        "by_component": [],
        "avg_time": {"G1": 0, "G2": 0, "G3": 0, "G4": 0, "G5": 0},
        "success_rate": {"G1": 0, "G2": 0, "G3": 0, "G4": 0, "G5": 0},
        "bottlenecks": []
      }
    },
    "alerts": [
      {
        "id": "ALT-001",
        "type": "WARNING",
        "indicator": "M-D-01",
        "message": "3 actions correctives en cours",
        "threshold": 5
      }
    ]
  }
}
```

### 9.2 Format Rapport Markdown

```markdown
# Rapport de Gouvernance — [Date]

## Vue d'Ensemble
- **Santé du système** : [Score]/10
- **Conformité** : [XX]%
- **Blocages** : [N]

## Indicateurs Clés
| Indicateur | Valeur | Cible | Statut |
|------------|--------|-------|--------|
| Conformité | XX% | > 95% | ✅/⚠️/❌ |
| Couverture contrôles | XX% | 100% | ✅/⚠️/❌ |
| Dette conformité | N | < 5 | ✅/⚠️/❌ |
| Blocages | N | 0 | ✅/⚠️/❌ |
| Exceptions actives | N | < 3 | ✅/⚠️/❌ |

## Progression des Composants
| Composant | Phase | Gate Suivant | Statut |
|-----------|-------|-------------|--------|
| SUPRA ZERO | PRODUCTION | - | ✅ |
| SUPRA FOUNDATION | PRODUCTION | - | ✅ |
| SUPRA CONSTITUTION | PRODUCTION | - | ✅ |

## Alertes
| Alerte | Type | Message |
|--------|------|---------|
| ALT-001 | ⚠️ | [Message] |

## Actions Recommandées
1. [Action 1]
2. [Action 2]
```

---

## 10. Fréquence et Responsabilités

| Rapport | Fréquence | Responsable | Destinataire |
|---------|-----------|-------------|--------------|
| Dashboard complet | Hebdomadaire | Architect | Executive |
| Rapport de conformité | Hebdomadaire | Auditor | Architect |
| État des Gates | À chaque Gate | Architect | Tous |
| Rapport de maturité | Mensuel | Architect | Executive |
| Rapport de risques | Mensuel | Auditor | Executive |
| Santé du système | Hebdomadaire | Architect | Executive |
| Rapport d'audit | Mensuel | Auditor | Executive |

---

## 11. Sources des Données

| Indicateur | Source de Données |
|------------|-------------------|
| Conformité | SUPRA_COMPLIANCE_MODEL.md, GOVERNANCE_REGISTRY.json (compliance) |
| Couverture | SUPRA_GOVERNANCE_REGISTRY.md, ADR_REGISTRY.json |
| Maturité | SUPRA_MASTER_MANIFEST.json, SUPRA_GOVERNANCE_REGISTRY.md (gates) |
| Dette | GOVERNANCE_REGISTRY.json (corrective_actions) |
| Risques | RISK_MATRIX.md, GOVERNANCE_REGISTRY.json (exceptions) |
| Blocages | MISSION_QUEUE.md, EXECUTION_BACKLOG.md |
| Santé | Tous les indicateurs ci-dessus |
| Gates | SUPRA_GATE_EXECUTION.md, GOVERNANCE_REGISTRY.json (gates) |

---

## 12. Évolution du Dashboard

Ce document est une spécification. L'implémentation du dashboard (outil, interface, automatisation) sera définie dans une mission ultérieure après validation de ce modèle par l'Executive.

**Prochaines étapes possibles** :
1. Script de génération automatique du rapport JSON
2. Intégration dans un rapport Markdown
3. Visualisation dans SUPRA Executive Shell
4. Alertes automatiques sur seuils

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA GOVERNANCE OPERATING MODEL V1. Aucune implémentation graphique — spécification uniquement.*
