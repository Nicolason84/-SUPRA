import Foundation
import Combine

@MainActor
final class WorkspaceIndexer: ObservableObject {
    @Published var index: WorkspaceIndex = .initial
    @Published var isIndexing = false

    private let discovery: WorkspaceDiscovery
    private var scanStartTime: CFAbsoluteTime = 0

    init(discovery: WorkspaceDiscovery) {
        self.discovery = discovery
    }

    func buildIndex() async throws -> WorkspaceIndex {
        isIndexing = true
        scanStartTime = CFAbsoluteTimeGetCurrent()

        let objects = try await discovery.scan()
        let enriched = enrichRelationships(objects)
        let sorted = enriched.sorted { $0.importance > $1.importance }

        let scanDuration = CFAbsoluteTimeGetCurrent() - scanStartTime
        let directories = sorted.filter { $0.type == .directory }.count
        let files = sorted.filter { $0.type != .directory }.count

        let metadata = WorkspaceMetadata(
            scanDuration: scanDuration,
            directoriesScanned: directories,
            filesScanned: files,
            errors: discovery.errors
        )

        index = WorkspaceIndex(
            version: "1.0.0",
            timestamp: Date(),
            objects: sorted,
            metadata: metadata
        )

        isIndexing = false
        saveToDisk()
        return index
    }

    private func enrichRelationships(_ objects: [WorkspaceObject]) -> [WorkspaceObject] {
        var indexed = Dictionary(uniqueKeysWithValues: objects.map { ($0.id, $0) })
        let paths = Dictionary(grouping: objects, by: { URL(fileURLWithPath: $0.path).deletingLastPathComponent().path })

        for (parentPath, children) in paths {
            guard objects.first(where: { $0.path == parentPath }) != nil else { continue }
            for var child in children {
                let parentPathObj = parentPath
                if let parentID = objects.first(where: { $0.path == parentPathObj })?.id {
                    if !child.relations.contains(where: { $0.targetId == parentID }) {
                        child.relations.append(.belongsTo(parentID))
                    }
                }
                indexed[child.id] = child
            }
        }

        return Array(indexed.values)
    }

    private func saveToDisk() {
        let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("workspace_index.json")
        guard let data = try? JSONEncoder.workspace.encode(index) else { return }
        try? data.write(to: url)
    }
}

extension JSONEncoder {
    static let workspace: JSONEncoder = {
        let e = JSONEncoder()
        e.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        e.dateEncodingStrategy = .iso8601
        return e
    }()
}

extension JSONDecoder {
    static let workspace: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()
}
