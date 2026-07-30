# Execution Backlog

> **DRAFT — PLAN STRUCTURÉ MAIS PARTIEL — NOT READY FOR IMPLEMENTATION**
>
> [FACT] `EXECUTIVE_EVENT_MODEL.md`, `RUNTIME_LAWS.md` et `UI_PHILOSOPHY.md` sont absents des sources autorisées. **G0 est rouge.**
> [EVIDENCE] Base exclusive: `ULTIMATE_CONSOLIDATION_REPORT.md`, `SUPRA_CANON.md`, `EXECUTIVE_RUNTIME.md`, `EXECUTIVE_OBJECT_MODEL.md`, `AGENTS.md`, `DEPENDENCY_MAP.md`.
> [PROPOSAL] Toute sortie produit décrite ici est future. Aucun contrat manquant n’est inventé.

## Convention de preuve et rollback

[PROPOSAL] Chaque mission utilise `Evidence/<ID>/before.sha256`, `before.status`, `allowlist.txt`, `change.patch`, `inverse.patch`, `commands.log`, `tests.log`, `after.sha256`, `certificate.md`. Si `git status --short -- <allowlist>` révèle un chevauchement non attribuable: **STOP**, aucune mutation. Rollback: appliquer `inverse.patch` chemin par chemin, ou restaurer chaque artefact depuis son archive nommée dans le manifest; toute réinitialisation globale du dépôt est interdite.

## LOT 1 Architecture

### A01 — Certifier sources et G0

- **Statut:** CANDIDATE READY — lecture seule
- **Objectif spécifique:** [PROPOSAL] inventorier les références et usages pour Certifier sources et G0; symboles fermés: SUPRAOperationalCoreApp, SUPRAOSProductRootView, ExecutiveWindow, SUPRACompositionRoot, RuntimeSnapshot, Execution.
- **Description:** Produire seulement l’incrément A01, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRAOperationalCoreApp, SUPRAOSProductRootView, ExecutiveWindow, SUPRACompositionRoot, RuntimeSnapshot, Execution; chemins: ULTIMATE_CONSOLIDATION_REPORT.md; SUPRA_CANON.md; EXECUTIVE_RUNTIME.md; EXECUTIVE_OBJECT_MODEL.md.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `aucune` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** docs/architecture/ADR-A01-G0-SOURCE-CERTIFICATION.md (sortie future proposée; aucun contenu normatif présumé).
- **Preuves exactes:** `Evidence/A01/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/A01/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/A01/allowlist.txt)` attendu exit 0; commande domaine `test -s ULTIMATE_CONSOLIDATION_REPORT.md && test -s SUPRA_CANON.md && test -s EXECUTIVE_RUNTIME.md && test -s EXECUTIVE_OBJECT_MODEL.md` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRAOperationalCoreApp, SUPRAOSProductRootView, ExecutiveWindow`; `git diff --check -- $(tr '\n' ' ' < Evidence/A01/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Certifier sources et G0 démontré dans `tests.log`.
- **Risque spécifique:** décision architecturale non prouvée; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/A01/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `test -s ULTIMATE_CONSOLIDATION_REPORT.md && test -s SUPRA_CANON.md && test -s EXECUTIVE_RUNTIME.md && test -s EXECUTIVE_OBJECT_MODEL.md` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** aucune. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### A02 — Capturer baseline attribuable

- **Statut:** BLOCKED — A01
- **Objectif spécifique:** [PROPOSAL] définir l’adaptateur minimal pour Capturer baseline attribuable; symboles fermés: SUPRAOperationalCoreApp, SUPRAOSProductRootView, ExecutiveWindow, SUPRACompositionRoot, RuntimeSnapshot, Execution.
- **Description:** Produire seulement l’incrément A02, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRAOperationalCoreApp, SUPRAOSProductRootView, ExecutiveWindow, SUPRACompositionRoot, RuntimeSnapshot, Execution; chemins: ULTIMATE_CONSOLIDATION_REPORT.md; SUPRA_CANON.md; EXECUTIVE_RUNTIME.md; EXECUTIVE_OBJECT_MODEL.md.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `A01` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** docs/architecture/ADR-A02-BASELINE-ATTRIBUTION.md (sortie future proposée; aucun contenu normatif présumé).
- **Preuves exactes:** `Evidence/A02/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/A02/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/A02/allowlist.txt)` attendu exit 0; commande domaine `test -s ULTIMATE_CONSOLIDATION_REPORT.md && test -s SUPRA_CANON.md && test -s EXECUTIVE_RUNTIME.md && test -s EXECUTIVE_OBJECT_MODEL.md` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRAOperationalCoreApp, SUPRAOSProductRootView, ExecutiveWindow`; `git diff --check -- $(tr '\n' ' ' < Evidence/A02/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Capturer baseline attribuable démontré dans `tests.log`.
- **Risque spécifique:** décision architecturale non prouvée; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/A02/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `test -s ULTIMATE_CONSOLIDATION_REPORT.md && test -s SUPRA_CANON.md && test -s EXECUTIVE_RUNTIME.md && test -s EXECUTIVE_OBJECT_MODEL.md` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** A01. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### A03 — ADR shell unique

- **Statut:** SOURCE-BLOCKED — G0 + A02
- **Objectif spécifique:** [PROPOSAL] raccorder un seul flux pour ADR shell unique; symboles fermés: SUPRAOperationalCoreApp, SUPRAOSProductRootView, ExecutiveWindow, SUPRACompositionRoot, RuntimeSnapshot, Execution.
- **Description:** Produire seulement l’incrément A03, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRAOperationalCoreApp, SUPRAOSProductRootView, ExecutiveWindow, SUPRACompositionRoot, RuntimeSnapshot, Execution; chemins: ULTIMATE_CONSOLIDATION_REPORT.md; SUPRA_CANON.md; EXECUTIVE_RUNTIME.md; EXECUTIVE_OBJECT_MODEL.md.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `A02` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** docs/architecture/ADR-A03-SINGLE-EXECUTIVE-SHELL.md (sortie future proposée; aucun contenu normatif présumé).
- **Preuves exactes:** `Evidence/A03/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/A03/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/A03/allowlist.txt)` attendu exit 0; commande domaine `test -s ULTIMATE_CONSOLIDATION_REPORT.md && test -s SUPRA_CANON.md && test -s EXECUTIVE_RUNTIME.md && test -s EXECUTIVE_OBJECT_MODEL.md` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRAOperationalCoreApp, SUPRAOSProductRootView, ExecutiveWindow`; `git diff --check -- $(tr '\n' ' ' < Evidence/A03/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère ADR shell unique démontré dans `tests.log`.
- **Risque spécifique:** décision architecturale non prouvée; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/A03/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `test -s ULTIMATE_CONSOLIDATION_REPORT.md && test -s SUPRA_CANON.md && test -s EXECUTIVE_RUNTIME.md && test -s EXECUTIVE_OBJECT_MODEL.md` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** A02. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### A04 — ADR Composition Root

- **Statut:** SOURCE-BLOCKED — G0 + A03
- **Objectif spécifique:** [PROPOSAL] prouver la parité nominale et dégradée pour ADR Composition Root; symboles fermés: SUPRAOperationalCoreApp, SUPRAOSProductRootView, ExecutiveWindow, SUPRACompositionRoot, RuntimeSnapshot, Execution.
- **Description:** Produire seulement l’incrément A04, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRAOperationalCoreApp, SUPRAOSProductRootView, ExecutiveWindow, SUPRACompositionRoot, RuntimeSnapshot, Execution; chemins: ULTIMATE_CONSOLIDATION_REPORT.md; SUPRA_CANON.md; EXECUTIVE_RUNTIME.md; EXECUTIVE_OBJECT_MODEL.md.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `A03` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** docs/architecture/ADR-A04-COMPOSITION-ROOT.md (sortie future proposée; aucun contenu normatif présumé).
- **Preuves exactes:** `Evidence/A04/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/A04/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/A04/allowlist.txt)` attendu exit 0; commande domaine `test -s ULTIMATE_CONSOLIDATION_REPORT.md && test -s SUPRA_CANON.md && test -s EXECUTIVE_RUNTIME.md && test -s EXECUTIVE_OBJECT_MODEL.md` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRAOperationalCoreApp, SUPRAOSProductRootView, ExecutiveWindow`; `git diff --check -- $(tr '\n' ' ' < Evidence/A04/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère ADR Composition Root démontré dans `tests.log`.
- **Risque spécifique:** décision architecturale non prouvée; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/A04/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `test -s ULTIMATE_CONSOLIDATION_REPORT.md && test -s SUPRA_CANON.md && test -s EXECUTIVE_RUNTIME.md && test -s EXECUTIVE_OBJECT_MODEL.md` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** A03. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### A05 — ADR ownership Execution

- **Statut:** SOURCE-BLOCKED — G0 + A04
- **Objectif spécifique:** [PROPOSAL] inventorier les références et usages pour ADR ownership Execution; symboles fermés: SUPRAOperationalCoreApp, SUPRAOSProductRootView, ExecutiveWindow, SUPRACompositionRoot, RuntimeSnapshot, Execution.
- **Description:** Produire seulement l’incrément A05, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRAOperationalCoreApp, SUPRAOSProductRootView, ExecutiveWindow, SUPRACompositionRoot, RuntimeSnapshot, Execution; chemins: ULTIMATE_CONSOLIDATION_REPORT.md; SUPRA_CANON.md; EXECUTIVE_RUNTIME.md; EXECUTIVE_OBJECT_MODEL.md.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `A04` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** docs/architecture/ADR-A05-EXECUTION-OWNERSHIP.md (sortie future proposée; aucun contenu normatif présumé).
- **Preuves exactes:** `Evidence/A05/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/A05/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/A05/allowlist.txt)` attendu exit 0; commande domaine `test -s ULTIMATE_CONSOLIDATION_REPORT.md && test -s SUPRA_CANON.md && test -s EXECUTIVE_RUNTIME.md && test -s EXECUTIVE_OBJECT_MODEL.md` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRAOperationalCoreApp, SUPRAOSProductRootView, ExecutiveWindow`; `git diff --check -- $(tr '\n' ' ' < Evidence/A05/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère ADR ownership Execution démontré dans `tests.log`.
- **Risque spécifique:** décision architecturale non prouvée; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/A05/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `test -s ULTIMATE_CONSOLIDATION_REPORT.md && test -s SUPRA_CANON.md && test -s EXECUTIVE_RUNTIME.md && test -s EXECUTIVE_OBJECT_MODEL.md` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** A04. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### A06 — Contrat RuntimeSnapshot

- **Statut:** SOURCE-BLOCKED — G0 + A05
- **Objectif spécifique:** [PROPOSAL] définir l’adaptateur minimal pour Contrat RuntimeSnapshot; symboles fermés: SUPRAOperationalCoreApp, SUPRAOSProductRootView, ExecutiveWindow, SUPRACompositionRoot, RuntimeSnapshot, Execution.
- **Description:** Produire seulement l’incrément A06, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRAOperationalCoreApp, SUPRAOSProductRootView, ExecutiveWindow, SUPRACompositionRoot, RuntimeSnapshot, Execution; chemins: ULTIMATE_CONSOLIDATION_REPORT.md; SUPRA_CANON.md; EXECUTIVE_RUNTIME.md; EXECUTIVE_OBJECT_MODEL.md.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `A05` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** docs/architecture/ADR-A06-RUNTIME-SNAPSHOT-CONTRACT.md (sortie future proposée; aucun contenu normatif présumé).
- **Preuves exactes:** `Evidence/A06/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/A06/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/A06/allowlist.txt)` attendu exit 0; commande domaine `test -s ULTIMATE_CONSOLIDATION_REPORT.md && test -s SUPRA_CANON.md && test -s EXECUTIVE_RUNTIME.md && test -s EXECUTIVE_OBJECT_MODEL.md` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRAOperationalCoreApp, SUPRAOSProductRootView, ExecutiveWindow`; `git diff --check -- $(tr '\n' ' ' < Evidence/A06/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Contrat RuntimeSnapshot démontré dans `tests.log`.
- **Risque spécifique:** décision architecturale non prouvée; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/A06/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `test -s ULTIMATE_CONSOLIDATION_REPORT.md && test -s SUPRA_CANON.md && test -s EXECUTIVE_RUNTIME.md && test -s EXECUTIVE_OBJECT_MODEL.md` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** A05. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### A07 — Contrat provenance

- **Statut:** SOURCE-BLOCKED — G0 + A06
- **Objectif spécifique:** [PROPOSAL] raccorder un seul flux pour Contrat provenance; symboles fermés: SUPRAOperationalCoreApp, SUPRAOSProductRootView, ExecutiveWindow, SUPRACompositionRoot, RuntimeSnapshot, Execution.
- **Description:** Produire seulement l’incrément A07, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRAOperationalCoreApp, SUPRAOSProductRootView, ExecutiveWindow, SUPRACompositionRoot, RuntimeSnapshot, Execution; chemins: ULTIMATE_CONSOLIDATION_REPORT.md; SUPRA_CANON.md; EXECUTIVE_RUNTIME.md; EXECUTIVE_OBJECT_MODEL.md.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `A06` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** docs/architecture/ADR-A07-PROVENANCE-CONTRACT.md (sortie future proposée; aucun contenu normatif présumé).
- **Preuves exactes:** `Evidence/A07/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/A07/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/A07/allowlist.txt)` attendu exit 0; commande domaine `test -s ULTIMATE_CONSOLIDATION_REPORT.md && test -s SUPRA_CANON.md && test -s EXECUTIVE_RUNTIME.md && test -s EXECUTIVE_OBJECT_MODEL.md` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRAOperationalCoreApp, SUPRAOSProductRootView, ExecutiveWindow`; `git diff --check -- $(tr '\n' ' ' < Evidence/A07/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Contrat provenance démontré dans `tests.log`.
- **Risque spécifique:** décision architecturale non prouvée; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/A07/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `test -s ULTIMATE_CONSOLIDATION_REPORT.md && test -s SUPRA_CANON.md && test -s EXECUTIVE_RUNTIME.md && test -s EXECUTIVE_OBJECT_MODEL.md` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** A06. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### A08 — Contrat identité/version

- **Statut:** SOURCE-BLOCKED — G0 + A07
- **Objectif spécifique:** [PROPOSAL] prouver la parité nominale et dégradée pour Contrat identité/version; symboles fermés: SUPRAOperationalCoreApp, SUPRAOSProductRootView, ExecutiveWindow, SUPRACompositionRoot, RuntimeSnapshot, Execution.
- **Description:** Produire seulement l’incrément A08, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRAOperationalCoreApp, SUPRAOSProductRootView, ExecutiveWindow, SUPRACompositionRoot, RuntimeSnapshot, Execution; chemins: ULTIMATE_CONSOLIDATION_REPORT.md; SUPRA_CANON.md; EXECUTIVE_RUNTIME.md; EXECUTIVE_OBJECT_MODEL.md.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `A07` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** docs/architecture/ADR-A08-IDENTITY-VERSIONING.md (sortie future proposée; aucun contenu normatif présumé).
- **Preuves exactes:** `Evidence/A08/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/A08/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/A08/allowlist.txt)` attendu exit 0; commande domaine `test -s ULTIMATE_CONSOLIDATION_REPORT.md && test -s SUPRA_CANON.md && test -s EXECUTIVE_RUNTIME.md && test -s EXECUTIVE_OBJECT_MODEL.md` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRAOperationalCoreApp, SUPRAOSProductRootView, ExecutiveWindow`; `git diff --check -- $(tr '\n' ' ' < Evidence/A08/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Contrat identité/version démontré dans `tests.log`.
- **Risque spécifique:** décision architecturale non prouvée; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/A08/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `test -s ULTIMATE_CONSOLIDATION_REPORT.md && test -s SUPRA_CANON.md && test -s EXECUTIVE_RUNTIME.md && test -s EXECUTIVE_OBJECT_MODEL.md` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** A07. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### A09 — Frontières de domaines

- **Statut:** SOURCE-BLOCKED — G0 + A08
- **Objectif spécifique:** [PROPOSAL] inventorier les références et usages pour Frontières de domaines; symboles fermés: SUPRAOperationalCoreApp, SUPRAOSProductRootView, ExecutiveWindow, SUPRACompositionRoot, RuntimeSnapshot, Execution.
- **Description:** Produire seulement l’incrément A09, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRAOperationalCoreApp, SUPRAOSProductRootView, ExecutiveWindow, SUPRACompositionRoot, RuntimeSnapshot, Execution; chemins: ULTIMATE_CONSOLIDATION_REPORT.md; SUPRA_CANON.md; EXECUTIVE_RUNTIME.md; EXECUTIVE_OBJECT_MODEL.md.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `A08` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** docs/architecture/ADR-A09-DOMAIN-BOUNDARIES.md (sortie future proposée; aucun contenu normatif présumé).
- **Preuves exactes:** `Evidence/A09/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/A09/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/A09/allowlist.txt)` attendu exit 0; commande domaine `test -s ULTIMATE_CONSOLIDATION_REPORT.md && test -s SUPRA_CANON.md && test -s EXECUTIVE_RUNTIME.md && test -s EXECUTIVE_OBJECT_MODEL.md` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRAOperationalCoreApp, SUPRAOSProductRootView, ExecutiveWindow`; `git diff --check -- $(tr '\n' ' ' < Evidence/A09/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Frontières de domaines démontré dans `tests.log`.
- **Risque spécifique:** décision architecturale non prouvée; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/A09/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `test -s ULTIMATE_CONSOLIDATION_REPORT.md && test -s SUPRA_CANON.md && test -s EXECUTIVE_RUNTIME.md && test -s EXECUTIVE_OBJECT_MODEL.md` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** A08. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### A10 — Carte de migration

- **Statut:** SOURCE-BLOCKED — G0 + A09
- **Objectif spécifique:** [PROPOSAL] définir l’adaptateur minimal pour Carte de migration; symboles fermés: SUPRAOperationalCoreApp, SUPRAOSProductRootView, ExecutiveWindow, SUPRACompositionRoot, RuntimeSnapshot, Execution.
- **Description:** Produire seulement l’incrément A10, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRAOperationalCoreApp, SUPRAOSProductRootView, ExecutiveWindow, SUPRACompositionRoot, RuntimeSnapshot, Execution; chemins: ULTIMATE_CONSOLIDATION_REPORT.md; SUPRA_CANON.md; EXECUTIVE_RUNTIME.md; EXECUTIVE_OBJECT_MODEL.md.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `A09` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** docs/architecture/ADR-A10-MIGRATION-MAP.md (sortie future proposée; aucun contenu normatif présumé).
- **Preuves exactes:** `Evidence/A10/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/A10/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/A10/allowlist.txt)` attendu exit 0; commande domaine `test -s ULTIMATE_CONSOLIDATION_REPORT.md && test -s SUPRA_CANON.md && test -s EXECUTIVE_RUNTIME.md && test -s EXECUTIVE_OBJECT_MODEL.md` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRAOperationalCoreApp, SUPRAOSProductRootView, ExecutiveWindow`; `git diff --check -- $(tr '\n' ' ' < Evidence/A10/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Carte de migration démontré dans `tests.log`.
- **Risque spécifique:** décision architecturale non prouvée; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/A10/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `test -s ULTIMATE_CONSOLIDATION_REPORT.md && test -s SUPRA_CANON.md && test -s EXECUTIVE_RUNTIME.md && test -s EXECUTIVE_OBJECT_MODEL.md` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** A09. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### A11 — Certifier CP0

- **Statut:** SOURCE-BLOCKED — G0 + A10
- **Objectif spécifique:** [PROPOSAL] raccorder un seul flux pour Certifier CP0; symboles fermés: SUPRAOperationalCoreApp, SUPRAOSProductRootView, ExecutiveWindow, SUPRACompositionRoot, RuntimeSnapshot, Execution.
- **Description:** Produire seulement l’incrément A11, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRAOperationalCoreApp, SUPRAOSProductRootView, ExecutiveWindow, SUPRACompositionRoot, RuntimeSnapshot, Execution; chemins: ULTIMATE_CONSOLIDATION_REPORT.md; SUPRA_CANON.md; EXECUTIVE_RUNTIME.md; EXECUTIVE_OBJECT_MODEL.md.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `A10` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** docs/architecture/ADR-A11-CP0-CERTIFICATION.md (sortie future proposée; aucun contenu normatif présumé).
- **Preuves exactes:** `Evidence/A11/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/A11/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/A11/allowlist.txt)` attendu exit 0; commande domaine `test -s ULTIMATE_CONSOLIDATION_REPORT.md && test -s SUPRA_CANON.md && test -s EXECUTIVE_RUNTIME.md && test -s EXECUTIVE_OBJECT_MODEL.md` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRAOperationalCoreApp, SUPRAOSProductRootView, ExecutiveWindow`; `git diff --check -- $(tr '\n' ' ' < Evidence/A11/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Certifier CP0 démontré dans `tests.log`.
- **Risque spécifique:** décision architecturale non prouvée; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/A11/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `test -s ULTIMATE_CONSOLIDATION_REPORT.md && test -s SUPRA_CANON.md && test -s EXECUTIVE_RUNTIME.md && test -s EXECUTIVE_OBJECT_MODEL.md` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** A10. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

## LOT 2 Runtime

### R01 — Baseline Runtime existant

- **Statut:** SOURCE-BLOCKED — G0 + A11
- **Objectif spécifique:** [PROPOSAL] inventorier les références et usages pour Baseline Runtime existant; symboles fermés: SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot, RuntimeDiagnosticsView, RuntimeDataService, RuntimeGateway, RuntimeMonitor, SUPRARuntimeEvents, SUPRARuntimeGraph, SUPRARuntimeMetrics, SUPRARuntimeLogger.
- **Description:** Produire seulement l’incrément R01, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot, RuntimeDiagnosticsView, RuntimeDataService, RuntimeGateway, RuntimeMonitor, SUPRARuntimeEvents, SUPRARuntimeGraph, SUPRARuntimeMetrics, SUPRARuntimeLogger; chemins: SUPRA/SUPRACompositionRoot.swift; SUPRA/RuntimeDiagnosticsView.swift; sources Runtime autorisées par allowlist PLAN.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `A11` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/SUPRACompositionRoot.swift; SUPRA/RuntimeDiagnosticsView.swift; sources Runtime autorisées par allowlist PLAN — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/R01/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/R01/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/R01/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx build` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot`; `git diff --check -- $(tr '\n' ' ' < Evidence/R01/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Baseline Runtime existant démontré dans `tests.log`.
- **Risque spécifique:** double publication ou snapshot non atomique; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/R01/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx build` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** A11. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### R02 — Adapter SUPRACompositionRoot

- **Statut:** SOURCE-BLOCKED — G0 + R01
- **Objectif spécifique:** [PROPOSAL] définir l’adaptateur minimal pour Adapter SUPRACompositionRoot; symboles fermés: SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot, RuntimeDiagnosticsView, RuntimeDataService, RuntimeGateway, RuntimeMonitor, SUPRARuntimeEvents, SUPRARuntimeGraph, SUPRARuntimeMetrics, SUPRARuntimeLogger.
- **Description:** Produire seulement l’incrément R02, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot, RuntimeDiagnosticsView, RuntimeDataService, RuntimeGateway, RuntimeMonitor, SUPRARuntimeEvents, SUPRARuntimeGraph, SUPRARuntimeMetrics, SUPRARuntimeLogger; chemins: SUPRA/SUPRACompositionRoot.swift; SUPRA/RuntimeDiagnosticsView.swift; sources Runtime autorisées par allowlist PLAN.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `R01` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/SUPRACompositionRoot.swift; SUPRA/RuntimeDiagnosticsView.swift; sources Runtime autorisées par allowlist PLAN — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/R02/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/R02/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/R02/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx build` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot`; `git diff --check -- $(tr '\n' ' ' < Evidence/R02/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Adapter SUPRACompositionRoot démontré dans `tests.log`.
- **Risque spécifique:** double publication ou snapshot non atomique; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/R02/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx build` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** R01. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### R03 — Façade RuntimeKernel

- **Statut:** SOURCE-BLOCKED — G0 + R02
- **Objectif spécifique:** [PROPOSAL] raccorder un seul flux pour Façade RuntimeKernel; symboles fermés: SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot, RuntimeDiagnosticsView, RuntimeDataService, RuntimeGateway, RuntimeMonitor, SUPRARuntimeEvents, SUPRARuntimeGraph, SUPRARuntimeMetrics, SUPRARuntimeLogger.
- **Description:** Produire seulement l’incrément R03, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot, RuntimeDiagnosticsView, RuntimeDataService, RuntimeGateway, RuntimeMonitor, SUPRARuntimeEvents, SUPRARuntimeGraph, SUPRARuntimeMetrics, SUPRARuntimeLogger; chemins: SUPRA/SUPRACompositionRoot.swift; SUPRA/RuntimeDiagnosticsView.swift; sources Runtime autorisées par allowlist PLAN.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `R02` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/SUPRACompositionRoot.swift; SUPRA/RuntimeDiagnosticsView.swift; sources Runtime autorisées par allowlist PLAN — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/R03/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/R03/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/R03/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx build` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot`; `git diff --check -- $(tr '\n' ' ' < Evidence/R03/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Façade RuntimeKernel démontré dans `tests.log`.
- **Risque spécifique:** double publication ou snapshot non atomique; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/R03/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx build` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** R02. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### R04 — Façade MissionEngine

- **Statut:** SOURCE-BLOCKED — G0 + R03
- **Objectif spécifique:** [PROPOSAL] prouver la parité nominale et dégradée pour Façade MissionEngine; symboles fermés: SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot, RuntimeDiagnosticsView, RuntimeDataService, RuntimeGateway, RuntimeMonitor, SUPRARuntimeEvents, SUPRARuntimeGraph, SUPRARuntimeMetrics, SUPRARuntimeLogger.
- **Description:** Produire seulement l’incrément R04, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot, RuntimeDiagnosticsView, RuntimeDataService, RuntimeGateway, RuntimeMonitor, SUPRARuntimeEvents, SUPRARuntimeGraph, SUPRARuntimeMetrics, SUPRARuntimeLogger; chemins: SUPRA/SUPRACompositionRoot.swift; SUPRA/RuntimeDiagnosticsView.swift; sources Runtime autorisées par allowlist PLAN.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `R03` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/SUPRACompositionRoot.swift; SUPRA/RuntimeDiagnosticsView.swift; sources Runtime autorisées par allowlist PLAN — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/R04/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/R04/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/R04/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx build` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot`; `git diff --check -- $(tr '\n' ' ' < Evidence/R04/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Façade MissionEngine démontré dans `tests.log`.
- **Risque spécifique:** double publication ou snapshot non atomique; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/R04/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx build` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** R03. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### R05 — Façade MemoryEngine

- **Statut:** SOURCE-BLOCKED — G0 + R04
- **Objectif spécifique:** [PROPOSAL] inventorier les références et usages pour Façade MemoryEngine; symboles fermés: SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot, RuntimeDiagnosticsView, RuntimeDataService, RuntimeGateway, RuntimeMonitor, SUPRARuntimeEvents, SUPRARuntimeGraph, SUPRARuntimeMetrics, SUPRARuntimeLogger.
- **Description:** Produire seulement l’incrément R05, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot, RuntimeDiagnosticsView, RuntimeDataService, RuntimeGateway, RuntimeMonitor, SUPRARuntimeEvents, SUPRARuntimeGraph, SUPRARuntimeMetrics, SUPRARuntimeLogger; chemins: SUPRA/SUPRACompositionRoot.swift; SUPRA/RuntimeDiagnosticsView.swift; sources Runtime autorisées par allowlist PLAN.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `R04` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/SUPRACompositionRoot.swift; SUPRA/RuntimeDiagnosticsView.swift; sources Runtime autorisées par allowlist PLAN — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/R05/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/R05/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/R05/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx build` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot`; `git diff --check -- $(tr '\n' ' ' < Evidence/R05/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Façade MemoryEngine démontré dans `tests.log`.
- **Risque spécifique:** double publication ou snapshot non atomique; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/R05/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx build` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** R04. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### R06 — Façade KnowledgeEngine

- **Statut:** SOURCE-BLOCKED — G0 + R05
- **Objectif spécifique:** [PROPOSAL] définir l’adaptateur minimal pour Façade KnowledgeEngine; symboles fermés: SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot, RuntimeDiagnosticsView, RuntimeDataService, RuntimeGateway, RuntimeMonitor, SUPRARuntimeEvents, SUPRARuntimeGraph, SUPRARuntimeMetrics, SUPRARuntimeLogger.
- **Description:** Produire seulement l’incrément R06, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot, RuntimeDiagnosticsView, RuntimeDataService, RuntimeGateway, RuntimeMonitor, SUPRARuntimeEvents, SUPRARuntimeGraph, SUPRARuntimeMetrics, SUPRARuntimeLogger; chemins: SUPRA/SUPRACompositionRoot.swift; SUPRA/RuntimeDiagnosticsView.swift; sources Runtime autorisées par allowlist PLAN.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `R05` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/SUPRACompositionRoot.swift; SUPRA/RuntimeDiagnosticsView.swift; sources Runtime autorisées par allowlist PLAN — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/R06/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/R06/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/R06/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx build` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot`; `git diff --check -- $(tr '\n' ' ' < Evidence/R06/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Façade KnowledgeEngine démontré dans `tests.log`.
- **Risque spécifique:** double publication ou snapshot non atomique; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/R06/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx build` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** R05. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### R07 — Façade DecisionEngine

- **Statut:** SOURCE-BLOCKED — G0 + R06
- **Objectif spécifique:** [PROPOSAL] raccorder un seul flux pour Façade DecisionEngine; symboles fermés: SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot, RuntimeDiagnosticsView, RuntimeDataService, RuntimeGateway, RuntimeMonitor, SUPRARuntimeEvents, SUPRARuntimeGraph, SUPRARuntimeMetrics, SUPRARuntimeLogger.
- **Description:** Produire seulement l’incrément R07, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot, RuntimeDiagnosticsView, RuntimeDataService, RuntimeGateway, RuntimeMonitor, SUPRARuntimeEvents, SUPRARuntimeGraph, SUPRARuntimeMetrics, SUPRARuntimeLogger; chemins: SUPRA/SUPRACompositionRoot.swift; SUPRA/RuntimeDiagnosticsView.swift; sources Runtime autorisées par allowlist PLAN.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `R06` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/SUPRACompositionRoot.swift; SUPRA/RuntimeDiagnosticsView.swift; sources Runtime autorisées par allowlist PLAN — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/R07/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/R07/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/R07/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx build` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot`; `git diff --check -- $(tr '\n' ' ' < Evidence/R07/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Façade DecisionEngine démontré dans `tests.log`.
- **Risque spécifique:** double publication ou snapshot non atomique; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/R07/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx build` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** R06. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### R08 — Façade DiscoveryEngine

- **Statut:** SOURCE-BLOCKED — G0 + R07
- **Objectif spécifique:** [PROPOSAL] prouver la parité nominale et dégradée pour Façade DiscoveryEngine; symboles fermés: SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot, RuntimeDiagnosticsView, RuntimeDataService, RuntimeGateway, RuntimeMonitor, SUPRARuntimeEvents, SUPRARuntimeGraph, SUPRARuntimeMetrics, SUPRARuntimeLogger.
- **Description:** Produire seulement l’incrément R08, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot, RuntimeDiagnosticsView, RuntimeDataService, RuntimeGateway, RuntimeMonitor, SUPRARuntimeEvents, SUPRARuntimeGraph, SUPRARuntimeMetrics, SUPRARuntimeLogger; chemins: SUPRA/SUPRACompositionRoot.swift; SUPRA/RuntimeDiagnosticsView.swift; sources Runtime autorisées par allowlist PLAN.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `R07` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/SUPRACompositionRoot.swift; SUPRA/RuntimeDiagnosticsView.swift; sources Runtime autorisées par allowlist PLAN — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/R08/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/R08/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/R08/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx build` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot`; `git diff --check -- $(tr '\n' ' ' < Evidence/R08/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Façade DiscoveryEngine démontré dans `tests.log`.
- **Risque spécifique:** double publication ou snapshot non atomique; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/R08/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx build` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** R07. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### R09 — Façade EvidenceEngine

- **Statut:** SOURCE-BLOCKED — G0 + R08
- **Objectif spécifique:** [PROPOSAL] inventorier les références et usages pour Façade EvidenceEngine; symboles fermés: SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot, RuntimeDiagnosticsView, RuntimeDataService, RuntimeGateway, RuntimeMonitor, SUPRARuntimeEvents, SUPRARuntimeGraph, SUPRARuntimeMetrics, SUPRARuntimeLogger.
- **Description:** Produire seulement l’incrément R09, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot, RuntimeDiagnosticsView, RuntimeDataService, RuntimeGateway, RuntimeMonitor, SUPRARuntimeEvents, SUPRARuntimeGraph, SUPRARuntimeMetrics, SUPRARuntimeLogger; chemins: SUPRA/SUPRACompositionRoot.swift; SUPRA/RuntimeDiagnosticsView.swift; sources Runtime autorisées par allowlist PLAN.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `R08` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/SUPRACompositionRoot.swift; SUPRA/RuntimeDiagnosticsView.swift; sources Runtime autorisées par allowlist PLAN — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/R09/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/R09/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/R09/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx build` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot`; `git diff --check -- $(tr '\n' ' ' < Evidence/R09/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Façade EvidenceEngine démontré dans `tests.log`.
- **Risque spécifique:** double publication ou snapshot non atomique; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/R09/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx build` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** R08. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### R10 — Façade ProviderEngine

- **Statut:** SOURCE-BLOCKED — G0 + R09
- **Objectif spécifique:** [PROPOSAL] définir l’adaptateur minimal pour Façade ProviderEngine; symboles fermés: SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot, RuntimeDiagnosticsView, RuntimeDataService, RuntimeGateway, RuntimeMonitor, SUPRARuntimeEvents, SUPRARuntimeGraph, SUPRARuntimeMetrics, SUPRARuntimeLogger.
- **Description:** Produire seulement l’incrément R10, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot, RuntimeDiagnosticsView, RuntimeDataService, RuntimeGateway, RuntimeMonitor, SUPRARuntimeEvents, SUPRARuntimeGraph, SUPRARuntimeMetrics, SUPRARuntimeLogger; chemins: SUPRA/SUPRACompositionRoot.swift; SUPRA/RuntimeDiagnosticsView.swift; sources Runtime autorisées par allowlist PLAN.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `R09` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/SUPRACompositionRoot.swift; SUPRA/RuntimeDiagnosticsView.swift; sources Runtime autorisées par allowlist PLAN — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/R10/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/R10/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/R10/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx build` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot`; `git diff --check -- $(tr '\n' ' ' < Evidence/R10/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Façade ProviderEngine démontré dans `tests.log`.
- **Risque spécifique:** double publication ou snapshot non atomique; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/R10/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx build` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** R09. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### R11 — Façade WorkspaceEngine

- **Statut:** SOURCE-BLOCKED — G0 + R10
- **Objectif spécifique:** [PROPOSAL] raccorder un seul flux pour Façade WorkspaceEngine; symboles fermés: SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot, RuntimeDiagnosticsView, RuntimeDataService, RuntimeGateway, RuntimeMonitor, SUPRARuntimeEvents, SUPRARuntimeGraph, SUPRARuntimeMetrics, SUPRARuntimeLogger.
- **Description:** Produire seulement l’incrément R11, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot, RuntimeDiagnosticsView, RuntimeDataService, RuntimeGateway, RuntimeMonitor, SUPRARuntimeEvents, SUPRARuntimeGraph, SUPRARuntimeMetrics, SUPRARuntimeLogger; chemins: SUPRA/SUPRACompositionRoot.swift; SUPRA/RuntimeDiagnosticsView.swift; sources Runtime autorisées par allowlist PLAN.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `R10` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/SUPRACompositionRoot.swift; SUPRA/RuntimeDiagnosticsView.swift; sources Runtime autorisées par allowlist PLAN — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/R11/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/R11/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/R11/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx build` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot`; `git diff --check -- $(tr '\n' ' ' < Evidence/R11/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Façade WorkspaceEngine démontré dans `tests.log`.
- **Risque spécifique:** double publication ou snapshot non atomique; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/R11/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx build` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** R10. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### R12 — Façade HealthEngine

- **Statut:** SOURCE-BLOCKED — G0 + R11
- **Objectif spécifique:** [PROPOSAL] prouver la parité nominale et dégradée pour Façade HealthEngine; symboles fermés: SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot, RuntimeDiagnosticsView, RuntimeDataService, RuntimeGateway, RuntimeMonitor, SUPRARuntimeEvents, SUPRARuntimeGraph, SUPRARuntimeMetrics, SUPRARuntimeLogger.
- **Description:** Produire seulement l’incrément R12, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot, RuntimeDiagnosticsView, RuntimeDataService, RuntimeGateway, RuntimeMonitor, SUPRARuntimeEvents, SUPRARuntimeGraph, SUPRARuntimeMetrics, SUPRARuntimeLogger; chemins: SUPRA/SUPRACompositionRoot.swift; SUPRA/RuntimeDiagnosticsView.swift; sources Runtime autorisées par allowlist PLAN.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `R11` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/SUPRACompositionRoot.swift; SUPRA/RuntimeDiagnosticsView.swift; sources Runtime autorisées par allowlist PLAN — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/R12/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/R12/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/R12/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx build` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot`; `git diff --check -- $(tr '\n' ' ' < Evidence/R12/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Façade HealthEngine démontré dans `tests.log`.
- **Risque spécifique:** double publication ou snapshot non atomique; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/R12/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx build` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** R11. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### R13 — Façade RecoveryEngine

- **Statut:** SOURCE-BLOCKED — G0 + R12
- **Objectif spécifique:** [PROPOSAL] inventorier les références et usages pour Façade RecoveryEngine; symboles fermés: SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot, RuntimeDiagnosticsView, RuntimeDataService, RuntimeGateway, RuntimeMonitor, SUPRARuntimeEvents, SUPRARuntimeGraph, SUPRARuntimeMetrics, SUPRARuntimeLogger.
- **Description:** Produire seulement l’incrément R13, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot, RuntimeDiagnosticsView, RuntimeDataService, RuntimeGateway, RuntimeMonitor, SUPRARuntimeEvents, SUPRARuntimeGraph, SUPRARuntimeMetrics, SUPRARuntimeLogger; chemins: SUPRA/SUPRACompositionRoot.swift; SUPRA/RuntimeDiagnosticsView.swift; sources Runtime autorisées par allowlist PLAN.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `R12` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/SUPRACompositionRoot.swift; SUPRA/RuntimeDiagnosticsView.swift; sources Runtime autorisées par allowlist PLAN — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/R13/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/R13/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/R13/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx build` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot`; `git diff --check -- $(tr '\n' ' ' < Evidence/R13/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Façade RecoveryEngine démontré dans `tests.log`.
- **Risque spécifique:** double publication ou snapshot non atomique; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/R13/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx build` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** R12. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### R14 — Façade FreezeEngine

- **Statut:** SOURCE-BLOCKED — G0 + R13
- **Objectif spécifique:** [PROPOSAL] définir l’adaptateur minimal pour Façade FreezeEngine; symboles fermés: SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot, RuntimeDiagnosticsView, RuntimeDataService, RuntimeGateway, RuntimeMonitor, SUPRARuntimeEvents, SUPRARuntimeGraph, SUPRARuntimeMetrics, SUPRARuntimeLogger.
- **Description:** Produire seulement l’incrément R14, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot, RuntimeDiagnosticsView, RuntimeDataService, RuntimeGateway, RuntimeMonitor, SUPRARuntimeEvents, SUPRARuntimeGraph, SUPRARuntimeMetrics, SUPRARuntimeLogger; chemins: SUPRA/SUPRACompositionRoot.swift; SUPRA/RuntimeDiagnosticsView.swift; sources Runtime autorisées par allowlist PLAN.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `R13` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/SUPRACompositionRoot.swift; SUPRA/RuntimeDiagnosticsView.swift; sources Runtime autorisées par allowlist PLAN — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/R14/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/R14/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/R14/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx build` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot`; `git diff --check -- $(tr '\n' ' ' < Evidence/R14/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Façade FreezeEngine démontré dans `tests.log`.
- **Risque spécifique:** double publication ou snapshot non atomique; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/R14/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx build` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** R13. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### R15 — Publication atomique RuntimeSnapshot

- **Statut:** SOURCE-BLOCKED — G0 + R14
- **Objectif spécifique:** [PROPOSAL] raccorder un seul flux pour Publication atomique RuntimeSnapshot; symboles fermés: SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot, RuntimeDiagnosticsView, RuntimeDataService, RuntimeGateway, RuntimeMonitor, SUPRARuntimeEvents, SUPRARuntimeGraph, SUPRARuntimeMetrics, SUPRARuntimeLogger.
- **Description:** Produire seulement l’incrément R15, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot, RuntimeDiagnosticsView, RuntimeDataService, RuntimeGateway, RuntimeMonitor, SUPRARuntimeEvents, SUPRARuntimeGraph, SUPRARuntimeMetrics, SUPRARuntimeLogger; chemins: SUPRA/SUPRACompositionRoot.swift; SUPRA/RuntimeDiagnosticsView.swift; sources Runtime autorisées par allowlist PLAN.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `R14` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/SUPRACompositionRoot.swift; SUPRA/RuntimeDiagnosticsView.swift; sources Runtime autorisées par allowlist PLAN — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/R15/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/R15/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/R15/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx build` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot`; `git diff --check -- $(tr '\n' ' ' < Evidence/R15/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Publication atomique RuntimeSnapshot démontré dans `tests.log`.
- **Risque spécifique:** double publication ou snapshot non atomique; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/R15/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx build` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** R14. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### R16 — Pilote RuntimeDiagnosticsView

- **Statut:** SOURCE-BLOCKED — G0 + R15
- **Objectif spécifique:** [PROPOSAL] prouver la parité nominale et dégradée pour Pilote RuntimeDiagnosticsView; symboles fermés: SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot, RuntimeDiagnosticsView, RuntimeDataService, RuntimeGateway, RuntimeMonitor, SUPRARuntimeEvents, SUPRARuntimeGraph, SUPRARuntimeMetrics, SUPRARuntimeLogger.
- **Description:** Produire seulement l’incrément R16, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot, RuntimeDiagnosticsView, RuntimeDataService, RuntimeGateway, RuntimeMonitor, SUPRARuntimeEvents, SUPRARuntimeGraph, SUPRARuntimeMetrics, SUPRARuntimeLogger; chemins: SUPRA/SUPRACompositionRoot.swift; SUPRA/RuntimeDiagnosticsView.swift; sources Runtime autorisées par allowlist PLAN.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `R15` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/SUPRACompositionRoot.swift; SUPRA/RuntimeDiagnosticsView.swift; sources Runtime autorisées par allowlist PLAN — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/R16/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/R16/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/R16/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx build` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot`; `git diff --check -- $(tr '\n' ' ' < Evidence/R16/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Pilote RuntimeDiagnosticsView démontré dans `tests.log`.
- **Risque spécifique:** double publication ou snapshot non atomique; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/R16/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx build` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** R15. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### R17 — Certifier CP1

- **Statut:** SOURCE-BLOCKED — G0 + R16
- **Objectif spécifique:** [PROPOSAL] inventorier les références et usages pour Certifier CP1; symboles fermés: SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot, RuntimeDiagnosticsView, RuntimeDataService, RuntimeGateway, RuntimeMonitor, SUPRARuntimeEvents, SUPRARuntimeGraph, SUPRARuntimeMetrics, SUPRARuntimeLogger.
- **Description:** Produire seulement l’incrément R17, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot, RuntimeDiagnosticsView, RuntimeDataService, RuntimeGateway, RuntimeMonitor, SUPRARuntimeEvents, SUPRARuntimeGraph, SUPRARuntimeMetrics, SUPRARuntimeLogger; chemins: SUPRA/SUPRACompositionRoot.swift; SUPRA/RuntimeDiagnosticsView.swift; sources Runtime autorisées par allowlist PLAN.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `R16` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/SUPRACompositionRoot.swift; SUPRA/RuntimeDiagnosticsView.swift; sources Runtime autorisées par allowlist PLAN — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/R17/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/R17/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/R17/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx build` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRACompositionRoot, RuntimeKernel (cible), RuntimeSnapshot`; `git diff --check -- $(tr '\n' ' ' < Evidence/R17/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Certifier CP1 démontré dans `tests.log`.
- **Risque spécifique:** double publication ou snapshot non atomique; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/R17/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx build` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** R16. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

## LOT 3 Mission

### M01 — Cartographie flux Mission

- **Statut:** SOURCE-BLOCKED — G0 + R17
- **Objectif spécifique:** [PROPOSAL] inventorier les références et usages pour Cartographie flux Mission; symboles fermés: MissionStore, MissionCenterView, MissionDetailView, MissionTimelineView, MissionGraphView, ExecutiveMissionControlView, SUPRAOSMissionCanvasView, Action, Execution.
- **Description:** Produire seulement l’incrément M01, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** MissionStore, MissionCenterView, MissionDetailView, MissionTimelineView, MissionGraphView, ExecutiveMissionControlView, SUPRAOSMissionCanvasView, Action, Execution; chemins: SUPRA/MissionStore.swift; SUPRA/MissionCenterView.swift; SUPRA/MissionDetailView.swift; vues Mission allowlistées.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `R17` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/MissionStore.swift; SUPRA/MissionCenterView.swift; SUPRA/MissionDetailView.swift; vues Mission allowlistées — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/M01/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/M01/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/M01/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `MissionStore, MissionCenterView, MissionDetailView`; `git diff --check -- $(tr '\n' ' ' < Evidence/M01/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Cartographie flux Mission démontré dans `tests.log`.
- **Risque spécifique:** transition Mission/Action/Execution divergente; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/M01/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** R17. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### M02 — Adapter MissionStore

- **Statut:** SOURCE-BLOCKED — G0 + M01
- **Objectif spécifique:** [PROPOSAL] définir l’adaptateur minimal pour Adapter MissionStore; symboles fermés: MissionStore, MissionCenterView, MissionDetailView, MissionTimelineView, MissionGraphView, ExecutiveMissionControlView, SUPRAOSMissionCanvasView, Action, Execution.
- **Description:** Produire seulement l’incrément M02, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** MissionStore, MissionCenterView, MissionDetailView, MissionTimelineView, MissionGraphView, ExecutiveMissionControlView, SUPRAOSMissionCanvasView, Action, Execution; chemins: SUPRA/MissionStore.swift; SUPRA/MissionCenterView.swift; SUPRA/MissionDetailView.swift; vues Mission allowlistées.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `M01` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/MissionStore.swift; SUPRA/MissionCenterView.swift; SUPRA/MissionDetailView.swift; vues Mission allowlistées — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/M02/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/M02/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/M02/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `MissionStore, MissionCenterView, MissionDetailView`; `git diff --check -- $(tr '\n' ' ' < Evidence/M02/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Adapter MissionStore démontré dans `tests.log`.
- **Risque spécifique:** transition Mission/Action/Execution divergente; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/M02/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** M01. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### M03 — Contrat Action/Execution

- **Statut:** SOURCE-BLOCKED — G0 + M02
- **Objectif spécifique:** [PROPOSAL] raccorder un seul flux pour Contrat Action/Execution; symboles fermés: MissionStore, MissionCenterView, MissionDetailView, MissionTimelineView, MissionGraphView, ExecutiveMissionControlView, SUPRAOSMissionCanvasView, Action, Execution.
- **Description:** Produire seulement l’incrément M03, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** MissionStore, MissionCenterView, MissionDetailView, MissionTimelineView, MissionGraphView, ExecutiveMissionControlView, SUPRAOSMissionCanvasView, Action, Execution; chemins: SUPRA/MissionStore.swift; SUPRA/MissionCenterView.swift; SUPRA/MissionDetailView.swift; vues Mission allowlistées.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `M02` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/MissionStore.swift; SUPRA/MissionCenterView.swift; SUPRA/MissionDetailView.swift; vues Mission allowlistées — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/M03/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/M03/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/M03/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `MissionStore, MissionCenterView, MissionDetailView`; `git diff --check -- $(tr '\n' ' ' < Evidence/M03/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Contrat Action/Execution démontré dans `tests.log`.
- **Risque spécifique:** transition Mission/Action/Execution divergente; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/M03/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** M02. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### M04 — Unifier MissionCenter/Detail

- **Statut:** SOURCE-BLOCKED — G0 + M03
- **Objectif spécifique:** [PROPOSAL] prouver la parité nominale et dégradée pour Unifier MissionCenter/Detail; symboles fermés: MissionStore, MissionCenterView, MissionDetailView, MissionTimelineView, MissionGraphView, ExecutiveMissionControlView, SUPRAOSMissionCanvasView, Action, Execution.
- **Description:** Produire seulement l’incrément M04, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** MissionStore, MissionCenterView, MissionDetailView, MissionTimelineView, MissionGraphView, ExecutiveMissionControlView, SUPRAOSMissionCanvasView, Action, Execution; chemins: SUPRA/MissionStore.swift; SUPRA/MissionCenterView.swift; SUPRA/MissionDetailView.swift; vues Mission allowlistées.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `M03` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/MissionStore.swift; SUPRA/MissionCenterView.swift; SUPRA/MissionDetailView.swift; vues Mission allowlistées — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/M04/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/M04/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/M04/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `MissionStore, MissionCenterView, MissionDetailView`; `git diff --check -- $(tr '\n' ' ' < Evidence/M04/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Unifier MissionCenter/Detail démontré dans `tests.log`.
- **Risque spécifique:** transition Mission/Action/Execution divergente; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/M04/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** M03. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### M05 — Fusionner Timeline/Graph

- **Statut:** SOURCE-BLOCKED — G0 + M04
- **Objectif spécifique:** [PROPOSAL] inventorier les références et usages pour Fusionner Timeline/Graph; symboles fermés: MissionStore, MissionCenterView, MissionDetailView, MissionTimelineView, MissionGraphView, ExecutiveMissionControlView, SUPRAOSMissionCanvasView, Action, Execution.
- **Description:** Produire seulement l’incrément M05, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** MissionStore, MissionCenterView, MissionDetailView, MissionTimelineView, MissionGraphView, ExecutiveMissionControlView, SUPRAOSMissionCanvasView, Action, Execution; chemins: SUPRA/MissionStore.swift; SUPRA/MissionCenterView.swift; SUPRA/MissionDetailView.swift; vues Mission allowlistées.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `M04` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/MissionStore.swift; SUPRA/MissionCenterView.swift; SUPRA/MissionDetailView.swift; vues Mission allowlistées — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/M05/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/M05/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/M05/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `MissionStore, MissionCenterView, MissionDetailView`; `git diff --check -- $(tr '\n' ' ' < Evidence/M05/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Fusionner Timeline/Graph démontré dans `tests.log`.
- **Risque spécifique:** transition Mission/Action/Execution divergente; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/M05/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** M04. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### M06 — Certifier CP3

- **Statut:** SOURCE-BLOCKED — G0 + M05
- **Objectif spécifique:** [PROPOSAL] définir l’adaptateur minimal pour Certifier CP3; symboles fermés: MissionStore, MissionCenterView, MissionDetailView, MissionTimelineView, MissionGraphView, ExecutiveMissionControlView, SUPRAOSMissionCanvasView, Action, Execution.
- **Description:** Produire seulement l’incrément M06, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** MissionStore, MissionCenterView, MissionDetailView, MissionTimelineView, MissionGraphView, ExecutiveMissionControlView, SUPRAOSMissionCanvasView, Action, Execution; chemins: SUPRA/MissionStore.swift; SUPRA/MissionCenterView.swift; SUPRA/MissionDetailView.swift; vues Mission allowlistées.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `M05` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/MissionStore.swift; SUPRA/MissionCenterView.swift; SUPRA/MissionDetailView.swift; vues Mission allowlistées — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/M06/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/M06/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/M06/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `MissionStore, MissionCenterView, MissionDetailView`; `git diff --check -- $(tr '\n' ' ' < Evidence/M06/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Certifier CP3 démontré dans `tests.log`.
- **Risque spécifique:** transition Mission/Action/Execution divergente; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/M06/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** M05. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

## LOT 4 Knowledge

### K01 — Cartographie Knowledge/Memory

- **Statut:** SOURCE-BLOCKED — G0 + R17
- **Objectif spécifique:** [PROPOSAL] inventorier les références et usages pour Cartographie Knowledge/Memory; symboles fermés: ConversationMemoryStore, KnowledgeExplorer, IntelligenceView, MemoryView, MultiMemoryView, SUPRAMemoryLensView, Knowledge providers, kernel.
- **Description:** Produire seulement l’incrément K01, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** ConversationMemoryStore, KnowledgeExplorer, IntelligenceView, MemoryView, MultiMemoryView, SUPRAMemoryLensView, Knowledge providers, kernel; chemins: sources Knowledge/Memory explicitement allowlistées au PLAN.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `R17` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** sources Knowledge/Memory explicitement allowlistées au PLAN — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/K01/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/K01/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/K01/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `ConversationMemoryStore, KnowledgeExplorer, IntelligenceView`; `git diff --check -- $(tr '\n' ' ' < Evidence/K01/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Cartographie Knowledge/Memory démontré dans `tests.log`.
- **Risque spécifique:** perte d’identité, lineage ou provenance; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/K01/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** R17. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### K02 — Adapter ConversationMemoryStore

- **Statut:** SOURCE-BLOCKED — G0 + K01
- **Objectif spécifique:** [PROPOSAL] définir l’adaptateur minimal pour Adapter ConversationMemoryStore; symboles fermés: ConversationMemoryStore, KnowledgeExplorer, IntelligenceView, MemoryView, MultiMemoryView, SUPRAMemoryLensView, Knowledge providers, kernel.
- **Description:** Produire seulement l’incrément K02, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** ConversationMemoryStore, KnowledgeExplorer, IntelligenceView, MemoryView, MultiMemoryView, SUPRAMemoryLensView, Knowledge providers, kernel; chemins: sources Knowledge/Memory explicitement allowlistées au PLAN.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `K01` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** sources Knowledge/Memory explicitement allowlistées au PLAN — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/K02/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/K02/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/K02/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `ConversationMemoryStore, KnowledgeExplorer, IntelligenceView`; `git diff --check -- $(tr '\n' ' ' < Evidence/K02/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Adapter ConversationMemoryStore démontré dans `tests.log`.
- **Risque spécifique:** perte d’identité, lineage ou provenance; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/K02/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 60 min. **Durée:** 4 h. **Dépendances:** K01. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### K03 — Unifier objets/relations

- **Statut:** SOURCE-BLOCKED — G0 + K02
- **Objectif spécifique:** [PROPOSAL] raccorder un seul flux pour Unifier objets/relations; symboles fermés: ConversationMemoryStore, KnowledgeExplorer, IntelligenceView, MemoryView, MultiMemoryView, SUPRAMemoryLensView, Knowledge providers, kernel.
- **Description:** Produire seulement l’incrément K03, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** ConversationMemoryStore, KnowledgeExplorer, IntelligenceView, MemoryView, MultiMemoryView, SUPRAMemoryLensView, Knowledge providers, kernel; chemins: sources Knowledge/Memory explicitement allowlistées au PLAN.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `K02` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** sources Knowledge/Memory explicitement allowlistées au PLAN — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/K03/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/K03/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/K03/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `ConversationMemoryStore, KnowledgeExplorer, IntelligenceView`; `git diff --check -- $(tr '\n' ' ' < Evidence/K03/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Unifier objets/relations démontré dans `tests.log`.
- **Risque spécifique:** perte d’identité, lineage ou provenance; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/K03/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** K02. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### K04 — Lineage/provenance

- **Statut:** SOURCE-BLOCKED — G0 + K03
- **Objectif spécifique:** [PROPOSAL] prouver la parité nominale et dégradée pour Lineage/provenance; symboles fermés: ConversationMemoryStore, KnowledgeExplorer, IntelligenceView, MemoryView, MultiMemoryView, SUPRAMemoryLensView, Knowledge providers, kernel.
- **Description:** Produire seulement l’incrément K04, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** ConversationMemoryStore, KnowledgeExplorer, IntelligenceView, MemoryView, MultiMemoryView, SUPRAMemoryLensView, Knowledge providers, kernel; chemins: sources Knowledge/Memory explicitement allowlistées au PLAN.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `K03` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** sources Knowledge/Memory explicitement allowlistées au PLAN — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/K04/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/K04/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/K04/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `ConversationMemoryStore, KnowledgeExplorer, IntelligenceView`; `git diff --check -- $(tr '\n' ' ' < Evidence/K04/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Lineage/provenance démontré dans `tests.log`.
- **Risque spécifique:** perte d’identité, lineage ou provenance; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/K04/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** K03. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### K05 — Providers Knowledge

- **Statut:** SOURCE-BLOCKED — G0 + K04
- **Objectif spécifique:** [PROPOSAL] inventorier les références et usages pour Providers Knowledge; symboles fermés: ConversationMemoryStore, KnowledgeExplorer, IntelligenceView, MemoryView, MultiMemoryView, SUPRAMemoryLensView, Knowledge providers, kernel.
- **Description:** Produire seulement l’incrément K05, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** ConversationMemoryStore, KnowledgeExplorer, IntelligenceView, MemoryView, MultiMemoryView, SUPRAMemoryLensView, Knowledge providers, kernel; chemins: sources Knowledge/Memory explicitement allowlistées au PLAN.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `K04` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** sources Knowledge/Memory explicitement allowlistées au PLAN — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/K05/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/K05/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/K05/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `ConversationMemoryStore, KnowledgeExplorer, IntelligenceView`; `git diff --check -- $(tr '\n' ' ' < Evidence/K05/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Providers Knowledge démontré dans `tests.log`.
- **Risque spécifique:** perte d’identité, lineage ou provenance; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/K05/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** K04. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### K06 — Certifier CP4

- **Statut:** SOURCE-BLOCKED — G0 + K05
- **Objectif spécifique:** [PROPOSAL] définir l’adaptateur minimal pour Certifier CP4; symboles fermés: ConversationMemoryStore, KnowledgeExplorer, IntelligenceView, MemoryView, MultiMemoryView, SUPRAMemoryLensView, Knowledge providers, kernel.
- **Description:** Produire seulement l’incrément K06, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** ConversationMemoryStore, KnowledgeExplorer, IntelligenceView, MemoryView, MultiMemoryView, SUPRAMemoryLensView, Knowledge providers, kernel; chemins: sources Knowledge/Memory explicitement allowlistées au PLAN.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `K05` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** sources Knowledge/Memory explicitement allowlistées au PLAN — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/K06/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/K06/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/K06/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `ConversationMemoryStore, KnowledgeExplorer, IntelligenceView`; `git diff --check -- $(tr '\n' ' ' < Evidence/K06/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Certifier CP4 démontré dans `tests.log`.
- **Risque spécifique:** perte d’identité, lineage ou provenance; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/K06/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** K05. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

## LOT 5 Decision

### D01 — Cartographie mutations Decision

- **Statut:** SOURCE-BLOCKED — G0 + R17,M03
- **Objectif spécifique:** [PROPOSAL] inventorier les références et usages pour Cartographie mutations Decision; symboles fermés: DecisionStore, DecisionInboxView, DecisionDetailView, DecisionRow, DecisionAuthorityView, SUPRADecisionRoomView.
- **Description:** Produire seulement l’incrément D01, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** DecisionStore, DecisionInboxView, DecisionDetailView, DecisionRow, DecisionAuthorityView, SUPRADecisionRoomView; chemins: SUPRA/DecisionStore.swift; SUPRA/DecisionInboxView.swift; SUPRA/DecisionDetailView.swift; SUPRA/DecisionRow.swift; vues Authority/Room allowlistées.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `R17,M03` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/DecisionStore.swift; SUPRA/DecisionInboxView.swift; SUPRA/DecisionDetailView.swift; SUPRA/DecisionRow.swift; vues Authority/Room allowlistées — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/D01/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/D01/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/D01/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `DecisionStore, DecisionInboxView, DecisionDetailView`; `git diff --check -- $(tr '\n' ' ' < Evidence/D01/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Cartographie mutations Decision démontré dans `tests.log`.
- **Risque spécifique:** mutation Decision non traçable; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/D01/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** R17,M03. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### D02 — Adapter DecisionStore

- **Statut:** SOURCE-BLOCKED — G0 + D01
- **Objectif spécifique:** [PROPOSAL] définir l’adaptateur minimal pour Adapter DecisionStore; symboles fermés: DecisionStore, DecisionInboxView, DecisionDetailView, DecisionRow, DecisionAuthorityView, SUPRADecisionRoomView.
- **Description:** Produire seulement l’incrément D02, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** DecisionStore, DecisionInboxView, DecisionDetailView, DecisionRow, DecisionAuthorityView, SUPRADecisionRoomView; chemins: SUPRA/DecisionStore.swift; SUPRA/DecisionInboxView.swift; SUPRA/DecisionDetailView.swift; SUPRA/DecisionRow.swift; vues Authority/Room allowlistées.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `D01` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/DecisionStore.swift; SUPRA/DecisionInboxView.swift; SUPRA/DecisionDetailView.swift; SUPRA/DecisionRow.swift; vues Authority/Room allowlistées — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/D02/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/D02/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/D02/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `DecisionStore, DecisionInboxView, DecisionDetailView`; `git diff --check -- $(tr '\n' ' ' < Evidence/D02/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Adapter DecisionStore démontré dans `tests.log`.
- **Risque spécifique:** mutation Decision non traçable; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/D02/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** D01. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### D03 — Unifier Inbox/Detail

- **Statut:** SOURCE-BLOCKED — G0 + D02
- **Objectif spécifique:** [PROPOSAL] raccorder un seul flux pour Unifier Inbox/Detail; symboles fermés: DecisionStore, DecisionInboxView, DecisionDetailView, DecisionRow, DecisionAuthorityView, SUPRADecisionRoomView.
- **Description:** Produire seulement l’incrément D03, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** DecisionStore, DecisionInboxView, DecisionDetailView, DecisionRow, DecisionAuthorityView, SUPRADecisionRoomView; chemins: SUPRA/DecisionStore.swift; SUPRA/DecisionInboxView.swift; SUPRA/DecisionDetailView.swift; SUPRA/DecisionRow.swift; vues Authority/Room allowlistées.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `D02` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/DecisionStore.swift; SUPRA/DecisionInboxView.swift; SUPRA/DecisionDetailView.swift; SUPRA/DecisionRow.swift; vues Authority/Room allowlistées — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/D03/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/D03/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/D03/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `DecisionStore, DecisionInboxView, DecisionDetailView`; `git diff --check -- $(tr '\n' ' ' < Evidence/D03/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Unifier Inbox/Detail démontré dans `tests.log`.
- **Risque spécifique:** mutation Decision non traçable; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/D03/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** D02. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### D04 — Authority/DecisionRoom

- **Statut:** SOURCE-BLOCKED — G0 + D03
- **Objectif spécifique:** [PROPOSAL] prouver la parité nominale et dégradée pour Authority/DecisionRoom; symboles fermés: DecisionStore, DecisionInboxView, DecisionDetailView, DecisionRow, DecisionAuthorityView, SUPRADecisionRoomView.
- **Description:** Produire seulement l’incrément D04, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** DecisionStore, DecisionInboxView, DecisionDetailView, DecisionRow, DecisionAuthorityView, SUPRADecisionRoomView; chemins: SUPRA/DecisionStore.swift; SUPRA/DecisionInboxView.swift; SUPRA/DecisionDetailView.swift; SUPRA/DecisionRow.swift; vues Authority/Room allowlistées.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `D03` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/DecisionStore.swift; SUPRA/DecisionInboxView.swift; SUPRA/DecisionDetailView.swift; SUPRA/DecisionRow.swift; vues Authority/Room allowlistées — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/D04/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/D04/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/D04/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `DecisionStore, DecisionInboxView, DecisionDetailView`; `git diff --check -- $(tr '\n' ' ' < Evidence/D04/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Authority/DecisionRoom démontré dans `tests.log`.
- **Risque spécifique:** mutation Decision non traçable; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/D04/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** D03. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### D05 — Certifier Decision

- **Statut:** SOURCE-BLOCKED — G0 + D04
- **Objectif spécifique:** [PROPOSAL] inventorier les références et usages pour Certifier Decision; symboles fermés: DecisionStore, DecisionInboxView, DecisionDetailView, DecisionRow, DecisionAuthorityView, SUPRADecisionRoomView.
- **Description:** Produire seulement l’incrément D05, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** DecisionStore, DecisionInboxView, DecisionDetailView, DecisionRow, DecisionAuthorityView, SUPRADecisionRoomView; chemins: SUPRA/DecisionStore.swift; SUPRA/DecisionInboxView.swift; SUPRA/DecisionDetailView.swift; SUPRA/DecisionRow.swift; vues Authority/Room allowlistées.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `D04` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/DecisionStore.swift; SUPRA/DecisionInboxView.swift; SUPRA/DecisionDetailView.swift; SUPRA/DecisionRow.swift; vues Authority/Room allowlistées — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/D05/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/D05/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/D05/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `DecisionStore, DecisionInboxView, DecisionDetailView`; `git diff --check -- $(tr '\n' ' ' < Evidence/D05/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Certifier Decision démontré dans `tests.log`.
- **Risque spécifique:** mutation Decision non traçable; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/D05/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** D04. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

## LOT 6 Workspace

### W01 — Cartographie Workspace

- **Statut:** SOURCE-BLOCKED — G0 + R17
- **Objectif spécifique:** [PROPOSAL] inventorier les références et usages pour Cartographie Workspace; symboles fermés: SUPRAOSWorkspaceExplorerView, FileSystemCardView, ProjectsCardView, WorkspaceDiscovery, WorkspaceIndexer, WorkspaceKnowledgeGraph, WorkspaceMemory.
- **Description:** Produire seulement l’incrément W01, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRAOSWorkspaceExplorerView, FileSystemCardView, ProjectsCardView, WorkspaceDiscovery, WorkspaceIndexer, WorkspaceKnowledgeGraph, WorkspaceMemory; chemins: sources Workspace explicitement allowlistées au PLAN.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `R17` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** sources Workspace explicitement allowlistées au PLAN — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/W01/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/W01/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/W01/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRAOSWorkspaceExplorerView, FileSystemCardView, ProjectsCardView`; `git diff --check -- $(tr '\n' ' ' < Evidence/W01/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Cartographie Workspace démontré dans `tests.log`.
- **Risque spécifique:** index Workspace périmé ou doublé; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/W01/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** R17. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### W02 — Adapter WorkspaceEngine

- **Statut:** SOURCE-BLOCKED — G0 + W01
- **Objectif spécifique:** [PROPOSAL] définir l’adaptateur minimal pour Adapter WorkspaceEngine; symboles fermés: SUPRAOSWorkspaceExplorerView, FileSystemCardView, ProjectsCardView, WorkspaceDiscovery, WorkspaceIndexer, WorkspaceKnowledgeGraph, WorkspaceMemory.
- **Description:** Produire seulement l’incrément W02, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRAOSWorkspaceExplorerView, FileSystemCardView, ProjectsCardView, WorkspaceDiscovery, WorkspaceIndexer, WorkspaceKnowledgeGraph, WorkspaceMemory; chemins: sources Workspace explicitement allowlistées au PLAN.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `W01` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** sources Workspace explicitement allowlistées au PLAN — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/W02/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/W02/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/W02/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRAOSWorkspaceExplorerView, FileSystemCardView, ProjectsCardView`; `git diff --check -- $(tr '\n' ' ' < Evidence/W02/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Adapter WorkspaceEngine démontré dans `tests.log`.
- **Risque spécifique:** index Workspace périmé ou doublé; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/W02/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** W01. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### W03 — Explorateur canonique

- **Statut:** SOURCE-BLOCKED — G0 + W02
- **Objectif spécifique:** [PROPOSAL] raccorder un seul flux pour Explorateur canonique; symboles fermés: SUPRAOSWorkspaceExplorerView, FileSystemCardView, ProjectsCardView, WorkspaceDiscovery, WorkspaceIndexer, WorkspaceKnowledgeGraph, WorkspaceMemory.
- **Description:** Produire seulement l’incrément W03, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRAOSWorkspaceExplorerView, FileSystemCardView, ProjectsCardView, WorkspaceDiscovery, WorkspaceIndexer, WorkspaceKnowledgeGraph, WorkspaceMemory; chemins: sources Workspace explicitement allowlistées au PLAN.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `W02` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** sources Workspace explicitement allowlistées au PLAN — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/W03/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/W03/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/W03/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRAOSWorkspaceExplorerView, FileSystemCardView, ProjectsCardView`; `git diff --check -- $(tr '\n' ' ' < Evidence/W03/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Explorateur canonique démontré dans `tests.log`.
- **Risque spécifique:** index Workspace périmé ou doublé; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/W03/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** W02. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### W04 — Cartes V5

- **Statut:** SOURCE-BLOCKED — G0 + W03
- **Objectif spécifique:** [PROPOSAL] prouver la parité nominale et dégradée pour Cartes V5; symboles fermés: SUPRAOSWorkspaceExplorerView, FileSystemCardView, ProjectsCardView, WorkspaceDiscovery, WorkspaceIndexer, WorkspaceKnowledgeGraph, WorkspaceMemory.
- **Description:** Produire seulement l’incrément W04, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRAOSWorkspaceExplorerView, FileSystemCardView, ProjectsCardView, WorkspaceDiscovery, WorkspaceIndexer, WorkspaceKnowledgeGraph, WorkspaceMemory; chemins: sources Workspace explicitement allowlistées au PLAN.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `W03` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** sources Workspace explicitement allowlistées au PLAN — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/W04/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/W04/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/W04/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRAOSWorkspaceExplorerView, FileSystemCardView, ProjectsCardView`; `git diff --check -- $(tr '\n' ' ' < Evidence/W04/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Cartes V5 démontré dans `tests.log`.
- **Risque spécifique:** index Workspace périmé ou doublé; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/W04/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** W03. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### W05 — Index/graph/memory

- **Statut:** SOURCE-BLOCKED — G0 + W04
- **Objectif spécifique:** [PROPOSAL] inventorier les références et usages pour Index/graph/memory; symboles fermés: SUPRAOSWorkspaceExplorerView, FileSystemCardView, ProjectsCardView, WorkspaceDiscovery, WorkspaceIndexer, WorkspaceKnowledgeGraph, WorkspaceMemory.
- **Description:** Produire seulement l’incrément W05, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRAOSWorkspaceExplorerView, FileSystemCardView, ProjectsCardView, WorkspaceDiscovery, WorkspaceIndexer, WorkspaceKnowledgeGraph, WorkspaceMemory; chemins: sources Workspace explicitement allowlistées au PLAN.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `W04` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** sources Workspace explicitement allowlistées au PLAN — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/W05/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/W05/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/W05/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRAOSWorkspaceExplorerView, FileSystemCardView, ProjectsCardView`; `git diff --check -- $(tr '\n' ' ' < Evidence/W05/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Index/graph/memory démontré dans `tests.log`.
- **Risque spécifique:** index Workspace périmé ou doublé; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/W05/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** W04. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### W06 — Certifier CP2

- **Statut:** SOURCE-BLOCKED — G0 + W05
- **Objectif spécifique:** [PROPOSAL] définir l’adaptateur minimal pour Certifier CP2; symboles fermés: SUPRAOSWorkspaceExplorerView, FileSystemCardView, ProjectsCardView, WorkspaceDiscovery, WorkspaceIndexer, WorkspaceKnowledgeGraph, WorkspaceMemory.
- **Description:** Produire seulement l’incrément W06, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRAOSWorkspaceExplorerView, FileSystemCardView, ProjectsCardView, WorkspaceDiscovery, WorkspaceIndexer, WorkspaceKnowledgeGraph, WorkspaceMemory; chemins: sources Workspace explicitement allowlistées au PLAN.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `W05` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** sources Workspace explicitement allowlistées au PLAN — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/W06/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/W06/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/W06/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRAOSWorkspaceExplorerView, FileSystemCardView, ProjectsCardView`; `git diff --check -- $(tr '\n' ' ' < Evidence/W06/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Certifier CP2 démontré dans `tests.log`.
- **Risque spécifique:** index Workspace périmé ou doublé; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/W06/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** W05. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

## LOT 7 UI

### U01 — Préparer ExecutiveWindow

- **Statut:** SOURCE-BLOCKED — G0 + R17
- **Objectif spécifique:** [PROPOSAL] inventorier les références et usages pour Préparer ExecutiveWindow; symboles fermés: ExecutiveWindow, SUPRAOSProductRootView, SUPRAOSDesignSystem, DashboardView, ContentView, 12 espaces canoniques.
- **Description:** Produire seulement l’incrément U01, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** ExecutiveWindow, SUPRAOSProductRootView, SUPRAOSDesignSystem, DashboardView, ContentView, 12 espaces canoniques; chemins: SUPRA/ExecutiveWindow.swift; SUPRA/SUPRAOSProductRootView.swift; SUPRA/SUPRAOSDesignSystem.swift; vues explicitement allowlistées.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `R17` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/ExecutiveWindow.swift; SUPRA/SUPRAOSProductRootView.swift; SUPRA/SUPRAOSDesignSystem.swift; vues explicitement allowlistées — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/U01/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/U01/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/U01/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `ExecutiveWindow, SUPRAOSProductRootView, SUPRAOSDesignSystem`; `git diff --check -- $(tr '\n' ' ' < Evidence/U01/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Préparer ExecutiveWindow démontré dans `tests.log`.
- **Risque spécifique:** shell/navigation concurrente ou logique métier dans View; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/U01/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** R17. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### U02 — Navigation 12 espaces

- **Statut:** SOURCE-BLOCKED — G0 + U01
- **Objectif spécifique:** [PROPOSAL] définir l’adaptateur minimal pour Navigation 12 espaces; symboles fermés: ExecutiveWindow, SUPRAOSProductRootView, SUPRAOSDesignSystem, DashboardView, ContentView, 12 espaces canoniques.
- **Description:** Produire seulement l’incrément U02, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** ExecutiveWindow, SUPRAOSProductRootView, SUPRAOSDesignSystem, DashboardView, ContentView, 12 espaces canoniques; chemins: SUPRA/ExecutiveWindow.swift; SUPRA/SUPRAOSProductRootView.swift; SUPRA/SUPRAOSDesignSystem.swift; vues explicitement allowlistées.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `U01` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/ExecutiveWindow.swift; SUPRA/SUPRAOSProductRootView.swift; SUPRA/SUPRAOSDesignSystem.swift; vues explicitement allowlistées — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/U02/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/U02/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/U02/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `ExecutiveWindow, SUPRAOSProductRootView, SUPRAOSDesignSystem`; `git diff --check -- $(tr '\n' ' ' < Evidence/U02/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Navigation 12 espaces démontré dans `tests.log`.
- **Risque spécifique:** shell/navigation concurrente ou logique métier dans View; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/U02/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** U01. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### U03 — Dashboard canonique

- **Statut:** SOURCE-BLOCKED — G0 + U02,M06,D05
- **Objectif spécifique:** [PROPOSAL] raccorder un seul flux pour Dashboard canonique; symboles fermés: ExecutiveWindow, SUPRAOSProductRootView, SUPRAOSDesignSystem, DashboardView, ContentView, 12 espaces canoniques.
- **Description:** Produire seulement l’incrément U03, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** ExecutiveWindow, SUPRAOSProductRootView, SUPRAOSDesignSystem, DashboardView, ContentView, 12 espaces canoniques; chemins: SUPRA/ExecutiveWindow.swift; SUPRA/SUPRAOSProductRootView.swift; SUPRA/SUPRAOSDesignSystem.swift; vues explicitement allowlistées.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `U02,M06,D05` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/ExecutiveWindow.swift; SUPRA/SUPRAOSProductRootView.swift; SUPRA/SUPRAOSDesignSystem.swift; vues explicitement allowlistées — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/U03/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/U03/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/U03/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `ExecutiveWindow, SUPRAOSProductRootView, SUPRAOSDesignSystem`; `git diff --check -- $(tr '\n' ' ' < Evidence/U03/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Dashboard canonique démontré dans `tests.log`.
- **Risque spécifique:** shell/navigation concurrente ou logique métier dans View; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/U03/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** U02,M06,D05. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### U04 — Projections Mission/Decision

- **Statut:** SOURCE-BLOCKED — G0 + U03,W06,K06
- **Objectif spécifique:** [PROPOSAL] prouver la parité nominale et dégradée pour Projections Mission/Decision; symboles fermés: ExecutiveWindow, SUPRAOSProductRootView, SUPRAOSDesignSystem, DashboardView, ContentView, 12 espaces canoniques.
- **Description:** Produire seulement l’incrément U04, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** ExecutiveWindow, SUPRAOSProductRootView, SUPRAOSDesignSystem, DashboardView, ContentView, 12 espaces canoniques; chemins: SUPRA/ExecutiveWindow.swift; SUPRA/SUPRAOSProductRootView.swift; SUPRA/SUPRAOSDesignSystem.swift; vues explicitement allowlistées.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `U03,W06,K06` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/ExecutiveWindow.swift; SUPRA/SUPRAOSProductRootView.swift; SUPRA/SUPRAOSDesignSystem.swift; vues explicitement allowlistées — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/U04/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/U04/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/U04/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `ExecutiveWindow, SUPRAOSProductRootView, SUPRAOSDesignSystem`; `git diff --check -- $(tr '\n' ' ' < Evidence/U04/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Projections Mission/Decision démontré dans `tests.log`.
- **Risque spécifique:** shell/navigation concurrente ou logique métier dans View; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/U04/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** U03,W06,K06. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### U05 — Projections Workspace/Knowledge

- **Statut:** SOURCE-BLOCKED — G0 + U04,P05
- **Objectif spécifique:** [PROPOSAL] inventorier les références et usages pour Projections Workspace/Knowledge; symboles fermés: ExecutiveWindow, SUPRAOSProductRootView, SUPRAOSDesignSystem, DashboardView, ContentView, 12 espaces canoniques.
- **Description:** Produire seulement l’incrément U05, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** ExecutiveWindow, SUPRAOSProductRootView, SUPRAOSDesignSystem, DashboardView, ContentView, 12 espaces canoniques; chemins: SUPRA/ExecutiveWindow.swift; SUPRA/SUPRAOSProductRootView.swift; SUPRA/SUPRAOSDesignSystem.swift; vues explicitement allowlistées.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `U04,P05` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/ExecutiveWindow.swift; SUPRA/SUPRAOSProductRootView.swift; SUPRA/SUPRAOSDesignSystem.swift; vues explicitement allowlistées — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/U05/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/U05/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/U05/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `ExecutiveWindow, SUPRAOSProductRootView, SUPRAOSDesignSystem`; `git diff --check -- $(tr '\n' ' ' < Evidence/U05/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Projections Workspace/Knowledge démontré dans `tests.log`.
- **Risque spécifique:** shell/navigation concurrente ou logique métier dans View; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/U05/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** U04,P05. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### U06 — Projection Runtime

- **Statut:** SOURCE-BLOCKED — G0 + U05
- **Objectif spécifique:** [PROPOSAL] définir l’adaptateur minimal pour Projection Runtime; symboles fermés: ExecutiveWindow, SUPRAOSProductRootView, SUPRAOSDesignSystem, DashboardView, ContentView, 12 espaces canoniques.
- **Description:** Produire seulement l’incrément U06, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** ExecutiveWindow, SUPRAOSProductRootView, SUPRAOSDesignSystem, DashboardView, ContentView, 12 espaces canoniques; chemins: SUPRA/ExecutiveWindow.swift; SUPRA/SUPRAOSProductRootView.swift; SUPRA/SUPRAOSDesignSystem.swift; vues explicitement allowlistées.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `U05` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/ExecutiveWindow.swift; SUPRA/SUPRAOSProductRootView.swift; SUPRA/SUPRAOSDesignSystem.swift; vues explicitement allowlistées — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/U06/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/U06/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/U06/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `ExecutiveWindow, SUPRAOSProductRootView, SUPRAOSDesignSystem`; `git diff --check -- $(tr '\n' ' ' < Evidence/U06/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Projection Runtime démontré dans `tests.log`.
- **Risque spécifique:** shell/navigation concurrente ou logique métier dans View; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/U06/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** U05. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### U07 — Discovery/Evidence

- **Statut:** SOURCE-BLOCKED — G0 + U06
- **Objectif spécifique:** [PROPOSAL] raccorder un seul flux pour Discovery/Evidence; symboles fermés: ExecutiveWindow, SUPRAOSProductRootView, SUPRAOSDesignSystem, DashboardView, ContentView, 12 espaces canoniques.
- **Description:** Produire seulement l’incrément U07, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** ExecutiveWindow, SUPRAOSProductRootView, SUPRAOSDesignSystem, DashboardView, ContentView, 12 espaces canoniques; chemins: SUPRA/ExecutiveWindow.swift; SUPRA/SUPRAOSProductRootView.swift; SUPRA/SUPRAOSDesignSystem.swift; vues explicitement allowlistées.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `U06` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/ExecutiveWindow.swift; SUPRA/SUPRAOSProductRootView.swift; SUPRA/SUPRAOSDesignSystem.swift; vues explicitement allowlistées — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/U07/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/U07/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/U07/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `ExecutiveWindow, SUPRAOSProductRootView, SUPRAOSDesignSystem`; `git diff --check -- $(tr '\n' ' ' < Evidence/U07/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Discovery/Evidence démontré dans `tests.log`.
- **Risque spécifique:** shell/navigation concurrente ou logique métier dans View; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/U07/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** U06. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### U08 — Providers/Reports/Developer/Settings

- **Statut:** SOURCE-BLOCKED — G0 + U07,P05
- **Objectif spécifique:** [PROPOSAL] prouver la parité nominale et dégradée pour Providers/Reports/Developer/Settings; symboles fermés: ExecutiveWindow, SUPRAOSProductRootView, SUPRAOSDesignSystem, DashboardView, ContentView, 12 espaces canoniques.
- **Description:** Produire seulement l’incrément U08, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** ExecutiveWindow, SUPRAOSProductRootView, SUPRAOSDesignSystem, DashboardView, ContentView, 12 espaces canoniques; chemins: SUPRA/ExecutiveWindow.swift; SUPRA/SUPRAOSProductRootView.swift; SUPRA/SUPRAOSDesignSystem.swift; vues explicitement allowlistées.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `U07,P05` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/ExecutiveWindow.swift; SUPRA/SUPRAOSProductRootView.swift; SUPRA/SUPRAOSDesignSystem.swift; vues explicitement allowlistées — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/U08/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/U08/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/U08/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `ExecutiveWindow, SUPRAOSProductRootView, SUPRAOSDesignSystem`; `git diff --check -- $(tr '\n' ' ' < Evidence/U08/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Providers/Reports/Developer/Settings démontré dans `tests.log`.
- **Risque spécifique:** shell/navigation concurrente ou logique métier dans View; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/U08/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** U07,P05. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### U09 — Déprécier shells alternatifs

- **Statut:** SOURCE-BLOCKED — G0 + U08
- **Objectif spécifique:** [PROPOSAL] inventorier les références et usages pour Déprécier shells alternatifs; symboles fermés: ExecutiveWindow, SUPRAOSProductRootView, SUPRAOSDesignSystem, DashboardView, ContentView, 12 espaces canoniques.
- **Description:** Produire seulement l’incrément U09, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** ExecutiveWindow, SUPRAOSProductRootView, SUPRAOSDesignSystem, DashboardView, ContentView, 12 espaces canoniques; chemins: SUPRA/ExecutiveWindow.swift; SUPRA/SUPRAOSProductRootView.swift; SUPRA/SUPRAOSDesignSystem.swift; vues explicitement allowlistées.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `U08` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/ExecutiveWindow.swift; SUPRA/SUPRAOSProductRootView.swift; SUPRA/SUPRAOSDesignSystem.swift; vues explicitement allowlistées — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/U09/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/U09/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/U09/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `ExecutiveWindow, SUPRAOSProductRootView, SUPRAOSDesignSystem`; `git diff --check -- $(tr '\n' ' ' < Evidence/U09/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Déprécier shells alternatifs démontré dans `tests.log`.
- **Risque spécifique:** shell/navigation concurrente ou logique métier dans View; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/U09/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** U08. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### U10 — Certifier CP5

- **Statut:** SOURCE-BLOCKED — G0 + U09
- **Objectif spécifique:** [PROPOSAL] définir l’adaptateur minimal pour Certifier CP5; symboles fermés: ExecutiveWindow, SUPRAOSProductRootView, SUPRAOSDesignSystem, DashboardView, ContentView, 12 espaces canoniques.
- **Description:** Produire seulement l’incrément U10, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** ExecutiveWindow, SUPRAOSProductRootView, SUPRAOSDesignSystem, DashboardView, ContentView, 12 espaces canoniques; chemins: SUPRA/ExecutiveWindow.swift; SUPRA/SUPRAOSProductRootView.swift; SUPRA/SUPRAOSDesignSystem.swift; vues explicitement allowlistées.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `U09` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** SUPRA/ExecutiveWindow.swift; SUPRA/SUPRAOSProductRootView.swift; SUPRA/SUPRAOSDesignSystem.swift; vues explicitement allowlistées — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/U10/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/U10/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/U10/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `ExecutiveWindow, SUPRAOSProductRootView, SUPRAOSDesignSystem`; `git diff --check -- $(tr '\n' ' ' < Evidence/U10/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Certifier CP5 démontré dans `tests.log`.
- **Risque spécifique:** shell/navigation concurrente ou logique métier dans View; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/U10/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** U09. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

## LOT 8 Provider

### P01 — Cartographie providers

- **Statut:** SOURCE-BLOCKED — G0 + R17
- **Objectif spécifique:** [PROPOSAL] inventorier les références et usages pour Cartographie providers; symboles fermés: SUPRAProviderRegistry, SUPRAProviderBroker, SUPRAOllamaProvider, OpenCodeClient, OpenCodeBridge, KnowledgeProvider.
- **Description:** Produire seulement l’incrément P01, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRAProviderRegistry, SUPRAProviderBroker, SUPRAOllamaProvider, OpenCodeClient, OpenCodeBridge, KnowledgeProvider; chemins: sources Provider/OpenCode/KnowledgeProvider explicitement allowlistées.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `R17` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** sources Provider/OpenCode/KnowledgeProvider explicitement allowlistées — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/P01/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/P01/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/P01/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRAProviderRegistry, SUPRAProviderBroker, SUPRAOllamaProvider`; `git diff --check -- $(tr '\n' ' ' < Evidence/P01/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Cartographie providers démontré dans `tests.log`.
- **Risque spécifique:** routage Provider ambigu ou panne masquée; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/P01/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** R17. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### P02 — Unifier Registry

- **Statut:** SOURCE-BLOCKED — G0 + P01
- **Objectif spécifique:** [PROPOSAL] définir l’adaptateur minimal pour Unifier Registry; symboles fermés: SUPRAProviderRegistry, SUPRAProviderBroker, SUPRAOllamaProvider, OpenCodeClient, OpenCodeBridge, KnowledgeProvider.
- **Description:** Produire seulement l’incrément P02, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRAProviderRegistry, SUPRAProviderBroker, SUPRAOllamaProvider, OpenCodeClient, OpenCodeBridge, KnowledgeProvider; chemins: sources Provider/OpenCode/KnowledgeProvider explicitement allowlistées.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `P01` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** sources Provider/OpenCode/KnowledgeProvider explicitement allowlistées — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/P02/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/P02/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/P02/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRAProviderRegistry, SUPRAProviderBroker, SUPRAOllamaProvider`; `git diff --check -- $(tr '\n' ' ' < Evidence/P02/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Unifier Registry démontré dans `tests.log`.
- **Risque spécifique:** routage Provider ambigu ou panne masquée; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/P02/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** P01. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### P03 — Broker/routage

- **Statut:** SOURCE-BLOCKED — G0 + P02
- **Objectif spécifique:** [PROPOSAL] raccorder un seul flux pour Broker/routage; symboles fermés: SUPRAProviderRegistry, SUPRAProviderBroker, SUPRAOllamaProvider, OpenCodeClient, OpenCodeBridge, KnowledgeProvider.
- **Description:** Produire seulement l’incrément P03, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRAProviderRegistry, SUPRAProviderBroker, SUPRAOllamaProvider, OpenCodeClient, OpenCodeBridge, KnowledgeProvider; chemins: sources Provider/OpenCode/KnowledgeProvider explicitement allowlistées.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `P02` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** sources Provider/OpenCode/KnowledgeProvider explicitement allowlistées — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/P03/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/P03/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/P03/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRAProviderRegistry, SUPRAProviderBroker, SUPRAOllamaProvider`; `git diff --check -- $(tr '\n' ' ' < Evidence/P03/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Broker/routage démontré dans `tests.log`.
- **Risque spécifique:** routage Provider ambigu ou panne masquée; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/P03/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** P02. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### P04 — Projection Provider

- **Statut:** SOURCE-BLOCKED — G0 + P03
- **Objectif spécifique:** [PROPOSAL] prouver la parité nominale et dégradée pour Projection Provider; symboles fermés: SUPRAProviderRegistry, SUPRAProviderBroker, SUPRAOllamaProvider, OpenCodeClient, OpenCodeBridge, KnowledgeProvider.
- **Description:** Produire seulement l’incrément P04, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRAProviderRegistry, SUPRAProviderBroker, SUPRAOllamaProvider, OpenCodeClient, OpenCodeBridge, KnowledgeProvider; chemins: sources Provider/OpenCode/KnowledgeProvider explicitement allowlistées.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `P03` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** sources Provider/OpenCode/KnowledgeProvider explicitement allowlistées — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/P04/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/P04/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/P04/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRAProviderRegistry, SUPRAProviderBroker, SUPRAOllamaProvider`; `git diff --check -- $(tr '\n' ' ' < Evidence/P04/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Projection Provider démontré dans `tests.log`.
- **Risque spécifique:** routage Provider ambigu ou panne masquée; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/P04/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** P03. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### P05 — Certifier Providers

- **Statut:** SOURCE-BLOCKED — G0 + P04
- **Objectif spécifique:** [PROPOSAL] inventorier les références et usages pour Certifier Providers; symboles fermés: SUPRAProviderRegistry, SUPRAProviderBroker, SUPRAOllamaProvider, OpenCodeClient, OpenCodeBridge, KnowledgeProvider.
- **Description:** Produire seulement l’incrément P05, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** SUPRAProviderRegistry, SUPRAProviderBroker, SUPRAOllamaProvider, OpenCodeClient, OpenCodeBridge, KnowledgeProvider; chemins: sources Provider/OpenCode/KnowledgeProvider explicitement allowlistées.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `P04` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** sources Provider/OpenCode/KnowledgeProvider explicitement allowlistées — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/P05/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/P05/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/P05/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `SUPRAProviderRegistry, SUPRAProviderBroker, SUPRAOllamaProvider`; `git diff --check -- $(tr '\n' ' ' < Evidence/P05/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Certifier Providers démontré dans `tests.log`.
- **Risque spécifique:** routage Provider ambigu ou panne masquée; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/P05/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** P04. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

## LOT 9 Developer

### V01 — Diagnostics Developer

- **Statut:** SOURCE-BLOCKED — G0 + R17,P05
- **Objectif spécifique:** [PROPOSAL] inventorier les références et usages pour Diagnostics Developer; symboles fermés: WorkerPoolView, SUPRARuntimeGraph, SUPRAScheduler, SUPRAWorkerFabric, SUPRAResourceIntelligenceView, ReportKnowledgeProvider, ContinuityManager.
- **Description:** Produire seulement l’incrément V01, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** WorkerPoolView, SUPRARuntimeGraph, SUPRAScheduler, SUPRAWorkerFabric, SUPRAResourceIntelligenceView, ReportKnowledgeProvider, ContinuityManager; chemins: sources Developer/Worker/Report/Continuity explicitement allowlistées.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `R17,P05` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** sources Developer/Worker/Report/Continuity explicitement allowlistées — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/V01/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/V01/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/V01/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `WorkerPoolView, SUPRARuntimeGraph, SUPRAScheduler`; `git diff --check -- $(tr '\n' ' ' < Evidence/V01/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Diagnostics Developer démontré dans `tests.log`.
- **Risque spécifique:** outil Developer mutateur ou preuve non reproductible; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/V01/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** R17,P05. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### V02 — Workers/Scheduler/AST

- **Statut:** SOURCE-BLOCKED — G0 + V01
- **Objectif spécifique:** [PROPOSAL] définir l’adaptateur minimal pour Workers/Scheduler/AST; symboles fermés: WorkerPoolView, SUPRARuntimeGraph, SUPRAScheduler, SUPRAWorkerFabric, SUPRAResourceIntelligenceView, ReportKnowledgeProvider, ContinuityManager.
- **Description:** Produire seulement l’incrément V02, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** WorkerPoolView, SUPRARuntimeGraph, SUPRAScheduler, SUPRAWorkerFabric, SUPRAResourceIntelligenceView, ReportKnowledgeProvider, ContinuityManager; chemins: sources Developer/Worker/Report/Continuity explicitement allowlistées.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `V01` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** sources Developer/Worker/Report/Continuity explicitement allowlistées — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/V02/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/V02/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/V02/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `WorkerPoolView, SUPRARuntimeGraph, SUPRAScheduler`; `git diff --check -- $(tr '\n' ' ' < Evidence/V02/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Workers/Scheduler/AST démontré dans `tests.log`.
- **Risque spécifique:** outil Developer mutateur ou preuve non reproductible; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/V02/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** V01. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### V03 — Reports/Continuity

- **Statut:** SOURCE-BLOCKED — G0 + V02
- **Objectif spécifique:** [PROPOSAL] raccorder un seul flux pour Reports/Continuity; symboles fermés: WorkerPoolView, SUPRARuntimeGraph, SUPRAScheduler, SUPRAWorkerFabric, SUPRAResourceIntelligenceView, ReportKnowledgeProvider, ContinuityManager.
- **Description:** Produire seulement l’incrément V03, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** WorkerPoolView, SUPRARuntimeGraph, SUPRAScheduler, SUPRAWorkerFabric, SUPRAResourceIntelligenceView, ReportKnowledgeProvider, ContinuityManager; chemins: sources Developer/Worker/Report/Continuity explicitement allowlistées.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `V02` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** sources Developer/Worker/Report/Continuity explicitement allowlistées — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/V03/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/V03/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/V03/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `WorkerPoolView, SUPRARuntimeGraph, SUPRAScheduler`; `git diff --check -- $(tr '\n' ' ' < Evidence/V03/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Reports/Continuity démontré dans `tests.log`.
- **Risque spécifique:** outil Developer mutateur ou preuve non reproductible; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/V03/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** V02. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### V04 — Certifier Developer

- **Statut:** SOURCE-BLOCKED — G0 + V03
- **Objectif spécifique:** [PROPOSAL] prouver la parité nominale et dégradée pour Certifier Developer; symboles fermés: WorkerPoolView, SUPRARuntimeGraph, SUPRAScheduler, SUPRAWorkerFabric, SUPRAResourceIntelligenceView, ReportKnowledgeProvider, ContinuityManager.
- **Description:** Produire seulement l’incrément V04, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** WorkerPoolView, SUPRARuntimeGraph, SUPRAScheduler, SUPRAWorkerFabric, SUPRAResourceIntelligenceView, ReportKnowledgeProvider, ContinuityManager; chemins: sources Developer/Worker/Report/Continuity explicitement allowlistées.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `V03` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** sources Developer/Worker/Report/Continuity explicitement allowlistées — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/V04/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/V04/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/V04/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `WorkerPoolView, SUPRARuntimeGraph, SUPRAScheduler`; `git diff --check -- $(tr '\n' ' ' < Evidence/V04/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Certifier Developer démontré dans `tests.log`.
- **Risque spécifique:** outil Developer mutateur ou preuve non reproductible; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/V04/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** V03. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

## LOT 10 Industrialisation

### I01 — Harnais parité

- **Statut:** SOURCE-BLOCKED — G0 + U10,V04
- **Objectif spécifique:** [PROPOSAL] inventorier les références et usages pour Harnais parité; symboles fermés: ContentView, CommandCenterView, SupraControlCenterView, TotalControlTowerView, SUPRAOSCommandCenterView, SUPRAOperationalCoreView, SUPRAOperationalControlCenterView, SUPRAEnvironmentCommandCenterView.
- **Description:** Produire seulement l’incrément I01, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** ContentView, CommandCenterView, SupraControlCenterView, TotalControlTowerView, SUPRAOSCommandCenterView, SUPRAOperationalCoreView, SUPRAOperationalControlCenterView, SUPRAEnvironmentCommandCenterView; chemins: shells/stores/pollings strictement listés par manifest Ixx.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `U10,V04` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** shells/stores/pollings strictement listés par manifest Ixx — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/I01/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/I01/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/I01/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `ContentView, CommandCenterView, SupraControlCenterView`; `git diff --check -- $(tr '\n' ' ' < Evidence/I01/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Harnais parité démontré dans `tests.log`.
- **Risque spécifique:** suppression prématurée ou rollback incomplet; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/I01/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** U10,V04. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### I02 — Pollings redondants

- **Statut:** SOURCE-BLOCKED — G0 + I01
- **Objectif spécifique:** [PROPOSAL] définir l’adaptateur minimal pour Pollings redondants; symboles fermés: ContentView, CommandCenterView, SupraControlCenterView, TotalControlTowerView, SUPRAOSCommandCenterView, SUPRAOperationalCoreView, SUPRAOperationalControlCenterView, SUPRAEnvironmentCommandCenterView.
- **Description:** Produire seulement l’incrément I02, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** ContentView, CommandCenterView, SupraControlCenterView, TotalControlTowerView, SUPRAOSCommandCenterView, SUPRAOperationalCoreView, SUPRAOperationalControlCenterView, SUPRAEnvironmentCommandCenterView; chemins: shells/stores/pollings strictement listés par manifest Ixx.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `I01` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** shells/stores/pollings strictement listés par manifest Ixx — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/I02/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/I02/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/I02/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `ContentView, CommandCenterView, SupraControlCenterView`; `git diff --check -- $(tr '\n' ' ' < Evidence/I02/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Pollings redondants démontré dans `tests.log`.
- **Risque spécifique:** suppression prématurée ou rollback incomplet; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/I02/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** I01. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### I03 — Fallbacks démonstration

- **Statut:** SOURCE-BLOCKED — G0 + I02
- **Objectif spécifique:** [PROPOSAL] raccorder un seul flux pour Fallbacks démonstration; symboles fermés: ContentView, CommandCenterView, SupraControlCenterView, TotalControlTowerView, SUPRAOSCommandCenterView, SUPRAOperationalCoreView, SUPRAOperationalControlCenterView, SUPRAEnvironmentCommandCenterView.
- **Description:** Produire seulement l’incrément I03, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** ContentView, CommandCenterView, SupraControlCenterView, TotalControlTowerView, SUPRAOSCommandCenterView, SUPRAOperationalCoreView, SUPRAOperationalControlCenterView, SUPRAEnvironmentCommandCenterView; chemins: shells/stores/pollings strictement listés par manifest Ixx.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `I02` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** shells/stores/pollings strictement listés par manifest Ixx — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/I03/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/I03/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/I03/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `ContentView, CommandCenterView, SupraControlCenterView`; `git diff --check -- $(tr '\n' ' ' < Evidence/I03/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Fallbacks démonstration démontré dans `tests.log`.
- **Risque spécifique:** suppression prématurée ou rollback incomplet; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/I03/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** I02. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### I04 — Navigation parallèle

- **Statut:** SOURCE-BLOCKED — G0 + I03
- **Objectif spécifique:** [PROPOSAL] prouver la parité nominale et dégradée pour Navigation parallèle; symboles fermés: ContentView, CommandCenterView, SupraControlCenterView, TotalControlTowerView, SUPRAOSCommandCenterView, SUPRAOperationalCoreView, SUPRAOperationalControlCenterView, SUPRAEnvironmentCommandCenterView.
- **Description:** Produire seulement l’incrément I04, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** ContentView, CommandCenterView, SupraControlCenterView, TotalControlTowerView, SUPRAOSCommandCenterView, SUPRAOperationalCoreView, SUPRAOperationalControlCenterView, SUPRAEnvironmentCommandCenterView; chemins: shells/stores/pollings strictement listés par manifest Ixx.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `I03` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** shells/stores/pollings strictement listés par manifest Ixx — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/I04/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/I04/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/I04/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `ContentView, CommandCenterView, SupraControlCenterView`; `git diff --check -- $(tr '\n' ' ' < Evidence/I04/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Navigation parallèle démontré dans `tests.log`.
- **Risque spécifique:** suppression prématurée ou rollback incomplet; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/I04/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** I03. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### I05 — Stores UI dupliqués

- **Statut:** SOURCE-BLOCKED — G0 + I04
- **Objectif spécifique:** [PROPOSAL] inventorier les références et usages pour Stores UI dupliqués; symboles fermés: ContentView, CommandCenterView, SupraControlCenterView, TotalControlTowerView, SUPRAOSCommandCenterView, SUPRAOperationalCoreView, SUPRAOperationalControlCenterView, SUPRAEnvironmentCommandCenterView.
- **Description:** Produire seulement l’incrément I05, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** ContentView, CommandCenterView, SupraControlCenterView, TotalControlTowerView, SUPRAOSCommandCenterView, SUPRAOperationalCoreView, SUPRAOperationalControlCenterView, SUPRAEnvironmentCommandCenterView; chemins: shells/stores/pollings strictement listés par manifest Ixx.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `I04` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** shells/stores/pollings strictement listés par manifest Ixx — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/I05/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/I05/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/I05/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `ContentView, CommandCenterView, SupraControlCenterView`; `git diff --check -- $(tr '\n' ' ' < Evidence/I05/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Stores UI dupliqués démontré dans `tests.log`.
- **Risque spécifique:** suppression prématurée ou rollback incomplet; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/I05/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** I04. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### I06 — Retrait shells alternatifs

- **Statut:** SOURCE-BLOCKED — G0 + I05
- **Objectif spécifique:** [PROPOSAL] définir l’adaptateur minimal pour Retrait shells alternatifs; symboles fermés: ContentView, CommandCenterView, SupraControlCenterView, TotalControlTowerView, SUPRAOSCommandCenterView, SUPRAOperationalCoreView, SUPRAOperationalControlCenterView, SUPRAEnvironmentCommandCenterView.
- **Description:** Produire seulement l’incrément I06, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** ContentView, CommandCenterView, SupraControlCenterView, TotalControlTowerView, SUPRAOSCommandCenterView, SUPRAOperationalCoreView, SUPRAOperationalControlCenterView, SUPRAEnvironmentCommandCenterView; chemins: shells/stores/pollings strictement listés par manifest Ixx.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `I05` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** shells/stores/pollings strictement listés par manifest Ixx — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/I06/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/I06/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/I06/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `ContentView, CommandCenterView, SupraControlCenterView`; `git diff --check -- $(tr '\n' ' ' < Evidence/I06/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Retrait shells alternatifs démontré dans `tests.log`.
- **Risque spécifique:** suppression prématurée ou rollback incomplet; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/I06/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** I05. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### I07 — Certifier CP6

- **Statut:** SOURCE-BLOCKED — G0 + I06
- **Objectif spécifique:** [PROPOSAL] raccorder un seul flux pour Certifier CP6; symboles fermés: ContentView, CommandCenterView, SupraControlCenterView, TotalControlTowerView, SUPRAOSCommandCenterView, SUPRAOperationalCoreView, SUPRAOperationalControlCenterView, SUPRAEnvironmentCommandCenterView.
- **Description:** Produire seulement l’incrément I07, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** ContentView, CommandCenterView, SupraControlCenterView, TotalControlTowerView, SUPRAOSCommandCenterView, SUPRAOperationalCoreView, SUPRAOperationalControlCenterView, SUPRAEnvironmentCommandCenterView; chemins: shells/stores/pollings strictement listés par manifest Ixx.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `I06` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** shells/stores/pollings strictement listés par manifest Ixx — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/I07/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/I07/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/I07/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `ContentView, CommandCenterView, SupraControlCenterView`; `git diff --check -- $(tr '\n' ' ' < Evidence/I07/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Certifier CP6 démontré dans `tests.log`.
- **Risque spécifique:** suppression prématurée ou rollback incomplet; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/I07/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** I06. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

### I08 — Freeze Version Ultime

- **Statut:** SOURCE-BLOCKED — G0 + I07
- **Objectif spécifique:** [PROPOSAL] prouver la parité nominale et dégradée pour Freeze Version Ultime; symboles fermés: ContentView, CommandCenterView, SupraControlCenterView, TotalControlTowerView, SUPRAOSCommandCenterView, SUPRAOperationalCoreView, SUPRAOperationalControlCenterView, SUPRAEnvironmentCommandCenterView.
- **Description:** Produire seulement l’incrément I08, sans capacité nouvelle; si la doctrine événement/loi Runtime/UI est nécessaire, consigner `SOURCE-BLOCKED` dans `certificate.md` et s’arrêter.
- **Périmètre IN:** ContentView, CommandCenterView, SupraControlCenterView, TotalControlTowerView, SUPRAOSCommandCenterView, SUPRAOperationalCoreView, SUPRAOperationalControlCenterView, SUPRAEnvironmentCommandCenterView; chemins: shells/stores/pollings strictement listés par manifest Ixx.
- **Périmètre OUT:** Packages, `SUPRA.xcodeproj`, fonctions nouvelles, fichiers non résolus dans `allowlist.txt`, décisions réservées aux trois doctrines absentes.
- **Entrées / préconditions:** dépendances `I07` certifiées; G0 vert sauf A01/A02 documentaires; audit Swift préalable; aucun overlap dirty.
- **Sorties produit exactes:** shells/stores/pollings strictement listés par manifest Ixx — modifications futures limitées aux chemins résolus dans allowlist.txt; aucun fichier hors allowlist.
- **Preuves exactes:** `Evidence/I08/{before.sha256,before.status,allowlist.txt,change.patch,inverse.patch,commands.log,tests.log,after.sha256,certificate.md}`.
- **Procédure:** 1. résoudre les chemins/symboles IN; 2. écrire allowlist et hashes before; 3. exécuter prechecks; 4. STOP si G0/overlap/test rouge; 5. Builder applique l’unique patch allowlisté; 6. exécuter test ciblé puis diff-check; 7. Auditor compare before/after et signe PASS/FAIL; 8. produire inverse.patch et certificat.
- **Prechecks / commandes:** `git status --short -- $(tr '\n' ' ' < Evidence/I08/allowlist.txt)` attendu vide ou attribution explicitement signée; `shasum -a 256 $(tr '\n' ' ' < Evidence/I08/allowlist.txt)` attendu exit 0; commande domaine `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendue exit 0.
- **Validation spécifique:** présence/référence unique de `ContentView, CommandCenterView, SupraControlCenterView`; `git diff --check -- $(tr '\n' ' ' < Evidence/I08/allowlist.txt)` exit 0; commande domaine exit 0; aucun chemin hors allowlist dans `git diff --name-only`; critère Freeze Version Ultime démontré dans `tests.log`.
- **Risque spécifique:** suppression prématurée ou rollback incomplet; trigger: second owner, second shell/source, test de parité rouge ou provenance absente.
- **Rollback / post-test:** STOP; appliquer `Evidence/I08/inverse.patch` uniquement aux chemins allowlistés (ou archive par chemin); recalculer SHA-256 égal à `before.sha256`; relancer `xcodebuild -project SUPRA.xcodeproj -scheme SUPRA -configuration Debug -sdk macosx test` attendu exit 0; Auditor atteste le retour.
- **RTO:** 45 min. **Durée:** 3 h. **Dépendances:** I07. **Autorité:** Architect/Router décision; Builder seul writer; Auditor certification; human gate aux checkpoints.

