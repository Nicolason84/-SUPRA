import Foundation
import Combine

enum TimelineEventType: String, Codable, CaseIterable, Identifiable {
    case objectCreated = "object_created"
    case objectModified = "object_modified"
    case missionStarted = "mission_started"
    case missionCompleted = "mission_completed"
    case decisionMade = "decision_made"
    case commitCreated = "commit_created"
    case reportGenerated = "report_generated"
    case freezeCreated = "freeze_created"
    case artifactProduced = "artifact_produced"
    case knowledgeUpdated = "knowledge_updated"
    case workspaceScanned = "workspace_scanned"
    case governanceIssue = "governance_issue"
    case contextPrepared = "context_prepared"

    var id: String { rawValue }
}

struct TimelineEvent: Identifiable, Codable, Equatable {
    let id: String
    let type: TimelineEventType
    let title: String
    let description: String
    let objectId: String?
    let objectName: String?
    let timestamp: String
    let source: String
    let importance: Double

    static func == (lhs: TimelineEvent, rhs: TimelineEvent) -> Bool {
        lhs.id == rhs.id
    }
}

@MainActor
final class ExecutiveTimeline: ObservableObject {
    @Published var events: [TimelineEvent] = []
    @Published var isLoaded = false

    func build(from kernel: NOVAKnowledgeKernel) {
        events = []
        let objects = kernel.allObjectsSnapshot()

        for obj in objects {
            if let created = obj.created {
                events.append(TimelineEvent(
                    id: "tl_created_\(obj.id)",
                    type: .objectCreated,
                    title: "\(obj.name) créé",
                    description: "\(obj.type.rawValue) dans \(obj.source.rawValue)",
                    objectId: obj.id,
                    objectName: obj.name,
                    timestamp: created,
                    source: obj.source.rawValue,
                    importance: obj.authority.map { Double($0.rank) / 100.0 } ?? 0.5
                ))
            }

            if let modified = obj.modified, modified != obj.created {
                events.append(TimelineEvent(
                    id: "tl_modified_\(obj.id)",
                    type: .objectModified,
                    title: "\(obj.name) modifié",
                    description: "Mise à jour dans \(obj.source.rawValue)",
                    objectId: obj.id,
                    objectName: obj.name,
                    timestamp: modified,
                    source: obj.source.rawValue,
                    importance: 0.3
                ))
            }
        }

        events.sort { e1, e2 in
            (e1.timestamp) > (e2.timestamp)
        }

        isLoaded = true
    }

    func events(forObjectId id: String) -> [TimelineEvent] {
        events.filter { $0.objectId == id }
    }

    func events(bySource source: String) -> [TimelineEvent] {
        events.filter { $0.source == source }
    }

    func events(byType type: TimelineEventType) -> [TimelineEvent] {
        events.filter { $0.type == type }
    }

    func recent(_ count: Int) -> [TimelineEvent] {
        Array(events.prefix(count))
    }

    func dateRange() -> (earliest: String?, latest: String?) {
        guard let first = events.last?.timestamp,
              let last = events.first?.timestamp
        else { return (nil, nil) }
        return (first, last)
    }

    func clear() {
        events = []
        isLoaded = false
    }
}
