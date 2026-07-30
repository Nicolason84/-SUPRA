# SUPRA AUTHORITY MODEL V1

## Modèle d'Autorité — Qui Décide, Qui Valide, Qui Fait Autorité

| Propriété | Valeur |
|-----------|--------|
| **Statut** | CONSTITUTION |
| **Version** | SUPRA_AUTHORITY_MODEL_V1 |
| **Date** | 2026-07-29 |
| **Principe** | Toute décision a un propriétaire. Toute autorité a des limites. |

---

## 1. Hiérarchie des Autorités

```
NIVEAU 0 : CONSTITUTION
    Autorité suprême. Définit les règles immuables.
    Décideur : Executive (utilisateur)
    │
    ▼
NIVEAU 1 : ARCHITECTURE
    Définit la structure, les contrats, les standards.
    Décideur : SUPRA-Architect
    Validateur : Executive
    │
    ▼
NIVEAU 2 : ROUTAGE
    Assigne les missions aux agents et modèles.
    Décideur : SUPRA-Router
    Validateur : SUPRA-Architect
    │
    ▼
NIVEAU 3 : EXÉCUTION
    Implémente, audite, explore, recherche.
    Exécutant : SUPRA-Builder
    Auditeurs : SUPRA-Auditor, SUPRA-Reviewer
    │
    ▼
NIVEAU 4 : RUNTIME
    Analyse le comportement, diagnostique, valide.
    Exécutant : SUPRA-Runtime
    Validateur : SUPRA-Architect
```

---

## 2. Matrice des Responsabilités (RACI)

| Domaine | Responsable (R) | Approbateur (A) | Consulté (C) | Informé (I) |
|---------|-----------------|-----------------|--------------|-------------|
| **Constitution** | Architect | Executive | Builder, Auditor | Tous |
| **Architecture** | Architect | Executive | Builder, Auditor, Refactor | Tous |
| **ADR** | Architect | Executive | Builder, Auditor | Router |
| **Manifest** | Builder | Architect | Auditor | Tous |
| **Registry** | Builder | Architect | Auditor | Tous |
| **Implémentation** | Builder | Architect | Refactor, Reviewer | Tous |
| **Tests** | Builder | Runtime | Reviewer | Architect |
| **Audit** | Auditor | Executive | Architect | Tous |
| **Review** | Reviewer | Architect | Builder | Tous |
| **Refactoring** | Refactor | Architect | Builder, Reviewer | Tous |
| **Recherche** | Research | Router | Architect | Tous |
| **Exploration** | Explorer | Router | Architect | Tous |
| **Runtime** | Runtime | Executive | Builder, Architect | Tous |
| **Routage** | Router | Architect | Research, Explorer | Tous |
| **Gouvernance** | Architect | Executive | Auditor | Tous |
| **Roadmap** | Architect | Executive | Builder, Research | Tous |
| **Plugins** | Builder | Architect | Research | Tous |
| **Theory** | Research | Architect | Router | Tous |
| **Sécurité** | Architect | Executive | Auditor, Runtime | Tous |
| **Documentation** | Builder | Architect | Explorer | Tous |
| **Métriques** | Runtime | Architect | Builder | Tous |

---

## 3. Matrice de Décision

| Type de Décision | Propose | Valide | Veto | Tranche |
|------------------|---------|--------|------|---------|
| Amendement constitutionnel | Architect | Executive | Auditor | Executive |
| Décision architecturale (ADR) | Architect | Executive | Auditor | Executive |
| Changement de contrat | Architect | Executive | Builder | Executive |
| Nouvel agent | Architect | Executive | Router | Executive |
| Nouveau plugin | Builder | Architect | Router | Executive |
| Nouvelle capacité | Architect | Executive | Auditor | Executive |
| Modification runtime | Builder | Runtime | Architect | Executive |
| Dépréciation composant | Architect | Executive | Auditor | Executive |
| Suppression définitive | Architect | Executive | Auditor + Builder | Executive |
| Rollback | Builder | Runtime | Architect | Executive |
| Décision de routage | Router | Architect | - | Architect |
| Choix de modèle | Router | Research | Architect | Architect |
| Classification mission | Router | Architect | - | Architect |
| Priorisation | Router | Executive | - | Executive |
| Freeze | Architect | Executive | Auditor | Executive |
| Release | Builder | Architect + Auditor | Executive | Executive |

---

## 4. Règles d'Autorité

### Règle A-01 : Principe de Cercle

Toute décision peut être contestée en remontant au cercle supérieur d'autorité. L'Executive est le cercle ultime.

### Règle A-02 : Principe de Délégation

Une autorité peut déléguer sa décision à un niveau inférieur, mais reste responsable de la décision.

### Règle A-03 : Principe de Non-Contournement

Aucune décision ne peut contourner un niveau d'autorité. Toute décision doit respecter la hiérarchie.

### Règle A-04 : Principe d'Enregistrement

Toute décision doit être enregistrée (ADR, commit, ou décision tracée). Une décision non enregistrée n'existe pas.

### Règle A-05 : Principe de Limite

Chaque autorité a un périmètre défini. Toute décision hors périmètre doit être remontée au niveau supérieur.

---

## 5. Autorités par Domaine

### 5.1 Autorité Constitutionnelle

| Élément | Autorité |
|---------|----------|
| Constitution | Executive |
| Principes immuables | Executive |
| Hiérarchie documentaire | Architect |
| Modèle d'autorité | Executive |

### 5.2 Autorité Architecturale

| Élément | Autorité |
|---------|----------|
| Architecture canonique | Architect |
| ADR | Architect (propose) / Executive (valide) |
| Standards | Architect |
| Contrats | Architect |
| Registres | Architect |

### 5.3 Autorité d'Implémentation

| Élément | Autorité |
|---------|----------|
| Code Swift | Builder |
| Tests | Builder |
| Configuration | Builder |
| Build | Builder |

### 5.4 Autorité de Validation

| Élément | Autorité |
|---------|----------|
| Conformité | Auditor |
| Qualité code | Reviewer |
| Comportement runtime | Runtime |
| Documentation | Explorer |

### 5.5 Autorité de Routage

| Élément | Autorité |
|---------|----------|
| Affectation agent | Router |
| Sélection modèle | Router |
| Priorisation | Router |
| Répartition charge | Router |

---

## 6. Règles de Conflit

### 6.1 Conflit entre Agents de Même Niveau

En cas de désaccord entre deux agents de même niveau (ex: Auditor vs Builder) :
1. Tentative de résolution directe
2. Escalade au niveau supérieur (Architect)
3. Si toujours pas résolu : Executive

### 6.2 Conflit entre Niveaux

En cas de désaccord entre niveaux différents, le niveau supérieur prévaut.

### 6.3 Conflit Constitutionnel

En cas de conflit impliquant la Constitution, seul l'Executive peut trancher.

---

## 7. Schéma d'Escalade

```
Agent A ←→ Agent B (désaccord)
        │
        ▼
    SUPRA-Architect (arbitrage technique)
        │
    ┌───┴───┐
    │       │
  Résolu  Non résolu
    │       │
    │       ▼
    │  Executive (décision finale)
    │       │
    └───────┘
        │
    DÉCISION ENREGISTRÉE (ADR si applicable)
```

---

## 8. Limites des Autorités

| Autorité | Ne Peut Pas |
|----------|-------------|
| Executive | Modifier la Constitution sans amendement |
| Architect | Implémenter du code (réservé Builder) |
| Builder | Prendre des décisions architecturales seules |
| Auditor | Modifier des fichiers (READ ONLY) |
| Router | Contourner la Single Writer Rule |
| Runtime | Modifier l'architecture |
| Reviewer | Refuser une implémentation (peut seulement recommander) |
| Refactor | Altérer le comportement fonctionnel |
| Research | Prendre des décisions exécutoires |
| Explorer | Modifier des fichiers (READ ONLY) |

---

## 9. Délégations Temporaires

Une délégation temporaire d'autorité peut être accordée par l'Executive pour :
- Une mission spécifique (périmètre défini)
- Une durée limitée (date d'expiration)
- Un agent spécifiquement habilité

Toute délégation doit être :
- Documentée dans la mission
- Traçable dans git
- Réversible à tout moment

---

## 10. Registre des Décisions d'Autorité

| ID | Date | Décision | Auteur | Statut |
|----|------|----------|--------|--------|
| AUT-001 | 2026-07-29 | Création du modèle d'autorité constitutionnel | Architect | ACTIF |
| AUT-002 | 2026-07-29 | Executive = décideur suprême | Architect | ACTIF |
| AUT-003 | 2026-07-29 | Single Writer = Builder | Architect | ACTIF |
| AUT-004 | 2026-07-29 | Architect = autorité architecturale | Executive | ACTIF |

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA CONSTITUTION V1.*
