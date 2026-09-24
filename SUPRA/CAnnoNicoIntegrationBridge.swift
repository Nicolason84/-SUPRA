import Foundation
import CAnnoNicoContracts
import PucheroMemoryAdapter
import NicoAppAdapter
import VideoSwapAdapter

enum SUPRACAnnoNicoIntegration {
    static let packageID = "CAnnoNicoIntegrationPackage"

    static let pucheroSource =
        "/Users/nicolasalonso/NOVA_OS/PUCHERO"

    static let nicoAppSource =
        "/Users/nicolasalonso/NOVA_OS/NICO_APP_V1"

    static let videoSwapSource =
        "/Users/nicolasalonso/Desktop/SUPRA_VIDEO_SWAP_V2"

    static let twinRegistrySource =
        "/Users/nicolasalonso/NOVA_OS/NICO_APP_IOS/NICO_APP_CLEAN/SUPRA_LEGO_ARCHITECTURE_V1/Twins/TWIN_REGISTRY.json"

    static let environmentTwinFabricSource =
        "/Users/nicolasalonso/NOVA_OS/SUPRA_CANNONICO_ENVIRONMENT_TWIN_FABRIC_V1/CURRENT/REPORT_TWINS.json"

    static let atlasSource =
        "/Users/nicolasalonso/NOVA_OS/PILOTE_ROOT_CANON/runtimes/ATLAS_RUNTIME"

    static let totalSystemTwinMapSource =
        "/Users/nicolasalonso/NOVA_OS/CANNONICO_ALL_SYSTEM_FILE_TWIN_SIDECAR_PARKING_V1/SIDECAR_PARKING/TWIN_MAP.json"

    static let uscrcProofGraphCanonSource =
        "/Users/nicolasalonso/NOVA_OS/_CANNONICO_MEMORY/uscrc_proofgraph_canon_v1/canon/USCRC_PROOFGRAPH_CANON_V1.json"

    static let uscrcGoldenPathSource =
        "/Users/nicolasalonso/NOVA_OS/_SINGLEGOLDENPATH/uscrc/uscrc_latest.json"

    static let proofGraphRuntimeSource =
        "/Users/nicolasalonso/NOVA_OS/TUV5_PROOFGRAPH_RUNTIME"

    static func recoveredReference(
        id: String,
        role: String,
        path: String,
        inputs: [String],
        outputs: [String],
        capabilities: [String]
    ) -> CAnnoNicoSourceReference {
        CAnnoNicoSourceReference(
            id: id,
            role: role,
            path: path,
            state: FileManager.default.fileExists(atPath: path) ? .recovered : .unavailable,
            inputs: inputs,
            outputs: outputs,
            capabilities: capabilities
        )
    }

    static func partialReference(
        id: String,
        role: String,
        inputs: [String],
        outputs: [String],
        capabilities: [String]
    ) -> CAnnoNicoSourceReference {
        CAnnoNicoSourceReference(
            id: id,
            role: role,
            path: nil,
            state: .partial,
            inputs: inputs,
            outputs: outputs,
            capabilities: capabilities
        )
    }

    static func snapshot() -> CAnnoNicoIntegrationSnapshot {
        CAnnoNicoIntegrationSnapshot(
            references: [
                PucheroMemoryAdapter(
                    sourcePath: pucheroSource
                ).snapshot(),
                NicoAppAdapter(
                    sourcePath: nicoAppSource
                ).snapshot(),
                VideoSwapAdapter(
                    sourcePath: videoSwapSource
                ).snapshot(),
                recoveredReference(
                    id: "uscrc.proofgraph.canon",
                    role: "READ_ONLY_USCRC_PROOFGRAPH_CANON",
                    path: uscrcProofGraphCanonSource,
                    inputs: ["media_source_identity", "proof_queries", "lineage_queries"],
                    outputs: ["uscrc_canon_refs", "proof_refs", "provenance_refs"],
                    capabilities: [
                        "READ_EXISTING_USCRC_PROOFGRAPH",
                        "PRESERVE_SOURCE_IDENTITY",
                        "NO_PARALLEL_PROOFCHAIN"
                    ]
                ),
                recoveredReference(
                    id: "uscrc.goldenpath",
                    role: "READ_ONLY_USCRC_CONTINUITY",
                    path: uscrcGoldenPathSource,
                    inputs: ["continuity_queries", "integrity_queries"],
                    outputs: ["continuity_state", "truth_route", "ui_to_truth_rule"],
                    capabilities: [
                        "READ_EXISTING_USCRC_CONTINUITY",
                        "VERIFY_CONTINUITY_STATE",
                        "NO_USCRC_RECREATION"
                    ]
                ),
                recoveredReference(
                    id: "proofgraph.runtime",
                    role: "READ_ONLY_PROOFGRAPH_RUNTIME",
                    path: proofGraphRuntimeSource,
                    inputs: ["evidence_queries", "lineage_queries", "proof_queries"],
                    outputs: ["proof_nodes", "proof_edges", "proof_refs", "snapshot_refs"],
                    capabilities: [
                        "READ_EXISTING_PROOFGRAPH_RUNTIME",
                        "RESOLVE_EXISTING_PROOF_LINEAGE",
                        "NO_PROOFGRAPH_REBUILD"
                    ]
                ),
                partialReference(
                    id: "smca.media.coherence",
                    role: "SPEC_ONLY_STRUCTURAL_MEDIA_COHERENCE",
                    inputs: ["media_hash", "metadata", "structural_observations"],
                    outputs: ["structural_flags", "coherence_indicator", "report_ref"],
                    capabilities: [
                        "STRUCTURAL_ANALYSIS_SPEC_ONLY",
                        "MCC_RUNTIME_UNPROVEN",
                        "NO_TRUTH_OR_AUTHENTICITY_SCORE"
                    ]
                ),
                recoveredReference(
                    id: "twin.registry",
                    role: "READ_ONLY_TWIN_REGISTRY",
                    path: twinRegistrySource,
                    inputs: ["canonical_twin_queries"],
                    outputs: ["twin_identities", "twin_states", "next_actions"],
                    capabilities: ["READ_EXISTING_TWINS", "NO_TWIN_RECREATION"]
                ),
                recoveredReference(
                    id: "twin.environment.fabric",
                    role: "READ_ONLY_ENVIRONMENT_TWIN_FABRIC",
                    path: environmentTwinFabricSource,
                    inputs: ["environment_queries", "report_queries"],
                    outputs: ["environment_twin_refs", "report_twin_refs"],
                    capabilities: ["READ_EXISTING_TWIN_FABRIC", "RESOLVE_TWIN_PROVENANCE"]
                ),
                recoveredReference(
                    id: "atlas.runtime",
                    role: "READ_ONLY_CANONICAL_ATLAS",
                    path: atlasSource,
                    inputs: ["structure_queries", "impact_queries"],
                    outputs: ["canonical_relations", "dependency_refs"],
                    capabilities: ["READ_EXISTING_ATLAS", "NO_PARALLEL_MAP"]
                ),
                recoveredReference(
                    id: "twin.system.file",
                    role: "READ_ONLY_TOTAL_SYSTEM_FILE_TWIN",
                    path: totalSystemTwinMapSource,
                    inputs: ["system_queries", "file_queries"],
                    outputs: ["system_file_twin_map", "lineage_refs"],
                    capabilities: ["READ_EXISTING_SYSTEM_TWIN", "NO_RESCAN_FROM_ZERO"]
                )
            ]
        )
    }

    static var recoveredCount: Int {
        snapshot().references.filter {
            $0.state == .recovered
        }.count
    }
}
