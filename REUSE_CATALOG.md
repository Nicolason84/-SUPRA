# REUSE_CATALOG

> Mission: SUPRA_CANONICAL_DISCOVERY_V1
> Generated: 2026-07-24T16:35:00Z
> Authority: READ_ONLY

---

## 1. COMPOSANTS RÉUTILISABLES

### 1.1 CAnnoNicoIntegrationPackage (PKG-001)

| Composant | Type | Réutilisable | Contexte |
|-----------|------|-------------|----------|
| `CAnnoNicoContracts` | Module (protocol) | **OUI** | Contrat canonique pour intégration d'adaptateurs externes |
| `CAnnoNicoAdapter` | Protocol | **OUI** | Interface standard pour connecter des sources de données externes |
| `PucheroMemoryAdapter` | Adapter | **OUI** | Adaptateur mémoire générique, réutilisable dans tout projet Swift |
| `NicoAppAdapter` | Adapter | **OUI** | Adaptateur d'application, générique |
| `VideoSwapAdapter` | Adapter | **OUI** | Adaptateur d'échange vidéo, réutilisable |

**Potentiel**: Ce package est le seul package local canonique intégré au projet Xcode. Il pourrait servir de fondation pour tous les adaptateurs externes.

### 1.2 Runtime Layer

| Composant | Type | Réutilisable | Contexte |
|-----------|------|-------------|----------|
| `RuntimeSourceProtocol` | Protocol | **OUI** | Interface standard pour sources de données runtime |
| `RuntimeConnectionState` | Enum | **OUI** | Machine d'état de connexion, générique |
| `RuntimeEvent` | Struct | **OUI** | Modèle d'événement universel |
| `RuntimeGateway` | Class (singleton) | **OUI** | Point d'entrée unique pour le runtime |
| `RuntimeDataService` | Class | **OUI** | Service de données centralisé |
| `RuntimeHealth` | Struct | **OUI** | Métriques de santé, générique |
| `RuntimeMonitor` | Class | **OUI** | Moniteur runtime, réutilisable |
| `RuntimeModels` | Structs | **OUI** | Modèles de données génériques |

**Potentiel**: La couche Runtime est complète, bien structurée (8 couches), et pourrait être extraite en package SPM indépendant.

### 1.3 Bridge Layer

| Composant | Type | Réutilisable | Contexte |
|-----------|------|-------------|----------|
| `OpenCodeBridge` | Class (singleton) | **OUI** | Bridge OpenCode complet, interface standardisée |
| `BridgeRequest` | Struct | **OUI** | Modèle de requête générique |
| `BridgeResponse` | Struct | **OUI** | Modèle de réponse générique |

### 1.4 Knowledge Layer

| Composant | Type | Réutilisable | Contexte |
|-----------|------|-------------|----------|
| `KnowledgeProvider` | Protocol | **OUI** | Interface pour fournisseurs de connaissance |
| `KnowledgeGraph` | Engine | **OUI** | Moteur de graphe de connaissance générique |
| `KnowledgeObject` | Model | **OUI** | Objet de connaissance universel |
| `KnowledgeRelation` | Model | **OUI** | Relation de connaissance universelle |
| `NOVAKnowledgeKernel` | Class | **OUI** | Kernel de connaissance, singleton |

### 1.5 Twin Layer

| Composant | Type | Réutilisable | Contexte |
|-----------|------|-------------|----------|
| `TwinRegistry` | Registry | **OUI** | Registre de jumeaux numériques |
| `TwinIdentity` | Model | **OUI** | Identité de jumeau |
| `TwinLifecycle` | Engine | **OUI** | Cycle de vie des jumeaux |
| `TwinFactory` | Factory | **OUI** | Factory de jumeaux |
| `TwinBindings` | Model | **OUI** | Liens entre jumeaux |

### 1.6 Workspace Layer

| Composant | Type | Réutilisable | Contexte |
|-----------|------|-------------|----------|
| `WorkspaceGovernor` | Engine | **OUI** | Gouvernance d'espace de travail |
| `WorkspaceIndexer` | Engine | **OUI** | Indexation de workspace |
| `WorkspaceKnowledgeGraph` | Engine | **OUI** | Graphe de connaissance workspace |
| `WorkspaceMemory` | Engine | **OUI** | Mémoire workspace |
| `WorkspaceStatisticsService` | Service | **OUI** | Statistiques workspace |

### 1.7 Design System

| Composant | Type | Réutilisable | Contexte |
|-----------|------|-------------|----------|
| `SUPRAOSDesignSystem` | Design System | **OUI** | Système de design complet, réutilisable |
| `SUPRAOSFoundation` | Foundation | **OUI** | Foundation SwiftUI réutilisable |

---

## 2. COMPOSANTS OBSOLÈTES

| ID | Composant | Chemin | Raison | Remplaçant |
|----|-----------|--------|--------|------------|
| OBS-001 | `SUPRA_VIDEO_SWAP_V1_ARCHIVE` | ~/NOVA_OS/SUPRA_VIDEO_SWAP_V1_ARCHIVE | Archivé, remplacé par V3 | SUPRA_VIDEO_SWAP_V3 |
| OBS-002 | `COHERENCE_ENGINE` | ~/NOVA_OS/COHERENCE_ENGINE_V1 | Abandonné, non référencé | Aucun |
| OBS-003 | `SUPRA_BISECT` | ~/NOVA_OS/SUPRA_BISECT | Projet de débogage temporaire | SUPRA |
| OBS-004 | `SUPRA_TEMP` | ~/NOVA_OS/SUPRA_TEMP | Projet temporaire | SUPRA |
| OBS-005 | `SUPRA_RECOVERY` (4 variants) | ~/NOVA_OS/SUPRA_RECOVERY_* | Récupération, non maintenu | SUPRA |
| OBS-006 | `ContentView.swift` backups (4) | SUPRA/ backups dirs | Multiples sauvegardes obsolètes | ContentView.swift actuel |

---

## 3. COMPOSANTS DUPLIQUÉS

| ID | Original | Duplicat | Type | Action suggérée |
|----|----------|----------|------|----------------|
| DUP-001 | `SUPRA/Infrastructure/SUPRATerminalMegabusBridge.swift` | `_NON_RUNTIME_ARCHITECTURE/.../SUPRATerminalMegabusBridge.swift` | Bridge | Supprimer l'archive |
| DUP-002 | `SUPRA/ContentView.swift` | `_SUPRA_BACKUPS/.../ContentView.swift` | View | Nettoyer les backups |
| DUP-003 | `SUPRA/ContentView.swift` | `.mechanical_extract_backup_.../ContentView.swift` | View | Nettoyer les backups |
| DUP-004 | `SUPRA_VIDEO_SWAP_V3` | `SUPRA_VIDEO_SWAP_V1_ARCHIVE` | Project | Archiver/Supprimer V1 |

---

## 4. COMPOSANTS ISOLÉS

| ID | Composant | Chemin | Raison |
|----|-----------|--------|--------|
| ISO-001 | `SUPRA_AST_PLATFORM` (PKG-002) | SUPRA/SUPRA_AST_PLATFORM | Package SPM complet mais NON intégré au projet Xcode. Aucune dépendance depuis le projet principal. Orphelin. |
| ISO-002 | `SUPRA/Bridges/` | SUPRA/Bridges/ | Répertoire vide, prévu pour extraction mais jamais utilisé. |
| ISO-003 | `HELENE_APP` | ~/NOVA_OS/HELENE_APP_V1 | Projet standalone, aucune connexion avec SUPRA. |
| ISO-004 | `COHERENCE_ENGINE` | ~/NOVA_OS/COHERENCE_ENGINE_V1 | Abandonné, aucune référence. |
| ISO-005 | `NOVA_BUILD_SYSTEM` | ~/NOVA_OS/NOVA_BUILD_SYSTEM | Système de build standalone, aucune intégration Xcode. |

---

## 5. COMPOSANTS NON RÉFÉRENCÉS

| ID | Composant | Chemin | Notes |
|----|-----------|--------|-------|
| UNREF-001 | `phase1_extract_models.sh` | SUPRA/phase1_extract_models.sh | Script non référencé dans le code |
| UNREF-002 | `phase2_extract_bridges.sh` | SUPRA/phase2_extract_bridges.sh | Script non référencé dans le code |
| UNREF-003 | `phase3_extract_globals.sh` | SUPRA/phase3_extract_globals.sh | Script non référencé dans le code |
| UNREF-004 | `.analysis/` | SUPRA/.analysis/ | Répertoire d'analyse non référencé |
| UNREF-005 | `.analysis_20260723_022133/` | SUPRA/.analysis_20260723_022133/ | Ancienne analyse non référencée |
| UNREF-006 | `.overnight_audit/` | SUPRA/.overnight_audit/ | Audit non référencé |
| UNREF-007 | `_VERIFICATIONS/` | SUPRA/_VERIFICATIONS/ | Vérifications non référencées |
| UNREF-008 | `Artifacts/` | SUPRA/Artifacts/ | Artefacts de build non référencés |
| UNREF-009 | `.restore_build/` | SUPRA/.restore_build/ | Restauration de build non référencée |
| UNREF-010 | `agent_results/` | SUPRA/agent_results/ | Résultats d'agents non référencés |

---

## 6. RECOMMANDATIONS

### Haute priorité
1. **Extraire la couche Runtime** en package SPM réutilisable
2. **Déplacer les Adapters** dans CAnnoNicoIntegrationPackage (déjà fait)
3. **Supprimer les doublons** de SUPRATerminalMegabusBridge

### Moyenne priorité
4. **Nettoyer les backups** ContentView.swift (4 doublons)
5. **Intégrer SUPRA_AST_PLATFORM** ou le déclarer officiellement comme outil CLI standalone
6. **Supprimer les projets obsolètes** (BISECT, TEMP, RECOVERY)

### Basse priorité
7. **Archiver les analyses et audits** dans _ARCHIVES/
8. **Documenter l'interface OpenCodeBridge** comme API publique
9. **Standardiser les adaptateurs** via CAnnoNicoAdapter protocol

---

## 7. MÉTRIQUES DE RÉUTILISATION

| Métrique | Valeur |
|----------|--------|
| Composants réutilisables | ~35 modules/classes/structs/protocols |
| Composants obsolètes | 6 |
| Composants dupliqués | 4 |
| Composants isolés | 5 |
| Composants non référencés | 10 |
| Espace récupérable estimé | ~350 Mo (doublons + archives) |
| Taux de réutilisation potentiel | ~45% du code Swift peut être extrait en packages réutilisables |
