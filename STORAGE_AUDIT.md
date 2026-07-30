# STORAGE AUDIT REPORT

**Date:** 2026-07-29
**Scope:** Full filesystem audit — Desktop, Documents, Downloads, Xcode, DerivedData, Archives, Simulators, SwiftPM, Homebrew caches, npm caches, pip caches, Ollama, models IA, logs, snapshots, reports, recovery, archives
**Disk:** 460Gi total — 389Gi used (85%) — 46Gi available (10%) post-cleanup

---

## 1. État Actuel

### 1.1 Utilisation par répertoire principal

| Répertoire | Taille | Type | Criticité |
|---|---|---|---|
| `~/.ollama/models` | 22 Gi | Modèles IA (qwen3-coder:latest, qwen3:4b-instruct, qwen3:4b) | CRITIQUE — modèles utilisés |
| `~/.codex` | 1.3 Gi | IDE OpenCode (packages, plugins, sessions, logs) | ÉLEVÉE — régénérable |
| `_NOVA_IMAC_COMMAND_CENTER` | 21 Gi | Archive projet IMAC (01_INDEX_GLOBAL, 02_LEGAL, 03_NOVA_PROJECTS, etc.) | ÉLEVÉE — archives importantes |
| `~/Desktop/NOVA_OS/SUPRA` | 39 Gi | Workspace principal SUPRA | CRITIQUE — code source |
| `~/.cache` | 1.8 Mi | Caches nettoyés (codex-runtimes, whisper, clang supprimés) | NETTOYÉ |
| `~/.npm` | 332 Mi | Cache npm (partiellement nettoyé) | RÉGÉNÉRABLE |
| `~/.gradle` | 527 Mi | Caches gradle (caches, wrapper, daemon nettoyés) | RÉGÉNÉRABLE |
| `~/.local/share/opencode` | 887 Mi | Données OpenCode | MODÉRÉE |
| `~/.opencode` | 193 Mi | Artefacts OpenCode (agents, skills, workflows) | MODÉRÉE |
| `~/Library/Developer/Xcode` | 4 Gi (Xcode.app) + 0B DerivedData | Xcode + DerivedData nettoyé | MODÉRÉE |
| `~/Library/Developer/CoreSimulator` | 385 Mi | Simulators Xcode | RÉGÉNÉRABLE |
| `~/Library/Caches/Homebrew` | 22 Mi | Cache Homebrew | RÉGÉNÉRABLE |
| `~/.swiftpm` | 0B | SwiftPM (vide) | NÉANT |
| `~/.Trash` | 0B | Corbeille (vide) | NÉANT |

### 1.2 Espace récupéré par phase

| Phase | Action | Espace récupéré |
|---|---|---|
| 2.1 | DerivedData (Xcode) | 1.2 Gi |
| 2.2 | Cache npm | ~246 Mi |
| 2.3 | Cache Homebrew | ~22 Mi |
| 2.4 | Caches gradle (caches + wrapper + daemon) | ~581 Mi |
| 2.5 | Cache whisper | 461 Mi |
| 2.6 | Cache codex-runtimes | 1.5 Gi |
| 2.7 | Cache opencode | 82 Mi |
| 2.8 | Cache clang | 124 Mi |
| 2.9 | Sessions codex | 264 Mi |
| **Total** | | **~6.7 Gi** |

---

## 2. Fichiers Régénérables (Éligibles au nettoyage Phase 2)

- ✅ DerivedData (1.2 Gi) — nettoyé
- ✅ Cache npm (578 Mi → 332 Mi restant) — nettoyé
- ✅ Caches gradle (1.1 Gi → 527 Mi restant) — nettoyé
- ✅ Cache codex-runtimes (1.5 Gi) — nettoyé
- ✅ Cache whisper (461 Mi) — nettoyé
- ✅ Cache clang (124 Mi) — nettoyé
- ✅ Cache opencode (82 Mi) — nettoyé
- ✅ Sessions codex (264 Mi) — nettoyé
- ✅ Homebrew caches (22 Mi) — nettoyé
- ✅ SwiftPM (0B — vide)
- ✅ CoreSimulator (385 Mi) — non nettoyé (peut contenir des simulators utiles)

---

## 3. Fichiers Obsolètes Identifiés

### 3.1 Doublons par nom dans le répertoire utilisateur

| Fichier | Copies estimées | Taille estimée | Statut |
|---|---|---|---|
| GO_SUPRA_URL_TO_EXECUTIVE_DOSSIER_V1.sh | 3 (1 original + 2 backups) | ~100 Ko | Redondant |
| GO_SUPRA_URL_TO_EXECUTIVE_DOSSIER_V1.sh.backup_* | 2 | — | Obsolet |
| NOVA · CALM SURFACE SYSTEM.pdf | 2 | ~276 Mo | Doublon |
| Profile_*.pdf | 26 fichiers | ~1.5 Gi potentiel | Doublons |
| WhatsApp Chat - *.zip | 20+ fichiers | Plusieurs Go | Doublons |
| nova_transport_dataset.* | 5 variants | ~25 Ko | Doublons |
| local_search_result*.json / .md | 6+ variants | ~128 Ko | Doublons |
| NICO_APP_LAYERS_AUDIT_* | 3 variants | ~163 Ko | Doublons |
| NOVA_HTML_AUDIT_REPORT.* | 2 (md + zip) | 44 Mo + 2.2 Mo | Doublon |
| MÉMOIRE DE PROCÉDÉ & D'ARCHITECTURE | 3 formats (pdf, gdoc, gdoc.pdf) | ~1.2 Go | Doublon |
| GO_SUPRA_VIDEO_SWAP_OS_V1.sh | 3 copies (1, 2, .sh) | ~114 Ko | Triplé |
| Résultat de Terminal*.txt | 22+ fichiers | ~100 Mo |Logs d'exécution |
| RUN_FROM_DOWNLOADS*.command | 7+ variants | ~1.8 Mo | Obsolet |
| STOS_ARCHITECTURE_BOOK_INDEX* | 2 fichiers | ~2.5 Ko | Doublon |
| SHA256SUMS.txt | 5 doublons | Inconnu | À fusionner |

### 3.2 Fichiers régénérables dans le workspace

- `SUPRA zip.zip` (414 Mo) — archive compressée du workspace
- `NOVA_HTML_AUDIT_REPORT.zip` (2.2 Mo) — doublon compressé
- `GO_SUPRA_SECURE_STORAGE_RECOVER_30GB_V1.zip` (2.9 Mo)
- `GO_SUPRA_TARGETED_SYSTEM_STORAGE_AUDIT_V2.zip` (2.9 Mo)
- `SUPRA_CANONICAL_AUDIT_PARALLEL_V1.zip` (6.8 Mo)
- Tous les `.zip` de livraison (50+ fichiers) — contenus déjà extraits

---

## 4. Fichiers Critiques (Protégés)

### 4.1 Non modifiables

- `~/Desktop/NOVA_OS/SUPRA/` — workspace source (39 Gi)
- `~/.ollama/models/` — modèles IA en usage (22 Gi)
- `~/.ollama/config.json` — configuration Ollama
- `~/.ollama/id_ed25519` — clé SSH Ollama
- `~/Desktop/NOVA_OS/SUPRA/opencode.json` — configuration OpenCode
- `~/Desktop/NOVA_OS/SUPRA/opencode.json.backup.*` — backups de config
- `~/Desktop/NOVA_OS/SUPRA/.git/` — historique Git (772 Mi)
- `~/Desktop/NOVA_OS/SUPRA/AGENTS.md` — instruction agents
- `~/Desktop/NOVA_OS/SUPRA/SUPRA_WORKSPACE_REGISTRY.json` — registre workspace

### 4.2 À conserver (archives importantes)

- `_NOVA_IMAC_COMMAND_CENTER/` — archive projet IMAC (21 Gi)
- `_NOVA_STORAGE_QUARANTINE_*` — quarantaine de stockage
- Tous les `.zip` de livraison avec le préfixe `SUPRA_*_DELIVERY.zip`

---

## 5. Impact

### 5.1 Avant nettoyage

- Espace disponible: **46 Gi** (10%)
- Utilisation: **389 Gi** (90%)

### 5.2 Après nettoyage Phase 2

- Espace disponible: **~53 Gi** (12%) estimation
- Récupéré: **~6.7 Gi** de caches régénérables

### 5.3 Potentiel supplémentaire identifié

| Action | Espace estimé | Risque |
|---|---|---|
| Supprimer les 26 Profile_*.pdf dupliqués | ~1.2 Gi | Faible — garder le plus récent |
| Compresser/supprimer WhatsApp Chat zip duplicates | ~3 Gi | Moyen — vérifier contenu |
| Supprimer les 7 RUN_FROM_DOWNLOADS*.command obsolètes | ~1.8 Mo | Nul |
| Supprimer GO_SUPRA_URL_TO_EXECUTIVE_DOSSIER_V1.sh.backup | ~66 Mo | Nul |
| Supprimer NOVA_HTML_AUDIT_REPORT.md (42 Mo, déjà en zip) | 42 Mo | Nul |
| Nettoyer CoreSimulator inutilisés | 385 Mi | Faible |
| Supprimer vidéos undress-*.mp4 (non pertinentes) | ~4 Gi | Moyen |

**Potentiel total de récupération additionnelle: ~8-10 Gi**

---

## 6. Recommandations

### 6.1 Actions immédiates (Phase 2)

1. ✅ DerivedData nettoyé (1.2 Gi)
2. ✅ Cache npm nettoyé (~246 Mi)
3. ✅ Caches gradle nettoyés (~581 Mi)
4. ✅ Cache codex-runtimes nettoyé (1.5 Gi)
5. ✅ Cache whisper nettoyé (461 Mi)
6. ✅ Cache opencode nettoyé (82 Mi)
7. ✅ Cache clang nettoyé (124 Mi)
8. ✅ Sessions codex nettoyées (264 Mi)
9. ✅ Homebrew caches nettoyés (22 Mi)

### 6.2 Actions recommandées (prochaines)

1. Supprimer les Profile_*.pdf dupliqués — ne garder que Profile.pdf (le plus récent)
2. Supprimer les RUN_FROM_DOWNLOADS*.command obsolètes
3. Supprimer les backups GO_SUPRA_URL_TO_EXECUTIVE_DOSSIER_V1.sh.backup_*
4. Compresser NOVA_HTML_AUDIT_REPORT.md (42 Mo) dans le zip existant, puis supprimer l'original
5. Nettoyer les simulators Xcode inutilisés (CoreSimulator 385 Mi)
6. Supprimer les vidéos undress-*.mp4 (non pertinentes pour SUPRA)
7. Supprimer les doublons WhatsApp Chat zip (garder la version la plus complète)

### 6.3 Actions stratégiques

1. **Migrer les écritures directes sur le Desktop** vers le Runtime Service dédié (cf. WORKSPACE_AUDIT.md)
2. **Consolider les archives _NOVA_IMAC_COMMAND_CENTER** (21 Gi) — envisager la compression et le déplacement vers un stockage externe
3. **Rationaliser les modèles Ollama** — ne garder que qwen3-coder:latest (18 Gi) si les modèles qwen3:4b et qwen3:4b-instruct ne sont pas activement utilisés
4. **Mettre en place un cycle de nettoyage automatique** des caches codex-runtimes et npm

---

## 7. Prochaines Actions

1. Exécuter les recommandations immédiates de suppression des fichiers obsolètes
2. Procéder au Workspace Governance (WORKSPACE_AUDIT.md)
3. Implémenter la stratégie de gouvernance des artefacts via le Runtime Service
4. Préparer le déploiement des modèles locaux prioritaires (Phase 5)
5. Produire la roadmap d'industrialisation (Phase 6)