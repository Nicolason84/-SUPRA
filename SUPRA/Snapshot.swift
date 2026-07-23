import Foundation

struct ArtifactStatus: Identifiable, Equatable {
    let id: String
    let name: String
    let path: String
    let status: String
    let detail: String?
    let modifiedAt: Date?
    let isAvailable: Bool
}

struct Snapshot: Equatable {
    let lots: [ArtifactStatus]
    let build: ArtifactStatus
    let manifest: ArtifactStatus
    let index: ArtifactStatus
    let desktopEstate: ArtifactStatus
    let capturedAt: Date

    var availableCount: Int {
        (lots + [build, manifest, desktopEstate]).filter(\.isAvailable).count
    }

    var requiredCount: Int { lots.count + 3 }
}
