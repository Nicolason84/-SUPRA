# SUPRA GOVERNANCE REGISTRY V1

## Registre Officiel de Gouvernance — Décisions, Autorités, Policies, Standards, Gates, ADR

| Propriété | Valeur |
|-----------|--------|
| **Statut** | GOVERNANCE — Registre officiel |
| **Version** | SUPRA_GOVERNANCE_REGISTRY_V1 |
| **Date** | 2026-07-29 |
| **Principe** | Toute décision de gouvernance est enregistrée. Toute autorité est référencée. |
| **Source Canonique** | GOVERNANCE_REGISTRY.json (à créer) |

---

## 1. Structure du Registre de Gouvernance

Le registre de gouvernance est un fichier JSON (`GOVERNANCE_REGISTRY.json`) à la racine du workspace.

### 1.1 Format Global

```json
{
  "governance_registry": {
    "format_version": "SUPRA_GOVERNANCE_REGISTRY_V1",
    "last_updated": "2026-07-29",
    "maintained_by": "SUPRA-Builder",
    "validated_by": "SUPRA-Architect"
  }
}
```

### 1.2 Sections du Registre

| Section | Contenu | Source Canonique |
|---------|---------|-----------------|
| `decisions` | Décisions de gouvernance enregistrées | Ce fichier |
| `authorities` | Autorités et responsabilités | SUPRA_AUTHORITY_MODEL.md |
| `policies` | Politiques de gouvernance actives | Governance docs |
| `standards` | Standards en vigueur | SUPRA_FOUNDATION_RULES.md |
| `gates` | État et historique des Gates | SUPRA_GATE_EXECUTION.md |
| `adr` | ADR référencées | ADR_REGISTRY.json |
| `versions` | Versions des documents de gouvernance | Ce fichier |
| `exceptions` | Exceptions et dérogations actives | SUPRA_COMPLIANCE_MODEL.md |
| `compliance` | État de la conformité | SUPRA_COMPLIANCE_MODEL.md |
| `metrics` | Indicateurs de gouvernance | SUPRA_GOVERNANCE_DASHBOARD.md |

---

## 2. Décisions

### 2.1 Format d'une Décision

```json
{
  "decisions": [
    {
      "id": "GOV-DEC-001",
      "type": "GATE",
      "description": "Validation du Gate G1 pour Theory Engine",
      "authority": "Executive",
      "decision": "GO",
      "date": "2026-07-29",
      "component": "theory-engine",
      "evidence": ["note-intention-theory-engine.md"],
      "conditions": [],
      "status": "ACTIVE",
      "superseded_by": null
    }
  ]
}
```

### 2.2 Types de Décisions

| Type | Code | Description |
|------|------|-------------|
| Gate | GATE | Décision de Gate (GO/NO GO) |
| Architecture | ARCH | Décision architecturale |
| Conformité | COMP | Décision de conformité |
| Exception | EXC | Exception accordée |
| Dérogation | DER | Dérogation permanente |
| Nomination | NOM | Nomination d'autorité |
| Arbitrage | ARB | Arbitrage de conflit |
| Urgence | URG | Décision d'urgence |

### 2.3 Cycle d'une Décision

```
PROPOSED → APPROVED → ACTIVE → SUPERSEDED → ARCHIVED
               ↓
           REJECTED
```

---

## 3. Autorités

### 3.1 Format d'une Autorité

```json
{
  "authorities": [
    {
      "id": "AUT-001",
      "domain": "Architecture",
      "title": "Architecte en chef",
      "holder": "SUPRA-Architect",
      "level": "G4",
      "responsibilities": [
        "Valider les ADR",
        "Maintenir l'Executive Canon",
        "Décider les standards"
      ],
      "limitations": [
        "Ne peut pas implémenter du code (réservé Builder)",
        "Ne peut pas modifier la Constitution sans amendement"
      ],
      "delegates_to": ["SUPRA-Router"],
      "reports_to": "Executive",
      "status": "ACTIVE"
    }
  ]
}
```

### 3.2 Liste des Autorités

| ID | Domaine | Titulaire | Niveau | Statut |
|----|---------|-----------|--------|--------|
| AUT-001 | Constitution | Executive | G5 | ACTIVE |
| AUT-002 | Architecture | Architect | G4 | ACTIVE |
| AUT-003 | Conformité | Auditor | G2 | ACTIVE |
| AUT-004 | Routage | Router | G3 | ACTIVE |
| AUT-005 | Implémentation | Builder | G1 | ACTIVE |
| AUT-006 | Qualité | Reviewer | G2 | ACTIVE |
| AUT-007 | Runtime | Runtime | G2 | ACTIVE |
| AUT-008 | Recherche | Research | G2 | ACTIVE |
| AUT-009 | Exploration | Explorer | G2 | ACTIVE |
| AUT-010 | Gouvernance | Architect | G4 | ACTIVE |
| AUT-011 | Migration | Builder + Architect | G2 | ACTIVE |
| AUT-012 | Registre | Builder | G1 | ACTIVE |

---

## 4. Policies

### 4.1 Format d'une Politique

```json
{
  "policies": [
    {
      "id": "POL-001",
      "name": "Workflow Policy",
      "source": "SUPRA_WORKFLOW_V1.md",
      "status": "CANONIQUE",
      "authority": "SUPRA-Architect",
      "applies_to": ["all missions"],
      "last_reviewed": "2026-07-29"
    }
  ]
}
```

### 4.2 Politiques Actives

| ID | Politique | Source | Statut | Domaine |
|----|-----------|--------|--------|---------|
| POL-001 | Workflow | SUPRA_WORKFLOW_V1.md | CANONIQUE | Exécution |
| POL-002 | Routage | SUPRA_ROUTER_SPECIFICATION_V1.md | CANONIQUE | Agents |
| POL-003 | Validation | VALIDATION_PROTOCOL.md | CANONIQUE | Qualité |
| POL-004 | Desktop Governance | DESKTOP_GOVERNANCE.md | CANONIQUE | Workspace |
| POL-005 | Agent Registry | SUPRA_AGENT_REGISTRY_V1.md | CANONIQUE | Agents |
| POL-006 | Model Registry | SUPRA_MODEL_REGISTRY_V1.md | CANONIQUE | Modèles |
| POL-007 | Gouvernance | SUPRA_GOVERNANCE_MODEL.md | ACTIVE | Gouvernance |
| POL-008 | Gates | SUPRA_GATE_EXECUTION.md | ACTIVE | Cycle de vie |
| POL-009 | Conformité | SUPRA_COMPLIANCE_MODEL.md | ACTIVE | Conformité |
| POL-010 | ADR | SUPRA_ADR_GOVERNANCE.md | ACTIVE | Décisions |

---

## 5. Standards

### 5.1 Format d'un Standard

```json
{
  "standards": [
    {
      "id": "STD-001",
      "name": "ADR Standard",
      "source": "SUPRA_ADR_STANDARD.md",
      "status": "CONSTITUTION",
      "authority": "SUPRA-Architect",
      "version": "V1"
    }
  ]
}
```

### 5.2 Standards en Vigueur

| ID | Standard | Source | Statut | Version |
|----|----------|--------|--------|---------|
| STD-001 | ADR Standard | SUPRA_ADR_STANDARD.md | CONSTITUTION | V1 |
| STD-002 | Foundation Rules | SUPRA_FOUNDATION_RULES.md | CANONIQUE | V1 |
| STD-003 | Continuité | CAnnoNico_CONTINUITY_STANDARD.md | CANONIQUE | V1 |
| STD-004 | Développement | CAnnoNico_DEVELOPMENT_GUIDE.md | CANONIQUE | V1 |
| STD-005 | Workflow | CAnnoNico_WORKFLOW_STANDARD.md | CANONIQUE | V1 |
| STD-006 | Executive Object Model | EXECUTIVE_OBJECT_MODEL.md | CANONIQUE | V1 |
| STD-007 | Executive Runtime | EXECUTIVE_RUNTIME.md | CANONIQUE | V1 |

---

## 6. Gates

### 6.1 Format d'un Enregistrement de Gate

```json
{
  "gates": [
    {
      "gate_id": "G1",
      "component": "theory-engine",
      "phase": "IDEA → FOUNDATION",
      "decision": "GO",
      "validator": "Executive",
      "date": "2026-07-29",
      "conditions": [],
      "evidence_refs": ["docs/note-intention-theory-engine.md"],
      "rollback_plan": null,
      "status": "PASS"
    }
  ]
}
```

### 6.2 État Global des Gates

```json
{
  "gate_status": {
    "G1": {"total": 0, "pass": 0, "fail": 0, "pending": 0},
    "G2": {"total": 0, "pass": 0, "fail": 0, "pending": 0},
    "G3": {"total": 0, "pass": 0, "fail": 0, "pending": 0},
    "G4": {"total": 0, "pass": 0, "fail": 0, "pending": 0},
    "G5": {"total": 0, "pass": 0, "fail": 0, "pending": 0}
  }
}
```

---

## 7. ADR

### 7.1 Référencement des ADR

```json
{
  "adr": {
    "canonical_source": "ADR_REGISTRY.json",
    "entries_count": 4,
    "last_updated": "2026-07-29",
    "summary": {
      "PROPOSED": 0,
      "REVIEW": 0,
      "ACCEPTED": 4,
      "REJECTED": 0,
      "IMPLEMENTED": 0,
      "ACTIVE": 4,
      "DEPRECATED": 0,
      "SUPERSEDED": 0,
      "ARCHIVED": 0
    }
  }
}
```

---

## 8. Versions

### 8.1 Format d'une Version

```json
{
  "versions": [
    {
      "id": "SUPRA_GOVERNANCE_MODEL_V1",
      "document": "SUPRA_GOVERNANCE_MODEL.md",
      "status": "ACTIVE",
      "date": "2026-07-29",
      "author": "SUPRA-Architect",
      "supersedes": null,
      "changes": "Création — Modèle de gouvernance initial"
    }
  ]
}
```

### 8.2 Documents de Gouvernance — Versions

| Document | Version | Statut | Date |
|----------|---------|--------|------|
| SUPRA_GOVERNANCE_MODEL.md | V1 | ACTIVE | 2026-07-29 |
| SUPRA_GOVERNANCE_AGENTS.md | V1 | ACTIVE | 2026-07-29 |
| SUPRA_GOVERNANCE_WORKFLOWS.md | V1 | ACTIVE | 2026-07-29 |
| SUPRA_GATE_EXECUTION.md | V1 | ACTIVE | 2026-07-29 |
| SUPRA_COMPLIANCE_MODEL.md | V1 | ACTIVE | 2026-07-29 |
| SUPRA_ADR_GOVERNANCE.md | V1 | ACTIVE | 2026-07-29 |
| SUPRA_GOVERNANCE_REGISTRY.md | V1 | ACTIVE | 2026-07-29 |
| SUPRA_GOVERNANCE_DASHBOARD.md | V1 | ACTIVE | 2026-07-29 |
| SUPRA_ULTIMATE_READINESS.md | V1 | ACTIVE | 2026-07-29 |

---

## 9. Exceptions et Dérogations

### 9.1 Format d'une Exception

```json
{
  "exceptions": [
    {
      "id": "EXC-001",
      "rule": "C-07",
      "description": "Workspace sale autorisé pour consolidation Phase 2a",
      "granted_by": "Executive",
      "date": "2026-07-29",
      "expires": "2026-08-29",
      "status": "ACTIVE",
      "conditions": ["Uniquement pour missions de consolidation"],
      "superseded_by": null
    }
  ]
}
```

### 9.2 Exceptions Actives

| ID | Règle | Description | Expire | Statut |
|----|-------|-------------|--------|--------|
| EXC-001 | C-07 | Workspace sale toléré (TP-01) | Fin Phase 2a | ACTIVE |
| EXC-002 | C-06 | Tests en échec tolérés (TP-02) | 9/9 tests | ACTIVE |
| EXC-003 | C-12 | Documents DRAFT autorisés (TP-03) | Implémentation | ACTIVE |

### 9.3 Dérogations Actives

| ID | Règle | Description | ADR | Statut |
|----|-------|-------------|-----|--------|
| *(Aucune dérogation active)* | | | | |

---

## 10. Conformité

### 10.1 Format de l'État de Conformité

```json
{
  "compliance": {
    "last_check": "2026-07-29",
    "overall_rate": 98.5,
    "checks": {
      "total": 120,
      "conforme": 118,
      "non_conforme": 2,
      "alerte": 0
    },
    "violations": [
      {
        "id": "VIO-001",
        "rule": "C-07",
        "severity": "MEDIUM",
        "component": "workspace",
        "status": "EXCEPTION_ACTIVE",
        "detected_at": "2026-07-29"
      }
    ],
    "corrective_actions": [
      {
        "id": "ACT-001",
        "violation": "VIO-001",
        "action": "Nettoyage du workspace",
        "assigned_to": "Builder",
        "deadline": "2026-07-30",
        "status": "OPEN"
      }
    ]
  }
}
```

---

## 11. Création du Registre

Le registre de gouvernance (`GOVERNANCE_REGISTRY.json`) sera créé par SUPRA-Builder lors de l'activation de la gouvernance. Ce document constitue la spécification.

### 11.1 Procédure de Création

1. Builder crée `GOVERNANCE_REGISTRY.json` à la racine
2. Structure initiale vide (template ci-dessus)
3. Architect valide la structure
4. Les décisions et événements sont ajoutés au fil de l'eau

### 11.2 Maintenance

| Action | Fréquence | Responsable |
|--------|-----------|-------------|
| Ajout décision | À chaque décision | Builder |
| Mise à jour autorités | À chaque changement | Architect |
| Mise à jour policies | À chaque changement | Architect |
| Mise à jour gates | À chaque décision Gate | Builder |
| Synchronisation ADR | À chaque ADR | Builder |
| Mise à jour versions | À chaque nouveau document | Builder |
| Mise à jour exceptions | À chaque exception | Builder |
| Audit du registre | Hebdomadaire | Auditor |

---

## 12. Sources Canoniques par Domaine

| Domaine | Source Canonique | Format | Mainteneur |
|---------|-----------------|--------|------------|
| Décisions de gouvernance | GOVERNANCE_REGISTRY.json (decisions) | JSON | Builder |
| Autorités | SUPRA_AUTHORITY_MODEL.md | Markdown | Architect |
| Policies | Governance documents (Niveau 5) | Markdown | Architect |
| Standards | SUPRA_FOUNDATION_RULES.md | Markdown | Architect |
| Gates | SUPRA_GATE_EXECUTION.md | Markdown | Architect |
| Historique des Gates | GOVERNANCE_REGISTRY.json (gates) | JSON | Builder |
| ADR | ADR_REGISTRY.json | JSON | Builder |
| Versions | GOVERNANCE_REGISTRY.json (versions) | JSON | Builder |
| Exceptions | GOVERNANCE_REGISTRY.json (exceptions) | JSON | Architect |
| Conformité | GOVERNANCE_REGISTRY.json (compliance) | JSON | Auditor |
| Métriques | SUPRA_GOVERNANCE_DASHBOARD.md | Markdown | Architect |
| Manifest maître | SUPRA_MASTER_MANIFEST.json | JSON | Architect |
| Registre maître | SUPRA_MASTER_REGISTRY.json | JSON | Architect |

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA GOVERNANCE OPERATING MODEL V1. Spécification du registre officiel de gouvernance.*
