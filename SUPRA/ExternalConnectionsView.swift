import SwiftUI

private enum ExternalConnectionFilter: String, CaseIterable, Identifiable {
    case all = "ALL"
    case live = "LIVE"
    case attention = "ATTENTION"
    case stale = "STALE"

    var id: Self { self }
}

struct ExternalConnectionsView: View {
    @Environment(\.supraHierarchyFocusRequest) private var focusRequest
    @Environment(\.openURL) private var openURL
    @State private var xReadReady = false
    @State private var inpiReady = false
    @State private var readinessCheckedAt: Date?
    @State private var filter: ExternalConnectionFilter = .all


    private let columns = [
        GridItem(.adaptive(minimum: 270, maximum: 390), spacing: 14)
    ]

    private var grouped: [(String, [ExternalConnectorDescriptor])] {
        let source = ExternalConnectorCatalog.all.filter { connector in
            switch filter {
            case .all:
                return true
            case .live:
                return ExternalConnectionProofLedger.freshness(for: connector) == .live
            case .stale:
                return ExternalConnectionProofLedger.freshness(for: connector) == .stale
            case .attention:
                return connector.status == .authRequired
                    || connector.status == .approvalRequired
                    || connector.status == .providerRequired
                    || connector.status == .blocked
            }
        }

        return Dictionary(grouping: source, by: \.family)
            .map { ($0.key, $0.value.sorted { $0.priority < $1.priority }) }
            .sorted { $0.0 < $1.0 }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                hero
                truthPanel
                filterRail
                authorityRail
                ForEach(grouped, id: \.0) { family, items in
                    section(family, items: items)
                }
            }
            .padding(26)
            .frame(maxWidth: 1560, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .task {
            refreshRuntimeReadiness()
            focusNativeRequest()
        }
        .onChange(of: focusRequest?.id) { _, _ in
            focusNativeRequest()
        }
        .background(
            LinearGradient(
                colors: [
                    Color.cyan.opacity(0.08),
                    Color(nsColor: .windowBackgroundColor),
                    Color(nsColor: .windowBackgroundColor)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    private var hero: some View {
        HStack(alignment: .top, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("EXTERNAL CONNECTIVITY FABRIC")
                    .font(.caption.weight(.heavy))
                    .tracking(1.8)
                    .foregroundStyle(.cyan)

                Text("One nervous system for the real world.")
                    .font(.system(size: 34, weight: .bold, design: .rounded))

                Text("Communications, institutions, finance, public presence and partner systems — read-first, least-privilege, evidence-returned.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: 900, alignment: .leading)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 7) {
                metric(String(ExternalConnectorCatalog.all.count), "connectors")
                metric(String(ExternalConnectorCatalog.all.filter { $0.priority == "P0" }.count), "P0")
                metric(String(ExternalConnectionProofLedger.liveCount), "fresh proof")
                metric(String(ExternalConnectionProofLedger.staleCount), "stale proof")
            }
        }
        .padding(22)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var truthPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Label("CONNECTION TRUTH", systemImage: "checkmark.shield.fill")
                    .font(.caption.weight(.heavy))
                    .tracking(1.4)
                    .foregroundStyle(.cyan)

                Spacer()

                Button {
                    refreshRuntimeReadiness()
                } label: {
                    Label("Refresh local readiness", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }

            Text("CONNECTED means a previously proven authenticated route. Local credential/config readiness is shown separately and is never promoted to CONNECTED without a live proof.")
                .font(.callout)
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                readinessBadge(
                    "X API READ",
                    xReadReady ? "LOCAL READY" : "AUTH MISSING",
                    ready: xReadReady
                )
                readinessBadge(
                    "INPI API",
                    inpiReady ? "LOCAL READY" : "CONFIG MISSING",
                    ready: inpiReady
                )
                readinessBadge(
                    "FRESH PROOF",
                    "\(ExternalConnectionProofLedger.liveCount)",
                    ready: ExternalConnectionProofLedger.liveCount > 0
                )
                readinessBadge(
                    "NEEDS AUTH / APPROVAL",
                    "\(ExternalConnectorCatalog.attentionCount)",
                    ready: ExternalConnectorCatalog.attentionCount == 0
                )
            }

            if let readinessCheckedAt {
                Text("Local readiness checked \(readinessCheckedAt.formatted(date: .omitted, time: .standard)) · secrets remain in Keychain/runtime only.")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(18)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var filterRail: some View {
        HStack(spacing: 8) {
            ForEach(ExternalConnectionFilter.allCases) { item in
                Button {
                    withAnimation(.snappy(duration: 0.18)) {
                        filter = item
                    }
                } label: {
                    HStack(spacing: 7) {
                        Circle()
                            .fill(filterTint(item))
                            .frame(width: 7, height: 7)
                        Text(item.rawValue)
                            .font(.caption2.weight(.heavy))
                    }
                    .padding(.horizontal, 11)
                    .padding(.vertical, 8)
                    .background(
                        filter == item ? filterTint(item).opacity(0.13) : Color.clear,
                        in: Capsule()
                    )
                    .overlay {
                        Capsule()
                            .stroke(
                                filter == item ? filterTint(item).opacity(0.45) : .white.opacity(0.06),
                                lineWidth: 1
                            )
                    }
                }
                .buttonStyle(.plain)
            }

            Spacer()

            Text("\(grouped.reduce(0) { $0 + $1.1.count }) visible")
                .font(.caption2.monospacedDigit().weight(.semibold))
                .foregroundStyle(.secondary)
        }
    }

    private var authorityRail: some View {
        HStack(spacing: 10) {
            authorityBadge("C0", "Public read", tint: .secondary)
            authorityBadge("C1", "Private read", tint: .mint)
            authorityBadge("C2", "Reversible write", tint: .blue)
            authorityBadge("C3", "External send", tint: .orange)
            authorityBadge("C4", "Financial prepare", tint: .yellow)
            authorityBadge("C5", "Money movement", tint: .red)
            authorityBadge("C6", "Legal/admin submit", tint: .purple)
        }
    }

    private func section(_ title: String, items: [ExternalConnectorDescriptor]) -> some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack {
                Text(title.uppercased())
                    .font(.caption.weight(.heavy))
                    .tracking(1.4)
                    .foregroundStyle(.secondary)
                Rectangle()
                    .fill(.white.opacity(0.08))
                    .frame(height: 1)
            }

            LazyVGrid(columns: columns, alignment: .leading, spacing: 14) {
                ForEach(items) { connector in
                    connectorCard(connector)
                }
            }
        }
    }

    private func connectorCard(_ connector: ExternalConnectorDescriptor) -> some View {
        let proof = ExternalConnectionProofLedger.proof(for: connector.id)
        let freshness = ExternalConnectionProofLedger.freshness(for: connector)
        let age = ExternalConnectionProofLedger.ageLabel(for: connector.id)
        let displayedStatus = connector.status == .connected
            ? freshness.rawValue
            : connector.status.rawValue
        let displayedTint = connector.status == .connected
            ? freshness.tint
            : connector.status.tint

        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 11) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(connector.status.tint.opacity(0.14))
                    Image(systemName: connector.systemImage)
                        .font(.headline)
                        .foregroundStyle(connector.status.tint)
                }
                .frame(width: 42, height: 42)

                VStack(alignment: .leading, spacing: 2) {
                    Text(connector.provider)
                        .font(.headline)
                    Text("\(connector.priority) · \(connector.authorityClass)")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 5) {
                    Text(displayedStatus)
                        .font(.caption2.weight(.heavy))
                        .foregroundStyle(displayedTint)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(displayedTint.opacity(0.10), in: Capsule())

                    if connector.status == .connected {
                        HStack(spacing: 5) {
                            Circle()
                                .fill(freshness.tint)
                                .frame(width: 6, height: 6)
                            Text(freshness.rawValue)
                                .font(.system(size: 9, weight: .heavy, design: .rounded))
                                .foregroundStyle(freshness.tint)
                            if let age {
                                Text("· \(age)")
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }

            Text(connector.detail)
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let proof {
                HStack(alignment: .top, spacing: 7) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(freshness.tint)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(proof.evidence)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                        Text(proof.source)
                            .font(.system(size: 9, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)
                    }
                }
            }

            Divider()

            Label(connector.officialRoute, systemImage: "link")
                .font(.caption)
                .foregroundStyle(.secondary)

            Label(connector.humanGate, systemImage: "person.badge.key.fill")
                .font(.caption)
                .foregroundStyle(.orange)

            if connector.id == "x" {
                readinessBadge("LOCAL X", xReadReady ? "READY" : "MISSING", ready: xReadReady)
            } else if connector.id == "inpi-rne" || connector.id == "inpi-ip" {
                readinessBadge("LOCAL INPI", inpiReady ? "READY" : "MISSING", ready: inpiReady)
            }

            if let url = setupURL(for: connector.id) {
                Button {
                    openURL(url)
                } label: {
                    Label(
                        connector.status == .connected ? "Open provider" : "Configure",
                        systemImage: "arrow.up.right.square"
                    )
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 200, alignment: .topLeading)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func setupURL(for id: String) -> URL? {
        let raw: String? = switch id {
        case "x": "https://developer.x.com/"
        case "inpi-rne", "inpi-ip": "https://data.inpi.fr/"
        case "instagram", "whatsapp": "https://developers.facebook.com/"
        case "youtube": "https://console.cloud.google.com/apis/library/youtube.googleapis.com"
        case "gbp": "https://console.cloud.google.com/"
        case "stripe": "https://dashboard.stripe.com/apikeys"
        case "docusign": "https://developers.docusign.com/"
        case "dgfip": "https://api.gouv.fr/"
        case "urssaf": "https://portailapi.urssaf.fr/"
        case "tamarind": "https://www.tamarind.bio/"
        default: nil
        }
        guard let raw else { return nil }
        return URL(string: raw)
    }

    private func filterTint(_ item: ExternalConnectionFilter) -> Color {
        switch item {
        case .all: return .cyan
        case .live: return .green
        case .attention: return .orange
        case .stale: return .yellow
        }
    }

    private func readinessBadge(_ title: String, _ value: String, ready: Bool) -> some View {
        HStack(spacing: 7) {
            Circle()
                .fill(ready ? Color.green : Color.orange)
                .frame(width: 7, height: 7)
            Text(title)
                .font(.caption2.weight(.heavy))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption2.weight(.bold))
                .foregroundStyle(ready ? .green : .orange)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(.quaternary, in: Capsule())
    }

    private func focusNativeRequest() {
        guard focusRequest?.target == .connectionsAttention else { return }
        filter = .attention
        refreshRuntimeReadiness()
    }

    private func refreshRuntimeReadiness() {
        xReadReady = ExternalConnectorRuntimeReadiness.xReadCredentialConfigured
        inpiReady = ExternalConnectorRuntimeReadiness.inpiRuntimeConfigured
        readinessCheckedAt = .now
    }

    private func authorityBadge(_ code: String, _ text: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(code)
                .font(.caption.weight(.heavy))
                .foregroundStyle(tint)
            Text(text)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func metric(_ value: String, _ label: String) -> some View {
        HStack(spacing: 7) {
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(.cyan)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
