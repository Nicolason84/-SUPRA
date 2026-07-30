# SUPRA Lab — Architecture V1

## Objectif

Laboratoire d'orchestration IA modulaire, gratuit, multi-modèle.  
Conçu pour être compatible OpenCode, Ollama, OpenAI-compatible APIs, modèles locaux et gratuits.

---

## Modules

### Router
- **Rôle**: Aiguille chaque mission vers le ou les agents compétents selon la charge, la capacité et la disponibilité des modèles.
- **Entrées**: Mission (texte structuré), registre des capacités des agents.
- **Sorties**: Plan d'affectation (agent + modèle).
- **Dépendances**: Capability Registry, Model Registry.
- **Critères de qualité**: Latence < 500ms, disponibilité 99.9%, décision déterministe ou probabiliste selon mode.

### Planner
- **Rôle**: Décompose une mission en étapes atomiques ordonnancées avec dépendances explicites.
- **Entrées**: Mission, contraintes de ressource.
- **Sorties**: Graphe de tâches (DAG).
- **Dépendances**: Router, Workflow Engine.
- **Critères de qualité**: Complétude de décomposition, pas d'étapes manquantes ou cycliques.

### Memory
- **Rôle**: Stocke et retrouve le contexte des missions passées, les décisions architecturales, les patterns réutilisables.
- **Entrées**: Requête de contexte (embedding + filtres).
- **Sorties**: Contexte pertinent (documents, décisions, patterns).
- **Dépendances**: Learning (pour mise à jour), tous les modules.
- **Critères de qualité**: Recall > 90%, Precision > 80%, latence < 200ms.

### Builder
- **Rôle**: Génère du code ou des artefacts à partir des spécifications fournies.
- **Entrées**: Spécification fonctionnelle, patrons de conception, contraintes.
- **Sorties**: Code, documentation, configurations.
- **Dépendances**: Planner, Memory, Model Registry.
- **Critères de qualité**: Code compilable, testé, conforme aux conventions du projet.

### Auditor
- **Rôle**: Analyse statique du code produit (conformité, sécurité, performance).
- **Entrées**: Code source, règles de conformité, base de vulnérabilités.
- **Sorties**: Rapport d'audit (anomalies, risques, scores).
- **Dépendances**: Builder, Validator.
- **Critères de qualité**: AUCune régression non détectée, faux positifs < 5%.

### Reviewer
- **Rôle**: Relecture humaine ou automatisée du code avec suggestions d'amélioration.
- **Entrées**: Code, rapport d'audit, normes du projet.
- **Sorties**: Revue structurée (commentaires, scores, décisions).
- **Dépendances**: Auditor, Builder.
- **Critères de qualité**: Couverture de revue > 95% des fichiers modifiés.

### Comparator
- **Rôle**: Compare les sorties de plusieurs agents ou modèles pour identifier divergences et consensus.
- **Entrées**: Sorties multiples (code, texte, décisions).
- **Sorties**: Matrice de comparaison, score de consensus, divergences classifiées.
- **Dépendances**: Fusion Engine, Router.
- **Critères de qualité**: Détection de toute divergence significative.

### Fusion Engine
- **Rôle**: Fusionne les résultats multiples en une sortie unique cohérente.
- **Entrées**: Sorties multiples + matrice de comparaison.
- **Sorties**: Résultat fusionné (vote majoritaire, weighted merge, synthèse).
- **Dépendances**: Comparator.
- **Critères de qualité**: Cohérence sémantique, pas de conflit non résolu.

### Validator
- **Rôle**: Valide le résultat final contre les critères d'acceptation de la mission.
- **Entrées**: Résultat fusionné, critères d'acceptation, tests.
- **Sorties**: Rapport de validation (pass/fail, couverture, score).
- **Dépendances**: Fusion Engine, Benchmark.
- **Critères de qualité**: 100% des critères d'acceptation vérifiés.

### Benchmark
- **Rôle**: Évalue les performances des modèles et des agents sur des jeux de tests standardisés.
- **Entrées**: Modèles, jeux de tests, métriques cibles.
- **Sorties**: Scores de performance, classement, tendances.
- **Dépendances**: Model Registry, Learning.
- **Critères de qualité**: Tests reproductibles, métriques normalisées.

### Learning
- **Rôle**: Améliore les modules par rétroaction (feedback loops, fine-tuning, mise à jour de prompts).
- **Entrées**: Résultats, métriques, feedback utilisateur.
- **Sorties**: Prompts optimisés, poids ajustés, règles mises à jour.
- **Dépendances**: Model Registry, Prompt Registry.
- **Critères de qualité**: Amélioration mesurable > 5% par cycle.

### Model Registry
- **Rôle**: Catalogue des modèles disponibles avec leurs capacités, coûts, disponibilités.
- **Entrées**: Modèles (Ollama, OpenAI, locaux, gratuits).
- **Sorties**: Fiche de modèle (capacités, statut, coût).
- **Dépendances**: Router, Benchmark.
- **Critères de qualité**: Mise à jour temps réel, détection de panne.

### Prompt Registry
- **Rôle**: Bibliothèque de prompts versionnés et optimisés.
- **Entrées**: Prompts, métadonnées (version, auteur, test).
- **Sorties**: Prompt versionné.
- **Dépendances**: Learning, Builder.
- **Critères de qualité**: Traçabilité, A/B testing possible.

### Capability Registry
- **Rôle**: Catalogue des capacités disponibles (quel agent/quel modèle fait quoi).
- **Entrées**: Modules, modèles, fonctions exposées.
- **Sorties**: Graphe de capacités.
- **Dépendances**: Model Registry, Prompt Registry.
- **Critères de qualité**: Exactitude des correspondances besoin → capacité.

### Workflow Engine
- **Rôle**: Ordonnance et exécute le pipeline complet.
- **Entrées**: Plan du Planner, modules disponibles.
- **Sorties**: Résultat final de la mission.
- **Dépendances**: Tous les modules.
- **Critères de qualité**: Résilience aux pannes, parallélisation, logs complets.

---

## Pipeline complet

```
Mission
  │
  ▼
Router ────────────────── Capability Registry
  │                           Model Registry
  ▼
Planner ────────────────── Memory
  │
  ▼
Sélection des agents ──── Workflow Engine
  │
  ▼
Exécution parallèle ───── Builder 1  Auditor 1
                             Builder 2  Auditor 2
                             Builder N  Auditor N
  │
  ├── Comparator ◄────────── Sorties multiples
  │
  ▼
Fusion Engine ◄────────── Matrice de comparaison
  │
  ▼
Validator ◄────────────── Critères d'acceptation
  │                         Benchmark
  ▼
Résultat final
  │
  ├── Memory (stockage du contexte)
  ├── Learning (feedback loop)
  └── Reviewer (relecture finale optionnelle)
```

---

## Contraintes architecturale

- **Aucun couplage fort**: Chaque module expose une interface (port) et dépend d'interfaces (adapters).
- **Composants remplaçables**: Chaque module peut être remplacé sans impacter les autres.
- **Multi-modèle**: Les appels aux modèles passent par une abstraction unifiée compatible Ollama, OpenAI, locaux.
- **OpenCode compatible**: Les agents OpenCode peuvent être enrôlés comme n'importe quel module via le Router.
- **Gratuit**: Priorité aux modèles open-source (Ollama, Llama, Mistral) et aux APIs gratuites.

---

## Principes de communication

- Tous les échanges passent par un bus de messages asynchrone.
- Chaque module produit des événements (logs, métriques, résultats).
- Les modules ne s'appellent pas directement — le Workflow Engine coordonne.
- Les données transitent en JSON structuré.
