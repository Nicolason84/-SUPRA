# SUPRA WORKSPACE QUICK WINS

**Version**: 1.0  
**Status**: VALIDATED  
**Category**: Workspace Validation  
**Path**: `SUPRA_WORKSPACE_QUICK_WINS.md`

---

## Quick Wins — Actions Immédiates

### Conditions

- Zéro risque de perte de données
- Entièrement réversible (rollback en une commande)
- Gain de lisibilité immédiat
- Aucune modification de SUPRA CORE
- Aucune création de structure permanente

---

## Priorité P0 — Très Haute

### QW1 — Déplacer les 30 scripts `.sh` du Desktop vers `SUPRA_SCRIPTS/`

| Champ | Valeur |
|-------|--------|
| **Action** | `mv ~/Desktop/*.sh ~/Desktop/SUPRA_SCRIPTS/` (30 fichiers) |
| **Gain** | -30 items à la racine du Desktop ; lisibilité ++ |
| **Risque** | Aucun (réversible) |
| **Rollback** | `mv ~/Desktop/SUPRA_SCRIPTS/*.sh ~/Desktop/` |
| **Dépendance** | Vérifier que SUPRA_SCRIPTS/ n'a pas de conflit de noms |
| **Durée** | 5 minutes |
| **Prérequis** | Audit du contenu actuel de `SUPRA_SCRIPTS/` |
| **Validation** | Desktop passe de ~95 à ~65 items |

### QW2 — Déplacer les fichiers `.log` du Desktop vers `Logs/`

| Champ | Valeur |
|-------|--------|
| **Action** | `mv ~/Desktop/*.log ~/Desktop/NOVA_OS/SUPRA/Logs/` (5 fichiers) |
| **Gain** | -5 items Desktop ; logs centralisés |
| **Risque** | Aucun (copie existante) |
| **Rollback** | `mv ~/Desktop/NOVA_OS/SUPRA/Logs/*.log ~/Desktop/` |
| **Dépendance** | Aucune |
| **Durée** | 1 minute |
| **Validation** | Les logs sont accessibles dans Logs/ |

### QW3 — Déplacer les fichiers `.txt` du Desktop vers `Reports/`

| Champ | Valeur |
|-------|--------|
| **Action** | `mv ~/Desktop/*.txt ~/Desktop/NOVA_OS/SUPRA/Reports/` (10 fichiers) |
| **Gain** | -10 items Desktop ; rapports centralisés |
| **Risque** | Aucun |
| **Rollback** | Reverse mv |
| **Dépendance** | Aucune |
| **Durée** | 1 minute |
| **Validation** | Les rapports sont accessibles dans Reports/ |

### QW4 — Déplacer les fichiers `.md` de test du Desktop vers `SUPRA_TEMP/`

| Champ | Valeur |
|-------|--------|
| **Action** | `mv ~/Desktop/TEST_VALIDATION.md ~/Desktop/TEST_VALIDATION_2.md ~/Desktop/SUPRA_TEMP/` |
| **Gain** | -2 items Desktop |
| **Risque** | Aucun (fichiers de test) |
| **Rollback** | Reverse mv |
| **Dépendance** | Aucune |
| **Durée** | 30 secondes |
| **Validation** | Les fichiers sont dans SUPRA_TEMP/ |

### QW5 — Déplacer les fichiers `.png` du Desktop vers `Evidence/` ou `Artifacts/`

| Champ | Valeur |
|-------|--------|
| **Action** | `mv ~/Desktop/*.png ~/Desktop/NOVA_OS/SUPRA/Evidence/` (4 fichiers) |
| **Gain** | -4 items Desktop |
| **Risque** | Aucun |
| **Rollback** | Reverse mv |
| **Dépendance** | Aucune |
| **Durée** | 30 secondes |
| **Validation** | Les images sont dans Evidence/ |

---

## Priorité P1 — Haute

### QW6 — Archiver le bundle dupliqué `SupraVideoSwap_FINAL 2.app`

| Champ | Valeur |
|-------|--------|
| **Action** | Déplacer le bundle dupliqué vers `SUPRA_ARCHIVE/` |
| **Gain** | -1 item Desktop ; clarification |
| **Risque** | Faible (copie fonctionnelle existe) |
| **Rollback** | Reverse mv |
| **Dépendance** | Décision : quel bundle est le "vrai" ? |
| **Durée** | 2 minutes |
| **Validation** | Un seul bundle FINAL sur le Desktop |
| **Note** | Demander confirmation avant exécution |

### QW7 — Déplacer `opencode.jsonc.DIAG` (ou fichiers diagnostiques similaires)

| Champ | Valeur |
|-------|--------|
| **Action** | Déplacer les fichiers de diagnostic vers `.opencode/` |
| **Gain** | -1 item Desktop |
| **Risque** | Aucun |
| **Rollback** | Reverse mv |
| **Dépendance** | Aucune |
| **Durée** | 30 secondes |

### QW8 — Nettoyer les fichiers `.json` orphelins à la racine (hors SUPRA_*)

| Champ | Valeur |
|-------|--------|
| **Action** | Identifier et déplacer les fichiers JSON non référencés vers `Artifacts/exports/` |
| **Gain** | Réduction du bruit visuel |
| **Risque** | Faible (vérifier chaque fichier) |
| **Dépendance** | Audit rapide des fichiers JSON racine |
| **Durée** | 5 minutes |

---

## Priorité P2 — Moyenne

### QW9 — Ajouter un `.gitignore` pour `SUPRA_TEMP/`

| Champ | Valeur |
|-------|--------|
| **Action** | Ajouter `SUPRA_TEMP/` au `.gitignore` |
| **Gain** | Empêche le commit accidentel de fichiers temporaires |
| **Risque** | Aucun |
| **Rollback** | `git checkout .gitignore` |
| **Dépendance** | Aucune |
| **Durée** | 1 minute |

### QW10 — Créer un alias Desktop pour accès rapide

| Champ | Valeur |
|-------|--------|
| **Action** | `ln -s ~/Desktop/NOVA_OS/SUPRA/ ~/Desktop/SUPRA_CORE` |
| **Gain** | Accès rapide sans navigation |
| **Risque** | Aucun (lien symbolique) |
| **Rollback** | `rm ~/Desktop/SUPRA_CORE` |
| **Dépendance** | Aucune |
| **Durée** | 30 secondes |
| **Note** | Optionnel, dépend des préférences utilisateur |

---

## Ordre d'exécution recommandé

```
QW1  →  Déplacer scripts .sh           [P0]   5 min
QW5  →  Déplacer .png                  [P0]   1 min
QW3  →  Déplacer .txt                  [P0]   1 min
QW2  →  Déplacer .log                  [P0]   1 min
QW4  →  Déplacer .md de test           [P0]   1 min
QW7  →  Déplacer fichiers diag         [P1]   1 min
QW8  →  Nettoyer JSON orphelins        [P1]   5 min
QW6  →  Archiver bundle dupliqué       [P1]   2 min
QW9  →  Ajouter .gitignore             [P2]   1 min
QW10 →  Alias Desktop (optionnel)      [P2]   1 min
```

**Temps total estimé**: ~20 minutes  
**Items Desktop retirés**: ~52  
**Desktop après Quick Wins**: ~43 items (vs ~95 aujourd'hui)

---

## Conditions de succès

| Condition | Statut |
|-----------|--------|
| Backup Desktop avant opérations | À faire |
| Vérification contenu SUPRA_SCRIPTS/ | À faire |
| Décision quel bundle garder | En attente |
| Validation par Executive | Requise |
