import Foundation
import Combine
import os

public enum SUPRAPipelineStage: String, Codable, Sendable, CaseIterable {
    case boot = "BOOT"
    case root = "ROOT"
    case discovery = "DISCOVERY"
    case artifact = "ARTIFACT"
    case manifest = "MANIFEST"
    case index = "INDEX"
    case validation = "VALIDATION"
    case snapshot = "SNAPSHOT"
    case dashboard = "DASHBOARD"
    case performance = "PERFORMANCE"
    case mission = "MISSION"
    case capability = "CAPABILITY"
    case provider = "PROVIDER"
    case executor = "EXECUTOR"
    case model = "MODEL"
    case decision = "DECISION"
    case memory = "MEMORY"
    case ui = "UI"
    case response = "RESPONSE"
    case error = "ERROR"

    var osLogCategory: String {
        switch self {
        case .boot: "Boot"
        case .root: "Root"
        case .discovery: "Discovery"
        case .artifact: "Artifact"
        case .manifest: "Manifest"
        case .index: "Index"
        case .validation: "Validation"
        case .snapshot: "Snapshot"
        case .dashboard: "Dashboard"
        case .performance: "Performance"
        case .mission: "Mission"
        case .capability: "Capability"
        case .provider: "Provider"
        case .executor: "Executor"
        case .model: "Model"
        case .decision: "Decision"
        case .memory: "Memory"
        case .ui: "UI"
        case .response: "Response"
        case .error: "Error"
        }
    }
}

public struct SUPRAEvent: Identifiable, Sendable {
    public let id: UUID
    public let stage: SUPRAPipelineStage
    public let message: String
    public let timestamp: Date
    public let durationMs: Int?

    public init(stage: SUPRAPipelineStage, message: String,
                durationMs: Int? = nil, timestamp: Date = Date()) {
        self.id = UUID()
        self.stage = stage
        self.message = message
        self.timestamp = timestamp
        self.durationMs = durationMs
    }
}

@MainActor
public final class SUPRARuntimeLogger: ObservableObject {
    public static let shared = SUPRARuntimeLogger()

    @Published public private(set) var events: [SUPRAEvent] = []
    @Published public private(set) var isLoggingEnabled = true

    private let maxEvents = 1000
    private var lastTimestamp: Date = .init()

    private static let subsystem = "com.novaera.supra.runtime"
    private static let baseCategory = "Runtime"
    private var loggers: [SUPRAPipelineStage: Logger] = [:]

    private init() {
        for stage in SUPRAPipelineStage.allCases {
            loggers[stage] = Logger(
                subsystem: Self.subsystem,
                category: "\(Self.baseCategory).\(stage.osLogCategory)"
            )
        }
    }

    public func log(_ stage: SUPRAPipelineStage, _ message: @autoclosure () -> String) {
        guard isLoggingEnabled else { return }

        let now = Date()
        let duration = lastTimestamp.distance(to: now) > 0
            ? Int(lastTimestamp.distance(to: now) * 1000)
            : nil
        let msg = message()

        let event = SUPRAEvent(stage: stage, message: msg,
                               durationMs: duration, timestamp: now)
        events.append(event)
        lastTimestamp = now

        if events.count > maxEvents {
            events = Array(events.suffix(maxEvents / 2))
        }

        if let osLogger = loggers[stage] {
            osLogger.info("\(msg, privacy: .public)")
        }
    }

    public func events(for stage: SUPRAPipelineStage) -> [SUPRAEvent] {
        events.filter { $0.stage == stage }
    }

    public func lastEvent(for stage: SUPRAPipelineStage) -> SUPRAEvent? {
        events.last { $0.stage == stage }
    }

    public func clear() {
        events = []
        lastTimestamp = Date()
    }

    public func summary() -> String {
        let stageCounts = Dictionary(grouping: events, by: \.stage).mapValues(\.count)
        let stages = stageCounts.sorted { $0.key.rawValue < $1.key.rawValue }
            .map { "\($0.key.rawValue): \($0.value)" }
            .joined(separator: ", ")
        return "Pipeline: \(events.count) événements [\(stages)]"
    }
}
