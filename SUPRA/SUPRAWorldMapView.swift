import SwiftUI
import Combine

struct WorldNode: Identifiable {
    let id = UUID()
    let name: String
    let type: WorldNodeType
    let state: String
    let confidence: Double
    let origin: String
    let explanation: String
    let possibleAction: String
    let color: Color
    let children: [WorldNode]
    let position: CGPoint
}

enum WorldNodeType: String, Codable {
    case hardware, software, twin, engine, mission, decision, memory, storage
}

@MainActor
final class SUPRAWorldMapState: ObservableObject {
    static let shared = SUPRAWorldMapState()

    @Published private(set) var nodes: [WorldNode] = []
    @Published private(set) var selectedNode: WorldNode?
    @Published private(set) var lastUpdated: Date?

    private let governor = SUPRAResourceGovernor.shared
    private let hardwareTwin = SUPRAHardwareTwin.shared
    private let softwareTwin = SUPRASoftwareTwin.shared
    private let dataTwin = SUPRADataTwin.shared
    private let developerTwin = SUPRADeveloperTwin.shared
    private let intelligence = SUPRAResourceIntelligenceEngine.shared
    private let evolution = SUPRAEvolutionEngine.shared
    private let recommendations = SUPRARecommendationEngine.shared

    private init() {}

    func refresh() {
        var newNodes: [WorldNode] = []
        var x: CGFloat = 0

        let hw = hardwareTwin.snapshot
        let sw = softwareTwin.snapshot

        newNodes.append(WorldNode(name: "CPU", type: .hardware,
            state: hw.map { "\(Int($0.cpuUsage * 100))%" } ?? "—",
            confidence: 0.92, origin: "host_statistics()", explanation: "Mesure directe des ticks CPU noyau",
            possibleAction: intelligence.anomalies.first { $0.domain == "CPU" }?.action ?? "Aucune action requise",
            color: (hw?.cpuUsage ?? 0) > 0.8 ? .supraRed : .supraGreen,
            children: [], position: CGPoint(x: x, y: 0)))
        x += 1

        newNodes.append(WorldNode(name: "RAM", type: .hardware,
            state: hw.map { "\(Int($0.ramUsedGB))/\(Int($0.physicalRAMGB))GB" } ?? "—",
            confidence: 0.90, origin: "vm_statistics64()", explanation: "Pages actives + wire size",
            possibleAction: governor.ramFraction > 0.85 ? "Fermer les applications inutilisées" : "OK",
            color: governor.ramFraction > 0.85 ? .supraOrange : .supraBlue,
            children: [], position: CGPoint(x: x, y: 0)))
        x += 1

        newNodes.append(WorldNode(name: "Stockage", type: .storage,
            state: hw.map { "\(Int($0.storageFreeGB))GB libre" } ?? "—",
            confidence: 0.88, origin: "URLResourceValues", explanation: "Capacité volume / disponible",
            possibleAction: (hw?.storageFreeGB ?? 0) < 20 ? "Nettoyer DerivedData et corbeille" : "Espace suffisant",
            color: (hw?.storageFreeGB ?? 0) > 20 ? .supraGreen : .supraOrange,
            children: [], position: CGPoint(x: x, y: 0)))
        x += 1

        newNodes.append(WorldNode(name: "Software", type: .software,
            state: sw.map { "\($0.applicationCount) apps" } ?? "—",
            confidence: 0.85, origin: "NSWorkspace + /Applications", explanation: "Applications, services, LaunchAgents, extensions",
            possibleAction: (sw?.launchAgentsCount ?? 0) > 50 ? "Désactiver les LaunchAgents inutiles" : "OK",
            color: .supraPurple, children: [], position: CGPoint(x: x, y: 0)))
        x += 1

        newNodes.append(WorldNode(name: "Evolution", type: .engine,
            state: "\(evolution.autoExecutedCount) auto",
            confidence: evolution.proposals.last?.confidence ?? 0,
            origin: "SUPRAEvolutionEngine", explanation: "Cycle Observe → Detect → Score Φ → Auto/Human",
            possibleAction: "\(evolution.humanPending.count) décisions humaines en attente",
            color: .supraGreen, children: [], position: CGPoint(x: x, y: 0)))
        x += 1

        newNodes.append(WorldNode(name: "Recommendations", type: .engine,
            state: "\(recommendations.active.count) actives",
            confidence: recommendations.active.first?.confidence ?? 0,
            origin: "SUPRARecommendationEngine", explanation: "Analyse des ressources et opportunités",
            possibleAction: "\(recommendations.autoExecutable.count) auto, \(recommendations.humanRequired.count) humain",
            color: .supraAccent, children: [], position: CGPoint(x: x, y: 0)))
        x += 1

        nodes = newNodes
        lastUpdated = Date()
    }

    func select(_ node: WorldNode) {
        selectedNode = node
    }
}

struct SUPRAWorldMapView: View {
    @StateObject private var state = SUPRAWorldMapState.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacing) {
                header
                mapView
                if let selected = state.selectedNode {
                    nodeDetail(selected)
                }
            }
            .padding(SUPRAOSDesignSystem.padding)
            .frame(maxWidth: 1280, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(Color.supraBackground)
        .onAppear { state.refresh() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("SUPRA WORLD MAP").font(.caption.weight(.bold)).tracking(2).foregroundColor(.supraAccent)
            Text("Visualisation spatiale des nœuds systèmes")
                .font(.system(size: 14)).foregroundColor(.supraTextSecondary)
            if let d = state.lastUpdated {
                Text("Actualisé: \(d.formatted(date: .omitted, time: .standard))")
                    .font(.caption2).foregroundColor(.supraTextTertiary)
            }
        }
    }

    private var mapView: some View {
        VStack(spacing: 16) {
            // Connection lines
            ZStack(alignment: .topLeading) {
                // Background
                RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadius)
                    .fill(Color.supraSurface)
                    .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadius).stroke(Color.supraBorder, lineWidth: 1))

                // Node grid
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 12)], spacing: 12) {
                    ForEach(state.nodes) { node in
                        nodeCard(node)
                            .onTapGesture { state.select(node) }
                    }
                }
                .padding(SUPRAOSDesignSystem.padding)
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadius))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadius).stroke(Color.supraBorder, lineWidth: 1))
    }

    private func nodeCard(_ node: WorldNode) -> some View {
        let isSelected = state.selectedNode?.id == node.id
        return VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(node.color.opacity(isSelected ? 0.25 : 0.12))
                    .frame(width: 56, height: 56)
                Circle()
                    .stroke(node.color, lineWidth: isSelected ? 3 : 1.5)
                    .frame(width: 56, height: 56)
                Text(String(node.name.prefix(2)))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(node.color)
            }

            Text(node.name).font(.system(size: 11, weight: .semibold)).foregroundColor(.supraText)

            HStack(spacing: 4) {
                Circle().fill(stateColor(node.state)).frame(width: 4, height: 4)
                Text(node.state).font(.system(size: 8)).foregroundColor(.supraTextSecondary).lineLimit(1)
            }

            SUPRAOSBadge(text: "Φ \(Int(node.confidence * 100))%", color: node.confidence > 0.85 ? .supraGreen : .supraOrange)
        }
        .frame(maxWidth: .infinity)
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(isSelected ? node.color.opacity(0.06) : Color.supraGlass)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(isSelected ? node.color : Color.supraBorder, lineWidth: isSelected ? 2 : 1))
        .scaleEffect(isSelected ? 1.05 : 1)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    private func nodeDetail(_ node: WorldNode) -> some View {
        SUPRAOSCard(
            title: "\(node.name) — DÉTAIL",
            subtitle: "Nœud \(node.type.rawValue)",
            icon: "info.circle.fill",
            color: node.color
        ) {
            VStack(alignment: .leading, spacing: 8) {
                detailRow("État", node.state, node.color)
                detailRow("Confiance Φ", "\(Int(node.confidence * 100))%", .supraAccent)
                detailRow("Origine", node.origin, .supraTextSecondary)
                detailRow("Explication", node.explanation, .supraText)
                detailRow("Action possible", node.possibleAction, .supraGreen)
            }
        }
    }

    private func detailRow(_ label: String, _ value: String, _ color: Color) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(label.uppercased()).font(.system(size: 8, weight: .semibold)).foregroundColor(.supraTextTertiary)
                .frame(width: 64, alignment: .trailing)
            Text(value).font(.system(size: 11)).foregroundColor(color)
            Spacer()
        }
    }

    private func stateColor(_ state: String) -> Color {
        if state.contains("%") {
            let v = state.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
            if let i = Int(v) { return i > 80 ? .supraRed : i > 50 ? .supraOrange : .supraGreen }
        }
        if state.contains("libre") || state.contains("OK") { return .supraGreen }
        return .supraTextSecondary
    }
}
