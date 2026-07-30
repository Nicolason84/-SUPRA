# INTELLIGENCE SOURCE MAP

## Sources disponibles

| Source | Mécanisme | Fréquence | Coût CPU | Données clés |
|---|---|---|---|---|
| **CAnnoNicoSnapshotStore** | Appel synchrone avec TTL 30s | On-demand | Light | snapshot, sourceCount, recoveredCount, cachedAt, references |
| **MultiMemoryStore** | Lecture fichier (init) + Combine CAnnoNico/Mission | Réactif + init | Medium | 5× MemorySourceInfo, globalHealth |
| **SUPRACommandCenterState** | 10× Combine sinks + scheduler 15s | Temps réel + 15s | Light | CommandCenterSnapshot (health, missions, resources, cannonico, runtime, multiMemory, actions) |
| **SUPRAResourceGovernor** | Timer 5s → host_statistics / task_info / sysctl | 5 secondes | Medium | cpuUsage, ramFraction, activeProcessCount, isHighLoad, isCritical |
| **MissionStore** | Énumération dossier + N lectures JSON | On-demand | Medium | missions, visibleMissions |
| **RuntimeMonitor** | Délégation OpenCodeClient Combine | Réactif | Light | health (isConnected, agentCount, activeMissionCount, lastSyncDate), events |
| **RuntimeGateway** | Async Task loop 5s (stub) + execute() | 5s (stub) + on-demand | Light | status, events, isConnected |
| **ControlTowerState** | Lecture CONTROL_TOWER_STATUS.json + Combine CAnnoNico | On-demand | Medium | TowerStatus (meta, processes, missions, builds, git, agents, health, warnings) |

## Observations

- **Seul poll actif**: SUPRAResourceGovernor (5s, 3 syscalls par tick)
- **Seules lectures fichier runtime**: MultiMemoryStore (init), MissionStore (on-demand), ControlTowerState (on-demand)
- **Couche agrégation**: SUPRACommandCenterState = 10 sinks Combine, reconstruction pure struct (coût CPU négligeable)
- **RuntimeMonitor** et **RuntimeGateway** dépendent de composants externes (OpenCodeClient, stub)
