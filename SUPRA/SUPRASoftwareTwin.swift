import Foundation
import Combine

struct SoftwareSnapshot {
    let applicationCount: Int
    let systemAppCount: Int
    let userAppCount: Int
    let recentApps: [String]
    let launchAgentsCount: Int
    let servicesCount: Int
    let extensionsCount: Int
    let hasFullDiskAccess: Bool
    let hasDeveloperTools: Bool
    let osVersion: String
    let xcodeVersion: String?
    let timestamp: Date
}

struct SoftwareApplication: Identifiable {
    let id: String
    let name: String
    let version: String
    let path: String
    let isSystem: Bool
}

@MainActor
final class SUPRASoftwareTwin: ObservableObject {
    static let shared = SUPRASoftwareTwin()

    @Published private(set) var snapshot: SoftwareSnapshot?
    @Published private(set) var applications: [SoftwareApplication] = []
    @Published private(set) var isCollecting = false
    @Published private(set) var lastError: String?

    private var cached: SoftwareSnapshot?
    private var lastHash = 0
    private let ttl: TimeInterval = 120

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
        if let apps = try? FileManager.default.contentsOfDirectory(atPath: "/Applications") {
            h.combine(apps.count)
        }
        h.combine(Int(Date().timeIntervalSince1970 / 120))
        return h.finalize()
    }

    private func gather() throws -> SoftwareSnapshot {
        let fm = FileManager.default

        let systemApps = (try? fm.contentsOfDirectory(atPath: "/System/Applications")) ?? []
        let userApps = (try? fm.contentsOfDirectory(atPath: "/Applications")) ?? []
        let systemCount = systemApps.filter { $0.hasSuffix(".app") }.count
        let userCount = userApps.filter { $0.hasSuffix(".app") }.count

        let allApps = (systemApps + userApps).filter { $0.hasSuffix(".app") }.sorted()
        let recentApps = Array(allApps.prefix(6))

        let launchAgents: Int
        if let user = try? fm.contentsOfDirectory(atPath: NSHomeDirectory() + "/Library/LaunchAgents"),
           let system = try? fm.contentsOfDirectory(atPath: "/Library/LaunchAgents") {
            launchAgents = user.count + system.count
        } else { launchAgents = 0 }

        let servicesCount = (try? shell("launchctl list 2>/dev/null | wc -l"))
            .flatMap { Int($0.trimmingCharacters(in: .whitespacesAndNewlines)) } ?? 0

        let extensions = (try? fm.contentsOfDirectory(atPath: "/Library/Extensions")) ?? []
        let osVersion = ProcessInfo.processInfo.operatingSystemVersionString

        let xcodeVersion = try? shell("/usr/bin/xcodebuild -version 2>/dev/null | head -1")

        let hasFullDisk = fm.isReadableFile(atPath: "/Library/Application Support")

        return SoftwareSnapshot(
            applicationCount: systemCount + userCount,
            systemAppCount: systemCount,
            userAppCount: userCount,
            recentApps: recentApps.map { $0.replacingOccurrences(of: ".app", with: "") },
            launchAgentsCount: launchAgents,
            servicesCount: servicesCount,
            extensionsCount: extensions.count,
            hasFullDiskAccess: hasFullDisk,
            hasDeveloperTools: xcodeVersion != nil,
            osVersion: osVersion,
            xcodeVersion: xcodeVersion?.trimmingCharacters(in: .whitespacesAndNewlines),
            timestamp: Date()
        )
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
