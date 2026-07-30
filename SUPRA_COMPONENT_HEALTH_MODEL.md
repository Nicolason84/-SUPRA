# SUPRA COMPONENT HEALTH MODEL V1

## Modèle de Santé et d'Observabilité des Composants Permanents

| Propriété | Valeur |
|-----------|--------|
| **Statut** | CORE — Modèle de santé permanent |
| **Version** | SUPRA_COMPONENT_HEALTH_MODEL_V1 |
| **Date** | 2026-07-29 |
| **Principe** | Tout composant est observable. Tout composant a une santé connue. |
| **Exécution** | Runtime Health Checks via Control Tower |

---

## 1. Principes du Health Model

| Principe | Description |
|----------|-------------|
| H-01 | Tout composant permanent expose son état de santé |
| H-02 | La santé est vérifiable à fréquence définie |
| H-03 | Un composant CRITICAL en échec bloque le système |
| H-04 | Les métriques de santé sont historisées (append-only) |
| H-05 | Tout changement d'état de santé est un événement tracé |
| H-06 | La santé est observable depuis le Runtime Dashboard |

---

## 2. États de Santé

```
HEALTHY ──▶ DEGRADED ──▶ CRITICAL ──▶ DOWN
  ▲            │            │            │
  └────────────┴────────────┴────────────┘
                   (recovery)
```

| État | Description | Action Runtime |
|------|-------------|----------------|
| `HEALTHY` | Fonctionne normalement | Aucune |
| `DEGRADED` | Fonctionne avec limitations | Alerte, surveillance renforcée |
| `CRITICAL` | Fonctionnalité réduite, risque de panne | Fallback activé, notification Executive |
| `DOWN` | Composant indisponible | Blocage des flux dépendants, mode dégradé |
| `UNKNOWN` | Santé non déterminée | Investigation immédiate |

---

## 3. Métriques de Santé par Type de Composant

### 3.1 Components Exécutables (Swift)

| Métrique | Type | Source | Critical |
|----------|------|--------|----------|
| `uptime_seconds` | Gauge | RuntimeMonitor | OUI |
| `last_heartbeat` | Timestamp | EventBus | OUI |
| `memory_mb` | Gauge | RuntimeMetrics | NON |
| `cpu_usage` | Gauge | RuntimeMetrics | NON |
| `error_rate` | Counter | RuntimeLogger | OUI |
| `response_time_ms` | Histogram | RuntimeMetrics | NON |
| `active_connections` | Gauge | RuntimeMonitor | NON |

### 3.2 Components Registry (JSON)

| Métrique | Type | Source | Critical |
|----------|------|--------|----------|
| `file_freshness_seconds` | Gauge | RuntimeDataService | OUI |
| `schema_valid` | Boolean | RegistrySystem | OUI |
| `entry_count` | Gauge | RegistrySystem | NON |
| `validation_success_rate` | Ratio | RegistrySystem | OUI |

### 3.3 Components Provider (LLM)

| Métrique | Type | Source | Critical |
|----------|------|--------|----------|
| `provider_uptime` | Ratio | ProviderHealth | OUI |
| `request_latency_ms` | Histogram | ProviderMetrics | OUI |
| `success_rate` | Ratio | ProviderMetrics | OUI |
| `fallback_rate` | Ratio | RouterMetrics | NON |
| `rate_limit_remaining` | Gauge | ProviderClient | NON |

### 3.4 Components Agent (OpenCode)

| Métrique | Type | Source | Critical |
|----------|------|--------|----------|
| `agent_available` | Boolean | AgentRegistry | OUI |
| `last_task_duration_ms` | Gauge | ExecutionTrace | NON |
| `task_success_rate` | Ratio | ExecutionTrace | OUI |
| `tasks_completed` | Counter | ExecutionTrace | NON |

---

## 4. Health Check Protocol

```
┌──────────────┐     ┌────────────────┐     ┌──────────────┐
│  Component   │────▶│  Health Probe  │────▶│ Control Tower│
│  (any)       │     │  (30s-5min)    │     │ (aggregator) │
└──────────────┘     └────────────────┘     └──────┬───────┘
                                                   │
                                          ┌────────┴────────┐
                                          │                  │
                                          ▼                  ▼
                                   ┌────────────┐   ┌──────────────┐
                                   │  Dashboard  │   │  Event Bus   │
                                   │  (display)  │   │  (alerting)  │
                                   └────────────┘   └──────────────┘
```

### 4.1 Health Check Frequencies

| Type de Composant | Fréquence | Méthode |
|-------------------|-----------|---------|
| Exécutable (Swift) | 30s | Heartbeat + Metric push |
| Registry (JSON) | 60s | File read + Schema validation |
| Provider (LLM) | 30s | API health endpoint |
| Agent (OpenCode) | 60s | Availability check |
| Spec (Document) | 24h | Manual review gate |
| Planned | N/A | Not checked |

---

## 5. Observabilité

### 5.1 Logging Levels

| Level | Usage | Composants |
|-------|-------|------------|
| `ERROR` | Erreur bloquante | Tous les composants exécutables |
| `WARN` | Dégradation non bloquante | Runtime, Providers, Router |
| `INFO` | Événement normal | Tous les composants |
| `DEBUG` | Diagnostic détaillé | Développement uniquement |
| `TRACE` | Trace d'exécution | Pipeline, Workflow |

### 5.2 Events

Chaque composant émet des événements tracés via le EventBus. Les événements sont :

- **Lifecycle**: `boot`, `shutdown`, `state_change`
- **Health**: `health_healthy`, `health_degraded`, `health_critical`, `health_down`, `health_recovered`
- **Performance**: `latency_breach`, `error_threshold_exceeded`
- **Business**: `mission_completed`, `mission_failed`, `decision_taken`

### 5.3 Traces

Les traces d'exécution sont stockées dans :

- `runtime_trace.json` — État du runtime
- `delegation_trace.json` — Délégations agents
- `runtime_metrics.json` — Métriques agrégées
- `execution_trace.json` — Traces d'exécution

---

## 6. Dashboard Mapping

| Dashboard L6 | Composable surveillé | Métriques clés |
|-------------|---------------------|----------------|
| Executive Dashboard | L5.EXECUTIVE_KERNEL, L4.ROUTER, L1.MODEL_REGISTRY | Success rate, active missions, provider status |
| Runtime View | L4.RUNTIME_KERNEL, L4.EXECUTIVE_RUNTIME | Uptime, pipeline state, worker pool |
| Mission Center | L4.MISSION_KERNEL, L5.MISSION_BROKER | Mission count, success rate, duration |
| Control Center | L4.CONTROL_TOWER, L4.EVENT_BUS | Alert count, system health |
| Evidence Explorer | L2.EVIDENCE_ENGINE | Evidence chain completeness |
| Settings View | All components | Configuration health |

---

## 7. Alerting Rules

| Règle | Condition | Action | Priorité |
|-------|-----------|--------|----------|
| A-01 | Component.health == DOWN && component.critical == true | BLOCK pipeline, notify Executive | P0 |
| A-02 | Provider.health == DOWN | Activer fallback, alerte | P0 |
| A-03 | Component.health == CRITICAL > 5min | Escalade vers Executive | P1 |
| A-04 | Error rate > 10% sur 5min | Investigation automatique | P1 |
| A-05 | Registry file freshness > 120s | Refresh registry | P2 |
| A-06 | Success rate < 80% sur 1h | Rapport d'analyse | P2 |

---

## 8. Implémentation Runtime

Le Health Model est implémenté par :

- **RuntimeMonitor** (`RuntimeMonitor.swift`) — Collecte les métriques
- **ControlTowerState** (`ControlTowerState.swift`) — Agrège et alerte
- **SUPRARuntimeMetrics** (`SUPRARuntimeMetrics.swift`) — Stocke les métriques
- **SUPRARuntimeLogger** (`SUPRARuntimeLogger.swift`) — Log events
- **SUPRARuntimeEvents** (`SUPRARuntimeEvents.swift`) — Event bus

---

*Document créé le 2026-07-29 dans le cadre de la mission SUPRA ULTIMATE CONSOLIDATED PHASE 5. Modèle de santé et d'observabilité. Ce document est un standard architectural, pas un document conceptuel.*
