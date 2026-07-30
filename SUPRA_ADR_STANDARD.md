# SUPRA ADR STANDARD V1

## Standard Officiel des Architecture Decision Records

| Propriété | Valeur |
|-----------|--------|
| **Statut** | CONSTITUTION — Standard obligatoire |
| **Version** | SUPRA_ADR_STANDARD_V1 |
| **Date** | 2026-07-29 |
| **Principe** | Toute décision architecturale importante doit être documentée par une ADR conforme |

---

## 1. Définition

Une Architecture Decision Record (ADR) est un document qui enregistre une décision architecturale importante, son contexte, ses conséquences, et sa justification.

---

## 2. Format

### 2.1 Nommage

```
ADR-NNN-Titre-court-du-sujet.md
```

Où :
- `NNN` : Numéro séquentiel à 3 chiffres (001, 002, ..., 999)
- `Titre-court-du-sujet` : Slug du sujet (kebab-case)

**Exemple** : `ADR-001-Adoption-de-la-Single-Writer-Rule.md`

### 2.2 Structure Obligatoire

Chaque ADR doit contenir les sections suivantes dans cet ordre :

```markdown
# ADR-NNN : Titre de la Décision

## Statut
[PROPOSED | ACCEPTED | DEPRECATED | SUPERSEDED]

## Date
YYYY-MM-DD

## Contexte
[Description du problème ou de l'opportunité qui motive cette décision]

## Décision
[Description de la décision prise]

## Justification
[Pourquoi cette décision a été prise]

## Conséquences
### Positives
- [Conséquence positive 1]
- [Conséquence positive 2]

### Négatives
- [Conséquence négative 1]
- [Conséquence négative 2]

### Neutres
- [Conséquence neutre 1]

## Alternatives Considérées
### Alternative 1 : [Titre]
- **Avantages** : [...]
- **Inconvénients** : [...]
- **Raison du rejet** : [...]

### Alternative 2 : [Titre]
- **Avantages** : [...]
- **Inconvénients** : [...]
- **Raison du rejet** : [...]

## Compliance
- [ ] Conforme à SUPRA_CONSTITUTION.md
- [ ] Conforme à SUPRA_IMMUTABLE_PRINCIPLES.md
- [ ] Conforme à SUPRA_EXECUTIVE_CANON.md
- [ ] ADR liée : [ADR-NNN]

## Décideur
[Nom de l'agent ou de la personne]

## Validateurs
- [Agent 1] : [APPROVED | REJECTED | PENDING]
- [Agent 2] : [APPROVED | REJECTED | PENDING]

## Références
- [Document ou source 1]
- [Document ou source 2]

## Notes
[Informations complémentaires, questions ouvertes, décisions futures]
```

### 2.3 Sections Optionnelles

Les sections suivantes peuvent être ajoutées si nécessaire :

```markdown
## Chronologie
- YYYY-MM-DD : Proposition initiale
- YYYY-MM-DD : Revue par Architect
- YYYY-MM-DD : Approuvée par Executive

## Preuves
[Lien vers prototype, test, benchmark]

## Migration
[Plan de migration si applicable]

## Rollback
[Procédure de rollback si applicable]
```

---

## 3. Numérotation

### 3.1 Règles

- Les numéros sont séquentiels et ne sont pas réutilisés
- Si une ADR est dépréciée, son numéro reste attribué
- Les numéros sont attribués par ordre de création

### 3.2 Registre ADR

Toutes les ADR sont enregistrées dans un registre central :

**Fichier** : `ADR_REGISTRY.json` (à la racine du workspace)

**Format** :

```json
{
  "adr_registry": {
    "format_version": "SUPRA_ADR_STANDARD_V1",
    "entries": [
      {
        "id": "ADR-001",
        "title": "Adoption de la Single Writer Rule",
        "status": "ACCEPTED",
        "date": "2026-07-29",
        "author": "SUPRA-Architect",
        "file": "ADR-001-Adoption-de-la-Single-Writer-Rule.md",
        "tags": ["governance", "agents"],
        "supersedes": [],
        "superseded_by": null
      }
    ]
  }
}
```

---

## 4. Cycle de Vie d'une ADR

```
PROPOSED → REVIEW → ACCEPTED → (ACTIVE)
                │                    │
                ▼                    ▼
            REJECTED            DEPRECATED
                                    │
                                    ▼
                              SUPERSEDED
                                    │
                                    ▼
                             (Archived)
```

| Statut | Description |
|--------|-------------|
| **PROPOSED** | ADR soumise pour revue |
| **REVIEW** | ADR en cours de revue |
| **ACCEPTED** | ADR approuvée et active |
| **REJECTED** | ADR refusée (avec justification) |
| **DEPRECATED** | ADR plus valide mais conservée |
| **SUPERSEDED** | ADR remplacée par une autre ADR |

### Transitions

| De | Vers | Condition |
|----|------|-----------|
| PROPOSED | REVIEW | Soumise par l'auteur |
| REVIEW | ACCEPTED | Approuvée par Architect + Executive |
| REVIEW | REJECTED | Refusée par Architect ou Executive |
| ACCEPTED | DEPRECATED | Décision de dépréciation |
| ACCEPTED | SUPERSEDED | Nouvelle ADR qui remplace |
| DEPRECATED | SUPERSEDED | Nouvelle ADR qui remplace |

---

## 5. Niveaux d'ADR

| Niveau | Description | Validateur |
|--------|-------------|------------|
| **CONSTITUTION** | Impacte la Constitution ou les Principes Immuables | Executive uniquement |
| **ARCHITECTURE** | Impacte l'architecture canonique ou les contrats majeurs | Executive + Architect |
| **STANDARD** | Impacte les standards, politiques ou conventions | Architect |
| **COMPONENT** | Impacte un composant spécifique | Architect + Builder |

---

## 6. Tags

Chaque ADR doit avoir au moins un tag parmi :

| Tag | Description |
|-----|-------------|
| `architecture` | Décision architecturale |
| `governance` | Décision de gouvernance |
| `security` | Décision de sécurité |
| `performance` | Décision de performance |
| `contract` | Décision de contrat |
| `agent` | Décision d'agent |
| `plugin` | Décision de plugin |
| `runtime` | Décision de runtime |
| `product` | Décision produit |
| `evolution` | Décision d'évolution |

---

## 7. Conventions de Rédaction

### 7.1 Langue
- Les ADR peuvent être rédigées en français ou en anglais
- Le titre et les tags doivent être dans la même langue
- La langue doit être cohérente dans une même ADR

### 7.2 Ton
- Neutre et factuel
- Justifications basées sur des preuves
- Pas de langage promotionnel ou subjectif

### 7.3 Longueur
- Maximum 2 pages (hors code)
- Si plus long, envisager de diviser en plusieurs ADR

---

## 8. Archivage

- Les ADR sont stockées dans le répertoire `ADR/` à la racine du workspace
- Les ADR ne sont jamais supprimées
- Les ADR dépréciées sont déplacées dans `ADR/ARCHIVE/`
- Le registre ADR (`ADR_REGISTRY.json`) est la source de vérité pour l'index

---

## 9. Liens avec Manifest et Registry

### 9.1 Manifest

Chaque ADR acceptée doit être référencée dans SUPRA_MASTER_MANIFEST.json si elle impacte un composant majeur :

```json
"adrs": [
  {
    "id": "ADR-001",
    "status": "ACCEPTED",
    "impacts": ["agents", "governance"]
  }
]
```

### 9.2 Registry

Le registre ADR (`ADR_REGISTRY.json`) est une catégorie du SUPRA_MASTER_REGISTRY.json :

```json
"adr": {
  "canonical_source": "ADR_REGISTRY.json",
  "status": "CANONICAL",
  "entries_count": 0
}
```

---

## 10. Gabarit (Template)

Un fichier template est disponible : `ADR/_TEMPLATE.md`

```markdown
# ADR-NNN : Titre de la Décision

## Statut
PROPOSED

## Date
YYYY-MM-DD

## Contexte


## Décision


## Justification


## Conséquences
### Positives


### Négatives


### Neutres


## Alternatives Considérées
### Alternative 1


### Alternative 2


## Compliance
- [ ] Conforme à SUPRA_CONSTITUTION.md
- [ ] Conforme à SUPRA_IMMUTABLE_PRINCIPLES.md
- [ ] Conforme à SUPRA_EXECUTIVE_CANON.md
- [ ] ADR liée : 

## Décideur

## Validateurs
- SUPRA-Architect : PENDING
- SUPRA-Auditor : PENDING

## Références

## Notes
```

---

## 11. Premières ADR

Les ADR suivantes sont créées automatiquement par cette mission :

| ID | Titre | Statut |
|----|-------|--------|
| ADR-001 | Adoption de la Single Writer Rule | ACCEPTED (historique) |
| ADR-002 | Architecture en couches L0-L6 | ACCEPTED (historique) |
| ADR-003 | Cycle de vie IDEA→PRODUCTION obligatoire | ACCEPTED |
| ADR-004 | Standard ADR obligatoire pour décisions architecturales | ACCEPTED |

---

## 12. Checklist de Validation

Avant qu'une ADR ne soit ACCEPTED :

- [ ] Structure conforme au standard
- [ ] Contexte clairement défini
- [ ] Décision explicitement énoncée
- [ ] Justification basée sur des preuves
- [ ] Conséquences documentées (positives et négatives)
- [ ] Alternatives considérées
- [ ] Compliance vérifiée avec la Constitution
- [ ] Tags attribués
- [ ] Numéro unique et séquentiel
- [ ] Validée par les validateurs requis

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA CONSTITUTION V1.*
