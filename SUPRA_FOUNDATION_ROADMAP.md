# SUPRA Foundation — Roadmap

## Feuille de Route Officielle — De SUPRA ZERO à Phase 2

| Propriété | Valeur |
|-----------|--------|
| **Statut** | CANONIQUE |
| **Version** | SUPRA_FOUNDATION_V1 |
| **Date** | 2026-07-29 |
| **Principe** | Ordre obligatoire — aucune phase ne peut commencer avant la précédente |

---

## 1. Ordre des Phases

```
                        ╔═══════════════════╗
                        ║   SUPRA ZERO ✅   ║  ← COMPLETED (2026-07-29)
                        ╚═══════════════════╝
                                │
                                ▼
                        ╔═══════════════════╗
                        ║ SUPRA FOUNDATION  ║  ← CURRENT MISSION
                        ║     (Phase 1)     ║
                        ╚═══════════════════╝
                                │
                                ▼
╔═══════════════════════════════════════════════════╗
║         SUPRA ULTIMATE CONSOLIDATION              ║  ← Phase 2a
║   Fusionner, consolider, unifier le codebase      ║
╚═══════════════════════════════════════════════════╝
                                │
                                ▼
╔═══════════════════════════════════════════════════╗
║                PLUGIN SDK                         ║  ← Phase 2b
║   Implémenter le SDK de plugins                   ║
╚═══════════════════════════════════════════════════╝
                                │
                                ▼
╔═══════════════════════════════════════════════════╗
║              THEORY ENGINE                        ║  ← Phase 2c
║   Construire l'ontologie et le moteur de théorie  ║
╚═══════════════════════════════════════════════════╝
                                │
                                ▼
╔═══════════════════════════════════════════════════╗
║               SHERPA V2                           ║  ← Phase 2d
║   Moteur de sélection de contexte                 ║
╚═══════════════════════════════════════════════════╝
                                │
                                ▼
╔═══════════════════════════════════════════════════╗
║               CORTEX V2                           ║  ← Phase 2e
║   Mémoire persistante et apprentissage            ║
╚═══════════════════════════════════════════════════╝
                                │
                                ▼
╔═══════════════════════════════════════════════════╗
║             EXECUTIVE OS                          ║  ← Phase 2f
║   Activation runtime, consolidation finale        ║
╚═══════════════════════════════════════════════════╝
                                │
                                ▼
╔═══════════════════════════════════════════════════╗
║               PHASE 2                             ║  ← Phase 3+
║   Production, multi-utilisateur, CI/CD            ║
╚═══════════════════════════════════════════════════╝
```

---

## 2. Détail des Phases

### Phase 1 : SUPRA FOUNDATION (Terminée)

| Propriété | Valeur |
|-----------|--------|
| **Statut** | ✅ COMPLETED — 2026-07-29 |
| **Objectif** | Transformer SUPRA ZERO en socle canonique unique |
| **Livrables** | 12 documents canoniques |

### Phase 2a : SUPRA ULTIMATE CONSOLIDATION

| Propriété | Valeur |
|-----------|--------|
| **Statut** | ⏳ NEXT |
| **Objectif** | Fusionner, consolider et unifier le codebase existant |

**Livrables** :
- Fusion des evidences frozen dans le Runtime
- Consolidation de l'Executive Kernel
- Unification du Composition Root
- Résolution des 3 tests en échec
- Commit des 14 fichiers non commités
- Nettoyage des duplicats de code Swift
- Formalisation du modèle objet exécutif

**Dépendances** : SUPRA FOUNDATION ✅
**Effort estimé** : 2-3 sessions
**Critères de succès** :
- 9/9 tests passent
- Workspace propre (0 modified files)
- Composition Root unique

### Phase 2b : PLUGIN SDK

| Propriété | Valeur |
|-----------|--------|
| **Statut** | ⏳ Phase 2a requise |
| **Objectif** | Implémenter le SDK de plugins spécifié |

**Livrables** :
- PluginRegistry (enregistrement, découverte)
- PluginLoader (chargement statique et dynamique)
- 7 protocoles Swift (Theory, Sherpa, Cortex, Proof, Workspace, Runtime, Provider)
- Plugin manifest validator
- Tests d'intégration plugins

**Dépendances** : Ultimate Consolidation
**Effort estimé** : 2-3 sessions
**Critères de succès** :
- Un plugin de test peut être chargé et exécuté
- Registry fonctionnel
- Cycle de vie complet testé

### Phase 2c : THEORY ENGINE

| Propriété | Valeur |
|-----------|--------|
| **Statut** | ⏳ Plugin SDK requis |
| **Objectif** | Construire l'ontologie et le moteur de théorie |

**Livrables** :
- Theory Ontology (modèle de données complet)
- Theory Library (10-20 théories fondatrices)
- Theory Graph (stockage persistant)
- Theory Search (recherche sémantique)

**Dépendances** : Plugin SDK
**Effort estimé** : 3-4 sessions
**Critères de succès** :
- 10+ concepts dans le graphe
- Recherche fonctionnelle
- Intégration avec Plugin SDK validée

### Phase 2d : SHERPA V2

| Propriété | Valeur |
|-----------|--------|
| **Statut** | ⏳ Theory Engine requis |
| **Objectif** | Moteur de sélection de contexte et recommandation |

**Livrables** :
- Context Selection Engine
- Provider Recommendation Engine
- Navigation Engine
- Intégration avec Theory
- Tests de routage contextuel

**Dépendances** : Theory Engine
**Effort estimé** : 2-3 sessions
**Critères de succès** :
- Une mission est routée avec contexte Theory
- Recommandation provider fonctionnelle
- Navigation contextuelle opérationnelle

### Phase 2e : CORTEX V2

| Propriété | Valeur |
|-----------|--------|
| **Statut** | ⏳ Sherpa V2 requis |
| **Objectif** | Mémoire persistante et apprentissage |

**Livrables** :
- Persistent Decision Memory
- Evidence Storage
- Learning Engine
- Experience Replay
- Intégration avec Sherpa

**Dépendances** : Sherpa V2
**Effort estimé** : 2-3 sessions
**Critères de succès** :
- Une décision est persistée et retrouvée
- Apprentissage par retour d'expérience fonctionnel
- Evidence correctement stockée

### Phase 2f : EXECUTIVE OS

| Propriété | Valeur |
|-----------|--------|
| **Statut** | ⏳ Cortex V2 requis |
| **Objectif** | Activation complète du runtime et consolidation finale |

**Livrables** :
- Runtime Activation (connexion providers → LLM calls)
- MissionExecutor full implementation
- Workflow engine end-to-end
- Executive Kernel full consolidation
- Dashboard intégré
- Tests d'intégration complets

**Dépendances** : Cortex V2
**Effort estimé** : 3-4 sessions
**Critères de succès** :
- Au moins 1 mission exécutée avec LLM call
- Workflow complet exécuté
- Tous les tests passent
- Dashboard affiche l'état temps réel

### Phase 3+ : PHASE 2

| Propriété | Valeur |
|-----------|--------|
| **Statut** | ⏳ Executive OS requis |
| **Objectif** | Production, scale, communauté |

**Livrables potentiels** :
- Multi-user support
- Plugin marketplace
- CI/CD pipeline
- Full test coverage (>80%)
- Documentation publique
- Community contributions

**Dépendances** : Executive OS
**Effort estimé** : 4-6 sessions

---

## 3. Graphe des Dépendances

```
FOUNDATION ──▶ CONSOLIDATION ──▶ PLUGIN SDK ──▶ THEORY ──▶ SHERPA ──▶ CORTEX ──▶ EXECUTIVE OS ──▶ PHASE 2
      │               │               │            │          │          │             │              │
      │               │               │            │          │          │             │              │
      ▼               ▼               ▼            ▼          ▼          ▼             ▼              ▼
   12 docs         Code+Tests      Protocols    Ontology   Context    Memory      Runtime        Production
                  + Fusion          +Loader     +Library   +Routing  +Learning    +Activation    +Scale
```

**Aucune parallélisation possible** — chaque phase dépend strictement de la précédente.

---

## 4. Estimation des Sessions

| Phase | Sessions | Complexité |
|-------|----------|------------|
| Foundation ✅ | 1 | Élevée (12 documents) |
| Ultimate Consolidation | 2-3 | Moyenne (code + tests) |
| Plugin SDK | 2-3 | Élevée (nouveau système) |
| Theory Engine | 3-4 | Très élevée (fondation cognitive) |
| Sherpa V2 | 2-3 | Élevée (contexte + routage) |
| Cortex V2 | 2-3 | Élevée (mémoire + apprentissage) |
| Executive OS | 3-4 | Très élevée (runtime activation) |
| Phase 2 | 4-6 | Variable (production) |
| **Total** | **19-28 sessions** | |

---

## 5. Risques et Bloqueurs

| Risque | Phase Impactée | Probabilité | Mitigation |
|--------|---------------|-------------|------------|
| 3 tests non fixés | Consolidation | Élevée | Root cause analysis immédiate |
| Provider non fonctionnel | Executive OS | Moyenne | Fallback, tests Ollama |
| Duplication de code | Consolidation | Moyenne | Revue systématique |
| Dette technique cachée | Consolidation | Moyenne | Audit complet du codebase |
| Surcharge de fichiers | Foundation | Faible | Consolidation déjà en cours |
| Modèle de données inadapté | Theory | Moyenne | Prototypage rapide |
| Complexité de l'apprentissage | Cortex | Élevée | Démarrer simple (règles) |

---

## 6. Jalons Clés

| Jalon | Date | Phase |
|-------|------|-------|
| 🏁 SUPRA ZERO terminé | 2026-07-29 | Foundation |
| 🏁 12/12 documents Foundation créés | 2026-07-29 | Foundation |
| 🏁 Phase 2 Gate validé | TBD | Fin Foundation |
| 🏁 9/9 tests passent | TBD | Consolidation |
| 🏁 Premier plugin chargé | TBD | Plugin SDK |
| 🏁 Premier concept dans Theory Graph | TBD | Theory Engine |
| 🏁 Première mission routée avec contexte | TBD | Sherpa V2 |
| 🏁 Première décision persistée | TBD | Cortex V2 |
| 🏁 Premier LLM call via MissionExecutor | TBD | Executive OS |
| 🏁 SUPRA Phase 2 | TBD | Phase 2 |

---

## 7. Décisions de Roadmap

| ID | Décision | Date | Auteur |
|----|----------|------|--------|
| R-01 | Ordre obligatoire : Consolidation → Plugins → Theory → Sherpa → Cortex → Executive OS → Phase 2 | 2026-07-29 | Executive |
| R-02 | Aucune parallélisation de phases | 2026-07-29 | Executive |
| R-03 | Phase 2 Gate avant toute Phase 2 | 2026-07-29 | Executive |
| R-04 | Theory Engine commence APRES Plugin SDK | 2026-07-29 | Architect |
| R-05 | Cortex V2 intégrera la mémoire persistante existante (20%) | 2026-07-29 | Architect |

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA FOUNDATION V1.*
