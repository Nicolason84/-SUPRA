# SUPRA IMMUTABLE PRINCIPLES V1

## Lois Permanentes du SUPRA Engineering Operating System

| Propriété | Valeur |
|-----------|--------|
| **Statut** | CONSTITUTION — Principes non négociables sauf amendement |
| **Version** | SUPRA_IMMUTABLE_PRINCIPLES_V1 |
| **Date** | 2026-07-29 |
| **Autorité** | Constitution — ces principes ne peuvent être modifiés que par amendement constitutionnel |

---

## Classification des Principes

Chaque principe est classé en :

| Catégorie | Code | Description |
|-----------|------|-------------|
| **Non négociable** | 🔒 | Ne peut être modifié. Requiert un amendement constitutionnel. |
| **Évolutif** | 🔄 | Peut être modifié par décision architecturale (ADR). |
| **Temporaire** | ⏳ | Valable jusqu'à une date ou condition spécifiée. |

---

## Titre I — Principes Non Négociables (🔒)

### Principe NN-01 : Unité d'Architecture

**Énoncé** : Il existe une seule architecture officielle de SUPRA, définie dans SUPRA_EXECUTIVE_CANON.md.

**Justification** : Les architectures concurrentes ont causé la fragmentation du codebase avant SUPRA ZERO. L'unité d'architecture est la condition sine qua non de la cohérence du système.

**Sanction** : Tout composant qui ne se conforme pas à l'architecture canonique est REFUSÉ.

### Principe NN-02 : Single Writer Rule

**Énoncé** : SUPRA-Builder est le seul agent autorisé à créer, modifier ou supprimer des fichiers. Tous les autres agents sont strictement READ ONLY.

**Justification** : Élimine les conflits d'écriture concurrents. Garantit la traçabilité de toute modification.

**Exception** : Mission explicitement autorisée par l'Executive avec périmètre et durée définis.

### Principe NN-03 : Réversibilité

**Énoncé** : Toute évolution doit être réversible. Aucune action irréversible n'est autorisée sans décision constitutionnelle.

**Justification** : La réversibilité est le mécanisme de sécurité fondamental de SUPRA. Sans elle, toute erreur devient une perte.

**Mesure** : Toute évolution doit inclure un plan de rollback validé avant exécution.

### Principe NN-04 : Source de Vérité Unique

**Énoncé** : Chaque domaine a exactement une source de vérité canonique.

**Justification** : Les sources de vérité multiples créent des contradictions, des ambiguïtés et des décisions non documentées.

**Application** : Défini dans SUPRA_MASTER_REGISTRY.json.

### Principe NN-05 : Cycle de Vie Obligatoire

**Énoncé** : Tout composant SUPRA doit suivre le cycle IDEA → FOUNDATION → CONSTITUTION → GOVERNANCE → ULTIMATE → PRODUCTION. Aucune étape ne peut être sautée.

**Justification** : Le cycle de vie garantit que chaque composant atteint la maturité requise avant d'être intégré.

**Sanction** : Tout composant qui saute une étape est considéré comme INVALIDE.

### Principe NN-06 : Traçabilité des Décisions

**Énoncé** : Toute décision architecturale importante doit être documentée par une ADR conforme à SUPRA_ADR_STANDARD.md.

**Justification** : Sans ADR, les décisions deviennent implicites, non documentées, et impossibles à auditer.

**Seuil** : Est considérée comme "importante" toute décision qui affecte l'architecture, les contrats, ou la réversibilité du système.

### Principe NN-07 : Propreté du Workspace

**Énoncé** : Le workspace principal de SUPRA doit être dans un état git propre (0 modified files) avant le début de toute mission majeure.

**Justification** : Un workspace sale rend la traçabilité impossible.

**Sanction** : Toute mission majeure commencée sur un workspace sale est automatiquement en FAIL.

### Principe NN-08 : Aucune Suppression Irréversible

**Énoncé** : Aucune suppression de fichier ou de composant n'est définitive sans validation explicite.

**Justification** : La conservation de l'historique est primordiale pour la réversibilité et l'audit.

**Application** : Tout composant déprécié est d'abord marqué DEPRECATED, puis FROZEN, puis potentiellement ARCHIVED. Jamais supprimé directement.

### Principe NN-09 : Propriété Unique

**Énoncé** : Toute capacité, tout composant et tout document a un propriétaire unique et identifié.

**Justification** : La responsabilité partagée est une responsabilité absente.

**Application** : Défini dans la matrice des responsabilités (SUPRA_AUTHORITY_MODEL.md).

---

## Titre II — Principes Évolutifs (🔄)

### Principe EV-01 : Pipeline d'Exécution

**Énoncé** : Le pipeline d'exécution par défaut est : Mission → Executive → Architect → Router → Read Agents → Comparator → Fusion → Validator → Builder.

**Évolutivité** : Des étapes peuvent être ajoutées ou retirées par ADR architecturale.

### Principe EV-02 : Format Documentaire

**Énoncé** : Les documents canoniques sont en Markdown. Les données structurées sont en JSON. Le code est en Swift.

**Évolutivité** : De nouveaux formats peuvent être adoptés par décision architecturale.

### Principe EV-03 : Nombre d'Agents

**Énoncé** : Les 9 agents fondateurs sont Builder, Architect, Auditor, Router, Explorer, Research, Runtime, Refactor, Reviewer.

**Évolutivité** : De nouveaux agents peuvent être ajoutés (Sherpa, Cortex, Theory, Governance, Product, Plugin) après validation Foundation → Constitution → Governance.

### Principe EV-04 : Fréquence des Gates

**Énoncé** : Les Gates sont déclenchés à chaque transition d'étape du cycle de vie.

**Évolutivité** : Des gates intermédiaires peuvent être ajoutés par phase.

### Principe EV-05 : Métriques de Complétion

**Énoncé** : Les pourcentages de complétion des couches architecturales sont suivis dans SUPRA_MASTER_MANIFEST.json.

**Évolutivité** : Les métriques peuvent être affinées, les seuils ajustés par ADR.

---

## Titre III — Principes Temporaires (⏳)

### Principe TP-01 : Workspace Sale Autorisé

**Énoncé** : Jusqu'à la fin de la Phase 2a (Ultimate Consolidation), un workspace partiellement sale est toléré pour les missions de consolidation.

**Expiration** : Fin de la mission SUPRA ULTIMATE CONSOLIDATION.

**Condition de levée** : 0 modified files dans git status.

### Principe TP-02 : Tests en Échec Tolérés

**Énoncé** : Jusqu'à la résolution des 3 tests en échec, les missions peuvent continuer sans exiger 9/9 tests passants.

**Expiration** : Résolution du dernier test en échec.

**Condition de levée** : 9/9 tests passants.

### Principe TP-03 : Documents en DRAFT Autorisés

**Énoncé** : Les documents de type PRÉPARATION ou SPÉCIFICATION peuvent être en statut DRAFT sans bloquer les missions ultérieures.

**Expiration** : Début de la phase d'implémentation du composant concerné.

**Condition de levée** : Tous les documents du composant en statut CANONIQUE ou VALIDÉ.

---

## Tableau de Bord des Principes

| ID | Principe | Classe | Statut | Sanction si Violation |
|----|----------|--------|--------|----------------------|
| NN-01 | Unité d'Architecture | 🔒 Non négociable | ACTIF | REFUS du composant |
| NN-02 | Single Writer Rule | 🔒 Non négociable | ACTIF | INVALIDATION de la modification |
| NN-03 | Réversibilité | 🔒 Non négociable | ACTIF | BLOCAGE de l'évolution |
| NN-04 | Source de Vérité Unique | 🔒 Non négociable | ACTIF | CORRECTION obligatoire |
| NN-05 | Cycle de Vie Obligatoire | 🔒 Non négociable | ACTIF | INVALIDATION du composant |
| NN-06 | Traçabilité des Décisions | 🔒 Non négociable | ACTIF | REFUS de la décision |
| NN-07 | Propreté du Workspace | 🔒 Non négociable | ACTIF | FAIL automatique |
| NN-08 | Aucune Suppression Irréversible | 🔒 Non négociable | ACTIF | ROLLBACK immédiat |
| NN-09 | Propriété Unique | 🔒 Non négociable | ACTIF | REFUS du composant |
| EV-01 | Pipeline d'Exécution | 🔄 Évolutif | ACTIF | ADR requise |
| EV-02 | Format Documentaire | 🔄 Évolutif | ACTIF | ADR requise |
| EV-03 | Nombre d'Agents | 🔄 Évolutif | ACTIF | Suivre le cycle de vie |
| EV-04 | Fréquence des Gates | 🔄 Évolutif | ACTIF | ADR requise |
| EV-05 | Métriques de Complétion | 🔄 Évolutif | ACTIF | ADR requise |
| TP-01 | Workspace Sale Autorisé | ⏳ Temporaire | ACTIF | Expire à la fin Phase 2a |
| TP-02 | Tests en Échec Tolérés | ⏳ Temporaire | ACTIF | Expire à 9/9 tests |
| TP-03 | Documents en DRAFT | ⏳ Temporaire | ACTIF | Expire à l'implémentation |

---

## Règle de Conflit Entre Principes

1. Un principe Non Négociable 🔒 prévaut toujours sur un principe Évolutif 🔄.
2. Un principe Évolutif 🔄 prévaut toujours sur un principe Temporaire ⏳.
3. En cas de conflit entre deux principes de même classe, la règle la plus restrictive s'applique.
4. Tout conflit non résolu est tranché par l'Executive.

---

## Amendement des Principes

| Action | Classe | Procédure |
|--------|--------|-----------|
| Modifier | 🔒 Non négociable | Amendement constitutionnel — ADR de niveau CONSTITUTION + approbation Executive |
| Modifier | 🔄 Évolutif | ADR architecturale — validation Architect |
| Modifier | ⏳ Temporaire | Expiration automatique ou décision Executive |
| Ajouter | Toute | ADR + validation Architect + approbation Executive |

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA CONSTITUTION V1.*
