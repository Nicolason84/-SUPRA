import Foundation
import Combine

public protocol SUPRAPlugin: AnyObject {
    var pluginID: String { get }
    var pluginVersion: String { get }
    var pluginCapabilities: [String] { get }
    func onRegister() async
    func onUnregister() async
    func healthCheck() async -> Bool
}

public extension SUPRAPlugin {
    func onRegister() async {}
    func onUnregister() async {}
    func healthCheck() async -> Bool { true }
}

@MainActor
public final class SUPRAPluginRegistry: ObservableObject {
    public static let shared = SUPRAPluginRegistry()

    @Published public private(set) var plugins: [String: SUPRAPlugin] = [:]
    @Published public private(set) var pluginHealth: [String: Bool] = [:]

    private init() {}

    public func register(_ plugin: SUPRAPlugin) {
        let id = plugin.pluginID
        plugins[id] = plugin
        pluginHealth[id] = false
        Task { [weak plugin] in
            await plugin?.onRegister()
            let healthy = await plugin?.healthCheck() ?? false
            Task { @MainActor in
                self.pluginHealth[id] = healthy
            }
        }
    }

    public func unregister(_ id: String) {
        guard let plugin = plugins.removeValue(forKey: id) else { return }
        pluginHealth.removeValue(forKey: id)
        Task { await plugin.onUnregister() }
    }

    public func plugin(_ id: String) -> SUPRAPlugin? { plugins[id] }

    public func plugins(capability: String) -> [SUPRAPlugin] {
        plugins.values.filter { $0.pluginCapabilities.contains(capability) }
    }

    public func allHealthy() async -> [String: Bool] {
        var results: [String: Bool] = [:]
        for (id, plugin) in plugins {
            results[id] = await plugin.healthCheck()
        }
        pluginHealth = results
        return results
    }

    public func clear() {
        plugins.removeAll()
        pluginHealth.removeAll()
    }
}
