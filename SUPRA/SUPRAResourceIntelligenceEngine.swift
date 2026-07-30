import Foundation
import Combine

struct WasteReport: Identifiable {
    let id = UUID()
    let category: WasteCategory
    let title: String
    let detail: String
    let estimatedRecoverable: String
    let confidence: Double
    let action: String
}

enum WasteCategory: String, Codable {
    case cpu, memory, storage, application, service, cache, duplicate
}

struct OptimizationOpportunity: Identifiable {
    let id = UUID()
    let domain: String
    let title: String
    let impact: String
    let effort: String
    let confidence: Double
    let autoFixable: Bool
}

@MainActor
final class SUPRAResourceIntelligenceEngine: ObservableObject {
    static let shared = SUPRAResourceIntelligenceEngine()

    @Published private(set) var anomalies: [AnomalyReport] = []
    @Published private(set) var cpuHistory: [Double] = []
    @Published private(set) var cpuCurrent: Double = 0
    @Published private(set) var ramUsedGB: Double = 0
    @Published private(set) var ramTotalGB: Double = 0
    @Published private(set) var swapUsed: String = "—"
    @Published private(set) var thermalState: String = "—"
    @Published private(set) var energyImpact: String = "—"
    @Published private(set) var heavyProcesses: [(name: String, cpu: Double, memory: Double)] = []
    @Published private(set) var wasteReports: [WasteReport] = []
    @Published private(set) var optimizationOpportunities: [OptimizationOpportunity] = []
    @Published private(set) var unusedApplications: [String] = []
    @Published private(set) var lastUpdated: Date?

    private let governor = SUPRAResourceGovernor.shared
    private let hardwareTwin = SUPRAHardwareTwin.shared
    private let softwareTwin = SUPRASoftwareTwin.shared
    private let dataTwin = SUPRADataTwin.shared
    private let developerTwin = SUPRADeveloperTwin.shared
    private var timer: Timer?

    private init() {}

    func start() {
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func refresh() {
        let hw = hardwareTwin.snapshot
        let sw = softwareTwin.snapshot
        let dt = dataTwin.snapshot
        let dv = developerTwin.snapshot

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
        wasteReports = computeWaste(hw: hw, sw: sw, dt: dt, dv: dv)
        optimizationOpportunities = computeOpportunities(hw: hw, sw: sw, dt: dt, dv: dv)
        unusedApplications = detectUnusedApplications(sw: sw)
        lastUpdated = Date()
    }

    private func computeAnomalies(hw: HardwareSnapshot?) -> [AnomalyReport] {
        var result: [AnomalyReport] = []

        if governor.isCritical {
            result.append(AnomalyReport(domain: "CPU", value: "\(Int(cpuCurrent * 100))%", threshold: ">95%",
                cause: "Processus intensif ou fuite CPU", impact: "Système ralenti, ventilateurs bruyants",
                action: "Identifier avec `top -o cpu` et suspendre", confidence: 0.92))
        } else if governor.isHighLoad {
            result.append(AnomalyReport(domain: "CPU", value: "\(Int(cpuCurrent * 100))%", threshold: ">80%",
                cause: "Charge soutenue", impact: "Performance réduite, latence",
                action: "Vérifier les processus en arrière-plan", confidence: 0.85))
        }

        let ramFraction = governor.ramFraction
        if ramFraction > 0.85 {
            result.append(AnomalyReport(domain: "RAM", value: "\(Int(ramFraction * 100))%", threshold: ">85%",
                cause: "Trop d'applications ou fuite mémoire", impact: "Swap système, ralentissement",
                action: "Fermer les applications inutilisées", confidence: 0.88))
        }

        if let hw = hw {
            if hw.thermalState == "serious" || hw.thermalState == "critical" {
                result.append(AnomalyReport(domain: "Thermique", value: hw.thermalState.uppercased(), threshold: "SERIOUS",
                    cause: "Surchauffe CPU/GPU", impact: "Throttling, baisse de performance",
                    action: "Réduire la charge CPU, vérifier la ventilation", confidence: 0.90))
            }
            if hw.storageFreeGB < 20 {
                result.append(AnomalyReport(domain: "Stockage", value: "\(Int(hw.storageFreeGB))GB libre", threshold: "<20GB",
                    cause: "Espace disque insuffisant", impact: "Swap limité, mises à jour bloquées",
                    action: "Nettoyer corbeille, DerivedData, fichiers volumineux", confidence: 0.85))
            }
        }

        if !heavyProcesses.isEmpty {
            let top = heavyProcesses[0]
            result.append(AnomalyReport(domain: "Processus", value: "\(top.name) \(Int(top.cpu * 100))%", threshold: ">50%",
                cause: "Processus consommateur", impact: "CPU monopolisé",
                action: "Évaluer si \(top.name) est nécessaire", confidence: 0.78))
        }

        return result
    }

    private func computeWaste(hw: HardwareSnapshot?, sw: SoftwareSnapshot?, dt: DataSnapshot?, dv: DeveloperSnapshot?) -> [WasteReport] {
        var result: [WasteReport] = []

        if let dv = dv, dv.derivedDataSizeMB > 500 {
            result.append(WasteReport(category: .cache, title: "DerivedData volumineux",
                detail: "\(dv.derivedDataSizeMB)MB dans ~/Library/Developer/Xcode/DerivedData",
                estimatedRecoverable: "\(dv.derivedDataSizeMB)MB", confidence: 0.95,
                action: "rm -rf ~/Library/Developer/Xcode/DerivedData/*"))
        }

        if let dt = dt, dt.duplicateCount > 5 {
            result.append(WasteReport(category: .duplicate, title: "Fichiers en double",
                detail: "\(dt.duplicateCount) fichiers identiques détectés",
                estimatedRecoverable: "~\(dt.duplicateCount * 50)MB", confidence: 0.82,
                action: "Utiliser fdupes pour dédupliquer"))
        }

        if let dt = dt, dt.largeFileCount > 5 {
            result.append(WasteReport(category: .storage, title: "Fichiers volumineux",
                detail: "\(dt.largeFileCount) fichiers >100MB",
                estimatedRecoverable: "~\(dt.largeFileCount * 200)MB", confidence: 0.78,
                action: "Archiver ou supprimer les fichiers inutilisés"))
        }

        if let excess = try? checkTrashSize(), excess > 500 {
            result.append(WasteReport(category: .storage, title: "Corbeille pleine",
                detail: "\(Int(excess))MB dans ~/.Trash",
                estimatedRecoverable: "\(Int(excess))MB", confidence: 0.90,
                action: "rm -rf ~/.Trash/*"))
        }

        if let sw = sw, sw.launchAgentsCount > 50 {
            result.append(WasteReport(category: .service, title: "LaunchAgents excessifs",
                detail: "\(sw.launchAgentsCount) agents de démarrage",
                estimatedRecoverable: "CPU+RAM", confidence: 0.65,
                action: "Désactiver les agents inutilisés avec launchctl"))
        }

        if let dv = dv, dv.swiftPackageCount > 30 {
            result.append(WasteReport(category: .cache, title: "Packages SPM non référencés",
                detail: "\(dv.swiftPackageCount) packages, dont ~\(max(0, dv.swiftPackageCount - 15)) inutilisés",
                estimatedRecoverable: "~500MB", confidence: 0.70,
                action: "Nettoyer ~/Library/Caches/org.swift.swiftpm"))
        }

        return result
    }

    private func computeOpportunities(hw: HardwareSnapshot?, sw: SoftwareSnapshot?, dt: DataSnapshot?, dv: DeveloperSnapshot?) -> [OptimizationOpportunity] {
        var result: [OptimizationOpportunity] = []

        if let hw = hw, hw.cpuUsage < 0.3 {
            result.append(OptimizationOpportunity(domain: "CPU", title: "Paralléliser les builds",
                impact: "Réduit le temps de build de 40%", effort: "Configurer xcodebuild avec -parallelizeTargets",
                confidence: 0.72, autoFixable: false))
        }

        if let hw = hw, hw.ramUsedGB < hw.physicalRAMGB * 0.5 {
            result.append(OptimizationOpportunity(domain: "RAM", title: "Cache RAM disponible",
                impact: "Accélère les compilations fréquentes", effort: "Augmenter swiftc -j",
                confidence: 0.68, autoFixable: false))
        }

        if let dv = dv, dv.derivedDataSizeMB > 1000 {
            result.append(OptimizationOpportunity(domain: "Build", title: "Nettoyer DerivedData avant build",
                impact: "Prévient les corruptions d'index", effort: "Ajouter une phase pré-build",
                confidence: 0.85, autoFixable: true))
        }

        if let dv = dv, dv.uncommittedRepos > 3 {
            result.append(OptimizationOpportunity(domain: "Git", title: "Auto-commits périodiques",
                impact: "Sauvegarde automatique du travail", effort: "Hook pre-commit automatisé",
                confidence: 0.76, autoFixable: false))
        }

        return result
    }

    private func detectUnusedApplications(sw: SoftwareSnapshot?) -> [String] {
        guard let sw = sw else { return [] }
        let path = NSHomeDirectory() + "/Applications"
        guard let apps = try? FileManager.default.contentsOfDirectory(atPath: path) else { return [] }
        let recent = Set(sw.recentApps.map { $0.lowercased() })
        return apps.filter { app in
            let name = app.lowercased().replacingOccurrences(of: ".app", with: "")
            return !recent.contains(name) && !name.contains("xcode") && !name.contains("terminal")
        }
    }

    private func checkTrashSize() throws -> Double {
        let trash = NSHomeDirectory() + "/.Trash"
        guard let contents = try? FileManager.default.contentsOfDirectory(atPath: trash) else { return 0 }
        var total: Double = 0
        for item in contents {
            let path = trash + "/" + item
            if let attrs = try? FileManager.default.attributesOfItem(atPath: path),
               let size = attrs[.size] as? UInt64 {
                total += Double(size)
            }
        }
        return total / 1_048_576
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
