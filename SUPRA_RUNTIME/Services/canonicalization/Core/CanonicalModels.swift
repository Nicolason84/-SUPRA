import Foundation

// MARK: - CANNoNICO Primitives

public enum CAN_TYPE: String, Codable, CaseIterable, Sendable {
    case agent = "agent"
    case knowledge = "knowledge"
    case event = "event"
    case decision = "decision"
    case constraint = "constraint"
    case relation = "relation"
    case capability = "capability"
    case projection = "projection"
    case memory = "memory"
    case runtime = "runtime"
    case workflow = "workflow"
    case service = "service"
    case connector = "connector"
    case manifest = "manifest"
    case registry = "registry"
    case model = "model"
    case document = "document"
    case script = "script"
    case config = "config"
    case structure = "structure"
}

public enum CAN_VERSION: String, Codable, Sendable {
    case v1 = "V1"
}

public enum CAN_STATE_STATUS: String, Codable, CaseIterable, Sendable {
    case active = "active"
    case inactive = "inactive"
    case deprecated = "deprecated"
    case error = "error"
    case canonical = "canonical"
    case duplicate = "duplicate"
    case merged = "merged"
    case orphan = "orphan"
}

public enum CAN_MODE: String, Codable, CaseIterable, Sendable {
    case normal = "normal"
    case degraded = "degraded"
    case fallback = "fallback"
    case maintenance = "maintenance"
}

public enum CAN_PHASE: String, Codable, CaseIterable, Sendable {
    case detect = "detect"
    case ingest = "ingest"
    case process = "process"
    case validate = "validate"
    case compile = "compile"
    case publish = "publish"
}

public enum CAN_VERDICT: String, Codable, CaseIterable, Sendable {
    case pass = "pass"
    case fail = "fail"
    case retry = "retry"
    case deferred = "deferred"
    case escalate = "escalate"
}

public enum CAN_SEVERITY: String, Codable, CaseIterable, Sendable {
    case critical = "critical"
    case error = "error"
    case warning = "warning"
    case info = "info"
}

public enum RELATION_TYPE: String, Codable, CaseIterable, Sendable {
    case dependsOn = "depends_on"
    case uses = "uses"
    case produces = "produces"
    case constrains = "constrains"
    case projectsTo = "projects_to"
    case compilesFrom = "compiles_from"
    case references = "references"
    case precedes = "precedes"
    case causes = "causes"
    case validates = "validates"
    case belongsTo = "belongs_to"
    case extends = "extends"
    case implements = "implements"
    case replaces = "replaces"
    case supersedes = "supersedes"
    case derivesFrom = "derives_from"
    case communicatesWith = "communicates_with"
    case syncsWith = "syncs_with"
    case triggers = "triggers"
    case monitors = "monitors"
    case controls = "controls"
    case observes = "observes"
    case equivalentTo = "equivalent_to"
    case variantOf = "variant_of"
    case partOf = "part_of"
    case contains = "contains"
    case duplicates = "duplicates"
}

public enum ARTIFACT_TYPE: String, Codable, CaseIterable, Sendable {
    case swiftFile = "swift_file"
    case bashScript = "bash_script"
    case jsonFile = "json_file"
    case yamlFile = "yaml_file"
    case markdownFile = "markdown_file"
    case sqlFile = "sql_file"
    case manifest = "manifest"
    case registry = "registry"
    case swiftStructure = "swift_structure"
    case swiftEnum = "swift_enum"
    case swiftStruct = "swift_struct"
    case swiftClass = "swift_class"
}

// MARK: - CAN_ID

public struct CAN_ID: Codable, Hashable, Sendable {
    public let value: String
    public let type: CAN_TYPE
    public let hash: String

    public init(type: CAN_TYPE, hash: String) {
        self.value = "can:\(type.rawValue):\(hash)"
        self.type = type
        self.hash = hash
    }

    public static func from(value: String) -> CAN_ID? {
        let parts = value.split(separator: ":", maxSplits: 2, omittingEmptySubsequences: false)
        guard parts.count == 3, let type = CAN_TYPE(rawValue: String(parts[1])) else {
            return nil
        }
        return CAN_ID(type: type, hash: String(parts[2]))
    }
}

// MARK: - CAN_KNOWLEDGE

public struct CAN_KNOWLEDGE: Codable, Hashable, Sendable {
    public let canId: CAN_ID
    public let canType: String = "knowledge"
    public let canVersion: CAN_VERSION = .v1
    public let canName: String
    public let canContent: String
    public let canSource: [String]
    public let canEvidence: [CAN_ID]
    public let canConfidence: Double
    public let canCompiledAt: Int64
    public let canState: CAN_STATE_STATUS
    public let canRelations: [CAN_RELATION_REF]
    public let canConstraints: [CAN_ID]
    public let canProjections: [String]
    public let canTrace: [CAN_ID]
    public let canValidated: Bool
    public let canRejected: Bool
    public let canRejectionReason: String?
}

// MARK: - CAN_RELATION

public struct CAN_RELATION_REF: Codable, Hashable, Sendable {
    public let target: CAN_ID
    public let relationType: RELATION_TYPE
    public let direction: String
    public let weight: Double
    public let evidence: [CAN_ID]
    public let compiledAt: Int64
    public let validated: Bool
}

// MARK: - CAN_EVENT

public struct CAN_EVENT: Codable, Hashable, Sendable {
    public let canId: CAN_ID
    public let canType: String = "event"
    public let canName: String
    public let canCategory: String
    public let canTick: Int64
    public let canEntity: CAN_ID
    public let canPayload: String
    public let canPreviousState: CAN_STATE_STATUS?
    public let canNextState: CAN_STATE_STATUS?
    public let canSource: CAN_ID?
    public let canEvidence: [CAN_ID]
    public let canCompiledAt: Int64
    public let canImmutable: Bool = true
}

// MARK: - CAN_DECISION

public struct CAN_DECISION: Codable, Hashable, Sendable {
    public let canId: CAN_ID
    public let canType: String = "decision"
    public let canSubject: String
    public let canContext: [String: String]
    public let canOptions: [CAN_DECISION_OPTION]
    public let canChosen: String
    public let canRationale: String
    public let canEvidence: [CAN_ID]
    public let canConstraints: [CAN_ID]
    public let canAuthoritative: Bool
    public let canVerdict: CAN_VERDICT
    public let canCompiledAt: Int64
    public let canSource: CAN_ID?
    public let canTrace: [CAN_ID]
    public let canValidated: Bool
    public let canGovernanceRef: CAN_ID?
}

public struct CAN_DECISION_OPTION: Codable, Hashable, Sendable {
    public let id: String
    public let description: String
    public let score: Double
}

// MARK: - CAN_CAPABILITY

public struct CAN_CAPABILITY: Codable, Hashable, Sendable {
    public let canId: CAN_ID
    public let canType: String = "capability"
    public let canName: String
    public let canDescription: String
    public let canEntity: CAN_ID
    public let canQuality: CAN_QUALITY
    public let canRequirements: [CAN_ID]
    public let canLimitations: [CAN_ID]
    public let canEvidence: [CAN_ID]
    public let canCompiledAt: Int64
    public let canValidated: Bool
}

public struct CAN_QUALITY: Codable, Hashable, Sendable {
    public let accuracy: Double
    public let latencyMs: Int
    public let availability: Double
    public let throughput: Double
    public let reliability: Double
}

// MARK: - CAN_CONSTRAINT

public struct CAN_CONSTRAINT: Codable, Hashable, Sendable {
    public let canId: CAN_ID
    public let canType: String = "constraint"
    public let canName: String
    public let canDescription: String
    public let canEntity: CAN_ID
    public let canRule: String
    public let canSeverity: CAN_SEVERITY
    public let canEvidence: [CAN_ID]
    public let canCompiledAt: Int64
}

// MARK: - CAN_STATE

public struct CAN_STATE: Codable, Hashable, Sendable {
    public let canId: CAN_ID
    public let canType: String = "state"
    public let canEntity: CAN_ID
    public let canStatus: CAN_STATE_STATUS
    public let canMode: CAN_MODE
    public let canPhase: CAN_PHASE
    public let canTick: Int64
    public let canProperties: [String: String]
    public let canEvidence: [CAN_ID]
    public let canCompiledAt: Int64
}

// MARK: - CAN_TRANSITION

public struct CAN_TRANSITION: Codable, Hashable, Sendable {
    public let canId: CAN_ID
    public let canType: String = "transition"
    public let canEntity: CAN_ID
    public let canFromState: CAN_STATE_STATUS
    public let canToState: CAN_STATE_STATUS
    public let canFromTick: Int64
    public let canToTick: Int64
    public let canTrigger: CAN_ID?
    public let canEvidence: [CAN_ID]
    public let canCompiledAt: Int64
}

// MARK: - Artifact Reference

public struct ArtifactReference: Codable, Hashable, Sendable {
    public let id: String
    public let type: ARTIFACT_TYPE
    public let path: String
    public let name: String
    public let sizeBytes: Int64
    public let lastModified: Int64
    public let checksum: String
    public let canonicalId: CAN_ID?
    public let semanticFingerprint: String
    public let sourceCategory: String
}

// MARK: - Duplicate Cluster

public struct DuplicateCluster: Codable, Hashable, Sendable {
    public let id: String
    public let semanticKey: String
    public let artifacts: [ArtifactReference]
    public let clusterType: ClusterType
    public let confidence: Double
    public let evidence: [String]

    public enum ClusterType: String, Codable, Hashable, Sendable {
        case duplicateConcept = "duplicate_concept"
        case duplicateResponsibility = "duplicate_responsibility"
        case duplicateRuntimeService = "duplicate_runtime_service"
        case duplicateModel = "duplicate_model"
        case duplicateDocumentation = "duplicate_documentation"
        case duplicateSwiftStructure = "duplicate_swift_structure"
        case duplicateBashScript = "duplicate_bash_script"
        case duplicateJSON = "duplicate_json"
        case duplicateYAML = "duplicate_yaml"
        case duplicateManifest = "duplicate_manifest"
        case duplicateRegistry = "duplicate_registry"
        case equivalentConcept = "equivalent_concept"
        case semanticallyRelated = "semantically_related"
    }
}

// MARK: - Canonical Entity

public struct CanonicalEntity: Codable, Hashable, Sendable {
    public let canId: CAN_ID
    public let canType: CAN_TYPE
    public let canName: String
    public let canSemantics: [String: String]
    public let canResponsibilities: [String]
    public let canCapabilities: [CAN_ID]
    public let canRelations: [CAN_RELATION_REF]
    public let canState: CAN_STATE_STATUS
    public let canTick: Int64
    public let canArtifacts: [ArtifactReference]
    public let canEvidence: [CAN_ID]
    public let canSource: [String]
    public let canProjections: [String]
    public let canConfidence: Double
    public let canValidated: Bool
}

// MARK: - Canonical Knowledge Graph Entry

public struct CGNode: Codable, Hashable, Sendable {
    public let id: CAN_ID
    public let label: String
    public let type: CAN_TYPE
    public let primitive: String
    public let responsibility: String?
    public let capability: CAN_ID?
    public let proof: [CAN_ID]
    public let nambrohoraRef: Int64
    public let properties: [String: String]
    public let relations: [CAN_RELATION_REF]
}

public struct CGEdge: Codable, Hashable, Sendable {
    public let source: CAN_ID
    public let target: CAN_ID
    public let relationType: RELATION_TYPE
    public let weight: Double
    public let evidence: [CAN_ID]
    public let tick: Int64
}

public struct CanonicalKnowledgeGraph: Codable, Hashable, Sendable {
    public let nodes: [CGNode]
    public let edges: [CGEdge]
    public let compiledAt: Int64
    public let tick: Int64
    public let version: String = "V1"

    public func node(with id: CAN_ID) -> CGNode? {
        nodes.first { $0.id == id }
    }

    public func edges(from id: CAN_ID) -> [CGEdge] {
        edges.filter { $0.source == id }
    }

    public func edges(to id: CAN_ID) -> [CGEdge] {
        edges.filter { $0.target == id }
    }
}