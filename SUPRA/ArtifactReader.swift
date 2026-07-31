import Foundation

struct ArtifactReader {
    enum ReaderError: LocalizedError {
        case unreadable(String, URL)
        case invalidJSON(String, URL)

        var errorDescription: String? {
            switch self {
            case .unreadable(let name, let url):
                return "\(name) unavailable: \(url.path)"
            case .invalidJSON(let name, let url):
                return "\(name) contains invalid JSON: \(url.path)"
            }
        }
    }

    private let fileSystem: FileSystemPort
    private let fileManager: FileManager

    private static var lotURLs: [URL] {
        let root = SUPRAEnvironmentResolver.shared.projectRoot
        return [
            URL(fileURLWithPath: "\(root)/proofs/LOT1_INSTALLATION_PROOF.json"),
            URL(fileURLWithPath: "\(root)/proofs/LOT2_INSTALLATION_PROOF.json"),
            URL(fileURLWithPath: "\(root)/proofs/LOT3_INSTALLATION_PROOF.json"),
        ]
    }
    private static var manifestURL: URL {
        URL(fileURLWithPath: "\(SUPRAEnvironmentResolver.shared.projectRoot)/MANIFEST.json")
    }
    private static var desktopEstateURL: URL {
        URL(fileURLWithPath: "\(SUPRAEnvironmentResolver.shared.projectRoot)/ESTATE_STATE.json")
    }
    private static var indexURL: URL {
        URL(fileURLWithPath: "\(SUPRAEnvironmentResolver.shared.projectRoot)/INDEX.json")
    }

    init(fileSystem: FileSystemPort = DefaultFileSystemPort.live(), fileManager: FileManager = .default) {
        self.fileSystem = fileSystem
        self.fileManager = fileManager
    }

    func read() throws -> Snapshot {
        let lots = Self.lotURLs.enumerated().map { offset, url in
            availableJSONStatus(name: "LOT\(offset + 1)", url: url, preferredKeys: ["verdict", "status", "result"])
        }
        let build = buildStatusForSnapshot()
        let manifest = availableJSONStatus(name: "MANIFEST", url: Self.manifestURL, preferredKeys: ["status", "state", "version"])
        let estate = availableJSONStatus(
            name: "Desktop Estate",
            url: Self.desktopEstateURL,
            preferredKeys: ["status", "state", "items_sorted", "sorted_items", "organized"]
        )

        return Snapshot(
            lots: lots,
            build: build,
            manifest: manifest,
            index: optionalJSONStatus(name: "INDEX", url: Self.indexURL),
            desktopEstate: estate,
            capturedAt: .now
        )
    }

    private func availableJSONStatus(name: String, url: URL, preferredKeys: [String]) -> ArtifactStatus {
        do {
            return try jsonStatus(name: name, url: url, preferredKeys: preferredKeys)
        } catch {
            return status(
                name: name,
                url: url,
                value: "Unavailable",
                detail: error.localizedDescription,
                available: false
            )
        }
    }

    private func buildStatusForSnapshot() -> ArtifactStatus {
        let location = StorageLocation(directory: .continuity, filename: "BUILD_STATUS.md")
        guard fileSystem.exists(location) else {
            SUPRARuntimeLogger.shared.log(.error, "ArtifactReader: BUILD_STATUS.md not found via FileSystemPort")
            return status(
                name: "BUILD_STATUS",
                url: fileSystem.url(for: location),
                value: "Unavailable",
                detail: "BUILD_STATUS.md not found in FileSystemPort",
                available: false
            )
        }
        do {
            let text = try fileSystem.readString(location)
            let meaningful = text.split(separator: "\n")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .first { $0.localizedCaseInsensitiveContains("status") }
                ?? text.split(separator: "\n").first.map(String.init)
                ?? "Available"
            return status(name: "BUILD_STATUS", url: fileSystem.url(for: location), value: meaningful, detail: nil)
        } catch {
            SUPRARuntimeLogger.shared.log(.error, "ArtifactReader: BUILD_STATUS.md read error via FileSystemPort: \(error.localizedDescription)")
            return status(
                name: "BUILD_STATUS",
                url: fileSystem.url(for: location),
                value: "Unavailable",
                detail: error.localizedDescription,
                available: false
            )
        }
    }

    private func jsonStatus(name: String, url: URL, preferredKeys: [String]) throws -> ArtifactStatus {
        guard let data = fileManager.contents(atPath: url.path) else {
            SUPRARuntimeLogger.shared.log(.error, "ArtifactReader: \(name) unreadable at \(url.path)")
            throw ReaderError.unreadable(name, url)
        }
        let object: [String: Any]
        do {
            guard let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                SUPRARuntimeLogger.shared.log(.error, "ArtifactReader: \(name) at \(url.path) is not a JSON object")
                throw ReaderError.invalidJSON(name, url)
            }
            object = obj
        } catch let error as ReaderError {
            throw error
        } catch {
            SUPRARuntimeLogger.shared.log(.error, "ArtifactReader: \(name) JSON parse error: \(error.localizedDescription)")
            throw ReaderError.invalidJSON(name, url)
        }
        let value = preferredKeys.compactMap { object[$0] }.first.map { String(describing: $0) }
        return status(name: name, url: url, value: value ?? "Available", detail: jsonDetail(object))
    }

    private func optionalJSONStatus(name: String, url: URL) -> ArtifactStatus {
        guard fileManager.fileExists(atPath: url.path) else {
            SUPRARuntimeLogger.shared.log(.error, "ArtifactReader: Optional \(name) not found at \(url.path)")
            return status(name: name, url: url, value: "Unavailable", detail: "Optional artifact", available: false)
        }
        do {
            return try jsonStatus(name: name, url: url, preferredKeys: ["status", "state", "version"])
        } catch {
            SUPRARuntimeLogger.shared.log(.error, "ArtifactReader: Optional \(name) unreadable: \(error.localizedDescription)")
            return status(name: name, url: url, value: "Unavailable", detail: "Optional artifact is unreadable", available: false)
        }
    }

    private func jsonDetail(_ object: [String: Any]) -> String? {
        let keys = ["tests", "count", "items", "conflicts", "exclusions"]
        let values = keys.compactMap { key in object[key].map { "\(key): \($0)" } }
        return values.isEmpty ? nil : values.joined(separator: " · ")
    }

    private func status(
        name: String,
        url: URL,
        value: String,
        detail: String?,
        available: Bool = true
    ) -> ArtifactStatus {
        let modifiedAt = try? url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate
        return ArtifactStatus(
            id: name,
            name: name,
            path: url.path,
            status: value,
            detail: detail,
            modifiedAt: modifiedAt,
            isAvailable: available
        )
    }
}
