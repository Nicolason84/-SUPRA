import SwiftUI

// MARK: - Executive Space Enum

enum ExecutiveSpace: String, CaseIterable, Identifiable {
    case cockpit = "Cockpit"
    case workflows = "Workflows"
    case missions = "Mission Center"
    case knowledge = "Knowledge Center"
    case discovery = "Discovery Center"
    case decisions = "Decision Center"
    case workspace = "Workspace"
    case runtime = "Runtime"
    case settings = "Settings"

    var id: Self { self }

    var icon: String {
        switch self {
        case .cockpit: return "square.grid.2x2.fill"
        case .workflows: return "square.grid.2x2.fill"
        case .missions: return "flag.fill"
        case .knowledge: return "brain.head.profile.fill"
        case .discovery: return "sparkles"
        case .decisions: return "checkmark.seal.fill"
        case .workspace: return "folder.fill"
        case .runtime: return "waveform.path.ecg"
        case .settings: return "gearshape.fill"
        }
    }

    var keyboardShortcut: String {
        switch self {
        case .cockpit: return "1"
        case .workflows: return "2"
        case .missions: return "3"
        case .knowledge: return "4"
        case .discovery: return "5"
        case .decisions: return "6"
        case .workspace: return "7"
        case .runtime: return "8"
        case .settings: return "9"
        }
    }

    /// Grouping for sidebar hierarchy
    var group: String {
        switch self {
        case .cockpit, .runtime: return "MONITOR"
        case .missions, .decisions, .workflows: return "WORK"
        case .knowledge, .discovery, .workspace: return "EXPLORE"
        case .settings: return "SYSTEM"
        }
    }

    /// Recents ranking for sidebar
    var recentsRank: Int {
        switch self {
        case .cockpit: return 0
        case .missions: return 1
        case .decisions: return 2
        case .workflows: return 3
        case .knowledge: return 4
        case .discovery: return 5
        case .workspace: return 6
        case .runtime: return 7
        case .settings: return 8
        }
    }
}

// MARK: - Executive Window

struct ExecutiveWindow: View {
    @State private var destination: ExecutiveSpace = .cockpit
    @State private var commandPalettePresented = false
    @State private var inspectorPresented = true
    @State private var notificationPresented = false
    @State private var query = ""
    @State private var sidebarHovered: ExecutiveSpace?
    @State private var previousDestination: ExecutiveSpace = .cockpit

    var body: some View {
        VStack(spacing: 0) {
            ExecutiveHeader(
                destination: destination,
                inspectorPresented: $inspectorPresented,
                commandPalettePresented: $commandPalettePresented,
                notificationPresented: $notificationPresented
            )
            Divider().overlay(Color.supraBorder)

            HStack(spacing: 0) {
                ExecutiveSidebar(
                    selection: $destination,
                    hoveredItem: $sidebarHovered
                )
                Divider().overlay(Color.supraBorder)

                ExecutiveWorkspace(destination: destination)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .trailing)),
                        removal: .opacity
                    ))

                if inspectorPresented {
                    Divider().overlay(Color.supraBorder)
                    ExecutiveInspector(destination: destination)
                        .frame(width: SUPRAOSDesignSystem.inspectorWidth)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }

            Divider().overlay(Color.supraBorder)
            ExecutiveStatusBar()
        }
        .background(Color.supraBackground)
        .withSUPRAFeedback()
        .overlay {
            if commandPalettePresented {
                CommandPalette(
                    query: $query,
                    isPresented: $commandPalettePresented,
                    selection: $destination
                )
                .transition(.opacity.combined(with: .scale(scale: 0.97)))
            }
        }
        .overlay(alignment: .topTrailing) {
            if notificationPresented {
                ExecutiveNotifications(isPresented: $notificationPresented)
                    .padding(.top, SUPRAOSDesignSystem.headerHeight + SUPRAOSDesignSystem.spacingSmall)
                    .padding(.trailing, SUPRAOSDesignSystem.spacingSmall)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(SUPRAOSDesignSystem.Motion.transition, value: destination)
        .animation(.easeOut(duration: 0.25), value: inspectorPresented)
        .animation(.easeOut(duration: 0.2), value: commandPalettePresented)
        .animation(.easeOut(duration: 0.2), value: notificationPresented)
        .accessibilityElement(children: .contain)
        // Keyboard navigation
        .onAppear {
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                handleKeyEvent(event)
                return event
            }
            setupNotificationHandlers()
        }
    }

    private func setupNotificationHandlers() {
        NotificationCenter.default.addObserver(forName: .supraNavigate, object: nil, queue: .main) { notification in
            if let spaceName = notification.object as? String,
               let space = ExecutiveSpace.allCases.first(where: { $0.rawValue == spaceName }) {
                withAnimation(SUPRAOSDesignSystem.Motion.transition) {
                    previousDestination = destination
                    destination = space
                }
            }
        }
        NotificationCenter.default.addObserver(forName: .supraNavigateBack, object: nil, queue: .main) { _ in
            withAnimation(SUPRAOSDesignSystem.Motion.transition) {
                let temp = destination
                destination = previousDestination
                previousDestination = temp
            }
        }
        NotificationCenter.default.addObserver(forName: .supraToggleInspector, object: nil, queue: .main) { _ in
            withAnimation(.easeOut(duration: 0.25)) {
                inspectorPresented.toggle()
            }
        }
        NotificationCenter.default.addObserver(forName: .supraRefresh, object: nil, queue: .main) { _ in
            // Force re-render of current space
            withAnimation(SUPRAOSDesignSystem.Motion.reveal) {
                let current = destination
                destination = destination // triggers refresh via onChange
            }
        }
        NotificationCenter.default.addObserver(forName: .supraSearch, object: nil, queue: .main) { _ in
            commandPalettePresented = true
        }
        NotificationCenter.default.addObserver(forName: .supraToggleSidebar, object: nil, queue: .main) { _ in
            // Post to sidebar toggle — handled internally
        }
    }

    private func handleKeyEvent(_ event: NSEvent) {
        // We handle keyboard shortcuts via .keyboardShortcut modifiers
        // This is a fallback for additional keyboard navigation
        if event.keyCode == 53 { // Escape
            if commandPalettePresented {
                withAnimation(.easeOut(duration: 0.15)) {
                    commandPalettePresented = false
                }
            }
            if notificationPresented {
                withAnimation(.easeOut(duration: 0.15)) {
                    notificationPresented = false
                }
            }
        }
    }
}

// MARK: - Executive Header

struct ExecutiveHeader: View {
    let destination: ExecutiveSpace
    @Binding var inspectorPresented: Bool
    @Binding var commandPalettePresented: Bool
    @Binding var notificationPresented: Bool

    var body: some View {
        HStack(spacing: SUPRAOSDesignSystem.spacingSmall) {
            // Logo
            HStack(spacing: 10) {
                Image(systemName: "hexagon.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.supraAccent)
                VStack(alignment: .leading, spacing: 1) {
                    Text("SUPRA EXECUTIVE OS")
                        .font(SUPRAOSDesignSystem.Fonts.label)
                        .tracking(1.4)
                        .foregroundStyle(Color.supraText)
                    Text(destination.rawValue)
                        .font(SUPRAOSDesignSystem.Fonts.caption)
                        .foregroundStyle(Color.supraTextSecondary)
                }
            }

            Spacer()

            // Badges
            HStack(spacing: 6) {
                SUPRAOSBadge(text: "V5.1.0", color: .supraAccent)
                SUPRAOSBadge(text: "OPERATIONAL", color: .supraGreen)
            }

            Spacer().frame(width: 16)

            // Actions
            HStack(spacing: 4) {
                Button { commandPalettePresented = true } label: {
                    Label("Command", systemImage: "command")
                        .font(.system(size: 12))
                }
                .buttonStyle(.borderless)
                .foregroundStyle(Color.supraTextSecondary)
                .help("Command Palette (⌘K)")

                Button { notificationPresented.toggle() } label: {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 12))
                }
                .buttonStyle(.borderless)
                .foregroundStyle(Color.supraTextSecondary)
                .help("Notifications")

                Button { inspectorPresented.toggle() } label: {
                    Image(systemName: "sidebar.trailing")
                        .font(.system(size: 12))
                }
                .buttonStyle(.borderless)
                .foregroundStyle(inspectorPresented ? Color.supraAccent : Color.supraTextSecondary)
                .help("Toggle Inspector (⌘I)")
                .keyboardShortcut("i", modifiers: [.command])
            }
        }
        .padding(.horizontal, SUPRAOSDesignSystem.paddingSmall)
        .frame(height: SUPRAOSDesignSystem.headerHeight)
        .background(Color.supraSurface)
    }
}

// MARK: - Executive Sidebar

struct ExecutiveSidebar: View {
    @Binding var selection: ExecutiveSpace
    @Binding var hoveredItem: ExecutiveSpace?
    @State private var isCollapsed = false
    @AppStorage("sidebarRecents") private var recentsData: Data = Data()
    @State private var recents: [ExecutiveSpace] = []

    private let groups: [(String, [ExecutiveSpace])] = [
        ("MONITOR", [.cockpit, .runtime]),
        ("WORK", [.missions, .decisions, .workflows]),
        ("EXPLORE", [.knowledge, .discovery, .workspace]),
        ("SYSTEM", [.settings])
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacingMini) {
            // Recents section (if any)
            if !recents.isEmpty && !isCollapsed {
                Text("RECENTS")
                    .font(SUPRAOSDesignSystem.Fonts.caption)
                    .tracking(1.4)
                    .foregroundStyle(Color.supraTextTertiary)
                    .padding(.horizontal, SUPRAOSDesignSystem.paddingSmall)
                    .padding(.top, SUPRAOSDesignSystem.paddingSmall)

                ForEach(recents) { item in
                    SidebarItem(
                        item: item,
                        isSelected: selection == item,
                        isHovered: hoveredItem == item,
                        isCollapsed: isCollapsed
                    )
                    .onTapGesture { selectItem(item) }
                    .onHover { hovering in
                        withAnimation(.easeOut(duration: 0.12)) {
                            hoveredItem = hovering ? item : nil
                        }
                    }
                    .keyboardShortcut(KeyEquivalent(Character(item.keyboardShortcut)), modifiers: [.command])
                    .help("\(item.rawValue) (⌘\(item.keyboardShortcut))")
                }

                Divider().overlay(Color.supraBorder)
                    .padding(.horizontal, SUPRAOSDesignSystem.paddingSmall)
                    .padding(.vertical, 2)
            }

            // Grouped navigation
            ForEach(groups, id: \.0) { groupName, items in
                if !isCollapsed {
                    Text(groupName)
                        .font(SUPRAOSDesignSystem.Fonts.caption)
                        .tracking(1.4)
                        .foregroundStyle(Color.supraTextTertiary)
                        .padding(.horizontal, SUPRAOSDesignSystem.paddingSmall)
                        .padding(.top, groupName == "MONITOR" ? SUPRAOSDesignSystem.paddingSmall : 0)
                }

                ForEach(items) { item in
                    SidebarItem(
                        item: item,
                        isSelected: selection == item,
                        isHovered: hoveredItem == item,
                        isCollapsed: isCollapsed
                    )
                    .onTapGesture { selectItem(item) }
                    .onHover { hovering in
                        withAnimation(.easeOut(duration: 0.12)) {
                            hoveredItem = hovering ? item : nil
                        }
                    }
                    .keyboardShortcut(KeyEquivalent(Character(item.keyboardShortcut)), modifiers: [.command])
                    .help("\(item.rawValue) (⌘\(item.keyboardShortcut))")
                    .contextMenu {
                        Button("Navigate to \(item.rawValue)") { selectItem(item) }
                        Button("Copy Name") { NSPasteboard.general.setString(item.rawValue, forType: .string) }
                        Divider()
                        Button("⌘\(item.keyboardShortcut)") {}
                    }
                }
            }

            Spacer()

            // Collapse toggle
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                    isCollapsed.toggle()
                }
            } label: {
                Image(systemName: isCollapsed ? "sidebar.right" : "sidebar.left")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.supraTextTertiary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 28)
            }
            .buttonStyle(.plain)
            .help("Toggle Sidebar")
            .accessibilityLabel("Toggle sidebar")
        }
        .padding(.horizontal, SUPRAOSDesignSystem.spacingTiny)
        .frame(width: isCollapsed ? SUPRAOSDesignSystem.sidebarCompactWidth : SUPRAOSDesignSystem.sidebarWidth)
        .background(Color.supraSurface)
        .animation(.spring(response: 0.3, dampingFraction: 0.85), value: isCollapsed)
        .onAppear { loadRecents() }
        .onChange(of: selection) { _, newValue in addToRecents(newValue) }
    }

    private func selectItem(_ item: ExecutiveSpace) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            selection = item
        }
        addToRecents(item)
    }

    private func addToRecents(_ item: ExecutiveSpace) {
        recents.removeAll { $0 == item }
        recents.insert(item, at: 0)
        if recents.count > 3 { recents = Array(recents.prefix(3)) }
        saveRecents()
    }

    private func loadRecents() {
        guard let decoded = try? JSONDecoder().decode([String].self, from: recentsData) else { return }
        recents = decoded.compactMap { name in ExecutiveSpace.allCases.first { $0.rawValue == name } }
    }

    private func saveRecents() {
        recentsData = (try? JSONEncoder().encode(recents.map(\.rawValue))) ?? Data()
    }
}

// MARK: - Sidebar Item

struct SidebarItem: View {
    let item: ExecutiveSpace
    let isSelected: Bool
    let isHovered: Bool
    let isCollapsed: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Icon with active indicator
            ZStack {
                if isSelected {
                    Circle()
                        .fill(Color.supraAccent)
                        .frame(width: 6, height: 6)
                        .offset(x: -8)
                }
                Image(systemName: item.icon)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                    .frame(width: 20)
            }

            if !isCollapsed {
                Text(item.rawValue)
                    .font(SUPRAOSDesignSystem.Fonts.body)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .lineLimit(1)

                Spacer()

                // Keyboard shortcut hint
                Text("⌘\(item.keyboardShortcut)")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.supraTextQuaternary)
            }
        }
        .padding(.horizontal, SUPRAOSDesignSystem.paddingSmall)
        .frame(height: SUPRAOSDesignSystem.navigationRowHeight)
        .background(
            ZStack {
                if isSelected {
                    RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall)
                        .fill(Color.supraAccent.opacity(0.14))
                } else if isHovered {
                    RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall)
                        .fill(Color.supraText.opacity(0.05))
                }
            }
        )
        .foregroundStyle(isSelected ? Color.supraAccent : Color.supraTextSecondary)
        .contentShape(Rectangle())
        .accessibilityLabel(item.rawValue)
        .accessibilityHint("Navigate to \(item.rawValue). Shortcut: ⌘\(item.keyboardShortcut)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Executive Workspace

struct ExecutiveWorkspace: View {
    let destination: ExecutiveSpace
    @EnvironmentObject private var runtime: RuntimeDataService

    @ViewBuilder
    var body: some View {
        Group {
            switch destination {
            case .cockpit: ExecutiveCockpit()
            case .workflows: ExecutiveWorkflowListView()
            case .missions: MissionCenterView()
            case .knowledge: ConversationTwinView()
            case .discovery: SUPRAEnvironmentCommandCenterView()
            case .decisions: SUPRADecisionRoomView()
            case .workspace: SUPRAOSWorkspaceExplorerView()
            case .runtime: RuntimeDiagnosticsView()
            case .settings: SettingsView(service: runtime)
            }
        }
        .id(destination)
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .move(edge: .trailing)),
            removal: .opacity.combined(with: .move(edge: .leading))
        ))
    }
}

// MARK: - Executive Cockpit

struct ExecutiveCockpit: View {
    @EnvironmentObject private var runtime: RuntimeDataService
    @StateObject private var environment = SUPRAEnvironmentWorldModel.shared
    @StateObject private var recommendations = SUPRARecommendationEngine.shared
    @StateObject private var evolution = SUPRAEvolutionEngine.shared
    @StateObject private var conversations = ConversationMemoryStore.shared
    @EnvironmentObject private var missionStore: MissionStore
    @EnvironmentObject private var decisionStore: DecisionStore

    @State private var isLoading = true
    @State private var loadedItems = 0

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacing) {
                cockpitHeader
                kpiGrid
                HStack(alignment: .top, spacing: SUPRAOSDesignSystem.spacingSmall) {
                    executiveHealth
                    missionCenter
                }
                HStack(alignment: .top, spacing: SUPRAOSDesignSystem.spacingSmall) {
                    knowledgeCenter
                    discoveryCenter
                    decisionCenter
                }
                integrationsSection
                dashboardSection
                healthSection
                executiveAlerts
                timeline
            }
            .padding(SUPRAOSDesignSystem.padding)
            .frame(maxWidth: SUPRAOSDesignSystem.workspaceMaxWidth)
            .frame(maxWidth: .infinity)
        }
        .background(Color.supraBackground)
        .task {
            // Progressive loading simulation
            isLoading = true
            loadedItems = 0

            missionStore.load()
            withAnimation(.easeOut(duration: 0.3)) { loadedItems = 1 }

            decisionStore.load()
            withAnimation(.easeOut(duration: 0.3).delay(0.1)) { loadedItems = 2 }

            runtime.load()
            withAnimation(.easeOut(duration: 0.3).delay(0.2)) { loadedItems = 3 }

            runtime.refreshSystemMetrics()
            withAnimation(.easeOut(duration: 0.3).delay(0.3)) {
                isLoading = false
                loadedItems = 4
            }
        }
    }

    private var cockpitHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacingTiny) {
                Text("EXECUTIVE COCKPIT")
                    .font(SUPRAOSDesignSystem.Fonts.label)
                    .tracking(1.8)
                    .foregroundStyle(Color.supraAccent)
                Text("System state, decisions and execution at a glance")
                    .font(SUPRAOSDesignSystem.Fonts.title)
                    .foregroundStyle(Color.supraText)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text("Runtime → UI")
                    .font(SUPRAOSDesignSystem.Fonts.caption)
                    .foregroundStyle(Color.supraTextTertiary)
                HStack(spacing: 6) {
                    Circle()
                        .fill(runtime.runtimeMetrics == nil ? Color.supraOrange : Color.supraGreen)
                        .frame(width: 6, height: 6)
                    Text(runtime.runtimeMetrics == nil ? "WAITING FOR DATA" : "LIVE · PUBLISHED")
                        .font(SUPRAOSDesignSystem.Fonts.label)
                        .foregroundStyle(runtime.runtimeMetrics == nil ? Color.supraOrange : Color.supraGreen)
                }
            }
        }
        .fadeIn(delay: 0.0)
    }

    private var kpiGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 145), spacing: SUPRAOSDesignSystem.spacingSmall)], spacing: SUPRAOSDesignSystem.spacingSmall) {
            kpiCard(label: "Missions", value: "\(missionStore.missions.count)", icon: "flag.fill", color: .supraAccent)
            kpiCard(label: "Decisions", value: "\(decisionStore.decisions.count)", icon: "checkmark.seal.fill", color: .supraOrange)
            kpiCard(label: "Knowledge", value: "\(conversations.conversations.count)", icon: "brain.head.profile.fill", color: .supraTeal)
            kpiCard(label: "Discoveries", value: "\(recommendations.active.count)", icon: "sparkles", color: .supraPurple)
            kpiCard(label: "Health", value: environment.state == nil ? "SYNC" : "READY", icon: "heart.text.square.fill", color: .supraGreen)
            kpiCard(label: "Alerts", value: "\(alertCount)", icon: "exclamationmark.triangle.fill", color: alertCount == 0 ? .supraGreen : .supraRed)
        }
        .skeleton(isLoading: isLoading, shape: .rounded(12))
    }

    private func kpiCard(label: String, value: String, icon: String, color: Color) -> some View {
        SUPRAOSStatCard(label: label, value: value, icon: icon, color: color)
            .fadeIn(delay: 0.1)
    }

    private var executiveHealth: some View {
        ExecutivePanel(title: "Executive Health", icon: "heart.text.square.fill", color: .supraGreen) {
            VStack(spacing: SUPRAOSDesignSystem.spacingTiny) {
                healthRow("Runtime", runtime.runtimeMetrics == nil ? "Standby" : "Active", runtime.runtimeMetrics == nil ? .supraOrange : .supraGreen)
                healthRow("Environment", environment.state == nil ? "Synchronizing" : "Operational", environment.state == nil ? .supraOrange : .supraGreen)
                healthRow("Evolution", "\(evolution.proposals.count) proposals", .supraAccent)
            }
        }
        .frame(maxWidth: .infinity)
        .fadeIn(delay: 0.15)
    }

    private var missionCenter: some View {
        ExecutivePanel(title: "Mission Center", icon: "flag.fill", color: .supraAccent) {
            compactRows(
                missionStore.missions.prefix(3).map { ($0.title, $0.status.rawValue) },
                empty: "No active mission"
            )
        }
        .frame(maxWidth: .infinity)
        .fadeIn(delay: 0.2)
    }

    private var knowledgeCenter: some View {
        ExecutivePanel(title: "Knowledge Center", icon: "brain.head.profile.fill", color: .supraTeal) {
            metric("\(conversations.conversations.count)", "canonical conversations")
        }
        .frame(maxWidth: .infinity)
        .fadeIn(delay: 0.25)
    }

    private var discoveryCenter: some View {
        ExecutivePanel(title: "Discovery Center", icon: "sparkles", color: .supraPurple) {
            metric("\(recommendations.active.count)", "active opportunities")
        }
        .frame(maxWidth: .infinity)
        .fadeIn(delay: 0.3)
    }

    private var decisionCenter: some View {
        ExecutivePanel(title: "Decision Center", icon: "checkmark.seal.fill", color: .supraOrange) {
            metric("\(decisionStore.decisions.count)", "traceable decisions")
        }
        .frame(maxWidth: .infinity)
        .fadeIn(delay: 0.35)
    }

    private var executiveAlerts: some View {
        ExecutivePanel(title: "Executive Alerts", icon: "exclamationmark.triangle.fill", color: alertCount == 0 ? .supraGreen : .supraRed) {
            if alertCount == 0 {
                Label("No critical alert. Executive systems are within operating bounds.", systemImage: "checkmark.circle.fill")
                    .font(SUPRAOSDesignSystem.Fonts.body)
                    .foregroundStyle(Color.supraGreen)
            } else {
                compactRows(alerts, empty: "")
            }
        }
        .fadeIn(delay: 0.4)
    }

    private var timeline: some View {
        ExecutivePanel(title: "Timeline", icon: "clock.fill", color: .supraBlue) {
            compactRows(
                missionStore.missions.prefix(4).map { ($0.title, $0.currentStatus) },
                empty: "Runtime timeline is ready"
            )
        }
        .fadeIn(delay: 0.45)
    }

    private var alerts: [(String, String)] {
        var rows: [(String, String)] = []
        if runtime.runtimeMetrics == nil { rows.append(("Runtime metrics", "Awaiting publication")) }
        rows.append(contentsOf: recommendations.humanRequired.prefix(2).map { ($0.problem, "Human decision") })
        return rows
    }

    private var alertCount: Int { alerts.count }

    private func healthRow(_ title: String, _ value: String, _ color: Color) -> some View {
        HStack {
            Circle().fill(color).frame(width: 7, height: 7)
            Text(title).foregroundStyle(Color.supraText)
            Spacer()
            Text(value).foregroundStyle(Color.supraTextSecondary)
        }
        .font(SUPRAOSDesignSystem.Fonts.body)
    }

    private func metric(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value).font(SUPRAOSDesignSystem.Fonts.metric).foregroundStyle(Color.supraText)
            Text(label).font(SUPRAOSDesignSystem.Fonts.caption).foregroundStyle(Color.supraTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func compactRows(_ rows: [(String, String)], empty: String) -> some View {
        VStack(spacing: SUPRAOSDesignSystem.spacingTiny) {
            if rows.isEmpty {
                Text(empty)
                    .font(SUPRAOSDesignSystem.Fonts.body)
                    .foregroundStyle(Color.supraTextTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                    HStack {
                        Text(row.0).lineLimit(1).foregroundStyle(Color.supraText)
                        Spacer()
                        Text(row.1).lineLimit(1).foregroundStyle(Color.supraTextTertiary)
                    }
                    .font(SUPRAOSDesignSystem.Fonts.caption)
                }
            }
        }
    }

    // MARK: - Integrations Section (G4)

    private var integrationsSection: some View {
        ExecutivePanel(title: "Integrations", icon: "point.3.connected.trianglepath.dotted", color: .supraAccent) {
            G4IntegrationView()
        }
        .fadeIn(delay: 0.38)
    }

    // MARK: - Dashboard Section (G1)

    private var dashboardSection: some View {
        ExecutivePanel(title: "Project Dashboard", icon: "square.grid.2x2", color: .supraBlue) {
            G1DashboardView()
        }
        .fadeIn(delay: 0.40)
    }

    // MARK: - Health Section (G2)

    private var healthSection: some View {
        ExecutivePanel(title: "Health Monitoring", icon: "heart.text.square.fill", color: .supraGreen) {
            HealthMonitorView()
        }
        .fadeIn(delay: 0.42)
    }
}

// MARK: - Executive Panel

struct ExecutivePanel<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let content: Content
    @State private var isHovered = false

    init(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacingSmall) {
            Label(title, systemImage: icon)
                .font(SUPRAOSDesignSystem.Fonts.section)
                .foregroundStyle(color)
                .accessibilityLabel("\(title) panel")
            content
            Spacer(minLength: 0)
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .frame(minHeight: SUPRAOSDesignSystem.compactPanelHeight, alignment: .topLeading)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(
            RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall)
                .stroke(isHovered ? Color.supraBorderLight : Color.supraBorder)
        )
        .scaleEffect(isHovered ? 1.015 : 1.0)
        .shadow(color: isHovered ? .black.opacity(0.15) : .clear, radius: 8, y: 3)
        .animation(.easeOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Executive Inspector

struct ExecutiveInspector: View {
    let destination: ExecutiveSpace
    @EnvironmentObject private var runtime: RuntimeDataService

    var body: some View {
        VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacingSmall) {
            // Header
            HStack {
                Text("INSPECTOR")
                    .font(SUPRAOSDesignSystem.Fonts.label)
                    .tracking(1.2)
                    .foregroundStyle(Color.supraTextTertiary)
                Spacer()
                Button {
                    // Close inspector — handled by parent binding
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.supraTextTertiary)
                }
                .buttonStyle(.plain)
                .help("Close Inspector")
            }

            Text(destination.rawValue)
                .font(SUPRAOSDesignSystem.Fonts.section)
                .foregroundStyle(Color.supraText)

            Divider().overlay(Color.supraBorder)

            // Content
            inspectorContent

            Spacer()

            // Footer
            VStack(spacing: 4) {
                Divider().overlay(Color.supraBorder)
                Text("Runtime → Store → View → Display")
                    .font(SUPRAOSDesignSystem.Fonts.caption)
                    .foregroundStyle(Color.supraTextTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
    }

    @ViewBuilder
    private var inspectorContent: some View {
        if runtime.runtimeMetrics == nil {
            // Loading state
            VStack(spacing: 16) {
                Spacer()
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 28))
                    .foregroundStyle(Color.supraTextTertiary)
                Text("Loading inspector data...")
                    .font(SUPRAOSDesignSystem.Fonts.body)
                    .foregroundStyle(Color.supraTextSecondary)
                Spacer()
            }
            .frame(maxWidth: .infinity)
        } else {
            // Content
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacingSmall) {
                    inspectorRow("Source", "Runtime")
                    inspectorRow("State", runtime.runtimeMetrics == nil ? "Standby" : "Published")
                    inspectorRow("Version", SUPRARuntimeRegistry.shared.runtimeVersion)
                    inspectorRow("Authority", "Executive")

                    Divider().overlay(Color.supraBorder)

                    // Contextual help
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CONTEXT")
                            .font(SUPRAOSDesignSystem.Fonts.caption)
                            .foregroundStyle(Color.supraTextTertiary)
                        Text(helpText(for: destination))
                            .font(SUPRAOSDesignSystem.Fonts.bodySmall)
                            .foregroundStyle(Color.supraTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    private func inspectorRow(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label.uppercased())
                .font(SUPRAOSDesignSystem.Fonts.caption)
                .foregroundStyle(Color.supraTextTertiary)
            Text(value)
                .font(SUPRAOSDesignSystem.Fonts.body)
                .foregroundStyle(Color.supraText)
        }
    }

    private func helpText(for space: ExecutiveSpace) -> String {
        switch space {
        case .cockpit: return "Overview of system state, key metrics, and active processes."
        case .workflows: return "Manage and monitor automated execution workflows."
        case .missions: return "Track active and past missions with full context."
        case .knowledge: return "Browse the canonical knowledge graph and conversations."
        case .discovery: return "Explore system capabilities and untapped potential."
        case .decisions: return "Review, validate, and trace executive decisions."
        case .workspace: return "Navigate the workspace structure and modules."
        case .runtime: return "Monitor runtime diagnostics and system health."
        case .settings: return "Configure runtime connections and preferences."
        }
    }
}

// MARK: - Executive Status Bar

struct ExecutiveStatusBar: View {
    @EnvironmentObject private var runtime: RuntimeDataService
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: SUPRAOSDesignSystem.spacingSmall) {
            // Runtime status
            HStack(spacing: 5) {
                Circle()
                    .fill(runtime.runtimeMetrics == nil ? Color.supraOrange : Color.supraGreen)
                    .frame(width: 6, height: 6)
                    .overlay(
                        Circle()
                            .stroke(runtime.runtimeMetrics == nil ? Color.supraOrange : Color.supraGreen, lineWidth: 2)
                            .scaleEffect(isHovered ? 1.6 : 1.0)
                            .opacity(isHovered ? 0.3 : 0)
                    )
                Text("Runtime \(runtime.runtimeMetrics == nil ? "standby" : "active")")
                    .font(SUPRAOSDesignSystem.Fonts.caption)
            }
            .foregroundStyle(runtime.runtimeMetrics == nil ? Color.supraOrange : Color.supraGreen)
            .onHover { hovering in
                withAnimation(.easeOut(duration: 0.2)) { isHovered = hovering }
            }
            .help("Runtime connection status")

            Text("·")
                .foregroundStyle(Color.supraTextTertiary)

            Label("Memory-first", systemImage: "memorychip.fill")
                .font(SUPRAOSDesignSystem.Fonts.caption)
                .foregroundStyle(Color.supraTextTertiary)

            Text("·")
                .foregroundStyle(Color.supraTextTertiary)

            Label("Executive Freeze V2", systemImage: "snowflake")
                .font(SUPRAOSDesignSystem.Fonts.caption)
                .foregroundStyle(Color.supraTextTertiary)

            Spacer()

            Text("SUPRA · Nicolas decides")
                .font(SUPRAOSDesignSystem.Fonts.caption)
                .foregroundStyle(Color.supraTextQuaternary)
        }
        .padding(.horizontal, SUPRAOSDesignSystem.paddingSmall)
        .frame(height: SUPRAOSDesignSystem.statusBarHeight)
        .background(Color.supraSurface)
    }
}

// MARK: - Command Palette

struct CommandPalette: View {
    @Binding var query: String
    @Binding var isPresented: Bool
    @Binding var selection: ExecutiveSpace

    private var results: [ExecutiveSpace] {
        query.isEmpty ? ExecutiveSpace.allCases : ExecutiveSpace.allCases.filter {
            $0.rawValue.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.15)) {
                        isPresented = false
                    }
                }

            VStack(spacing: 0) {
                // Search field
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.supraTextTertiary)
                    TextField("Search commands and executive spaces", text: $query)
                        .textFieldStyle(.plain)
                        .font(SUPRAOSDesignSystem.Fonts.body)
                        .foregroundStyle(Color.supraText)
                }
                .padding(SUPRAOSDesignSystem.paddingSmall)

                Divider().overlay(Color.supraBorder)

                // Results
                ScrollView {
                    VStack(spacing: 2) {
                        ForEach(results) { item in
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                    selection = item
                                    isPresented = false
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: item.icon)
                                        .font(.system(size: 14))
                                        .frame(width: 20)
                                    Text(item.rawValue)
                                        .font(SUPRAOSDesignSystem.Fonts.body)
                                    Spacer()
                                    Text("⌘\(item.keyboardShortcut)")
                                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                                        .foregroundStyle(Color.supraTextQuaternary)
                                }
                                .padding(.horizontal, SUPRAOSDesignSystem.paddingSmall)
                                .frame(height: 36)
                                .background(
                                    selection == item ?
                                        Color.supraAccent.opacity(0.1) : .clear,
                                    in: RoundedRectangle(cornerRadius: 6)
                                )
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(selection == item ? Color.supraAccent : Color.supraText)
                        }
                    }
                    .padding(SUPRAOSDesignSystem.spacingTiny)
                }
                .frame(maxHeight: 280)
            }
            .frame(width: SUPRAOSDesignSystem.commandPaletteWidth)
            .background(Color.supraSurface)
            .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadius)
                    .stroke(Color.supraBorder)
            )
            .shadow(color: SUPRAOSDesignSystem.Shadow.large.color,
                    radius: SUPRAOSDesignSystem.Shadow.large.blur,
                    x: SUPRAOSDesignSystem.Shadow.large.offset.width,
                    y: SUPRAOSDesignSystem.Shadow.large.offset.height)
        }
    }
}

// MARK: - Executive Notifications

struct ExecutiveNotifications: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacingSmall) {
            // Header
            HStack {
                Text("Notifications")
                    .font(SUPRAOSDesignSystem.Fonts.section)
                    .foregroundStyle(Color.supraText)
                Spacer()
                Button {
                    withAnimation(.easeOut(duration: 0.15)) {
                        isPresented = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.supraTextTertiary)
                }
                .buttonStyle(.plain)
            }

            // Content
            VStack(spacing: 8) {
                notificationRow(
                    icon: "checkmark.circle.fill",
                    message: "Executive Runtime is operational",
                    color: .supraGreen
                )
                Divider().overlay(Color.supraBorder)
                Label("All systems nominal. You're up to date.", systemImage: "checkmark.circle.fill")
                    .font(SUPRAOSDesignSystem.Fonts.caption)
                    .foregroundStyle(Color.supraGreen)
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .frame(width: SUPRAOSDesignSystem.notificationWidth)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(
            RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall)
                .stroke(Color.supraBorder)
        )
        .shadow(color: SUPRAOSDesignSystem.Shadow.medium.color,
                radius: SUPRAOSDesignSystem.Shadow.medium.blur,
                x: SUPRAOSDesignSystem.Shadow.medium.offset.width,
                y: SUPRAOSDesignSystem.Shadow.medium.offset.height)
    }

    private func notificationRow(icon: String, message: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
            Text(message)
                .font(SUPRAOSDesignSystem.Fonts.body)
                .foregroundStyle(Color.supraText)
            Spacer()
        }
    }
}
