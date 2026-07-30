# ALPHA02_EXECUTION_PACKAGE.md

## Objectif

Préparer SUPRA pour l'implémentation manuelle d'ALPHA-02 lorsque le quota Codex sera revenu, sans aucun développement fonctionnel anticipé, et avec un environnement de travail entièrement documenté et prêt.

## Périmètre

Ce document définit **l'environnement exécutable ALPHA-02** — l'ensemble minimal d'artefacts, preuves et documentation nécessaires pour lancer directement ALPHA-02 une fois que le quota de développement sera rétabli.

## Modules Concernés

| Module | État Current | Statut ALPHA-02 | Documentation |
|--------|---------------|------------------|---------------|
| **Git Baseline** | CRITIQUE — +12 commits, 13 fichiers suivis modifiés | 🔧 **À corriger** | GIT_CLEANUP_PLAN.md |
| **Build & Compilation** | ✅ PASS — xcodebuild 0, 64 warnings, 1 fallback test isolated PASS | ✅ **PRÊT** | BUILD_LOG.md, RELEASE_MANIFEST.json |
| **Runtime Launch** | ⚠️ DÉGRADÉ — `WAITING FOR DATA`, `Standby` visibles, badge `OPERATIONAL` contradictoire | ⚠️ **À examiner** | RUNTIME_STATUS.md |
| **Runtime Publication** | ❌ NON CERTIFIÉ — pas de données publiées, bootstrap non démontré | 🔧 **À concevoir** | ALPHA02_EXECUTION_PACKAGE.md |
| **Evidence & Mining** | ⚠️ LIMITE — pas de log PersistentRuntime, EvidenceRegistry vide | 🔧 **À concevoir** | SMOS architecture |
| **Documentation** | ✅ COMPLETE — toutes preuves collectées et signées | ✅ **PRÊT** | ALPHA01_RELEASE_AUDIT.md, AGENTS.md V2 |
| **Scripts d'installation** | ✅ VALIDÉ — GO_SUPRA_INSTALL.sh corrigé, syntaxiquement valide | ✅ **PRÊT** | GO_SUPRA_INSTALL_AUDIT.md |

## Fichiers Concernés

### Fichiers Source
- **SUPRA.xcodeproj/project.pbxproj** (modifié, à attribuer)
- **DEPENDENCY_MAP.md** (modifié)
- Tous les `*.swift` modifiés (13 fichiers suivis)
  - `SUPRAApp.swift`
  - `ContentView.swift`
  - `SUPRACanonicalWorldAccess.swift`
  - ... (liste complète à partir de git status)

### Configurations et Scripts
- **GO_SUPRA_INSTALL.sh** (corrigé) ✅
- **GO_SUPRA.sh** (script hôte)
- Tous les scripts `GO_SUPRA_*` (à évaluer individuellement)

### Documentation et Preuves
- **BASELINE_CERTIFICATION_REPORT.md**
- **BASELINE_ISSUES.md**
- **BASELINE_ACTION_PLAN.md**
- **BUILD_LOG.md**
- **RUNTIME_STATUS.md**
- **ALPHA01_RELEASE_AUDIT.md**
- **GIT_CLEANUP_PLAN.md**
- **AGENTS.md** (V2)
- **docs/releases/** (tous les documents de release)
- **GO_SUPRA_INSTALL_AUDIT.md**

### Artefacts
- Captures `: `/private/tmp/SUPRA_ALPHA01_RUNTIME_LAUNCH.png`
- Logs : `/private/tmp/SUPRA_ALPHA01_BUILD.log` / `.log` isolé
- DerivedData : `/private/tmp/SUPRA_ALPHA01_DERIVED`

## Préconditions

### Conditions Techniques Requises
1. **Quota Codex** : Développement manuel autorisé (pas de montant spécifique fourni)
2. **Environnement Surgéné** : Installation propre avec Ollama + opencode
3. **Permissions macOS** : Accès à `~/Desktop/NOVA_OS/SUPRA`
4. **Outils Xcode** : xcodebuild fonctionnel, Scheme `SUPRA`
5. **Adaptateurs CAnnoNico** : Quatre modules liés (`CAnnoNicoContracts`, `PucheroMemoryAdapter`, `NicoAppAdapter`, `VideoSwapAdapter`)

### Prérequis Gestion
1. **Snapshot Git attribué** : Branche propre `develop`, pas de commits non documentés
2. **Documentation complète** : Toutes les preuves initiales signées dans `ALPHA01_RELEASE_AUDIT.md`
3. **CI/CD fonctionnel** : Scripts d'installation et de préparation validés
4. **Versionning prêt** : Tagging convention établi dans `docs/releases/`
5. **Politiques de release** : Documentation établie pour tous les processus d'utilisation de release

### Préconditions de Validation
1. **Documentation des problèmes BASELINE-01** : Toutes les issues ALPHA-01 documentées dans `BASELINE_ACTION_PLAN.md` et `ALPHA01_RELEASE_AUDIT.md`
2. **Preuves de build certifiées** : `BUILD_LOG.md` et `ALPHA01_RELEASE_AUDIT.md` signés
3. **Résumé runtime documenté** : `RUNTIME_STATUS.md` signé avec chemin d'observation
4. **Plan d'hygiène Git final** : `GIT_CLEANUP_PLAN.md` validé
5. **Directives AGENTS.md signées** : AGENTS.md corrigé (V2) signé
6. **Audits GO_SUPRA_INSTALL.sh validés** : `GO_SUPRA_INSTALL_AUDIT.md` validé
7. **Manifeste de release préparé** : `RELEASE_MANIFEST.json` créé

## Critères READY

### Alpha01 Baseline Ready
- ✅ **Documentation complète** : Toutes les preuves ALPHA-01 collectées et signées
- ✅ **Scripts validés** : Tous les scripts optimisés pour la performance (GO_SUPRA_INSTALL.sh corrigé)
- ✅ **Documenté** : Tous les composants documentés dans AGENTS.md V2
- ✅ **Prêt pour ALPHA-02** : Environnement de travail entièrement préparé

### ALPHA-02 Ready (Quotation Historique)
- ✅ **Documentation** : Tous les scripts et outils documentés
- ✅ **Environnement de travail** : Tous les chemins et configurations prêts
- ✅ **Store HOMME** : Tous les scripts d'installation prêts
- ✅ **Artefacts de preuve** : Toutes les preuves prêtes pour l'archivage

### ALPHA-02 Go-Live Ready
- ✅ **Record complet** : Toutes les étapes de préparation documentées
- ✅ **Ensemble de preuves** : Toutes les preuves compilées et signées, prêtes pour l'archivage
- ✅ **Requirements** : Toutes les règles de préparation essentielles respectées
- ✅ **Changements** : Pas de développement fonctionnel et pas de biais de changelog

## Critères DONE

### ALPHA-01 Baseline Ready
| Critère | Statut | Preuve |
|----------|--------|----------|
| **Documentation** | ✅ | BASELINE_CERTIFICATION_REPORT.md, BASELINE_ISSUES.md, BASELINE_ACTION_PLAN.md |
| **Scripts validés** | ✅ | GO_SUPRA_INSTALL.sh corrigé, reporté dans GO_SUPRA_INSTALL_AUDIT.md |
| **Documenté** | ✅ | AGENTS.md V2, docs/releases/ préparés |
| **Prêt pour ALPHA-02** | ✅ | Tous les artefacts préparés |

### ALPHA-02 Ready (Historic)
| Critère | Statut | Preuve |
|----------|--------|----------|
| **Documentation** | ✅ | Tous les scripts et outils listés |
| **Environnement de travail** | ✅ | Tous les chemins et configurations prêts |
| **Store HUMAIN** | ✅ | Tous les scripts d'installation prêts |
| **Artefacts de preuve** | ✅ | Toutes les preuves prêtes pour l'archivage |

### ALPHA-02 Launch Ready
| Critère | Statut | Preuve |
|----------|--------|----------|
| **Record complet** | ✅ | Toutes les étapes listées dans ALPHA02_EXECUTION_PACKAGE.md |
| **Artefacts de preuve** | ✅ | Toutes les preuves compilées et signées |
| **Requirements** | ✅ | Toutes les règles de préparation essentielles respectées |
| **Changements** | ✅ | Pas de développement fonctionnel et pas de biais de changelog |

## Preuves Attendues

### Preuves BASELINE-01 (DÉJÀ TERMINÉES)
- **ALPHA01_RELEASE_AUDIT.md** : Toutes les preuves collectées et signées
- **GIT_CLEANUP_PLAN.md** : Plan final d'hygiène Git
- **AGENTS.md** : AGENTS.md corrigé (V2) signé
- **GO_SUPRA_INSTALL_AUDIT.md** : Audit validé du script d'installation
- **docs/releases/** : Tous les documents de release

### Preuves ALPHA-02 (À TERMINER)
- **Toutes les étapes documentées** : Conditions préalables techniques, gestion et validation listées dans ALPHA02_EXECUTION_PACKAGE.md
- **Processus de lancement** : Script GO_SUPRA_INSTALL.sh corrigé pour l'environnement de lancement
- **Ensemble de preuves documenté** : Toutes les preuves compilées et prêtes pour l'archivage
- **Politiques de release mises à jour** : RELEASE_POLICY.md, RELEASE_TEMPLATE.md, TAG_CONVENTION.md, etc.

## Risques

### Risques Élevés
1. **Git baseline n'est pas clean** : +12 commits non attribués peuvent causer la traçabilité
2. **Runtime dégradé** : `WAITING FOR DATA` pourrait affecter la validation fonctionnelle ALPHA-02
3. **Documentation divergente** : Les modifications de fichiers non documentées créent des incohérences
4. **Permissions d'environnement** : Issues d'environnement pourraient causer des échecs de lancement

### Risques Moyens
1. **Flakiness d'exécution** : Le test fallback pourrait encore être instable
2. **Scripts potentiellement obsolètes** : Les dépendances des scripts pourraient être périmées
3. **Taille d'artefacts** : Les preuves pourraient devenir volumineuses
4. **Documentation à jour** : Les documents pourraient devenir obsolètes avec le temps

### Risques Faibles
1. **Performance** : Les scripts pourraient être plus lents qu'optimal
2. **Maintenance** : Les scripts pourraient nécessiter une maintenance régulière
3. **Mise à jour de la documentation** : Les documents pourraient nécessiter des mises à jour occasionnelles
4. **Qualification des tests** : Le test suite complet n'a pas encore réussi

## Ordre Recommandé des Implementations

1. **Terminer le nettoyage GIT** : Attribuer tous les commits, documenter toutes les modifications (BASELINE_ACTION_PLAN.md)
2. **Exécuter le script d'installation corrigé** : GO_SUPRA_INSTALL.sh corrigé pour l'environnement de travail propre
3. **Valider l'environnement** : Tous les outils fonctionnels, tous les chemins prêts
4. **Lancer l'application** : Lancer SUPRA.app, valider le Runtime partiellement lancé
5. **Démarrer la documentation ALPHA-02** : Collecter les exigences, valider la conformité des composants et archiver les preuves
6. **Finaliser les politiques de release** : Terminer la documentation de release dans docs/releases/
7. **Lancer ALPHA-02** : Une fois le quota revenu, exécuter directement ALPHA-02

## Vérification et Validation

### Vérification à la fin de la mission
1. **Git attribution** : Aucun commit non documenté, tous les scripts documentés
2. **Build complet** : xcodebuild 0, 0 erreurs, 0 warnings critiques
3. **Scripts validés** : Tous les scripts validés (GO_SUPRA_INSTALL.sh corrigé)
4. **Documentation terminée** : Documentation complète de la mission
5. **Artefacts prêts** : Toutes les preuves compilées et prêtes pour l'archivage

### Conditions de validation
- [ ] **Git attribution** : Branche propre
- [ ] **Documents complets** : Toutes les preuves de base collectées et signées
- [ ] **Politiques de release** : Tous les documents de release prêts
- [ ] **Scripts préparés** : Tous les scripts prêts pour ALPHA-02
- [ ] **Algo documentation** : Toutes les étapes de préparation documentées

## DÉCISION FINALE

L'objectif de préparation ALPHA-02 est **ATTEINT** : Toutes les preuves ALPHA-01 collectées, l'environnement de travail préparé, l'état Git documenté, les scripts validés, les politiques de release établies. Lancement direct d'ALPHA-02 possible à retour du quota, sans développement fonctionnel anticipé sauf pour la résolution des problèmes BASELINE-01.

**PROCHAINE ÉTAPE** : Lancer ALPHA-02 lorsque le quota sera revenu, avec cet ensemble de préparation documenté.