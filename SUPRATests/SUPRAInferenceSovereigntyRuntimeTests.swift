import XCTest
@testable import SUPRA

@MainActor
final class SUPRAInferenceSovereigntyRuntimeTests: XCTestCase {
    override func tearDown() async throws {
        let registry = SUPRAProviderRegistry.shared
        registry.unregister(.ollama)
        registry.unregister(.openAI)
        registry.unregister(.lmStudio)
    }

    func testCanonicalRuntimeExecutesWithLocalProvider() async throws {
        let provider = SovereigntyTestProvider(
            type: .ollama,
            responseContent: "local execution complete"
        )
        SUPRAProviderRegistry.shared.register(provider)

        let response = try await InferenceSovereigntyRuntime.shared.execute(
            task: SUPRAInferenceTask(
                missionTitle: "Local Sovereignty Proof",
                prompt: "Analyze the repository state and prepare the next executive mission.",
                category: .repositoryAnalysis,
                requiredCapabilities: [.analysis, .reasoning],
                maxTokens: 2048,
                confidence: 0.9,
                evidenceQuality: 0.9
            )
        )

        XCTAssertEqual(response.provider, .ollama)
        XCTAssertEqual(response.content, "local execution complete")
        XCTAssertEqual(InferenceSovereigntyRuntime.shared.lastDecision?.selectedProvider, .ollama)
        XCTAssertEqual(InferenceSovereigntyRuntime.shared.lastDecision?.executionStrategy, "local_first")
    }

    func testSameTaskRunsWithDifferentConfiguredProvidersWithoutCodeChanges() async throws {
        let task = SUPRAInferenceTask(
            missionTitle: "Interchangeable Provider Proof",
            prompt: "Reason about the current mission and summarize the next action.",
            category: .reasoning,
            requiredCapabilities: [.reasoning, .analysis],
            maxTokens: 2048,
            confidence: 0.85,
            evidenceQuality: 0.8
        )

        let localProvider = SovereigntyTestProvider(
            type: .ollama,
            responseContent: "local provider selected"
        )
        SUPRAProviderRegistry.shared.register(localProvider)
        let localResponse = try await InferenceSovereigntyRuntime.shared.execute(task: task)
        XCTAssertEqual(localResponse.provider, .ollama)

        SUPRAProviderRegistry.shared.unregister(.ollama)

        let cloudProvider = SovereigntyTestProvider(
            type: .openAI,
            responseContent: "cloud provider selected"
        )
        SUPRAProviderRegistry.shared.register(cloudProvider)
        let cloudResponse = try await InferenceSovereigntyRuntime.shared.execute(task: task)
        XCTAssertEqual(cloudResponse.provider, .openAI)
        XCTAssertEqual(cloudResponse.content, "cloud provider selected")
    }
}

private final class SovereigntyTestProvider: SUPRAProvider {
    let type: SUPRAProviderType
    let configuration: SUPRAProviderConfiguration
    private let responseContent: String

    init(type: SUPRAProviderType, responseContent: String) {
        self.type = type
        self.responseContent = responseContent
        self.configuration = SUPRAProviderConfiguration(
            type: type,
            baseURL: "http://test.local",
            isEnabled: true,
            priority: 0,
            timeoutSeconds: 5
        )
    }

    var isAvailable: Bool { true }
    var supportedCapabilities: [SUPRACapability] { SUPRACapability.allCases }

    func execute(request: SUPRAExecutionRequest) async throws -> SUPRAProviderResponse {
        SUPRAProviderResponse(
            requestID: request.id,
            content: responseContent,
            model: "\(type.rawValue)-test-model",
            provider: type,
            durationMs: 1,
            tokensIn: request.prompt.count,
            tokensOut: responseContent.count,
            finishedNormally: true,
            error: nil
        )
    }

    func checkHealth() async -> Bool { true }
}
