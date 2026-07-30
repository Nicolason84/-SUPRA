import Foundation
import Combine

enum SourceState: String, Codable {
    case resolved
    case missing
    case stale
    case permissionDenied
    case unavailable
}

struct ResolvedSource: Identifiable {
    let id: String
    let path: String
    let state: SourceState
    let label: String
    let lastVerified: Date
}

@MainActor
final class SUPRAEnvironmentResolver: ObservableObject {
    static let shared = SUPRAEnvironmentResolver()

    @Published private(set) var sources: [ResolvedSource] = []
    @Published private(set) var isResolved = false

    private let coordinator = ProtectedFolderAccessCoordinator.shared

    private init() {}

    func resolve() {
        let all: [(id: String, label: String, names: [String])] = [
            ("workspaceRoot", "Workspace Root", ["SUPRA"]),
            ("novaOSRoot", "NOVA OS Root", ["NOVA_OS"]),
            ("pucheroRoot", "Puchero Root", ["PUCHERO"]),
            ("nicoAppRoot", "Nico App Root", ["NICO_APP_V1"]),
            ("videoSwapRoot", "Video Swap Root", ["SUPRA_VIDEO_SWAP_V2"]),
            ("gabrielConductorRoot", "Gabriel Conductor Root", ["GABRIEL_PARALLEL_MISSION_CONDUCTOR_V1"]),
            ("desktop", "Desktop", ["Desktop"]),
            ("documents", "Documents", ["Documents"]),
            ("downloads", "Downloads", ["Downloads"]),
            ("developer", "Developer", ["Developer"]),
            ("projects", "Projects", ["Projects"]),
            ("github", "GitHub", ["github", "GitHub"]),
        ]

        var resolved: [ResolvedSource] = []
        for entry in all {
            let found = coordinator.snapshot.authorizedRootPaths.first {
                entry.names.contains(URL(fileURLWithPath: $0).lastPathComponent)
            } ?? coordinator.snapshot.entries.first {
                $0.isDirectory && entry.names.contains($0.name)
            }?.path
            resolved.append(ResolvedSource(
                id: entry.id,
                path: found ?? "",
                state: found == nil ? .unavailable : .resolved,
                label: entry.label, lastVerified: Date()
            ))
        }
        sources = resolved
        isResolved = true
    }

    func path(for id: String) -> String? {
        sources.first { $0.id == id && $0.state == .resolved }?.path
    }

    func state(for id: String) -> SourceState {
        sources.first { $0.id == id }?.state ?? .unavailable
    }

    var projectRoot: String {
        path(for: "workspaceRoot") ?? FileManager.default.currentDirectoryPath
    }
}
