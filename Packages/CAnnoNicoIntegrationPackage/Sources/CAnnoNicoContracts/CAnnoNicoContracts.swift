import Foundation

public enum CAnnoNicoIntegrationState: String, Codable, Sendable {
    case recovered
    case unavailable
    case partial
}

public struct CAnnoNicoSourceReference: Codable, Sendable, Hashable {
    public let id: String
    public let role: String
    public let path: String?
    public let state: CAnnoNicoIntegrationState
    public let inputs: [String]
    public let outputs: [String]
    public let capabilities: [String]

    public init(
        id: String,
        role: String,
        path: String?,
        state: CAnnoNicoIntegrationState,
        inputs: [String],
        outputs: [String],
        capabilities: [String]
    ) {
        self.id = id
        self.role = role
        self.path = path
        self.state = state
        self.inputs = inputs
        self.outputs = outputs
        self.capabilities = capabilities
    }
}

public protocol CAnnoNicoAdapter: Sendable {
    static var adapterID: String { get }
    func snapshot() -> CAnnoNicoSourceReference
}

public struct CAnnoNicoIntegrationSnapshot: Codable, Sendable {
    public let generatedAt: Date
    public let references: [CAnnoNicoSourceReference]

    public init(
        generatedAt: Date = Date(),
        references: [CAnnoNicoSourceReference]
    ) {
        self.generatedAt = generatedAt
        self.references = references
    }
}
