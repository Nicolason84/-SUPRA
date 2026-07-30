import Foundation
import Combine
import AppKit

enum ThrottleLevel: String, Codable, Comparable {
    case paused = "Paused"
    case minimal = "Minimal"
    case reduced = "Reduced"
    case normal = "Normal"

    var factor: Double {
        switch self {
        case .paused: 0
        case .minimal: 0.25
        case .reduced: 0.5
        case .normal: 1.0
        }
    }

    static func < (lhs: ThrottleLevel, rhs: ThrottleLevel) -> Bool {
        lhs.factor < rhs.factor
    }
}

struct ResourceSnapshot: Equatable {
    let cpuUsage: Double
    let ramUsed: UInt64
    let ramTotal: UInt64
    let activeProcessCount: Int
    let freeDiskGB: Double
    let isXcodeActive: Bool
    let throttleLevel: ThrottleLevel
    let timestamp: Date

    var ramFraction: Double {
        ramTotal > 0 ? Double(ramUsed) / Double(ramTotal) : 0
    }

    var isHighLoad: Bool {
        cpuUsage > 0.8 || ramFraction > 0.85
    }

    var isCritical: Bool {
        cpuUsage > 0.95 || ramFraction > 0.95
    }

    var isIdle: Bool {
        cpuUsage < 0.2
    }

    static let initial = ResourceSnapshot(
        cpuUsage: 0, ramUsed: 0, ramTotal: 1,
        activeProcessCount: 0, freeDiskGB: 0,
        isXcodeActive: false, throttleLevel: .normal,
        timestamp: Date()
    )
}

@MainActor
final class SUPRAResourceGovernor: ObservableObject {
    static let shared = SUPRAResourceGovernor()

    @Published private(set) var snapshot = ResourceSnapshot.initial
    @Published private(set) var isMonitoring = false

    private var timer: Timer?
    private let processInfo = ProcessInfo.processInfo
    private var previousLoad: host_cpu_load_info_data_t?
    private let pollInterval: TimeInterval
    private var idleTicks = 0

    init(pollInterval: TimeInterval = 5) {
        self.pollInterval = pollInterval
    }

    func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true
        previousLoad = cpuLoad()
        poll()
        timer = Timer.scheduledTimer(withTimeInterval: pollInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.poll()
            }
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        isMonitoring = false
    }

    var cpuUsage: Double { snapshot.cpuUsage }
    var ramFraction: Double { snapshot.ramFraction }
    var isHighLoad: Bool { snapshot.isHighLoad }
    var isCritical: Bool { snapshot.isCritical }
    var throttleLevel: ThrottleLevel { snapshot.throttleLevel }
    var throttleFactor: Double { snapshot.throttleLevel.factor }

    private func poll() {
        let cpu = sampleCPU()
        let ram = memoryUsage()
        let processes = activeProcessCount()
        let disk = freeDiskSpace()
        let xcode = isXcodeRunning()
        let throttle = computeThrottle(cpu: cpu, ramFraction: ram.ramFraction, isXcodeActive: xcode)
        snapshot = ResourceSnapshot(
            cpuUsage: cpu,
            ramUsed: ram.used,
            ramTotal: ram.total,
            activeProcessCount: processes,
            freeDiskGB: disk,
            isXcodeActive: xcode,
            throttleLevel: throttle,
            timestamp: Date()
        )
    }

    // MARK: - Throttle logic

    private func computeThrottle(cpu: Double, ramFraction: Double, isXcodeActive: Bool) -> ThrottleLevel {
        if cpu > 0.95 || ramFraction > 0.95 {
            idleTicks = 0
            return .minimal
        }
        if cpu > 0.8 || (cpu > 0.6 && isXcodeActive) {
            idleTicks = 0
            return .reduced
        }
        if cpu < 0.2 {
            idleTicks += 1
        } else {
            idleTicks = 0
        }
        if idleTicks >= 3 {
            idleTicks = 3
            return .normal
        }
        return .normal
    }

    // MARK: - CPU sampling

    private func sampleCPU() -> Double {
        let current = cpuLoad()
        guard let prev = previousLoad else {
            previousLoad = current
            return 0
        }
        previousLoad = current

        let deltaUser = Double(current.cpu_ticks.0 - prev.cpu_ticks.0)
        let deltaSystem = Double(current.cpu_ticks.1 - prev.cpu_ticks.1)
        let deltaIdle = Double(current.cpu_ticks.2 - prev.cpu_ticks.2)
        let total = deltaUser + deltaSystem + deltaIdle
        guard total > 0, deltaUser >= 0, deltaSystem >= 0, deltaIdle >= 0 else { return snapshot.cpuUsage }
        return (deltaUser + deltaSystem) / total
    }

    private func cpuLoad() -> host_cpu_load_info_data_t {
        var info = host_cpu_load_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size)
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
            }
        }
        return result == KERN_SUCCESS ? info : host_cpu_load_info_data_t()
    }

    // MARK: - Memory

    private func memoryUsage() -> (used: UInt64, total: UInt64, ramFraction: Double) {
        var info = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<natural_t>.size)
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        let used = result == KERN_SUCCESS ? info.resident_size : 0
        let total = processInfo.physicalMemory
        return (used, total, total > 0 ? Double(used) / Double(total) : 0)
    }

    // MARK: - Process count

    private func activeProcessCount() -> Int {
        var mib = [CTL_KERN, KERN_PROC, KERN_PROC_ALL]
        var size: size_t = 0
        sysctl(&mib, u_int(mib.count), nil, &size, nil, 0)
        return size / MemoryLayout<kinfo_proc>.size
    }

    // MARK: - Disk space

    private func freeDiskSpace() -> Double {
        let paths = FileManager.default.mountOfVolume(at: URL(fileURLWithPath: "/"))
        guard let path = paths else { return 0 }
        do {
            let values = try path.resourceValues(forKeys: [.volumeAvailableCapacityKey])
            return Double(values.volumeAvailableCapacity ?? 0) / 1_000_000_000
        } catch {
            return 0
        }
    }

    // MARK: - Xcode detection

    private func isXcodeRunning() -> Bool {
        let workspace = NSWorkspace.shared
        return workspace.runningApplications.contains { app in
            app.bundleIdentifier == "com.apple.dt.Xcode"
        }
    }
}

private extension FileManager {
    func mountOfVolume(at url: URL) -> URL? {
        do {
            let values = try url.resourceValues(forKeys: [.volumeURLKey])
            return values.volume
        } catch {
            return nil
        }
    }
}
