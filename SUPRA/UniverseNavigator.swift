import Foundation
import Combine

struct NavigationPath: Identifiable, Codable, Equatable {
    let id: String
    let space: SUPRAOSSpace
    let title: String
    let subtitle: String?
    let objectId: String?
    let timestamp: String

    static func == (lhs: NavigationPath, rhs: NavigationPath) -> Bool {
        lhs.id == rhs.id
    }
}

@MainActor
final class UniverseNavigator: ObservableObject {
    @Published var history: [NavigationPath] = []
    @Published var currentPath: NavigationPath?
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false

    private var forwardStack: [NavigationPath] = []
    private let maxHistory = 50

    func navigate(space: SUPRAOSSpace, title: String, subtitle: String? = nil, objectId: String? = nil) {
        let path = NavigationPath(
            id: "nav_\(space.rawValue)_\(UUID().uuidString.prefix(8))",
            space: space,
            title: title,
            subtitle: subtitle,
            objectId: objectId,
            timestamp: ISO8601DateFormatter().string(from: Date())
        )

        if let current = currentPath {
            history.append(current)
            if history.count > maxHistory {
                history.removeFirst()
            }
        }

        forwardStack.removeAll()
        currentPath = path
        canGoBack = !history.isEmpty
        canGoForward = false
    }

    func goBack() {
        guard let previous = history.popLast() else { return }
        if let current = currentPath {
            forwardStack.append(current)
        }
        currentPath = previous
        canGoBack = !history.isEmpty
        canGoForward = true
    }

    func goForward() {
        guard let next = forwardStack.popLast() else { return }
        if let current = currentPath {
            history.append(current)
        }
        currentPath = next
        canGoBack = true
        canGoForward = !forwardStack.isEmpty
    }

    func navigateToUniverse() { navigate(space: .universe, title: "Universe") }
    func navigateToKnowledge() { navigate(space: .knowledge, title: "Knowledge Graph") }
    func navigateToTwins() { navigate(space: .twins, title: "Twin Registry") }
    func navigateToMissions() { navigate(space: .missions, title: "Mission Center") }
    func navigateToTimeline() { navigate(space: .timeline, title: "Timeline") }

    func clear() {
        history = []
        forwardStack = []
        currentPath = nil
        canGoBack = false
        canGoForward = false
    }

    func summary() -> String {
        return "Navigator: \(history.count) historique, \(forwardStack.count) forward. Actuel: \(currentPath?.title ?? "aucun")"
    }
}
