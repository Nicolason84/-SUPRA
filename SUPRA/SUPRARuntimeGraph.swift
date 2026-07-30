import Foundation
import Combine

public struct SUPRARuntimeNode: Identifiable, Sendable {
    public let id: String
    public let name: String
    public let type: NodeType
    public let status: NodeStatus
    public let health: Bool
    public let children: [String]

    public enum NodeType: String, Sendable {
        case mission
        case decision
        case capability
        case provider
        case model
        case plugin
        case memory
        case learning
        case executor
        case validation
    }

    public enum NodeStatus: String, Sendable {
        case active
        case inactive
        case error
        case discovering
    }

    public init(id: String, name: String, type: NodeType, status: NodeStatus = .active,
                health: Bool = true, children: [String] = []) {
        self.id = id
        self.name = name
        self.type = type
        self.status = status
        self.health = health
        self.children = children
    }
}

public struct SUPRARuntimeEdge: Identifiable, Sendable {
    public let id: String
    public let sourceID: String
    public let targetID: String
    public let label: String

    public init(sourceID: String, targetID: String, label: String = "") {
        self.id = "\(sourceID)->\(targetID)"
        self.sourceID = sourceID
        self.targetID = targetID
        self.label = label
    }
}

@MainActor
public final class SUPRARuntimeGraph: ObservableObject {
    public static let shared = SUPRARuntimeGraph()

    @Published public private(set) var nodes: [String: SUPRARuntimeNode] = [:]
    @Published public private(set) var edges: [String: SUPRARuntimeEdge] = [:]
    @Published public private(set) var lastUpdated: Date = .init()

    private let events = SUPRARuntimeEvents.shared
    private let providerPluginRegistry = SUPRAProviderPluginRegistry.shared
    private let pluginRegistry = SUPRAPluginRegistry.shared
    private let learningEngine = SUPRALearningEngine.shared
    private let decisionEngine = SUPRADecisionEngine.shared

    private init() {}

    public func refresh() {
        nodes.removeAll()
        edges.removeAll()
        buildGraph()
        lastUpdated = Date()
    }

    private func buildGraph() {
        addNode("decision_engine", "Decision Engine", .decision)
        addNode("execution_planner", "Execution Planner", .decision)
        addNode("routing_policy", "Routing Policy", .decision)
        addNode("capability_broker", "Capability Broker", .capability)
        addNode("scheduler", "Scheduler", .executor)
        addNode("fallback_engine", "Fallback Engine", .executor)
        addNode("learning_engine", "Learning Engine", .learning)
        addNode("runtime_metrics", "Runtime Metrics", .memory)

        addEdge("decision_engine", "execution_planner", "plans")
        addEdge("execution_planner", "routing_policy", "routes")
        addEdge("routing_policy", "capability_broker", "resolves")
        addEdge("routing_policy", "scheduler", "schedules")
        addEdge("scheduler", "fallback_engine", "falls back")
        addEdge("learning_engine", "routing_policy", "trains")
        addEdge("runtime_metrics", "learning_engine", "feeds")

        for (id, plugin) in providerPluginRegistry.providerPlugins {
            let pluginID = "plugin_\(id)"
            addNode(pluginID, plugin.declaration.providerName, .plugin,
                    health: pluginRegistry.pluginHealth[id] ?? false)
            addEdge("capability_broker", pluginID, "uses")
            addEdge("scheduler", pluginID, "executes")

            for model in plugin.models {
                let modelID = "model_\(model.modelID)"
                addNode(modelID, model.modelName, .model)
                addEdge(pluginID, modelID, "provides")

                for cap in model.capabilities {
                    let capID = "cap_\(cap)"
                    if nodes[capID] == nil {
                        addNode(capID, cap.cap, .capability)
                    }
                    addEdge(modelID, capID, "supports")
                }
            }
        }

        events.emit(.modelLoaded, "Runtime graph rebuilt: \(nodes.count) nodes, \(edges.count) edges",
                     source: "SUPRARuntimeGraph")
    }

    private func addNode(_ id: String, _ name: String, _ type: SUPRARuntimeNode.NodeType,
                          status: SUPRARuntimeNode.NodeStatus = .active, health: Bool = true) {
        nodes[id] = SUPRARuntimeNode(id: id, name: name, type: type, status: status, health: health)
    }

    private func addEdge(_ source: String, _ target: String, _ label: String = "") {
        let edge = SUPRARuntimeEdge(sourceID: source, targetID: target, label: label)
        edges[edge.id] = edge
    }

    public func graphDescription() -> String {
        var desc = "Runtime Graph (\(nodes.count) nodes, \(edges.count) edges)\n"
        desc += "Nodes:\n"
        for node in nodes.values.sorted(by: { $0.id < $1.id }) {
            desc += "  [\(node.type.rawValue)] \(node.name) - \(node.health ? "healthy" : "unhealthy")\n"
        }
        desc += "Edges:\n"
        for edge in edges.values.sorted(by: { $0.id < $1.id }) {
            if let source = nodes[edge.sourceID]?.name,
               let target = nodes[edge.targetID]?.name {
                desc += "  \(source) -> \(target) [\(edge.label)]\n"
            }
        }
        return desc
    }
}

private extension String {
    var cap: String {
        self.prefix(1).uppercased() + self.dropFirst()
    }
}
