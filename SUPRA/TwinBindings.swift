import Foundation
import Combine

struct TwinBinding: Identifiable, Codable, Equatable {
    let id: String
    let twinId: String
    let sourceType: String
    let sourceId: String
    let sourceName: String
    let bindingType: String
    let strength: Double
    let bidirectional: Bool
    let createdAt: String
    let updatedAt: String?
    let metadata: [String: String]

    static func == (lhs: TwinBinding, rhs: TwinBinding) -> Bool {
        lhs.id == rhs.id
    }
}

@MainActor
final class TwinBindings: ObservableObject {
    @Published var bindings: [TwinBinding] = []

    func register(_ binding: TwinBinding) {
        bindings.append(binding)
    }

    func bindings(for twinId: String) -> [TwinBinding] {
        bindings.filter { $0.twinId == twinId }
    }

    func bindings(forSourceId sourceId: String) -> [TwinBinding] {
        bindings.filter { $0.sourceId == sourceId }
    }

    func resolveSource(twinId: String) -> [String] {
        bindings.filter { $0.twinId == twinId }.map(\.sourceId)
    }

    func resolveTwin(sourceId: String) -> [String] {
        bindings.filter { $0.sourceId == sourceId }.map(\.twinId)
    }

    func unregister(twinId: String) {
        bindings.removeAll { $0.twinId == twinId }
    }

    func summary() -> [String: Int] {
        Dictionary(grouping: bindings, by: { $0.bindingType }).mapValues(\.count)
    }

    static func createBinding(twinId: String, object: CAnnoNicoObject, strength: Double = 1.0) -> TwinBinding {
        TwinBinding(
            id: "bind_\(twinId)_\(object.id)",
            twinId: twinId,
            sourceType: object.source.rawValue,
            sourceId: object.id,
            sourceName: object.name,
            bindingType: "canonical",
            strength: strength,
            bidirectional: true,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: nil,
            metadata: ["type": object.type.rawValue, "source": object.source.rawValue]
        )
    }
}
