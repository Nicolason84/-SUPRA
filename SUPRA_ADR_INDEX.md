# SUPRA ADR INDEX V1

## Index des Architecture Decision Records de SUPRA Ultimate Consolidated

| Propriété | Valeur |
|-----------|--------|
| **Statut** | CORE — Index permanent des décisions architecturales |
| **Version** | SUPRA_ADR_INDEX_V1 |
| **Date** | 2026-07-29 |
| **Principe** | Toute décision architecturale est tracée et indexée |
| **Base** | SUPRA_ADR_STANDARD.md, SUPRA_ADR_GOVERNANCE.md |

---

## 1. Registre des ADR

| ID | Titre | Statut | Niveau | Auteur | Date | Tags |
|----|-------|--------|--------|--------|------|------|
| ADR-001 | Adoption de la Single Writer Rule | ACTIVE | CONSTITUTION | SUPRA-Architect | 2026-07-29 | governance, agents, builder |
| ADR-002 | Architecture en couches L0-L6 | ACTIVE | ARCHITECTURE | SUPRA-Architect | 2026-07-29 | architecture, layers |
| ADR-003 | Cycle de vie IDEA→PRODUCTION obligatoire | ACTIVE | CONSTITUTION | SUPRA-Architect | 2026-07-29 | lifecycle, gates |
| ADR-004 | Standard ADR obligatoire | ACTIVE | CONSTITUTION | SUPRA-Architect | 2026-07-29 | adr, governance |
| ADR-005 | Knowledge Compiler comme point d'entrée unique | ACTIVE | ARCHITECTURE | SUPRA-Architect | 2026-07-29 | knowledge, compiler |
| ADR-006 | Absorption des composants CANONICO | ACTIVE | ARCHITECTURE | SUPRA-Architect | 2026-07-29 | canonico, consolidation |
| ADR-007 | Executive Cockpit read-only | ACTIVE | ARCHITECTURE | SUPRA-Builder | 2026-07-29 | cockpit, ui, read-only |
| ADR-008 | 7 Kernels comme socle opérationnel | ACTIVE | ARCHITECTURE | SUPRA-Architect | 2026-07-29 | kernels, core |
| ADR-009 | Master Index unique | ACTIVE | CONSTITUTION | SUPRA-Architect | 2026-07-29 | index, navigation |
| ADR-010 | Master Graph unique | ACTIVE | CONSTITUTION | SUPRA-Architect | 2026-07-29 | graph, relations |
| ADR-011 | Zero dépendance directe aux documents historiques | ACTIVE | CONSTITUTION | SUPRA-Architect | 2026-07-29 | knowledge, kernel |
| ADR-012 | Composition Root comme pattern d'injection | ACTIVE | ARCHITECTURE | SUPRA-Builder | 2026-07-29 | composition, di |
| ADR-013 | Agents OpenCode natifs | ACTIVE | STANDARD | SUPRA-Architect | 2026-07-29 | agents, opencode |
| ADR-014 | Routage par scoring pondéré | ACTIVE | STANDARD | SUPRA-Router | 2026-07-29 | router, scoring |
| ADR-015 | Pipeline 8 étapes (Plan→Memory) | ACTIVE | STANDARD | SUPRA-Architect | 2026-07-29 | pipeline, workflow |
| ADR-016 | Format ADR obligatoire avec template | ACTIVE | STANDARD | SUPRA-Architect | 2026-07-29 | adr, template |
| ADR-017 | Event Bus asynchrone pub/sub | PROPOSED | ARCHITECTURE | SUPRA-Runtime | 2026-07-29 | events, pubsub |
| ADR-018 | Twin Universe comme abstraction d'état | ACTIVE | ARCHITECTURE | SUPRA-Runtime | 2026-07-29 | twins, state |
| ADR-019 | Governance Kernel comme autorité de compliance | ACTIVE | ARCHITECTURE | SUPRA-Architect | 2026-07-29 | governance, compliance |
| ADR-020 | Protection Model pour zones critiques | ACTIVE | CONSTITUTION | SUPRA-Architect | 2026-07-29 | protection, security |
| ADR-021 | Provider Framework avec abstraction unifiée | ACTIVE | ARCHITECTURE | SUPRA-Architect | 2026-07-29 | providers, abstraction |
| ADR-022 | Model Registry avec auto-détection Ollama | ACTIVE | STANDARD | SUPRA-Router | 2026-07-29 | models, registry |
| ADR-023 | Platform Registry comme identification unique | ACTIVE | CONSTITUTION | SUPRA-Architect | 2026-07-29 | platform, registry |
| ADR-024 | Component Catalog comme source de vérité des composants | ACTIVE | STANDARD | SUPRA-Architect | 2026-07-29 | catalog, components |
| ADR-025 | Component Contracts comme contrats inter-composants | ACTIVE | STANDARD | SUPRA-Architect | 2026-07-29 | contracts, interfaces |
| ADR-026 | Dependency Graph comme graphe permanent | ACTIVE | STANDARD | SUPRA-Architect | 2026-07-29 | dependencies, graph |
| ADR-027 | Runtime Blueprint pour architecture d'exécution | ACTIVE | STANDARD | SUPRA-Architect | 2026-07-29 | runtime, blueprint |

---

## 2. Distribution par Niveau

| Niveau | Count | Description |
|--------|-------|-------------|
| CONSTITUTION | 8 | Décisions constitutionnelles (validation Executive requise) |
| ARCHITECTURE | 12 | Décisions architecturales majeures |
| STANDARD | 7 | Standards et conventions |
| COMPONENT | 0 | Décisions au niveau composant |
| **Total** | **27** | |

---

## 3. Distribution par Statut

| Statut | Count |
|--------|-------|
| ACTIVE | 26 |
| PROPOSED | 1 |
| ACCEPTED | 0 |
| IMPLEMENTED | 0 |
| REJECTED | 0 |
| SUPERSEDED | 0 |
| DEPRECATED | 0 |
| ARCHIVED | 0 |

---

## 4. Distribution par Auteur

| Auteur | Count |
|--------|-------|
| SUPRA-Architect | 20 |
| SUPRA-Builder | 3 |
| SUPRA-Router | 2 |
| SUPRA-Runtime | 2 |

---

## 5. Tags les Plus Fréquents

| Tag | Count |
|-----|-------|
| architecture | 8 |
| governance | 5 |
| standards | 4 |
| agents | 3 |
| core | 3 |
| compiler | 2 |
| knowledge | 2 |
| router | 2 |
| runtime | 2 |
| contracts | 2 |

---

## 6. ADR Proposées (PENDING)

| ID | Titre | Proposeur | Priorité |
|----|-------|-----------|----------|
| ADR-017 | Event Bus asynchrone pub/sub | SUPRA-Runtime | HAUTE |
| ADR-028 | Workflow Engine en Swift natif | SUPRA-Runtime | HAUTE |
| ADR-029 | Consolidation des registres multiples | SUPRA-Architect | MOYENNE |
| ADR-030 | Standardisation des contrats REST CORE API | SUPRA-Architect | MOYENNE |

---

## 7. Correspondance avec les Gates

| ADR | Gate | Statut |
|-----|------|--------|
| ADR-001 à ADR-004 | G3 (CONSTITUTION) | VALIDÉ |
| ADR-005 à ADR-014 | G4 (GOVERNANCE) | VALIDÉ |
| ADR-015 à ADR-027 | G4 (GOVERNANCE) | VALIDÉ |
| ADR-017, ADR-028 à ADR-030 | G2 (FOUNDATION) | EN ATTENTE |

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA ULTIMATE CONSOLIDATED PHASE 2. Index permanent des Architecture Decision Records.*
