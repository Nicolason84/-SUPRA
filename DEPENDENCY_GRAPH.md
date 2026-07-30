# Dependency Graph

Generated: 2026-07-29T12:00:00Z

## Initialization Order

- `RuntimeDataService`
- `RuntimeMonitor`
- `MultiMemoryStore`
- `SUPRAIntelligenceEngine`
- `SUPRAMissionObserver`
- `MissionOpportunityEngine`
- `MissionEvolutionEngine`
- `MissionStore`
- `DecisionStore`
- `SUPRARuntimeEvents`
- `ControlTowerState`
- `SUPRARuntimeKernel`

## Binding Order

- `MissionStore->MissionEvolutionEngine`
- `MultiMemoryStore->MissionStore`
- `MultiMemoryStore->RuntimeMonitor`
- `SUPRAIntelligenceEngine->MultiMemoryStore`
- `SUPRAIntelligenceEngine->MissionStore`
- `SUPRAMissionObserver->SUPRAIntelligenceEngine`
- `SUPRAMissionObserver->MultiMemoryStore`
- `MissionOpportunityEngine->SUPRAMissionObserver`
- `MissionEvolutionEngine->MissionOpportunityEngine`

## Services

- `ControlTowerState` -> init: [`RuntimeDataService`, `RuntimeMonitor`] bind: []
- `DecisionStore` -> init: [] bind: []
- `MissionEvolutionEngine` -> init: [] bind: [`MissionOpportunityEngine`]
- `MissionOpportunityEngine` -> init: [] bind: [`SUPRAMissionObserver`]
- `MissionStore` -> init: [`MissionEvolutionEngine`] bind: [`MissionEvolutionEngine`]
- `MultiMemoryStore` -> init: [] bind: [`MissionStore`, `RuntimeMonitor`]
- `RuntimeDataService` -> init: [] bind: []
- `RuntimeMonitor` -> init: [`RuntimeDataService`] bind: []
- `SUPRAIntelligenceEngine` -> init: [] bind: [`MultiMemoryStore`, `MissionStore`]
- `SUPRAMissionObserver` -> init: [] bind: [`SUPRAIntelligenceEngine`, `MultiMemoryStore`]
- `SUPRARuntimeEvents` -> init: [] bind: []
- `SUPRARuntimeKernel` -> init: [] bind: []

## Edges

- `SUPRACompositionRoot` -> `ControlTowerState` (`create`)
- `SUPRACompositionRoot` -> `DecisionStore` (`create`)
- `SUPRACompositionRoot` -> `MissionEvolutionEngine` (`create`)
- `SUPRACompositionRoot` -> `MissionOpportunityEngine` (`create`)
- `SUPRACompositionRoot` -> `MissionStore` (`create`)
- `SUPRACompositionRoot` -> `MultiMemoryStore` (`create`)
- `SUPRACompositionRoot` -> `RuntimeDataService` (`create`)
- `SUPRACompositionRoot` -> `RuntimeMonitor` (`create`)
- `SUPRACompositionRoot` -> `SUPRAIntelligenceEngine` (`create`)
- `SUPRACompositionRoot` -> `SUPRAMissionObserver` (`create`)
- `SUPRACompositionRoot` -> `SUPRARuntimeEvents` (`create`)
- `SUPRACompositionRoot` -> `SUPRARuntimeKernel` (`create`)
- `ControlTowerState` -> `RuntimeDataService` (`init`)
- `ControlTowerState` -> `RuntimeMonitor` (`init`)
- `MissionEvolutionEngine` -> `MissionOpportunityEngine` (`bind`)
- `MissionOpportunityEngine` -> `SUPRAMissionObserver` (`bind`)
- `MissionStore` -> `MissionEvolutionEngine` (`init`)
- `MissionStore` -> `MissionEvolutionEngine` (`bind`)
- `MultiMemoryStore` -> `MissionStore` (`bind`)
- `MultiMemoryStore` -> `RuntimeMonitor` (`bind`)
- `RuntimeMonitor` -> `RuntimeDataService` (`init`)
- `SUPRAIntelligenceEngine` -> `MissionStore` (`bind`)
- `SUPRAIntelligenceEngine` -> `MultiMemoryStore` (`bind`)
- `SUPRAMissionObserver` -> `SUPRAIntelligenceEngine` (`bind`)
- `SUPRAMissionObserver` -> `MultiMemoryStore` (`bind`)

## Cycles

- None
