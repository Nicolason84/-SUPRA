import Foundation

struct SUPRAFlowMarker: Codable, Sendable, Equatable {
    let schema: String

    let flowID: String
    let traceID: String
    let spanID: String
    let parentSpanID: String?

    let missionID: String
    let phaseID: String

    let nodeID: String
    let previousNodeID: String?
    let edgeID: String
    let sourceRef: String

    let authority: String
    let humanGate: String

    let createdAt: String
    let enteredAt: String
    let startedAt: String
    let finishedAt: String?

    let queueMs: Int
    let serviceMs: Int?
    let waitMs: Int

    let status: String
    let outcome: String?
    let retryCount: Int

    let evidenceRefs: [String]
    let memoryReturn: String?
    let canonReturn: String?

    enum CodingKeys: String, CodingKey {
        case schema
        case flowID = "flow_id"
        case traceID = "trace_id"
        case spanID = "span_id"
        case parentSpanID = "parent_span_id"
        case missionID = "mission_id"
        case phaseID = "phase_id"
        case nodeID = "node_id"
        case previousNodeID = "previous_node_id"
        case edgeID = "edge_id"
        case sourceRef = "source_ref"
        case authority
        case humanGate = "human_gate"
        case createdAt = "created_at"
        case enteredAt = "entered_at"
        case startedAt = "started_at"
        case finishedAt = "finished_at"
        case queueMs = "queue_ms"
        case serviceMs = "service_ms"
        case waitMs = "wait_ms"
        case status
        case outcome
        case retryCount = "retry_count"
        case evidenceRefs = "evidence_refs"
        case memoryReturn = "memory_return"
        case canonReturn = "canon_return"
    }

    func asJSONObject() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)

        guard let object = try JSONSerialization.jsonObject(with: data)
                as? [String: Any] else {
            throw NSError(
                domain: "SUPRA.FlowMarker",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Unable to serialize flow marker."
                ]
            )
        }

        return object
    }
}
