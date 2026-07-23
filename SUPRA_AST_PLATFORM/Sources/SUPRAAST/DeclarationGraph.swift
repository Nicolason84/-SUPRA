import Foundation

public struct DeclarationGraph: Codable, Sendable, Equatable {
    public struct Node: Codable, Sendable, Equatable {
        public let name: String
        public let kind: String
        public let parent: String?
        public let children: [String]

        public init(name: String, kind: String, parent: String? = nil, children: [String] = []) {
            self.name = name
            self.kind = kind
            self.parent = parent
            self.children = children
        }
    }

    public let source: String
    public let nodes: [Node]

    public init(source: String, nodes: [Node] = []) {
        self.source = source
        self.nodes = nodes
    }
}
