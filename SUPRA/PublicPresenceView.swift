import SwiftUI

private struct PublicChannel: Identifiable {
    let id: String
    let name: String
    let role: String
    let status: ExternalConnectionStatus
    let symbol: String
    let priority: String
}

struct PublicPresenceView: View {
    private let channels: [PublicChannel] = [
        .init(id: "linkedin", name: "LinkedIn", role: "Founder + company + B2B authority", status: .authRequired, symbol: "person.text.rectangle.fill", priority: "P1"),
        .init(id: "x", name: "X", role: "Realtime intelligence + technical voice", status: .authRequired, symbol: "text.bubble.fill", priority: "P1"),
        .init(id: "instagram", name: "Instagram / Meta", role: "Visual proof + products + brand", status: .authRequired, symbol: "camera.fill", priority: "P1"),
        .init(id: "youtube", name: "YouTube", role: "Demos + technical narratives + Shorts", status: .authRequired, symbol: "play.rectangle.fill", priority: "P1"),
        .init(id: "gbp", name: "Google Business Profile", role: "Local presence + reviews + posts", status: .approvalRequired, symbol: "mappin.and.ellipse", priority: "P1")
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
                VStack(alignment: .leading, spacing: 11) {
                    HStack {
                        Image(systemName: channel.symbol)
                            .font(.title2)
                            .foregroundStyle(channel.status.tint)
                        Spacer()
                        Text(channel.priority)
                            .font(.caption2.weight(.heavy))
                            .foregroundStyle(.secondary)
                    }

                    Text(channel.name)
                        .font(.headline)

                    Text(channel.role)
                        .font(.callout)
                        .foregroundStyle(.secondary)

                    Divider()

                    Text(channel.status.rawValue)
                        .font(.caption2.weight(.heavy))
                        .foregroundStyle(channel.status.tint)
                }
                .padding(17)
                .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
                .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 18))
            }
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
