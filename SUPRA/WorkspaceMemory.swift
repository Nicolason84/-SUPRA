import Foundation
import Combine

@MainActor
final class WorkspaceMemoryStore: ObservableObject {
    @Published var memory: WorkspaceMemory
    @Published var lastEntry: WorkspaceMemoryEntry?

    private let fileURL: URL

    init(baseURL: URL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)) {
        let base = baseURL
        fileURL = base.appendingPathComponent("workspace_memory.json")

        if let data = try? Data(contentsOf: fileURL),
           let loaded = try? JSONDecoder.workspace.decode(WorkspaceMemory.self, from: data) {
            memory = loaded
        } else {
            memory = WorkspaceMemory(version: "1.0.0", entries: [], lastIndexed: nil, totalSnapshots: 0)
        }
    }

    func recordEvent(type: String, object: WorkspaceObject?, change: String) {
        let entry = WorkspaceMemoryEntry(
            id: UUID().uuidString,
            timestamp: Date(),
            version: "1.0.0",
            eventType: type,
            objectId: object?.id,
            objectName: object?.name,
            objectType: object?.type,
            changeDescription: change,
            previousHash: nil,
            newHash: object?.hash
        )

        memory.entries.insert(entry, at: 0)
        memory.totalSnapshots += 1
        lastEntry = entry
        save()
    }

    func recordScan(index: WorkspaceIndex) {
        memory.lastIndexed = index.timestamp
        let entry = WorkspaceMemoryEntry(
            id: UUID().uuidString,
            timestamp: index.timestamp,
            version: index.version,
            eventType: "index_completed",
            objectId: nil,
            objectName: nil,
            objectType: nil,
            changeDescription: "Indexed \(index.objects.count) objects in \(String(format: "%.1f", index.metadata.scanDuration))s",
            previousHash: nil,
            newHash: nil
        )
        memory.entries.insert(entry, at: 0)
        memory.totalSnapshots += 1
        lastEntry = entry
        save()
    }

    func recordChange(old: WorkspaceObject?, new: WorkspaceObject) {
        guard let old = old else {
            recordEvent(type: "created", object: new, change: "\(new.type.rawValue) created: \(new.name)")
            return
        }
        if old.hash != new.hash {
            recordEvent(type: "modified", object: new, change: "\(new.name) modified")
        }
    }

    func history(for objectId: String) -> [WorkspaceMemoryEntry] {
        memory.entries.filter { $0.objectId == objectId }
    }

    func recentEvents(limit: Int = 50) -> [WorkspaceMemoryEntry] {
        Array(memory.entries.prefix(limit))
    }

    private func save() {
        guard let data = try? JSONEncoder.workspace.encode(memory) else { return }
        try? data.write(to: fileURL)
    }
}
