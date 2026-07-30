import SwiftUI
import Combine

struct AnomalyReport: Identifiable {
    let id = UUID()
    let domain: String
    let value: String
    let threshold: String
    let cause: String
    let impact: String
    let action: String
    let confidence: Double
}

@MainActor
final class SUPRAResourceIntelligence: ObservableObject {
    static let shared = SUPRAResourceIntelligence()

    @Published private(set) var anomalies: [AnomalyReport] = []
    @Published private(set) var cpuHistory: [Double] = []
    @Published private(set) var cpuCurrent: Double = 0
    @Published private(set) var ramUsedGB: Double = 0
    @Published private(set) var ramTotalGB: Double = 0
    @Published private(set) var swapUsed: String = "—"
    @Published private(set) var thermalState: String = "—"
    @Published private(set) var energyImpact: String = "—"
    @Published private(set) var heavyProcesses: [(name: String, cpu: Double, memory: Double)] = []
    @Published private(set) var lastUpdated: Date?

    private let governor = SUPRAResourceGovernor.shared
    private let hardwareTwin = SUPRAHardwareTwin.shared
    private var timer: Timer?

    private init() {}

    func start() {
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func refresh() {
        let hw = hardwareTwin.snapshot

        cpuCurrent = governor.cpuUsage
        cpuHistory.append(cpuCurrent)
        if cpuHistory.count > 120 { cpuHistory.removeFirst() }

        ramUsedGB = hw?.ramUsedGB ?? Double(governor.snapshot.ramUsed) / 1_073_741_824
        ramTotalGB = hw?.physicalRAMGB ?? Double(governor.snapshot.ramTotal) / 1_073_741_824
        thermalState = hw?.thermalState ?? "—"
        swapUsed = querySwap()
        energyImpact = queryEnergy()
        heavyProcesses = queryHeavyProcesses()
        anomalies = computeAnomalies(hw: hw)
        lastUpdated = Date()
    }

    private func computeAnomalies(hw: HardwareSnapshot?) -> [AnomalyReport] {
        var result: [AnomalyReport] = []

        if governor.isCritical {
            result.append(AnomalyReport(
                domain: "CPU", value: "\(Int(cpuCurrent * 100))%", threshold: ">95%",
                cause: "Processus intensifs ou fuite CPU", impact: "Système ralenti, ventilateurs bruyants",
                action: "Identifier le processus avec `top -o cpu` et le suspendre", confidence: 0.92
            ))
        } else if governor.isHighLoad {
            result.append(AnomalyReport(
                domain: "CPU", value: "\(Int(cpuCurrent * 100))%", threshold: ">80%",
                cause: "Charge soutenue", impact: "Performance réduite, latence",
                action: "Vérifier les processus en arrière-plan", confidence: 0.85
            ))
        }

        let ramFraction = governor.ramFraction
        if ramFraction > 0.85 {
            result.append(AnomalyReport(
                domain: "RAM", value: "\(Int(ramFraction * 100))%", threshold: ">85%",
                cause: "Trop d'applications ouvertes ou fuite mémoire",
                impact: "Swap système, ralentissement général",
                action: "Fermer les applications inutilisées, vérifier l'activité mémoire", confidence: 0.88
            ))
        }

        if let hw = hw {
            if hw.thermalState == "serious" || hw.thermalState == "critical" {
                result.append(AnomalyReport(
                    domain: "Thermique", value: hw.thermalState.uppercased(), threshold: "SERIOUS",
                    cause: "Surchauffe CPU/GPU", impact: "Throttling, baisse de performance, usure",
                    action: "Réduire la charge CPU, vérifier la ventilation", confidence: 0.90
                ))
            }

            if hw.storageFreeGB < 20 {
                result.append(AnomalyReport(
                    domain: "Stockage", value: "\(Int(hw.storageFreeGB))GB libre", threshold: "<20GB",
                    cause: "Espace disque insuffisant", impact: "Swap limité, mises à jour bloquées",
                    action: "Vider la corbeille, nettoyer DerivedData, déplacer les fichiers volumineux", confidence: 0.85
                ))
            }
        }

        if !heavyProcesses.isEmpty {
            let top = heavyProcesses[0]
            result.append(AnomalyReport(
                domain: "Processus", value: "\(top.name) \(Int(top.cpu * 100))%", threshold: ">50%",
                cause: "Processus consommateur de ressources", impact: "CPU monopolisé",
                action: "Évaluer si \(top.name) est nécessaire, le suspendre ou le réduire", confidence: 0.78
            ))
        }

        return result
    }

    private func querySwap() -> String {
        guard let r = try? shell("sysctl vm.swapusage 2>/dev/null | awk '{print $7}'") else { return "—" }
        return r.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func queryEnergy() -> String {
        guard let r = try? shell("pmset -g therm 2>/dev/null | grep 'CPU_Speed_Limit' | awk '{print $3}'") else { return "—" }
        let v = r.trimmingCharacters(in: .whitespacesAndNewlines)
        if let i = Int(v), i < 100 { return "Réduit (\(i)%)" }
        return "Normal"
    }

    private func queryHeavyProcesses() -> [(name: String, cpu: Double, memory: Double)] {
        guard let r = try? shell("ps axro pid,pcpu,pmem,comm -m 2>/dev/null | head -8") else { return [] }
        var result: [(String, Double, Double)] = []
        for line in r.components(separatedBy: .newlines).dropFirst() {
            let parts = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
            if parts.count >= 4, let cpu = Double(parts[1]), cpu > 5 {
                let mem = Double(parts[2]) ?? 0
                result.append((parts[3], cpu / 100, mem / 100))
            }
        }
        return result
    }

    private func shell(_ cmd: String) throws -> String {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/bin/zsh")
        p.arguments = ["-c", cmd]
        let o = Pipe()
        p.standardOutput = o
        try p.run()
        p.waitUntilExit()
        return String(data: o.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    }
}

struct SUPRAResourceIntelligenceView: View {
    @StateObject private var intelligence = SUPRAResourceIntelligence.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SUPRAOSDesignSystem.spacing) {
                header
                metricsGrid
                if !intelligence.anomalies.isEmpty {
                    anomaliesSection
                }
                if !intelligence.heavyProcesses.isEmpty {
                    processesSection
                }
                cpuHistorySection
            }
            .padding(SUPRAOSDesignSystem.padding)
            .frame(maxWidth: 1280, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(Color.supraBackground)
        .onAppear { intelligence.start() }
        .onDisappear { intelligence.stop() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("RESOURCE INTELLIGENCE")
                .font(.caption.weight(.bold)).tracking(1.6).foregroundColor(.supraAccent)
            Text("Analyse temps réel des ressources")
                .font(.system(size: 14)).foregroundColor(.supraTextSecondary)
            if let d = intelligence.lastUpdated {
                Text("Mis à jour: \(d.formatted(date: .omitted, time: .standard))")
                    .font(.caption2).foregroundColor(.supraTextTertiary)
            }
        }
    }

    private var metricsGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
            SUPRAStatCard(label: "CPU", value: "\(Int(intelligence.cpuCurrent * 100))%", icon: "cpu",
                       color: intelligence.cpuCurrent > 0.8 ? .supraRed : intelligence.cpuCurrent > 0.6 ? .supraOrange : .supraGreen, variant: .compact)
            SUPRAStatCard(label: "RAM", value: "\(Int(intelligence.ramUsedGB)) / \(Int(intelligence.ramTotalGB)) GB", icon: "memorychip.fill",
                       color: intelligence.cpuCurrent > 0.8 ? .supraOrange : .supraBlue, variant: .compact)
            SUPRAStatCard(label: "Swap", value: intelligence.swapUsed, icon: "arrow.triangle.swap",
                       color: intelligence.swapUsed != "—" && intelligence.swapUsed != "0" ? .supraOrange : .supraTextSecondary, variant: .compact)
            SUPRAStatCard(label: "Thermal", value: intelligence.thermalState.capitalized, icon: "thermometer.medium",
                       color: thermalColor(intelligence.thermalState), variant: .compact)
            SUPRAStatCard(label: "Énergie", value: intelligence.energyImpact, icon: "bolt.fill",
                       color: intelligence.energyImpact.contains("Réduit") ? .supraOrange : .supraGreen, variant: .compact)
            SUPRAStatCard(label: "Processus", value: "\(intelligence.heavyProcesses.count) lourds", icon: "terminal.fill",
                       color: intelligence.heavyProcesses.isEmpty ? .supraGreen : .supraOrange, variant: .compact)
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadius))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadius).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var anomaliesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("ANOMALIES DÉTECTÉES (\(intelligence.anomalies.count))")
            ForEach(intelligence.anomalies) { anomaly in
                anomalyCard(anomaly)
            }
        }
    }

    private func anomalyCard(_ a: AnomalyReport) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Circle().fill(anomalyColor(a)).frame(width: 10, height: 10)
                Text(a.domain).font(.system(size: 13, weight: .bold)).foregroundColor(.supraText)
                Spacer()
                SUPRAOSBadge(text: a.value, color: anomalyColor(a))
                SUPRAOSBadge(text: "Φ \(Int(a.confidence * 100))%", color: .supraAccent)
            }
            Divider().background(Color.supraBorder)
            detailRow("Cause", a.cause)
            detailRow("Impact", a.impact)
            detailRow("Action", a.action)
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(anomalyColor(a).opacity(0.3), lineWidth: 1))
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text(label.uppercased())
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.supraTextTertiary)
                .frame(width: 48, alignment: .trailing)
            Text(value)
                .font(.system(size: 11))
                .foregroundColor(.supraTextSecondary)
        }
    }

    private var processesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("PROCESSUS LOURDS")
            ForEach(intelligence.heavyProcesses.prefix(6), id: \.name) { proc in
                HStack(spacing: 8) {
                    Circle().fill(Color.supraOrange).frame(width: 6, height: 6)
                    Text(proc.name).font(.system(size: 11, weight: .medium)).foregroundColor(.supraText).lineLimit(1)
                    Spacer()
                    Text("\(Int(proc.cpu * 100))% CPU").font(.system(size: 10)).foregroundColor(.supraOrange)
                    Text("\(Int(proc.memory * 100))% RAM").font(.system(size: 10)).foregroundColor(.supraBlue)
                }
                .padding(8)
                .background(Color.supraGlass)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private var cpuHistorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("CPU HISTORIQUE (dernières minutes)")
            GeometryReader { geo in
                let h: CGFloat = 100
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color.supraSurface).frame(height: h)
                    if !intelligence.cpuHistory.isEmpty {
                        Path { path in
                            let w = geo.size.width
                            let step = w / CGFloat(max(intelligence.cpuHistory.count - 1, 1))
                            path.move(to: CGPoint(x: 0, y: h - CGFloat(intelligence.cpuHistory[0]) * h))
                            for i in 1..<intelligence.cpuHistory.count {
                                path.addLine(to: CGPoint(x: CGFloat(i) * step, y: h - CGFloat(intelligence.cpuHistory[i]) * h))
                            }
                        }
                        .stroke(Color.supraAccent, lineWidth: 2)
                    }
                    // Threshold lines
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: h * 0.2))
                        path.addLine(to: CGPoint(x: geo.size.width, y: h * 0.2))
                    }.stroke(Color.supraGreen.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4]))
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: h * 0.8))
                        path.addLine(to: CGPoint(x: geo.size.width, y: h * 0.8))
                    }.stroke(Color.supraRed.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4]))
                }
            }
            .frame(height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .padding(SUPRAOSDesignSystem.paddingSmall)
        .background(Color.supraSurface)
        .clipShape(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall))
        .overlay(RoundedRectangle(cornerRadius: SUPRAOSDesignSystem.cornerRadiusSmall).stroke(Color.supraBorder, lineWidth: 1))
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title).font(.system(size: 11, weight: .semibold)).foregroundColor(.supraTextTertiary).tracking(1)
    }

    private func anomalyColor(_ a: AnomalyReport) -> Color {
        a.confidence > 0.85 ? .supraRed : a.confidence > 0.7 ? .supraOrange : .supraAccent
    }

    private func thermalColor(_ t: String) -> Color {
        switch t.lowercased() { case "nominal": .supraGreen case "fair": .supraOrange case "serious": .supraRed case "critical": .supraPurple default: .supraTextSecondary }
    }
}


