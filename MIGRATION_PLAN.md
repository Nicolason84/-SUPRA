# MIGRATION PLAN

## Plan de Migration vers l'Architecture Canonique SUPRA

| Propriété | Valeur |
|---|---|
| **Version** | MIGRATION_PLAN_V1 |
| **Date** | 2026-07-29 |
| **Statut** | LIVRABLE AUDIT — PLAN |
| **Autorité** | SUPRA Constitution — Article 2 |
| **Dérivé de** | SEMANTIC_CANONICAL_MAP.md, TUV5_KNOWLEDGE_COMPILER.md, CANNoNICO_FOUNDATION.md, CANNoNICO_PRIMITIVES.md, NAMBROCAHORA_FOUNDATION.md, RUNTIME_CANONICAL_MODEL.md |

---

## 1. PHILOSOPHIE DE MIGRATION

La migration ne modifie PAS le code existant.
La migration ÉTABLIT les fondations pour que le prochain code respecte l'architecture canonique.

Chaque étape est un jalon de conformité, pas de réécriture.

---

## 2. PHASES DE MIGRATION

### Phase 0 : Conformité Documentaire (Actuelle → J+0)

| # | Tâche | Livrable | Statut |
|---|-------|----------|--------|
| 0.1 | Adopter SEMANTIC_CANONICAL_MAP.md comme cartographie sémantique officielle | ✅ Livré | Complete |
| 0.2 | Adopter TUV5_KNOWLEDGE_COMPILER.md comme spécification TUV5 officielle | ✅ Livré | Complete |
| 0.3 | Adopter CANNoNICO_FOUNDATION.md comme fondation CANNoNICO officielle | ✅ Livré | Complete |
| 0.4 | Adopter CANNoNICO_PRIMITIVES.md comme référence de primitives officielle | ✅ Livré | Complete |
| 0.5 | Adopter NAMBROCAHORA_FOUNDATION.md comme fondation temporelle officielle | ✅ Livré | Complete |
| 0.6 | Adopter RUNTIME_CANONICAL_MODEL.md comme modèle canonique du Runtime | ✅ Livré | Complete |
| 0.7 | Adopter MIGRATION_PLAN.md comme plan de migration officiel | ✅ Livré | Complete |
| 0.8 | Archiver les documents historiques obsolètes dans la section ZERO | À faire | N/A |

### Phase 1 : Conformité du Runtime Codebase (J+0 → J+30)

| # | Tâche | Fichier(s) | Action | Validation |
|---|-------|-----------|--------|-----------|
| 1.1 | Remplacer `Date()` par `NAMBROCAHORA.tick()` dans CAnnoNicoSnapshotStore | `SUPRA/CAnnoNicoSnapshotStore.swift` | Modifier le champ `generatedAt: Date` en `generatedAtTick: INT64` | Aucun `Date` reste dans CAnnoNicoSnapshotStore |
| 1.2 | Remplacer `Date()` par `NAMBROCAHORA.tick()` dans Snapshot | `SUPRA/Snapshot.swift` | Même migration | Aucun `Date` reste dans Snapshot |
| 1.3 | Remplacer `Date()` par `NAMBROCAHORA.tick()` dans SUPRARuntimeEvents | `SUPRA/SUPRARuntimeEvents.swift` | Même migration | Aucun `Date` reste |
| 1.4 | Remplacer `Date()` par `NAMBROCAHORA.tick()` dans RuntimeGateway | `SUPRA/RuntimeGateway.swift` | Même migration | Aucun `Date` reste |
| 1.5 | Remplacer `Date()` par `NAMBROCAHORA.tick()` dans MissionStore | `SUPRA/MissionStore.swift` | Même migration | Aucun `Date` reste |
| 1.6 | Remplacer `Date()` par `NAMBROCAHORA.tick()` dans DecisionStore | `SUPRA/DecisionStore.swift` | Même migration | Aucun `Date` reste dans DecisionStore |
| 1.7 | Remplacer `Date()` par `NAMBROCAHORA.tick()` dans ExecutiveMemory | `SUPRA/ExecutiveMemory.swift` | Même migration | Aucun `Date` reste |
| 1.8 | Remplacer `Date()` par `NAMBROCAHORA.tick()` dans CAnnoNicoIntegrationSnapshot | `Packages/CAnnoNicoIntegrationPackage/Sources/CAnnoNicoContracts/CAnnoNicoContracts.swift` | Modifier `generatedAt: Date` en `generatedAtTick: INT64` | Aucun `Date` reste |
| 1.9 | Remplacer `UUID()` par `NAMBROCAHORA.eventId()` pour les identifiants d'événements | Fichiers concernés | UUID → NAMBROCAHORA eventId | Aucun UUID pour les événements système |
| 1.10 | Créer `NAMBROCAHORA.swift` dans `SUPRA/` | Nouveau fichier | Implémentation de l'enum NAMBROCAHORA | Compile et passe les tests |
| 1.11 | Créer `CANNoNICO.swift` dans `SUPRA/` | Nouveau fichier | Implémentation des primitives CANNoNICO | Compile et passe les tests |
| 1.12 | Créer `TUV5.swift` dans `SUPRA/` | Nouveau fichier | Implémentation du Knowledge Compiler | Compile et passe les tests |

### Phase 2 : Fusion des Registres (J+30 → J+60)

| # | Tâche | Action | Validation |
|---|-------|--------|-----------|
| 2.1 | Fusionner Agent Registry (Markdown) + Agent Canon + AI Lab Agent definitions → IdentityCore CANNoNICO | Un seul fichier d'identité agent | Aucun registre agent séparé |
| 2.2 | Fusionner Model Registry (Markdown) + Model definitions + Provider definitions → KnowledgeCore CANNoNICO | Un seul fichier de connaissance modèle | Aucun registre modèle séparé |
| 2.3 | Fusionner Capability Registry + CapabilityBroker + Router classification → IdentityCore CANNoNICO | Un seul fichier de capabilities | Aucun registry capability séparé |
| 2.4 | Fusionner Plugin Registry + Plugin SDK Spec → IdentityCore CANNoNICO | Un seul fichier de plugins | Aucun registry plugin séparé |
| 2.5 | Fusionner Master Registry JSON → Single CANNoNICO Registry | Un seul JSON de registre canonique | Aucun registre JSON séparé |
| 2.6 | Fusionner Master Manifest JSON → Single CANNoNICO Manifest | Un seul JSON de manifest canonique | Aucun manifest JSON séparé |
| 2.7 | Fusionner ADR Registry → CANNoNICO DecisionCore | ADR intégrés dans CANNoNICO | Aucun registre ADR séparé |
| 2.8 | Fusionner Governance Registry → CANNoNICO Governance Core | Governance intégrée dans CANNoNICO | Aucun registry governance séparé |

### Phase 3 : Suppression des Duplicatas (J+60 → J+90)

| # | Tâche | Action | Validation |
|---|-------|--------|-----------|
| 3.1 | Supprimer la couche Adapters ad hoc (NicoAppAdapter, PucheroMemoryAdapter, VideoSwapAdapter) | Remplacer par un seul CANNoNICO Adapter générique | Un seul adapter, un seul type CAnnoNicoAdapter |
| 3.2 | Supprimer les Providers ad hoc (SUPRAOllamaProvider, SUPRAOpenAIProvider, etc.) | Remplacer par un seul CANNoNICO Provider paramétré | Un seul provider, paramétré par capability |
| 3.3 | Supprimer la duplication State (`MissionStatus`, `RuntimeState`, `SnapshotState`, `ExecutionState`) | Remplacer par StateCore CANNoNICO | Un seul `CAN_STATE` |
| 3.4 | Supprimer la duplication Event (`RuntimeEvent`, `SUPRARuntimeEvents`, `RuntimeEventSource`) | Remplacer par CAN_EVENT CANNoNICO | Un seul événement système |
| 3.5 | Supprimer la duplication Memory (`MultiMemoryStore`, `ConversationMemoryStore`, `ExecutiveMemory`) | Remplacer par MemoryCore CANNoNICO | Un seul store mémoire |
| 3.6 | Supprimer la duplication Registry (Master Registry, Agent Registry, Model Registry, etc.) | Remplacer par IdentityCore CANNoNICO | Un seul registre canonique |
| 3.7 | Supprimer les timestamps système dispersés | Remplacer par NAMBROCAHORA | Aucun `Date` dans le Runtime |

### Phase 4 : Intégration TUV5 (J+90 → J+120)

| # | Tâche | Action | Validation |
|---|-------|--------|-----------|
| 4.1 | Intégrer TUV5 comme entry point unique de toute connaissance | TUV5 est le seul point d'entrée pour la compilation de connaissance | Aucune connaissance contournant TUV5 |
| 4.2 | Connecter TUV5 à CANNoNICO | TUV5 produit du CANNoNICO | Le Runtime consomme uniquement du CANNoNICO |
| 4.3 | Connecter TUV5 à NAMBROCAHORA | TUV5 utilise NAMBROCAHORA pour tous ses timestamps | Aucun `Date` dans TUV5 |
| 4.4 | Connecter TUV5 au Projection Engine | TUV5 déclenche la projection après compilation | Les projections sont automatiques |
| 4.5 | Connecter le Runtime à TUV5 | Le Runtime demande la compilation via TUV5 avant toute opération | Aucune opération Runtime sans TUV5 |

### Phase 5 : Conformité aux Lois (J+120 → J+150)

| Loi | Vérification | Moyen |
|-----|-------------|-------|
| Loi 1 : La connaissance > les fichiers | Vérifier que TUV5 compile toute connaissance avant utilisation | Audit TUV5 |
| Loi 2 : Runtime raisonne en CANNoNICO | Vérifier que le Runtime ne contient aucune référence directe à Swift/JSON/Bash/MD | Analyse statique du code |
| Loi 3 : Runtime synchronise en NAMBROCAHORA | Vérifier qu'aucun `Date()` reste dans le Runtime | Analyse statique + tests |
| Loi 4 : TUV5 transforme complexité → connaissance | Vérifier que TUV5 a bien 6 étapes et 16 sources | Audit TUV5 |
| Loi 5 : Nouvelles capacités enrichissent le Runtime | Vérifier que toute nouvelle capacité ajoute une CANNoNICO entity | Review des PR |

### Phase 6 : Validation Finale (J+150 → J+180)

| # | Tâche | Validation |
|---|-------|-----------|
| 6.1 | Lancer le SUPRA Execution Gate re-vérifié sur l'architecture cible | Gate score 1.00 |
| 6.2 | Vérifier la cohérence cross-document de tous les 7 livrables | Aucune contradiction |
| 6.3 | Vérifier que les 7 primitives CANNoNICO sont suffisantes | Tout le codebase se ramène aux 14 primitives |
| 6.4 | Vérifier que NAMBROCAHORA est la référence temporelle unique | Aucun `Date` dans le Runtime |
| 6.5 | Vérifier que CANNoNICO est la représentation unique du Runtime | Le Runtime ne raisonne que sur CANNoNICO |
| 6.6 | Vérifier que TUV5 est le seul entry point de connaissance | Aucune connaissance non compilée |
| 6.7 | Vérifier la Projection Engine fonctionne pour tous les formats | Swift/JSON/Bash/MD/UI/API |
| 6.8 | Vérifier la migration peut être inversée (réversibilité) | Rollback plan validé |

---

## 3. JALONS DE CONFORMITÉ

### 3.1 Jalon J+0 : Fondations Documentaires
- [x] SEMANTIC_CANONICAL_MAP.md
- [x] TUV5_KNOWLEDGE_COMPILER.md
- [x] CANNoNICO_FOUNDATION.md
- [x] CANNoNICO_PRIMITIVES.md
- [x] NAMBROCAHORA_FOUNDATION.md
- [x] RUNTIME_CANONICAL_MODEL.md
- [x] MIGRATION_PLAN.md

### 3.2 Jalon J+30 : Temps Canonique
- [ ] NAMBROCAHORA.swift créé et compilé
- [ ] Zéro `Date` dans CAnnoNicoSnapshotStore
- [ ] Zéro `Date` dans Snapshot
- [ ] Zéro `Date` dans SUPRARuntimeEvents

### 3.3 Jalon J+60 : Identités Canoniques
- [ ] CANNoNICO.swift créé et compilé
- [ ] Zéro `UUID` pour les identifiants système
- [ ] Tous les registres fusionnés en IdentityCore CANNoNICO

### 3.4 Jalon J+90 : Connaissance Canonique
- [ ] TUV5.swift créé et compilé
- [ ] TUV5 est le seul entry point de connaissance
- [ ] Zéro connaissance contournant TUV5

### 3.5 Jalon J+120 : Runtime Canonique
- [ ] Le Runtime ne contient aucune référence directe à Swift/JSON/Bash/MD
- [ ] Le Runtime ne contient aucun `Date` système
- [ ] Le Runtime ne contient aucun UUID système

### 3.6 Jalon J+150 : Conformité aux 5 Lois
- [ ] Loi 1 : Vérifiée (TUV5 compilatif)
- [ ] Loi 2 : Vérifiée (Runtime CANNoNICO-only)
- [ ] Loi 3 : Vérifiée (NAMBROCAHORA-only)
- [ ] Loi 4 : Vérifiée (TUV5 cycle complet)
- [ ] Loi 5 : Vérifiée (aucune couche ajoutée)

### 3.7 Jalon J+180 : Validation Finale
- [ ] Execution Gate re-vérifié : 1.00
- [ ] Cohérence cross-document vérifiée
- [ ] Réversibilité validée

---

## 4. RISQUES ET MITIGATIONS

| Risque | Impact | Probabilité | Mitigation |
|--------|--------|-------------|-----------|
| Régression temporelle lors de la migration Date→NAMBROCAHORA | Élevé | Moyen | Migration incrémentale + rollback plan |
| Perte de données lors de la fusion des registres | Élevé | Faible | Mapping exhaustif + validation TUV5 |
| Incompatibilité avec les systèmes externes | Moyen | Moyen | Projection Engine maintient la compatibilité |
| Rétention de `Date` dans du code non migré | Élevé | Élevé | Analyse statique automatisée à chaque phase |
| Complexité excessive des primitives CANNoNICO | Moyen | Faible | 14 primitives exactement — minimalité vérifiée |
| Refus de l'équipe de migrationner | Faible | Faible | Chaque phase est additive, non destructrice |

---

## 5. RÉVERSIBILITÉ

Chaque phase de migration est réversible :

| Phase | Réversal | Mécanisme |
|-------|----------|-----------|
| Phase 0 | Aucun code modifié | Réversible par défaut |
| Phase 1 | Champs Date→tick ajoutés, pas supprimés | Les anciens champs restent jusqu'à J+30 |
| Phase 2 | Registres fusionnés dans IdentityCore, anciens registres archivés | Archivage ZIP, pas suppression |
| Phase 3 | Adapters/Providers/States doublons archivés | Archivage ZIP, pas suppression |
| Phase 4 | TUV5 ajouté en parallèle, TUV5 existant conservé | Les deux coexistent |
| Phase 5 | Conformité vérifiée, ancien code marqué OBSOLETE | Marquage, pas suppression |
| Phase 6 | Gate de validation, rollback si échec | Rollback vers J+0 |

---

## 6. TABLEAU DE BORD DE MIGRATION

### 6.1 Métriques de Progression

| Métrique | Cible | Actuel | Phase |
|----------|-------|--------|-------|
| `Date` dans Runtime | 0 | ? | Phase 1 |
| `UUID` dans événements système | 0 | ? | Phase 1 |
| Entrées TUV5 (sources compilées) | 16+ | 0 | Phase 4 |
| CANNoNICO entities actives | 14+ | 0 | Phase 2 |
| NAMBROCAHORA ticks générés/jour | >0 | 0 | Phase 1 |
| Registres dupliqués | 0 | 6+ | Phase 2 |
| Couches de Runtime | 4 | 6+ | Phase 3 |
| Gates de conformité passés | 7/7 | 7/7 (Phase 0) | Phase 6 |

### 6.2 Critères d'Acceptation par Phase

| Phase | Critère d'Acceptation |
|-------|------------------------|
| Phase 0 | Les 7 livrables existent, sont validés, et accessibles |
| Phase 1 | NAMBROCAHORA.swift compile, les `Date` sont migrés dans les fichiers cibles |
| Phase 2 | Tous les registres sont fusionnés, un seul IdentityCore CANNoNICO |
| Phase 3 | Les duplicatas sont archivés, 4 couches Runtime |
| Phase 4 | TUV5 compile la connaissance vers CANNoNICO |
| Phase 5 | Les 5 lois sont conformes |
| Phase 6 | Execution Gate 1.00, cohérence vérifiée, réversibilité validée |

---

## 7. PRÉ-REQUIS À AUCUNE IMPLÉMENTATION MAJEURE

Conformément à la mission, aucune implémentation majeure ne doit commencer avant que :

| Condition | Status |
|-----------|--------|
| Architecture de manière argumentée et vérifiable | ✅ Vérifié |
| Les 7 livrables produits | ✅ Livrés |
| L'audit exhaustif mené | ✅ Complété |
| Les primitives universelles déterminées | ✅ 7 déterminées |
| Les doublons identifiés | ✅ 18 identifiés |
| Les responsabilités à fusionner listées | ✅ 5 fusions |
| Les couches à disparaître identifiées | ✅ 4 couches |
| Les représentations CANNoNICO identifiées | ✅ 8 devenant CANNoNICO |
| Les éléments NAMBROCAHORA identifiés | ✅ 20+ entités |
| La réponse à la question finale | ✅ Documentée dans les 7 livrables |

---

*Migration Plan V1 — SUPRA ULTIMATE CONSOLIDATED*
*Audit exécuté le 2026-07-29*
*Prochaine étape : Phase 1 — Temps Canonique (NAMBROCAHORA.swift)*
