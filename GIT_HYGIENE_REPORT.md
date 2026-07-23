# SUPRA — Rapport d’hygiène Git V1

- Mission : `SUPRA_GIT_HYGIENE_V1`
- Date d’audit : 2026-07-22
- Dépôt : `/Users/nicolasalonso/Desktop/NOVA_OS/SUPRA`
- Branche : `supra/human-gate-single-source-20260721_072447`
- Commit observé : `1b2dba9`
- Mode : lecture seule ; aucun build, aucune review et aucune opération sur l’index ou l’historique Git

## Synthèse

L’hygiène Git est actuellement insuffisante. Le dépôt ne possède aucun fichier `.gitignore`, tandis que 1 371 fichiers non suivis sont visibles avant création de ce rapport. Parmi eux, 1 335 proviennent du seul répertoire SwiftPM `Packages/CAnnoNicoIntegrationPackage/.build`, soit environ 44 Mio d’artefacts générés. Le paquet contient aussi cinq fichiers sources/manifeste qui paraissent légitimes, mais aucun élément de `Packages/` n’est suivi.

Risque principal : une commande d’ajout large pourrait mélanger code utile, caches de compilation, données utilisateur Xcode, captures d’écran et sauvegardes ponctuelles.

## 1. `.gitignore`

### Constat

- Aucun fichier `.gitignore` n’existe dans l’arborescence de travail.
- `.git/info/exclude` ignore uniquement `.DS_Store` et `UserInterfaceState.xcuserstate`.
- Ces exclusions locales ne sont pas partageables avec les autres clones.
- Les dossiers `.build/` et `.swiftpm/xcode/xcuserdata/` ne sont pas ignorés.

### Recommandation

Créer ultérieurement un `.gitignore` partagé couvrant au minimum :

```gitignore
.DS_Store
.build/
DerivedData/
*.xcuserstate
xcuserdata/
.swiftpm/xcode/xcuserdata/
```

À valider séparément avant modification : la politique de conservation des captures `*.png`, des rapports générés et des fichiers de sauvegarde horodatés.

## 2. Fichiers non suivis

### État observé avant création du rapport

- 1 371 fichiers non suivis.
- 3 fichiers suivis sont modifiés : `SUPRA.xcodeproj/project.pbxproj`, `SUPRA/ContentView.swift`, `SUPRA/SUPRAApp.swift`. Ils sont signalés uniquement comme contexte et ne sont pas audités ici.
- Le dépôt ne compte actuellement que 8 fichiers suivis.

Répartition des fichiers non suivis :

| Groupe | Nombre | Qualification |
|---|---:|---|
| `Packages/.../.build/` | 1 335 entrées Git visibles | Artefacts générés SwiftPM |
| `Packages/.../.swiftpm/` | 1 | Donnée utilisateur Xcode |
| `Packages/` hors artefacts | 5 | Manifeste et sources probablement destinés au suivi |
| `SUPRA/` | 21 | Sources, JSON et 2 sauvegardes ponctuelles |
| Racine — PNG | 8 | Captures/artefacts visuels, environ 11 Mio |
| Racine — rapport existant | 1 | `SUPRA_MISSION_CENTER_V1_FREEZE_REPORT.md` |

Les deux sauvegardes non suivies identifiées sont :

- `SUPRA/ContentView.swift.BACKUP_V5_20260718_080641`
- `SUPRA/ContentView.swift.before_ollama_swift6_20260720_160224`

## 3. Artefacts générés

### SwiftPM

`Packages/CAnnoNicoIntegrationPackage/.build/` occupe environ 44 Mio et contient 1 334 fichiers physiques. On y trouve notamment caches de modules, index de symboles, objets compilés, dépendances, diagnostics, bases et descriptions de build. Ce contenu est reproductible et ne devrait normalement pas être versionné.

Un répertoire vide distinct, `Packages/CAnnoNicoIntegrationPackage/.build 2/`, est également présent. Son nom indique vraisemblablement une copie accidentelle.

### Xcode et macOS

- `.swiftpm/xcode/xcuserdata/.../xcschememanagement.plist` est une donnée spécifique à l’utilisateur.
- Les fichiers `.DS_Store` existent à la racine et dans `Packages/`; ils sont masqués par `.git/info/exclude`, mais pas par une règle partagée.

### Captures et rapports

Huit PNG non suivis se trouvent à la racine, pour environ 11 Mio au total. Leur nommage indique des captures de validation ou de dashboard. Le rapport `SUPRA_MISSION_CENTER_V1_FREEZE_REPORT.md` semble également être un livrable généré. Leur conservation dans Git doit relever d’une politique explicite, car ils peuvent rapidement alourdir l’historique.

### Sauvegardes

Les deux variantes `BACKUP` / `before_` de `ContentView.swift` sont des copies ponctuelles. Elles devraient être archivées hors du dépôt ou couvertes par une convention d’exclusion si elles ne constituent pas des sources officielles.

## 4. Audit de `Packages/`

Le répertoire occupe environ 44 Mio et aucun de ses fichiers n’est suivi par Git.

Contenu source utile identifié :

- `Packages/CAnnoNicoIntegrationPackage/Package.swift`
- `Packages/CAnnoNicoIntegrationPackage/Sources/CAnnoNicoContracts/CAnnoNicoContracts.swift`
- `Packages/CAnnoNicoIntegrationPackage/Sources/NicoAppAdapter/NicoAppAdapter.swift`
- `Packages/CAnnoNicoIntegrationPackage/Sources/PucheroMemoryAdapter/PucheroMemoryAdapter.swift`
- `Packages/CAnnoNicoIntegrationPackage/Sources/VideoSwapAdapter/VideoSwapAdapter.swift`

Le paquet juxtapose donc cinq fichiers potentiellement versionnables et plus de mille fichiers générés non versionnables. Sans règles d’ignore, l’ajout du paquet est à haut risque.

## Priorités proposées

1. Ajouter des règles partagées pour SwiftPM, Xcode et macOS.
2. Décider explicitement si le manifeste et les quatre sources de `Packages/` appartiennent au dépôt.
3. Définir une politique pour les captures PNG et rapports générés.
4. Déplacer ou ignorer les sauvegardes ponctuelles.
5. Nettoyer ultérieurement `.build/` et `.build 2/` seulement après validation explicite ; aucun nettoyage n’a été effectué pendant cet audit.

## Garantie d’exécution

Cet audit n’a lancé ni build ni review. Il n’a exécuté aucune commande `git add`, `git rm` ou `git commit`, et n’a modifié ni l’index ni l’historique. Le seul fichier créé est le présent rapport demandé par la mission.
