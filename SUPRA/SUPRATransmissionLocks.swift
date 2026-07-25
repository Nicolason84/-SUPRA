import Foundation
import Combine

@MainActor
public final class SUPRATransmissionLocks: ObservableObject {
    public static let shared = SUPRATransmissionLocks()

    @Published public private(set) var developWriterLock = false
    @Published public private(set) var fileScopeLocks: [String: Bool] = [:]
    @Published public private(set) var xcodebuildLocks: [String: Bool] = [:]
    @Published public private(set) var commitLock = false
    @Published public private(set) var modelMemoryLock = false

    public let maxDevelopWriters = 1
    public let maxXcodebuildPerDerivedData = 1

    private var lockHolders: [TransmissionLockType: String] = [:]
    private var lockTimestamps: [TransmissionLockType: Date] = [:]

    private init() {}

    public func acquire(_ lock: TransmissionLockType, holder: String, scope: String? = nil) -> Bool {
        switch lock {
        case .developWriter:
            guard !developWriterLock else { return false }
            developWriterLock = true
        case .fileScope:
            let key = scope ?? "default"
            guard fileScopeLocks[key] != true else { return false }
            fileScopeLocks[key] = true
        case .xcodebuild, .derivedData:
            let key = scope ?? "default"
            guard xcodebuildLocks[key] != true else { return false }
            xcodebuildLocks[key] = true
        case .commit:
            guard !commitLock else { return false }
            commitLock = true
        case .modelMemory:
            guard !modelMemoryLock else { return false }
            modelMemoryLock = true
        }
        lockHolders[lock] = holder
        lockTimestamps[lock] = Date()
        return true
    }

    public func release(_ lock: TransmissionLockType, scope: String? = nil) {
        switch lock {
        case .developWriter:
            developWriterLock = false
        case .fileScope:
            fileScopeLocks[scope ?? "default"] = false
        case .xcodebuild, .derivedData:
            xcodebuildLocks[scope ?? "default"] = false
        case .commit:
            commitLock = false
        case .modelMemory:
            modelMemoryLock = false
        }
        lockHolders.removeValue(forKey: lock)
        lockTimestamps.removeValue(forKey: lock)
    }

    public func isLocked(_ lock: TransmissionLockType, scope: String? = nil) -> Bool {
        switch lock {
        case .developWriter: return developWriterLock
        case .fileScope: return fileScopeLocks[scope ?? "default"] ?? false
        case .xcodebuild, .derivedData: return xcodebuildLocks[scope ?? "default"] ?? false
        case .commit: return commitLock
        case .modelMemory: return modelMemoryLock
        }
    }

    public func holder(of lock: TransmissionLockType) -> String? {
        lockHolders[lock]
    }

    public func releaseAll(by holder: String) {
        for (lock, h) in lockHolders where h == holder {
            release(lock)
        }
    }

    public func status() -> String {
        var s = "Locks:\n"
        s += "  DEVELOP_WRITER: \(developWriterLock ? "held by \(lockHolders[.developWriter] ?? "?")" : "free")\n"
        s += "  COMMIT: \(commitLock ? "held" : "free")\n"
        s += "  MODEL_MEMORY: \(modelMemoryLock ? "held" : "free")\n"
        s += "  FILE_SCOPES: \(fileScopeLocks.filter(\.value).count) active\n"
        s += "  XCODEBUILD: \(xcodebuildLocks.filter(\.value).count) active"
        return s
    }

    public func reset() {
        developWriterLock = false
        fileScopeLocks = [:]
        xcodebuildLocks = [:]
        commitLock = false
        modelMemoryLock = false
        lockHolders = [:]
        lockTimestamps = [:]
    }
}

public struct SUPRATransmissionLocksSnapshot: Codable, Sendable {
    public let developWriterLocked: Bool
    public let developWriterHolder: String?
    public let activeFileScopes: [String]
    public let activeXcodebuildScopes: [String]
    public let commitLocked: Bool
    public let modelMemoryLocked: Bool

    public init(developWriterLocked: Bool, developWriterHolder: String?,
                activeFileScopes: [String], activeXcodebuildScopes: [String],
                commitLocked: Bool, modelMemoryLocked: Bool) {
        self.developWriterLocked = developWriterLocked
        self.developWriterHolder = developWriterHolder
        self.activeFileScopes = activeFileScopes
        self.activeXcodebuildScopes = activeXcodebuildScopes
        self.commitLocked = commitLocked
        self.modelMemoryLocked = modelMemoryLocked
    }

    @MainActor
    public static func capture(from locks: SUPRATransmissionLocks) -> SUPRATransmissionLocksSnapshot {
        SUPRATransmissionLocksSnapshot(
            developWriterLocked: locks.developWriterLock,
            developWriterHolder: locks.holder(of: .developWriter),
            activeFileScopes: locks.fileScopeLocks.filter(\.value).keys.sorted(),
            activeXcodebuildScopes: locks.xcodebuildLocks.filter(\.value).keys.sorted(),
            commitLocked: locks.commitLock,
            modelMemoryLocked: locks.modelMemoryLock
        )
    }
}
