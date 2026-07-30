# SUPRA MISSION KERNEL V1

## Gestion des Missions — Cycle de Vie, États, Handover, Continuité, Preuves, Validation

| Propriété | Valeur |
|-----------|--------|
| **Statut** | CORE — Mission Kernel |
| **Version** | SUPRA_MISSION_KERNEL_V1 |
| **Date** | 2026-07-29 |
| **Autorité** | CORE — Toute mission passe par ce Kernel |
| **Préséance** | CORE > tout système de mission antérieur |

---

## 1. Définition d'une Mission

Une mission est une unité de travail atomique qui transforme un objectif en livrable validé.

Toute mission possède :
- Un identifiant unique
- Un objectif clairement énoncé
- Un propriétaire (Executive ou délégué)
- Un cycle de vie documenté
- Des preuves de complétion
- Un état traçable

---

## 2. Cycle de Vie d'une Mission

```
┌─────────────────────────────────────────────────────────────────────┐
│                      CYCLE DE VIE D'UNE MISSION                      │
│                                                                      │
│  RECEIVED ──▶ VALIDATED ──▶ PLANNED ──▶ EXECUTING ──▶ COMPLETED     │
│      │            │             │             │            │         │
│      ▼            ▼             ▼             ▼            ▼         │
│  Rejetée     Révisée      Re-planifiée  En échec     Archivée       │
│                                                                      │
│  Transitions possibles :                                             │
│  RECEIVED    → VALIDATED (si objectif valide)                       │
│  RECEIVED    → REJECTED (si objectif invalide)                      │
│  VALIDATED   → PLANNED (si plan disponible)                         │
│  VALIDATED   → REVISED (si objectif à clarifier)                    │
│  PLANNED     → EXECUTING (si ressources allouées)                   │
│  PLANNED     → RE-PLANIFIED (si plan à ajuster)                     │
│  EXECUTING   → COMPLETED (si livrable validé)                       │
│  EXECUTING   → FAILED (si échec irrécupérable)                      │
│  COMPLETED   → ARCHIVED (après validation finale)                   │
│  FAILED      → RE-PLANIFIED (si nouvelle tentative)                 │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 3. États d'une Mission

| État | Définition | Actions Autorisées |
|------|------------|-------------------|
| **RECEIVED** | Mission soumise, en attente de validation | Valider, Rejeter, Réviser |
| **VALIDATED** | Objectif validé, en attente de planification | Planifier, Réviser |
| **PLANNED** | Plan défini, en attente d'exécution | Exécuter, Re-planifier |
| **EXECUTING** | En cours d'exécution | Compléter, Échouer, Reporter |
| **COMPLETED** | Livrable produit, en attente de validation finale | Archiver, Rouvrir |
| **FAILED** | Échec constaté | Re-planifier, Archiver |
| **REJECTED** | Mission rejetée | Archiver (avec justification) |
| **REVISED** | Objectif à clarifier | Soumettre révision |
| **RE-PLANIFIED** | Plan modifié | Exécuter (nouveau plan) |
| **ARCHIVED** | Mission terminée, conservée pour historique | Lecture seule |

---

## 4. Structure d'une Mission

```json
{
  "mission_id": "SUPRA_CORE_V1",
  "title": "SUPRA ULTIMATE CORE V1",
  "status": "EXECUTING",
  "owner": "SUPRA-Builder",
  "objective": "Créer SUPRA CORE, le socle opérationnel unique",
  "phases": [
    {
      "id": "phase-1",
      "name": "MASTER INDEX",
      "status": "COMPLETED",
      "deliverable": "SUPRA_MASTER_INDEX.md"
    },
    {
      "id": "phase-2",
      "name": "MASTER GRAPH",
      "status": "COMPLETED",
      "deliverable": "SUPRA_MASTER_GRAPH.md"
    }
  ],
  "gates": {
    "G1": {"status": "PASS", "date": "2026-07-29"},
    "G2": {"status": "PASS", "date": "2026-07-29"}
  },
  "evidence": [
    "SUPRA_MASTER_INDEX.md",
    "SUPRA_MASTER_GRAPH.md"
  ],
  "dependencies": [],
  "created_at": "2026-07-29",
  "completed_at": null
}
```

---

## 5. Handover et Continuité

### 5.1 Règles de Handover

| Règle | Description |
|-------|-------------|
| H-01 | Toute mission doit pouvoir être reprise par un autre agent |
| H-02 | L'état de la mission est persistant et traçable |
| H-03 | Les preuves de chaque étape sont conservées |
| H-04 | Le contexte de la mission est documenté dans SESSION_SNAPSHOT |
| H-05 | En cas d'interruption, la mission peut être reprise à la dernière étape complétée |

### 5.2 Handover Procedure

```
1. DÉTECTION D'INTERRUPTION
   ── Raison documentée (fin de session, erreur, priorité)
   
2. SAUVEGARDE DE L'ÉTAT
   ── Mission mise à jour dans le registre
   ── SESSION_SNAPSHOT produit
   ── Preuves de l'étape courante conservées
   
3. NOTIFICATION
   ── Agent suivant notifié via HANDOFF.md
   ── Contexte de reprise fourni
   
4. REPRISE
   ── Agent suivant lit l'état de la mission
   ── Continue à partir de la dernière étape complétée
```

### 5.3 Continuité de Session

| Mécanisme | Description | Source |
|-----------|-------------|--------|
| Session Snapshot | État complet de la session en cours | SESSION_SNAPSHOT_*.json |
| Handoff Doc | Instructions pour l'agent suivant | HANDOFF.md |
| Mission Queue | File d'attente des missions | MISSION_QUEUE.md |
| Continuity Pack | Pack de continuité complet | SUPRA_CONTINUITY_PACK.md |
| Session Summary | Résumé de fin de session | SESSION_SUMMARY.md |

---

## 6. Preuves

### 6.1 Types de Preuve

| Type | Format | Exemple |
|------|--------|---------|
| Document | Markdown | SUPRA_EXECUTIVE_KERNEL.md |
| Rapport | Markdown | EXECUTION_REPORT.md |
| Métrique | JSON | runtime_metrics.json |
| Test | JSON | mission_center_metrics.json |
| Décision | ADR | ADR-001.md |
| Validation | Rapport | VALIDATION_REPORT.md |
| État | SNAPSHOT | SESSION_SNAPSHOT_*.json |
| Trace | JSON | execution_trace.json |

### 6.2 Règles de Preuve

| Règle | Description |
|-------|-------------|
| P-01 | Toute mission produit au moins une preuve par phase |
| P-02 | Les preuves sont stockées dans Evidence/ ou à la racine |
| P-03 | Les preuves ne sont jamais supprimées |
| P-04 | Chaque preuve est référencée dans le registre de mission |
| P-05 | Une mission sans preuve est considérée comme non-terminée |

---

## 7. Validation

### 7.1 Critères de Validation

| Critère | Question |
|---------|----------|
| Complétude | Tous les livrables sont-ils produits ? |
| Conformité | Les livrables respectent-ils les standards ? |
| Cohérence | Les livrables sont-ils cohérents entre eux ? |
| Traçabilité | Chaque décision est-elle traçable ? |
| Réversibilité | La mission est-elle réversible ? |
| Preuve | Chaque phase a-t-elle sa preuve ? |

### 7.2 Processus de Validation

```
1. AUTO-VALIDATION
   ── L'agent exécutant vérifie ses propres livrables
   
2. REVUE
   ── SUPRA-Reviewer examine la qualité et la complétude
   
3. AUDIT
   ── SUPRA-Auditor vérifie la conformité
   
4. APPROBATION
   ── SUPRA-Architect ou Executive approuve
   
5. CLÔTURE
   ── Mission marquée COMPLETED ou ARCHIVED
```

---

## 8. Pipeline d'Exécution

```
Mission → Executive → Architect → Router → Read Agents → Comparator → Fusion → Validator → Builder
    │         │           │         │           │            │         │          │         │
    ▼         ▼           ▼         ▼           ▼            ▼         ▼          ▼         ▼
Soumise   Approuvée   Structurée  Routée    Exécutée     Comparée   Fusionnée  Validée   Écrite
```

---

## 9. Gates de Mission

| Gate | Transition | Validateur |
|------|-----------|------------|
| G1 | RECEIVED → VALIDATED | Executive |
| G2 | VALIDATED → PLANNED | Architect |
| G3 | PLANNED → EXECUTING | Router |
| G4 | EXECUTING → COMPLETED | Reviewer + Auditor |
| G5 | COMPLETED → ARCHIVED | Executive |

---

## 10. Règles du Mission Kernel

| ID | Règle | Sanction |
|----|-------|----------|
| MK-01 | Toute mission a un état explicite | Mission sans état = INVALIDE |
| MK-02 | Toute mission a un propriétaire | Mission sans owner = REFUSÉE |
| MK-03 | Toute transition d'état est tracée | Transition non tracée = NULLE |
| MK-04 | Toute phase produit une preuve | Phase sans preuve = INCOMPLÈTE |
| MK-05 | Toute mission est réversible | Mission irréversible = BLOQUÉE |
| MK-06 | Toute mission peut être handoverée | Mission non handoverable = RISQUE |

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA ULTIMATE CORE V1. Kernel de gestion des missions.*
