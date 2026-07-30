# SUPRA ADR GOVERNANCE V1

## Gouvernance du Cycle de Vie des Architecture Decision Records

| Propriété | Valeur |
|-----------|--------|
| **Statut** | GOVERNANCE — Processus ADR activé |
| **Version** | SUPRA_ADR_GOVERNANCE_V1 |
| **Date** | 2026-07-29 |
| **Principe** | Toute décision architecturale est documentée, tracée, gouvernée |
| **Base** | SUPRA_ADR_STANDARD.md (Constitution) — rendu opérationnel |

---

## 1. Cycle de Vie d'une ADR — Version Opérationnelle

```
PROPOSED
   │
   ▼
┌─────────────────────────────────────┐
│           REVIEW                    │
│  Analyse, consultation, évaluation  │
└─────────────────────────────────────┘
   │                    │
   ▼                    ▼
┌──────────────┐  ┌──────────────┐
│  ACCEPTED    │  │  REJECTED    │
│  Approuvée   │  │  Refusée     │
└──────────────┘  └──────────────┘
   │
   ▼
┌─────────────────────────────────────┐
│         IMPLEMENTED                 │
│  Décision appliquée dans le code   │
└─────────────────────────────────────┘
   │
   ▼
┌─────────────────────────────────────┐
│  ACTIVE / SUPERSEDED / DEPRECATED   │
│  Selon l'évolution                  │
└─────────────────────────────────────┘
   │
   ▼
┌─────────────────────────────────────┐
│           ARCHIVED                  │
│  Conservation permanente            │
└─────────────────────────────────────┘
```

---

## 2. Définition des Statuts

### 2.1 PROPOSED

| Propriété | Valeur |
|-----------|--------|
| **Description** | ADR soumise pour revue |
| **Auteur** | Tout agent autorisé |
| **Validateur** | SUPRA-Architect |
| **Durée max** | 1 session |
| **Action** | Soumission via fichier ADR-NNN.md dans ADR/ |

**Critères d'entrée** :
- Conforme au standard (SUPRA_ADR_STANDARD.md)
- Contexte clairement défini
- Décision explicitement énoncée

**Action de transition** :
```
PROPOSED → REVIEW : Soumission par l'auteur + notification Architect
```

### 2.2 REVIEW

| Propriété | Valeur |
|-----------|--------|
| **Description** | ADR en cours de revue |
| **Responsable** | SUPRA-Architect |
| **Participants** | Auteur, Auditor (conformité), parties prenantes |
| **Durée max** | 2 sessions |

**Actions de la revue** :
1. Analyse de la décision proposée
2. Vérification de conformité (Auditor)
3. Consultation des parties impactées
4. Évaluation des alternatives
5. Décision

**Transitions** :
```
REVIEW → ACCEPTED : Approuvée par Architect
REVIEW → REJECTED : Refusée (avec justification)
```

### 2.3 ACCEPTED

| Propriété | Valeur |
|-----------|--------|
| **Description** | ADR approuvée, décision active |
| **Validateur** | SUPRA-Architect (STANDARD/COMPONENT) ou + Executive (CONSTITUTION/ARCHITECTURE) |
| **Action** | Enregistrement dans ADR_REGISTRY.json |

**Livrables** :
- ADR_REGISTRY.json mis à jour (statut → ACCEPTED)
- Manifest mis à jour si impact composant
- Communication aux parties informées

**Transitions** :
```
ACCEPTED → IMPLEMENTED : Décision appliquée
ACCEPTED → DEPRECATED : Décision de dépréciation
ACCEPTED → SUPERSEDED : Nouvelle ADR qui remplace
```

### 2.4 REJECTED

| Propriété | Valeur |
|-----------|--------|
| **Description** | ADR refusée |
| **Action** | Conservation avec justification du refus |
| **Réouverture** | Possible si nouvelles preuves |

**Règles** :
- Une ADR REJECTED peut être resoumise après 1 session
- La resoumission doit inclure les réponses aux objections
- Au-delà de 2 refus, l'Executive doit être consulté

### 2.5 IMPLEMENTED

| Propriété | Valeur |
|-----------|--------|
| **Description** | Décision appliquée dans le code ou la documentation |
| **Responsable** | SUPRA-Builder |
| **Vérification** | SUPRA-Architect |

**Livrables** :
- Code ou documentation modifiés
- Preuve d'implémentation (commit, PR)
- ADR mise à jour (statut → IMPLEMENTED)

**Transition** :
```
IMPLEMENTED → ACTIVE : Implémentation vérifiée
```

### 2.6 ACTIVE

| Propriété | Valeur |
|-----------|--------|
| **Description** | ADR implémentée et active |
| **Durée** | Jusqu'à dépréciation ou remplacement |
| **Surveillance** | Auditor (vérification continue) |

### 2.7 SUPERSEDED

| Propriété | Valeur |
|-----------|--------|
| **Description** | ADR remplacée par une nouvelle ADR |
| **Lien** | Référence à l'ADR remplaçante |
| **Action** | Mise à jour du registre |

### 2.8 DEPRECATED

| Propriété | Valeur |
|-----------|--------|
| **Description** | ADR plus valide mais conservée |
| **Action** | Marquée DEPRECATED dans le registre |
| **Migration** | Si applicable, référence vers la nouvelle ADR |

### 2.9 ARCHIVED

| Propriété | Valeur |
|-----------|--------|
| **Description** | ADR conservée pour historique |
| **Action** | Déplacement dans ADR/ARCHIVE/ |
| **Suppression** | Jamais — les ADR ne sont jamais supprimées |

---

## 3. Responsabilités

### 3.1 Par Rôle

| Rôle | Responsabilité ADR |
|------|-------------------|
| **Proposeur** | Rédiger l'ADR, soumettre pour revue, répondre aux objections |
| **SUPRA-Architect** | Valider la conformité au standard, évaluer l'impact architectural, décider ACCEPTED/REJECTED |
| **SUPRA-Auditor** | Vérifier la conformité constitutionnelle, auditer les conséquences |
| **SUPRA-Builder** | Implémenter la décision, mettre à jour les registres |
| **SUPRA-Router** | Routage vers les bons validateurs si nécessaire |
| **Executive** | Décider pour les ADR de niveau CONSTITUTION et ARCHITECTURE |

### 3.2 Matrice RACI des ADR

| Activité | Proposeur | Architect | Auditor | Builder | Executive |
|----------|-----------|-----------|---------|---------|-----------|
| Rédaction | R | C | - | - | - |
| Soumission | R | A | - | - | - |
| Revue | C | R | C | - | I |
| Validation architecture | - | R | C | - | A |
| Validation conformité | - | I | R | - | - |
| Décision (STANDARD) | - | A/R | C | I | - |
| Décision (ARCHITECTURE) | - | R | C | I | A |
| Décision (CONSTITUTION) | - | R | C | I | A/R |
| Implémentation | - | I | - | R | - |
| Vérification | - | A | C | - | - |
| Archivage | - | A | - | R | - |

---

## 4. Validations

### 4.1 Checklist de Validation Obligatoire

Avant qu'une ADR ne soit ACCEPTED :

| # | Critère | RESPONSABLE |
|---|---------|-------------|
| 1 | Structure conforme au standard SUPRA_ADR_STANDARD.md | Architect |
| 2 | Contexte clairement défini | Architect |
| 3 | Décision explicitement énoncée | Architect |
| 4 | Justification basée sur des preuves | Architect |
| 5 | Conséquences documentées (positives, négatives, neutres) | Architect |
| 6 | Alternatives considérées (au moins 2) | Architect |
| 7 | Compliance vérifiée avec la Constitution | Auditor |
| 8 | Compliance vérifiée avec les Principes Immuables | Auditor |
| 9 | Compliance vérifiée avec l'Executive Canon | Architect |
| 10 | Tags attribués et valides | Architect |
| 11 | Numéro unique et séquentiel | Builder |
| 12 | Niveau d'ADR correct (CONSTITUTION/ARCHITECTURE/STANDARD/COMPONENT) | Architect |
| 13 | Validée par les validateurs requis | Architect |
| 14 | Aucune contradiction avec les ADR existantes | Auditor |

### 4.2 Validation par Niveau

| Niveau ADR | Validateur Requis | Délai Max |
|------------|-------------------|-----------|
| **CONSTITUTION** | Executive + Architect | 3 sessions |
| **ARCHITECTURE** | Executive + Architect | 2 sessions |
| **STANDARD** | Architect | 1 session |
| **COMPONENT** | Architect + Builder | 1 session |

---

## 5. Archivage

### 5.1 Règles d'Archivage

| Critère | Valeur |
|---------|--------|
| **Quand** | ADR passée en SUPERSEDED ou DEPRECATED depuis > 3 mois |
| **Où** | ADR/ARCHIVE/ADR-NNN-Titre.md |
| **Par** | Builder (sur instruction Architect) |
| **Registre** | Statut → ARCHIVED dans ADR_REGISTRY.json |

### 5.2 Structure de l'Archive

```
ADR/
├── ADR-001-Adoption-de-la-Single-Writer-Rule.md
├── ADR-002-Architecture-en-couches-L0-L6.md
├── ADR-003-Cycle-de-vie-IDEA-PRODUCTION-obligatoire.md
├── ADR-004-Standard-ADR-obligatoire.md
├── ...
└── ARCHIVE/
    ├── ADR-00X-Ancienne-decision.md
    └── ...
```

### 5.3 Conservation

- Les ADR ne sont jamais supprimées
- Les ADR archivées restent lisibles
- Le registre ADR conserve la référence vers l'archive

---

## 6. Liens avec le Manifest et le Registry

### 6.1 ADR_REGISTRY.json

Source de vérité pour toutes les ADR. Structure :

```json
{
  "adr_registry": {
    "format_version": "SUPRA_ADR_STANDARD_V1",
    "last_updated": "2026-07-29",
    "entries": [
      {
        "id": "ADR-001",
        "title": "Adoption de la Single Writer Rule",
        "status": "ACCEPTED",
        "level": "CONSTITUTION",
        "date": "2026-07-29",
        "author": "SUPRA-Architect",
        "file": "ADR-001-Adoption-de-la-Single-Writer-Rule.md",
        "tags": ["governance", "agents"],
        "supersedes": [],
        "superseded_by": null,
        "impacts": ["AGENTS.md", "opencode.json"],
        "validator": "Executive",
        "validation_date": "2026-07-29"
      }
    ]
  }
}
```

### 6.2 SUPRA_MASTER_MANIFEST.json

Les ADR acceptées qui impactent des composants majeurs sont référencées :

```json
{
  "adrs": [
    {
      "id": "ADR-001",
      "status": "ACCEPTED",
      "impacts": ["agents", "governance"]
    }
  ]
}
```

### 6.3 SUPRA_MASTER_REGISTRY.json

Le registre ADR est référencé comme source canonique :

```json
{
  "adr": {
    "canonical_source": "ADR_REGISTRY.json",
    "status": "CANONICAL",
    "maintained_by": "SUPRA-Builder",
    "validated_by": "SUPRA-Architect"
  }
}
```

### 6.4 GOVERNANCE_REGISTRY.json

Le registre de gouvernance référence les ADR pour la traçabilité des décisions :

```json
{
  "decisions": [
    {
      "adr_id": "ADR-001",
      "decision": "Single Writer Rule",
      "status": "IMPLEMENTED",
      "governance_ref": "GOV-001"
    }
  ]
}
```

---

## 7. Correspondance avec les Gates

| Événement ADR | Gate Associé | Action |
|---------------|-------------|--------|
| PROPOSED | G2 (si nouveau composant) | Vérification que le composant est en FOUNDATION |
| ACCEPTED | G3 | Validation que l'architecture est définie |
| IMPLEMENTED | G4 | Validation que l'implémentation est complète |
| ACTIVE | G5 | Validation que le composant est en PRODUCTION |

---

## 8. Métriques des ADR

| Métrique | Cible | Mesure |
|----------|-------|--------|
| Temps moyen PROPOSED → ACCEPTED | < 2 sessions | Date soumission → décision |
| Taux d'acceptation | > 70% | ACCEPTED / total |
| Taux de SUPERSEDED | < 20% | SUPERSEDED / ACCEPTED total |
| Nombre d'ADR actives | < 50 | ADR en statut ACTIVE |
| Couverture des décisions | 100% | Décisions tracées / décisions totales |
| Temps de revue | < 1 session | Date REVIEW → décision |

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA GOVERNANCE OPERATING MODEL V1. Active le cycle de vie des ADR défini dans SUPRA_ADR_STANDARD.md.*
