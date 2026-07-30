import Foundation

struct AutoMissionQueue {
    let auto: [MissionProposal]
    let supervision: [MissionProposal]
    let human: [MissionProposal]

    var totalCount: Int { auto.count + supervision.count + human.count }
    var autoCount: Int { auto.count }
    var supervisionCount: Int { supervision.count }
    var humanCount: Int { human.count }

    var autonomyLevel: Double {
        guard totalCount > 0 else { return 0 }
        return Double(autoCount) / Double(totalCount)
    }

    init(from engine: SUPRAMissionProposalEngine) {
        auto = engine.autoQueue
        supervision = engine.supervisionQueue
        human = engine.humanQueue
    }
}
