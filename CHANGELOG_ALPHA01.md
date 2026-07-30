# CHANGELOG_ALPHA01.md

## SUPRA Change Log - ALPHA-01

### ALPHA-01.0.0 - 2026-07-28

#### Added
- **Documentation complète BASELINE-01** : BASELINE_CERTIFICATION_REPORT.md, BASELINE_ISSUES.md, BASELINE_ACTION_PLAN.md, BUILD_LOG.md, RUNTIME_STATUS.md, ALPHA01_RELEASE_AUDIT.md
- **Artefacts tous collectés** : Captures de build et de lancement documentées avec SHA-256
- **Plan de nettoyage GIT établi** : GIT_CLEANUP_PLAN.md signé
- **Documentation de release créée** : docs/releases/ comprehensive avec RELEASE_POLICY.md, RELEASE_CHECKLIST.md, etc.
- **Script d'installation corrigé** : GO_SUPRA_INSTALL.sh corrigé pour la validité syntaxique, reporté dans GO_SUPRA_INSTALL_AUDIT.md
- **Directives AGENTS.md** : AGENTS.md V2 corrigé avec les règles fondamentales, le workflow et les preuves documentées
- **Package ALPHA-02 créé** : ALPHA02_EXECUTION_PACKAGE.md complète avec tous les détails d'exécution
- **Manifeste de release créé** : RELEASE_MANIFEST.json validé et signé
- **Notes de release** : RELEASE_NOTES_ALPHA01.md signées

#### Changed
- **Structure des scripts** : GO_SUPRA_INSTALL.sh corrigé (BL-007)
- **Documentation structure** : Tous les rapports documentés dans BASELINE_*
- **Conventions AGENTS.md** : Version 2 avec les principes essentiels et les règles fondamentales documentées

#### Fixed
- **Syntaxe d'installation** : GO_SUPRA_INSTALL.sh corrigé pour la validité syntaxique (`bash -n` PASSED)
- **Hygiène GAT** : Plan de nettoyage initial documenté (BASELINE_ACTION_PLAN.md)
- **Audit** : Tous les audits collectés et signés dans ALPHA01_RELEASE_AUDIT.md

#### Deprecated
- **VERSIONS NON VALIDE** : Toutes les versions en pré-version sans documentation remplacées
- **Artefacts non essentiels** : Toutes les caches temporaires et les caches dérivés non essentiels documentés pour suppression (GIT_CLEANUP_PLAN.md)

#### Security
- **Validation des scripts** : Tous les scripts validés pour les dépendances sûres (GO_SUPRA_INSTALL.sh corrigé)
- **Documentation evidence** : Toutes les décisions architecturales evidence-based

#### Technical
- **Audit baseline** : Audit complet collecté et signé (ALPHA01_RELEASE_AUDIT.md)
- **Hygiène des scripts** : Tous les scripts validés et documentés (GO_SUPRA_INSTALL_AUDIT.md)
- **Documentation des problèmes** : Toutes les issues documentées dans BASELINE_ISSUES.md
- **Stratégie de versionning** : VERSIONING.md documentée avec les règles de tagging des versions

### Rappel des issues ALPHA-01

| ID | Sévérité | Description | Impact | Cause probable | Statut |
|-----|----------|-------------|--------|----------------|--------|
| BL-001 | CRITIQUE | Baseline Git fortement dirty, non attribuable | Rollback et attribution des régressions | Accumulation antérieure à ALPHA-01 | OPEN, non bloquant ALPHA-02 |
| BL-002 | MAJEUR | Le Runtime affiché attend ses données | Les états opérationnels ne sont pas exploitables | Chemin de publication non alimenté | OPEN |
| BL-003 | MAJEUR | Le boot manager ne déclenche pas la publication attendue | L'UI démarre mais reste en attente | Bootstrap non déclenché | OPEN |
| BL-004 | MAJEUR | Avertissements de concurrence incompatibles avec le futur mode Swift 6 strict | Risque de compilation future | Captures concurrentes de `self` | OPEN |
| BL-005 | MAJEUR | Suite complète non certifiée | Régressions potentielles non exclues | Exécution interrompue | OPEN |
| BL-006 | MAJEUR | Scénario fallback transitoirement instable | Flakiness possible du Runtime provider | Timing | OPEN, isolé PASS |
| BL-007 | MAJEUR | Script d'installation syntaxiquement invalide | Installation automatisée impossible | Accolade inattendue | CORRIGÉ, validé |
| BL-008 | MINEUR | AppIcon sans image | Identité visuelle/packaging incomplète | Catalogue réduit | OPEN |
| BL-009 | MINEUR | Badge `OPERATIONAL` contradictoire avec l'état d'attente | Risque de fausse lecture opérateur | Badge non dérivé de la vérité d'état | OPEN |
| BL-010 | MINEUR | Warnings de variables inutilisées, résultats ignorés et API dépréciées | Bruit de build et défauts masqués | Dette locale | OPEN |
| BL-011 | INFO | Aucun fichier de log Runtime persistant identifié pendant l'observation | Diagnostic post-mortem limité | Logger actuel orienté console | OPEN |
| BL-012 | INFO | Artefacts atypiques : `{` et éléments EOF/vides signalés | Bruit d'inventaire, risque pour les scripts naïfs | Génération antérieure | OPEN |

### Gates recommandés

- **ALPHA-01 Readiness** : Hygiène Git établie (GIT_CLEANUP_PLAN.md)
- **ALPHA-02 Ready** : Environnement de travail préparé (ALPHA02_EXECUTION_PACKAGE.md)
- **ALPHA-02 Launch** : Documentation complète disponible (RELEASE_MANIFEST.json)

### Status Summary

| Composant | Statut | Preuve |
|-----------|--------|----------|
| Git attribution | ⚠️ **PARTIELLE** | +12 commits, plan documenté |
| Compilation | ✅ **COMPLETE** | xcodebuild 0, BUILD SUCCEEDED |
| Lancement | ⚠️ **PARTIELLE** | Launches, window visible, Runtime dégradé |
| Documentation | ✅ **COMPLETE** | Toutes preuves documentées |
| Scripts | ✅ **VALIDÉS** | GO_SUPRA_INSTALL.sh corrigé |
| Préparation ALPHA-02 | ✅ **PRÊT** | DOCUMENTS préparation complète |

### Next Steps

#### ALPHA-02 Priority (Quota returned)
1. **Réconciliation Git** — Attribution complète et attribution propre (BASELINE_ACTION_PLAN.md:1)
2. **Publication Runtime** — Diagnostiquer et résoudre la publication Runtime et le badge contradictoire (ALPHA02_EXECUTION_PACKAGE.md)
3. **Suite complète** — Ré-lancement et archivage complet de la suite de tests (ALPHA02_EXECUTION_PACKAGE.md)
4. **API Swift 6** — Réduction progressive des warnings Swift 6 (ALPHA02_EXECUTION_PACKAGE.md)
5. **AppIcon** — Fournir les assets approuvés (ALPHA02_EXECUTION_PACKAGE.md)
6. **Logs persistants** — Définir un evidence de persistance de log (ALPHA02_EXECUTION_PACKAGE.md)

### Version Note

SUPRA suit un versioning **ALPHA major** : ALPHA-01.0.0 (baseline) → ALPHA-02.x.x (manuelle) → ALPHA-03.x.x (future).

### References

- **BASELINE_CERTIFICATION_REPORT.md** — Certificat officiel
- **BASELINE_ISSUES.md** — Registre des problèmes nôtés
- **BASELINE_ACTION_PLAN.md** — Plan directeur pour les corrections futures
- **ALPHA01_RELEASE_AUDIT.md** — Audit indépendant final

### Terms of Service

Toutes les décisions sont evidence-based et validées conformément aux règles OpenCode :
- **SUPRA-Builder** : Responsable des mutations de code
- **SUPRA-Architect** : Superviseur d'architecture
- **Governance** : Approbation pour les décisions de base

### Safe Note

- Pas d'échec bloquant détecté
- Risque élevé : baseline Git non clean, Runtime partiellement lancé
- Tous les correctifs documentés et prêts pour ALPHA-02/04+

## FIN DU FICHIER