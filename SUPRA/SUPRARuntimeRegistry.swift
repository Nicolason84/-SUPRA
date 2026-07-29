import Foundation
import Combine

@MainActor
public final class SUPRARuntimeRegistry: ObservableObject {
    public static let shared = SUPRARuntimeRegistry()

    @Published public private(set) var allPlugins: [String: SUPRAPlugin] = [:]
    @Published public private(set) var allProviderPlugins: [String: SUPRAProviderPlugin] = [:]
    @Published public private(set) var allPluginDeclarations: [SUPRAProviderPluginDeclaration] = []
    @Published public private(set) var allModelDeclarations: [SUPRAProviderModelDeclaration] = []
    @Published public private(set) var runtimeVersion: String = "—"
    @Published public private(set) var isInitialized = false

    private let pluginRegistry = SUPRAPluginRegistry.shared
    private let providerPluginRegistry = SUPRAProviderPluginRegistry.shared
    private let events = SUPRARuntimeEvents.shared

    private init() {}

    private static func readCanonicalVersion() -> String {
        let path = "\(SUPRAEnvironmentResolver.shared.projectRoot)/version.json"
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let version = obj["supra_state_version"] as? String
        else { return "—" }
        return version
    }

    public func initialize() async {
        guard !isInitialized else { return }

        runtimeVersion = Self.readCanonicalVersion()

        allPlugins = pluginRegistry.plugins
        allProviderPlugins = providerPluginRegistry.providerPlugins
        allPluginDeclarations = providerPluginRegistry.declarations

        allModelDeclarations = providerPluginRegistry.providerPlugins.values
            .flatMap(\.models)

        isInitialized = true
        events.emit(.modelLoaded, "Runtime registry initialized: \(allPlugins.count) plugins, \(allModelDeclarations.count) models",
                     source: "SUPRARuntimeRegistry")
    }

    public func refresh() {
        allPlugins = pluginRegistry.plugins
        allProviderPlugins = providerPluginRegistry.providerPlugins
        allPluginDeclarations = providerPluginRegistry.declarations
        allModelDeclarations = providerPluginRegistry.providerPlugins.values
            .flatMap(\.models)
    }

    public func providerPlugin(for providerID: String) -> SUPRAProviderPlugin? {
        allProviderPlugins[providerID]
    }

    public func plugins(capability: String) -> [SUPRAProviderPlugin] {
        allProviderPlugins.values.filter { $0.declaration.capabilities.contains(capability) }
    }

    public func models(capability: String) -> [SUPRAProviderModelDeclaration] {
        allModelDeclarations.filter { $0.capabilities.contains(capability) }
    }

    public func models(providerID: String) -> [SUPRAProviderModelDeclaration] {
        allModelDeclarations.filter { $0.providerID == providerID }
    }

    public func summary() -> String {
        var s = "Runtime Registry v\(runtimeVersion)\n"
        s += "Plugins: \(allPlugins.count)\n"
        s += "Provider Plugins: \(allProviderPlugins.count)\n"
        s += "Plugin Declarations: \(allPluginDeclarations.count)\n"
        s += "Model Declarations: \(allModelDeclarations.count)\n"
        s += "\nProviders:\n"
        for decl in allPluginDeclarations {
            s += "  \(decl.providerName) (v\(decl.providerVersion)) - \(decl.capabilities.joined(separator: ", "))\n"
        }
        s += "\nModels:\n"
        for model in allModelDeclarations {
            s += "  \(model.modelName) [\(model.providerID)] - \(model.capabilities.joined(separator: ", "))\n"
        }
        return s
    }
}
