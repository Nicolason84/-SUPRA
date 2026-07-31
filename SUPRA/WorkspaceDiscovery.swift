import Foundation
import Combine

@MainActor
final class WorkspaceDiscovery: ObservableObject {
    @Published var isScanning = false
    @Published var progress: Double = 0
    @Published var discoveredCount: Int = 0
    @Published var errors: [String] = []
    @Published var lastScanDate: Date?

    private let config: WorkspaceConfiguration
    private let coordinator: ProtectedFolderAccessCoordinator

    init(
        config: WorkspaceConfiguration? = nil,
        coordinator: ProtectedFolderAccessCoordinator? = nil
    ) {
        self.config = config ?? .default
        self.coordinator = coordinator ?? .shared
    }

    func scan() async throws -> [WorkspaceObject] {
        isScanning = true
        progress = 0
        errors.removeAll()

        let protectedSnapshot = coordinator.snapshot
        let allObjects = protectedSnapshot.entries.compactMap(makeWorkspaceObject)
        discoveredCount = allObjects.count
        progress = 1
        lastScanDate = Date()
        isScanning = false

        return allObjects
    }

    private func makeWorkspaceObject(_ entry: ProtectedFolderEntry) -> WorkspaceObject? {
        if !entry.isDirectory {
            guard entry.sizeBytes > 0, entry.sizeBytes <= config.maxFileSizeBytes else { return nil }
            guard config.fileExtensions.contains(entry.pathExtension) ||
                    ["txt", "md", "log", "out", "cfg", "ini", "conf"].contains(entry.pathExtension)
            else { return nil }
        }
        let type: WorkspaceObjectType
        if entry.isDirectory {
            type = entry.name == ".git" ? .gitRepository : .directory
        } else if entry.pathExtension == "xcodeproj" || entry.pathExtension == "xcworkspace" {
            type = .xcodeProject
        } else {
            type = .file
        }
        let hash = "\(entry.path):\(entry.sizeBytes):\(entry.modifiedAt?.timeIntervalSince1970 ?? 0)"
        return WorkspaceObject(
            id: String(hash.hashValue),
            name: entry.name,
            path: entry.path,
            type: type,
            language: nil,
            dateCreated: entry.createdAt,
            dateModified: entry.modifiedAt,
            sizeBytes: entry.sizeBytes,
            hash: String(hash.hashValue),
            relations: [],
            tags: [type.rawValue],
            importance: type == .gitRepository || type == .xcodeProject ? 1 : 0.5,
            projectName: URL(fileURLWithPath: entry.authorizedRootPath).lastPathComponent,
            moduleName: nil,
            lineCount: nil
        )
    }
}
