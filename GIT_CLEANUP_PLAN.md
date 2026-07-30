# GIT_CLEANUP_PLAN.md

## RÉSUMÉ Plan de nettoyage GIT

Selon **ALPHA-01_RELEASE_AUDIT.md** : la branche `develop` contient +12 commits, 13 fichiers suivis modifiés (11 Swift, pbxproj + Dependency Map), 0 staged, 949 non suivis. Pas de tags initiaux.

## Pour Conserver

### Fichiers sources essentiels
- SUPRA/SUPRAApp.swift
- SUPRA/ContentView.swift
- SUPRA/SUPRACanonicalWorldAccess.swift
- autres Swift sources principaux (liste complète dans git status original)

### Configurations et métadonnées essentielles
- `SUPRA.xcodeproj/project.pbxproj`
- `DEPENDENCY_MAP.md`
- `Package.swift` (s'il existe)
- `Package.resolved`

### Documentation à conserver
- BASELINE_CERTIFICATION_REPORT.md
- BASELINE_ISSUES.md
- BASELINE_ACTION_PLAN.md
- BUILD_LOG.md
- RUNTIME_STATUS.md
- ALPHA01_RELEASE_AUDIT.md (ce plan)
- AGENTS.md
- RELEASE_* (tous les documents de release sous docs/releases/)
- GO_SUPRA_INSTALL_AUDIT.md

### Scripts et builds techniques
- GO_SUPRA_INSTALL.sh (corrigé)
- scripts assimilés GO_SUPRA_* (à évaluer pour le contenu)
- makefile / scripts d'extraction si présents

### Artefacts et preuves techniques
- Tous les audits et preuves documentés (BASELINE_*, ALPHA01_RELEASE_AUDIT, etc.)
- Tous les *.log collectés, sauf les temporaires vides (default.profraw)
- Captures (*.png) seulement si preuves essentielles (preuve de lancement)
- Caches de build : .swiftpm, .derivedData, .build (sélectionner uniquement si reconstitution nécessaire)

### Informations opérationnelles
- .gitignore (mais préserver les exclusions essentielles)
- .gitconfig (état utilisateur)
- Autres métadonnées Git (HEAD, branche)

## À Supprimer

### Artefacts temporaires et caches
- default.profraw (0 octet, déjà retiré)
- Caches dérivésData : `/private/tmp/SUPRA_*`
- Tous les `.profraw`, `.log` générés avant certification si non documentés comme preuve
- Tous les caches temporaires `.derivedData`, `.swiftpm`

### Fichiers temporaires dérivés
- build logs inutiles dans les artefacts
- Tous les `.tmp`, `~`, `*~`, `.*` exceptés pour le suivi du dépôt

## À Ignorer

### Fichiers générés et non sources
- Tous les `*.log` dans Artifacts/, sauf si prouvés essentiels
- Tous les `*.tmp`, `*.cache`, `*.prof`, `*.profraw` sauf preuve nécessaire
- Tous les `*.png` capturés sauf si preuve de lancement essentielle
- Tous les `*.json`, `*.csv`, `*.tsv` non sources sauf régression détectée

### Caches système et intermédiaires
- `.swiftpm` (mais préserver les informations de dépendance pour la réproduction)
- `.cache/` (sauf fichiers essentiels)
- `.derivedData/` (et similaires)
- `.annotation`, `.internal` fichiers (si présents)

### Artefacts CHANGELOG non nécessaires
- changelog temporaire des tâches ignorés

## À Archiver

### Preuves historiques
- Tous les fichiers de base LINE *
- Tous les audits de base et actions
- Tous les artefacts de base et preuves documentés comme archival (selon base de preuve GLOBAL_GRAPH*)

### Versions et snapshots
- Tag ALPHA-01.0.0 (s'il existe)
- Snapshot Git HEAD pour l'attribution (HEAD observé à partir des journaux ALPHA-01)
- Tous les tâches documentées du dépôt (hors documentation locale)

### Scripts et flows techniques établis
- Tous les scripts GO_SUPRA_* consolidés (documentés comme partie de GO_SUPRA.sh)
- Tous les extraits scripts CLEANUP, AUDIT établis

## Stratégie conservation/suppression/gestion des arèles

### Principes régissant le plan
- **Retenir** des fichiers nécessaires à la reproduction de la baseline
- **Supprimer** des caches temporaires qui se régénèrent
- **Archiver** des preuves historiques pour la compliance sous le prefix BASELINE_
- **Ignorer** des artefacts non essentiels pour les futures missions

### Règles régissant le plan
- Tout fichier modifié après l'audit de base DEVEUT être documenté
- Toute suppression DOIT être justifiée par BL-001, BL-002, etc.
- Tout fichier archivé doit avoir une référence claire dans ALPHA01_RELEASE_AUDIT.md
- Utiliser uniquement les mécanismes documentés OpenCode pour les mutations

## Résumé décisions suppression/conservation/archival

| Catégorie | Conserver ? | Supprimer ? | Archiver ? | Raison |
|----------|----------|----------|------------|--------|
| Sources Swift essentiels | ✅ | ❌ | ❌ | Build et runtime nécessaires |
| Configurations (Xcode, Package) | ✅ | ❌ | ❌ | Build nécessaire pour réproduction |
| BASELINE_* (tous) | ✅ | ❌ | ✅ | Preuves essentielles et historiques |
| BASELINE_ACTION_PLAN.md | ✅ | ❌ | ❌ | Plan directeur future mission |
| BUILD_LOG.md | ✅ | ❌ | ❌ | Preuve build nécessaire |
| RUNTIME_STATUS.md | ✅ | ❌ | ❌ | Observé état runtime |
| ALPHA01_RELEASE_AUDIT.md | ✅ | ❌ | ❌ | Audit final ALPHA-01 |
| AGENTS.md | ✅ | ❌ | ✅ | Conventions futures mais stable |
| docs/releases/* | ✅ | ❌ | ✅ | Politiques release mais stable |
| GO_SUPRA_INSTALL_AUDIT.md | ✅ | ❌ | ✅ | Preuve corrected script |
| default.profraw | ❌ | ✅ | ❌ | Vide, supprimé avant certification |
| Caches dérivésData | ❌ | ✅ | ✅ | Régénérables |
| Tous *.log non documentés | ❌ | ✅ | ✅ | Pas de valeur evidence |
| Toutes les captures PNG non prévues | ❌ | ✅ | ✅ | Pas de preuve essentielle |

## Mise en œuvre plan

### Script automatisé (optionnel)
```bash
# Script de nettoyage recommandé pour la maintenance future
git clean -fdX  # Utile pour les caches
rm -rf "*.profraw" "*.derivedData" "*.log" (sauf ceux documentés)
# Sauvegarder les fichiers essentiels pour le snapshot
```

### Surveillance future
- Ajouter un garde dans GO_SUPRA_INSTALL.sh pour détecter new files non documentés
- Ajouter une validation dans AGENTS.md pour signaler tout fichier inconnu ajouté à la racine

### Piste d'audit ultérieure
- Toutes les décisions suppression/maintien documentées dans ce plan
- Toute suppression ultérieure doit être justifiée dans BASELINE_ACTION_PLAN.md ou ALPHA02_EXECUTION_PACKAGE.md
- Les mutations passant par SUPRA-Builder et Mission Center devront attester de la justification

## Validation post-mission

### Test du plan
- Après validation ALPHA-02, relire BASELINE_ACTION_PLAN.md pour toute divergence de plan
- Vérifier que AGENTS.md V2 correspond au plan de nettoyage (pas de relecture anticipée)
- Vérifier que GO_SUPRA_INSTALL.sh corrigé est toujours valide après toute modification future

### Feuille de route d'amélioration
- ALORS revoyez ce plan après retours du quota
- Mettez à jour le plan en résultat de MISSION_AMAZON___DRIFT_FOUND
- Intégrer au processus release. Plus, lors de l'exécution, utiliser `git status` et `git diff` et documenter seulement essentielle préparation nécessaire.

## RÉSUMÉ : Version 1.0', 2026-07-28
Cette version comprend les décisions documentées de la mission ALPHA-01 initiale sur la gestion et la conservation des artefacts. Les missions futures devront suivre ce plan pour préserver et gérer les artefacts du dépôt.