import SwiftUI

struct SUPRAOperationalControlCenterView: View {
    @StateObject private var resourceEngine = SUPRAResourceIntelligenceEngine.shared
    @StateObject private var potential = SUPRAMacPotential.shared
    @StateObject private var recommendationEngine = SUPRARecommendationEngine.shared
    @StateObject private var evolutionEngine = SUPRAEvolutionEngine.shared
    @StateObject private var envModel = SUPRAEnvironmentWorldModel.shared
    @StateObject private var refreshCoordinator = SUPRAPassiveRefreshCoordinator.shared
    @EnvironmentObject private var runtimeService: RuntimeDataService
    @EnvironmentObject private var missionStore: MissionStore
    @State private var prompt = ""
    @State private var isExecuting = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacing) {
                    header
                    promptSection
                    userMissionsSection
                    monMacSection
                    Divider().background(Color.supraBorder)
                    potentielSection
                    Divider().background(Color.supraBorder)
                    opportunitesSection
                    Divider().background(Color.supraBorder)
                    missionsSection
                    Divider().background(Color.supraBorder)
                    actionsSection
                    Divider().background(Color.supraBorder)
                    decisionsSection
                }
                .padding(SUPRAOSDesignSystem.padding)
                .frame(maxWidth: 1280, alignment: .leading)
                .frame(maxWidth: .infinity)
            }
            .background(Color.supraBackground)
            .task { runtimeService.refreshSystemMetrics() }
            .navigationDestination(for: Mission.self) { mission in
                MissionDetailView(mission: mission)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 10) {
                Image(systemName: "command").font(.system(size: 20)).foregroundColor(.supraAccent)
                VStack(alignment: .leading, spacing: 1) {
                    Text("SUPRA CONTROL CENTER").font(.caption.weight(.bold)).tracking(2).foregroundColor(.supraAccent)
                    Text("Environment Twin · Auto-Évolution · Intelligence Embarquée")
                        .font(.system(size: 12)).foregroundColor(.supraTextSecondary)
                }
                Spacer()
                HStack(spacing: 6) {
                    Circle().fill(Color.supraGreen).frame(width: 6, height: 6)
                    Text("Online").font(.system(size: 10)).foregroundColor(.supraGreen)
                }
                refreshIndicator
            }
            if let state = envModel.state {
                HStack(spacing: 12) {
                    healthPill("CPU", "\(Int((state.hardware?.cpuUsage ?? 0) * 100))%", healthColor(state.hardware?.cpuUsage ?? 0, high: 0.8))
                    healthPill("RAM", "\(Int((state.hardware?.ramUsedGB ?? 0) / max(state.hardware?.physicalRAMGB ?? 1, 1) * 100))%", healthColor(state.hardware?.ramUsedGB ?? 0, high: (state.hardware?.physicalRAMGB ?? 1) * 0.85))
                    healthPill("Stockage", "\(Int(state.hardware?.storageFreeGB ?? 0))GB libre", state.hardware?.storageFreeGB ?? 0 > 20 ? .supraGreen : .supraOrange)
                    healthPill("Thermal", state.hardware?.thermalState.capitalized ?? "—", thermalColor(state.hardware?.thermalState ?? ""))
                    Spacer()
                    Text(state.timestamp.formatted(date: .omitted, time: .standard))
                        .font(.caption2).foregroundColor(.supraTextTertiary)
                }
            }
        }
    }

    private var monMacSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("1. MON MAC MAINTENANT")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 10)], spacing: 10) {
                if let hw = envModel.state?.hardware {
                    SUPRAOSStatCard(label: "CPU", value: "\(Int(hw.cpuUsage * 100))% • \(hw.cpuCount) cores", icon: "cpu", color: hw.cpuUsage > 0.8 ? .supraRed : .supraGreen)
                    SUPRAOSStatCard(label: "RAM", value: "\(Int(hw.ramUsedGB))/\(Int(hw.physicalRAMGB)) GB", icon: "memorychip.fill", color: hw.ramUsedGB > hw.physicalRAMGB * 0.85 ? .supraOrange : .supraBlue)
                    SUPRAOSStatCard(label: "Stockage", value: "\(Int(hw.storageFreeGB))GB libre", icon: "externaldrive.fill", color: hw.storageFreeGB > 20 ? .supraGreen : .supraOrange)
                    SUPRAOSStatCard(label: "Thermal", value: hw.thermalState.capitalized, icon: "thermometer.medium", color: thermalColor(hw.thermalState))
                    SUPRAOSStatCard(label: "GPU", value: hw.gpuModel, icon: "rectangle.split.3x3.fill", color: .supraPurple)
                    processCard
                }
                if let sw = envModel.state?.software {
                    SUPRAOSStatCard(label: "Applications", value: "\(sw.applicationCount)", icon: "square.grid.3x3.fill", color: .supraAccent)
                    SUPRAOSStatCard(label: "Services", value: "\(sw.servicesCount)", icon: "gearshape.2.fill", color: .supraTeal)
                }
                if let dv = envModel.state?.developer {
                    SUPRAOSStatCard(label: "Projets", value: "\(dv.projectCount)", icon: "folder.fill", color: .supraBlue)
                    SUPRAOSStatCard(label: "Git repos", value: "\(dv.gitRepositoryCount)", icon: "arrow.triangle.branch", color: .supraGreen)
                }
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var promptSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("0. NOUVELLE MISSION")
            HStack(spacing: 10) {
                TextField("Décris ta mission…", text: $prompt)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .padding(10)
                    .background(Color.supraGlass)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.supraBorder, lineWidth: 1))
                Button {
                    executePrompt()
                } label: {
                    HStack(spacing: 6) {
                        if isExecuting {
                            ProgressView().scaleEffect(0.7).frame(width: 12, height: 12)
                        }
                        Text(isExecuting ? "Exécution…" : "Exécuter")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(prompt.isEmpty || isExecuting ? Color.supraTextTertiary : Color.supraAccent)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .disabled(prompt.isEmpty || isExecuting)
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var userMissionsSection: some View {
        let recent = missionStore.missions.suffix(5)
        return VStack(alignment: .leading, spacing: 8) {
            sectionHeader("MES MISSIONS (\(missionStore.missions.count))")
            if recent.isEmpty {
                Text("Aucune mission pour le moment")
                    .font(.system(size: 11)).foregroundColor(.supraTextTertiary).padding(8)
            } else {
                ForEach(recent) { mission in
                    NavigationLink(value: mission) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(missionColor(mission.status))
                                .frame(width: 8, height: 8)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(mission.title)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.supraText)
                                Text(mission.currentStatus)
                                    .font(.system(size: 9))
                                    .foregroundColor(.supraTextSecondary)
                            }
                            Spacer()
                            Text(mission.status.rawValue)
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundColor(missionColor(mission.status))
                        }
                        .padding(8)
                        .background(Color.supraGlass)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private func missionColor(_ status: Mission.Status) -> Color {
        switch status {
        case .completed: .supraGreen
        case .active: .supraAccent
        case .blocked: .supraRed
        case .planned: .supraTextTertiary
        }
    }

    private func executePrompt() {
        let text = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        isExecuting = true
        Task {
            if let id = await missionStore.createMission(intent: text) {
                prompt = ""
                await missionStore.executeMission(id: id)
            }
            isExecuting = false
        }
    }

    private var potentielSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("2. POTENTIEL INUTILISÉ")
            HStack(spacing: 12) {
                ZStack {
                    Circle().stroke(Color.supraBorder.opacity(0.3), lineWidth: 8).frame(width: 80, height: 80)
                    Circle().trim(from: 0, to: CGFloat(1.0 - potential.potentialPercent / 100))
                        .stroke(potentialGaugeColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 80, height: 80).rotationEffect(.degrees(-90))
                    VStack(spacing: 1) {
                        Text("\(Int(potential.potentialPercent))%").font(.system(size: 16, weight: .bold)).foregroundColor(potentialGaugeColor)
                        Text("libre").font(.system(size: 7)).foregroundColor(.supraTextTertiary)
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(potential.summary).font(.system(size: 13, weight: .medium)).foregroundColor(.supraText)
                    if !potential.items.isEmpty {
                        Text("Priorité: \(potential.items[0].title) (\(potential.items[0].domain))")
                            .font(.system(size: 10)).foregroundColor(.supraTextSecondary)
                    }
                }
                Spacer()
                if !potential.items.isEmpty {
                    SUPRAOSBadge(text: "\(potential.items.count) domaines", color: .supraAccent)
                }
            }
            if !potential.items.isEmpty {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 200), spacing: 8)], spacing: 8) {
                    ForEach(potential.items.prefix(4)) { item in
                        HStack(spacing: 6) {
                            Image(systemName: item.icon).font(.system(size: 10)).foregroundColor(item.color)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(item.title).font(.system(size: 10, weight: .medium)).foregroundColor(.supraText)
                                Text(item.value).font(.system(size: 9)).foregroundColor(item.color)
                            }
                            Spacer()
                        }
                        .padding(8).background(Color.supraGlass).clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var opportunitesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("3. OPPORTUNITÉS DÉTECTÉES (\(recommendationEngine.active.count))")
            if !recommendationEngine.active.isEmpty {
                ForEach(recommendationEngine.active.prefix(3)) { rec in
                    HStack(spacing: 8) {
                        Circle().fill(rec.isAutoExecutable ? Color.supraGreen : Color.supraOrange).frame(width: 6, height: 6)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(rec.problem).font(.system(size: 11, weight: .medium)).foregroundColor(.supraText)
                            Text(rec.action).font(.system(size: 9)).foregroundColor(.supraTextSecondary)
                        }
                        Spacer()
                        SUPRAOSBadge(text: "Φ \(Int(rec.confidence * 100))%", color: .supraAccent)
                        SUPRAOSBadge(text: rec.isAutoExecutable ? "AUTO" : "HUMAIN", color: rec.isAutoExecutable ? .supraGreen : .supraOrange)
                    }
                    .padding(8).background(Color.supraGlass).clipShape(RoundedRectangle(cornerRadius: 6))
                }
            } else {
                Text("Aucune opportunité détectée — l'environnement est optimal")
                    .font(.system(size: 11)).foregroundColor(.supraGreen).padding(8)
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var missionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("4. MISSIONS PROPOSÉES (\(evolutionEngine.proposals.count))")
            if !evolutionEngine.proposals.isEmpty {
                ForEach(evolutionEngine.proposals.reversed().prefix(3)) { prop in
                    let autoEligible = prop.confidence > 0.85 && prop.isReversible && !prop.hasCriticalRisk
                    HStack(spacing: 8) {
                        Image(systemName: statusIcon(prop.status)).font(.system(size: 10)).foregroundColor(statusColor(prop.status))
                        VStack(alignment: .leading, spacing: 1) {
                            Text(prop.title).font(.system(size: 11, weight: .medium)).foregroundColor(.supraText)
                            Text(prop.category.rawValue).font(.system(size: 9)).foregroundColor(.supraTextTertiary)
                        }
                        Spacer()
                        SUPRAOSBadge(text: "Φ \(Int(prop.confidence * 100))%", color: prop.confidence > 0.85 ? .supraGreen : .supraOrange)
                        SUPRAOSBadge(text: autoEligible ? "AUTO" : "HUMAIN", color: autoEligible ? .supraGreen : .supraOrange)
                    }
                    .padding(8).background(Color.supraGlass).clipShape(RoundedRectangle(cornerRadius: 6))
                }
            } else {
                Text("Aucune mission proposée — le moteur observe en continu")
                    .font(.system(size: 11)).foregroundColor(.supraTextTertiary).padding(8)
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("5. ACTIONS AUTOMATIQUES (\(evolutionEngine.autoExecutedCount))")
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("\(evolutionEngine.autoExecutedCount)").font(.system(size: 28, weight: .bold)).foregroundColor(.supraGreen)
                    Text("EXÉCUTÉES").font(.system(size: 8, weight: .semibold)).foregroundColor(.supraTextTertiary).tracking(1)
                }
                VStack(spacing: 4) {
                    Text("\(recommendationEngine.autoExecutable.count)").font(.system(size: 28, weight: .bold)).foregroundColor(.supraAccent)
                    Text("EN ATTENTE").font(.system(size: 8, weight: .semibold)).foregroundColor(.supraTextTertiary).tracking(1)
                }
                VStack(spacing: 4) {
                    Text("\(recommendationEngine.autoExecutedCount)").font(.system(size: 28, weight: .bold)).foregroundColor(.supraBlue)
                    Text("RECOMMENDATIONS").font(.system(size: 8, weight: .semibold)).foregroundColor(.supraTextTertiary).tracking(1)
                }
                Spacer()
            }
            if !resourceEngine.wasteReports.isEmpty {
                Text("Gaspillages détectés: \(resourceEngine.wasteReports.count)").font(.system(size: 10)).foregroundColor(.supraOrange)
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var decisionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("6. DÉCISIONS HUMAINES (\(evolutionEngine.humanPending.count + recommendationEngine.humanRequired.count))")
            if evolutionEngine.humanPending.isEmpty && recommendationEngine.humanRequired.isEmpty {
                Text("Aucune décision humaine requise")
                    .font(.system(size: 11)).foregroundColor(.supraGreen).padding(8)
            } else {
                if !evolutionEngine.humanPending.isEmpty {
                    Text("ÉVOLUTION").font(.system(size: 9, weight: .semibold)).foregroundColor(.supraOrange).tracking(1)
                    ForEach(evolutionEngine.humanPending.prefix(2)) { prop in
                        HStack(spacing: 6) {
                            Image(systemName: "clock.fill").font(.system(size: 8)).foregroundColor(.supraOrange)
                            Text(prop.title).font(.system(size: 10)).foregroundColor(.supraText)
                            Spacer()
                            SUPRAOSBadge(text: "Φ \(Int(prop.confidence * 100))%", color: .supraAccent)
                        }
                        .padding(6).background(Color.supraGlass).clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
                if !recommendationEngine.humanRequired.isEmpty {
                    Text("RECOMMENDATIONS").font(.system(size: 9, weight: .semibold)).foregroundColor(.supraOrange).tracking(1).padding(.top, 4)
                    ForEach(recommendationEngine.humanRequired.prefix(2)) { rec in
                        HStack(spacing: 6) {
                            Image(systemName: "clock.fill").font(.system(size: 8)).foregroundColor(.supraOrange)
                            Text(rec.problem).font(.system(size: 10)).foregroundColor(.supraText)
                            Spacer()
                            SUPRAOSBadge(text: "Φ \(Int(rec.confidence * 100))%", color: .supraAccent)
                        }
                        .padding(6).background(Color.supraGlass).clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var processCard: some View {
        switch runtimeService.systemMetrics.heavyProcesses {
        case .loading:
            SUPRAOSStatCard(label: "Processus", value: "…", icon: "terminal.fill", color: .supraTextTertiary)
        case .available(let procs) where procs.isEmpty:
            SUPRAOSStatCard(label: "Processus", value: "Aucun processus lourd", icon: "terminal.fill", color: .supraGreen)
        case .available(let procs):
            SUPRAOSStatCard(label: "Processus", value: "\(procs.count) lourds", icon: "terminal.fill", color: .supraOrange)
        case .unavailable:
            SUPRAOSStatCard(label: "Processus", value: "Indisponible", icon: "terminal.fill", color: .supraTextTertiary)
        }
    }

    private var refreshIndicator: some View {
        HStack(spacing: 4) {
            if let msg = refreshCoordinator.statusMessage {
                Text(msg)
                    .font(.system(size: 8))
                    .foregroundColor(.supraGreen)
                    .transition(.opacity)
            }
            Circle()
                .fill(refreshCoordinator.isRefreshing ? Color.supraAccent : Color.supraTextTertiary)
                .frame(width: 3, height: 3)
            Text("Dernière actualisation : \(refreshCoordinator.lastRefresh?.formatted(date: .omitted, time: .standard) ?? "—")")
                .font(.system(size: 8))
                .foregroundColor(.supraTextTertiary)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title).font(.system(size: 11, weight: .semibold)).foregroundColor(.supraTextTertiary).tracking(1)
    }

    private func healthPill(_ label: String, _ value: String, _ color: Color) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 5, height: 5)
            Text("\(label): \(value)").font(.system(size: 9)).foregroundColor(.supraTextSecondary)
        }
        .padding(.horizontal, 6).padding(.vertical, 3)
        .background(color.opacity(0.1)).clipShape(Capsule())
    }

    private func healthColor(_ value: Double, high threshold: Double) -> Color {
        value > threshold ? .supraRed : value > threshold * 0.9 ? .supraOrange : .supraGreen
    }

    private func thermalColor(_ t: String) -> Color {
        switch t.lowercased() { case "nominal": .supraGreen case "fair": .supraOrange case "serious": .supraRed case "critical": .supraPurple default: .supraTextSecondary }
    }

    private var potentialGaugeColor: Color {
        potential.potentialPercent > 50 ? .supraGreen : potential.potentialPercent > 25 ? .supraAccent : .supraOrange
    }

    private func statusIcon(_ status: EvolutionStatus) -> String {
        switch status { case .pending: "clock.fill" case .approved: "checkmark.circle.fill" case .autoExecuted: "bolt.fill" case .executed: "checkmark.shield.fill" case .failed: "exclamationmark.triangle.fill" case .rejected: "xmark.circle.fill" }
    }

    private func statusColor(_ status: EvolutionStatus) -> Color {
        switch status { case .pending: .supraOrange case .approved: .supraGreen case .autoExecuted: .supraGreen case .executed: .supraBlue case .failed: .supraRed case .rejected: .supraTextTertiary }
    }
}
