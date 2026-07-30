import Foundation
import Combine

@MainActor
final class SUPRACompositionRoot: ObservableObject {
    static let shared = SUPRACompositionRoot()

    let runtimeDataService: RuntimeDataService
    let missionStore: MissionStore
    let decisionStore: DecisionStore
    let runtimeMonitor: RuntimeMonitor
    let eventBus: SUPRARuntimeEvents
    let controlTowerState: ControlTowerState
    let runtimeKernel: SUPRARuntimeKernel
    let multiMemoryStore: MultiMemoryStore
    let intelligenceEngine: SUPRAIntelligenceEngine
    let missionObserver: SUPRAMissionObserver
    let missionOpportunityEngine: MissionOpportunityEngine
    let missionEvolutionEngine: MissionEvolutionEngine
    @Published private(set) var bootstrapEvents: [BootstrapActivationEvent] = []
    @Published private(set) var bootstrapState: BootstrapActivationState = .creatingServices

    private var hasActivatedRuntime = false

    private init() {
        let creationEvent = BootstrapActivationEvent(
            state: .creatingServices,
            timestamp: Date(),
            detail: "Bootstrap service creation started"
        )
        let runtimeDataService = RuntimeDataService.shared
        let runtimeMonitor = RuntimeMonitor(dataService: runtimeDataService)
        let multiMemoryStore = MultiMemoryStore.shared
        let intelligenceEngine = SUPRAIntelligenceEngine.shared
        let missionObserver = SUPRAMissionObserver.shared
        let missionOpportunityEngine = MissionOpportunityEngine.shared
        let missionEvolutionEngine = MissionEvolutionEngine.shared
        let missionStore = MissionStore(evolutionEngine: missionEvolutionEngine)

        self.runtimeDataService = runtimeDataService
        self.missionStore = missionStore
        self.decisionStore = DecisionStore()
        self.runtimeMonitor = runtimeMonitor
        self.eventBus = SUPRARuntimeEvents.shared
        self.controlTowerState = ControlTowerState(
            dataService: runtimeDataService,
            monitor: runtimeMonitor
        )
        self.runtimeKernel = SUPRARuntimeKernel.shared
        self.multiMemoryStore = multiMemoryStore
        self.intelligenceEngine = intelligenceEngine
        self.missionObserver = missionObserver
        self.missionOpportunityEngine = missionOpportunityEngine
        self.missionEvolutionEngine = missionEvolutionEngine

        self.bootstrapEvents = [creationEvent]
        self.bootstrapState = .creatingServices
        record(.bindingDependencies, detail: "Binding bootstrap dependencies")
        missionStore.bind(evolutionEngine: missionEvolutionEngine)
        multiMemoryStore.bind(missionStore: missionStore, runtimeMonitor: runtimeMonitor)
        intelligenceEngine.bind(multiMemory: multiMemoryStore, missionStore: missionStore)
        missionObserver.bind(intelligenceEngine: intelligenceEngine, multiMemory: multiMemoryStore)
        missionOpportunityEngine.bind(observer: missionObserver)
        missionEvolutionEngine.bind(opportunityEngine: missionOpportunityEngine)
        record(.publishingReferences, detail: "Canonical bootstrap references published")
    }

    func loadRuntime() {
        guard !hasActivatedRuntime else { return }
        hasActivatedRuntime = true
        record(.activatingRuntime, detail: "Runtime activation started")
        runtimeKernel.load()
        eventBus.emit(.modelLoaded,
                       "Runtime kernel initialized: \(runtimeKernel.state?.componentCount ?? 0) components",
                       source: "SUPRACompositionRoot")
        record(.runtimeReady, detail: "Runtime ready")
    }

    private func record(_ state: BootstrapActivationState, detail: String) {
        bootstrapState = state
        bootstrapEvents.append(BootstrapActivationEvent(state: state, timestamp: Date(), detail: detail))
    }
}
