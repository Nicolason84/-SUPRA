import Foundation
import Combine

enum UniverseTimelineEventType: String, Codable, CaseIterable, Identifiable {
    case universeCreated = "universe_created"
    case twinCreated = "twin_created"
    case twinUpdated = "twin_updated"
    case twinSynced = "twin_synced"
    case twinArchived = "twin_archived"
    case knowledgeBuilt = "knowledge_built"
    case missionStarted = "mission_started"
    case missionCompleted = "mission_completed"
    case graphBuilt = "graph_built"
    case governanceScan = "governance_scan"
    case contextPrepared = "context_prepared"
    case bridgeConnected = "bridge_connected"
    case bridgeDisconnected = "bridge_disconnected"
    case systemEvent = "system_event"

    var id: String { rawValue }
}

struct UniverseTimelineEvent: Identifiable, Codable, Equatable {
    let id: String
    let type: UniverseTimelineEventType
    let title: String
    let description: String
    let space: SUPRAOSSpace?
    let objectId: String?
    let objectName: String?
    let importance: Double
    let timestamp: String

    static func == (lhs: UniverseTimelineEvent, rhs: UniverseTimelineEvent) -> Bool {
        lhs.id == rhs.id
    }
}

@MainActor
final class UniverseTimelineEngine: ObservableObject {
    @Published var events: [UniverseTimelineEvent] = []

    private let maxEvents = 500

    func record(_ event: UniverseTimelineEvent) {
        events.insert(event, at: 0)
        if events.count > maxEvents {
            events.removeLast()
        }
    }

    func recordUniverseCreated() {
        record(UniverseTimelineEvent(
            id: "evt_uni_\(UUID().uuidString.prefix(8))",
            type: .universeCreated,
            title: "Univers créé",
            description: "NOVA Universe Engine initialisé",
            space: .universe, objectId: nil, objectName: nil,
            importance: 1.0,
            timestamp: ISO8601DateFormatter().string(from: Date())
        ))
    }

    func recordTwinCreated(name: String, twinId: String) {
        record(UniverseTimelineEvent(
            id: "evt_twin_\(UUID().uuidString.prefix(8))",
            type: .twinCreated,
            title: "Twin créé: \(name)",
            description: "Nouveau Twin \(name)",
            space: .twins, objectId: twinId, objectName: name,
            importance: 0.8,
            timestamp: ISO8601DateFormatter().string(from: Date())
        ))
    }

    func recordKnowledgeBuilt(objectCount: Int) {
        record(UniverseTimelineEvent(
            id: "evt_know_\(UUID().uuidString.prefix(8))",
            type: .knowledgeBuilt,
            title: "Knowledge Graph construit",
            description: "\(objectCount) objets indexés",
            space: .knowledge, objectId: nil, objectName: nil,
            importance: 0.9,
            timestamp: ISO8601DateFormatter().string(from: Date())
        ))
    }

    func recordMissionStarted(name: String, missionId: String) {
        record(UniverseTimelineEvent(
            id: "evt_mis_\(UUID().uuidString.prefix(8))",
            type: .missionStarted,
            title: "Mission démarrée: \(name)",
            description: "Mission \(name)",
            space: .missions, objectId: missionId, objectName: name,
            importance: 0.7,
            timestamp: ISO8601DateFormatter().string(from: Date())
        ))
    }

    func recordBridgeConnected() {
        record(UniverseTimelineEvent(
            id: "evt_bridge_\(UUID().uuidString.prefix(8))",
            type: .bridgeConnected,
            title: "Bridge connecté",
            description: "OpenCode Bridge connecté au Runtime",
            space: .runtime, objectId: nil, objectName: nil,
            importance: 0.6,
            timestamp: ISO8601DateFormatter().string(from: Date())
        ))
    }

    func events(for space: SUPRAOSSpace) -> [UniverseTimelineEvent] {
        events.filter { $0.space == space }
    }

    func events(byType type: UniverseTimelineEventType) -> [UniverseTimelineEvent] {
        events.filter { $0.type == type }
    }

    func recent(_ count: Int) -> [UniverseTimelineEvent] {
        Array(events.prefix(count))
    }

    func summary() -> String {
        "Timeline: \(events.count) événements enregistrés"
    }

    func clear() {
        events = []
    }
}
