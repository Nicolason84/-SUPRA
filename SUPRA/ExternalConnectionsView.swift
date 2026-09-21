import SwiftUI

struct ExternalConnectionsView: View {
    private let columns = [
        GridItem(.adaptive(minimum: 270, maximum: 390), spacing: 14)
    ]

    private var grouped: [(String, [ExternalConnectorDescriptor])] {
        Dictionary(grouping: ExternalConnectorCatalog.all, by: \.family)
            .map { ($0.key, $0.value.sorted { $0.priority < $1.priority }) }
            .sorted { $0.0 < $1.0 }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                hero
                authorityRail
                ForEach(grouped, id: \.0) { family, items in
                    section(family, items: items)
                }
            }
            .padding(26)
            .frame(maxWidth: 1560, alignment: .leading)
            .frame(maxWidth: .infinity)
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
                metric(String(ExternalConnectorCatalog.all.filter { $0.status == .connected }.count), "connected now")
            }
        }
        .padding(22)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
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
        VStack(alignment: .leading, spacing: 12) {
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

                Text(connector.status.rawValue)
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(connector.status.tint)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(connector.status.tint.opacity(0.10), in: Capsule())
            }

            Text(connector.detail)
                .font(.callout)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            Label(connector.officialRoute, systemImage: "link")
                .font(.caption)
                .foregroundStyle(.secondary)

            Label(connector.humanGate, systemImage: "person.badge.key.fill")
                .font(.caption)
                .foregroundStyle(.orange)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 200, alignment: .topLeading)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
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
