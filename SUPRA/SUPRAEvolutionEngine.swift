import Foundation
import Combine

struct EvolutionProposal: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: EvolutionCategory
    let confidence: Double
    let isReversible: Bool
    let hasCriticalRisk: Bool
    let impact: String
    let rollbackCommand: String?
    let executeCommand: String?
    let proposedAt: Date
    var executedAt: Date?
    var status: EvolutionStatus = .pending
}

enum EvolutionCategory: String, Codable {
    case storage, performance, development, system, workflow
}

enum EvolutionStatus: String, Codable {
    case pending, approved, autoExecuted, executed, failed, rejected
}

@MainActor
final class SUPRAEvolutionEngine: ObservableObject {
    static let shared = SUPRAEvolutionEngine()

    @Published private(set) var proposals: [EvolutionProposal] = []
    @Published private(set) var autoExecutedCount = 0
    @Published private(set) var humanPendingCount = 0
    @Published private(set) var lastCycle: Date?
    @Published private(set) var isObserving = false

    private let governor = SUPRAResourceGovernor.shared
    private let envModel = SUPRAEnvironmentWorldModel.shared
    private let copilot = SUPRAOptimizationCopilot.shared
    private let hardwareTwin = SUPRAHardwareTwin.shared
    private let softwareTwin = SUPRASoftwareTwin.shared
    private let dataTwin = SUPRADataTwin.shared
    private let developerTwin = SUPRADeveloperTwin.shared
    private let scheduler = SUPRABackgroundScheduler.shared

    private var lastHash = 0
    private var executionHistory: [(EvolutionProposal, Bool)] = []

    private init() {}

    func observe() {
        isObserving = true
        scheduler.register(id: "evolution_engine", label: "Evolution Engine", interval: 120) { [weak self] in
            await self?.cycle()
        }
    }

    func stop() {
        isObserving = false
        scheduler.unregister(id: "evolution_engine")
    }

    func cycle() async {
        guard let state = envModel.state else { return }
        let h = hash(state: state)
        guard h != lastHash else { return }
        lastHash = h

        let detected = detectOpportunities(state: state)
        guard !detected.isEmpty else { return }

        for proposal in detected {
            proposals.append(proposal)

            if proposal.confidence > 0.85 && proposal.isReversible && !proposal.hasCriticalRisk {
                await execute(proposal)
                proposals[proposals.count - 1].status = .autoExecuted
                autoExecutedCount += 1
            } else {
                proposals[proposals.count - 1].status = .pending
                humanPendingCount += 1
            }
        }

        lastCycle = Date()
    }

    private func detectOpportunities(state: CompleteEnvironmentState) -> [EvolutionProposal] {
        var result: [EvolutionProposal] = []

        if let dt = state.data, dt.duplicateCount > 10 {
            result.append(EvolutionProposal(
                title: "Déduplication automatique", description: "\(dt.duplicateCount) fichiers en double détectés",
                category: .storage, confidence: 0.88, isReversible: true, hasCriticalRisk: false,
                impact: "Libère de l'espace disque", rollbackCommand: "mv ~/.Trash/* ~/restored/",
                executeCommand: "rm -rf ~/.Trash/*", proposedAt: Date()
            ))
        }

        if let dev = state.developer, dev.derivedDataSizeMB > 2000 {
            result.append(EvolutionProposal(
                title: "Nettoyage DerivedData", description: "\(dev.derivedDataSizeMB)MB dans DerivedData",
                category: .storage, confidence: 0.95, isReversible: true, hasCriticalRisk: false,
                impact: "Libère \(dev.derivedDataSizeMB)MB, accélère l'indexation",
                rollbackCommand: nil,
                executeCommand: "rm -rf ~/Library/Developer/Xcode/DerivedData/*",
                proposedAt: Date()
            ))
        }

        if let hw = state.hardware, hw.storageFreeGB < 20 {
            result.append(EvolutionProposal(
                title: "Nettoyage disque automatique", description: "\(Int(hw.storageFreeGB))GB libres",
                category: .storage, confidence: 0.90, isReversible: true, hasCriticalRisk: false,
                impact: "Libère de l'espace disque critique",
                rollbackCommand: nil,
                executeCommand: "rm -rf ~/.Trash/* ~/Library/Caches/* 2>/dev/null",
                proposedAt: Date()
            ))
        }

        if let dev = state.developer, dev.swiftPackageCount > 20, let repoCount = state.developer?.gitRepositoryCount, repoCount > 5 {
            let unused = max(0, dev.swiftPackageCount - repoCount * 3)
            if unused > 5 {
                result.append(EvolutionProposal(
                    title: "Nettoyage packages SPM inutilisés",
                    description: "~\(unused) packages SPM non référencés par des projets actifs",
                    category: .development, confidence: 0.72, isReversible: true, hasCriticalRisk: false,
                    impact: "Libère de l'espace, accélère la résolution SPM",
                    rollbackCommand: nil,
                    executeCommand: nil,
                    proposedAt: Date()
                ))
            }
        }

        if state.hardware != nil, let sw = state.software, sw.servicesCount > 80 {
            let heavy = governor.snapshot.activeProcessCount
            if heavy > 200 {
                result.append(EvolutionProposal(
                    title: "Réduction processus arrière-plan",
                    description: "\(heavy) processus actifs, \(sw.servicesCount) services",
                    category: .performance, confidence: 0.78, isReversible: true, hasCriticalRisk: true,
                    impact: "Libère CPU et RAM, améliore la réactivité",
                    rollbackCommand: nil,
                    executeCommand: nil,
                    proposedAt: Date()
                ))
            }
        }

        return result
    }

    func execute(_ proposal: EvolutionProposal) async {
        guard let cmd = proposal.executeCommand else {
            markExecuted(proposal, success: true)
            return
        }
        do {
            let p = Process()
            p.executableURL = URL(fileURLWithPath: "/bin/zsh")
            p.arguments = ["-c", cmd]
            let o = Pipe()
            p.standardOutput = o
            try p.run()
            p.waitUntilExit()
            markExecuted(proposal, success: p.terminationStatus == 0)
            if p.terminationStatus == 0 {
                autoExecutedCount += 1
            }
        } catch {
            markExecuted(proposal, success: false)
        }
    }

    func approveHuman(_ proposal: EvolutionProposal) {
        Task { await execute(proposal) }
    }

    func reject(_ proposal: EvolutionProposal) {
        guard let idx = proposals.firstIndex(where: { $0.id == proposal.id }) else { return }
        proposals[idx].status = .rejected
        humanPendingCount = max(0, humanPendingCount - 1)
    }

    private func markExecuted(_ proposal: EvolutionProposal, success: Bool) {
        guard let idx = proposals.firstIndex(where: { $0.id == proposal.id }) else { return }
        proposals[idx].executedAt = Date()
        proposals[idx].status = success ? .executed : .failed
        executionHistory.append((proposal, success))
    }

    var humanPending: [EvolutionProposal] {
        proposals.filter { $0.status == .pending && !($0.confidence > 0.85 && $0.isReversible && !$0.hasCriticalRisk) }
    }

    private func hash(state: CompleteEnvironmentState) -> Int {
        var h = Hasher()
        h.combine(state.data?.duplicateCount)
        h.combine(state.developer?.derivedDataSizeMB)
        h.combine(state.developer?.swiftPackageCount)
        h.combine(state.hardware?.storageFreeGB)
        h.combine(state.hardware?.cpuUsage)
        h.combine(state.software?.servicesCount)
        h.combine(governor.snapshot.activeProcessCount)
        return h.finalize()
    }
}
