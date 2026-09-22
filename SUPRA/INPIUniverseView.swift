import SwiftUI

private struct INPIDomain: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let symbol: String
    let cadence: String
    let priority: String
}

struct INPIUniverseView: View {
    @State private var apiConfigured = false
    private let domains: [INPIDomain] = [
        .init(id: "rne", title: "RNE / Entreprises", subtitle: "Identity, creations, modifications and cessations.", symbol: "building.2.fill", cadence: "Daily", priority: "P0"),
        .init(id: "accounts", title: "Comptes annuels", subtitle: "Public annual accounts and financial statements.", symbol: "chart.bar.doc.horizontal.fill", cadence: "Daily", priority: "P0"),
        .init(id: "acts", title: "Actes & statuts", subtitle: "Corporate acts, statutes and filed legal documents.", symbol: "doc.text.fill", cadence: "Daily", priority: "P0"),
        .init(id: "marks", title: "Marques", subtitle: "FR, EU and WO trademark notices, media and watchlists.", symbol: "seal.fill", cadence: "Weekly", priority: "P0"),
        .init(id: "patents", title: "Brevets", subtitle: "FR / EP / WO patents, status, notices and documents.", symbol: "lightbulb.max.fill", cadence: "Weekly", priority: "P0"),
        .init(id: "designs", title: "Dessins & modèles", subtitle: "French and international designs/models and reproductions.", symbol: "square.on.square.fill", cadence: "Weekly / biweekly", priority: "P0")
    ]

    private let watchTargets = [
        "NOVA ERA",
        "SUPRA",
        "ojO",
        "ProofGraph",
        "USCRC-One",
        "Φ-Coin"
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                hero
                sourceTruth
                domainGrid
                watchlist
                gatePanel
            }
            .padding(26)
            .frame(maxWidth: 1500, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(
            LinearGradient(
                colors: [
                    Color.indigo.opacity(0.11),
                    Color(nsColor: .windowBackgroundColor),
                    Color(nsColor: .windowBackgroundColor)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .task {
            apiConfigured = INPIOfficialConnectorConfiguration.fromRuntime() != nil
        }
    }

    private var hero: some View {
        HStack(alignment: .top, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text("INPI")
                        .font(.caption.weight(.heavy))
                        .tracking(1.8)
                        .foregroundStyle(.indigo)
                    Text("P0 STRATEGIC UNIVERSE")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                }

                Text("Corporate truth + industrial property intelligence.")
                    .font(.system(size: 34, weight: .bold, design: .rounded))

                Text("RNE · comptes · actes · marques · brevets · dessins & modèles · watchlists · conflicts · filing candidates · evidence packs.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: 900, alignment: .leading)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 7) {
                stateBadge(
                    apiConfigured ? "OFFICIAL API CONFIGURED" : "OFFICIAL API AUTH REQUIRED",
                    apiConfigured ? .green : .orange
                )
                stateBadge(
                    apiConfigured ? "READ READY" : "READ BLOCKED UNTIL AUTH",
                    apiConfigured ? .mint : .secondary
                )
                stateBadge("FILINGS HUMAN-GATED", .orange)
            }
        }
        .padding(22)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var sourceTruth: some View {
        HStack(spacing: 12) {
            truthCard("Entreprise", "RNE / CMC", "Daily", "building.columns.fill")
            truthCard("Finance", "Annual accounts", "Daily", "eurosign.square.fill")
            truthCard("Legal", "Acts / statutes", "Daily", "doc.text.magnifyingglass")
            truthCard("IP", "Marks / patents / designs", "Periodic", "seal.fill")
        }
    }

    private var domainGrid: some View {
        VStack(alignment: .leading, spacing: 13) {
            Label("Official datasets", systemImage: "square.grid.2x2.fill")
                .font(.title3.bold())

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 270, maximum: 390), spacing: 14)],
                alignment: .leading,
                spacing: 14
            ) {
                ForEach(domains) { domain in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: domain.symbol)
                                .font(.title2)
                                .foregroundStyle(.indigo)
                            Spacer()
                            Text(domain.priority)
                                .font(.caption2.weight(.heavy))
                                .foregroundStyle(.indigo)
                        }

                        Text(domain.title)
                            .font(.headline)

                        Text(domain.subtitle)
                            .font(.callout)
                            .foregroundStyle(.secondary)

                        Divider()

                        Label(domain.cadence, systemImage: "clock.arrow.circlepath")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(17)
                    .frame(maxWidth: .infinity, minHeight: 170, alignment: .topLeading)
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            }
        }
    }

    private var watchlist: some View {
        VStack(alignment: .leading, spacing: 13) {
            Label("Canonical watchlist", systemImage: "eye.fill")
                .font(.title3.bold())

            FlowLayout(items: watchTargets)
        }
    }

    private var gatePanel: some View {
        HStack(alignment: .top, spacing: 14) {
            panel(
                title: "AUTONOMOUS",
                icon: "bolt.fill",
                tint: .green,
                lines: ["Search / monitor", "Conflict research", "Corporate evidence", "Watchlist alerts", "Evidence pack preparation"]
            )

            panel(
                title: "HUMAN GATE",
                icon: "person.badge.key.fill",
                tint: .orange,
                lines: ["Trademark filing", "Patent filing", "Design filing", "Company-data change", "Fee payment", "Legal representation"]
            )
        }
    }

    private func truthCard(_ title: String, _ value: String, _ cadence: String, _ icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.indigo)
            Text(title).font(.caption.weight(.bold))
            Text(value).font(.headline)
            Text(cadence).font(.caption2).foregroundStyle(.secondary)
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
    }

    private func stateBadge(_ text: String, _ tint: Color) -> some View {
        Text(text)
            .font(.caption2.weight(.heavy))
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(tint.opacity(0.10), in: Capsule())
    }

    private func panel(title: String, icon: String, tint: Color, lines: [String]) -> some View {
        VStack(alignment: .leading, spacing: 11) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(tint)

            ForEach(lines, id: \.self) { line in
                Label(line, systemImage: "checkmark")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 190, alignment: .topLeading)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 18))
    }
}

private struct FlowLayout: View {
    let items: [String]

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 140, maximum: 220), spacing: 10)],
            alignment: .leading,
            spacing: 10
        ) {
            ForEach(items, id: \.self) { item in
                Label(item, systemImage: "scope")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.indigo)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glassEffect(.regular, in: Capsule())
            }
        }
    }
}
