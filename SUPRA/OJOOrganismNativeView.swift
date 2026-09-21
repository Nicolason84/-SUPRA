import SwiftUI
import Foundation

struct OJOOrganismEnvelope: Codable, Sendable {
    let updatedAt: String?
    let state: OJOOrganismState
    let learning: OJOLearningState?
    let controlReadiness: OJOControlReadiness?
    let sourceSequences: OJOSourceSequences?

    enum CodingKeys: String, CodingKey {
        case updatedAt = "updated_at"
        case state
        case learning
        case controlReadiness = "control_readiness"
        case sourceSequences = "source_sequences"
    }

    static let fallback = OJOOrganismEnvelope(
        updatedAt: nil,
        state: OJOOrganismState(
            strain: 0.1077,
            vigilance: 0.32,
            asymmetry: 0.11,
            arms: [
                "macro": 0.32,
                "budget": 0.1833,
                "energy": 0.0234,
                "finance": 0.0063,
                "logistics": 0.153,
                "climate": 0,
                "health": 0.0108,
                "geopolitics": 0.0167
            ],
            regime: "CALM",
            topArm: "macro",
            heartRateVisual: 60,
            respirationVisual: 10.7,
            sensorHealth: 1
        ),
        learning: OJOLearningState(stage: "BOOTSTRAP", samples: 1),
        controlReadiness: OJOControlReadiness(
            sensorCoverage: 1,
            mathematicalObservability: "UNPROVEN",
            controllability: "UNPROVEN",
            closedLoopControl: "NOT_READY"
        ),
        sourceSequences: OJOSourceSequences(budget: 6, environment: 4)
    )
}

struct OJOOrganismState: Codable, Sendable {
    let strain: Double
    let vigilance: Double
    let asymmetry: Double
    let arms: [String: Double]
    let regime: String
    let topArm: String
    let heartRateVisual: Int
    let respirationVisual: Double
    let sensorHealth: Double

    enum CodingKeys: String, CodingKey {
        case strain, vigilance, asymmetry, arms, regime
        case topArm = "top_arm"
        case heartRateVisual = "heart_rate_visual"
        case respirationVisual = "respiration_visual"
        case sensorHealth = "sensor_health"
    }
}

struct OJOLearningState: Codable, Sendable {
    let stage: String
    let samples: Int
}

struct OJOControlReadiness: Codable, Sendable {
    let sensorCoverage: Double?
    let mathematicalObservability: String?
    let controllability: String?
    let closedLoopControl: String?

    enum CodingKeys: String, CodingKey {
        case sensorCoverage = "sensor_coverage"
        case mathematicalObservability = "mathematical_observability"
        case controllability
        case closedLoopControl = "closed_loop_control"
    }
}

struct OJOSourceSequences: Codable, Sendable {
    let budget: Int?
    let environment: Int?
}

@MainActor
final class OJOOrganismNativeStore: ObservableObject {
    @Published private(set) var envelope: OJOOrganismEnvelope = .fallback
    @Published private(set) var isLive = false
    @Published private(set) var lastError: String?

    private let endpoint = URL(
        string: "https://raw.githubusercontent.com/Nicolason84/nova-trust/main/docs/data/organism-state.json"
    )!
    private let cacheKey = "OJO_ORGANISM_NATIVE_CACHE_V1"

    init() {
        if let cached = UserDefaults.standard.data(forKey: cacheKey),
           let decoded = try? JSONDecoder().decode(OJOOrganismEnvelope.self, from: cached) {
            envelope = decoded
        }
    }

    func run() async {
        while !Task.isCancelled {
            await refresh()
            try? await Task.sleep(nanoseconds: 15_000_000_000)
        }
    }

    func refresh() async {
        var request = URLRequest(url: endpoint)
        request.timeoutInterval = 8
        request.cachePolicy = .reloadIgnoringLocalCacheData

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse,
                  (200..<300).contains(http.statusCode)
            else {
                throw URLError(.badServerResponse)
            }

            let decoded = try JSONDecoder().decode(OJOOrganismEnvelope.self, from: data)
            envelope = decoded
            isLive = true
            lastError = nil
            UserDefaults.standard.set(data, forKey: cacheKey)
        } catch {
            isLive = false
            lastError = error.localizedDescription
        }
    }
}

struct OJOOrganismNativeView: View {
    @StateObject private var store = OJOOrganismNativeStore()
    @State private var selectedArm: String?

    private let armOrder = [
        "macro", "budget", "energy", "finance",
        "logistics", "climate", "health", "geopolitics"
    ]

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                organismStage
                    .frame(minWidth: max(650, geometry.size.width * 0.66))
                inspector
                    .frame(width: max(310, geometry.size.width * 0.28))
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(nsColor: .windowBackgroundColor),
                        Color.black.opacity(0.82)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .task { await store.run() }
    }

    private var organismStage: some View {
        VStack(alignment: .leading, spacing: 18) {
            header

            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                Canvas { context, size in
                    drawOrganism(
                        context: &context,
                        size: size,
                        date: timeline.date,
                        state: store.envelope.state
                    )
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectNextArm()
                }
                .overlay(alignment: .bottomLeading) {
                    armLegend
                        .padding(20)
                }
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.black.opacity(0.28))
                        .overlay {
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(.white.opacity(0.07), lineWidth: 1)
                        }
                )
            }
        }
        .padding(26)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 18) {
            VStack(alignment: .leading, spacing: 7) {
                Text("ojO · ORGANISM")
                    .font(.caption.bold())
                    .tracking(2.2)
                    .foregroundStyle(.secondary)
                Text("La donnée devient matière.")
                    .font(.system(size: 36, weight: .semibold, design: .rounded))
                Text("Un organisme natif, vivant et raccordé au même état canonique que SUPRA.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 8) {
                Circle()
                    .fill(store.isLive ? Color.green : Color.orange)
                    .frame(width: 8, height: 8)
                Text(store.isLive ? "LIVE" : "CACHE")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(.thinMaterial, in: Capsule())
        }
    }

    private var inspector: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                stateCard
                armCard
                learningCard
                truthCard
            }
            .padding(22)
        }
        .background(.ultraThinMaterial)
        .overlay(alignment: .leading) {
            Rectangle().fill(.white.opacity(0.07)).frame(width: 1)
        }
    }

    private var stateCard: some View {
        let state = store.envelope.state
        return inspectorCard("ÉTAT ACTUEL", symbol: "heart.text.square") {
            Text(regimeLabel(state.regime))
                .font(.system(size: 31, weight: .bold, design: .rounded))
            Text("Pulse \(state.heartRateVisual) · respiration \(state.respirationVisual, specifier: "%.1f")")
                .foregroundStyle(.secondary)
            metric("Tension", state.strain)
            metric("Vigilance", state.vigilance)
            metric("Capteurs", state.sensorHealth)
        }
    }

    private var armCard: some View {
        let state = store.envelope.state
        let arm = selectedArm ?? state.topArm
        let value = state.arms[arm] ?? 0

        return inspectorCard("ORGANE", symbol: "point.3.connected.trianglepath.dotted") {
            Text(displayName(arm))
                .font(.title2.bold())
            Text(arm == state.topArm ? "Bras dominant" : "Organe sélectionné")
                .font(.caption)
                .foregroundStyle(.secondary)
            metric("Activation", value)
            Text("Touchez un bras dans l’organisme pour l’isoler.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var learningCard: some View {
        let learning = store.envelope.learning
        let readiness = store.envelope.controlReadiness

        return inspectorCard("APPRENTISSAGE", symbol: "brain.head.profile") {
            HStack {
                Text(learning?.stage ?? "—")
                    .font(.headline)
                Spacer()
                Text("\(learning?.samples ?? 0) états")
                    .foregroundStyle(.secondary)
            }

            Divider()

            statusRow(
                "Observabilité",
                readiness?.mathematicalObservability ?? "UNPROVEN"
            )
            statusRow(
                "Contrôlabilité",
                readiness?.controllability ?? "UNPROVEN"
            )
            statusRow(
                "Boucle fermée",
                readiness?.closedLoopControl ?? "NOT_READY"
            )
        }
    }

    private var truthCard: some View {
        inspectorCard("TRUTH / NON-RÉGRESSION", symbol: "checkmark.shield") {
            Label("Dernier état sain conservé", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Label("Fallback natif immédiat", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Label("Aucun WebView", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)

            if let error = store.lastError {
                Text(error)
                    .font(.caption2)
                    .foregroundStyle(.orange)
                    .textSelection(.enabled)
            }
        }
    }

    private var armLegend: some View {
        HStack(spacing: 8) {
            ForEach(armOrder, id: \.self) { arm in
                let value = store.envelope.state.arms[arm] ?? 0
                Button {
                    selectedArm = arm
                } label: {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(color(for: arm, activation: value))
                            .frame(width: 7, height: 7)
                        Text(displayName(arm))
                            .font(.caption2.bold())
                    }
                }
                .buttonStyle(.plain)
                .opacity(selectedArm == nil || selectedArm == arm ? 1 : 0.55)
            }
        }
        .padding(9)
        .background(.ultraThinMaterial, in: Capsule())
    }

    @ViewBuilder
    private func inspectorCard<Content: View>(
        _ title: String,
        symbol: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: symbol)
                .font(.caption.bold())
                .tracking(1.2)
                .foregroundStyle(.secondary)
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
    }

    private func metric(_ title: String, _ value: Double) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(title).font(.caption)
                Spacer()
                Text("\(Int((value * 100).rounded()))%")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.08))
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.cyan.opacity(0.8), .orange.opacity(0.9)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(2, proxy.size.width * min(max(value, 0), 1)))
                }
            }
            .frame(height: 6)
        }
    }

    private func statusRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .font(.caption.monospaced())
                .foregroundStyle(value.contains("UNPROVEN") || value.contains("NOT_READY") ? .orange : .green)
        }
    }

    private func drawOrganism(
        context: inout GraphicsContext,
        size: CGSize,
        date: Date,
        state: OJOOrganismState
    ) {
        let center = CGPoint(x: size.width * 0.5, y: size.height * 0.48)
        let t = date.timeIntervalSinceReferenceDate
        let heartHz = max(0.5, Double(state.heartRateVisual) / 60.0)
        let pulse = 0.5 + 0.5 * sin(t * heartHz * .pi * 2)
        let breathHz = max(0.08, state.respirationVisual / 60.0)
        let breath = 0.5 + 0.5 * sin(t * breathHz * .pi * 2)
        let bodyRadius = min(size.width, size.height) * (0.14 + 0.025 * breath)

        // Ambient field.
        for ring in 1...5 {
            let radius = bodyRadius * (1.5 + Double(ring) * 0.5)
            var ellipse = Path()
            ellipse.addEllipse(
                in: CGRect(
                    x: center.x - radius,
                    y: center.y - radius,
                    width: radius * 2,
                    height: radius * 2
                )
            )
            context.stroke(
                ellipse,
                with: .color(.cyan.opacity(0.025 + Double(ring) * 0.008)),
                lineWidth: 1
            )
        }

        // Arms / nervous paths.
        for (index, arm) in armOrder.enumerated() {
            let activation = state.arms[arm] ?? 0
            let angle = Double(index) / Double(armOrder.count) * .pi * 2 - .pi / 2
            let length = min(size.width, size.height) * (0.31 + 0.10 * activation)
            let end = CGPoint(
                x: center.x + cos(angle) * length,
                y: center.y + sin(angle) * length
            )
            let perpendicular = CGPoint(x: -sin(angle), y: cos(angle))
            let bend = CGFloat(sin(t * 0.8 + Double(index)) * (10 + 20 * activation))
            let c1 = CGPoint(
                x: center.x + cos(angle) * length * 0.36 + perpendicular.x * bend,
                y: center.y + sin(angle) * length * 0.36 + perpendicular.y * bend
            )
            let c2 = CGPoint(
                x: center.x + cos(angle) * length * 0.72 - perpendicular.x * bend * 0.7,
                y: center.y + sin(angle) * length * 0.72 - perpendicular.y * bend * 0.7
            )

            var path = Path()
            path.move(to: center)
            path.addCurve(to: end, control1: c1, control2: c2)

            context.drawLayer { layer in
                layer.addFilter(
                    .shadow(
                        color: color(for: arm, activation: activation).opacity(0.6),
                        radius: 8
                    )
                )
                layer.stroke(
                    path,
                    with: .color(color(for: arm, activation: activation).opacity(0.78)),
                    lineWidth: 2.5 + CGFloat(activation * 9)
                )
            }

            // Circulating pulse.
            let progress = (t * (0.05 + activation * 0.12) + Double(index) / 8)
                .truncatingRemainder(dividingBy: 1)
            let dot = cubicPoint(progress, center, c1, c2, end)
            context.fill(
                Path(ellipseIn: CGRect(x: dot.x - 4, y: dot.y - 4, width: 8, height: 8)),
                with: .color(.white.opacity(0.75))
            )

            // Terminal organ.
            let nodeRadius = CGFloat(7 + activation * 12)
            context.drawLayer { layer in
                layer.addFilter(.shadow(color: color(for: arm, activation: activation), radius: 10))
                layer.fill(
                    Path(
                        ellipseIn: CGRect(
                            x: end.x - nodeRadius,
                            y: end.y - nodeRadius,
                            width: nodeRadius * 2,
                            height: nodeRadius * 2
                        )
                    ),
                    with: .color(color(for: arm, activation: activation).opacity(0.82))
                )
            }
        }

        // Membrane layers.
        for layerIndex in stride(from: 4, through: 1, by: -1) {
            let ratio = CGFloat(1 + Double(layerIndex) * 0.11)
            let radius = bodyRadius * ratio
            context.drawLayer { layer in
                layer.addFilter(.shadow(color: .cyan.opacity(0.18), radius: 18))
                layer.fill(
                    Path(
                        ellipseIn: CGRect(
                            x: center.x - radius,
                            y: center.y - radius * 0.83,
                            width: radius * 2,
                            height: radius * 1.66
                        )
                    ),
                    with: .color(
                        Color.cyan.opacity(0.016 * Double(layerIndex) + 0.01 * pulse)
                    )
                )
            }
        }

        // Inner organs.
        let organOffsets: [(Double, Double, Color)] = [
            (-0.28, -0.08, .purple),
            (0.25, -0.18, .cyan),
            (-0.08, 0.25, .orange),
            (0.28, 0.20, .indigo)
        ]

        for (index, item) in organOffsets.enumerated() {
            let x = center.x + CGFloat(item.0) * bodyRadius
            let y = center.y + CGFloat(item.1) * bodyRadius
            let r = bodyRadius * CGFloat(0.24 + 0.03 * sin(t + Double(index)))
            context.drawLayer { layer in
                layer.addFilter(.shadow(color: item.2.opacity(0.7), radius: 14))
                layer.fill(
                    Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)),
                    with: .color(item.2.opacity(0.22))
                )
                layer.stroke(
                    Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)),
                    with: .color(.white.opacity(0.12)),
                    lineWidth: 1
                )
            }
        }

        // Heart / pulse.
        let heartRadius = bodyRadius * CGFloat(0.20 + 0.08 * pulse)
        context.drawLayer { layer in
            layer.addFilter(.shadow(color: .orange.opacity(0.9), radius: 22))
            layer.fill(
                Path(
                    ellipseIn: CGRect(
                        x: center.x - heartRadius,
                        y: center.y - heartRadius,
                        width: heartRadius * 2,
                        height: heartRadius * 2
                    )
                ),
                with: .color(.orange.opacity(0.62))
            )
        })
    }

    private func selectNextArm() {
        let current = selectedArm.flatMap { armOrder.firstIndex(of: $0) } ?? -1
        selectedArm = armOrder[(current + 1) % armOrder.count]
    }

    private func cubicPoint(
        _ progress: Double,
        _ p0: CGPoint,
        _ p1: CGPoint,
        _ p2: CGPoint,
        _ p3: CGPoint
    ) -> CGPoint {
        let t = CGFloat(progress)
        let u = 1 - t
        let x =
            u * u * u * p0.x
            + 3 * u * u * t * p1.x
            + 3 * u * t * t * p2.x
            + t * t * t * p3.x
        let y =
            u * u * u * p0.y
            + 3 * u * u * t * p1.y
            + 3 * u * t * t * p2.y
            + t * t * t * p3.y
        return CGPoint(x: x, y: y)
    }

    private func color(for arm: String, activation: Double) -> Color {
        let base: Color
        switch arm {
        case "macro": base = .cyan
        case "budget": base = .orange
        case "energy": base = .blue
        case "finance": base = .purple
        case "logistics": base = .mint
        case "climate": base = .teal
        case "health": base = .pink
        case "geopolitics": base = .indigo
        default: base = .white
        }
        return base.opacity(0.5 + min(max(activation, 0), 1) * 0.5)
    }

    private func displayName(_ arm: String) -> String {
        switch arm {
        case "macro": return "MACRO"
        case "budget": return "BUDGET"
        case "energy": return "ÉNERGIE"
        case "finance": return "FINANCE"
        case "logistics": return "LOGISTIQUE"
        case "climate": return "CLIMAT"
        case "health": return "SANTÉ"
        case "geopolitics": return "GÉOPOLITIQUE"
        default: return arm.uppercased()
        }
    }

    private func regimeLabel(_ regime: String) -> String {
        switch regime {
        case "CALM": return "CALME"
        case "VIGILANT": return "VIGILANCE"
        case "STRESS": return "TENSION"
        case "SHOCK": return "CHOC"
        case "RECOVERY": return "RÉCUPÉRATION"
        case "BLIND_SPOT": return "ANGLE MORT"
        default: return regime
        }
    }
}
