import Foundation
import Combine

struct CompleteEnvironmentState {
    let hardware: HardwareSnapshot?
    let software: SoftwareSnapshot?
    let data: DataSnapshot?
    let developer: DeveloperSnapshot?
    let memory: CanonicalMultiMemoryState
    let environmentScore: Double
    let health: String
    let timestamp: Date
}

@MainActor
final class SUPRAEnvironmentWorldModel: ObservableObject {
    static let shared = SUPRAEnvironmentWorldModel()

    @Published private(set) var state: CompleteEnvironmentState?
    @Published private(set) var lastUpdated: Date?
    @Published private(set) var isRefreshing = false

    private let hardwareTwin = SUPRAHardwareTwin.shared
    private let softwareTwin = SUPRASoftwareTwin.shared
    private let dataTwin = SUPRADataTwin.shared
    private let developerTwin = SUPRADeveloperTwin.shared
    private let access = SUPRACanonicalWorldAccess.shared

    private var lastHash = 0
    private var timer: Timer?

    private init() {}

    func startAutoRefresh() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.refresh() }
        }
    }

    func stopAutoRefresh() {
        timer?.invalidate()
        timer = nil
    }

    func refresh() {
        isRefreshing = true

        hardwareTwin.refresh()
        softwareTwin.refresh()
        // File-derived twins consume the coordinator cache only. They never scan.
        dataTwin.refresh()
        developerTwin.refresh()

        let h = computeHash()
        guard h != lastHash else { isRefreshing = false; return }
        lastHash = h

        build()
        isRefreshing = false
    }

    private func computeHash() -> Int {
        var h = Hasher()
        h.combine(hardwareTwin.snapshot?.timestamp)
        h.combine(softwareTwin.snapshot?.timestamp)
        h.combine(dataTwin.snapshot?.timestamp)
        h.combine(developerTwin.snapshot?.timestamp)
        return h.finalize()
    }

    private func build() {
        let mem = access.getAllStates()
        let hw = hardwareTwin.snapshot
        let sw = softwareTwin.snapshot
        let dt = dataTwin.snapshot
        let dv = developerTwin.snapshot

        let score = computeScore(hw: hw, sw: sw, dt: dt, dv: dv)
        let health: String
        switch score {
        case 0.8...: health = "healthy"
        case 0.5..<0.8: health = "degraded"
        default: health = "critical"
        }

        state = CompleteEnvironmentState(
            hardware: hw,
            software: sw,
            data: dt,
            developer: dv,
            memory: mem,
            environmentScore: score,
            health: health,
            timestamp: Date()
        )
        lastUpdated = Date()
    }

    private func computeScore(hw: HardwareSnapshot?, sw: SoftwareSnapshot?, dt: DataSnapshot?, dv: DeveloperSnapshot?) -> Double {
        var score = 1.0
        if let h = hw {
            if h.thermalState == "critical" { score -= 0.3 }
            else if h.thermalState == "serious" { score -= 0.15 }
            if h.cpuUsage > 0.9 { score -= 0.2 }
            else if h.cpuUsage > 0.7 { score -= 0.1 }
            if h.batteryPresent && h.batteryPercent < 20 { score -= 0.1 }
        }
        if let s = sw {
            if s.launchAgentsCount > 50 { score -= 0.05 }
        }
        if let d = dt {
            if d.duplicateCount > 20 { score -= 0.05 }
            if d.largeFileCount > 10 { score -= 0.05 }
        }
        if let d = dv {
            if d.uncommittedRepos > 5 { score -= 0.05 }
            if d.derivedDataSizeMB > 5000 { score -= 0.05 }
        }
        return max(0, min(1, score))
    }

    var summary: String {
        guard let s = state else { return "Environment model not ready" }
        return """
        ENVIRONMENT TWIN
        Health: \(s.health) | Score: \(Int(s.environmentScore * 100))%
        Hardware: \(s.hardware?.cpuCount ?? 0) cores · \(s.hardware?.physicalRAMGB ?? 0)GB RAM
        Software: \(s.software?.applicationCount ?? 0) apps · \(s.software?.servicesCount ?? 0) services
        Data: \(s.data?.projectCount ?? 0) projects · \(s.data?.documentCount ?? 0) documents
        Developer: \(s.developer?.swiftFileCount ?? 0) Swift files · \(s.developer?.gitRepositoryCount ?? 0) repos
        """
    }
}
