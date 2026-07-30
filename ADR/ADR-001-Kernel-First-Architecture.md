# ADR-001 : Architecture First — KERNEL EXECUTION OS

## Statut
PROPOSED

## Date
2026-07-29

## Contexte
L’audit GABRIEL marque officiellement la fin de la phase d’exploration de NOVA ERA.

Nous disposons désormais d’une cartographie complète des composants vivants, de leurs responsabilités, de leurs dépendances et de leurs relations.

Cette connaissance est suffisante pour changer de priorité :

**Objectif** : Consolidated Before Extending — Consolider le Kernel avant d’ajouter de nouvelles fonctionnalités.

Le véritable cœur de NOVA ERA n’est pas un Runtime, ni une Forge, ni une conversation.

Le cœur de NOVA ERA est un **Kernel — un système d’exploitation exécutif gouverné par une mémoire persistante, versionnée et vérifiable**.

Ce Kernel devient la **seule source de vérité** pour tout le système.

## Décision
Établir un **Kernel Execution Operating System (KERNEL OS)** comme l’architecture de base de NOVA ERA.

Le Kernel sera un contrat d’architecture et de gouvernance qui définit les règles communes pour tous les composants, indépendamment du langage, du fournisseur d’IA ou de l’agent utilisé.

Le Kernel gouvernera l’état du système, les missions, les preuves, les événements, les composants, les fournisseurs et toutes les relations entre eux.

Tous les agents (ChatGPT, OpenCode, Codex, Claude, Gemini, etc.) seront des **clients du Kernel** qui lisent l’état courant, exécutent leurs missions, publient des résultats et attendent la validation.

Les agents ne posséderont jamais leur propre vérité — ils collaboreront sur une même base gouvernée.

Le Kernel comprendra des registres spécialisés (Mission, Runtime, Decision, Proof, Component, Provider, Graph, Event, Snapshot, ADR) qui constituent la donnée canonique.

L’Executive Memory sera une projection consolidée des registres, fournissant une vue opérationnelle pour les agents.

Tout nouveau module devra d’abord s’intégrer au contrat du Kernel avant d’être implémenté.

L’objectif est de développer un système d’exploitation exécutif capable de conserver l’état du système, de gouverner les décisions, de coordonner les agents et d’assurer la continuité du projet, indépendamment des modèles d’IA utilisés.

## Justification

### 1. Fins de la Phase d’Exploration
- L’audit GABRIEL a validé les composants existants.
- La cartographie est complète et fiable.
- Pas besoin de nouvelles fonctionnalités immédiatement.

### 2. Changement de Paradigme
- Les modèles d’IA évoluent, les fournisseurs changent.
- Les conversations peuvent se terminer.
- Le système doit survivre à ces changements.
- Solution : Un Kernel permanent et indépendant du fournisseur.

### 3. Architecture First
- Les règles doivent être stables avant le code.
- Le Kernel est un contrat, pas un dossier.
- Le code peut évoluer, le contrat reste stable.

### 4. Source de Vérité Unique
- Pas de vérité fragmentée entre modèles.
- Pas de mémoire dépendante d’un agent spécifique.
- Provenance unique et traçable.

### 5. Gouvernance Centralisée
- Tous les registres sont intégrés et gouvernés.
- Validation uniforme pour tous les composants.
- Application cohérente des politiques.

### 6. Collaborativité Unifiée des Agents
- Tous les agents suivent le même cycle de lecture-exécution-validation.
- Collaboration équitable via le même Kernel.
- Pas de hiérarchie entre modèles.

### 7. Résilience des Fournisseurs
- Le Provider Manager sélectionne automatiquement un autre moteur.
- La continuité est garantie indépendamment des quotas ou de la disponibilité.

### 8. Traçabilité et Certification
- Chaque écriture doit être prouvée.
- Validation utilisateur forcée pour les décisions significatives.
- Audit complet de toutes les mutations.

## Conséquences

### Positives
- **Continuité**: Le système survit aux changements de modèles et de fournisseurs.
- **Gouvernance**: Règles stables et contractuelles pour tous les composants.
- **Traçabilité**: Chaîne complète de confiance avec audit.
- **Réutilisation**: Tous les composants partagent une base commune.
- **Perspective unifiée**: Toutes les décisions et preuves sont centralisées.

### Négatives
- **Courbe d’apprentissage**: Les agents doivent adopter le Kernel.
- **Governance overhead**: Validation stricte et revue des décisions.
- **Dépendance centrale**: Le système dépend fortement du Kernel.

### Neutres
- **Compromis**: Temps de développement vs stabilité à long terme.
- **Évolution**: Le Kernel peut être versionné.
- **Écosystème**: Nouvelle base pour les contributions communautaires.

## Alternatives Considérées

### Alternative 1 : Architecture Orientée Runtime
**Avantages** : Focalisé sur l’exécution, activation rapide.
**Inconvénients** : Pas de gouvernance centralisée, vérité éphémère.
**Raison du rejet** : Pas de continuité à long terme.

### Alternative 2 : Multi-Mémoire Par Agent
**Avantages** : Réduction de la charge du Kernel.
**Inconvénients** : Vérité fragmentée, perte de traçabilité.
**Raison du rejet** : Pas d’Évidence Force, violation des principes SUPRA.

### Alternative 3 : Microservices Sans Kernel Central
**Avantages** : Déploiement indépendant.
**Inconvénients** : Pas de cohérence globale, conflits de versions.
**Raison du rejet** : Pas de Source de Vérité unique, violation de l’Architecture Force.

## Compliance
- ✅ Conforme à SUPRA_CONSTITUTION.md : La Constitution est intégrée comme base.
- ✅ Conforme à SUPRA_IMMUTABLE_PRINCIPLES.md : Gouvernance permanente.
- ✅ Conforme à SUPRA_EXECUTIVE_CANON.md : Le Kernel est l’exécutive system.

## Décideur
SUPRA-Architect (Emmanuel Rykachev)

## Validateurs
- SUPRA-Auditor : [APPROVED]
- SUPRA-Reviewer : [APPROVED]

## Références
- AGENTS.md : Contrat de fonctionnement SUPRA.
- SUPRA_AGENT_REGISTRY_V1.md : Registre des agents.
- SUPRA_ROUTER_SPECIFICATION_V1.md : Spécification du routeur.
- SUPRA_MODEL_REGISTRY_V1.md : Registre des modèles.
- SUPRA_AI_LAB_ARCHITECTURE_V1.md : Documentation de conception.
- SUPRA_FACTORY_CONSTITUTION.md : Constitution des factories.

## Notes

### Statut de Mise en œuvre

Cette ADR propose une transformation architecturale fondamentale. Sa mise en œuvre nécessite :

1. **Création des registres** : 10 registres spécialisés dans .kernel/
2. **Schema Definition** : Schémas pour tous les objets (mission, décision, preuve, etc.)
3. **Contrats de lecture/écriture** : Règles de gouvernance et contrats de fournisseurs
4. **Internal API** : Interfaces pour la communication agent-kernel
5. **Executive Memory** : Projection des registres pour les agents
6. **ADR Registry** : Documentation des décisions architecturales
7. **Provider Manager** : Sélection automatique des fournisseurs
8. **Gate System** : Validation CONTINUE | ADAPT | REPLAN | HALT

### Prochaines Étapes

1. Créer **ADR_REGISTRY.json** (version 1.0.0)
2. Déployer **KernelRegistry.json** et **WorkspaceRegistry.json**
3. Déployer **Runtime.json** comme état live
4. Implémenter tous les registres dans .kernel/
5. Valider via FACTORY_01_ARCHITECTURE et FACTORY_06_PROOF
6. Autoriser les décisions d’implémentation via FACTORY_10_EXECUTIVE

### Signification

Cette décision transforme NOVA ERA d’une **collection de conversations** à un **exécutive OS gouverné par une mémoire persistante**.

Le succès sera mesuré par :
- **Continuité** : Session reprises sans perte de données.
- **Gouvernance** : Toutes les decisions validées et traçables.
- **Collaboration** : Tous les agents partagent la même vérité.

Cette fondation soutient NOVA ERA pour les années à venir, indépendamment de l’évolution des modèles, fournisseurs et interfaces utilisateurs.