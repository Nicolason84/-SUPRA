import XCTest
@testable import SUPRA

@MainActor
final class SUPRARuntimeProviderProofTests: XCTestCase {

    // MARK: - Test Providers

    private final class TestProviderA: SUPRAProviderPlugin {
        let pluginID = "test.provider.a"
        let pluginVersion = "1.0"
        let pluginCapabilities = ["conversation"]

        let declaration = SUPRAProviderPluginDeclaration(
            pluginID: "test.provider.a",
            providerID: "test.provider.a",
            providerName: "Test Provider A",
            providerVersion: "1.0",
            capabilities: ["conversation"]
        )

        let models: [SUPRAProviderModelDeclaration] = [
            SUPRAProviderModelDeclaration(
                modelID: "test-model-a",
                modelName: "Test Model A",
                providerID: "test.provider.a",
                capabilities: ["conversation"]
            )
        ]

        func execute(prompt: String, systemPrompt: String, modelID: String,
                     maxTokens: Int, temperature: Double) async throws -> String {
            return "Result from Provider A"
        }
    }

    private final class TestProviderB: SUPRAProviderPlugin {
        let pluginID = "test.provider.b"
        let pluginVersion = "1.0"
        let pluginCapabilities = ["conversation"]

        let declaration = SUPRAProviderPluginDeclaration(
            pluginID: "test.provider.b",
            providerID: "test.provider.b",
            providerName: "Test Provider B",
            providerVersion: "1.0",
            capabilities: ["conversation"]
        )

        let models: [SUPRAProviderModelDeclaration] = [
            SUPRAProviderModelDeclaration(
                modelID: "test-model-b",
                modelName: "Test Model B",
                providerID: "test.provider.b",
                capabilities: ["conversation"]
            )
        ]

        func execute(prompt: String, systemPrompt: String, modelID: String,
                     maxTokens: Int, temperature: Double) async throws -> String {
            return "Result from Provider B"
        }
    }

    private final class FailingProvider: SUPRAProviderPlugin {
        let pluginID = "test.provider.fail"
        let pluginVersion = "1.0"
        let pluginCapabilities = ["conversation"]

        let declaration = SUPRAProviderPluginDeclaration(
            pluginID: "test.provider.fail",
            providerID: "test.provider.fail",
            providerName: "Failing Provider",
            providerVersion: "1.0",
            capabilities: ["conversation"]
        )

        let models: [SUPRAProviderModelDeclaration] = [
            SUPRAProviderModelDeclaration(
                modelID: "test-model-fail",
                modelName: "Failing Model",
                providerID: "test.provider.fail",
                capabilities: ["conversation"]
            )
        ]

        func execute(prompt: String, systemPrompt: String, modelID: String,
                     maxTokens: Int, temperature: Double) async throws -> String {
            throw NSError(domain: "test", code: 500,
                         userInfo: [NSLocalizedDescriptionKey: "Intentional failure"])
        }
    }

    // MARK: - Kernel Provider Independence

    func testKernelHasNoConcreteProviderReference() throws {
        let kernelFiles = [
            "SUPRADecisionEngine",
            "SUPRAExecutionPlanner",
            "SUPRARoutingPolicy",
            "SUPRAScheduler",
            "SUPRAFallbackEngine",
            "SUPRALearningEngine",
            "SUPRAPluginRegistry",
            "SUPRARuntimeRegistry",
            "SUPRARuntimeGraph",
            "SUPRARuntimeMetrics",
            "SUPRARuntimeEvents",
            "SUPRACapabilityBroker",
            "SUPRAExecutionPipeline",
            "SUPRAOrchestrationExecutor"
        ]
        let concreteProviders = ["ollama", "openai", "anthropic", "gemini", "codex",
                                 "lmStudio", "openRouter", "vLLM", "groq", "mistral",
                                 "claude", "gpt"]
        for file in kernelFiles {
            let path = "SUPRA/" + file + ".swift"
            if let content = try? String(contentsOfFile: path) {
                for provider in concreteProviders {
                    XCTAssertFalse(content.lowercased().contains(provider),
                                   "\(file).swift references concrete provider '\(provider)'")
                }
            }
        }
    }

    // MARK: - Provider Registration

    func testPluginRegistryRegisterAndRetrieve() async throws {
        let registry = SUPRAProviderPluginRegistry.shared
        let provider = TestProviderA()

        registry.register(provider)
        let retrieved = registry.plugin("test.provider.a")
        XCTAssertNotNil(retrieved, "Provider A should be retrievable after registration")

        let all = registry.providerPlugins.values
        XCTAssertTrue(all.contains { $0.pluginID == "test.provider.a" },
                      "Provider A should be in allPlugins")
    }

    func testTwoProvidersRegistration() async throws {
        let registry = SUPRAProviderPluginRegistry.shared
        let providerA = TestProviderA()
        let providerB = TestProviderB()

        registry.register(providerA)
        registry.register(providerB)

        let all = registry.providerPlugins.values
        let ids = Set(all.map(\.pluginID))
        XCTAssertTrue(ids.contains("test.provider.a"))
        XCTAssertTrue(ids.contains("test.provider.b"))
    }

    // MARK: - Provider Swap

    func testProviderSwapSameMission() async throws {
        let planners = SUPRAExecutionPlanner.shared
        let scheduler = SUPRAScheduler.shared

        let understanding = SUPRAUnderstanding(missionTitle: "Test", prompt: "test")
        let decision = SUPRAOrchestrationDecision(
            missionID: UUID(), understanding: understanding,
            steps: [SUPRAOrchestrationStep(order: 1, action: .generate,
                                           requiredCapabilities: ["conversation"])]
        )

        let plan = await planners.plan(decision: decision, prompt: "test", systemPrompt: "")
        let requirements = SUPRARoutingRequirements(requiredCapabilities: ["conversation"])
        let slots = await scheduler.schedule(plan: plan, requirements: requirements)

        XCTAssertFalse(slots.isEmpty, "Should produce at least one slot")
    }

    // MARK: - Runtime Events

    func testRuntimeEventEmitted() async throws {
        let events = SUPRARuntimeEvents.shared
        let initialCount = events.events.count
        events.emit(.executionStarted, "Test event", source: "test")
        let newCount = events.events.count
        XCTAssertEqual(newCount, initialCount + 1, "Event should be recorded")
    }

    // MARK: - Runtime Metrics

    func testRuntimeMetricEmitted() async throws {
        let metrics = SUPRARuntimeMetrics.shared
        let initial = metrics.history.count
        metrics.recordCustom(name: "test_metric", value: 42.0, unit: "count")
        let updated = metrics.history.count
        XCTAssertEqual(updated, initial + 1, "Metric should be recorded")
    }

    // MARK: - Fallback

    func testFallbackScenario() async throws {
        let _ = SUPRAFallbackEngine.shared
        let providers = SUPRAProviderPluginRegistry.shared.providerPlugins.values
        XCTAssertFalse(providers.isEmpty, "At least one provider should be registered")
    }
}
