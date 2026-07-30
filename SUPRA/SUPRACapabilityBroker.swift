import Foundation
import Combine

@MainActor
public final class SUPRACapabilityBroker: ObservableObject {
    public static let shared = SUPRACapabilityBroker()

    @Published public private(set) var registeredCapabilities: Set<SUPRACapability> = []

    private init() {}

    public func resolveCapabilities(for prompt: String) -> [SUPRACapability] {
        let lower = prompt.lowercased()
        var caps: [SUPRACapability] = [.reasoning]

        if lower.contains("code") || lower.contains("program") || lower.contains("swift")
            || lower.contains("function") || lower.contains("implement") {
            caps.append(.coding)
        }
        if lower.contains("image") || lower.contains("vision") || lower.contains("see")
            || lower.contains("visual") {
            caps.append(.vision)
        }
        if lower.contains("search") || lower.contains("find") || lower.contains("lookup") {
            caps.append(.search)
        }
        if lower.contains("remember") || lower.contains("memory") || lower.contains("recall") {
            caps.append(.memory)
        }
        if lower.contains("plan") || lower.contains("strategy") || lower.contains("schedule") {
            caps.append(.planning)
        }
        if lower.contains("stream") || lower.contains("real-time") || lower.contains("live") {
            caps.append(.streaming)
        }
        if lower.contains("embed") || lower.contains("vector") || lower.contains("semantic") {
            caps.append(.embeddings)
        }
        if lower.contains("chat") || lower.contains("talk") || lower.contains("hello")
            || lower.contains("bonjour") || lower.contains("hi") {
            caps.append(.conversation)
        }
        caps.append(.analysis)

        return Array(Set(caps))
    }

    public func registerCapabilities(_ caps: [SUPRACapability]) {
        for cap in caps { registeredCapabilities.insert(cap) }
    }

    public func canFulfill(_ required: [SUPRACapability]) -> Bool {
        for cap in required {
            guard registeredCapabilities.contains(cap) else { return false }
        }
        return true
    }

    public func closestModel(for capabilities: [SUPRACapability]) -> SUPRAModelEntry? {
        let registry = SUPRAModelRegistry.shared
        for cap in capabilities {
            if let match = registry.models(for: cap).first { return match }
        }
        return registry.find(id: "deepseek-r1")
    }
}
