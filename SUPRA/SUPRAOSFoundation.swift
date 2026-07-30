import Foundation
import Combine

enum SUPRAOSSpace: String, Codable, CaseIterable, Identifiable {
    case universe, knowledge, twins, workspace, projects
    case companies, people, memory, timeline, evidence
    case missions, runtime, automation, analytics, explorer

    var id: String { rawValue }

    var label: String {
        switch self {
        case .universe: return "Universe"
        case .knowledge: return "Knowledge"
        case .twins: return "Twins"
        case .workspace: return "Workspace"
        case .projects: return "Projects"
        case .companies: return "Companies"
        case .people: return "People"
        case .memory: return "Memory"
        case .timeline: return "Timeline"
        case .evidence: return "Evidence"
        case .missions: return "Missions"
        case .runtime: return "Runtime"
        case .automation: return "Automation"
        case .analytics: return "Analytics"
        case .explorer: return "Explorer"
        }
    }

    var icon: String {
        switch self {
        case .universe: return "sparkle"
        case .knowledge: return "brain.head.profile"
        case .twins: return "person.2.fill"
        case .workspace: return "desktopcomputer"
        case .projects: return "folder"
        case .companies: return "building.2"
        case .people: return "person.3"
        case .memory: return "memorychip"
        case .timeline: return "clock"
        case .evidence: return "checkmark.shield"
        case .missions: return "flag"
        case .runtime: return "gear"
        case .automation: return "gearshape.2"
        case .analytics: return "chart.bar"
        case .explorer: return "magnifyingglass"
        }
    }
}

struct SUPRAOSConfig: Codable {
    let version: String
    let theme: String
    let animationsEnabled: Bool
    let liveUpdates: Bool
    let defaultSpace: SUPRAOSSpace
    let language: String
    let telemetry: Bool
}

@MainActor
final class SUPRAOSFoundation: ObservableObject {
    static let shared = SUPRAOSFoundation()

    @Published var activeSpace: SUPRAOSSpace = .universe
    @Published var config: SUPRAOSConfig
    @Published var isInitialized = false

    private let engine: UniverseEngine

    private init() {
        engine = .shared
        config = SUPRAOSConfig(
            version: "1.0.0",
            theme: "dark",
            animationsEnabled: true,
            liveUpdates: true,
            defaultSpace: .universe,
            language: "fr",
            telemetry: false
        )
    }

    func initialize() {
        engine.start()
        isInitialized = true
    }

    func navigate(to space: SUPRAOSSpace) {
        activeSpace = space
    }

    func updateConfig(_ newConfig: SUPRAOSConfig) {
        config = newConfig
    }

    func summary() -> String {
        """
        SUPRA OS \(config.version)
        Espace: \(activeSpace.label)
        Engine: \(engine.isRunning ? "actif" : "inactif")
        Thème: \(config.theme)
        Animations: \(config.animationsEnabled ? "activées" : "désactivées")
        """
    }
}
