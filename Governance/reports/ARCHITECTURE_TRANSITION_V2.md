# ARCHITECTURE_TRANSITION_V2.md — Validation et Consolidation

| Propriété | Valeur |
|---|---|
| **Document** | Architecture Transition V2 |
| **Date** | 2026-07-29 |
| **Statut** | LIVRABLE DE VALIDATION |
| **Autorité** | SUPRA Constitution — Article 2 |
| **Référence** | ARCHITECTURE_TRANSITION_V1.md (validation) |
| **Loi applicable** | Knowledge First, Canon Before Code, One Concept One Canonical Definition Many Projections |

---

## 1. RÉSUMÉ EXÉCUTIF

### 1.1 Réponse à la Question Stratégique

**L'architecture actuelle permet-elle de faire de SUPRA un système où la connaissance est la mémoire durable et où les artefacts techniques ne sont que des projections gouvernées ?**

**Réponse : OUI, théoriquement. NON, en pratique.**

Le modèle V1 est conceptuellement solide. Les fondations CANNoNICO, TUV5, NAMBROCAHORA et la structure à 4 facultés forment un cadre cohérent. Cependant, l'écart entre le modèle théorique et l'implémentation actuelle est considérable et empêche le système d'atteindre son objectif. Les artefacts techniques (JSON, Swift, Markdown) sont encore traités comme des sources de vérité indépendantes dans la pratique, et non comme des projections du modèle canonique.

Avant toute implémentation majeure, les changements conceptuels suivants sont nécessaires :

1. **Implémenter le pipeline TUV5** — sans lui, la compilation de la connaissance brute en CANNoNICO n'existe pas. La connaissance reste fragmentée entre les fichiers sources.
2. **Implémenter le Projection Engine** — sans lui, les artefacts sont écrits manuellement et ne sont pas traçables vers CANNoNICO.
3. **Implémenter le PUCHERO Knowledge Maturation Engine** — sans lui, la maturation de la connaissance est distribuée et non coordonnée.
4. **Unifier les mémoires** sous CANNoNICO.MEMORY_CORE — 4 stores actuellement fragmentés.
5. **Intégrer NAMBROCAHORA au Runtime** — les timestamps système restent dans les modèles Swift.
6. **Consolider les registres dupliqués** sous CANNoNICO.IDENTITY_CORE — 8+ fichiers JSON redondants.

---

## 2. MISSION FONDAMENTALE

### 2.1 Mission Directrice Unique

**SUPRA est un système cognitif gouverné dont la mission est de transformer la connaissance brute en connaissance canonique, puis de projeter cette connaissance canonique en artefacts techniques exécutables.**

Formulation canonique :
> Connaissance brute → TUV5 → CANNoNICO → Runtime → Projections

### 2.2 Dérivation des Sous-Missions

| Sous-Mission | Dérivation | Faculté |
|---|---|---|
| Ingestion des sources | Étape 1 de la transformation (TUV5) | TUV5 |
| Maturité de la connaissance | Condition de passage vers la canonisation (PUCHERO) | PUCHERO |
| Représentation canonique | Produit de la transformation (CANNoNICO) | CANNoNICO |
| Exécution et action | Application de la connaissance canonique (Runtime) | RUNTIME |
| Gouvernance | Contrôle de la qualité de la transformation (CANNoNICO) | CANNoNICO |
| Projection technique | Distribution de la connaissance aux consommateurs (RUNTIME) | RUNTIME + CANNoNICO |

Toutes les sous-missions dérivent de la mission directrice. Il n'existe pas de mission autonome.

---

## 3. FACULTÉS — VALIDATION

### 3.1 Les Quatre Facultés Sont-elles Suffisantes ?

**Oui.** Les quatre facultés actuelles sont suffisantes pour couvrir le cycle complet de vie de la connaissance dans SUPRA.

| Faculté | Rôle dans le cycle | Justification |
|---|---|---|
| **TUV5 — COMPRENDRE** | Ingestion et compilation de la connaissance brute | Sans ingestion, pas de connaissance à traiter. C'est l'entrée du système. |
| **PUCHERO — MÛRIR** | Confrontation, consolidation, détection de contradictions, enrichissement | Sans maturation, la connaissance incohérente serait canonisée. C'est le filtre qualité. |
| **CANNoNICO — CANONISER** | Représentation unique et officielle de la connaissance | Sans canon, chaque composant serait une source de vérité indépendante. C'est le cœur du système. |
| **RUNTIME — EXÉCUTER** | Orchestration, décision, exécution, projection | Sans exécution, la connaissance canonique resterait statique. C'est le moteur d'action. |

### 3.2 Une Cinquième Faculté est-elle Nécessaire ?

**Non.** Une cinquième faculté (apprentissage, adaptation) n'est pas nécessaire car elle émerge naturellement du cycle des quatre facultés existantes :

```
TUV5 compile → CANNoNICO stocke → PUCHERO évalue → RUNTIME exécute →
Résultats d'exécution retournent dans TUV5 comme nouvelles sources → cycle recommence
```

Ce feedback loop constitue le mécanisme d'apprentissage. L'EvolutionEngine et l'IntelligenceEngine (actuellement classés en PUCHERO) sont les implémentations de ce feedback.

**Conclusion :** L'apprentissage n'est pas une faculté distincte — c'est une propriété émergente du cycle TUV5 → PUCHERO → CANNoNICO → RUNTIME → TUV5.

---

## 4. CAPACITÉS — VALIDATION

### 4.1 Justification de Chaque Capacité

#### TUV5 — COMPRENDRE (8 capacités)

| Capacité | Justifiée ? | Non redondante ? | Faculté rattachée | Notes |
|---|---|---|---|---|
| TUV5.INGESTION | ✅ | ✅ | TUV5 | Entrée unique pour toute connaissance brute |
| TUV5.EXTRACTION | ✅ | ✅ | TUV5 | Extraction de concepts, entités, relations |
| TUV5.FUSION | ✅ | ✅ | TUV5 | Fusion de concepts équivalents — distincte de EXTRACTION |
| TUV5.NORMALIZATION | ✅ | ✅ | TUV5 | Alignement ontologique + NAMBROCAHORA |
| TUV5.VALIDATION | ✅ | ✅ | TUV5 | Intégrité structurale + contraintes |
| TUV5.COMPILATION | ✅ | ✅ | TUV5 | Intégration dans le graphe canonique |
| TUV5.PUBLICATION | ✅ | ✅ | TUV5 | Persistance + génération de projections |
| TUV5.PROJECTION | ⚠️ | ⚠️ | TUV5 | **AMBIGUÏTÉ** — Voir section 4.3 |

#### PUCHERO — MÛRIR (8 capacités)

| Capacité | Justifiée ? | Non redondante ? | Faculté rattachée | Notes |
|---|---|---|---|---|
| PUCHERO.CONFRONTATION | ✅ | ✅ | PUCHERO | Confrontation de sources multiples |
| PUCHERO.CONSOLIDATION | ✅ | ✅ | PUCHERO | Fusion de connaissances partielles |
| PUCHERO.CONTRADICTION_DETECTION | ✅ | ✅ | PUCHERO | Détection de contradictions logiques |
| PUCHERO.EVIDENCE_ACCUMULATION | ✅ | ✅ | PUCHERO | Accumulation de preuves |
| PUCHERO.COHERENCE_SCORING | ✅ | ✅ | PUCHERO | Score de cohérence par concept |
| PUCHERO.ENRICHMENT | ✅ | ✅ | PUCHERO | Enrichissement progressif |
| PUCHERO.MATURITY_GATE | ✅ | ✅ | PUCHERO | Verrouillage de maturité |
| PUCHERO.REPAIR | ✅ | ✅ | PUCHERO | Correction de concepts incohérents |

#### CANNoNICO — CANONISER (10 capacités)

| Capacité | Justifiée ? | Non redondante ? | Faculté rattachée | Notes |
|---|---|---|---|---|
| CANNoNICO.IDENTITY_CORE | ✅ | ✅ | CANNoNICO | Identités canoniques (can::<type>::<sha256>) |
| CANNoNICO.KNOWLEDGE_CORE | ✅ | ✅ | CANNoNICO | Connaissance structurée compilée |
| CANNoNICO.RELATION_CORE | ✅ | ✅ | CANNoNICO | Arcs dirigés entre identités |
| CANNoNICO.TEMPORAL_CORE | ✅ | ✅ | CANNoNICO | Temps canonique NAMBROCAHORA |
| CANNoNICO.DECISION_CORE | ✅ | ✅ | CANNoNICO | Décisions documentées |
| CANNoNICO.STATE_CORE | ✅ | ✅ | CANNoNICO | États et transitions |
| CANNoNICO.CONSTRAINT_CORE | ✅ | ✅ | CANNoNICO | Contraintes actives |
| CANNoNICO.MEMORY_CORE | ✅ | ✅ | CANNoNICO | Mémoire unifiée |
| CANNoNICO.GOVERNANCE_CORE | ✅ | ✅ | CANNoNICO | Gouvernance unifiée |
| CANNoNICO.PROJECTION_ENGINE | ✅ | ✅ | CANNoNICO | Versions projections |

#### RUNTIME — EXÉCUTER (10 capacités)

| Capacité | Justifiée ? | Non redondante ? | Faculté rattachée | Notes |
|---|---|---|---|---|
| RUNTIME.ORCHESTRATION | ✅ | ✅ | RUNTIME | Ordonnancement des tâches |
| RUNTIME.MISSION_EXECUTION | ✅ | ✅ | RUNTIME | Cycle de vie des missions |
| RUNTIME.WORKFLOW_ENGINE | ✅ | ✅ | RUNTIME | DAG + parallélisation |
| RUNTIME.TASK_EXECUTION | ✅ | ✅ | RUNTIME | Tâches atomiques |
| RUNTIME.DECISION_ENGINE | ⚠️ | ⚠️ | RUNTIME | **AMBIGUÏTÉ** — Voir section 4.3 |
| RUNTIME.PROJECTION | ⚠️ | ⚠️ | RUNTIME | **AMBIGUÏTÉ** — Voir section 4.3 |
| RUNTIME.SYNC | ✅ | ✅ | RUNTIME | Synchronisation projections ↔ CANNoNICO |
| RUNTIME.PROVIDER_BRIDGE | ✅ | ✅ | RUNTIME | Pont vers providers IA |
| RUNTIME.CONNECTOR | ✅ | ✅ | RUNTIME | Connexion systèmes externes |
| RUNTIME.OBSERVABILITY | ✅ | ✅ | RUNTIME | Métriques, events, logging |

### 4.2 Ambiguïtés Identifiées

#### Ambiguïté A : TUV5.PROJECTION vs RUNTIME.PROJECTION

**Problème :** Les deux capacités portent le nom "PROJECTION" mais ont des rôles différents.

- **TUV5.PROJECTION** : Génère des projections du modèle canonique vers des formats intermédiaires (étape de compilation)
- **RUNTIME.PROJECTION** : Génère des artefacts techniques finaux (Swift, JSON, Bash, UI) à partir des décisions runtime

**Résolution V2 :** Renommer pour clarifier :
- TUV5.PROJECTION → **TUV5.COMPILATION_PROJECTION** (projections intermédiaires de compilation)
- RUNTIME.PROJECTION → **RUNTIME.ARTIFACT_PROJECTION** (projections finales vers formats techniques)

#### Ambiguïté B : RUNTIME.DECISION_ENGINE vs CANNoNICO.DECISION_CORE

**Problème :** RUNTIME.DECISION_EVALUATE produit des décisions, et CANNoNICO.DECISION_CORE les représente. Confusion sur la frontière entre exécution et représentation.

**Résolution V2 :** Clarifier le rôle de chacun :
- **RUNTIME.DECISION_ENGINE** : Évalue des propositions, produit des verdicts — c'est un mécanisme d'exécution
- **CANNoNICO.DECISION_CORE** : Représente les décisions en tant qu'entités CANNoNICO — c'est le modèle canonique

La relation est : RUNTIME.DECISION_ENGINE produit des données que CANNoNICO.DECISION_CORE représente.

### 4.3 Capacités Redondantes ou Fusionnables

| # | Redondance | Composants Impliqués | Action V2 |
|---|---|---|---|
| V2-R1 | TUV5.PROJECTION et RUNTIME.PROJECTION | TUV5.8 + RUNTIME.6 | Fusionner en une seule capacité : déplacer RUNTIME.PROJECTION vers CANNoNICO.PROJECTION_ENGINE (qui existe déjà) |
| V2-R2 | RUNTIME.DECISION_ENGINE et CANNoNICO.DECISION_CORE | RUNTIME.5 + CANNoNICO.5 | Clarifier la frontière ; aucune fusion, mais documentation de la relation parent/enfant |
| V2-R3 | TUV5.VALIDATION et PUCHERO.CONTRADICTION_DETECTION | TUV5.5 + PUCHERO.3 | Partiellement redondantes ; TUV5.VAL fait de la validation structurelle, PUCHERO.CD de la détection sémantique — maintenir séparées mais documenter la distinction |

**Total des capacités après consolidation :** 34 (réduction de 36 à 34)

---

## 5. SERVICES RUNTIME — VALIDATION

### 5.1 Mapping Service → Capacité → Faculté

| Service | Capacité(s) | Faculté | Justification | Conforme ? |
|---|---|---|---|---|
| Workspace | RUNTIME.ORCHESTRATION, RUNTIME.ARTIFACT_PROJECTION | RUNTIME | Organise les artefacts comme projections du modèle canonique | ✅ |
| Storage | TUV5.INGESTION, TUV5.FUSION | TUV5 | Surveille le FS et détecte les doublons — fonction d'ingestion | ✅ |
| Provider | RUNTIME.PROVIDER_BRIDGE | RUNTIME | Inventorie les providers IA | ✅ |
| Build | RUNTIME.WORKFLOW_ENGINE, RUNTIME.TASK_EXECUTION | RUNTIME | Centralise les builds — exécution de workflow | ✅ |
| Diagnostics | PUCHERO.CONFRONTATION, PUCHERO.CONTRADICTION_DETECTION, PUCHERO.REPAIR | PUCHERO | Diagnostique les anomalies du système comme connaissance | ✅ |
| Health | RUNTIME.OBSERVABILITY | RUNTIME | Mesure l'état global | ✅ |
| Snapshot | CANNoNICO.STATE_CORE, CANNoNICO.TEMPORAL_CORE | CANNoNICO | Snapshots avec cohérence temporelle | ✅ |
| Recovery | RUNTIME.ORCHESTRATION, RUNTIME.MISSION_EXECUTION | RUNTIME | Orchestration de récupération | ✅ |
| Governance | CANNoNICO.GOVERNANCE_CORE | CANNoNICO | Politiques et conformité | ✅ |

### 5.2 Violations de Frontière détectées

| # | Service | Problème | Action V2 |
|---|---|---|---|
| S1 | Storage | Accède directement aux fichiers — ne passe pas par CANNoNICO | Storage doit ingérer via TUV5, pas lire les fichiers directement |
| S2 | Health | Métriques utilisent des timestamps système | Migrer vers NAMBROCAHORA |
| S3 | Snapshot | Certains snapshots stockent des Date() système | Migrer vers NAMBROCAHORA |
| S4 | Build | Le build produit des artefacts qui ne sont pas des projections CANNoNICO | Le build doit projeter depuis CANNoNICO, pas produire des fichiers ad hoc |

---

## 6. CANONICAL KNOWLEDGE GRAPH — V1

### 6.1 Structure Minimale du Canonical Knowledge Graph

Le CKG V1 est défini par les 7 dimensions suivantes :

#### 6.1.1 Identité
| Élément | Format | Exemple |
|---|---|---|
| CAN_ID | `can:<type>:<sha256>` | `can:agent:a1b2c3...` |
| CAN_TYPE | Nom du type canonique | `agent`, `knowledge`, `decision`, `constraint` |
| CAN_VERSION | Version sémantique | `V1`, `V2` |
| CAN_NAME | Nom lisible | `SUPRA-Builder` |

#### 6.1.2 Concepts
Les concepts CANNoNICO sont les entités fondamentales du graphe :

| Domaine | Préfixe | Description |
|---|---|---|
| Identity | `can:identity:` | Définitions d'entités |
| Relation | `can:relation:` | Liens entre entités |
| Capability | `can:capability:` | Compétences mesurables |
| Event | `can:event:` | Occurrences immutables |
| Knowledge | `can:knowledge:` | Connaissance structurée compilée |
| Decision | `can:decision:` | Choix documentés |
| Time | `can:time:` | Référence NAMBROCAHORA |
| Constraint | `can:constraint:` | Règles et limites |
| Evidence | `can:evidence:` | Preuves et chaînes de justification |
| Projection | `can:projection:` | Vues dérivées |

#### 6.1.3 Relations
| Relation Type | Direction | Sémantique |
|---|---|---|
| `depends_on` | A → B | A dépend de B |
| `uses` | A → B | A utilise B |
| `produces` | A → B | A produit B |
| `constrains` | A → B | A limite B |
| `projects_to` | CANNoNICO → Format | CANNoNICO se projette vers ce format |
| `compiles_from` | CANNoNICO ← Source | CANNoNICODE dérive de cette source TUV5 |
| `references` | A → B | A référence B |
| `precedes` | A → B | A précède B dans le temps |
| `causes` | A → B | A cause B |
| `validates` | A → B | A prouve B |

#### 6.1.4 Responsabilités
Chaque nœud CANNoNICO a une responsabilité attribuée :

| Domaine | Responsabilité | Faculté | Capacité |
|---|---|---|---|
| Identity | Génération et résolution d'identités | CANNoNICO | IDENTITY_CORE |
| Knowledge | Stockage et compilation de la connaissance | TUV5 + CANNoNICO | EXTRACTION/FUSION + KNOWLEDGE_CORE |
| Relation | Gestion des arcs dirigés | CANNoNICO | RELATION_CORE |
| Temporal |Fourniture du temps canonique | CANNoNICO + TUV5 | TEMPORAL_CORE + NORMALIZATION |
| Decision | Prise de décision documentée | CANNoNICO + RUNTIME | DECISION_CORE + DECISION_ENGINE |
| State | Gestion des états et transitions | CANNoNICO + RUNTIME | STATE_CORE + ORCHESTRATION |
| Constraint | Validation des contraintes | CANNoNICO | CONSTRAINT_CORE |
| Evidence | Chaînes de preuve | PUCHERO + CANNoNICO | EVIDENCE_ACCUMULATION + EVIDENCE |
| Memory | Mémoire unifiée | CANNoNICO | MEMORY_CORE |
| Governance | Application des règles | CANNoNICO | GOVERNANCE_CORE |
| Projection | Génération des artefacts | CANNoNICO + RUNTIME | PROJECTION_ENGINE + ARTIFACT_PROJECTION |

#### 6.1.5 Preuves
Structure de la chaîne de preuve :

```
TUV5 Compilation (source, step, timestamp=NAMBROCAHORA_tick)
  → produit une preuve can:evidence:<sha256>
    → référencée par CANNoNICO entities via can:validates
      → chaînable de la source brute jusqu'à la projection finale
```

Chaque décision CANNoNICO doit référencer au minimum une preuve can:evidence.
Chaque projection doit référencer la décision CANNoNICO qui l'a générée.

#### 6.1.6 Contraintes
| ID | Contrainte | Source |
|---|---|---|
| CKG-01 | Tout nœud doit avoir un CAN_ID valide | CANNoNICO.IDENTITY_CORE |
| CKG-02 | Tout arc doit référencer des nœuds existants | CANNoNICO.RELATION_CORE |
| CKG-03 | Tout timestamp doit être un NAMBROCAHORA tick | NAMBROCAHORA |
| CKG-04 | Toute décision doit référencer une preuve | CANNoNICO.DECISION_CORE |
| CKG-05 | Toute projection doit référencer son entité CANNoNICO source | CANNoNICO.PROJECTION_ENGINE |
| CKG-06 | Aucun fichier ne peut être source de vérité autonome | Loi 1 (Connaissance > fichiers) |
| CKG-07 | Le CANNoNICO seul peut être modifié par TUV5 | Loi 2 (Runtime en CANNoNICO) |
| CKG-08 | Les projections ne peuvent jamais modifier le CANNoNICO | Loi 3 (Projection-only) |
| CKG-09 | Chaque entité a un unique propriétaire | NN-09 |
| CKG-10 | Aucune suppression irréversible | NN-08 |

#### 6.1.7 Historique
L'historique du CKG est représenté par :
- **Les events CANNoNICO** : chaque changement d'état est un `can:event` avec un tick NAMBROCAHORA
- **Les transitions CANNoNICO.STATE_CORE** : chaque changement d'état est tracé avec from_state, to_state, tick, preuve
- **Les versions CANNoNICO.KNOWLEDGE_CORE** : chaque compilation TUV5 incrémente un CAN_VERSION

#### 6.1.8 Référence Temporelle NAMBROCAHORA
- Type : INT64
- Comportement : monotone croissant, logique (pas physique)
- Premier tick : 0
- Incrément : +1 par événement CANNoNICO
- Règles :
  - C-NAMBRO-01 : Le tick ne doit jamais reculer
  - C-NAMBRO-02 : Stockage en INT64 uniquement (jamais string en interne)
  - C-NAMBRO-03 : Conversion tick→ISO8601 bijective
  - C-NAMBRO-04 : Persistance du tick final entre redémarrages
  - C-NAMBRO-05 : Unicité garantie par avancement monotone
  - C-NAMBRO-06 : Ticks de publication TUV5 consécutifs (pas de gaps)
  - C-NAMBRO-07 : tick=0 réservé à l'initialisation

---

## 7. PROJECTIONS — VALIDATION

### 7.1 Vérification : Chaque Artefact est-il une Projection ?

| Artefact | Type | Est une projection ? | Statut V2 |
|---|---|---|---|
| `knowledge_graph.json` | JSON | ❌ Non — traité comme source de vérité | **À migrer** vers projection de CANNoNICO.KNOWLEDGE_CORE |
| `knowledge_identity.json` | JSON | ❌ Non — source de vérité | **À migrer** vers projection de CANNoNICO.IDENTITY_CORE |
| `knowledge_relations.json` | JSON | ❌ Non — source de vérité | **À migrer** vers projection de CANNoNICO.RELATION_CORE |
| `CANONICAL_RUNTIME.json` | JSON | ⚠️ Partiellement | **À migrer** — doit être régénéré depuis CANNoNICO |
| `CANONICAL_REGISTRY.json` | JSON | ⚠️ Partiellement | **À consolider** — registre unique, projection de CANNoNICO.IDENTITY_CORE |
| `CANONICAL_SERVICES.json` | JSON | ❌ Redondant | **À déprécier** — absorber dans CANONICAL_REGISTRY.json |
| `*.swift` | Code | ⚠️ Partiellement | Certains fichiers sont des projections; d'autres modélisent directement des concepts — **à réécrire** pour être des projections du CANNoNICO |
| `*.md` | Documentation | ✅ Oui (théoriquement) | En pratique, beaucoup de .md sont des sources de vérité elles-mêmes — **doivent devenir des projections** |
| `*.sh` | Bash | ✅ Oui | Scripts comme projections de workflows CANNoNICO |
| `SUPRA_*.json` (traces, metrics) | JSON | ⚠️ Partiellement | Contiennent encore des Date() et timestamps système — **doivent utiliser NAMBROCAHORA** |
| SwiftUI Views | UI | ✅ Oui | Projections CANNoNICO vers l'interface utilisateur |
| CANNoNICO primitives | Swift | ✅ Oui | Implémentations canoniques, pas des projections — c'est le modèle lui-même |

### 7.2 Problèmes Critiques de Projection

| # | Problème | Gravité | Action V2 |
|---|---|---|---|
| P1 | knowledge_graph.json est une source de vérité autonome | CRITIQUE | Supprimer. Le CANNoNICO.KNOWLEDGE_CORE est la seule source. Regénérer le JSON via projection. |
| P2 | Les fichiers JSON CANONICAL_* sont mis à jour manuellement | CRITIQUE | Tout JSON doit être régénéré par le Projection Engine depuis CANNoNICO |
| P3 | Les Swift files contiennent des modèles qui ne sont pas des projections CANNoNICO | ÉLEVÉE | Réécrire les modèles Swift pour qu'ils soient des projections du CANNoNICO runtime |
| P4 | NAMBROCAHORA n'est pas intégré dans les modèles Runtime Swift | ÉLEVÉE | Migrer tous les Date() système vers NAMBROCAHORA tick |
| P5 | Les .md sont modifiés manuellement comme sources de vérité | MOYENNE | Tout .md doit être auto-généré depuis le CANNoNICO via Projection Engine |

---

## 8. ARCHITECTURE V2 CONSOLIDÉE

### 8.1 Structure V2

```
┌─────────────────────────────────────────────────────────────────┐
│                    SUPRA ARCHITECTURE V2                          │
│                     Système Cognitif Gouverné                     │
│                                                                    │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │  FACULTÉ 1 — TUV5 — COMPRENDRE                            │ │
│  │  ├── INGESTION (parse sources hétérogènes)                │ │
│  │  ├── EXTRACTION (extraire concepts/entités/relations)     │ │
│  │  ├── FUSION (fusionner concepts équivalents)              │ │
│  │  ├── NORMALIZATION (aligner ontologie + NAMBROCAHORA)     │ │
│  │  ├── VALIDATION (intégrité + contraintes)                 │ │
│  │  ├── COMPILATION (intégrer dans le graphe canonique)      │ │
│  │  ├── PUBLICATION (persister + projeter)                   │ │
│  │  └── COMPILATION_PROJECTION (projections intermédiaires)  │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                          │                                       │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │  FACULTÉ 2 — PUCHERO — MÛRIR                              │ │
│  │  ├── CONFRONTATION (sources multiples)                    │ │
│  │  ├── CONSOLIDATION (connaissances partielles → cohérentes)│ │
│  │  ├── CONTRADICTION_DETECTION (divergences logiques)       │ │
│  │  ├── EVIDENCE_ACCUMULATION (preuves supporting/refuting)   │ │
│  │  ├── COHERENCE_SCORING (score par concept)                │ │
│  │  ├── ENRICHMENT (ajout relations/contraintes)             │ │
│  │  ├── MATURITY_GATE (verrouillage de maturité)             │ │
│  │  └── REPAIR (corrections minimales)                       │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                          │                                       │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │  FACULTÉ 3 — CANNoNICO — CANONISER                        │ │
│  │  ├── IDENTITY_CORE (can::<type>::<sha256>)                │ │
│  │  ├── KNOWLEDGE_CORE (connaissance structurée compilée)    │ │
│  │  ├── RELATION_CORE (arcs dirigés entre identités)         │ │
│  │  ├── TEMPORAL_CORE (NAMBROCAHORA ticks)                   │ │
│  │  ├── DECISION_CORE (décisions documentées)                │ │
│  │  ├── STATE_CORE (états et transitions)                    │ │
│  │  ├── CONSTRAINT_CORE (contraintes actives)                │ │
│  │  ├── MEMORY_CORE (mémoire unifiée)                        │ │
│  │  ├── GOVERNANCE_CORE (règles + principes + conformité)    │ │
│  │  └── PROJECTION_ENGINE (vers Swift/JSON/Bash/MD/UI/API)  │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                          │                                       │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │  FACULTÉ 4 — RUNTIME — EXÉCUTER                           │ │
│  │  ├── ORCHESTRATION (ordonnancement)                       │ │
│  │  ├── MISSION_EXECUTION (cycle de vie)                     │ │
│  │  ├── WORKFLOW_ENGINE (DAG + parallélisation)              │ │
│  │  ├── TASK_EXECUTION (tâches atomiques)                   │ │
│  │  ├── DECISION_ENGINE (évaluation de propositions)         │ │
│  │  ├── ARTIFACT_PROJECTION (Swift/JSON/Bash/MD/UI/API)     │ │
│  │  ├── SYNC (synchronisation projections ↔ CANNoNICO)       │ │
│  │  ├── PROVIDER_BRIDGE (connecteurs IA)                     │ │
│  │  ├── CONNECTOR (systèmes externes)                        │ │
│  │  └── OBSERVABILITY (métriques + events + logging)         │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                                                                    │
│  ─────────────────────────────────────────────────────────────   │
│  Flux unique :                                                    │
│  Connaissance brute → TUV5 → CANNoNICO → Runtime → NAMBROCAHORA│
│                             ↓                                      │
│                      PROJECTION ENGINE → Formats externes       │
│  ─────────────────────────────────────────────────────────────   │
└─────────────────────────────────────────────────────────────────┘
```

### 8.2 Changements Conceptuels V2 par rapport à V1

| # | Changement | Raison |
|---|---|---|
| V2-C1 | Renommer TUV5.PROJECTION en TUV5.COMPILATION_PROJECTION | Éliminer l'ambiguïté avec RUNTIME.PROJECTION |
| V2-C2 | Renommer RUNTIME.PROJECTION en RUNTIME.ARTIFACT_PROJECTION | Clarifier que c'est la projection finale vers formats techniques |
| V2-C3 | Déplacer RUNTIME.PROJECTION vers CANNoNICO.PROJECTION_ENGINE | Le Projection Engine est un concept CANNoNICO, pas un concept Runtime |
| V2-C4 | Clarifier RUNTIME.DECISION_ENGINE comme mécanisme d'exécution et CANNoNICO.DECISION_CORE comme modèle | Éliminer la confusion entre production et représentation de décisions |
| V2-C5 | Fusionner les 8 registres CANONICAL_* en un seul CANONICAL_REGISTRY.json | Éliminer la redondance RD1 |
| V2-C6 | Fusionner les 15+ docs CANONICO/CANNoNICO en un CANNoNICO CORE | Éliminer la redondance RD2 |
| V2-C7 | Supprimer les 3 artefacts considérés comme sources de vérité autonomes (knowledge_graph.json, knowledge_identity.json, knowledge_relations.json) | Appliquer la Loi 1 : connaissance > fichiers |

### 8.3 Simplifications V2

| # | Simplification | Avant | Après |
|---|---|---|---|
| S1 | Nombre de capacités | 36 | 34 (après fusion TUV5.PROJECTION + RUNTIME.PROJECTION) |
| S2 | Fichiers CANONICAL_* JSON | 17 | 1 (CANONICAL_REGISTRY.json) |
| S3 | Docs CANONICO/CANNoNICO | 15+ | 1 (CANNoNICO CORE avec modules thématiques) |
| S4 | Mémoires | 4 stores | 1 MemoryCore |
| S5 | Références temporelles | Date() + NAMBROCAHORA + ISO8601 | NAMBROCAHORA unique |
| S6 | Régimes d'ID | 3+ (CAN_ID + ComponentID + NUCLEO) | 1 (CAN_ID can::<type>::<sha256>) |

### 8.4 Concepts à Fusionner

| # | Concept Actuel | Fusion En | Raison |
|---|---|---|---|
| F1 | TUV5.PROJECTION + RUNTIME.PROJECTION | CANNoNICO.PROJECTION_ENGINE (avec sous-types) | Même sémantique, portée différenciée par sous-type |
| F2 | Agent Registry + Model Registry + Capability Registry + Plugin Registry | CANNoNICO.IDENTITY_CORE | Même structure : identité + type + capacités + relations |
| F3 | KnowledgeKernel + KnowledgeGraph + KnowledgeRelations + KnowledgeSources | CANNoNICO.KNOWLEDGE_CORE | Même domaine : connaissance structurée |
| F4 | RuntimeKernel + RuntimeGraph + RuntimeStatus + RuntimeMetrics + RuntimeTrace | RUNTIME.OBSERVABILITY (modèle) + CANNoNICO.STATE_CORE (état) | Le Kernel est le modèle, les autres sont des projections |
| F5 | Workflow + Pipeline + TaskGraph + ParallelGroup | RUNTIME.WORKFLOW_ENGINE | Même concept : exécution structurée |
| F6 | SUPRA-Arch + SUPRA-Builder + SUPRA-Router + SUPRA-Reviewer + SUPRA-Refactor + SUPRA-Auditor + SUPRA-Explorer + SUPRA-Research + SUPRA-Runtime | TUV5 + RUNTIME (agent pool) | Les agents SUPRA sont des projections CANNoNICO |
| F7 | MultiMemoryStore + ConversationMemoryStore + CAnnoNicoSnapshotStore + ExecutiveMemory | CANNoNICO.MEMORY_CORE | Mémoire unifiée |

### 8.5 Concepts à Supprimer

| # | Concept | Raison de suppression |
|---|---|---|
| X1 | knowledge_graph.json (fichier autonome) | DOIT être remplacé par CANNoNICO.KNOWLEDGE_CORE comme source de vérité. Le JSON est une projection. |
| X2 | knowledge_identity.json | Remplacé par CANNoNICO.IDENTITY_CORE |
| X3 | knowledge_relations.json | Remplacé par CANNoNICO.RELATION_CORE |
| X4 | knowledge_sources.json | Remplacé par TUV5 tracking (provenance via TUV5_COMPILATION_TRACE) |
| X5 | knowledge_lineage.json | Remplacé par CANNoNICO.EVIDENCE (chaîne de preuves) |
| X6 | knowledge_kernel.json (autonome) | Remplacé par CANNoNICO.KNOWLEDGE_CORE |
| X7 | knowledge_statistics.json | Remplacé par RUNTIME.OBSERVABILITY |
| X8 | knowledge_context_examples.json | Remplacé par CANNoNICO.KNOWLEDGE_CORE + Projection Engine |
| X9 | CANONICAL_SERVICES.json | Absorbé dans CANONICAL_REGISTRY.json |
| X10 | CANONICAL_WORKERS.json | Absorbé dans CANONICAL_REGISTRY.json |
| X11 | CANONICAL_PACKAGES.json | Absorbé dans CANONICAL_REGISTRY.json |
| X12 | CANONICAL_MODULES.json | Absorbé dans CANONICAL_REGISTRY.json |
| X13 | CANONICAL_BRIDGES.json | Absorbé dans CANONICAL_REGISTRY.json |
| X14 | CANONICAL_ADAPTERS.json | Absorbé dans CANONICAL_REGISTRY.json |
| X15 | CANONICAL_PROJECTS.json | Absorbé dans CANONICAL_REGISTRY.json |
| X16 | SUPRA_COMMAND_CENTER_APP (deprecated) | Supprimé — remplacé par SUPRAOperationalCoreApp |
| X17 | SUPRA_APP (deprecated) | Supprimé — remplacé par SUPRAOperationalCoreApp |
| X18 | CANONICAL_BRIDGE_DECLARATION_PROBE.json | Fichier temporaire de diagnostic — à supprimer |
| X19 | CANONICAL_FUNCTIONAL_CLASSIFICATION.json | Remplacé par CANNoNICO.CAPABILITY_CORE |

---

## 9. ROADMAP DE MIGRATION VERS Single Source of Knowledge

### Phase 1 — Fondations (CRITIQUE) — Priorité immédiate

| # | Action | Capacité V2 | Artefacts Impactés | Critère de Succession |
|---|---|---|---|---|
| 1 | Implémenter TUV5 Ingestion Pipeline | TUV5.INGESTION | Remplacer l'ingestion manuelle par un pipeline automatique | TUV5 compile automatiquement tout fichier source en CANNoNICO |
| 2 | Implémenter PUCHERO Knowledge Maturation Engine | PUCHERO (ensemble) | Coordonner IntelligenceEngine, EvolutionEngine, RecommendationEngine | Un engine unique évalue la maturité de toute connaissance |
| 3 | Implémenter Projection Engine | CANNoNICO.PROJECTION_ENGINE | Régénérer Swift, JSON, Bash, MD, UI depuis CANNoNICO | Les artefacts techniques ne sont plus écrits manuellement |
| 4 | Supprimer knowledge_graph.json, knowledge_identity.json, knowledge_relations.json | CANNoNICO.KNOWLEDGE_CORE | 3 fichiers JSON supprimés | Le CANNoNICO est la seule source de vérité pour la connaissance |
| 5 | Unifier les mémoires en CANNoNICO.MEMORY_CORE | CANNoNICO.MEMORY_CORE | MultiMemoryStore, ConversationMemoryStore, CAnnoNicoSnapshotStore, ExecutiveMemory → 1 store | 4 stores → 1 |

### Phase 2 — Migration (ÉLEVÉE) — Après Phase 1

| # | Action | Capacité V2 | Artefacts Impactés | Critère de Succession |
|---|---|---|---|---|
| 6 | Migrer tous les timestamps → NAMBROCAHORA | NAMBROCAHORA | RuntimeModels.swift, Date() dans stores | Aucun Date() système dans les modèles CANNoNICO |
| 7 | Fusionner SUPRAScheduler + SUPRABackgroundScheduler | RUNTIME.ORCHESTRATION | 2 composants → 1 | Modes (normal/background) d'une seule capacité |
| 8 | Fusionner 4 intelligence engines en PUCHERO.COHERENCE_SCORING | PUCHERO.COHERENCE_SCORING | SUPRAIntelligenceEngine, EvolutionEngine, RecommendationEngine, ResourceIntelligenceEngine → 1 | 4 engines → 1 avec spécialisations internes |
| 9 | Consolidater les 8 registres CANONICAL_* en CANONICAL_REGISTRY.json | CANNoNICO.IDENTITY_CORE | 17 JSON → 1 | Registre unique avec sous-domaines |
| 10 | Migrer les modèles Runtime vers CANNoNICO entities | CANNoNICO.Layer 2 | 21 types Runtime → CANNoNICO entities | Les types Runtime sont des projections CANNoNICO |

### Phase 3 — Gouvernance (MOYENNE) — Après Phase 2

| # | Action | Capacité V2 | Artefacts Impactés | Critère de Succession |
|---|---|---|---|---|
| 11 | Unifier la gouvernance sous CANNoNICO.GOVERNANCE_CORE | CANNoNICO.GOVERNANCE_CORE | Governance/*.md → 1 noyau | Gouvernance unifiée |
| 12 | Créer la canonicalization state machine | CANNoNICO (pipeline) | DETECT → GROUP → COMPARE → CANONICALIZE → LINK → PROVE → MIGRATE | Pipeline implémenté comme machine à états |
| 13 | Créer Knowledge Graph Query Interface | TUV5 + CANNoNICO | NOVAKnowledgeKernel.search(query:) → CANNoNICO-native query | Interface CANNoNICO-native |
| 14 | Créer la canonical evidence chain | PUCHERO + CANNoNICO | consensus_trace.json, routing_trace.json, execution_trace.json → CANNoNICO.EVIDENCE | Chaîne de preuves unifiée |

### Phase 4 — Optimisation (BAISSE) — Après Phase 3

| # | Action | Capacité V2 | Artefacts Impactés | Critère de Succession |
|---|---|---|---|---|
| 15 | Déprécier les composants LEGACY | Divers | ArtifactReader, SUPRAEnvironmentAutoMissions | Suppression planifiée |
| 16 | Déprécier les fichiers de registre individuels | CANNoNICO.IDENTITY_CORE | CANONICAL_SERVICES.json, CANONICAL_WORKERS.json, etc. | Fichiers dépréciés |
| 17 | Atteindre le critère de maturité | Toutes | Reconstruction complète depuis la connaissance canonique seule | Si le dépôt Git disparaît, le Runtime reconstruit tout depuis CANNoNICO |

---

## 10. CRITÈRE DE MATURITÉ V2

SUPRA atteint le niveau de maturité V2 lorsque :

> Si l'ensemble du dépôt Git disparaissait aujourd'hui, le Runtime serait capable de reconstruire progressivement les Runtime Services, les projections Swift, les scripts Bash, les Manifest, la documentation et les interfaces à partir de la seule connaissance canonique CANNoNICO.

### Critères de validation V2 :

1. Le CANNoNICO Core contient toutes les identités, relations, contraintes et preuves
2. Le TUV5 Pipeline est opérationnel (compile tout source en CANNoNICO)
3. Le PUCHERO Engine est opérationnel (évalue la maturité de toute connaissance)
4. Le Projection Engine génère toutes les projections (Swift, JSON, Bash, MD, YAML, UI, API)
5. Le NAMBROCAHORA est intégré au Runtime (aucun Date() système dans les modèles CANNoNICO)
6. La Memory Core est unifiée (4 stores → 1)
7. Les registres sont consolidés (17 JSON → 1)
8. Les artefacts techniques ne sont que des projections (aucun .md ou .json n'est une source de vérité autonome)
9. La preuve est traçable (chaque projection référence son entité CANNoNICO source)
10. Le système peut se reconstruire entièrement depuis CANNoNICO

### État actuel :

| Critère | Statut |
|---|---|
| 1 | ⚠️ Partiellement — CANNoNICO Core est défini mais pas implémenté comme moteur |
| 2 | ❌ Non — TUV5 Pipeline n'existe pas |
| 3 | ❌ Non — PUCHERO Engine n'existe pas |
| 4 | ❌ Non — Projection Engine n'existe pas |
| 5 | ❌ Non — Date() système encore présent dans les modèles |
| 6 | ❌ Non — 4 stores séparés |
| 7 | ❌ Non — 17+ fichiers JSON |
| 8 | ❌ Non — .md et .json sont des sources de vérité |
| 9 | ❌ Non — Traçabilité partielle |
| 10 | ❌ Non — Aucune reconstruction possible |

**Résultat : 0/10 — le système n'est pas encore au niveau de maturité V2.**

---

## 11. CONCLUSION

### 11.1 Validation du Modèle V1

Le modèle V1 est **conceptuellement correct**. Les 4 facultés, les 36 capacités, la structure CANNoNICO et les principes fondateurs (Knowledge First, Canon Before Code) forment un cadre cohérent et bien pensé.

### 11.2 Constats V2

| Dimension | Constat |
|---|---|
| Mission | ✅ Unique et dérivable |
| Facultés | ✅ 4 suffisantes, pas de 5e nécessaire |
| Capacités | ⚠️ 2 ambiguïtés détectées et résolues, 1 redondance fusionnée |
| Services | ✅ Tous correctement rattachés, 4 violations de frontière identifiées |
| CANNoNICO | ⚠️ Richesse suffisante en théorie, mais besoin de Learning + Feedback primitives |
| CKG | ✅ Structure V1 définie avec 7 dimensions |
| Projections | ❌ 5 problèmes critiques empêchant les artefacts d'être de simples projections |
| Roadmap | ✅ 4 phases définies pour atteindre le Single Source of Knowledge |

### 11.3 Mot d'ordre V2

> **Le modèle V1 est le bon modèle. Le problème n'est pas l'architecture — c'est l'implémentation.**
>
> Tant que le TUV5 Pipeline, le Projection Engine et le PUCHERO Engine ne sont pas opérationnels, les artefacts continueront d'être des sources de vérité autonomes et non des projections.
>
> Knowledge First. Canon Before Code. One Concept. One Canonical Definition. Many Projections.

---

*Validation d'Architecture V2 — SUPRA Système Cognitif Gouverné*
*Document produit le 2026-07-29 dans le cadre de l'Execution Gate : Architecture V2 Validation*
*Autorité : SUPRA Constitution — Article 2*
*Statut : LIVRABLE DE VALIDATION — À valider avant toute implémentation V2*