import SwiftUI
import Combine

// MARK: - DashboardCoordinator

@MainActor
final class DashboardCoordinator: ObservableObject {
    @Published private(set) var activeSection: DashboardSection?
    @Published private(set) var isNavigationExpanded = true

    private let state: SUPRACommandCenterState

    init(state: SUPRACommandCenterState? = nil) {
        self.state = state ?? .shared
    }

    var isReady: Bool { state.isReady }

    var healthSection: CommandCenterSystemHealth? { state.healthSection }
    var runtimeSection: CommandCenterRuntime? { state.runtimeSection }
    var memorySection: CommandCenterCannonico? { state.cannonicoSection }
    var missionsSection: CommandCenterMissions? { state.missionsSection }
    var intelligenceSection: CommandCenterIntelligence? { state.intelligenceSection }
    var resourcesSection: CommandCenterResources? { state.resourcesSection }

    func navigateTo(_ section: DashboardSection) {
        withAnimation(SUPRAOSDesignSystem.Motion.focus) {
            activeSection = section
        }
    }

    func clearNavigation() {
        withAnimation(SUPRAOSDesignSystem.Motion.focus) {
            activeSection = nil
        }
    }

    func toggleNavigation() {
        withAnimation(SUPRAOSDesignSystem.Motion.feedback) {
            isNavigationExpanded.toggle()
        }
    }
}
