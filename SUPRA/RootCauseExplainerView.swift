import SwiftUI
import CommonCrypto

struct RootCauseCheck: Identifiable {
    let id = UUID()
    let label: String
    let status: CheckStatus
    let expected: String
    let observed: String
    let reason: String
}

enum CheckStatus {
    case pass
    case warning
    case failure

    var icon: String {
        switch self {
        case .pass: "checkmark.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .failure: "xmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .pass: .supraGreen
        case .warning: .supraOrange
        case .failure: .supraRed
        }
    }

    var label: String {
        switch self {
        case .pass: "PASS"
        case .warning: "WARNING"
        case .failure: "FAILURE"
        }
    }
}

struct RootCauseExplainerView: View {
    let checks: [RootCauseCheck]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(checks) { check in
                HStack(spacing: 10) {
                    Image(systemName: check.status.icon)
                        .font(.system(size: 14))
                        .foregroundColor(check.status.color)
                        .frame(width: 20)
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(check.label)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.supraText)
                            Text(check.status.label)
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundColor(check.status.color)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(check.status.color.opacity(0.15))
                                .clipShape(Capsule())
                        }
                        HStack(spacing: 4) {
                            Text("Expected:")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundColor(.supraTextTertiary)
                            Text(check.expected)
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor(.supraTextSecondary)
                        }
                        HStack(spacing: 4) {
                            Text("Observed:")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundColor(.supraTextTertiary)
                            Text(check.observed)
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor(.supraTextSecondary)
                        }
                        if !check.reason.isEmpty {
                            HStack(spacing: 4) {
                                Text("Reason:")
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundColor(check.status == .failure ? .supraRed : .supraOrange)
                                Text(check.reason)
                                    .font(.system(size: 9))
                                    .foregroundColor(check.status == .failure ? .supraRed : .supraOrange)
                            }
                        }
                    }
                    Spacer()
                }
                .padding(10)
                .background(Color.supraSurfaceLight)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(check.status.color.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }
}

extension RootCauseExplainerView {
    static func build(from bootManager: ExecutiveBootManager, continuityManager: ContinuityManager) -> [RootCauseCheck] {
        var checks: [RootCauseCheck] = []

        let freezeCommit = bootManager.freezeMetadata.gitCommit
        let currentCommit = continuityManager.state.gitCommit
        checks.append(RootCauseCheck(
            label: "Git Revision",
            status: freezeCommit == currentCommit || freezeCommit == "—" || currentCommit == "—" ? .pass : .failure,
            expected: freezeCommit,
            observed: currentCommit,
            reason: freezeCommit == currentCommit || freezeCommit == "—" || currentCommit == "—"
                ? "Git commit matches frozen revision"
                : "Current commit \(currentCommit) differs from frozen \(freezeCommit)"
        ))

        let freezeBranch = bootManager.freezeMetadata.gitBranch
        let currentBranch = continuityManager.state.gitBranch
        checks.append(RootCauseCheck(
            label: "Git Branch",
            status: freezeBranch == currentBranch || freezeBranch == "—" || currentBranch == "—" ? .pass : .failure,
            expected: freezeBranch,
            observed: currentBranch,
            reason: freezeBranch == currentBranch || freezeBranch == "—" || currentBranch == "—"
                ? "Git branch matches frozen branch"
                : "Current branch \(currentBranch) differs from frozen \(freezeBranch)"
        ))

        let buildStatus = bootManager.freezeMetadata.buildStatus
        checks.append(RootCauseCheck(
            label: "Build Status",
            status: buildStatus == "SUCCEEDED" ? .pass : .warning,
            expected: "SUCCEEDED",
            observed: buildStatus,
            reason: buildStatus == "SUCCEEDED" ? "Build passed" : "Build status: \(buildStatus)"
        ))

        let freezeTimestamp = bootManager.freezeMetadata.timestamp
        checks.append(RootCauseCheck(
            label: "Freeze Timestamp",
            status: freezeTimestamp != "—" ? .pass : .warning,
            expected: "Valid ISO date",
            observed: freezeTimestamp,
            reason: freezeTimestamp != "—" ? "Freeze timestamp present" : "No freeze timestamp recorded"
        ))

        let runtimeVersion = bootManager.freezeMetadata.runtimeVersion
        checks.append(RootCauseCheck(
            label: "Runtime Version",
            status: runtimeVersion != "—" ? .pass : .warning,
            expected: "SUPRAOperationalCoreApp",
            observed: runtimeVersion,
            reason: runtimeVersion != "—" ? "Runtime version resolved" : "Runtime version unknown"
        ))

        let continuityVersion = continuityManager.state.runtimeVersion
        checks.append(RootCauseCheck(
            label: "Continuity Version",
            status: continuityVersion != "—" ? .pass : .warning,
            expected: "≥ 1.0.0",
            observed: continuityVersion,
            reason: continuityVersion != "—" ? "Continuity state version resolved" : "Continuity version unknown"
        ))

        let artifactHash = artifactHash()
        checks.append(RootCauseCheck(
            label: "Artifact Hashes",
            status: artifactHash.status,
            expected: artifactHash.expected,
            observed: artifactHash.observed,
            reason: artifactHash.reason
        ))

        return checks
    }

    private static func artifactHash() -> (status: CheckStatus, expected: String, observed: String, reason: String) {
        let root = SUPRAEnvironmentResolver.shared.projectRoot
        let paths = [
            ("LOT1", "\(root)/proofs/LOT1_INSTALLATION_PROOF.json"),
            ("LOT2", "\(root)/proofs/LOT2_INSTALLATION_PROOF.json"),
            ("LOT3", "\(root)/proofs/LOT3_INSTALLATION_PROOF.json"),
        ]
        var allValid = true
        var details: [String] = []
        for (name, path) in paths {
            if let data = FileManager.default.contents(atPath: path) {
                let hash = data.sha256Hex
                details.append("\(name):\(hash.prefix(16))")
            } else {
                allValid = false
                details.append("\(name):MISSING")
            }
        }
        let observed = details.joined(separator: " ")
        if allValid {
            return (.pass, "All artifacts present", observed, "All 3 LOT artifacts readable")
        } else {
            return (.failure, "All artifacts present", observed, "Some artifacts missing or unreadable")
        }
    }
}


