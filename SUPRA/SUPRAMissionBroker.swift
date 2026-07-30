import Foundation
import Combine

public enum SUPRAExecutionMode: String, Codable, Sendable {
    case automatic
    case supervised
    case humanRequired
}

public struct SUPRAExecutionPlan: Codable, Sendable {
    public let missionID: UUID
    public let title: String
    public let prompt: String
    public let systemPrompt: String
    public let capabilities: [SUPRACapability]
    public let preferredProvider: SUPRAProviderType?
    public let preferredModel: String?
    public let mode: SUPRAExecutionMode
    public let maxTokens: Int
    public let temperature: Double

    public init(missionID: UUID, title: String, prompt: String, systemPrompt: String = "",
                capabilities: [SUPRACapability], preferredProvider: SUPRAProviderType? = nil,
                preferredModel: String? = nil, mode: SUPRAExecutionMode = .automatic,
                maxTokens: Int = 2048, temperature: Double = 0.7) {
        self.missionID = missionID
        self.title = title
        self.prompt = prompt
        self.systemPrompt = systemPrompt
        self.capabilities = capabilities
        self.preferredProvider = preferredProvider
        self.preferredModel = preferredModel
        self.mode = mode
        self.maxTokens = maxTokens
        self.temperature = temperature
    }
}

@MainActor
public final class SUPRAMissionBroker: ObservableObject {
    public static let shared = SUPRAMissionBroker()

    @Published public private(set) var lastPlan: SUPRAExecutionPlan?
    @Published public private(set) var isRouting = false

    private let capabilityBroker = SUPRACapabilityBroker.shared

    private init() {}

    public func route(missionTitle: String, prompt: String, systemPrompt: String = "",
                      preferredProvider: SUPRAProviderType? = nil) async -> SUPRAExecutionPlan {
        isRouting = true
        defer { isRouting = false }

        let capabilities = capabilityBroker.resolveCapabilities(for: prompt)

        let plan = SUPRAExecutionPlan(
            missionID: UUID(),
            title: missionTitle,
            prompt: prompt,
            systemPrompt: systemPrompt,
            capabilities: capabilities,
            preferredProvider: preferredProvider,
            preferredModel: nil,
            mode: determineMode(for: capabilities),
            maxTokens: 2048,
            temperature: 0.7
        )

        lastPlan = plan
        return plan
    }

    private func determineMode(for capabilities: [SUPRACapability]) -> SUPRAExecutionMode {
        if capabilities.contains(.coding) || capabilities.contains(.planning) {
            return .supervised
        }
        return .automatic
    }
}
