# SUPRA WORKSPACE LIFECYCLE

**Version**: 1.0  
**Status**: STABLE  
**Category**: Workspace Governance  
**Path**: `SUPRA_WORKSPACE_LIFECYCLE.md`

---

## Lifecycle States

```
                       +-------+
                       |  NEW  |
                       +---+---+
                           |
                           v
                       +--------+
          +------------| ACTIVE |------------+
          |            +--------+            |
          v                                   v
    +--------+                          +--------+
    | STABLE |                          | LEGACY |
    +--------+                          +--------+
          |                                   |
          v                                   v
     +----------+                      +----------+
     | ARCHIVED |                      |  FROZEN  |
     +----------+                      +----------+
```

### State Definitions

| State | Tag | Description | Visibility | Mutability |
|-------|-----|-------------|------------|------------|
| **NEW** | `[NEW]` | Créé mais non activé | Privé | Read-Write |
| **ACTIVE** | `[ACTIVE]` | En usage quotidien | Public | Read-Write |
| **STABLE** | `[STABLE]` | Validé, non modifié | Public | Read-Only |
| **ARCHIVED** | `[ARCHIVED]` | Historique, conservé | Archive | Read-Only |
| **FROZEN** | `[FROZEN]` | Figé, point de référence | Archive | Immutable |
| **LEGACY** | `[LEGACY]` | Obsolète, conservé pour référence | Archive | Read-Only |
| **TRANSIENT** | `[TEMP]` | Temporaire, durée de vie limitée | Privé | Auto-delete |

---

## Transition Rules

### NEW → ACTIVE

**Conditions**:
- Mission approuvée par Executive
- Structure validée par Architect
- Entrée enregistrée dans Workspace Index

**Actions**:
- Tag `ACTIVE` ajouté
- Dossier déplacé vers Active Workspace (ou link créé)
- Responsable assigné

### ACTIVE → STABLE

**Conditions**:
- Travail terminé et vérifié
- Documentation complète
- Aucune modification active depuis 7 jours
- Revue par Reviewer effectuée

**Actions**:
- Tag `STABLE` ajouté
- Tag `ACTIVE` retiré
- Permissions passées en Read-Only
- Certification enregistrée

### STABLE → ARCHIVED

**Conditions**:
- Aucun accès depuis 30 jours
- Contenu consolidé dans le Core
- Backup vérifié

**Actions**:
- Tag `ARCHIVED` ajouté
- Compression possible (zip)
- Déplacement vers zone Archives
- Index mis à jour

### ARCHIVED → FROZEN

**Conditions**:
- Décision Executive de freeze
- Hash d'intégrité enregistré
- Point de non-retour validé

**Actions**:
- Tag `FROZEN` ajouté
- Signature checksum enregistrée
- Immutabilité garantie
- Référence dans Freeze Registry

### FROZEN → LEGACY

**Conditions**:
- Obsolescence confirmée
- Remplacement validé
- Aucun accès depuis 90 jours

**Actions**:
- Tag `LEGACY` ajouté
- Déplacement vers zone Legacy
- Notification aux dépendances

### ACTIVE → LEGACY (direct)

**Conditions** exceptionnelles:
- Abandon immédiat décidé par Executive
- Remplacement urgent

### TRANSIENT → auto-delete

**Conditions**:
- Durée de vie configurée à la création
- Expiration atteinte

**Actions**:
- Notification 7 jours avant suppression
- Backup automatique si nécessaire
- Purge sécurisée

---

## Reverse Transitions

| Reverse | Conditions | Approbation |
|---------|------------|-------------|
| ARCHIVED → STABLE | Restauration décidée par mission | Executive + Architect |
| FROZEN → ARCHIVED | Unfreeze exceptionnel | Executive seulement |
| LEGACY → ARCHIVED | Réactivation partielle | Executive + Reviewer |
| STABLE → ACTIVE | Reprise de maintenance | Mission approuvée |

---

## Lifecycle Defaults by Category

| Category | Default State | Auto-Transition | Retention |
|----------|---------------|-----------------|-----------|
| Active Workspace | ACTIVE | STABLE après 7j inactif | Illimitée |
| Products | ACTIVE | STABLE après release | Illimitée |
| Runtime | ACTIVE | TRANSIENT (purge 30j logs) | 30-90 jours |
| Development | ACTIVE | ARCHIVED après merge | Jusqu'à release |
| Documentation | STABLE | ARCHIVED après 90j sans mise à jour | Illimitée |
| Archives | ARCHIVED | FROZEN après validation | Illimitée |
| Snapshots | FROZEN | LEGACY après 90j | Illimitée |
| Temporary | TRANSIENT | Auto-delete après 7j | 7 jours |
| Sandbox | TRANSIENT | ARCHIVED si pertinent | 30 jours max |
| External Imports | LEGACY | N/A | Illimitée |

---

## Lifecycle Enforcement

1. **Tags**: chaque dossier doit porter son tag d'état dans son nom ou un fichier `.lifecycle`
2. **Audit**: vérification automatique de l'état de chaque dossier tous les 7 jours
3. **Alertes**: notification avant toute transition automatique
4. **Rollback**: toute transition peut être annulée dans les 24h
5. **Trace**: chaque transition est enregistrée dans le Lifecycle Log
