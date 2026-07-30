import Foundation

public struct PlatformManifest: Codable, Sendable {
    public let registry: RegistryMeta
    public let metadata: Metadata
    public let components: [PlatformComponent]

    public struct RegistryMeta: Codable, Sendable {
        public let id: String
        public let name: String
        public let version: String
        public let date: String
        public let authority: String
        public let canonicalModel: String
        public let totalComponents: Int
        public let description: String

        enum CodingKeys: String, CodingKey {
            case id, name, version, date, authority, description
            case canonicalModel = "canonical_model"
            case totalComponents = "total_components"
        }
    }

    public struct Metadata: Codable, Sendable {
        public let layers: [String: LayerInfo]
    }

    public struct LayerInfo: Codable, Sendable {
        public let name: String
        public let count: Int
        public let color: String
    }

    public static func load(from url: URL) throws -> PlatformManifest {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(PlatformManifest.self, from: data)
    }

    public static func defaultRegistryURL() -> URL {
        URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent("SUPRA_EXECUTIVE_PLATFORM_REGISTRY.json")
    }
}

public struct PlatformComponent: Codable, Sendable, Identifiable {
    public let id: String
    public let name: String
    public let layer: String
    public let mission: String
    public let responsibilities: [String]
    public let domain: String
    public let owner: String
    public let version: String
    public let maturity: String
    public let state: String
    public let inputs: [ComponentIO]
    public let outputs: [ComponentIO]
    public let contractsConsumed: [String]
    public let contractsPublished: [String]
    public let dependencies: [String]
    public let dependents: [String]
    public let invariants: [String]
    public let events: [String]
    public let api: [ComponentAPI]
    public let tests: [String]
    public let adrs: [String]
    public let health: ComponentHealthDef
    public let observability: ComponentObservability
    public let relatedComponents: [String]
    public let runtime: ComponentRuntimeDef
    public let lifecycle: ComponentLifecycle
    public let implementation: ComponentImplementation

    enum CodingKeys: String, CodingKey {
        case id, name, layer, mission, responsibilities, domain, owner
        case version, maturity, state, inputs, outputs, events, api
        case tests, adrs, health, observability, runtime, lifecycle, implementation
        case contractsConsumed = "contracts_consumed"
        case contractsPublished = "contracts_published"
        case dependencies, dependents, invariants
        case relatedComponents = "related_components"
    }
}

public struct ComponentIO: Codable, Sendable {
    public let name: String
    public let type: String
    public let format: String
    public let description: String?
    public let optional: Bool
}

public struct ComponentAPI: Codable, Sendable {
    public let name: String
    public let signature: String
    public let stability: String
    public let visibility: String
}

public struct ComponentHealthDef: Codable, Sendable {
    public let checks: [String]
    public let metrics: [String]
    public let frequency: String
    public let critical: Bool
}

public struct ComponentObservability: Codable, Sendable {
    public let events: [String]
    public let logs: Bool
    public let metrics: Bool
    public let traces: Bool
    public let dashboard: String
}

public struct ComponentRuntimeDef: Codable, Sendable {
    public let executable: Bool
    public let location: String
    public let entrypoint: String
    public let stateful: Bool
    public let lifecycle: String
}

public struct ComponentLifecycle: Codable, Sendable {
    public let stages: [String]
    public let transitions: [LifecycleTransition]
    public let gates: [String]
}

public struct LifecycleTransition: Codable, Sendable {
    public let from: String
    public let to: String
    public let gate: String?
}

public struct ComponentImplementation: Codable, Sendable {
    public let language: String
    public let files: [String]
    public let tests: [String]
    public let documentation: [String]
}
