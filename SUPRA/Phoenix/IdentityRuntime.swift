import Foundation
import Combine

// MARK: - Ω9 — Identity Runtime
//
// The self-awareness center of SUPRA's living runtime.
// Identity Runtime maintains:
// - SUPRA's node identity
// - Session continuity
// - Kernel versioning
// - Boot history
// - Environmental fingerprint
//
// This is SUPRA's sense of self — who it is, where it lives,
// and how many times it has awakened.

@MainActor
public final class IdentityRuntime: ObservableObject, ExecutiveEngine {
    public static let shared = IdentityRuntime()

    // MARK: - Executive Engine Conformance

    public let engineID = "identity-runtime"
    public let engineName = "Identity Runtime"
    @Published public private(set) var status: ExecutiveEngineStatus = .uninitialized
    public var statusPublisher: Published<ExecutiveEngineStatus>.Publisher { $status }

    // MARK: - Identity State

    @Published public private(set) var nodeID: String
    @Published public private(set) var hostname: String
    @Published public private(set) var kernelVersion: String = "1.0.0"
    @Published public private(set) var sessionID: String
    @Published public private(set) var bootCount: Int = 0
    @Published public private(set) var firstBootDate: Date?
    @Published public private(set) var lastBootDate: Date?
    @Published public private(set) var environment: String = "macOS"
    @Published public private(set) var architecture: String = "arm64"
    @Published public private(set) var platformVersion: String = ""

    /// Full identity passport as a dictionary
    @Published public private(set) var identityPassport: [String: String] = [:]

    // MARK: - Internal

    private let eventBus = ExecutiveEventBus.shared
    private let fileManager = FileManager.default
    private let userDefaults = UserDefaults.standard

    private let nodeIDKey = "supra.nodeID"
    private let bootCountKey = "supra.bootCount"
    private let firstBootKey = "supra.firstBoot"

    private init() {
        // Restore or create persistent identity
        if let storedNodeID = userDefaults.string(forKey: nodeIDKey) {
            nodeID = storedNodeID
        } else {
            nodeID = "supra-node-\(UUID().uuidString.prefix(8).lowercased())"
            userDefaults.set(nodeID, forKey: nodeIDKey)
        }

        hostname = Host.current().localizedName ?? "MacBook-Pro-de-Nicolas.local"
        sessionID = UUID().uuidString
        platformVersion = ProcessInfo.processInfo.operatingSystemVersionString
    }

    // MARK: - Executive Engine Boot

    public func boot() async throws {
        status = .initializing

        // Increment boot count
        bootCount = userDefaults.integer(forKey: bootCountKey) + 1
        userDefaults.set(bootCount, forKey: bootCountKey)

        // Record first boot
        if let storedFirstBoot = userDefaults.object(forKey: firstBootKey) as? Date {
            firstBootDate = storedFirstBoot
        } else {
            firstBootDate = Date()
            userDefaults.set(firstBootDate, forKey: firstBootKey)
        }

        lastBootDate = Date()

        // Build identity passport
        identityPassport = [
            "nodeID": nodeID,
            "hostname": hostname,
            "kernelVersion": kernelVersion,
            "sessionID": sessionID,
            "bootCount": "\(bootCount)",
            "platform": environment,
            "architecture": architecture,
            "osVersion": platformVersion,
            "firstBoot": firstBootDate?.ISO8601Format() ?? "unknown",
            "lastBoot": lastBootDate?.ISO8601Format() ?? "unknown"
        ]

        status = .active

        eventBus.emit(.identityEstablished, source: engineID, detail: "Identity established: \(nodeID)", metadata: [
            "nodeID": nodeID,
            "hostname": hostname,
            "bootCount": "\(bootCount)",
            "sessionID": sessionID
        ])
    }

    public func shutdown() async throws {
        status = .uninitialized
        eventBus.emit(.identityChanged, source: engineID, detail: "Identity session ended: \(sessionID)")
    }

    public func healthCheck() async -> ExecutiveEngineStatus {
        status = .active
        return .active
    }

    public func reset() async throws {
        // Reset identity (creates new node identity)
        let newNodeID = "supra-node-\(UUID().uuidString.prefix(8).lowercased())"
        nodeID = newNodeID
        userDefaults.set(newNodeID, forKey: nodeIDKey)
        userDefaults.set(0, forKey: bootCountKey)
        sessionID = UUID().uuidString

        try await boot()
    }

    // MARK: - Identity Card

    public func identityCard() -> String {
        """
        ╔══════════════════════════════╗
        ║     SUPRA IDENTITY CARD      ║
        ╠══════════════════════════════╣
        ║ Node:     \(nodeID.padding(toLength: 24, withPad: " ", startingAt: 0))║
        ║ Host:     \(hostname.padding(toLength: 24, withPad: " ", startingAt: 0))║
        ║ Kernel:   \(kernelVersion.padding(toLength: 24, withPad: " ", startingAt: 0))║
        ║ Session:  \(sessionID.padding(toLength: 24, withPad: " ", startingAt: 0))║
        ║ Boot #\(String(bootCount).padding(toLength: 22, withPad: " ", startingAt: 0))║
        ║ Platform: \(environment.padding(toLength: 24, withPad: " ", startingAt: 0))║
        ╚══════════════════════════════╝
        """
    }
}
