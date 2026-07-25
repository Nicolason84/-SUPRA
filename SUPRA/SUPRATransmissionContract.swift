import Foundation

public enum PowerGear: String, Codable, Sendable, CaseIterable, Comparable {
    case G0_MECHANICAL
    case G1_ECO
    case G2_STANDARD
    case G3_TORQUE
    case G4_REVIEW
    case G5_OVERDRIVE

    public var rank: Int {
        switch self {
        case .G0_MECHANICAL: return 0
        case .G1_ECO: return 1
        case .G2_STANDARD: return 2
        case .G3_TORQUE: return 3
        case .G4_REVIEW: return 4
        case .G5_OVERDRIVE: return 5
        }
    }

    public static func < (lhs: PowerGear, rhs: PowerGear) -> Bool {
        lhs.rank < rhs.rank
    }
}

public struct PowerProfile: Codable, Sendable {
    public let gear: PowerGear
    public let providerCapability: String
    public let contextLimit: Int
    public let maxParallelTasks: Int
    public let writePermission: Bool
    public let allowedTools: [String]
    public let timeout: Int
    public let retryLimit: Int
    public let fallbackGear: PowerGear?
    public let memoryBudget: Double
    public let cpuBudget: Double

    public init(gear: PowerGear, providerCapability: String, contextLimit: Int,
                maxParallelTasks: Int, writePermission: Bool, allowedTools: [String],
                timeout: Int, retryLimit: Int, fallbackGear: PowerGear?,
                memoryBudget: Double, cpuBudget: Double) {
        self.gear = gear
        self.providerCapability = providerCapability
        self.contextLimit = contextLimit
        self.maxParallelTasks = maxParallelTasks
        self.writePermission = writePermission
        self.allowedTools = allowedTools
        self.timeout = timeout
        self.retryLimit = retryLimit
        self.fallbackGear = fallbackGear
        self.memoryBudget = memoryBudget
        self.cpuBudget = cpuBudget
    }

    public static let `default` = PowerProfile(
        gear: .G2_STANDARD,
        providerCapability: "reasoning",
        contextLimit: 4096,
        maxParallelTasks: 1,
        writePermission: false,
        allowedTools: ["read", "search"],
        timeout: 30,
        retryLimit: 2,
        fallbackGear: .G1_ECO,
        memoryBudget: 0.5,
        cpuBudget: 0.3
    )
}

public struct TransmissionDecision: Codable, Sendable {
    public let selectedGear: PowerGear
    public let selectedProviderID: String
    public let selectedModelID: String
    public let selectedWorkerID: String?
    public let selectedTimeout: Int
    public let selectedFallback: PowerGear?
    public let lockRequirements: [TransmissionLockType]
    public let reason: String
    public let timestamp: Date

    public init(selectedGear: PowerGear, selectedProviderID: String, selectedModelID: String,
                selectedWorkerID: String? = nil, selectedTimeout: Int,
                selectedFallback: PowerGear? = nil, lockRequirements: [TransmissionLockType],
                reason: String, timestamp: Date = Date()) {
        self.selectedGear = selectedGear
        self.selectedProviderID = selectedProviderID
        self.selectedModelID = selectedModelID
        self.selectedWorkerID = selectedWorkerID
        self.selectedTimeout = selectedTimeout
        self.selectedFallback = selectedFallback
        self.lockRequirements = lockRequirements
        self.reason = reason
        self.timestamp = timestamp
    }
}

public enum TransmissionLockType: String, Codable, Sendable {
    case developWriter = "DEVELOP_WRITER"
    case fileScope = "FILE_SCOPE"
    case xcodebuild = "XCODEBUILD"
    case derivedData = "DERIVED_DATA"
    case commit = "COMMIT"
    case modelMemory = "MODEL_MEMORY"
}

public struct TransmissionTelemetry: Codable, Sendable {
    public let currentGear: PowerGear
    public let currentProviderID: String
    public let currentWorkerID: String?
    public let queueDepth: Int
    public let writerLockState: String
    public let buildLockState: String
    public let cpuPressure: Double
    public let memoryPressure: Double
    public let diskPressure: Double
    public let contextUsage: Int
    public let contextLimit: Int
    public let taskDurationMs: Int
    public let gearShiftCount: Int
    public let fallbackCount: Int
    public let failedTaskCount: Int
    public let timestamp: Date

    public init(currentGear: PowerGear, currentProviderID: String,
                currentWorkerID: String? = nil, queueDepth: Int,
                writerLockState: String, buildLockState: String,
                cpuPressure: Double, memoryPressure: Double, diskPressure: Double,
                contextUsage: Int, contextLimit: Int, taskDurationMs: Int,
                gearShiftCount: Int, fallbackCount: Int, failedTaskCount: Int,
                timestamp: Date = Date()) {
        self.currentGear = currentGear
        self.currentProviderID = currentProviderID
        self.currentWorkerID = currentWorkerID
        self.queueDepth = queueDepth
        self.writerLockState = writerLockState
        self.buildLockState = buildLockState
        self.cpuPressure = cpuPressure
        self.memoryPressure = memoryPressure
        self.diskPressure = diskPressure
        self.contextUsage = contextUsage
        self.contextLimit = contextLimit
        self.taskDurationMs = taskDurationMs
        self.gearShiftCount = gearShiftCount
        self.fallbackCount = fallbackCount
        self.failedTaskCount = failedTaskCount
        self.timestamp = timestamp
    }
}
