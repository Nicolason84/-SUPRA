import Foundation
import CAnnoNicoContracts

public struct PucheroMemoryAdapter: CAnnoNicoAdapter {
    public static let adapterID = "puchero.memory"

    private let sourcePath: String?

    public init(sourcePath: String?) {
        self.sourcePath = sourcePath
    }

    public func snapshot() -> CAnnoNicoSourceReference {
        let exists = sourcePath.map {
            FileManager.default.fileExists(atPath: $0)
        } ?? false

        return CAnnoNicoSourceReference(
            id: Self.adapterID,
            role: "READ_ONLY_MEMORY_AND_LINEAGE",
            path: sourcePath,
            state: exists ? .recovered : .unavailable,
            inputs: ["canonical_queries", "evidence_requests"],
            outputs: ["memory_references", "proof_lineage"],
            capabilities: [
                "READ_EXISTING_MEMORY",
                "RESOLVE_PROOF_REFERENCES",
                "NO_DATA_DUPLICATION"
            ]
        )
    }
}
