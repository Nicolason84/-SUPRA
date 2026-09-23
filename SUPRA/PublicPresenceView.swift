import SwiftUI

private struct PublicChannel: Identifiable {
    let id: String
    let name: String
    let role: String
    let symbol: String
    let priority: String
}

struct PublicPresenceView: View {
    @State private var selectedChannel: PublicChannel?

    private let channels: [PublicChannel] = [
        .init(id: "linkedin", name: "LinkedIn", role: "Founder + company + B2B authority", symbol: "person.text.rectangle.fill", priority: "P1"),
        .init(id: "x", name: "X", role: "Realtime intelligence + technical voice", symbol: "text.bubble.fill", priority: "P1"),
        .init(id: "instagram", name: "Instagram / Meta", role: "Visual proof + products + brand", symbol: "camera.fill", priority: "P1"),
        .init(id: "youtube", name: "YouTube", role: "Demos + technical narratives + Shorts", symbol: "play.rectangle.fill", priority: "P1"),
        .init(id: "gbp", name: "Google Business Profile", role: "Local presence + reviews + posts", symbol: "mappin.and.ellipse", priority: "P1")
    ]

    private let pipeline = [
        "REAL EVENT", "EVIDENCE", "STORY", "DRAFT", "FACT CHECK",
        "BRAND", "HUMAN GATE", "PUBLISH", "ENGAGEMENT", "LEAD", "MEMORY"
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                hero
                channelGrid
                pipelineView
                publicLaw
            }
            .padding(26)
            .frame(maxWidth: 1500, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background(
            LinearGradient(
                colors: [
                    Color.pink.opacity(0.08),
                    Color(nsColor: .windowBackgroundColor),
                    Color(nsColor: .windowBackgroundColor)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .sheet(item: $selectedChannel) { channel in
            channelDetail(channel)
        }
    }

    private var hero: some View {
        HStack(alignment: .center, spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.pink.opacity(0.10))
                Circle()
                    .stroke(Color.pink.opacity(0.34), lineWidth: 1)
                    .padding(7)
                Image(systemName: "dot.radiowaves.left.and.right")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(.pink)
                    .shadow(color: .pink.opacity(0.30), radius: 16)
            }
            .frame(width: 82, height: 82)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text("PRÉSENCE")
                        .font(.caption.weight(.heavy))
                        .tracking(1.8)
                        .foregroundStyle(.pink)
                    Text("CORE SURFACE")
                        .font(.caption2.weight(.heavy))
                        .foregroundStyle(.pink)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(Color.pink.opacity(0.10), in: Capsule())
                }

                Text("Exist visibly. Emit proof. Receive the world.")
                    .font(.system(size: 34, weight: .bold, design: .rounded))

                Text("The external living surface of SUPRA: proven events become public signal, engagement returns as evidence, and every channel feeds Commercial, Product and CAnnoNico.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: 1040, alignment: .leading)
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 24))
    }

    private var channelGrid: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 250, maximum: 340), spacing: 14)],
            alignment: .leading,
            spacing: 14
        ) {
            ForEach(channels) { channel in
                let descriptor = ExternalConnectorCatalog.descriptor(id: channel.id)
                let status = descriptor?.status ?? .planned
                let freshness = descriptor.map { ExternalConnectionProofLedger.freshness(for: $0) }
                let age = ExternalConnectionProofLedger.ageLabel(for: channel.id)

                Button {
                    selectedChannel = channel
                } label: {
                    VStack(alignment: .leading, spacing: 11) {
                        HStack {
                            Image(systemName: channel.symbol)
                                .font(.title2)
                                .foregroundStyle(status.tint)
                            Spacer()
                            Text(channel.priority)
                                .font(.caption2.weight(.heavy))
                                .foregroundStyle(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.tertiary)
                        }

                        Text(channel.name)
                            .font(.headline)

                        Text(channel.role)
                            .font(.callout)
                            .foregroundStyle(.secondary)

                        Divider()

                        HStack(spacing: 7) {
                            Text(status.rawValue)
                                .font(.caption2.weight(.heavy))
                                .foregroundStyle(status.tint)

                            if status == .connected, let freshness {
                                Text(freshness.rawValue)
                                    .font(.caption2.weight(.heavy))
                                    .foregroundStyle(freshness.tint)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(freshness.tint.opacity(0.10), in: Capsule())
                                if let age {
                                    Text(age)
                                        .font(.caption2.monospacedDigit())
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }

                        if let descriptor {
                            Label(descriptor.officialRoute, systemImage: "link")
                                .font(.caption2)
                                .foregroundStyle(.secondary)

                            Label(descriptor.humanGate, systemImage: "person.badge.key.fill")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                        }
                    }
                    .padding(17)
                    .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 18))
            }
        }
    }

    private func channelDetail(_ channel: PublicChannel) -> some View {
        let descriptor = ExternalConnectorCatalog.descriptor(id: channel.id)
        let status = descriptor?.status ?? .planned
        let freshness = descriptor.map { ExternalConnectionProofLedger.freshness(for: $0) }
        let age = ExternalConnectionProofLedger.ageLabel(for: channel.id)

        return ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .top, spacing: 16) {
                    Image(systemName: channel.symbol)
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(status.tint)
                        .frame(width: 58, height: 58)
                        .background(status.tint.opacity(0.10), in: RoundedRectangle(cornerRadius: 16))

                    VStack(alignment: .leading, spacing: 5) {
                        Text(channel.name)
                            .font(.title.bold())
                        Text(channel.role)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text(status.rawValue)
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(status.tint)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 6)
                        .background(status.tint.opacity(0.10), in: Capsule())
                }

                if let descriptor {
                    VStack(alignment: .leading, spacing: 10) {
                        Label(descriptor.detail, systemImage: "scope")
                        Label(descriptor.officialRoute, systemImage: "link")
                        Label(descriptor.humanGate, systemImage: "person.badge.key.fill")
                            .foregroundStyle(.orange)
                        if status == .connected, let freshness {
                            Label("Proof \(freshness.rawValue)\(age.map { " · \($0)" } ?? "")", systemImage: "checkmark.seal.fill")
                                .foregroundStyle(freshness.tint)
                        }
                    }
                    .font(.callout)
                }

                Divider()

                VStack(alignment: .leading, spacing: 10) {
                    Text("What SUPRA adds")
                        .font(.headline)
                    Label("Connection truth + proof freshness instead of a blind external link", systemImage: "checkmark.shield.fill")
                    Label("Mission / product / evidence / lead / memory lineage when source objects exist", systemImage: "point.3.connected.trianglepath.dotted")
                    Label("Engagement and results return to Evidence → Memory → CAnnoNico", systemImage: "arrow.triangle.2.circlepath")
                    Label("Publication and destructive actions stay human-gated", systemImage: "person.badge.key.fill")
                }
                .font(.callout)

                if channel.id == "youtube" {
                    Divider()
                    VStack(alignment: .leading, spacing: 10) {
                        Text("YouTube · Media Hero contract")
                            .font(.headline)
                        Text("SUPRA should not merely reopen youtube.com. The useful target is contextual playback with transcript/metadata, source + product + mission lineage, evidence, notes, related assets, comments/engagement and memory return.")
                            .foregroundStyle(.secondary)
                        if status != .connected {
                            Label("No fake player: YouTube is not connected, and no canonical media item is selected.", systemImage: "exclamationmark.triangle.fill")
                                .font(.callout.weight(.semibold))
                                .foregroundStyle(.orange)
                        }
                    }
                }
            }
            .padding(26)
            .frame(minWidth: 620, idealWidth: 760, maxWidth: 860, alignment: .leading)
        }
    }

    private var pipelineView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Publication circulation", systemImage: "arrow.triangle.2.circlepath")
                .font(.title3.bold())

            ScrollView(.horizontal) {
                HStack(spacing: 7) {
                    ForEach(Array(pipeline.enumerated()), id: \.offset) { index, stage in
                        if index > 0 {
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.tertiary)
                        }

                        Text(stage)
                            .font(.caption2.weight(.heavy))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .glassEffect(.regular, in: Capsule())
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    private var publicLaw: some View {
        HStack(alignment: .top, spacing: 14) {
            law("MUST", .green, [
                "Evidence-backed claims",
                "Channel-specific variants",
                "Publication IDs + timestamps",
                "Engagement → lead linkage"
            ])

            law("FORBIDDEN", .red, [
                "Invented customer results",
                "Fake partnerships",
                "Unproven certifications",
                "Confidential/private data"
            ])
        }
    }

    private func law(_ title: String, _ tint: Color, _ lines: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption.weight(.heavy))
                .tracking(1.2)
                .foregroundStyle(tint)

            ForEach(lines, id: \.self) { line in
                Label(line, systemImage: title == "MUST" ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 170, alignment: .topLeading)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 18))
    }
}
