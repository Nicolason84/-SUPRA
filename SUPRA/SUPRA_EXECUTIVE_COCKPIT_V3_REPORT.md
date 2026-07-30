# SUPRA Executive Cockpit V3 — OpenCode Client Layer

## Mission
SUPRA_EXECUTIVE_COCKPIT_V3 — Évoluer le Cockpit d'un lecteur de fichiers Runtime vers un client natif du serveur OpenCode.

## Architecture

```
Cockpit (V1/V2 views)
    ↓ observe
RuntimeMonitor
    ↓ subscribe
OpenCodeClient (shared singleton — single entry point)
    ↓ wraps
RuntimeSourceProtocol
    ├── JSONRuntimeSource (MODE 1 — file polling, fully functional)
    └── OpenCodeRuntimeSource (MODE 2 — structural placeholder)
```

Le Cockpit ne connaît jamais la source réelle. Il dialogue uniquement avec `OpenCodeClient`.

## New Files (4)

| File | Lines | Purpose |
|------|-------|---------|
| `RuntimeSourceProtocol.swift` | ~20 | Protocol + RuntimeSourceMode enum (JSON/AUTO/OpenCode) |
| `RuntimeConnectionState.swift` | ~30 | 5 states: Disconnected, Connecting, Connected, Degraded, Offline |
| `RuntimeEventSource.swift` | ~165 | Two source implementations: JSONRuntimeSource (file polling) + OpenCodeRuntimeSource (placeholder) |
| `OpenCodeClient.swift` | ~100 | @MainActor ObservableObject singleton, single entry point, source abstraction, Combine subscriptions |

## Modified Files (3 + 1)

| File | Changes |
|------|---------|
| `RuntimeMonitor.swift` | Removed all file-watching code (~80 lines removed). Delegates to OpenCodeClient.shared. Subscribes to client.$events and client.$health. `start()` configures + starts client. |
| `SettingsView.swift` | Added "Runtime Mode" section with segmented picker (JSON/AUTO/OpenCode), connection state indicator, last event timestamp, last sync timestamp. Removed custom LabeledContent extension. |
| `SUPRAExecutiveCockpitView.swift` | Added `@StateObject private var client = OpenCodeClient.shared` + `.task { client.setMode(.json) }` to initialize the single entry point. |
| `RuntimeHealth.swift` | Added `connectionState: RuntimeConnectionState` field (to align with new architecture). |

## Architecture principles

### Cockpit = CLIENT
- `OpenCodeClient` est le point d'entrée unique
- Le Cockpit (1M vues via RuntimeMonitor) ne connaît jamais la source réelle
- Aucune logique métier dans le client — les sources sont interchangeables

### Runtime = ENGINE
- Strictement inchangé
- Tous les fichiers Runtime dans SUPRA/ et .opencode/ sont préservés
- Aucun agent, build, commit, package modifié

### Source abstraction
- `RuntimeSourceProtocol` définit l'interface source
- `JSONRuntimeSource` = héritage V2 (file watching, 3s polling)
- `OpenCodeRuntimeSource` = préparation native OpenCode
- Le Cockpit bascule entre sources via `client.setMode()`

### Pas de régression
- `RuntimeDataService` inchangé — V1/V2 views continuent de l'observer
- `JSONRuntimeSource` appelle `dataService.load()` lors des changements fichiers
- Tous les fichiers JSON chargés (8 fichiers, 4 modèles V2)

## Data Flow

```
[Runtime files] ──► JSONRuntimeSource ──► OpenCodeClient ──► RuntimeMonitor ──► Views
                     (poll + decode)       (@Published)      (@Published)
```

## Audit Final

| Critère | Statut |
|---------|--------|
| Cockpit indépendant | ✅ Cockpit dialogue uniquement avec OpenCodeClient |
| Runtime inchangé | ✅ Aucun fichier Runtime modifié |
| Compatibilité JSON conservée | ✅ JSONRuntimeSource = MODE 1 |
| Préparation native OpenCode | ✅ OpenCodeRuntimeSource = MODE 2 |
| Aucune logique métier dupliquée | ✅ Sources = pure I/O, Client = pure abstraction |
| Architecture extensible | ✅ Nouveau source = implémenter RuntimeSourceProtocol |

## Next Moves
1. V4: OpenCodeRuntimeSource réel (connexion WebSocket/HTTP au serveur OpenCode)
2. V4: Mode AUTO — détection auto de la source disponible
3. V4: Reconnect / fallback automatique entre sources
