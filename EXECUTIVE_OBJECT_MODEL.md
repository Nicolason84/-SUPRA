# SUPRA Executive Object Model

> [FACT][META-OM-001] **DRAFT — NON VALIDÉ — NON EFFECTIF.** Les objets ci-dessous sont des contrats conceptuels, pas des structures de code.

## 1. Principes

[PROPOSAL][OM-001] Chaque objet possède une identité stable, une version, un propriétaire, un cycle de vie explicite, une provenance et des relations nommées.

[PROPOSAL][OM-002] Une relation porte ses cardinalités et son autorité. Une référence n’accorde jamais la propriété de l’objet référencé.

## 2. Les douze objets fondamentaux

| Objet | Rôle | Cycle de vie | Propriétaire | Relations et cardinalités |
|---|---|---|---|---|
| [PROPOSAL][O-01] Mission | unité exécutive orientée résultat | proposée → prête → active → suspendue → achevée/annulée/échouée | MissionEngine | 1..n Objective; 0..n Decision; 0..n Task; 0..n Execution; 0..n Evidence |
| [PROPOSAL][O-02] Objective | résultat vérifiable d’une Mission | défini → accepté → en cours → atteint/non atteint/abandonné | MissionEngine | appartient à 1 Mission; 0..n Task; 0..n Evidence |
| [PROPOSAL][O-03] Decision | arbitrage traçable | proposée → en revue → approuvée/rejetée/différée → révoquée | DecisionEngine | concerne 0..n Mission/Objective; autorise 0..n Action; cite 0..n Evidence |
| [PROPOSAL][O-04] Action | intention autorisée de changement | proposée → autorisée → distribuée → exécutée/échouée/annulée | engine du domaine affecté | issue de 0..1 Decision; génère 0..n Task/Execution; cite 0..n Evidence |
| [PROPOSAL][O-05] Evidence | preuve immuable ou référence vérifiable | observée → indexée → validée/contestée → archivée | EvidenceEngine | étaye 0..n Objective/Decision/Execution/Knowledge |
| [PROPOSAL][O-06] Knowledge | assertion ou structure interprétée | candidate → validée → active → supersédée/révoquée | KnowledgeEngine | dérive de 1..n Evidence/Memory; concerne 0..n Workspace/Mission |
| [PROPOSAL][O-07] Memory | trace conservée avec contexte | capturée → disponible → consolidée → expirée/supprimée selon politique | MemoryEngine | source possible de 0..n Knowledge; liée à 0..n Mission/Workspace |
| [PROPOSAL][O-08] RuntimeSnapshot | projection atomique de lecture | assemblé → publié → supersédé → retenu/expiré | RuntimeSnapshotStore | contient exactement 11 contributions; référence 0..n objets par projection |
| [PROPOSAL][O-09] Workspace | périmètre gouverné de ressources | découvert → autorisé → indexé → actif → archivé/révoqué | WorkspaceEngine | contient 0..n Mission/Task/Knowledge/Memory; expose 0..n Provider autorisés |
| [PROPOSAL][O-10] Provider | capacité d’exécution externe/interne enregistrée | découvert → enregistré → disponible/dégradé/indisponible → retiré | ProviderEngine | sert 0..n Execution; possède 1..n capacités déclarées |
| [PROPOSAL][O-11] Task | unité planifiée, non nécessairement exécutée | créée → prête → bloquée/en cours → terminée/échouée/annulée | MissionEngine | appartient à 1 Mission; sert 1..n Objective; produit 0..n Execution |
| [PROPOSAL][O-12] Execution | tentative concrète et corrélée | demandée → autorisée → démarrée → réussie/échouée/annulée | owner à décider | exécute 1 Action ou Task; utilise 0..1 Provider; produit 0..n Evidence |

[HYPOTHESIS][H-OM-01] L’ownership d’Execution entre MissionEngine, ProviderEngine et une éventuelle autorité d’orchestration n’est pas résolu. Validation : ADR. Impact : événements terminaux et retry ambigus.

[HYPOTHESIS][H-OM-02] La frontière Action/Task peut différer dans les modèles historiques. Validation : mapping de fixtures réelles. Impact : adapter requis.

## 3. Identité, mutation et relations

[PROPOSAL][OM-003] Toute mutation crée une nouvelle version logique; elle conserve l’identité, la cause, l’auteur et la version antérieure.

[PROPOSAL][OM-004] Les états terminaux ne sont pas réouverts implicitement. Une reprise crée une transition autorisée ou un nouvel objet corrélé.

[PROPOSAL][OM-005] Une suppression logique préserve la traçabilité requise; l’effacement physique dépend d’une politique de rétention et de sensibilité encore à décider.

[PROPOSAL][OM-006] Le Snapshot ne devient jamais propriétaire des objets projetés et ne doit pas servir de commande.

## 4. Matrice d’autorité

| Opération | Autorité |
|---|---|
| [PROPOSAL][OM-A01] créer/activer Mission, Objective, Task | MissionEngine |
| [PROPOSAL][OM-A02] statuer Decision | DecisionEngine et human gate éventuel |
| [PROPOSAL][OM-A03] autoriser Action | engine du domaine, sous contraintes de Decision |
| [PROPOSAL][OM-A04] valider Evidence | EvidenceEngine |
| [PROPOSAL][OM-A05] promouvoir Knowledge | KnowledgeEngine |
| [PROPOSAL][OM-A06] retenir Memory | MemoryEngine |
| [PROPOSAL][OM-A07] publier RuntimeSnapshot | RuntimeSnapshotStore |
| [PROPOSAL][OM-A08] enregistrer Workspace/Provider | WorkspaceEngine / ProviderEngine |
| [HYPOTHESIS][OM-A09] terminer Execution | owner à décider par ADR |

## 5. Registres

| Registre | Entrées |
|---|---|
| [HYPOTHESIS][OM-HYP] | H-OM-01 owner Execution; H-OM-02 Action/Task; politique de rétention |
| [PROPOSAL][OM-RISK] | identités dupliquées; relation sans cardinalité; transitions illégales; snapshot traité comme modèle mutable |
| [PROPOSAL][OM-DEC] | ADR ownership Execution; mapping modèles historiques; politique d’effacement |
| [EVIDENCE][OM-TRACE] | inventaire des modèles dans [`ULTIMATE_CONSOLIDATION_REPORT.md`](ULTIMATE_CONSOLIDATION_REPORT.md); doctrine [`SUPRA_CANON.md`](SUPRA_CANON.md) |

[FACT][CHG-OM-001] `2026-07-28` — création du draft V1.
