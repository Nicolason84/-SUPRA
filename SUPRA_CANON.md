# SUPRA Executive OS — Canon

> [FACT][META-001] Statut : **DRAFT — NON VALIDÉ — NON EFFECTIF**. Version documentaire `SUPRA_EXECUTIVE_CANON_V1`, datée du 28 juillet 2026. Aucune implémentation ne peut se réclamer de ce Canon avant validation explicite de l’utilisateur.

## 1. Autorité documentaire

[PROPOSAL][GOV-001] Le présent document devient, après validation explicite, la constitution de SUPRA Executive OS. Décideur : utilisateur/propriétaire du projet. Critère d’acceptation : approbation explicite du lot documentaire complet.

[PROPOSAL][GOV-002] Ordre de préséance, du plus normatif au plus explicatif :

1. [PROPOSAL] `SUPRA_CANON.md`;
2. [PROPOSAL] [`RUNTIME_LAWS.md`](RUNTIME_LAWS.md);
3. [PROPOSAL] [`EXECUTIVE_OBJECT_MODEL.md`](EXECUTIVE_OBJECT_MODEL.md), [`EXECUTIVE_EVENT_MODEL.md`](EXECUTIVE_EVENT_MODEL.md), [`EXECUTIVE_RUNTIME.md`](EXECUTIVE_RUNTIME.md);
4. [PROPOSAL] [`UI_PHILOSOPHY.md`](UI_PHILOSOPHY.md), [`EXECUTION_PHILOSOPHY.md`](EXECUTION_PHILOSOPHY.md);
5. [PROPOSAL] [`SUPRA_EXECUTIVE_BOOK.md`](SUPRA_EXECUTIVE_BOOK.md).

[PROPOSAL][GOV-003] En cas de contradiction de même niveau, la règle la plus restrictive protège le Runtime jusqu’à décision d’architecture enregistrée. Une observation `[FACT]` ne rend pas effective une cible `[PROPOSAL]`.

## 2. Base probatoire et taxonomie

| Classe | Définition et usage |
|---|---|
| [FACT][TAX-FACT] | Observation présente dans les sources lues; elle ne prouve ni exhaustivité ni comportement runtime. |
| [EVIDENCE][TAX-EVIDENCE] | Référence datée, localisable et assortie de sa limite probatoire. |
| [HYPOTHESIS][TAX-HYPOTHESIS] | Élément non démontré, avec validation attendue et impact si faux. |
| [PROPOSAL][TAX-PROPOSAL] | Norme ou cible soumise à décision, avec propriétaire et critère d’acceptation. |

| Source Phase 0 | État de lecture | Portée |
|---|---|---|
| [EVIDENCE][SRC-001] `AGENTS.md` | intégrale, 28-07-2026 | rôles, Single Writer, pipeline et interdictions |
| [EVIDENCE][SRC-002] `ULTIMATE_CONSOLIDATION_REPORT.md` | intégrale, 28-07-2026 | inventaire précédent, cible, risques et limites |
| [EVIDENCE][SRC-003] `DEPENDENCY_MAP.md` | intégrale, 28-07-2026 | graphe historique et mise à jour Foundation Memory |
| [EVIDENCE][SRC-004] `README.md` | absent à la racine, 28-07-2026 | aucune preuve produit issue de ce nom |
| [EVIDENCE][SRC-005] `ARCHITECTURE.md` | absent à la racine, 28-07-2026 | aucune autorité d’architecture sous ce nom |
| [EVIDENCE][SRC-006] `CURRENT_STATE.json` | absent à la racine, 28-07-2026 | état courant non certifié sous ce nom |

[FACT][BASE-001] Le dépôt était déjà fortement modifié et non suivi avant ce lot; l’attribution de l’état produit reste donc limitée à des preuves ciblées.

[HYPOTHESIS][H-12] Les trois générations décrites par le rapport correspondent encore exactement aux routes disponibles. Validation : inventaire runtime et captures dans une mission ultérieure. Impact si faux : matrice de migration à réviser.

## 3. Vision, mission et valeurs

[PROPOSAL][VIS-001] Vision : faire de SUPRA un Executive Operating System unique qui transforme des objectifs en décisions, actions, exécutions et preuves, tout en rendant l’état réel du système intelligible et gouvernable.

[PROPOSAL][MIS-001] Mission : fournir une autorité exécutive locale cohérente pour piloter les missions, le Runtime, les espaces de travail, la connaissance, les décisions et les providers sans fragmenter les sources de vérité.

| Valeur | Exigence |
|---|---|
| [PROPOSAL][VAL-001] Vérité explicite | L’état inconnu, périmé ou indisponible est affiché comme tel. |
| [PROPOSAL][VAL-002] Traçabilité | Toute décision, action et transition critique possède cause, auteur, temps et preuve. |
| [PROPOSAL][VAL-003] Autorité unique | Une donnée, un service stateful et une règle métier ont chacun un propriétaire. |
| [PROPOSAL][VAL-004] Réversibilité | Toute consolidation est livrée par lot observable et réversible. |
| [PROPOSAL][VAL-005] Préservation | Les composants matures sont adaptés avant tout retrait. |
| [PROPOSAL][VAL-006] Lisibilité | Le système expose la réalité opérationnelle sans simulation silencieuse. |

## 4. Objectifs et invariants

[PROPOSAL][OBJ-001] Unifier le produit sans ajouter de fonctionnalité, de quatrième dashboard ni de Runtime concurrent.

[PROPOSAL][OBJ-002] Rendre le comportement gouvernable par contrats, événements explicites, responsabilités et critères de conformité testables.

[PROPOSAL][OBJ-003] Préparer une consolidation séquentielle fondée sur la parité, le shadow mode et le rollback.

[PROPOSAL][INV-001] Il existe une seule application SUPRA Executive OS, un seul shell produit, un seul propriétaire de composition et une seule vérité de lecture Runtime.

[PROPOSAL][INV-002] L’UI projette un `RuntimeSnapshot`; elle ne possède ni logique métier, ni I/O, ni boucle Runtime.

[PROPOSAL][INV-003] Les moteurs acceptent des commandes explicites et contribuent des états/événements; ils ne se partagent pas de données par communication implicite.

[PROPOSAL][INV-004] Une donnée critique expose provenance, temps, fraîcheur et erreur éventuelle.

[PROPOSAL][INV-005] Aucune implémentation, suppression ou activation de ce Canon n’intervient avant validation explicite.

## 5. Architecture cible et responsabilités

[PROPOSAL][ARC-001] Les quatre autorités cibles sont :

| Autorité | Responsabilité | Limite |
|---|---|---|
| [PROPOSAL][AUTH-UI] `ExecutiveWindow` | shell et navigation des douze espaces | ne possède pas le métier |
| [PROPOSAL][AUTH-LIFE] `SUPRACompositionRoot` | cycle de vie et unicité des instances | ne duplique pas les engines |
| [PROPOSAL][AUTH-READ] `RuntimeSnapshotStore` | publication atomique et lecture canonique | n’exécute aucune commande métier |
| [PROPOSAL][AUTH-VIS] `SUPRAOSDesignSystem` | identité visuelle et composants | ne définit pas le domaine |

[HYPOTHESIS][H-01] `RuntimeKernel` et `RuntimeSnapshotStore` ne sont pas démontrés comme implémentés conformément à cette doctrine. Validation : audit Swift et test d’atomicité. Impact : toute formulation demeure une cible.

[HYPOTHESIS][H-11] Le Runtime actif n’a pas été validé dynamiquement pendant cette mission documentaire. Validation : smoke test ultérieur. Impact : aucun état « opérationnel » n’est certifié ici.

[HYPOTHESIS][H-09] Les snapshots historiques pourront être adaptés sans perte sémantique. Validation : fixtures et comparateur de parité. Impact : schémas ou migration à spécifier.

[PROPOSAL][ARC-002] Les onze domaines Runtime sont exclusivement : Mission, Memory, Knowledge, Decision, Discovery, Evidence, Provider, Workspace, Health, Recovery et Freeze. Leur doctrine détaillée est dans [`EXECUTIVE_RUNTIME.md`](EXECUTIVE_RUNTIME.md).

[PROPOSAL][ARC-003] Les douze espaces UI sont exclusivement : Dashboard, Mission, Runtime, Workspace, Knowledge, Discovery, Decisions, Evidence, Providers, Reports, Developer et Settings. Leur doctrine est dans [`UI_PHILOSOPHY.md`](UI_PHILOSOPHY.md).

[PROPOSAL][ARC-004] Le modèle comporte exclusivement les douze objets fondamentaux définis dans [`EXECUTIVE_OBJECT_MODEL.md`](EXECUTIVE_OBJECT_MODEL.md) : Mission, Objective, Decision, Action, Evidence, Knowledge, Memory, RuntimeSnapshot, Workspace, Provider, Task et Execution.

## 6. Limites et principes d’évolution

[PROPOSAL][LIM-001] Hors Canon : logique d’implémentation, syntaxe Swift, configuration Xcode, Packages, endpoints nouveaux, migration de données et sélection d’une technologie de bus.

[PROPOSAL][EVO-001] Toute évolution commence par une preuve du besoin, une analyse de propriétaire, une ADR, un contrat, un plan de compatibilité et un critère de retrait.

[PROPOSAL][EVO-002] Un nouveau module ne peut être admis que s’il possède un domaine non couvert, un propriétaire unique, des commandes/événements explicites, une projection snapshot, des tests de loi et un rollback.

[PROPOSAL][EVO-003] Une duplication temporaire exige une date d’expiration, une destination canonique, un comparateur de parité et une décision de retrait.

## 7. Registres

### 7.1 Hypothèses ouvertes

| ID | Hypothèse | Validation requise | Risque |
|---|---|---|---|
| [HYPOTHESIS][H-02] | persistance événementielle non démontrée | audit stockage et replay | perte de traçabilité |
| [HYPOTHESIS][H-03] | portée d’« une Mission active » = `runtimeID` | décision produit | conflits multi-workspace |
| [HYPOTHESIS][H-04] | propriétaire canonique d’Execution à confirmer | ADR Mission/Provider | responsabilité ambiguë |
| [HYPOTHESIS][H-05] | rétention des événements inconnue | politique de données | volume ou preuve insuffisante |
| [HYPOTHESIS][H-06] | classification de sensibilité incomplète | audit sécurité | fuite dans logs/replay |
| [HYPOTHESIS][H-07] | seuils de fraîcheur et barrière atomique inconnus | SLO par domaine | snapshot incohérent |
| [HYPOTHESIS][H-08] | frontière Action/Task à éprouver sur cas réels | atelier objet | duplication sémantique |
| [HYPOTHESIS][H-10] | sources absentes ne contiennent pas d’autorité concurrente | création/revue ultérieure | doctrine incomplète |

### 7.2 Risques

| ID | Risque | Niveau | Maîtrise proposée |
|---|---|---|---|
| [PROPOSAL][R-01] | double exécution | critique | idempotence, corrélation, propriétaire unique |
| [PROPOSAL][R-02] | snapshot incohérent | critique | publication atomique, révision monotone |
| [PROPOSAL][R-03] | contournement d’un human gate | critique | décision et autorisation persistées |
| [PROPOSAL][R-04] | divergence stores/snapshot | élevé | shadow mode et comparateur |
| [PROPOSAL][R-05] | fallback fictif | élevé | états stale/unavailable/error |
| [PROPOSAL][R-06] | bascule événementielle big-bang | élevé | adoption domaine par domaine |
| [PROPOSAL][R-07] | schéma incompatible | élevé | versions et adapters |
| [FACT][R-08] | baseline Git dirty | élevé | manifest attribuable par lot |
| [PROPOSAL][R-09] | données sensibles dans événements | élevé | classification et redaction |
| [PROPOSAL][R-10] | confusion Freeze/live | élevé | stores et labels séparés |

### 7.3 Décisions requises

| ID | Décision | Autorité | Condition |
|---|---|---|---|
| [PROPOSAL][D-001] | valider ou rejeter le Canon | utilisateur | revue des huit documents |
| [PROPOSAL][D-002] | fixer la portée d’une Mission active | propriétaire produit | résolution H-03 |
| [PROPOSAL][D-003] | attribuer Execution | architecte + runtime owner | résolution H-04 |
| [PROPOSAL][D-004] | définir rétention/sensibilité/fraîcheur | gouvernance | résolution H-05/H-06/H-07 |
| [PROPOSAL][D-005] | confirmer l’entry point actif | validation runtime | build + inspection dynamique |

### 7.4 Traçabilité et changelog

| ID | Doctrine | Sources |
|---|---|---|
| [EVIDENCE][TR-001] | Single Writer et pipeline | SRC-001 |
| [EVIDENCE][TR-002] | architecture unifiée, onze domaines, douze espaces | SRC-002 |
| [EVIDENCE][TR-003] | coexistence historique des architectures | SRC-003 |
| [HYPOTHESIS][TR-004] | entry point courant | SRC-002 plus récent contre SRC-003 historique; D-005 requise |

[FACT][CHG-001] `2026-07-28` — création du draft V1; aucune version antérieure de ce fichier.
