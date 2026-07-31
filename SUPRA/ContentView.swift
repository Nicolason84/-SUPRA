import SwiftUI
import Combine
import AppKit
import Foundation
import CryptoKit
import CAnnoNicoContracts

struct ContentView: View {
    @StateObject var store = SUPRAExecutiveStore()
    @State var selection: SUPRASection.ID? = "workspace"
    @State var chatDraft = ""
    @State private var pendingAction: SUPRAActionDefinition?
    @State private var showActionConfirmation = false
    @State private var systemIntegrity = SUPRASystemIntegritySnapshot.unavailable
    @State private var operationalQuery = ""
    @State private var operationalScope = "All"
    @State private var operationalSelectedKey: String?
    @State private var operationalInspectorVisible = true
    @State private var sidebarAdvancedExpanded = false
    @State private var autopilotStarted = false
    @State var gabrielSnapshot = SUPRAGabrielConductorSnapshot.unavailable
    @State var gabrielBusy = false
    @State var structureMode: SUPRAStructureMode = .hydrogen
    @State var humanStage: SUPRAHumanStage = .observe
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var immersiveFocus = false
    @State var circuitPurgeCount = 0
    @State var filteredInputStatus = "FILTERED"
    @State private var autonomousHumanGateEnabled = false
    @State private var autonomousHumanGateStarted = false
    @State private var autonomousCycleCount = 0
    @State private var autonomousStatus = "AUTONOMOUS"
    @State private var autonomousLastProcessedReply = ""
    @State private var technicalDisclosureExpanded = false
    @State var terminalMegabusStatus = "OFFLINE"

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sidebar
                .navigationSplitViewColumnWidth(min: 210, ideal: 245, max: 285)
        } content: {
            structureNavigator
                .navigationSplitViewColumnWidth(min: 250, ideal: 310, max: 380)
        } detail: {
            structureDetail
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 1180, minHeight: 760)
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                Picker("Structure", selection: $structureMode) {
                    ForEach(SUPRAStructureMode.allCases) { mode in
                        Label(mode.rawValue, systemImage: mode.symbol).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(minWidth: 430)
                Button {
                    immersiveFocus.toggle()
                    columnVisibility = immersiveFocus ? .detailOnly : .all
                } label: {
                    Label(immersiveFocus ? "Exit focus" : "Immersive focus", systemImage: immersiveFocus ? "rectangle.split.3x1" : "viewfinder")
                }
            }
        }
        .task {
            store.load()
            autonomousHumanGateEnabled = hasAuthorizedHumanGate
            autonomousStatus = effectiveAutonomousStatus
            systemIntegrity = SUPRASystemIntegrityLoader.load()
            SUPRATerminalMegabusBridge.registerSUPRAAndGabriel()
            terminalMegabusStatus = SUPRATerminalMegabusBridge.status()
            startAutopilotIfNeeded()
            gabrielSnapshot = SUPRAGabrielConductorRuntime.load()
        }
        .onChange(of: operationalDecisionCandidates.count) { _, _ in
            autonomousHumanGateEnabled = hasAuthorizedHumanGate
            autonomousStatus = effectiveAutonomousStatus
        }
        .onChange(of: autonomousHumanGateEnabled) { _, proposedValue in
            let authorizedValue = hasAuthorizedHumanGate
            if proposedValue != authorizedValue {
                autonomousHumanGateEnabled = authorizedValue
            }
            autonomousStatus = effectiveAutonomousStatus
        }
        .onChange(of: autonomousStatus) { _, proposedValue in
            let authorizedValue = effectiveAutonomousStatus
            if proposedValue != authorizedValue {
                autonomousStatus = authorizedValue
            }
        }
    }


    @ViewBuilder
    private var structureDetail: some View {
        if selection == "workspace" {
            switch structureMode {
            case .hydrogen: hydrogenExperience
            case .atomium: atomiumExperience
            case .arbo: arboExperience
            case .orbital: orbitalExperience
            }
        } else {
            detail
        }
    }

    private var hydrogenExperience: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                structureHero("HYDROGEN", title: humanIntent, subtitle: humanNextAction, symbol: humanStage.symbol)
                cannonicoCircuitBoard
                operationalWorkspacePage
            }
            .padding(28)
        }
        .background(structureBackground)
    }

    private var atomiumExperience: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                structureHero("ATOMIUM", title: "Comprendre le système comme un organisme vivant.", subtitle: "Noyau SUPRA, modules CAnnoNico, Gabriel et décisions humaines.", symbol: "atom")
                cannonicoCircuitBoard
                integrationAtomium
            }
            .padding(28)
        }
        .background(structureBackground)
    }

    private var arboExperience: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                structureHero("ARBO", title: "Naviguer du sens vers la preuve.", subtitle: "Source → module → capacité → produit → preuve → décision → action.", symbol: "point.3.connected.trianglepath.dotted")
                cannonicoCircuitBoard
                arboGraph
            }
            .padding(28)
        }
        .background(structureBackground)
    }

    private var orbitalExperience: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                structureHero("ORBITAL", title: "Faire converger plusieurs intelligences.", subtitle: "Trois missions isolées, Gabriel conduit, SUPRA arbitre.", symbol: "circle.dotted.and.circle")
                cannonicoCircuitBoard
                gabrielOrbital
            }
            .padding(28)
        }
        .background(structureBackground)
    }

    private func structureHero(_ eyebrow: String, title: String, subtitle: String, symbol: String) -> some View {
        HStack(spacing: 22) {
            Image(systemName: symbol).font(.system(size: 40, weight: .semibold)).frame(width: 88, height: 88).background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
            VStack(alignment: .leading, spacing: 7) {
                Text(eyebrow).font(.caption.weight(.black)).foregroundStyle(.secondary)
                Text(title).font(.system(size: 32, weight: .bold, design: .rounded))
                Text(subtitle).font(.title3).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(26)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28))
    }

    private var integrationAtomium: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 250), spacing: 16)], spacing: 16) {
            structureCard("SUPRA Core", role: "FINAL AUTHORITY", status: systemIntegrity.isHealthy ? "HEALTHY" : "CHECK", symbol: "cpu.fill")
            ForEach(cannonicoIntegrationSnapshot.references, id: \.id) { reference in
                structureCard(reference.id, role: reference.role, status: reference.state.rawValue.uppercased(), symbol: "shippingbox.fill")
            }
            structureCard("Gabriel", role: "VISIBLE CONDUCTOR", status: gabrielSnapshot.status, symbol: "circle.hexagongrid.fill")
        }
    }

    private func structureCard(_ title: String, role: String, status: String, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack { Image(systemName: symbol).font(.title2); Spacer(); Text(status).font(.caption2.weight(.black)) }
            Text(title).font(.title3.bold())
            Text(role).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 145, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 22))
    }

    private var arboGraph: some View {
        VStack(alignment: .leading, spacing: 14) {
            structureCard("SUPRA", role: "Autorité finale", status: "ROOT", symbol: "cpu.fill")
            structureCard("Gabriel", role: "Conduite des missions", status: gabrielSnapshot.status, symbol: "circle.hexagongrid.fill")
            structureCard("CAnnoNico", role: "Contrats, modules, lineage", status: "ACTIVE", symbol: "atom")
            structureCard("PUCHERO · NICO_APP · VIDEO_SWAP", role: "Sources et capacités réelles", status: "3/3", symbol: "square.grid.3x3.fill")
        }
    }

    private var gabrielOrbital: some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                ForEach(gabrielSnapshot.workers, id: \.id) { worker in
                    VStack(spacing: 8) {
                        Image(systemName: "circle.dotted.circle.fill").font(.system(size: 34))
                        Text(worker.title).font(.headline).multilineTextAlignment(.center)
                        Text(worker.status).font(.caption2.weight(.black))
                    }
                    .frame(maxWidth: .infinity, minHeight: 140)
                    .padding(16)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 20))
                }
            }
            Image(systemName: "arrow.down").font(.title2).foregroundStyle(.secondary)
            structureCard("GABRIEL", role: "Collecte · compare · consolide", status: gabrielSnapshot.status, symbol: "circle.hexagongrid.fill")
            Image(systemName: "arrow.down").font(.title2).foregroundStyle(.secondary)
            Label("SUPRA · FINAL AUTHORITY", systemImage: "checkmark.shield.fill").font(.title3.bold()).padding(18).background(.regularMaterial, in: Capsule())
        }
    }

    private var structureBackground: some View {
        LinearGradient(colors: [Color(nsColor: .windowBackgroundColor), Color(nsColor: .controlBackgroundColor).opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
    }
    // SUPRA_MULTI_STRUCTURE_CLOSED_CIRCUIT_V1_END

    // SUPRA_AUTOPILOT_MINIMAL_UI_V1_BEGIN
    private var sidebar: some View {
        List(selection: $selection) {
            Label("Workspace", systemImage: "square.grid.2x2.fill")
                .tag("workspace")

            Label {
                HStack(spacing: 8) {
                    Text("Decision Inbox")
                    Spacer(minLength: 8)
                    Text(operationalDecisionCandidates.count.formatted())
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: "rectangle.3.group.fill")
            }
            .tag("decisions")

            Label {
                HStack(spacing: 8) {
                    Text("Chat SUPRA")
                    Spacer(minLength: 8)
                    Circle()
                        .fill(store.chatConnected ? .green : .orange)
                        .frame(width: 7, height: 7)
                }
            } icon: {
                Image(systemName: "message.fill")
            }
            .tag("chat")

            Label {
                HStack(spacing: 8) {
                    Text("System Integrity")
                    Spacer(minLength: 8)
                    Circle()
                        .fill(systemIntegrity.isHealthy ? .green : .orange)
                        .frame(width: 7, height: 7)
                }
            } icon: {
                Image(systemName: "checkmark.shield.fill")
            }
            .tag("integrity")

            DisclosureGroup(isExpanded: $sidebarAdvancedExpanded) {
                ForEach(store.model.sections) { section in
                    Label {
                        HStack(spacing: 8) {
                            Text(section.title)
                            Spacer(minLength: 8)
                            if section.count > 0 {
                                Text(section.count.formatted())
                                    .font(.caption.monospacedDigit())
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } icon: {
                        Image(systemName: section.systemImage)
                    }
                    .tag(section.id)
                }

                Label {
                    HStack(spacing: 8) {
                        Text("Opportunities")
                        Spacer(minLength: 8)
                        Text(store.monetizableOpportunities.count.formatted())
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "sparkles")
                }
                .tag("opportunities")

                Label {
                    HStack(spacing: 8) {
                        Text("Action Center")
                        Spacer(minLength: 8)
                        Text(store.actions.count.formatted())
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "checkmark.shield")
                }
                .tag("actions")
            } label: {
                Label("Advanced", systemImage: "slider.horizontal.3")
                    .foregroundStyle(.secondary)
            }
        }
        .listStyle(.sidebar)
        .safeAreaInset(edge: .bottom) {
            VStack(alignment: .leading, spacing: 5) {
                Divider()
                HStack(spacing: 7) {
                    Circle()
                        .fill(terminalMegabusStatus == "CONNECTED" ? .green : .orange)
                        .frame(width: 7, height: 7)
                    Text("MEGABUS \(terminalMegabusStatus)")
                        .font(.caption.weight(.bold))
                }
                HStack(spacing: 7) {
                    Circle()
                        .fill(store.model.system.status == "READY" ? .green : .orange)
                        .frame(width: 7, height: 7)
                    Text("AUTOPILOT")
                        .font(.caption.weight(.semibold))
                }
                Text("SUPRA agit · Nicolas décide")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .navigationTitle("SUPRA")
    }


    @ViewBuilder
    private var detail: some View {
        switch selection {
        case "chat":
            humanSynthesisChatPage

        case "workspace":
            operationalWorkspacePage

        case "decisions":
            operationalWorkspacePage

        case "integrity":
            systemIntegrityPage

        case "actions":
            actionCenterPage

        case "opportunities":
            registryPage(
                title: "Monetizable Opportunities",
                subtitle: "Capacités candidates · pas des produits lancés",
                icon: "sparkles",
                records: store.monetizableOpportunities
            )

        case "projects":
            registryPage(
                title: "Projects",
                subtitle: "Registre canonique des projets",
                icon: "folder",
                records: store.model.projects
            )

        case "capabilities":
            registryPage(
                title: "Capabilities",
                subtitle: "Capacités existantes récupérées",
                icon: "shippingbox",
                records: store.model.capabilities
            )

        case "products":
            registryPage(
                title: "Products",
                subtitle: "Produits et actifs monétisables",
                icon: "cube.box",
                records: store.model.products
            )

        case "runtime":
            sourcePage(
                title: "Runtime",
                subtitle: "Backend existant connecté à la façade",
                icon: "bolt.circle",
                matching: ["RUNTIME"]
            )

        case "atlas":
            sourcePage(
                title: "Atlas",
                subtitle: "Cartographie et index canoniques",
                icon: "square.stack.3d.up",
                matching: ["ATLAS"]
            )

        case "memory":
            sourcePage(
                title: "Memory",
                subtitle: "Index mémoire et registre des ressources",
                icon: "brain",
                matching: ["IMAC_MEMORY_INDEX", "RESOURCE_REGISTRY"]
            )

        case "interface":
            interfacePage

        default:
            executivePage
        }
    }




    // SUPRA_OPERATIONAL_WORKSPACE_V1_BEGIN

    private var operationalWorkspaceRecords: [SUPRARecord] {
        let records: [SUPRARecord]

        switch operationalScope {
        case "Projects":
            records = store.model.projects
        case "Capabilities":
            records = store.model.capabilities
        case "Products":
            records = store.model.products
        case "Opportunities":
            records = store.monetizableOpportunities
        default:
            records = store.model.projects
                + store.model.capabilities
                + store.model.products
                + store.monetizableOpportunities
        }

        let query = operationalQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return records }

        return records.filter { record in
            [record.name, record.detail, record.path, record.status]
                .compactMap { $0 }
                .joined(separator: " ")
                .localizedCaseInsensitiveContains(query)
        }
    }

    private var operationalSelectedRecord: SUPRARecord? {
        guard let operationalSelectedKey else {
            return operationalWorkspaceRecords.first
        }

        return operationalWorkspaceRecords.first {
            ($0.path ?? $0.name) == operationalSelectedKey
        } ?? operationalWorkspaceRecords.first
    }

    private func isAuthorizedHumanGate(_ record: SUPRARecord) -> Bool {
        let normalized = [record.name, record.detail, record.path, record.status]
            .compactMap { $0 }
            .joined(separator: " ")
            .folding(
                options: [.diacriticInsensitive, .caseInsensitive],
                locale: .current
            )
            .lowercased()

        let authorizedSignals = [
            "authority conflict",
            "conflit d'autorite",
            "constitutional choice",
            "choix constitutionnel",
            "compatibility break",
            "rupture de compatibilite",
            "canonical promotion",
            "promotion canonique",
            "irreversible action",
            "action irreversible",
            "high human impact",
            "impact humain eleve",
            "high strategic impact",
            "impact strategique eleve"
        ]

        return authorizedSignals.contains {
            normalized.contains($0)
        }
    }

    private var hasAuthorizedHumanGate: Bool {
        !operationalDecisionCandidates.isEmpty
    }

    private var effectiveAutonomousStatus: String {
        hasAuthorizedHumanGate ? "HUMAN GATE" : "AUTONOMOUS"
    }


    var operationalDecisionCandidates: [SUPRARecord] {
        let records = store.model.projects
            + store.model.capabilities
            + store.model.products
            + store.monetizableOpportunities

        return records.filter(isAuthorizedHumanGate)
    }

    private var cannonicoParallelRecords: [SUPRARecord] {
        let records = store.model.projects + store.model.capabilities + store.model.products
        return records.filter { record in
            [record.name, record.detail, record.path]
                .compactMap { $0 }
                .joined(separator: " ")
                .localizedCaseInsensitiveContains("cannonico")
        }
    }

    // SUPRA_CANNONICO_SNAPSHOT_UI_V1_BEGIN
    var cannonicoIntegrationSnapshot: CAnnoNicoIntegrationSnapshot {
        CAnnoNicoSnapshotStore.shared.currentState.snapshot
    }

    var cannonicoRecoveredReferences: [CAnnoNicoSourceReference] {
        cannonicoIntegrationSnapshot.references.filter {
            $0.state == .recovered
        }
    }

    private var cannonicoPendingReferences: [CAnnoNicoSourceReference] {
        cannonicoIntegrationSnapshot.references.filter {
            $0.state != .recovered
        }
    }

    private var cannonicoIntegrationMissionPrompt: String {
        let moduleLines = cannonicoIntegrationSnapshot.references.map { reference in
            let path = reference.path ?? "unresolved"
            let capabilities = reference.capabilities.joined(separator: ", ")
            let inputs = reference.inputs.joined(separator: ", ")
            let outputs = reference.outputs.joined(separator: ", ")

            return "MODULE=\(reference.id) ROLE=\(reference.role) STATE=\(reference.state.rawValue) PATH=\(path) INPUTS=[\(inputs)] OUTPUTS=[\(outputs)] CAPABILITIES=[\(capabilities)]"
        }
        .joined(separator: "\n")

        return
            "CANNONICO INTEGRATION AUTOPILOT. Analyse les trois modules réels déjà liés à SUPRA. "
            + "Pour chaque module, produis uniquement des opérations prouvées de COMBINE, HYBRIDIZE, FUSE, SUPPLEMENT, REDUCE ou AMPLIFY. "
            + "N'invente aucune capacité, ne copie aucune donnée, ne recrée aucun moteur, ne modifie aucune source. "
            + "Travaille automatiquement sur tout ce qui est sûr, réversible et allowlisté. "
            + "Retourne exactement: MODULE, OPERATION, SOURCE, CIBLE, CONTRAT_IO, PREUVES, RISQUE, ACTION_AUTOMATIQUE, DECISION_HUMAINE_REQUISE.\n"
            + moduleLines
    }

    private var appIntegrationCandidates: [SUPRARecord] {
        store.model.projects.filter { record in
            [record.name, record.detail, record.path]
                .compactMap { $0 }
                .joined(separator: " ")
                .lowercased()
                .contains("app")
        }
    }

    private var autopilotLatestReply: String? {
        store.chatMessages.last(where: { $0.role == "assistant" })?.text
    }

    private var operationalWorkspacePage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack(alignment: .center, spacing: 18) {
                    Image(systemName: "sparkles.rectangle.stack.fill")
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(.blue)
                        .frame(width: 72, height: 72)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))

                    VStack(alignment: .leading, spacing: 5) {
                        Text("Decision Inbox")
                            .font(.largeTitle.bold())
                        Text("SUPRA travaille seul. Tu interviens uniquement lorsqu’une décision importante est réellement nécessaire.")
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text(operationalDecisionCandidates.isEmpty ? "AUTOPILOT" : "DECISION REQUIRED")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(operationalDecisionCandidates.isEmpty ? .green : .orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(
                            (operationalDecisionCandidates.isEmpty ? Color.green : Color.orange).opacity(0.12),
                            in: Capsule()
                        )
                }

                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("SUPRA Autopilot")
                                .font(.title2.bold())
                            Text("Analyse, combine, hybridise, fusionne et complète automatiquement les actifs existants.")
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        HStack(spacing: 7) {
                            Circle()
                                .fill(store.chatBusy ? .orange : .green)
                                .frame(width: 8, height: 8)
                            Text(store.chatBusy ? "ANALYSING" : "ACTIVE")
                                .font(.caption.weight(.bold))
                        }
                    }

                    HStack(spacing: 12) {
                        Label("\(appIntegrationCandidates.count) app candidates", systemImage: "app.badge")
                        Label("Combine", systemImage: "rectangle.2.swap")
                        Label("Hybridize", systemImage: "arrow.triangle.merge")
                        Label("Fuse", systemImage: "point.3.filled.connected.trianglepath.dotted")
                        Label("Supplement", systemImage: "plus.rectangle.on.rectangle")
                        Spacer()
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                    if let reply = autopilotLatestReply {
                        Text(reply)
                            .font(.callout)
                            .lineLimit(8)
                            .textSelection(.enabled)
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.quaternary, in: RoundedRectangle(cornerRadius: 14))

                        Button {
                            selection = "chat"
                        } label: {
                            Label("Open full SUPRA analysis", systemImage: "message.fill")
                        }
                        .buttonStyle(.bordered)
                    } else {
                        Text("SUPRA prépare automatiquement la prochaine décision humaine réellement nécessaire.")
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(20)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))

                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("CAnnoNico Integration Snapshot")
                                .font(.title2.bold())

                            Text("État réel des modules liés, sans duplication de données ni recréation de moteur.")
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text("\(cannonicoRecoveredReferences.count)/\(cannonicoIntegrationSnapshot.references.count) RECOVERED")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(cannonicoPendingReferences.isEmpty ? .green : .orange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(
                                (cannonicoPendingReferences.isEmpty ? Color.green : Color.orange).opacity(0.12),
                                in: Capsule()
                            )
                    }

                    ForEach(cannonicoIntegrationSnapshot.references, id: \.id) { reference in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .top, spacing: 12) {
                                Image(
                                    systemName: reference.state == .recovered
                                        ? "checkmark.seal.fill"
                                        : "exclamationmark.triangle.fill"
                                )
                                .foregroundStyle(reference.state == .recovered ? .green : .orange)
                                .font(.title3)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(reference.id)
                                        .font(.headline.monospaced())

                                    Text(reference.role)
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.secondary)

                                    if let path = reference.path {
                                        Text(path)
                                            .font(.caption.monospaced())
                                            .foregroundStyle(.secondary)
                                            .lineLimit(2)
                                            .textSelection(.enabled)
                                    }
                                }

                                Spacer()

                                Text(reference.state.rawValue.uppercased())
                                    .font(.caption2.weight(.black))
                                    .foregroundStyle(reference.state == .recovered ? .green : .orange)
                            }

                            HStack(spacing: 8) {
                                Label("\(reference.inputs.count) inputs", systemImage: "arrow.down.doc")
                                Label("\(reference.outputs.count) outputs", systemImage: "arrow.up.doc")
                                Label("\(reference.capabilities.count) capabilities", systemImage: "square.grid.3x3.fill")
                                Spacer()
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)

                            if !reference.capabilities.isEmpty {
                                Text(reference.capabilities.joined(separator: " · "))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(3)
                            }
                        }
                        .padding(14)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 14))
                    }

                    HStack(spacing: 10) {
                        Button {
                            chatDraft = cannonicoIntegrationMissionPrompt
                            selection = "chat"
                        } label: {
                            Label("Generate integration missions", systemImage: "arrow.triangle.branch")
                        }
                        .buttonStyle(.borderedProminent)

                        Button {
                            Task {
                                await store.sendChat(cannonicoIntegrationMissionPrompt)
                            }
                        } label: {
                            Label("Run Autopilot now", systemImage: "bolt.fill")
                        }
                        .buttonStyle(.bordered)
                        .disabled(store.chatBusy)
                    }
                }
                .padding(20)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))

                // SUPRA_GABRIEL_PARALLEL_CONDUCTOR_UI_V1_BEGIN
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Gabriel · Parallel Mission Conductor")
                                .font(.title2.bold())
                            Text("Trois workers isolés · une autorité finale SUPRA.")
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(gabrielSnapshot.status)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(gabrielSnapshot.status == "PASS" ? .green : .orange)
                    }

                    HStack(spacing: 12) {
                        Label("3 mission slots", systemImage: "square.grid.3x1.folder.badge.plus")
                        Label("3 worker processes", systemImage: "cpu")
                        Label("1 SUPRA UI", systemImage: "macwindow")
                        Label("Read only", systemImage: "lock.shield")
                        Spacer()
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                    ForEach(gabrielSnapshot.workers, id: \.id) { worker in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(
                                    worker.status == "PASS"
                                        ? .green
                                        : worker.status == "RUNNING"
                                            ? .orange
                                            : .secondary
                                )
                                .frame(width: 8, height: 8)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(worker.title)
                                    .font(.headline)
                                Text(worker.mission)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }

                            Spacer()

                            Text(worker.status)
                                .font(.caption2.weight(.black))
                        }
                        .padding(12)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
                    }

                    HStack(spacing: 10) {
                        Button {
                            gabrielBusy = true
                            Task {
                                await SUPRAGabrielConductorRuntime.run()
                                gabrielSnapshot = SUPRAGabrielConductorRuntime.load()
                                gabrielBusy = false
                            }
                        } label: {
                            Label("Run three missions", systemImage: "play.fill")
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(gabrielBusy)

                        Button {
                            gabrielSnapshot = SUPRAGabrielConductorRuntime.load()
                        } label: {
                            Label("Refresh", systemImage: "arrow.clockwise")
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(20)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
                // SUPRA_GABRIEL_PARALLEL_CONDUCTOR_UI_V1_END

                if operationalDecisionCandidates.isEmpty {
                    ContentUnavailableView(
                        "Aucune décision humaine requise",
                        systemImage: "checkmark.circle.fill",
                        description: Text("SUPRA continue automatiquement les tâches sûres et réversibles.")
                    )
                    .frame(maxWidth: .infinity, minHeight: 220)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
                } else {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Décisions prioritaires")
                            .font(.title2.bold())

                        ForEach(operationalDecisionCandidates) { record in
                            VStack(alignment: .leading, spacing: 14) {
                                HStack(alignment: .top, spacing: 14) {
                                    Image(systemName: operationalIcon(for: record))
                                        .font(.title2)
                                        .frame(width: 44, height: 44)
                                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))

                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(record.name)
                                            .font(.title3.bold())

                                        if let detail = record.detail {
                                            Text(detail)
                                                .foregroundStyle(.secondary)
                                                .lineLimit(3)
                                        }

                                        statusBadge(record.status)
                                    }

                                    Spacer()
                                }

                                HStack(spacing: 10) {
                                    Button {
                                        chatDraft =
                                            "Prépare une décision exécutive binaire et fondée sur preuves. "
                                            + "Format obligatoire: RECOMMANDATION, POURQUOI, PREUVES, RISQUES, "
                                            + "CONSÉQUENCE SI OUI, CONSÉQUENCE SI NON, ACTION AUTOMATIQUE APRÈS VALIDATION. "
                                            + "Objet: \(record.name). Statut: \(record.status). "
                                            + "Source: \(record.path ?? "non résolue")."
                                        selection = "chat"
                                    } label: {
                                        Label("Expliquer", systemImage: "wand.and.stars")
                                    }
                                    .buttonStyle(.borderedProminent)

                                    Button {
                                        operationalSelectedKey = record.path ?? record.name
                                        selection = "actions"
                                    } label: {
                                        Label("Actions sûres", systemImage: "checkmark.shield")
                                    }
                                    .buttonStyle(.bordered)

                                    if let path = record.path {
                                        Button {
                                            NSWorkspace.shared.activateFileViewerSelecting([
                                                URL(fileURLWithPath: path)
                                            ])
                                        } label: {
                                            Label("Preuve", systemImage: "doc.text.magnifyingglass")
                                        }
                                        .buttonStyle(.bordered)
                                    }
                                }
                            }
                            .padding(18)
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("CAnnoNico Total · Parallel Lane")
                                .font(.title2.bold())
                            Text("Modularisation, atomisation, LEGO, contrats et lineage en parallèle.")
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(
                            cannonicoParallelRecords.isEmpty
                                ? "RECOVERY REQUIRED"
                                : "RECOVERED SOURCES \(cannonicoParallelRecords.count)"
                        )
                        .font(.caption.weight(.bold))
                        .foregroundStyle(cannonicoParallelRecords.isEmpty ? .orange : .green)
                    }

                    HStack(spacing: 14) {
                        Label("Atoms", systemImage: "circle.grid.cross")
                        Label("Modules", systemImage: "shippingbox.fill")
                        Label("LEGO", systemImage: "square.grid.3x3.fill")
                        Label("Contracts", systemImage: "doc.badge.gearshape")
                        Label("Lineage", systemImage: "point.3.connected.trianglepath.dotted")
                        Spacer()
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                }
                .padding(20)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))

                DisclosureGroup("Explorer les actifs — mode avancé") {
                    VStack(spacing: 14) {
                        Picker("Scope", selection: $operationalScope) {
                            Text("All").tag("All")
                            Text("Projects").tag("Projects")
                            Text("Capabilities").tag("Capabilities")
                            Text("Products").tag("Products")
                            Text("Opportunities").tag("Opportunities")
                        }
                        .pickerStyle(.segmented)

                        TextField("Recherche avancée", text: $operationalQuery)
                            .textFieldStyle(.roundedBorder)

                        Text("\(operationalWorkspaceRecords.count.formatted()) objets disponibles")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.top, 12)
                }
                .padding(18)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
            }
            .padding(28)
            .frame(maxWidth: 1100, alignment: .leading)
        }
        .navigationTitle("Decision Inbox")
    }



    private var operationalInspector: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                if let record = operationalSelectedRecord {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: operationalIcon(for: record))
                            .font(.title2)
                            .frame(width: 42, height: 42)
                            .background(
                                .regularMaterial,
                                in: RoundedRectangle(cornerRadius: 12)
                            )

                        VStack(alignment: .leading, spacing: 5) {
                            Text(record.name)
                                .font(.title2.bold())
                                .textSelection(.enabled)

                            statusBadge(record.status)
                        }
                    }

                    Divider()

                    inspectorField(title: "Detail", value: record.detail)
                    inspectorField(title: "Source", value: record.path)
                    inspectorField(title: "Status", value: record.status)

                    Divider()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("One-click actions")
                            .font(.headline)

                        Button {
                            chatDraft =
                                "Analyse cet objet sélectionné, identifie ses preuves, "
                                + "ses relations, ses blocages et sa meilleure prochaine action. "
                                + "Objet: \(record.name). Statut: \(record.status). "
                                + "Source: \(record.path ?? "non résolue")."
                            selection = "chat"
                        } label: {
                            Label("Ask SUPRA", systemImage: "message.fill")
                        }
                        .buttonStyle(.borderedProminent)

                        Button {
                            selection = "actions"
                        } label: {
                            Label(
                                "Open contextual actions",
                                systemImage: "checkmark.shield"
                            )
                        }
                        .buttonStyle(.bordered)

                        if let path = record.path {
                            Button {
                                NSWorkspace.shared.activateFileViewerSelecting([
                                    URL(fileURLWithPath: path)
                                ])
                            } label: {
                                Label("Reveal source", systemImage: "folder")
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "Select an object",
                        systemImage: "cursorarrow.click.2",
                        description: Text(
                            "The inspector exposes identity, evidence and available actions."
                        )
                    )
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }

    private func inspectorField(title: String, value: String?) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title.uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)

            Text(value ?? "Unavailable")
                .font(.callout)
                .foregroundStyle(value == nil ? .secondary : .primary)
                .textSelection(.enabled)
        }
    }

    private func operationalIcon(for record: SUPRARecord) -> String {
        let combined = [record.name, record.detail, record.path]
            .compactMap { $0 }
            .joined(separator: " ")
            .lowercased()

        if combined.contains("product") { return "cube.box" }
        if combined.contains("capabil") { return "shippingbox" }
        if combined.contains("opportun") { return "sparkles" }
        return "folder"
    }

    // SUPRA_OPERATIONAL_WORKSPACE_V1_END

    private var systemIntegrityPage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HStack(spacing: 18) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundStyle(systemIntegrity.isHealthy ? .green : .orange)
                        .frame(width: 72, height: 72)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))

                    VStack(alignment: .leading, spacing: 5) {
                        Text("System Integrity")
                            .font(.largeTitle.bold())
                        Text("Preuves locales validées · lecture seule")
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text(systemIntegrity.isHealthy ? "HEALTHY" : "ATTENTION")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(systemIntegrity.isHealthy ? .green : .orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background((systemIntegrity.isHealthy ? Color.green : Color.orange).opacity(0.12), in: Capsule())
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 14)], spacing: 14) {
                    integrityCard(
                        title: "Build",
                        value: systemIntegrity.buildVerdict == "BUILD_SUCCEEDED" ? "PASS" : systemIntegrity.buildVerdict,
                        icon: "hammer.fill"
                    )
                    integrityCard(
                        title: "Rollback",
                        value: systemIntegrity.rollbackVerdict == "ROLLBACK_RESTORATION_PROVEN" ? "PROVEN" : systemIntegrity.rollbackVerdict,
                        icon: "arrow.uturn.backward.circle.fill"
                    )
                    integrityCard(
                        title: "Source Mutation",
                        value: systemIntegrity.sourceMutation,
                        icon: "lock.shield.fill"
                    )
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Verified evidence")
                        .font(.title3.bold())
                    integrityEvidenceRow(title: "Build log", path: systemIntegrity.buildLogPath)
                    Divider()
                    integrityEvidenceRow(title: "Rollback proof", path: systemIntegrity.rollbackProofPath)
                }
                .padding(20)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
            }
            .padding(28)
            .frame(maxWidth: 1100, alignment: .leading)
        }
        .navigationTitle("System Integrity")
        .toolbar {
            ToolbarItemGroup {
                Button {
                    systemIntegrity = SUPRASystemIntegrityLoader.load()
                } label: {
                    Label("Recheck", systemImage: "arrow.clockwise")
                }

                if let path = systemIntegrity.buildLogPath {
                    Button {
                        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: path)])
                    } label: {
                        Label("Reveal Build Log", systemImage: "doc.text.magnifyingglass")
                    }
                }
            }
        }
    }

    private func integrityCard(title: String, value: String, icon: String) -> some View {
        let positive = ["PASS", "PROVEN", "NONE"].contains(value)

        return VStack(alignment: .leading, spacing: 13) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                Spacer()
                Circle()
                    .fill(positive ? .green : .orange)
                    .frame(width: 8, height: 8)
            }
            Text(value)
                .font(.system(size: 25, weight: .bold, design: .rounded))
            Text(title)
                .font(.headline)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
    }

    private func integrityEvidenceRow(title: String, path: String?) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(path == nil ? .orange : .green)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(path ?? "Evidence unavailable")
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .textSelection(.enabled)
            }

            Spacer()

            if let path {
                Button("Reveal") {
                    NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: path)])
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(.vertical, 6)
    }

    private var actionCenterPage: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Action Center")
                        .font(.largeTitle.bold())
                    Text("Local · allowlist SHA-256 · confirmation obligatoire · aucun shell libre")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("Demander à SUPRA") {
                    chatDraft = "Parmi les actions allowlistées du centre local, laquelle recommandes-tu et pourquoi ? Ne propose qu’un identifiant existant; n’exécute rien."
                    selection = "chat"
                }
                Button { store.loadActions() } label: { Label("Refresh", systemImage: "arrow.clockwise") }
            }
            .padding(24)
            Divider()

            if store.actions.isEmpty {
                ContentUnavailableView(
                    "Aucune action approuvée",
                    systemImage: "checkmark.shield",
                    description: Text("Sécurité active : aucun script n’est exécutable tant qu’il n’est pas allowlisté avec son empreinte.")
                )
            } else {
                List(store.actions) { action in
                    HStack(spacing: 14) {
                        Image(systemName: action.mode == "READ_ONLY" ? "eye" : "externaldrive.badge.checkmark")
                            .foregroundStyle(action.mode == "READ_ONLY" ? .blue : .orange)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(action.title).font(.headline)
                            Text(action.id).font(.caption.monospaced()).textSelection(.enabled)
                            Text(action.description).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(action.mode).font(.caption2.weight(.bold)).foregroundStyle(.secondary)
                        Button("Vérifier") { store.verify(action) }
                        Button("Exécuter") {
                            pendingAction = action
                            showActionConfirmation = true
                        }
                        .disabled(store.actionBusy)
                    }.padding(.vertical, 7)
                }
            }
            Divider()
            ScrollView {
                Text(store.actionOutput.isEmpty ? "Aucune action récente." : store.actionOutput)
                    .font(.caption.monospaced())
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(18)
            }.frame(minHeight: 130, maxHeight: 220)
        }
        .confirmationDialog(
            "Confirmer l’exécution locale",
            isPresented: $showActionConfirmation,
            titleVisibility: .visible,
            presenting: pendingAction
        ) { action in
            Button("Exécuter \(action.title)", role: .destructive) {
                Task { await store.execute(action) }
            }
            Button("Annuler", role: .cancel) {}
        } message: { action in
            Text("Identifiant: \(action.id). Le SHA-256 sera revérifié immédiatement avant exécution. Aucun argument libre ne sera transmis.")
        }
    }

    // SUPRA_HUMAN_SYNTHESIS_AUTONOMOUS_GATE_V1_BEGIN
    private var humanSynthesisChatPage: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Chat SUPRA")
                                .font(.largeTitle.bold())

                            Text("Synthèse humaine d’abord · technique sur demande")
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        HStack(spacing: 8) {
                            Circle()
                                .fill(
                                    autonomousStatus == "HUMAN GATE"
                                        ? .orange
                                        : autonomousHumanGateEnabled
                                            ? .green
                                            : .secondary
                                )
                                .frame(width: 8, height: 8)

                            Text(autonomousStatus)
                                .font(.caption.weight(.black))
                        }
                    }

                    humanAutonomyCard

                    if let reply = autopilotLatestReply {
                        humanSynthesisCard(reply)

                        DisclosureGroup(
                            isExpanded: $technicalDisclosureExpanded
                        ) {
                            Text(reply)
                                .font(.callout.monospaced())
                                .textSelection(.enabled)
                                .frame(
                                    maxWidth: .infinity,
                                    alignment: .leading
                                )
                                .padding(16)
                                .background(
                                    .quaternary,
                                    in: RoundedRectangle(cornerRadius: 14)
                                )
                                .padding(.top, 10)
                        } label: {
                            Label(
                                "Voir preuves, contrats et réponse brute",
                                systemImage: "chevron.right.circle"
                            )
                            .font(.headline)
                        }
                        .padding(18)
                        .background(
                            .regularMaterial,
                            in: RoundedRectangle(cornerRadius: 18)
                        )
                    } else {
                        ContentUnavailableView(
                            "SUPRA prépare la synthèse",
                            systemImage: "sparkles",
                            description: Text(
                                "Le système continue automatiquement jusqu’à une décision humaine critique."
                            )
                        )
                        .frame(minHeight: 260)
                    }
                }
                .padding(28)
                .frame(maxWidth: 1120, alignment: .leading)
            }

            Divider()

            HStack(spacing: 10) {
                TextField("Parler à SUPRA…", text: $chatDraft)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        sendHumanChatDraft()
                    }

                Button {
                    sendHumanChatDraft()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                }
                .buttonStyle(.plain)
                .disabled(
                    chatDraft
                        .trimmingCharacters(
                            in: .whitespacesAndNewlines
                        )
                        .isEmpty
                    || store.chatBusy
                )
            }
            .padding(14)
            .background(.bar)
        }
        .navigationTitle("Chat SUPRA")
        .task {
            startAutonomousHumanGateIfNeeded()
        }
    }

    private var humanAutonomyCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label(
                    "Autonomous until human-critical decision",
                    systemImage: "infinity.circle.fill"
                )
                .font(.title3.bold())

                Spacer()

                Toggle(
                    "Autonomous until human gate",
                    isOn: $autonomousHumanGateEnabled
                )
                .labelsHidden()
                .onChange(
                    of: autonomousHumanGateEnabled
                ) { _, enabled in
                    autonomousStatus =
                        enabled
                            ? "AUTONOMOUS"
                            : "PAUSED"

                    if enabled {
                        startAutonomousHumanGateIfNeeded()
                    }
                }
            }

            HStack(spacing: 14) {
                Label(
                    "Cycle \(autonomousCycleCount)",
                    systemImage: "arrow.triangle.2.circlepath"
                )

                Label(
                    "Safe + reversible only",
                    systemImage: "checkmark.shield.fill"
                )

                Label(
                    "Critical human gate",
                    systemImage: "person.crop.circle.badge.exclamationmark"
                )

                Spacer()
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)

            Text(
                "SUPRA observe, vérifie, combine, hybridise, fusionne, complète, réduit, amplifie et poursuit seul. Le cycle s’arrête uniquement devant une décision humaine critique, un risque élevé, une autorité conflictuelle, une promotion canonique ou une action irréversible."
            )
            .font(.callout)
            .foregroundStyle(.secondary)
        }
        .padding(20)
        .background(
            .regularMaterial,
            in: RoundedRectangle(cornerRadius: 20)
        )
    }

    private func humanSynthesisCard(
        _ raw: String
    ) -> some View {
        let synthesis = humanSynthesis(from: raw)

        return VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(synthesis.title)
                        .font(.title2.bold())

                    Text(synthesis.summary)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(synthesis.badge)
                    .font(.caption.weight(.black))
                    .foregroundStyle(
                        synthesis.requiresHuman
                            ? .orange
                            : .green
                    )
                    .padding(.horizontal, 11)
                    .padding(.vertical, 7)
                    .background(
                        (
                            synthesis.requiresHuman
                                ? Color.orange
                                : Color.green
                        )
                        .opacity(0.12),
                        in: Capsule()
                    )
            }

            ForEach(
                synthesis.operations,
                id: \.self
            ) { operation in
                Label(
                    operation,
                    systemImage: "arrow.right.circle.fill"
                )
                .font(.headline)
            }

            if synthesis.requiresHuman {
                VStack(alignment: .leading, spacing: 8) {
                    Label(
                        "Décision humaine requise",
                        systemImage: "person.crop.circle.badge.exclamationmark"
                    )
                    .font(.headline)

                    Text(synthesis.humanDecision)
                        .foregroundStyle(.secondary)
                }
                .padding(14)
                .background(
                    Color.orange.opacity(0.10),
                    in: RoundedRectangle(cornerRadius: 14)
                )
            } else {
                Label(
                    "Aucune intervention nécessaire · SUPRA continue",
                    systemImage: "checkmark.circle.fill"
                )
                .font(.headline)
                .foregroundStyle(.green)
            }
        }
        .padding(22)
        .background(
            .regularMaterial,
            in: RoundedRectangle(cornerRadius: 22)
        )
    }

    private struct HumanSynthesis {
        let title: String
        let summary: String
        let badge: String
        let operations: [String]
        let requiresHuman: Bool
        let humanDecision: String
    }

    private func humanSynthesis(
        from raw: String
    ) -> HumanSynthesis {
        let upper = raw.uppercased()

        let humanGateMarkers = [
            "DECISION_HUMAINE_REQUISE=YES",
            "DECISION_HUMAINE_REQUISE=TRUE",
            "ACTION_CENTER_EXECUTION_REQUIRED:\n- YES",
            "RISQUE=HIGH",
            "RISK=HIGH",
            "AUTHORITY_CONFLICT=YES",
            "CANONICAL_PROMOTION_REQUIRED=YES",
            "IRREVERSIBLE_ACTION_REQUIRED=YES"
        ]

        let requiresHuman = humanGateMarkers.contains {
            upper.contains($0)
        }

        let operationNames = [
            "HYBRIDIZE": "Hybridation préparée",
            "COMBINE": "Combinaison préparée",
            "FUSE": "Fusion préparée",
            "SUPPLEMENT": "Complément préparé",
            "REDUCE": "Réduction préparée",
            "AMPLIFY": "Amplification préparée"
        ]

        let operations = operationNames.compactMap {
            key,
            label in

            upper.contains("OPERATION=\(key)")
                ? label
                : nil
        }

        let moduleCount =
            raw.components(separatedBy: "MODULE=").count - 1

        let summary: String

        if moduleCount > 0 {
            summary =
                "SUPRA a consolidé \(moduleCount) module"
                + (moduleCount > 1 ? "s" : "")
                + " et préparé les opérations sûres."
        } else if upper.contains("BLOCKER") {
            summary =
                "SUPRA a terminé l’analyse et isolé les blocages réels."
        } else {
            summary =
                "SUPRA a terminé un cycle d’analyse et de consolidation."
        }

        return HumanSynthesis(
            title:
                requiresHuman
                    ? "Une décision importante t’attend"
                    : "SUPRA continue automatiquement",
            summary: summary,
            badge:
                requiresHuman
                    ? "HUMAN GATE"
                    : "AUTONOMOUS",
            operations:
                operations.isEmpty
                    ? [
                        "Analyse terminée",
                        "Preuves conservées",
                        "Prochain cycle préparé"
                    ]
                    : Array(operations.prefix(6)),
            requiresHuman: requiresHuman,
            humanDecision:
                requiresHuman
                    ? "SUPRA a détecté un risque élevé, un conflit d’autorité, une promotion canonique ou une action irréversible. Examine la preuve technique avant validation."
                    : "Aucune"
        )
    }

    private func startAutonomousHumanGateIfNeeded() {
        guard autonomousHumanGateEnabled else {
            return
        }

        guard !autonomousHumanGateStarted else {
            return
        }

        autonomousHumanGateStarted = true

        Task {
            while autonomousHumanGateEnabled {
                if Task.isCancelled {
                    break
                }

                if let reply = autopilotLatestReply,
                   reply != autonomousLastProcessedReply {
                    autonomousLastProcessedReply = reply

                    let synthesis =
                        humanSynthesis(from: reply)

                    if synthesis.requiresHuman {
                        autonomousStatus = "HUMAN GATE"
                        autonomousHumanGateEnabled = false
                        break
                    }

                    if !store.chatBusy {
                        autonomousCycleCount += 1
                        autonomousStatus =
                            "AUTONOMOUS · CYCLE "
                            + "\(autonomousCycleCount)"

                        await store.sendChat(
                            "SUPRA AUTONOMOUS CLOSED LOOP. Continue le travail automatiquement. "
                            + "Observe, vérifie, combine, hybridise, fusionne, complète, réduit, amplifie et mémorise uniquement ce qui est sûr, prouvé, allowlisté et réversible. "
                            + "Ne demande aucune intervention humaine sauf décision critique: risque élevé, conflit d’autorité, rupture de compatibilité, promotion canonique, action irréversible ou impact humain/stratégique majeur. "
                            + "Retourne d’abord une synthèse humaine, puis les opérations structurées MODULE, OPERATION, SOURCE, CIBLE, CONTRAT_IO, PREUVES, RISQUE, ACTION_AUTOMATIQUE, DECISION_HUMAINE_REQUISE."
                        )
                    }
                }

                try? await Task.sleep(
                    nanoseconds: 4_000_000_000
                )
            }

            autonomousHumanGateStarted = false
        }
    }

    private func sendHumanChatDraft() {
        let prompt =
            chatDraft.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !prompt.isEmpty else {
            return
        }

        chatDraft = ""

        Task {
            await store.sendChat(prompt)
        }
    }
    // SUPRA_HUMAN_SYNTHESIS_AUTONOMOUS_GATE_V1_END

    private var chatPage: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Chat SUPRA")
                        .font(.largeTitle.bold())
                    Text("Ollama via le bridge SUPRA local · qwen3:4b · mémoire en lecture seule")
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Circle()
                    .fill(store.chatConnected ? .green : .orange)
                    .frame(width: 9, height: 9)
                Text(store.chatConnected ? "CONNECTED" : "LOCAL BRIDGE")
                    .font(.caption.monospaced().weight(.semibold))
            }
            .padding(24)

            Divider()

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 14) {
                        if store.chatMessages.isEmpty {
                            ContentUnavailableView(
                                "SUPRA est prêt",
                                systemImage: "message.badge.waveform",
                                description: Text("Pose une question ou demande une vérification de la mémoire iMac.")
                            )
                            .padding(.top, 70)
                        }

                        ForEach(store.chatMessages) { message in
                            VStack(alignment: .leading, spacing: 5) {
                                Text(message.role == "user" ? "ORIAMLUX" : "SUPRA")
                                    .font(.caption.monospaced().weight(.bold))
                                    .foregroundStyle(message.role == "user" ? .blue : .cyan)
                                Text(message.text)
                                    .textSelection(.enabled)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(14)
                            .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
                            .id(message.id)
                        }
                    }
                    .padding(20)
                }
                .onChange(of: store.chatMessages.count) {
                    guard let last = store.chatMessages.last else { return }
                    withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }

            Divider()

            HStack(alignment: .bottom, spacing: 12) {
                TextField("Parler à SUPRA…", text: $chatDraft, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...6)
                    .onSubmit { sendChatDraft() }

                Button {
                    sendChatDraft()
                } label: {
                    if store.chatBusy {
                        ProgressView().controlSize(.small)
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                    }
                }
                .buttonStyle(.plain)
                .disabled(store.chatBusy || chatDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(18)
        }
    }

    private func startAutopilotIfNeeded() {
        guard !autopilotStarted else { return }
        autopilotStarted = true

        let names = appIntegrationCandidates
            .prefix(40)
            .map(\.name)
            .joined(separator: ", ")

        let prompt =
            "AUTOPILOT SUPRA. Analyse automatiquement les actifs et applications existants. "
            + "Cherche les possibilités prouvées de COMBINE, HYBRIDIZE, FUSE, SUPPLEMENT, REDUCE et AMPLIFY. "
            + "N'invente aucune preuve, ne modifie aucune source et n'exécute aucune action non allowlistée. "
            + "Travaille sans intervention humaine sur tout ce qui est sûr et réversible. "
            + "Retourne uniquement: travail automatique possible, blocages réels, puis la prochaine décision humaine importante si elle existe. "
            + "Candidats visibles: \(names).\n\n"
            + cannonicoIntegrationMissionPrompt

        Task {
            await store.sendChat(prompt)
        }
    }


    private func sendChatDraft() {
        let text = chatDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !store.chatBusy else { return }
        chatDraft = ""
        Task { await store.sendChat(text) }
    }

    private var executivePage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                hero

                metricsGrid

                if !store.model.alerts.isEmpty {
                    alertsPanel
                }

                sourcesPanel
            }
            .padding(28)
            .frame(maxWidth: 1440, alignment: .leading)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .navigationTitle("Executive")
        .toolbar {
            ToolbarItemGroup {
                Button {
                    store.load()
                } label: {
                    Label("Reload", systemImage: "arrow.clockwise")
                }

                Button {
                    store.revealModel()
                } label: {
                    Label("Reveal Model", systemImage: "doc.text.magnifyingglass")
                }
            }
        }
    }

    private var hero: some View {
        HStack(alignment: .center, spacing: 22) {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .frame(width: 92, height: 92)

                Image(systemName: "cpu.fill")
                    .font(.system(size: 42, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
            }

            VStack(alignment: .leading, spacing: 7) {
                Text(store.model.system.name)
                    .font(.system(size: 36, weight: .bold, design: .rounded))

                Text(store.model.system.subtitle)
                    .font(.title3)
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    statusBadge(store.model.system.status)

                    Text("Memory First")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(.thinMaterial, in: Capsule())
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text("Canonical sources")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(store.model.metrics.sourcesFound.formatted())
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .monospacedDigit()

                Text("connected")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(24)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
    }

    private var metricsGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.adaptive(minimum: 180), spacing: 14)
            ],
            spacing: 14
        ) {
            metricCard(
                title: "Projects",
                value: store.model.metrics.projects,
                icon: "folder"
            )

            metricCard(
                title: "Capabilities",
                value: store.model.metrics.capabilities,
                icon: "shippingbox"
            )

            metricCard(
                title: "Products",
                value: store.model.metrics.products,
                icon: "cube.box"
            )

            metricCard(
                title: "UI modules",
                value: store.model.metrics.uiModules,
                icon: "macwindow"
            )

            metricCard(
                title: "Memory",
                value: store.model.metrics.memoryObjects,
                icon: "brain"
            )

            metricCard(
                title: "Resources",
                value: store.model.metrics.resources,
                icon: "externaldrive"
            )
        }
    }

    private func metricCard(
        title: String,
        value: Int,
        icon: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)

                Spacer()

                Text(value > 0 ? "CONNECTED" : "MISSING")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(value > 0 ? .green : .orange)
            }

            Text(value.formatted())
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .monospacedDigit()

            Text(title)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
    }

    private var alertsPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                title: "Attention required",
                subtitle: "Sources non retrouvées dans les emplacements ciblés",
                icon: "exclamationmark.triangle"
            )

            ForEach(store.model.alerts) { alert in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(alert.title)
                            .font(.headline)

                        Text(alert.detail)
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
                .padding(14)
                .background(
                    Color.orange.opacity(0.08),
                    in: RoundedRectangle(cornerRadius: 14)
                )
            }
        }
    }

    private var sourcesPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                title: "Canonical lineage",
                subtitle: "Sources récupérées, sans réécriture du backend",
                icon: "point.3.connected.trianglepath.dotted"
            )

            ForEach(store.model.sources) { source in
                HStack(spacing: 12) {
                    Circle()
                        .fill(source.status == "CONNECTED" ? .green : .orange)
                        .frame(width: 8, height: 8)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(source.name)
                            .font(.headline)

                        Text(source.path ?? "Source non retrouvée")
                            .font(.caption.monospaced())
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .textSelection(.enabled)
                    }

                    Spacer()

                    Text(source.authority ?? "OBSERVED")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)

                Divider()
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    private func registryPage(
        title: String,
        subtitle: String,
        icon: String,
        records: [SUPRARecord]
    ) -> some View {
        VStack(spacing: 0) {
            pageHeader(
                title: title,
                subtitle: subtitle,
                icon: icon,
                count: records.count
            )

            if records.isEmpty {
                ContentUnavailableView(
                    "Registry source unavailable",
                    systemImage: icon,
                    description: Text(
                        "La façade n’invente aucune donnée. "
                        + "Le registre correspondant doit être reconnecté."
                    )
                )
            } else {
                List(records) { record in
                    HStack(spacing: 12) {
                        Image(systemName: icon)
                            .frame(width: 24)
                            .foregroundStyle(.secondary)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(record.name)
                                .font(.headline)

                            if let detail = record.detail {
                                Text(detail)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }

                            if let path = record.path {
                                Text(path)
                                    .font(.caption.monospaced())
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                    .textSelection(.enabled)
                            } else if title == "Projects" {
                                Text("Chemin non résolu")
                                    .font(.caption.monospaced())
                                    .foregroundStyle(.orange)
                            }
                        }

                        Spacer()

                        statusBadge(record.status)
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .navigationTitle(title)
    }

    private func sourcePage(
        title: String,
        subtitle: String,
        icon: String,
        matching names: [String]
    ) -> some View {
        let matchingSources = store.model.sources.filter {
            names.contains($0.name)
        }

        return VStack(spacing: 0) {
            pageHeader(
                title: title,
                subtitle: subtitle,
                icon: icon,
                count: matchingSources.filter { $0.status == "CONNECTED" }.count
            )

            List(matchingSources) { source in
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .frame(width: 28)

                    VStack(alignment: .leading, spacing: 7) {
                        Text(source.name)
                            .font(.headline)

                        Text(source.path ?? "Source non retrouvée")
                            .font(.callout.monospaced())
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)

                        Text(source.authority ?? "OBSERVED")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }

                    Spacer()

                    statusBadge(source.status)
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle(title)
    }

    private var interfacePage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                pageHeader(
                    title: "Interface",
                    subtitle: "Façade native connectée au modèle canonique",
                    icon: "macwindow",
                    count: store.model.metrics.uiModules
                )

                VStack(alignment: .leading, spacing: 14) {
                    interfaceRule(
                        title: "Backend",
                        value: "Réutilisé, non réécrit",
                        icon: "server.rack"
                    )

                    interfaceRule(
                        title: "Source de données",
                        value: "SUPRA_EXECUTIVE_UI_MODEL.json",
                        icon: "curlybraces.square"
                    )

                    interfaceRule(
                        title: "SwiftUI",
                        value: "Façade native macOS",
                        icon: "swift"
                    )

                    interfaceRule(
                        title: "Memory First",
                        value: "Actif",
                        icon: "brain"
                    )
                }
                .padding(20)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
            }
            .padding(28)
            .frame(maxWidth: 1100, alignment: .leading)
        }
        .navigationTitle("Interface")
    }

    private func interfaceRule(
        title: String,
        value: String,
        icon: String
    ) -> some View {
        HStack(spacing: 13) {
            Image(systemName: icon)
                .frame(width: 24)

            Text(title)
                .font(.headline)

            Spacer()

            Text(value)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 7)
    }

    private func pageHeader(
        title: String,
        subtitle: String,
        icon: String,
        count: Int
    ) -> some View {
        HStack(spacing: 18) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .semibold))
                .frame(width: 52, height: 52)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.largeTitle.bold())

                Text(subtitle)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(count.formatted())
                .font(.title.bold().monospacedDigit())
        }
        .padding(24)
        .background(.bar)
    }

    private func sectionHeader(
        title: String,
        subtitle: String,
        icon: String
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.title3.bold())

                Text(subtitle)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func statusBadge(_ status: String) -> some View {
        Text(status)
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .foregroundStyle(statusColor(status))
            .background(
                statusColor(status).opacity(0.12),
                in: Capsule()
            )
    }

    private func statusColor(_ status: String) -> Color {
        switch status.uppercased() {
        case "READY", "CONNECTED", "VALIDATED", "ACTIVE":
            return .green

        case "WARNING", "RECOVERY_REQUIRED", "SOURCE_MISSING", "DEGRADED":
            return .orange

        case "FAILED":
            return .red

        default:
            return .secondary
        }
    }
}


struct SUPRAChatMessage: Identifiable {
    let id = UUID()
    let role: String
    let text: String
}

private struct SUPRAChatRequest: Encodable {
    let message: String
}

private struct SUPRAChatResponse: Decodable {
    let status: String?
    let reply: String?
    let error: String?
}


// SUPRA_ACTION_CENTER_SECURE_V1_BEGIN
nonisolated struct SUPRAActionManifest: Decodable, Sendable {
    let schema: String
    let remoteExecution: Bool
    let freeShell: Bool
    let argumentsAllowed: Bool
    let actions: [SUPRAActionDefinition]
    enum CodingKeys: String, CodingKey {
        case schema, actions
        case remoteExecution = "remote_execution"
        case freeShell = "free_shell"
        case argumentsAllowed = "arguments_allowed"
    }
}

nonisolated struct SUPRAActionDefinition: Decodable, Identifiable, Sendable {
    let id: String
    let title: String
    let scriptPath: String
    let sha256: String
    let mode: String
    let requiresConfirmation: Bool
    let backupPaths: [String]
    let description: String
    enum CodingKeys: String, CodingKey {
        case id, title, sha256, mode, description
        case scriptPath = "script_path"
        case requiresConfirmation = "requires_confirmation"
        case backupPaths = "backup_paths"
    }
}

enum SUPRAActionError: LocalizedError {
    case invalidManifest, remoteExecutionForbidden, pathForbidden, hashMismatch
    case scriptMissing, confirmationMissing, mutationWithoutBackup, executionFailed(Int32)
    var errorDescription: String? {
        switch self {
        case .invalidManifest: return "Manifeste invalide."
        case .remoteExecutionForbidden: return "Exécution distante ou shell libre interdit."
        case .pathForbidden: return "Chemin hors des racines locales autorisées."
        case .hashMismatch: return "L’empreinte du script a changé."
        case .scriptMissing: return "Script allowlisté introuvable."
        case .confirmationMissing: return "Confirmation obligatoire absente."
        case .mutationWithoutBackup: return "Action mutante sans chemins de sauvegarde explicites."
        case .executionFailed(let code): return "Le script a échoué (code \(code)); rollback appliqué."
        }
    }
}

enum SUPRAActionRuntime {
    nonisolated static var centerURL: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("NOVA_OS/SUPRA_ACTION_CENTER_V1")
    }

    nonisolated static var manifestURL: URL {
        centerURL.appendingPathComponent("ALLOWLIST.json")
    }

    nonisolated static func loadManifest() throws -> SUPRAActionManifest {
        let manifest = try JSONDecoder().decode(SUPRAActionManifest.self, from: Data(contentsOf: manifestURL))
        guard manifest.schema == "SUPRA_ACTION_ALLOWLIST_V1" else { throw SUPRAActionError.invalidManifest }
        guard !manifest.remoteExecution && !manifest.freeShell && !manifest.argumentsAllowed else {
            throw SUPRAActionError.remoteExecutionForbidden
        }
        return manifest
    }

    nonisolated static func verify(_ action: SUPRAActionDefinition) throws {
        guard action.requiresConfirmation else { throw SUPRAActionError.confirmationMissing }
        let raw = URL(fileURLWithPath: action.scriptPath).resolvingSymlinksInPath()
        let home = FileManager.default.homeDirectoryForCurrentUser.resolvingSymlinksInPath().path + "/"
        let allowed = [home + "NOVA_OS/", home + "Downloads/", home + "Desktop/"]
        guard allowed.contains(where: { raw.path.hasPrefix($0) }) else { throw SUPRAActionError.pathForbidden }
        guard FileManager.default.fileExists(atPath: raw.path) else { throw SUPRAActionError.scriptMissing }
        let digest = SHA256.hash(data: try Data(contentsOf: raw)).map { String(format: "%02x", $0) }.joined()
        guard digest == action.sha256.lowercased() else { throw SUPRAActionError.hashMismatch }
        if action.mode != "READ_ONLY" && action.backupPaths.isEmpty { throw SUPRAActionError.mutationWithoutBackup }
    }

    nonisolated static func execute(_ action: SUPRAActionDefinition) throws -> String {
        try verify(action)
        let fm = FileManager.default
        let stamp = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")
        let run = centerURL.appendingPathComponent("ACTION_RUNS/\(stamp)-\(action.id)")
        let backup = run.appendingPathComponent("BACKUP")
        try fm.createDirectory(at: backup, withIntermediateDirectories: true)
        var saved: [(URL, URL)] = []
        for (index, value) in action.backupPaths.enumerated() {
            let source = URL(fileURLWithPath: value).resolvingSymlinksInPath()
            let destination = backup.appendingPathComponent("\(index)-\(source.lastPathComponent)")
            if fm.fileExists(atPath: source.path) { try fm.copyItem(at: source, to: destination); saved.append((source,destination)) }
        }
        let outputURL = run.appendingPathComponent("OUTPUT.log")
        fm.createFile(atPath: outputURL.path, contents: nil)
        let handle = try FileHandle(forWritingTo: outputURL)
        defer { try? handle.close() }
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [action.scriptPath]
        process.currentDirectoryURL = URL(fileURLWithPath: action.scriptPath).deletingLastPathComponent()
        process.environment = ["HOME": NSHomeDirectory(), "USER": NSUserName(), "PATH": "/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin", "LC_ALL": "C"]
        process.standardOutput = handle; process.standardError = handle
        try process.run(); process.waitUntilExit()
        if process.terminationStatus != 0 {
            for (source, copy) in saved.reversed() {
                if fm.fileExists(atPath: source.path) { try? fm.removeItem(at: source) }
                try? fm.copyItem(at: copy, to: source)
            }
            throw SUPRAActionError.executionFailed(process.terminationStatus)
        }
        let text = (try? String(contentsOf: outputURL, encoding: .utf8)) ?? ""
        return "EXECUTION=PASS\nID=\(action.id)\nRUN=\(run.path)\n\n" + String(text.suffix(12000))
    }
}
// SUPRA_ACTION_CENTER_SECURE_V1_END

@MainActor
final class SUPRAExecutiveStore: ObservableObject {
    @Published private(set) var model: SUPRAExecutiveModel = .fallback
    @Published private(set) var monetizableOpportunities: [SUPRARecord] = []
    @Published private(set) var actions: [SUPRAActionDefinition] = []
    @Published private(set) var actionOutput = ""
    @Published private(set) var actionBusy = false

    @Published private(set) var chatMessages: [SUPRAChatMessage] = []
    @Published private(set) var chatBusy = false
    @Published private(set) var chatConnected = false

    private let chatURL = URL(string: "http://127.0.0.1:18765/v1/chat")!

    func sendChat(_ text: String) async {
        chatMessages.append(SUPRAChatMessage(role: "user", text: text))
        chatBusy = true
        defer { chatBusy = false }

        do {
            var request = URLRequest(url: chatURL)
            request.timeoutInterval = 600
            request.httpMethod = "POST"
            request.timeoutInterval = 180
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("SUPRA.app", forHTTPHeaderField: "X-SUPRA-Client")
            request.httpBody = try JSONEncoder().encode(SUPRAChatRequest(message: text))

            // SUPRA_MISSION_EVIDENCE_INJECTION_V1_BEGIN

            guard let originalRequestBody = request.httpBody,
                  var localBridgePayload = try JSONSerialization.jsonObject(
                      with: originalRequestBody
                  ) as? [String: Any]
            else {
                throw URLError(.cannotParseResponse)
            }

            let missionEvidence =
                SUPRAMissionEvidenceLoader.loadRequiredEvidence()

            let requiredMissionEvidence = Set([
                "GRAPH_SCHEMA_PROBE",
                "STATUS"
            ])

            let loadedMissionEvidence = Set(
                missionEvidence.map(\.evidenceId)
            )

            guard requiredMissionEvidence.isSubset(
                of: loadedMissionEvidence
            ) else {
                let missingEvidence = requiredMissionEvidence
                    .subtracting(loadedMissionEvidence)
                    .sorted()
                    .joined(separator: ", ")

                throw NSError(
                    domain: "SUPRA.MissionContextLoader",
                    code: 1,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "Mission evidence missing: \(missingEvidence)"
                    ]
                )
            }

            SUPRAMissionEvidenceLoader
                .removePlaceholderMissionEvidence(
                    from: &localBridgePayload
                )

            localBridgePayload["mission_evidence"] =
                missionEvidence.map { evidence in
                    [
                        "evidence_id": evidence.evidenceId,
                        "source_path": evidence.sourcePath,
                        "content_type": evidence.contentType,
                        "content": evidence.content
                    ]
                }

            request.httpBody = try JSONSerialization.data(
                withJSONObject: localBridgePayload,
                options: []
            )

            // SUPRA_MISSION_EVIDENCE_INJECTION_V1_END

            let configuration = URLSessionConfiguration.ephemeral
            configuration.timeoutIntervalForRequest = 600
            configuration.timeoutIntervalForResource = 900
            configuration.waitsForConnectivity = true
            let session = URLSession(configuration: configuration)
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            let payload = try JSONDecoder().decode(SUPRAChatResponse.self, from: data)
            guard (200..<300).contains(http.statusCode), payload.status == "PASS", let reply = payload.reply else {
                throw NSError(
                    domain: "SUPRABridge",
                    code: http.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: payload.error ?? "Réponse invalide du bridge"]
                )
            }
            chatConnected = true
            chatMessages.append(SUPRAChatMessage(role: "assistant", text: reply))
        } catch {
            chatConnected = false
            chatMessages.append(
                SUPRAChatMessage(role: "assistant", text: "Bridge indisponible : \(error.localizedDescription)")
            )
        }
    }


    private var modelURL: URL? {
        Bundle.main.url(
            forResource: "SUPRA_EXECUTIVE_UI_MODEL",
            withExtension: "json"
        )
    }

    func load() {
        loadActions()

        guard let modelURL else {
            model = .fallback.withAlert(
                title: "UI model missing from application bundle",
                detail: "SUPRA_EXECUTIVE_UI_MODEL.json n’est pas inclus dans le bundle."
            )
            monetizableOpportunities = []
            return
        }

        do {
            let data = try Data(contentsOf: modelURL)
            let decoder = JSONDecoder()
            let baseModel = try decoder.decode(
                SUPRAExecutiveModel.self,
                from: data
            )

            do {
                let connection = try baseModel.connectingSemanticProductFeeds()
                model = connection.model
                monetizableOpportunities = connection.opportunities
            } catch {
                model = baseModel.withAlert(
                    title: "Semantic product feed unavailable",
                    detail: error.localizedDescription
                )
                monetizableOpportunities = []
            }
        } catch {
            model = .fallback.withAlert(
                title: "UI model decoding failed",
                detail: error.localizedDescription
            )
            monetizableOpportunities = []
        }
    }


    func loadActions() {
        do {
            actions = try SUPRAActionRuntime.loadManifest().actions
            actionOutput = "Allowlist chargée : \(actions.count) action(s)."
        } catch {
            actions = []
            actionOutput = "Allowlist indisponible : \(error.localizedDescription)"
        }
    }

    func verify(_ action: SUPRAActionDefinition) {
        do {
            try SUPRAActionRuntime.verify(action)
            actionOutput = "VERIFY=PASS\nID=\(action.id)\nSHA256=\(action.sha256)\nMODE=\(action.mode)"
        } catch {
            actionOutput = "VERIFY=FAILED\nID=\(action.id)\nERROR=\(error.localizedDescription)"
        }
    }

    func execute(_ action: SUPRAActionDefinition) async {
        actionBusy = true
        actionOutput = "EXECUTION=START\nID=\(action.id)"
        do {
            let output = try await Task.detached(priority: .userInitiated) {
                try SUPRAActionRuntime.execute(action)
            }.value
            actionOutput = output
        } catch {
            actionOutput = "EXECUTION=FAILED\nID=\(action.id)\nERROR=\(error.localizedDescription)"
        }
        actionBusy = false
    }

    func revealModel() {
        guard let modelURL else {
            return
        }

        NSWorkspace.shared.activateFileViewerSelecting([modelURL])
    }
}

struct SUPRAExecutiveModel: Codable {
    let schema: String
    let generatedAt: String
    let mode: String
    let memoryFirst: Bool
    let backendRewritten: Bool
    let swiftuiRole: String
    let system: SUPRASystem
    let metrics: SUPRAMetrics
    let sections: [SUPRASection]
    let projects: [SUPRARecord]
    let capabilities: [SUPRARecord]
    let products: [SUPRARecord]
    let sources: [SUPRASource]
    let alerts: [SUPRAAlert]

    enum CodingKeys: String, CodingKey {
        case schema
        case generatedAt = "generated_at"
        case mode
        case memoryFirst = "memory_first"
        case backendRewritten = "backend_rewritten"
        case swiftuiRole = "swiftui_role"
        case system
        case metrics
        case sections
        case projects
        case capabilities
        case products
        case sources
        case alerts
    }

    static let fallback = SUPRAExecutiveModel(
        schema: "SUPRA_EXECUTIVE_UI_MODEL_V1",
        generatedAt: "",
        mode: "RECOVERY",
        memoryFirst: true,
        backendRewritten: false,
        swiftuiRole: "FACADE_ONLY",
        system: SUPRASystem(
            name: "SUPRA",
            subtitle: "Executive Operating System",
            status: "DEGRADED",
            canonicalSource: nil,
            runtimeSource: nil,
            atlasSource: nil
        ),
        metrics: SUPRAMetrics(
            projects: 0,
            capabilities: 0,
            products: 0,
            uiModules: 0,
            memoryObjects: 0,
            resources: 0,
            sourcesFound: 0,
            sourcesMissing: 0
        ),
        sections: [
            SUPRASection(
                id: "executive",
                title: "Executive",
                systemImage: "crown",
                subtitle: "Recovery mode",
                count: 0,
                status: "DEGRADED"
            )
        ],
        projects: [],
        capabilities: [],
        products: [],
        sources: [],
        alerts: []
    )

    func withAlert(
        title: String,
        detail: String
    ) -> SUPRAExecutiveModel {
        SUPRAExecutiveModel(
            schema: schema,
            generatedAt: generatedAt,
            mode: mode,
            memoryFirst: memoryFirst,
            backendRewritten: backendRewritten,
            swiftuiRole: swiftuiRole,
            system: system,
            metrics: metrics,
            sections: sections,
            projects: projects,
            capabilities: capabilities,
            products: products,
            sources: sources,
            alerts: alerts + [
                SUPRAAlert(
                    id: UUID().uuidString,
                    severity: "FAILED",
                    title: title,
                    detail: detail
                )
            ]
        )
    }
}


// SUPRA_PRODUCTS_SEMANTIC_V4_BEGIN
private struct SUPRASemanticProjectsFeed: Decodable {
    let projects: [SUPRASemanticProject]
}

private struct SUPRASemanticProject: Decodable {
    let projectID: String
    let name: String
    let classification: String
    let paths: [String]
    let capabilities: [String]
    let observationCount: Int
    enum CodingKeys: String, CodingKey {
        case projectID = "project_id"
        case name, classification, paths, capabilities
        case observationCount = "observation_count"
    }
}

private struct SUPRASemanticProductsFeed: Decodable {
    let products: [SUPRASemanticProduct]
    let capabilityOpportunities: [SUPRAFacadeCandidate]

    enum CodingKeys: String, CodingKey {
        case products
        case capabilityOpportunities = "capability_opportunities"
    }
}

private struct SUPRASemanticProduct: Decodable {
    let id: String
    let name: String
    let classification: String
    let identityAuthority: String
    let path: String?
    let score: Double
    let evidenceCount: Int
    let launchedProductProven: Bool
    let goal: String?

    enum CodingKeys: String, CodingKey {
        case id, name, classification, path, score, goal
        case identityAuthority = "identity_authority"
        case evidenceCount = "evidence_count"
        case launchedProductProven = "launched_product_proven"
    }
}

private struct SUPRAFacadeCandidate: Decodable {
    let candidateID: String
    let name: String
    let status: String
    let declaredAction: String
    let declaredRank: Int
    let matchedReconciledProjectCount: Int
    let maturityScoreDeclared: Double
    let notALaunchedProduct: Bool

    enum CodingKeys: String, CodingKey {
        case candidateID = "candidate_id"
        case name, status
        case declaredAction = "declared_action"
        case declaredRank = "declared_rank"
        case matchedReconciledProjectCount = "matched_reconciled_project_count"
        case maturityScoreDeclared = "maturity_score_declared"
        case notALaunchedProduct = "not_a_launched_product"
    }
}

private struct SUPRASemanticFacadeConnection {
    let model: SUPRAExecutiveModel
    let opportunities: [SUPRARecord]
}

private enum SUPRASemanticFeedError: LocalizedError {
    case zeroProducts
    case invalidOpportunities(Int)
    case unprovenLaunch
    var errorDescription: String? {
        switch self {
        case .zeroProducts: return "Le registre sémantique Products est vide."
        case .invalidOpportunities(let count): return "Opportunités: \(count), attendu: 20."
        case .unprovenLaunch: return "Un produit non prouvé a été marqué comme lancé."
        }
    }
}

private extension SUPRAExecutiveModel {
    func connectingSemanticProductFeeds() throws -> SUPRASemanticFacadeConnection {
        let root = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("NOVA_OS/SUPRA_STREAM_RECONCILIATION_V1/CURRENT", isDirectory: true)
        let url = root.appendingPathComponent("04_PRODUCTS_SEMANTIC_V4.json")
        let projectsURL = root.appendingPathComponent("02_PROJECTS_RECONCILED_FEED.json")
        let decoder = JSONDecoder()
        let feed = try decoder.decode(
            SUPRASemanticProductsFeed.self,
            from: Data(contentsOf: url, options: [.mappedIfSafe])
        )
        let projectsFeed = try decoder.decode(
            SUPRASemanticProjectsFeed.self,
            from: Data(contentsOf: projectsURL, options: [.mappedIfSafe])
        )
        guard projectsFeed.projects.count == 3200 else {
            throw NSError(domain: "SUPRAProjects", code: 3200, userInfo: [NSLocalizedDescriptionKey: "Flux Projects refusé: \(projectsFeed.projects.count), attendu: 3200."])
        }
        guard !feed.products.isEmpty else { throw SUPRASemanticFeedError.zeroProducts }
        guard feed.capabilityOpportunities.count == 20 else {
            throw SUPRASemanticFeedError.invalidOpportunities(feed.capabilityOpportunities.count)
        }
        guard feed.products.allSatisfy({ !$0.launchedProductProven }) else {
            throw SUPRASemanticFeedError.unprovenLaunch
        }

        let connectedProjects = projectsFeed.projects.map { item in
            SUPRARecord(
                id: item.projectID,
                name: item.name,
                status: item.classification,
                path: item.paths.first,
                score: nil,
                detail: "\(item.capabilities.count) capacités · \(item.observationCount) observations"
            )
        }
        let productRecords = feed.products.map { item in
            SUPRARecord(
                id: item.id,
                name: item.name,
                status: item.classification,
                path: item.path,
                score: item.score,
                detail: item.goal ?? "\(item.evidenceCount) preuves · autorité: \(item.identityAuthority)"
            )
        }
        let opportunityRecords = feed.capabilityOpportunities.map { item in
            SUPRARecord(
                id: item.candidateID,
                name: item.name,
                status: "MONETIZABLE_CAPABILITY",
                path: nil,
                score: item.maturityScoreDeclared,
                detail: "\(item.declaredAction) · rang déclaré \(item.declaredRank) · \(item.matchedReconciledProjectCount) projets liés"
            )
        }
        let connectedMetrics = SUPRAMetrics(
            projects: connectedProjects.count,
            capabilities: metrics.capabilities,
            products: productRecords.count,
            uiModules: metrics.uiModules,
            memoryObjects: metrics.memoryObjects,
            resources: metrics.resources,
            sourcesFound: metrics.sourcesFound,
            sourcesMissing: max(0, metrics.sourcesMissing - 1)
        )
        let connectedSections = sections.map { section in
            SUPRASection(
                id: section.id,
                title: section.title,
                systemImage: section.systemImage,
                subtitle: section.subtitle,
                count: section.id == "products" ? productRecords.count : (section.id == "projects" ? connectedProjects.count : section.count),
                status: section.status
            )
        }
        let connectedSources = sources.map { source in
            guard source.name == "PRODUCT_REGISTRY" else { return source }
            return SUPRASource(
                name: source.name,
                path: url.path,
                status: "CONNECTED",
                authority: "RECONCILED_EVIDENCE",
                priority: source.priority
            )
        }
        let connectedAlerts = alerts.filter {
            !(($0.title + " " + $0.detail).uppercased().contains("PRODUCT_REGISTRY"))
        }
        let connectedModel = SUPRAExecutiveModel(
            schema: schema,
            generatedAt: generatedAt,
            mode: mode,
            memoryFirst: memoryFirst,
            backendRewritten: backendRewritten,
            swiftuiRole: swiftuiRole,
            system: system,
            metrics: connectedMetrics,
            sections: connectedSections,
            projects: connectedProjects,
            capabilities: capabilities,
            products: productRecords,
            sources: connectedSources,
            alerts: connectedAlerts
        )
        return SUPRASemanticFacadeConnection(model: connectedModel, opportunities: opportunityRecords)
    }
}
// SUPRA_PRODUCTS_SEMANTIC_V4_END

struct SUPRASystem: Codable {
    let name: String
    let subtitle: String
    let status: String
    let canonicalSource: String?
    let runtimeSource: String?
    let atlasSource: String?

    enum CodingKeys: String, CodingKey {
        case name
        case subtitle
        case status
        case canonicalSource = "canonical_source"
        case runtimeSource = "runtime_source"
        case atlasSource = "atlas_source"
    }
}

struct SUPRAMetrics: Codable {
    let projects: Int
    let capabilities: Int
    let products: Int
    let uiModules: Int
    let memoryObjects: Int
    let resources: Int
    let sourcesFound: Int
    let sourcesMissing: Int

    enum CodingKeys: String, CodingKey {
        case projects
        case capabilities
        case products
        case uiModules = "ui_modules"
        case memoryObjects = "memory_objects"
        case resources
        case sourcesFound = "sources_found"
        case sourcesMissing = "sources_missing"
    }
}




struct SUPRAAlert: Codable, Identifiable {
    let id: String
    let severity: String
    let title: String
    let detail: String

    init(
        id: String = UUID().uuidString,
        severity: String,
        title: String,
        detail: String
    ) {
        self.id = id
        self.severity = severity
        self.title = title
        self.detail = detail
    }

    enum CodingKeys: String, CodingKey {
        case severity
        case title
        case detail
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        severity = try container.decode(String.self, forKey: .severity)
        title = try container.decode(String.self, forKey: .title)
        detail = try container.decode(String.self, forKey: .detail)

        id = "\(severity):\(title)"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(severity, forKey: .severity)
        try container.encode(title, forKey: .title)
        try container.encode(detail, forKey: .detail)
    }
}

#Preview {
    ContentView()
        .frame(width: 1200, height: 760)
}


// MARK: - SUPRA LIVE CURRENT BOARDS V1

private enum SUPRALiveSection: String, CaseIterable, Identifiable {
    case workspace = "Workspace"
    case architecture = "Architecture"
    case authority = "Authority Gate"
    case storage = "Storage"
    case decisions = "Decision Inbox"
    case system = "Live System Status"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .workspace: return "rectangle.3.group"
        case .architecture: return "point.3.connected.trianglepath.dotted"
        case .authority: return "checkmark.shield"
        case .storage: return "internaldrive"
        case .decisions: return "tray.full"
        case .system: return "waveform.path.ecg"
        }
    }
}

private struct SUPRALiveSnapshot {
    var architectureStatus = "UNAVAILABLE"
    var architectureVerdict = "No current architecture board"
    var authorityStatus = "UNAVAILABLE"
    var authorityVerdict = "No current authority board"
    var authorityGate = "UNKNOWN"
    var storageStatus = "UNAVAILABLE"
    var recovered = "—"
    var reviewVolume = "—"
    var reviewItems = 0
    var storageNext = "No storage decision board"
    var updatedAt = Date()
}

@MainActor
private final class SUPRALiveBoardsModel: ObservableObject {
    @Published var snapshot = SUPRALiveSnapshot()
    @Published var lastError: String?

    private var timer: Timer?
    private let home = FileManager.default.homeDirectoryForCurrentUser

    private var architectureURL: URL {
        home.appendingPathComponent("NOVA_OS/SUPRA_READ_RECONCILED_VERDICT_AND_REPUBLISH_ARCHITECTURE_DECISION_BOARD_V1/CURRENT/DECISION_BOARD.json")
    }

    private var authorityURL: URL {
        home.appendingPathComponent("NOVA_OS/SUPRA_RESOLVE_AUTHORITY_FIELD_LINEAGE_AND_CLOSE_SINGLE_HUMAN_GATE_V1/CURRENT/DECISION_BOARD_AUTHORITY_FINAL.json")
    }

    private var storageURL: URL {
        home.appendingPathComponent("NOVA_OS/SUPRA_EXECUTE_APPROVED_DERIVED_DATA_BATCH_AND_BUILD_REVIEW_BOARD_FOR_26_70_GB_V1/CURRENT/STORAGE_DECISION_BOARD_AFTER_DERIVED_DATA.json")
    }

    func start() {
        stop()
        reload()
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.reload()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func reload() {
        do {
            let architecture = try readObject(architectureURL)
            let authority = try readObject(authorityURL)
            let storage = try readObject(storageURL)

            var next = SUPRALiveSnapshot()
            next.architectureStatus = text(architecture["status"], fallback: "UNKNOWN")
            next.architectureVerdict = text(architecture["verdict"], fallback: "No verdict")
            next.authorityStatus = text(authority["status"], fallback: "UNKNOWN")
            next.authorityVerdict = text(authority["verdict"], fallback: "No verdict")

            if let gate = authority["single_human_gate"] as? [String: Any] {
                next.authorityGate = text(gate["status"], fallback: "UNKNOWN")
            }

            next.storageStatus = text(storage["status"], fallback: "UNKNOWN")
            next.recovered = text(storage["derived_data_recovered_human"], fallback: "—")
            next.reviewVolume = text(storage["remaining_review_total_human"], fallback: "—")
            next.reviewItems = storage["remaining_review_items"] as? Int ?? 0
            next.storageNext = text(storage["next_action"], fallback: "No next action")
            next.updatedAt = Date()

            snapshot = next
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }

    func openArchitectureEvidence() {
        NSWorkspace.shared.open(architectureURL)
    }

    func openAuthorityEvidence() {
        NSWorkspace.shared.open(authorityURL)
    }

    func openStorageEvidence() {
        NSWorkspace.shared.open(storageURL)
    }

    private func readObject(_ url: URL) throws -> [String: Any] {
        let data = try Data(contentsOf: url, options: [.mappedIfSafe])
        guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(
                domain: "SUPRALiveBoards",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid JSON object: \(url.path)"]
            )
        }
        return object
    }

    private func text(_ value: Any?, fallback: String) -> String {
        guard let value else { return fallback }
        return String(describing: value)
    }
}

struct SUPRALiveBoardsRootView: View {
    @StateObject private var model = SUPRALiveBoardsModel()
    @State private var selection: SUPRALiveSection? = .workspace

    var body: some View {
        NavigationSplitView {
            List(SUPRALiveSection.allCases, selection: $selection) { section in
                Label(section.rawValue, systemImage: section.icon)
                    .tag(section)
            }
            .navigationTitle("SUPRA")
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(model.lastError == nil ? Color.green : Color.orange)
                        .frame(width: 8, height: 8)

                    Text(model.lastError == nil ? "CURRENT connected" : "CURRENT degraded")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()
                }
                .padding(12)
            }
        } detail: {
            detailView
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(Color(nsColor: .windowBackgroundColor))
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 1120, minHeight: 720)
        .onAppear { model.start() }
        .onDisappear { model.stop() }
    }

    @ViewBuilder
    private var detailView: some View {
        switch selection ?? .workspace {
        case .workspace:
            SUPRAWorkspaceLiveView(model: model)
        case .architecture:
            SUPRAArchitectureLiveView(model: model)
        case .authority:
            SUPRAAuthorityLiveView(model: model)
        case .storage:
            SUPRAStorageLiveView(model: model)
        case .decisions:
            SUPRADecisionInboxLiveView(model: model)
        case .system:
            SUPRASystemLiveView(model: model)
        }
    }
}

private struct SUPRAWorkspaceLiveView: View {
    @ObservedObject var model: SUPRALiveBoardsModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SUPRAHeader(
                    title: "Workspace",
                    subtitle: "Architecture, authority and storage in one native surface"
                )

                HStack(spacing: 16) {
                    SUPRAStatusCard(
                        title: "Architecture",
                        status: model.snapshot.architectureStatus,
                        detail: model.snapshot.architectureVerdict,
                        color: .green
                    )

                    SUPRAStatusCard(
                        title: "Authority",
                        status: model.snapshot.authorityGate,
                        detail: model.snapshot.authorityVerdict,
                        color: .blue
                    )

                    SUPRAStatusCard(
                        title: "Storage",
                        status: model.snapshot.storageStatus,
                        detail: "Recovered \(model.snapshot.recovered) · Review \(model.snapshot.reviewVolume)",
                        color: .orange
                    )
                }

                SUPRAActionCard(
                    title: "Human decisions",
                    actions: [
                        "Resolve authority lineage",
                        "Review \(model.snapshot.reviewVolume)",
                        "Approve only explicit storage paths"
                    ],
                    icon: "person.fill.questionmark",
                    color: .purple
                )
            }
            .padding(28)
        }
    }
}

private struct SUPRAArchitectureLiveView: View {
    @ObservedObject var model: SUPRALiveBoardsModel

    var body: some View {
        SUPRADetailPage(
            title: "Architecture",
            status: model.snapshot.architectureStatus,
            verdict: model.snapshot.architectureVerdict,
            actionTitle: "Open architecture evidence",
            action: model.openArchitectureEvidence
        )
    }
}

private struct SUPRAAuthorityLiveView: View {
    @ObservedObject var model: SUPRALiveBoardsModel

    var body: some View {
        SUPRADetailPage(
            title: "Authority Gate",
            status: model.snapshot.authorityGate,
            verdict: model.snapshot.authorityVerdict,
            actionTitle: "Open authority lineage",
            action: model.openAuthorityEvidence
        )
    }
}

private struct SUPRAStorageLiveView: View {
    @ObservedObject var model: SUPRALiveBoardsModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SUPRAHeader(
                    title: "Storage",
                    subtitle: "Approved cleanup and explicit review"
                )

                HStack(spacing: 16) {
                    SUPRAStatusCard(
                        title: "Recovered",
                        status: model.snapshot.recovered,
                        detail: "DerivedData approved batch",
                        color: .green
                    )

                    SUPRAStatusCard(
                        title: "Review volume",
                        status: model.snapshot.reviewVolume,
                        detail: "\(model.snapshot.reviewItems) explicit items",
                        color: .orange
                    )
                }

                SUPRAActionCard(
                    title: "Next decision",
                    actions: [model.snapshot.storageNext],
                    icon: "arrow.triangle.branch",
                    color: .blue
                )

                Button("Open storage evidence", action: model.openStorageEvidence)
                    .buttonStyle(.borderedProminent)
            }
            .padding(28)
        }
    }
}

private struct SUPRADecisionInboxLiveView: View {
    @ObservedObject var model: SUPRALiveBoardsModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SUPRAHeader(
                    title: "Decision Inbox",
                    subtitle: "Human gates only"
                )

                SUPRAActionCard(
                    title: "Authority",
                    actions: [
                        "Gate: \(model.snapshot.authorityGate)",
                        "Resolve missing explicit lineage"
                    ],
                    icon: "person.badge.key.fill",
                    color: .purple
                )

                SUPRAActionCard(
                    title: "Storage",
                    actions: [
                        "Review \(model.snapshot.reviewVolume)",
                        "Keep / move / delete per explicit item"
                    ],
                    icon: "externaldrive.fill",
                    color: .orange
                )
            }
            .padding(28)
        }
    }
}

private struct SUPRASystemLiveView: View {
    @ObservedObject var model: SUPRALiveBoardsModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SUPRAHeader(
                    title: "Live System Status",
                    subtitle: "Read-only CURRENT board connection"
                )

                SUPRAStatusCard(
                    title: "Connection",
                    status: model.lastError == nil ? "CONNECTED" : "DEGRADED",
                    detail: model.lastError ?? "All CURRENT boards readable",
                    color: model.lastError == nil ? .green : .red
                )

                Text(
                    "Last refresh: \(model.snapshot.updatedAt.formatted(date: .numeric, time: .standard))"
                )
                .foregroundStyle(.secondary)

                Button("Refresh now") {
                    model.reload()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(28)
        }
    }
}

private struct SUPRADetailPage: View {
    let title: String
    let status: String
    let verdict: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SUPRAHeader(title: title, subtitle: "Live CURRENT board")

                SUPRAStatusCard(
                    title: "Status",
                    status: status,
                    detail: verdict,
                    color: .blue
                )

                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
            }
            .padding(28)
        }
    }
}

private struct SUPRAHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 34, weight: .bold))

            Text(subtitle)
                .foregroundStyle(.secondary)
        }
    }
}


