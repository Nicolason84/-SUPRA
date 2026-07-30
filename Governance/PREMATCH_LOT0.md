# LOT 0 — Pré-matching de la fondation de gouvernance

Date: 2026-07-27  
Statut: **PASS — autorisation limitée aux artefacts de gouvernance**  
Périmètre: registres, ADR, fitness functions, validation et quality gates

## Sources découvertes

| Responsabilité | Source existante | Décision |
|---|---|---|
| Constitution | `docs/SUPRA_EXECUTIVE_OS_CONSTITUTION_V1.md` | REUSE / CANONIZE |
| Gouvernance documentaire | `docs/SUPRA_EXECUTIVE_OS_GOVERNANCE.md` | REUSE / CANONIZE |
| Autorités fonctionnelles | `SUPRA_FUNCTIONAL_AUTHORITY.json` | REUSE / ADAPTER |
| Registre global | `CANONICAL_REGISTRY.json` | REUSE comme source historique |
| Modules/services/packages | `CANONICAL_MODULES.json`, `CANONICAL_SERVICES.json`, `CANONICAL_PACKAGES.json` | REUSE |
| Workers | `CANONICAL_WORKERS.json`, `.opencode/registry/agent_registry.json` | REUSE / MERGE projection |
| Capacités | `.opencode/registry/capability_registry.json` | REUSE / CANONIZE |
| Providers/modèles | `.opencode/runtime/provider_registry.json`, `.opencode/registry/model_registry.json` | REUSE |
| Workflows | `.opencode/registry/workflow_registry.json` | REUSE |
| Doublons | `DUPLICATE_REGISTRY.json`, `CANNO_DUPLICATE_VALIDATION.md` | REUSE comme preuves |
| Graphes | `SUPRA_DEPENDENCY_GRAPH.json`, `SUPRA_RUNTIME_GRAPH.json`, `SUPRA_ARCHITECTURE_INDEX.json` | REUSE historique; régénération future |
| Audit composition | `GO_SUPRA_COMPOSITION_ROOT_AUDIT.sh` | ADAPTER |
| Validation plateforme | `GO_SUPRA_VALIDATE.sh`, `GO_SUPRA_VALIDATE_V3.sh` | REUSE comme contrôles d’environnement |
| Freeze/continuité | `CONTINUITY.md`, `FREEZE_V1.md`, `Freeze/` | REUSE |

## Classification obligatoire

### KEEP

- Constitution et Gouvernance existantes dans `docs/`.
- Autorités Runtime existantes.
- Composition Root validée.
- Freeze protégé-folder.
- Rapports et preuves historiques.

### MERGE

- Les registres existants sont réunis par une projection gouvernance ; leurs
  fichiers sources ne sont pas supprimés ni écrasés.
- Les classifications workers/capabilities/providers sont reliées sans créer un
  nouveau registre Runtime.

### REUSE

- JSON registries existants.
- Scripts d’audit existants.
- Rapports de freeze et de continuité.

### CANONIZE

- `Governance/constitution_registry.json` comme index constitutionnel.
- `Governance/authority_registry.json` comme projection des autorités.
- `Governance/capability_registry.json` comme projection capability-first.
- `Governance/adr_registry.json` comme index ADR vivant.
- `Governance/fitness_functions.json` comme règles exécutables déclaratives.
- `Governance/quality_gates.json` comme séquence normative des quality gates.

### ADAPTER

- Un validateur read-only dédié consomme les registres et les sources Swift sans
  modifier le Runtime.
- Les audits existants restent disponibles et sont référencés comme preuves ou
  contrôles complémentaires.

### REMOVE

- Aucun fichier existant supprimé.
- Aucun registre historique déplacé ou réécrit.

### CREATE

Uniquement les artefacts de gouvernance ci-dessus et leurs preuves. Aucun type
Swift métier, aucune vue, aucun service d’exécution et aucun nouveau moteur ne
sera créé.

## Analyse d’impact

- Dépendances Runtime: aucune modification.
- Cible Xcode: aucune modification.
- Package.swift: aucune modification.
- Freeze protégé-folder: aucune modification.
- Risque principal: divergence entre projections gouvernance et sources
  historiques ; mitigé par références, empreintes et verdicts explicites.
- Bénéfice: une validation automatique avant tout futur lot.

## Verdict

Le LOT 0 est autorisé uniquement pour les artefacts sous `Governance/` et les
rapports produits par leur validateur. Toute modification hors de ce périmètre
doit être refusée.
