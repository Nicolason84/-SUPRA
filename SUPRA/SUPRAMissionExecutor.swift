import Foundation
import Combine

enum ExecutionStatus: String, Codable {
    case pending = "PENDING"
    case approved = "APPROVED"
    case executed = "EXECUTED"
    case failed = "FAILED"
    case rolledBack = "ROLLED_BACK"
    case rejected = "REJECTED"
}

struct ExecutionRecord: Identifiable {
    let id: UUID
    let proposalID: UUID
    let title: String
    let status: ExecutionStatus
    let executedAt: Date?
    let error: String?
    let rollbackAvailable: Bool
}

@MainActor
final class SUPRAMissionExecutor: ObservableObject {
    static let shared = SUPRAMissionExecutor()

    @Published private(set) var executionHistory: [ExecutionRecord] = []
    @Published private(set) var lastExecutionAt: Date?
    @Published private(set) var readyToExecute = true

    private let sovereignCategories: Set<DecisionCategory> = [.policy, .financial, .legal, .security, .authority]

    private init() {}

    func canAutoExecute(_ proposal: MissionProposal) -> Bool {
        guard proposal.verdict.authority == .autoExecute else { return false }
        guard !sovereignCategories.contains(proposal.category) else { return false }
        guard proposal.isReversible else { return false }
        guard proposal.verdict.rollbackAvailable else { return false }
        guard proposal.evidence.permissionsAvailable else { return false }
        return true
    }

    func execute(_ proposal: MissionProposal) -> ExecutionRecord {
        guard canAutoExecute(proposal) else {
            let record = ExecutionRecord(
                id: UUID(), proposalID: proposal.id,
                title: proposal.title, status: .rejected,
                executedAt: nil, error: "Cannot execute: authorization check failed",
                rollbackAvailable: proposal.isReversible
            )
            executionHistory.append(record)
            return record
        }

        let record = ExecutionRecord(
            id: UUID(), proposalID: proposal.id,
            title: proposal.title, status: .approved,
            executedAt: Date(), error: nil,
            rollbackAvailable: proposal.isReversible
        )
        executionHistory.append(record)
        lastExecutionAt = Date()
        return record
    }

    func markExecuted(_ id: UUID) {
        guard let idx = executionHistory.firstIndex(where: { $0.id == id }) else { return }
        executionHistory[idx] = ExecutionRecord(
            id: id, proposalID: executionHistory[idx].proposalID,
            title: executionHistory[idx].title, status: .executed,
            executedAt: Date(), error: nil,
            rollbackAvailable: executionHistory[idx].rollbackAvailable
        )
    }

    func markFailed(_ id: UUID, error: String) {
        guard let idx = executionHistory.firstIndex(where: { $0.id == id }) else { return }
        executionHistory[idx] = ExecutionRecord(
            id: id, proposalID: executionHistory[idx].proposalID,
            title: executionHistory[idx].title, status: .failed,
            executedAt: Date(), error: error,
            rollbackAvailable: executionHistory[idx].rollbackAvailable
        )
    }

    func rollback(_ id: UUID) {
        guard let idx = executionHistory.firstIndex(where: { $0.id == id }) else { return }
        guard executionHistory[idx].rollbackAvailable else { return }
        executionHistory[idx] = ExecutionRecord(
            id: id, proposalID: executionHistory[idx].proposalID,
            title: executionHistory[idx].title, status: .rolledBack,
            executedAt: executionHistory[idx].executedAt, error: "Rolled back",
            rollbackAvailable: false
        )
    }

    func clearHistory() {
        executionHistory = []
        lastExecutionAt = nil
    }

    var autoExecutedCount: Int {
        executionHistory.filter { $0.status == .executed }.count
    }

    var pendingCount: Int {
        executionHistory.filter { $0.status == .pending || $0.status == .approved }.count
    }

    func executeAsync(_ proposal: MissionProposal) async -> ExecutionRecord {
        guard canAutoExecute(proposal) else {
            let record = ExecutionRecord(
                id: UUID(), proposalID: proposal.id,
                title: proposal.title, status: .rejected,
                executedAt: nil, error: "Cannot execute: authorization check failed",
                rollbackAvailable: proposal.isReversible
            )
            executionHistory.append(record)
            return record
        }

        let recordId = UUID()
        let pending = ExecutionRecord(
            id: recordId, proposalID: proposal.id,
            title: proposal.title, status: .pending,
            executedAt: nil, error: nil,
            rollbackAvailable: proposal.isReversible
        )
        executionHistory.append(pending)

        guard await SUPRAExecutionPipeline.shared.run(
            missionTitle: proposal.title,
            prompt: proposal.reason,
            systemPrompt: ""
        ) != nil else {
            let err = SUPRAExecutionPipeline.shared.lastError ?? "Pipeline execution failed"
            markFailed(recordId, error: err)
            return executionHistory.last { $0.id == recordId } ?? pending
        }

        let record = ExecutionRecord(
            id: recordId, proposalID: proposal.id,
            title: proposal.title, status: .executed,
            executedAt: Date(), error: nil,
            rollbackAvailable: proposal.isReversible
        )
        if let idx = executionHistory.firstIndex(where: { $0.id == recordId }) {
            executionHistory[idx] = record
        }
        lastExecutionAt = Date()
        return record
    }
}
