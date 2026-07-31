import Foundation
import Combine
import SwiftUI

struct HardwareSnapshot: Hashable {
    let cpuCount: Int
    let cpuFrequencyGHz: Double
    let cpuUsage: Double
    let gpuModel: String
    let gpuVRAMMB: Int
    let physicalRAMGB: Double
    let ramUsedGB: Double
    let storageTotalGB: Double
    let storageFreeGB: Double
    let batteryPresent: Bool
    let batteryPercent: Int
    let batteryCharging: Bool
    let networkReachable: Bool
    let networkInterface: String
    let thermalState: String
    let timestamp: Date
}

@MainActor
final class SUPRAHardwareTwin: ObservableObject {
    static let shared = SUPRAHardwareTwin()

    @Published private(set) var snapshot: HardwareSnapshot?
    @Published private(set) var isCollecting = false
    @Published private(set) var lastError: String?

    private var cached: HardwareSnapshot?
    private var lastHash = 0
    private let ttl: TimeInterval = 60
    private let thermalStateNames: [ProcessInfo.ThermalState: String] = [
        .nominal: "nominal", .fair: "fair", .serious: "serious", .critical: "critical"
    ]

    private init() {}

    func refresh() {
        isCollecting = true
        let h = collectHash()
        guard h != lastHash || snapshot == nil else { isCollecting = false; return }
        lastHash = h
        do {
            let s = try gather()
            cached = s
            snapshot = s
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
        isCollecting = false
    }

    private func collectHash() -> Int {
        var h = Hasher()
        h.combine(ProcessInfo.processInfo.thermalState.rawValue)
        h.combine(ProcessInfo.processInfo.activeProcessorCount)
        h.combine(Int(Date().timeIntervalSince1970 / 60))
        return h.finalize()
    }

    private func gather() throws -> HardwareSnapshot {
        let pi = ProcessInfo.processInfo
        let cpuCount = pi.activeProcessorCount
        let cpuFreq = cpuFrequencyGHz()
        let cpuUsage = currentCpuUsage()
        let gpu = gpuInfo()
        let ramGB = Double(pi.physicalMemory) / 1_073_741_824
        let ramUsed = currentRAMUsedGB()
        let storage = storageInfo()
        let battery = batteryInfo()
        let net = networkInfo()
        let thermal = thermalStateNames[pi.thermalState] ?? "unknown"

        return HardwareSnapshot(
            cpuCount: cpuCount,
            cpuFrequencyGHz: cpuFreq,
            cpuUsage: cpuUsage,
            gpuModel: gpu.model,
            gpuVRAMMB: gpu.vramMB,
            physicalRAMGB: round(ramGB * 10) / 10,
            ramUsedGB: round(ramUsed * 10) / 10,
            storageTotalGB: round(storage.total * 10) / 10,
            storageFreeGB: round(storage.free * 10) / 10,
            batteryPresent: battery.present,
            batteryPercent: battery.percent,
            batteryCharging: battery.charging,
            networkReachable: net.reachable,
            networkInterface: net.interface,
            thermalState: thermal,
            timestamp: Date()
        )
    }

    private func cpuFrequencyGHz() -> Double {
        if let result = try? shell("sysctl -n hw.cpufrequency_max") {
            return (Double(result.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0) / 1_000_000_000
        }
        return 0
    }

    private func currentCpuUsage() -> Double {
        var cpuInfo = host_cpu_load_info()
        var countPtr = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size)
        let result = withUnsafeMutablePointer(to: &cpuInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(countPtr)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &countPtr)
            }
        }
        guard result == KERN_SUCCESS else { return 0 }
        let total = Double(cpuInfo.cpu_ticks.0 + cpuInfo.cpu_ticks.1 + cpuInfo.cpu_ticks.2 + cpuInfo.cpu_ticks.3)
        let idle = Double(cpuInfo.cpu_ticks.3)
        return total > 0 ? min(1.0, (total - idle) / total) : 0
    }

    private func currentRAMUsedGB() -> Double {
        var size = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
        var vmStats = vm_statistics64_data_t()
        let result = withUnsafeMutablePointer(to: &vmStats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &size)
            }
        }
        guard result == KERN_SUCCESS else { return 0 }
        let pageSize = vm_kernel_page_size
        let usedPages = UInt64(vmStats.active_count + vmStats.wire_count)
        return Double(usedPages * UInt64(pageSize)) / 1_073_741_824
    }

    private func gpuInfo() -> (model: String, vramMB: Int) {
        if let result = try? shell("system_profiler SPDisplaysDataType 2>/dev/null | grep -E 'Chipset Model|VRAM'") {
            let lines = result.components(separatedBy: .newlines)
            let model = lines.first { $0.contains("Chipset Model") }?
                .replacingOccurrences(of: "Chipset Model: ", with: "").trimmingCharacters(in: .whitespaces) ?? "Unknown"
            let vram = lines.first { $0.contains("VRAM") }?
                .components(separatedBy: ":").last?
                .trimmingCharacters(in: .whitespaces)
                .components(separatedBy: " ").first ?? "0"
            return (model, Int(vram) ?? 0)
        }
        return ("Unknown", 0)
    }

    private func storageInfo() -> (total: Double, free: Double) {
        let keys: [URLResourceKey] = [.volumeTotalCapacityKey, .volumeAvailableCapacityKey]
        let root = URL(fileURLWithPath: "/")
        guard let values = try? root.resourceValues(forKeys: Set(keys)) else { return (0, 0) }
        return (
            Double(values.volumeTotalCapacity ?? 0) / 1_073_741_824,
            Double(values.volumeAvailableCapacity ?? 0) / 1_073_741_824
        )
    }

    private func batteryInfo() -> (present: Bool, percent: Int, charging: Bool) {
        if let result = try? shell("pmset -g batt 2>/dev/null") {
            let present = result.contains("InternalBattery")
            let percent: Int
            if let pRange = result.range(of: "(\\d+)%", options: .regularExpression) {
                percent = Int(result[pRange].dropLast()) ?? 0
            } else { percent = 0 }
            let charging = result.contains("charging") || result.contains("AC Power")
            return (present, percent, charging)
        }
        return (false, 0, false)
    }

    private func networkInfo() -> (reachable: Bool, interface: String) {
        if let result = try? shell("route -n get default 2>/dev/null | grep interface") {
            let iface = result.components(separatedBy: ":").last?.trimmingCharacters(in: .whitespaces) ?? "—"
            return (true, iface)
        }
        return (false, "—")
    }

    private func shell(_ cmd: String) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", cmd]
        let output = Pipe()
        process.standardOutput = output
        try process.run()
        process.waitUntilExit()
        return String(data: output.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    }
}
