# NEXT SESSION BRIEF — SUPRA THEORY ENGINE

## Context

Session précédente : **CAMP_BASE_02_FOUNDATION** — terminée et clôturée.
Status: `SESSION_STATUS: CLOSED`, `CONTINUITY: VERIFIED`, `RECOVERY: SUCCESS`

Le Workspace est stable, la Runtime est version 2.2.0, l'Alpha-01 est figée et certifiée.
**La prochaine session ne doit plus être orientée code, mais connaissance.**

## Architecture Actuelle

```
THEORY (à construire)
  ↓
SHERPA (à construire — sélection de contexte)
  ↓
CORTEX (à construire — mémoire persistante)
  ↓
RUNTIME [EXISTANT — SUPRAOperationalCoreApp, v2.2.0]
  ↓
PROVIDERS [EXISTANT — Ollama, OpenCode]
```

## État du Workspace

| Élément | Statut |
|---------|--------|
| Branch | `develop` (HEAD: 80ca2f1) |
| Modifications non commit | 14 fichiers modifiés (missions, vues, dépendances) |
| Build Xcode | SUCCEDED (Debug, arm64) |
| Pipeline Runtime | 10 stages, FULLY_INSTRUMENTED |
| Agents définis | 9 (Architect, Builder, Auditor, Reviewer, Explorer, Research, Runtime, Refactor, Router) |
| Provider par défaut | OLLAMA_LOCAL / qwen3-coder (healthy) |
| Fichiers Swift | 214 dans SUPRA/, 9 dans SUPRATests/ |
| WORKSPACE_MANIFEST | Valide — version CAMP_BASE_02_FOUNDATION_1.0 |

## État Runtime

- **Entry point**: `SUPRAOperationalCoreApp`
- **Sandbox**: DISABLED (fixed)
- **Workflows**: 5 ready (0 executed)
- **Artifacts**: 6/6 operational
- **Tests connus échouant**: 3 (fallback, index exclusion, unchanged files)
- **Transmission**: Adaptive multipower protocol implémenté et testé

## Ce qui fonctionne

- Navigation complète du Control Center avec section de prompt mission
- MissionStore avec création, suivi et historique
- 5 workflows métier enregistrés (Business Health, Decision Audit, Monetization, Environment Assessment, Opportunity Discovery)
- Protected Folder Access Coordinator (sandbox contournée, accès sécurisé)
- Dashboard runtime avec métriques système
- Architecture provider avec broker, fallback, et registry
- Knowledge Graph, Twin System, Universe Engine

## Ce qui reste à construire (ordre conseillé)

### PRIORITÉ 1 : SUPRA THEORY ENGINE (Nouvelle session)
*Ne pas écrire de code Swift. Construire le socle intellectuel.*

1. **Ontologie des connaissances** — Définir les domaines :
   - Architecture, Runtime, IA, RAG, Agents, UX, Gouvernance, Décision,
     Graphes, Mémoire, Systèmes distribués, Sécurité, Produits, Business

2. **Bibliothèque théorique de référence** — Chaque théorie en objet structuré :
   - auteur, concepts, principes, avantages, limites, cas d'utilisation,
     contre-indications, relations, niveau de confiance

3. **Moteur de recherche théorique** — SHERPA doit pouvoir chercher les concepts
   pertinents avant chaque décision majeure (architecture RAG)

4. **Theory Graph** — Relier concepts, décisions, composants et preuves

5. **Séparation définitive des couches** :
   ```
   THEORY → SHERPA → CORTEX → RUNTIME → PROVIDERS
   ```

### PRIORITÉ 2 : Résolution de dette technique
- `testFallbackScenario` — analyser root cause
- `testINDEX_FILE_EXCLUDED_FROM_SCAN` — réparer
- `testUNCHANGED_FILES_NOT_REPARSED` — réparer

### PRIORITÉ 3 : Activation du Runtime (Phase 1 Alive)
- Connecter OllamaProvider → MissionExecutor → première mission LLM
- "Quelle est l'utilisation CPU ?" — premier appel réel

## Ce qu'il ne faut PAS refaire

- ✗ Ne pas recréer WORKSPACE_MANIFEST.json — déjà validé
- ✗ Ne pas réauditer l'Alpha-01 — déjà figée
- ✗ Ne pas refactorer le Control Center — déjà restructuré
- ✗ Ne pas toucher au Protected Folder — déjà frozen
- ✗ Ne pas ajouter de nouveaux providers sans mission explicite
- ✗ Ne pas produire de nouveaux audits/documentation redondants
- ✗ Ne pas modifier Package.swift sans evidence-backed mission
- ✗ Ne pas refaire des freezes — déjà 5 snapshots frozen

## Ordre Conseillé des Prochaines Étapes

```
Étape 1: [Théorie] Définir l'ontologie SUPRA (domaines, relations)
Étape 2: [Théorie] Construire la bibliothèque de théories (10-20 théories fondatrices)
Étape 3: [Théorie] Construire le Theory Graph (concepts → composants → preuves)
Étape 4: [Théorie] Implémenter le moteur de recherche théorique (RAG)
Étape 5: [Théorie] Définir SHERPA (sélection de contexte)
Étape 6: [Théorie] Définir CORTEX (mémoire persistante)
Étape 7: [Runtime] Résoudre les 3 tests échouants
Étape 8: [Runtime] Activer la première mission LLM de bout en bout
```

## Preuves Disponibles

| Preuve | Emplacement |
|--------|-------------|
| SESSION_CONTINUITY_REPORT.md | Racine du workspace |
| SESSION_SNAPSHOT_20260729.json | Racine du workspace |
| WORKSPACE_MANIFEST.json | Racine du workspace |
| RELEASE_MANIFEST.json | Release v1.0.0 certifiée |
| ALPHA01_RELEASE_AUDIT.md | Audit Alpha-01 complet |
| RUNTIME_STATUS.json | État runtime complet |
| SUPRA_STATE.json | État global |

## Commandes Utiles pour la Prochaine Session

```bash
# Voir l'état actuel
git log --oneline -5
git status
git diff --stat

# Voir le manifeste
cat WORKSPACE_MANIFEST.json | python3 -m json.tool

# Voir les fichiers modifiés non commit
git diff --name-only

# Voir les 3 tests échouants
xcodebuild test -scheme SUPRA -destination 'platform=macOS' 2>&1 | grep FAILED
```
