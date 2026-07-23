import Foundation
import Combine

@MainActor
final class ControlCenterStore: ObservableObject {
    @Published private(set) var snapshot: Snapshot?
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading = false

    private let reader: ArtifactReader

    init() {
        self.reader = ArtifactReader()
    }

    init(reader: ArtifactReader) {
        self.reader = reader
    }

    func load() {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            snapshot = try reader.read()
        } catch {
            snapshot = nil
            errorMessage = error.localizedDescription
        }
    }
}
