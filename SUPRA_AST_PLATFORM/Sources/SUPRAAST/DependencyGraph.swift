import Foundation

public struct DependencyGraph: Codable, Sendable, Equatable {
    public struct Edge: Codable, Sendable, Equatable {
        public let source: String
        public let target: String

        public init(source: String, target: String) {
            self.source = source
            self.target = target
        }
    }

    public let nodes: [String]
    public let edges: [Edge]

    public init(nodes: [String] = [], edges: [Edge] = []) {
        self.nodes = nodes
        self.edges = edges
    }
}
