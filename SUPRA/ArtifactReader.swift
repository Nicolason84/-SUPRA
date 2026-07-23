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

    private let fileManager: FileManager

    private static let lotURLs = [
        URL(fileURLWithPath: "/Users/nicolasalonso/NOVA_OS/SUPRA_EXECUTIVE_RUNTIME_V1/proofs/LOT1_INSTALLATION_PROOF.json"),
        URL(fileURLWithPath: "/Users/nicolasalonso/NOVA_OS/SUPRA_EXECUTIVE_RUNTIME_V1/proofs/LOT2_INSTALLATION_PROOF.json"),
        URL(fileURLWithPath: "/Users/nicolasalonso/NOVA_OS/SUPRA_EXECUTIVE_RUNTIME_V1/proofs/LOT3_INSTALLATION_PROOF.json")
    ]
    private static let buildURL = URL(fileURLWithPath: "/Users/nicolasalonso/NOVA_OS/_SYSTEM_BUILD/FULL_BUILD_20260605_120156/BUILD_STATUS.md")
    private static let manifestURL = URL(fileURLWithPath: "/Users/nicolasalonso/NOVA_OS/SUPRA_UI_DATA_BINDER_V1/CURRENT/MANIFEST.json")
    private static let desktopEstateURL = URL(fileURLWithPath: "/Users/nicolasalonso/NOVA_OS/SUPRA_CANNONICO_IMAC_ESTATE_V1/CURRENT/ESTATE_STATE.json")
    private static let indexURL = URL(fileURLWithPath: "/Users/nicolasalonso/NOVA_OS/SUPRA_CONTROLLED_STORAGE_RELEASE_V1/INDEX.json")

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func read() throws -> Snapshot {
        let lots = Self.lotURLs.enumerated().map { offset, url in
            availableJSONStatus(name: "LOT\(offset + 1)", url: url, preferredKeys: ["verdict", "status", "result"])
        }
        let build = availableTextStatus(name: "BUILD_STATUS", url: Self.buildURL)
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

    private func availableTextStatus(name: String, url: URL) -> ArtifactStatus {
        do {
            return try textStatus(name: name, url: url)
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

    private func jsonStatus(name: String, url: URL, preferredKeys: [String]) throws -> ArtifactStatus {
        guard let data = fileManager.contents(atPath: url.path) else {
            throw ReaderError.unreadable(name, url)
        }
        guard let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw ReaderError.invalidJSON(name, url)
        }
        let value = preferredKeys.compactMap { object[$0] }.first.map { String(describing: $0) }
        return status(name: name, url: url, value: value ?? "Available", detail: jsonDetail(object))
    }

    private func optionalJSONStatus(name: String, url: URL) -> ArtifactStatus {
        guard fileManager.fileExists(atPath: url.path) else {
            return status(name: name, url: url, value: "Unavailable", detail: "Optional artifact", available: false)
        }
        return (try? jsonStatus(name: name, url: url, preferredKeys: ["status", "state", "version"]))
            ?? status(name: name, url: url, value: "Unavailable", detail: "Optional artifact is unreadable", available: false)
    }

    private func textStatus(name: String, url: URL) throws -> ArtifactStatus {
        guard let text = try? String(contentsOf: url, encoding: .utf8) else {
            throw ReaderError.unreadable(name, url)
        }
        let meaningful = text.split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { $0.localizedCaseInsensitiveContains("status") }
            ?? text.split(separator: "\n").first.map(String.init)
            ?? "Available"
        return status(name: name, url: url, value: meaningful, detail: nil)
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
