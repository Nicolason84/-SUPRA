# CLEANUP PLAN — SUPRA ENVIRONMENT TWIN V1

**Règle fondamentale**: NE RIEN SUPPRIMER. Proposer des actions sans les exécuter.

---

## A CONSERVER

| Élément | Justification | Impact | Risque |
|---------|---------------|--------|--------|
| `~/Desktop/NOVA_OS/SUPRA/` | Projet canonique avec build PASS | Critique | Aucun |
| `~/Desktop/NOVA_OS/SUPRA/Packages/CAnnoNicoIntegrationPackage/` | Package intégré au build | Critique | Aucun |
| `~/NOVA_OS/NICO_APP_IOS/NICO_APP/` | Projet iOS actif avec git | Élevé | Aucun |
| `~/NOVA_OS/HELENE_APP_IOS/SUPRA_HELENE/` | Standalone iOS actif | Moyen | Aucun |
| `~/Desktop/SUPRA_VIDEO_SWAP_V3/` | Version récente active | Élevé | Aucun |
| `~/NOVA_BUILD_SYSTEM/` | Orchestration de builds | Élevé | Aucun |

---

## A ARCHIVER (déplacer hors du chemin actif)

| Élément | Destination proposée | Justification | Risque |
|---------|---------------------|---------------|--------|
| `SUPRA_RECOVERY/` | `SUPRA/_SUPRA_BACKUPS/` | Snapshots utiles mais pas quotidiens | Faible — déplacement seul |
| `SUPRA_BISECT/` | `SUPRA/_SUPRA_BACKUPS/` | Copie réduite, obsolète après build stable | Faible |
| `FREEZE_SUPRA_*` (5 dossiers) | `SUPRA/_SUPRA_BACKUPS/freezes/` | Freezes temporels, utiles pour historique | Faible |
| `SUPRA_VIDEO_SWAP_V1_ARCHIVE/` | Archive dédiée | Remplacé par V3 | Faible |
| `SUPRA_PROJECTS/` | Archive dédiée | Références, pas actif | Faible |
| `_DESKTOP_CLEAN_ARCHIVE/` | Archive dédiée | Ancien ménage de Bureau | Faible |

---

## A FUSIONNER

| Élément | Fusionner dans | Justification | Risque |
|---------|---------------|---------------|--------|
| `SUPRA_RECOVERY/CHAT/` → fichiers uniques | `SUPRA/SUPRA/` | Si contient des correctifs non intégrés | **Moyen** — nécessite comparatif |
| `SUPRA_RECOVERY/BRIDGE/` → fichiers uniques | `SUPRA/SUPRA/Bridges/` | Idem | **Moyen** |
| `SUPRA_RECOVERY/HEALTH/` → fichiers uniques | `SUPRA/SUPRA/` | Idem | **Moyen** |
| `SUPRA_RECOVERY/BASELINE/` → fichiers uniques | `SUPRA/SUPRA/` | Idem | **Moyen** |

**Recommandation**: Lancer `diff -r SUPRA_RECOVERY SUPRA` pour identifier des différences avant fusion.

---

## A RENOMMER

| Élément | Nouveau nom proposé | Justification | Risque |
|---------|---------------------|---------------|--------|
| `SUPRA/SUPRA/ContentView.swift.BACKUP_V5_20260718_080641` | `_BACKUP_ContentView.swift.V5` | Backup de version, hors du chemin de compilation | Faible |
| `SUPRA/SUPRA/ContentView.swift.before_ollama_swift6_20260720_160224` | `_BACKUP_ContentView.swift.ollama` | Idem | Faible |
| `SUPRA/SUPRA/UniverseDashboard.swift.bak` | `_BACKUP_UniverseDashboard.swift` | Backup non compilé | Faible |

---

## A DÉPLACER

| Élément | Destination | Justification | Risque |
|---------|-------------|---------------|--------|
| `~/Desktop/SUPRA_TEMP/` | `~/Desktop/NOVA_OS/SUPRA/_SUPRA_BACKUPS/temp/` | Dossier temporaire dans le workspace | Faible |
| Fichiers `.txt/.log` sur le Bureau (236 MB) | `~/Desktop/NOVA_OS/SUPRA/_SUPRA_BACKUPS/logs/` | Logs recovery, pas sur le Bureau | **Moyen** — certains peuvent être importants |
| `SUPRA_SCRIPTS/` (vide) | `~/Desktop/NOVA_OS/SUPRA/_SUPRA_BACKUPS/` | Dossier vide, à supprimer | Faible |

---

## A SUPPRIMER PLUS TARD (après validation)

| Élément | Quand | Justification | Dépendances |
|---------|-------|---------------|-------------|
| `SUPRA_BISECT/` | Après 1 semaine de builds stables | Copie de bissection inutile | Aucune |
| `SUPRA_RECOVERY/` | Après fusion des correctifs uniques | Snapshots récupérés dans SUPRA | Comparaison diff |
| Logs recovery Bureau (236 MB) | Après archivage | Logs de diagnostic, surtout binaires | Aucune |
| `FREEZE_SUPRA_*` | Après archivage dans `_SUPRA_BACKUPS/` | Freezes temporels | Aucune |
| `_DESKTOP_CLEAN_ARCHIVE/` | Après vérification | Ancien ménage | Aucune |
| DerivedData Xcode | Mensuellement | ~28 GB estimés dans les 29 GB de SUPRA | Rebuild nécessaire après |

---

## Estimation Espace Récupérable

| Action | Espace estimé |
|--------|--------------|
| Nettoyage DerivedData Xcode | ~28 GB |
| Suppression logs recovery Bureau | ~236 MB |
| Archivage SUPRA_TEMP | ~33 MB |
| Archivage SUPRA_VIDEO_SWAP_V1 | ~20 MB |
| Archivage SUPRA_PROJECTS | ~13 MB |
| Archivage freezes | ~12 MB |
| **Total estimé** | **~28.3 GB** |

**Note**: La grande majorité de l'espace (28 GB/29 GB) est probablement du DerivedData Xcode.  
Commander `rm -rf ~/Library/Developer/Xcode/DerivedData` récupérerait ~28 GB.

---

## TOP 20 des Actions Prioritaires

| # | Action | Priorité | Effort | Gain |
|---|--------|----------|--------|------|
| 1 | Nettoyer DerivedData Xcode | **Haute** | Faible | ~28 GB |
| 2 | Archiver logs recovery Bureau | **Haute** | Faible | 236 MB |
| 3 | Archiver SUPRA_TEMP | Haute | Faible | 33 MB |
| 4 | Renommer backups ContentView | Haute | Faible | - |
| 5 | Archiver FREEZE_SUPRA_* | Haute | Faible | 12 MB |
| 6 | Archiver SUPRA_VIDEO_SWAP_V1 | Moyenne | Faible | 20 MB |
| 7 | Archiver SUPRA_PROJECTS | Moyenne | Faible | 13 MB |
| 8 | Fusionner SUPRA_RECOVERY différences | Moyenne | **Élevé** | - |
| 9 | Choisir NICO_APP vs NICO_APP_CLEAN | Moyenne | **Élevé** | 5.3 GB |
| 10 | Déplacer SUPRA_BISECT | Moyenne | Faible | 17 MB |
| 11 | Archiver _DESKTOP_CLEAN_ARCHIVE | Basse | Faible | 4.4 MB |
| 12 | Supprimer dossiers vides Desktop | Basse | Faible | - |
| 13 | Consolider SUPRA_HELENE standalone | Basse | Moyen | - |
| 14 | Documenter rôles projets | Basse | Faible | - |
| 15 | Vérifier SUPRA_AST_PLATFORM usage | Basse | Faible | - |
| 16 | Nettoyer les `.bak` dans SUPRA/ | Basse | Faible | - |
| 17 | Archiver COHERENCE_ENGINE | Basse | Faible | 1.3 MB |
| 18 | Vérifier VideoSwap V1 usage | Basse | Faible | - |
| 19 | Supprimer `.DS_Store` superflus | Basse | Faible | - |
| 20 | Audit mensuel DerivedData | Basse | Faible | ~28 GB récurrent |
