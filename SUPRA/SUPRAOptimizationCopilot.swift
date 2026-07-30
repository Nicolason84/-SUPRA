import Foundation
import Combine

struct OptimizationFinding: Identifiable {
    let id: UUID
    let title: String
    let detail: String
    let impact: String
    let impactScore: Double
    let evidence: String
    let isReversible: Bool
    let confidence: Double
    let suggestedAction: String
    let category: String
    let canAutoExecute: Bool
    let proposedAt: Date
}

@MainActor
final class SUPRAOptimizationCopilot: ObservableObject {
    static let shared = SUPRAOptimizationCopilot()

    @Published private(set) var findings: [OptimizationFinding] = []
    @Published private(set) var autoQueue: [OptimizationFinding] = []
    @Published private(set) var humanQueue: [OptimizationFinding] = []
    @Published private(set) var lastAnalysis: Date?

    private let envModel = SUPRAEnvironmentWorldModel.shared
    private var lastHash = 0

    private init() {}

    func analyze() {
        guard let state = envModel.state else { return }
        let h = computeHash(from: state)
        guard h != lastHash else { return }
        lastHash = h

        var newFindings: [OptimizationFinding] = []

        newFindings.append(contentsOf: analyzeHardware(state))
        newFindings.append(contentsOf: analyzeDeveloper(state))
        newFindings.append(contentsOf: analyzeData(state))

        findings = newFindings
        classify()
        lastAnalysis = Date()
    }

    private func computeHash(from state: CompleteEnvironmentState) -> Int {
        var h = Hasher()
        h.combine(state.hardware?.cpuUsage)
        h.combine(state.hardware?.thermalState)
        h.combine(state.hardware?.ramUsedGB)
        h.combine(state.developer?.derivedDataSizeMB)
        h.combine(state.developer?.uncommittedRepos)
        h.combine(state.data?.duplicateCount)
        h.combine(state.data?.largeFileCount)
        return h.finalize()
    }

    private func analyzeHardware(_ s: CompleteEnvironmentState) -> [OptimizationFinding] {
        var result: [OptimizationFinding] = []
        guard let hw = s.hardware else { return result }

        if hw.cpuUsage > 0.85 {
            result.append(finding(
                title: "High CPU Load", detail: "CPU at \(Int(hw.cpuUsage * 100))% on \(hw.cpuCount) cores",
                impact: "Performance degradation", impactScore: 0.7,
                evidence: "CPU usage exceeds 85% threshold",
                reversible: true, confidence: 0.9, action: "Identify and reduce background CPU-intensive processes",
                category: "performance", auto: false
            ))
        }

        if hw.ramUsedGB > hw.physicalRAMGB * 0.85 {
            result.append(finding(
                title: "Memory Pressure", detail: "\(hw.ramUsedGB)GB / \(hw.physicalRAMGB)GB in use",
                impact: "System slowdown, swap usage", impactScore: 0.65,
                evidence: "RAM usage exceeds 85% of physical memory",
                reversible: true, confidence: 0.85, action: "Close unused applications and browser tabs",
                category: "memory", auto: false
            ))
        }

        if hw.storageFreeGB < 20 {
            result.append(finding(
                title: "Low Disk Space", detail: "\(Int(hw.storageFreeGB))GB free of \(Int(hw.storageTotalGB))GB",
                impact: "System instability, cannot write large files", impactScore: 0.8,
                evidence: "Free disk space below 20GB",
                reversible: true, confidence: 0.95, action: "Clean large files and archives",
                category: "storage", auto: false
            ))
        }

        if hw.thermalState == "serious" || hw.thermalState == "critical" {
            result.append(finding(
                title: "Thermal Throttling", detail: "Thermal state: \(hw.thermalState)",
                impact: "CPU/GPU performance reduced", impactScore: 0.75,
                evidence: "System thermal state is \(hw.thermalState)",
                reversible: true, confidence: 0.9, action: "Reduce workload and check cooling",
                category: "thermal", auto: false
            ))
        }

        if hw.batteryPresent && hw.batteryPercent < 20 && !hw.batteryCharging {
            result.append(finding(
                title: "Low Battery", detail: "\(hw.batteryPercent)% remaining",
                impact: "Risk of data loss on power failure", impactScore: 0.5,
                evidence: "Battery below 20% and not charging",
                reversible: true, confidence: 0.95, action: "Connect power adapter",
                category: "power", auto: false
            ))
        }

        return result
    }

    private func analyzeDeveloper(_ s: CompleteEnvironmentState) -> [OptimizationFinding] {
        var result: [OptimizationFinding] = []
        guard let dv = s.developer else { return result }

        if dv.derivedDataSizeMB > 1000 {
            result.append(finding(
                title: "Large Derived Data", detail: "\(dv.derivedDataSizeMB)MB in ~/Library/Developer/Xcode/DerivedData",
                impact: "Wasted disk space", impactScore: 0.4,
                evidence: "DerivedData exceeds 1GB",
                reversible: true, confidence: 0.9, action: "Clean Xcode derived data",
                category: "developer", auto: true
            ))
        }

        if dv.uncommittedRepos > 3 {
            result.append(finding(
                title: "Uncommitted Changes", detail: "\(dv.uncommittedRepos) repositories have uncommitted changes",
                impact: "Risk of losing work", impactScore: 0.3,
                evidence: "git status --porcelain shows changes in \(dv.uncommittedRepos) repos",
                reversible: true, confidence: 0.7, action: "Commit or stash changes across repositories",
                category: "developer", auto: false
            ))
        }

        return result
    }

    private func analyzeData(_ s: CompleteEnvironmentState) -> [OptimizationFinding] {
        var result: [OptimizationFinding] = []
        guard let dt = s.data else { return result }

        if dt.duplicateCount > 10 {
            result.append(finding(
                title: "Duplicate Files Detected", detail: "\(dt.duplicateCount) groups of duplicate files",
                impact: "Wasted storage", impactScore: 0.35,
                evidence: "\(dt.duplicateCount) groups of files with same name and size",
                reversible: true, confidence: 0.75, action: "Review and consolidate duplicate files",
                category: "data", auto: false
            ))
        }

        if dt.largeFileCount > 10 {
            result.append(finding(
                title: "Large Files", detail: "\(dt.largeFileCount) files over 100MB",
                impact: "Consumes significant storage", impactScore: 0.3,
                evidence: "\(dt.largeFileCount) files exceed 100MB each",
                reversible: true, confidence: 0.8, action: "Archive or remove unnecessary large files",
                category: "data", auto: false
            ))
        }

        if dt.archiveCount > 20 {
            result.append(finding(
                title: "Many Archives", detail: "\(dt.archiveCount) archive files found on Desktop/Downloads",
                impact: "Unnecessary storage usage", impactScore: 0.25,
                evidence: "\(dt.archiveCount) zip/dmg/tar files in common directories",
                reversible: true, confidence: 0.85, action: "Clean up downloaded archives",
                category: "data", auto: false
            ))
        }

        return result
    }

    private func classify() {
        var auto: [OptimizationFinding] = []
        var human: [OptimizationFinding] = []
        for f in findings {
            if f.canAutoExecute && f.confidence >= 0.85 { auto.append(f) }
            else { human.append(f) }
        }
        autoQueue = auto
        humanQueue = human
    }

    private func finding(title: String, detail: String, impact: String, impactScore: Double, evidence: String, reversible: Bool, confidence: Double, action: String, category: String, auto: Bool) -> OptimizationFinding {
        OptimizationFinding(
            id: UUID(), title: title, detail: detail,
            impact: impact, impactScore: impactScore,
            evidence: evidence, isReversible: reversible,
            confidence: confidence, suggestedAction: action,
            category: category, canAutoExecute: auto && confidence >= 0.85 && reversible,
            proposedAt: Date()
        )
    }
}
