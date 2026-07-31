import Foundation
import Combine

@MainActor
final class WorkspaceKnowledgeGraph: ObservableObject {
    @Published var graph: WorkspaceGraph?
    @Published var isBuilt = false

    private var nodeDict: [String: GraphNode] = [:]
    private var edgeDict: [String: GraphEdge] = [:]
    private var adjacency: [String: Set<String>] = [:]

    func build(from index: WorkspaceIndex) -> WorkspaceGraph {
        nodeDict.removeAll()
        edgeDict.removeAll()
        adjacency.removeAll()

        var nodes: [GraphNode] = []
        var edges: [GraphEdge] = []

        let topObjects = index.objects.filter { $0.importance > 0.3 }

        for obj in topObjects {
            let node = GraphNode(id: obj.id, name: obj.name, type: obj.type, importance: obj.importance, projectName: obj.projectName)
            nodes.append(node)
            nodeDict[obj.id] = node
        }

        let paths = Dictionary(grouping: topObjects, by: { URL(fileURLWithPath: $0.path).deletingLastPathComponent().path })

        for (parentPath, children) in paths {
            guard let parent = topObjects.first(where: { $0.path == parentPath }),
                  nodeDict[parent.id] != nil
            else { continue }

            for child in children where child.id != parent.id {
                let edge = GraphEdge.contains(parent.id, child.id)
                edges.append(edge)
                adjacency[parent.id, default: []].insert(child.id)
            }
        }

        let projects = topObjects.filter { $0.type == .project || $0.type == .gitRepository || $0.type == .xcodeProject }
        for project in projects {
            let projectDir = URL(fileURLWithPath: project.path).deletingLastPathComponent().path
            let related = topObjects.filter { $0.path.hasPrefix(projectDir) && $0.id != project.id }
            for obj in related where nodeDict[project.id] != nil && nodeDict[obj.id] != nil {
                let edge = GraphEdge.references(project.id, obj.id)
                let key = edge.id
                if edgeDict[key] == nil {
                    edges.append(edge)
                    edgeDict[key] = edge
                    adjacency[project.id, default: []].insert(obj.id)
                }
            }
        }

        let startTime = Date()

        graph = WorkspaceGraph(
            version: "1.0.0",
            timestamp: startTime,
            nodes: nodes,
            edges: edges,
            metadata: WorkspaceMetadata(
                scanDuration: Date().timeIntervalSince(startTime),
                directoriesScanned: index.metadata.directoriesScanned,
                filesScanned: nodes.count,
                errors: []
            )
        )

        isBuilt = true
        saveToDisk()
        return graph!
    }

    func neighbors(of id: String) -> [GraphNode] {
        guard let neighborIds = adjacency[id] else { return [] }
        return neighborIds.compactMap { nodeDict[$0] }
    }

    func path(from source: String, to target: String) -> [GraphNode] {
        var visited = Set<String>()
        var queue: [(String, [GraphNode])] = [(source, [])]

        while !queue.isEmpty {
            let (current, path) = queue.removeFirst()
            if current == target {
                var result = path
                if let node = nodeDict[current] {
                    result.append(node)
                }
                return result
            }
            guard !visited.contains(current) else { continue }
            visited.insert(current)
            if let current = nodeDict[current] {
                let nextPath = path + [current]
                for neighbor in adjacency[current.id] ?? [] {
                    queue.append((neighbor, nextPath))
                }
            }
        }
        return []
    }

    private func saveToDisk() {
        guard let graph = graph else { return }
        let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("workspace_graph.json")
        guard let data = try? JSONEncoder.workspace.encode(graph) else { return }
        try? data.write(to: url)
    }
}
