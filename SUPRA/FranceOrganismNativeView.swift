import SwiftUI
import Foundation
import Combine

struct FranceOrganismEnvelope: Codable, Sendable {
    let updatedAt: String?
    let topology: FranceTopology
    let physiology: FrancePhysiology
    let nextResolution: [String: String]?

    enum CodingKeys: String, CodingKey {
        case updatedAt = "updated_at"
        case topology
        case physiology
        case nextResolution = "next_resolution"
    }

    static let fallback = FranceOrganismEnvelope(
        updatedAt: nil,
        topology: FranceTopology(
            counts: FranceCounts(regions: 18, departments: 101, epcis: 1252, communes: 34875),
            regions: FranceRegion.fallback
        ),
        physiology: FrancePhysiology(
            regime: "CALM",
            strain: 0.11,
            vigilance: 0.32,
            heartRateVisual: 60,
            respirationVisual: 10.7,
            sensorHealth: 1,
            systems: [
                "macro": 0.32, "budget": 0.18, "energy": 0.04, "finance": 0.01,
                "logistics": 0.15, "climate": 0, "health": 0.01, "geopolitics": 0.02
            ],
            learning: FranceLearning(stage: "BOOTSTRAP", samples: 5)
        ),
        nextResolution: [
            "territorial_event_binding": "PENDING",
            "region_specific_systems": "PENDING",
            "department_epci_commune_drilldown": "TOPOLOGY_READY"
        ]
    )
}

struct FranceTopology: Codable, Sendable {
    let counts: FranceCounts
    let regions: [FranceRegion]
}

struct FranceCounts: Codable, Sendable {
    let regions: Int
    let departments: Int
    let epcis: Int
    let communes: Int
}

struct FranceRegion: Codable, Sendable, Identifiable {
    let code: String
    let name: String
    let population: Int
    let departments: Int
    let epcis: Int
    let communes: Int
    let populationShare: Double?
    let state: String?
    let localPressure: String?
    let systems: [String: Double]?
    let truth: String?

    var id: String { code }

    enum CodingKeys: String, CodingKey {
        case code, name, population, departments, epcis, communes, state, systems, truth
        case populationShare = "population_share"
        case localPressure = "local_pressure"
    }

    static let fallback: [FranceRegion] = [
        .init(code:"01",name:"Guadeloupe",population:384160,departments:1,epcis:6,communes:32,populationShare:0.0056,state:"OBSERVED",localPressure:"UNRESOLVED",systems:nil,truth:nil),
        .init(code:"02",name:"Martinique",population:360630,departments:1,epcis:3,communes:34,populationShare:0.0053,state:"OBSERVED",localPressure:"UNRESOLVED",systems:nil,truth:nil),
        .init(code:"03",name:"Guyane",population:293996,departments:1,epcis:4,communes:22,populationShare:0.0043,state:"OBSERVED",localPressure:"UNRESOLVED",systems:nil,truth:nil),
        .init(code:"04",name:"La Réunion",population:889679,departments:1,epcis:5,communes:24,populationShare:0.0130,state:"OBSERVED",localPressure:"UNRESOLVED",systems:nil,truth:nil),
        .init(code:"06",name:"Mayotte",population:256518,departments:1,epcis:5,communes:17,populationShare:0.0038,state:"OBSERVED",localPressure:"UNRESOLVED",systems:nil,truth:nil),
        .init(code:"11",name:"Île-de-France",population:12463067,departments:8,epcis:52,communes:1266,populationShare:0.1823,state:"OBSERVED",localPressure:"UNRESOLVED",systems:nil,truth:nil),
        .init(code:"24",name:"Centre-Val de Loire",population:2587031,departments:6,epcis:82,communes:1754,populationShare:0.0378,state:"OBSERVED",localPressure:"UNRESOLVED",systems:nil,truth:nil),
        .init(code:"27",name:"Bourgogne-Franche-Comté",population:2802670,departments:8,epcis:116,communes:3685,populationShare:0.0410,state:"OBSERVED",localPressure:"UNRESOLVED",systems:nil,truth:nil),
        .init(code:"28",name:"Normandie",population:3345842,departments:5,epcis:71,communes:2644,populationShare:0.0490,state:"OBSERVED",localPressure:"UNRESOLVED",systems:nil,truth:nil),
        .init(code:"32",name:"Hauts-de-France",population:5992194,departments:5,epcis:92,communes:3782,populationShare:0.0877,state:"OBSERVED",localPressure:"UNRESOLVED",systems:nil,truth:nil),
        .init(code:"44",name:"Grand Est",population:5563378,departments:10,epcis:150,communes:5115,populationShare:0.0814,state:"OBSERVED",localPressure:"UNRESOLVED",systems:nil,truth:nil),
        .init(code:"52",name:"Pays de la Loire",population:3907156,departments:5,epcis:71,communes:1228,populationShare:0.0572,state:"OBSERVED",localPressure:"UNRESOLVED",systems:nil,truth:nil),
        .init(code:"53",name:"Bretagne",population:3449370,departments:4,epcis:61,communes:1202,populationShare:0.0505,state:"OBSERVED",localPressure:"UNRESOLVED",systems:nil,truth:nil),
        .init(code:"75",name:"Nouvelle-Aquitaine",population:6150451,departments:12,epcis:156,communes:4293,populationShare:0.0900,state:"OBSERVED",localPressure:"UNRESOLVED",systems:nil,truth:nil),
        .init(code:"76",name:"Occitanie",population:6124653,departments:13,epcis:164,communes:4446,populationShare:0.0896,state:"OBSERVED",localPressure:"UNRESOLVED",systems:nil,truth:nil),
        .init(code:"84",name:"Auvergne-Rhône-Alpes",population:8205557,departments:12,epcis:172,communes:4025,populationShare:0.1201,state:"OBSERVED",localPressure:"UNRESOLVED",systems:nil,truth:nil),
        .init(code:"93",name:"Provence-Alpes-Côte d'Azur",population:5218960,departments:6,epcis:52,communes:946,populationShare:0.0764,state:"OBSERVED",localPressure:"UNRESOLVED",systems:nil,truth:nil),
        .init(code:"94",name:"Corse",population:355486,departments:2,epcis:19,communes:360,populationShare:0.0052,state:"OBSERVED",localPressure:"UNRESOLVED",systems:nil,truth:nil)
    ]
}

struct FrancePhysiology: Codable, Sendable {
    let regime: String?
    let strain: Double?
    let vigilance: Double?
    let heartRateVisual: Int?
    let respirationVisual: Double?
    let sensorHealth: Double?
    let systems: [String: Double]
    let learning: FranceLearning?

    enum CodingKeys: String, CodingKey {
        case regime, strain, vigilance, systems, learning
        case heartRateVisual = "heart_rate_visual"
        case respirationVisual = "respiration_visual"
        case sensorHealth = "sensor_health"
    }
}

struct FranceLearning: Codable, Sendable {
    let stage: String
    let samples: Int
}

struct FranceDepartment: Codable, Sendable, Identifiable {
    let code: String
    let nom: String
    var id: String { code }
}

@MainActor
final class FranceOrganismStore: ObservableObject {
    @Published private(set) var envelope: FranceOrganismEnvelope = .fallback
    @Published private(set) var isLive = false
    @Published private(set) var lastError: String?
    @Published private(set) var departments: [String: [FranceDepartment]] = [:]

    private let endpoint = URL(string:
        "https://raw.githubusercontent.com/Nicolason84/nova-trust/main/docs/data/france-organism.json"
    )!
    private let cacheKey = "OJO_FRANCE_ORGANISM_NATIVE_CACHE_V1"

    init() {
        if let cached = UserDefaults.standard.data(forKey: cacheKey),
           let decoded = try? JSONDecoder().decode(FranceOrganismEnvelope.self, from: cached) {
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
                  (200..<300).contains(http.statusCode) else {
                throw URLError(.badServerResponse)
            }
            let decoded = try JSONDecoder().decode(FranceOrganismEnvelope.self, from: data)
            envelope = decoded
            isLive = true
            lastError = nil
            UserDefaults.standard.set(data, forKey: cacheKey)
        } catch {
            isLive = false
            lastError = error.localizedDescription
        }
    }

    func loadDepartments(regionCode: String) async {
        guard departments[regionCode] == nil else { return }
        guard let url = URL(string: "https://geo.api.gouv.fr/regions/\(regionCode)/departements") else { return }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse,
                  (200..<300).contains(http.statusCode) else { return }
            departments[regionCode] = try JSONDecoder().decode([FranceDepartment].self, from: data)
        } catch {
            return
        }
    }
}

struct FranceOrganismNativeView: View {
    @StateObject private var store = FranceOrganismStore()
    @State private var selectedRegionCode: String? = "11"
    @State private var selectedSystem = "macro"

    private let systemOrder = [
        "macro","budget","energy","finance",
        "logistics","climate","health","geopolitics"
    ]

    private let metroPositions: [String: CGPoint] = [
        "53": CGPoint(x: 0.20, y: 0.34), // Bretagne
        "28": CGPoint(x: 0.36, y: 0.23), // Normandie
        "32": CGPoint(x: 0.50, y: 0.13), // Hauts-de-France
        "44": CGPoint(x: 0.70, y: 0.27), // Grand Est
        "11": CGPoint(x: 0.47, y: 0.32), // Île-de-France
        "52": CGPoint(x: 0.28, y: 0.47), // Pays de la Loire
        "24": CGPoint(x: 0.43, y: 0.48), // Centre-Val de Loire
        "27": CGPoint(x: 0.60, y: 0.44), // Bourgogne-Franche-Comté
        "75": CGPoint(x: 0.29, y: 0.67), // Nouvelle-Aquitaine
        "84": CGPoint(x: 0.55, y: 0.62), // Auvergne-Rhône-Alpes
        "76": CGPoint(x: 0.46, y: 0.80), // Occitanie
        "93": CGPoint(x: 0.70, y: 0.76), // PACA
        "94": CGPoint(x: 0.82, y: 0.84)  // Corse
    ]

    private let overseasPositions: [String: CGPoint] = [
        "01": CGPoint(x: 0.12, y: 0.90),
        "02": CGPoint(x: 0.23, y: 0.91),
        "03": CGPoint(x: 0.34, y: 0.92),
        "04": CGPoint(x: 0.73, y: 0.92),
        "06": CGPoint(x: 0.84, y: 0.92)
    ]

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                stage
                    .frame(minWidth: max(720, geometry.size.width * 0.68))
                inspector
                    .frame(width: max(330, geometry.size.width * 0.28))
            }
            .background(
                LinearGradient(
                    colors: [Color(nsColor: .windowBackgroundColor), .black.opacity(0.86)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .task { await store.run() }
        .task(id: selectedRegionCode) {
            if let selectedRegionCode {
                await store.loadDepartments(regionCode: selectedRegionCode)
            }
        }
    }

    private var stage: some View {
        VStack(alignment: .leading, spacing: 14) {
            header
            systemStrip

            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                Canvas { context, size in
                    drawFrance(context: &context, size: size, date: timeline.date)
                }
                .background(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(.black.opacity(0.30))
                        .overlay {
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .stroke(.white.opacity(0.06), lineWidth: 1)
                        }
                )
                .overlay(alignment: .bottomLeading) {
                    Text("Disposition territoriale illustrative · structure administrative réelle")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(16)
                }
                .overlay {
                    GeometryReader { proxy in
                        ForEach(store.envelope.topology.regions) { region in
                            regionHitTarget(region, size: proxy.size)
                        }
                    }
                }
            }
        }
        .padding(24)
    }

    private var header: some View {
        let counts = store.envelope.topology.counts
        let phys = store.envelope.physiology

        return HStack(alignment: .top, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text("FRANCE · JUMEAU VIVANT")
                    .font(.caption.bold())
                    .tracking(2.0)
                    .foregroundStyle(.secondary)
                Text("France, organisme distribué.")
                    .font(.system(size: 38, weight: .semibold, design: .rounded))
                Text("\(counts.regions) régions · \(counts.departments) départements · \(counts.epcis.formatted()) EPCI · \(counts.communes.formatted()) communes")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                HStack(spacing: 7) {
                    Circle()
                        .fill(store.isLive ? .green : .orange)
                        .frame(width: 8, height: 8)
                    Text(store.isLive ? "FRANCE LIVE" : "CACHE SAIN")
                        .font(.caption.bold())
                }
                Text("\(regimeLabel(phys.regime ?? "—")) · pulse \(phys.heartRateVisual ?? 0)")
                    .font(.headline)
                Text("apprentissage \(phys.learning?.samples ?? 0) états")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
        }
    }

    private var systemStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {
                ForEach(systemOrder, id: \.self) { system in
                let value = store.envelope.physiology.systems[system] ?? 0
                Button {
                    selectedSystem = system
                } label: {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(systemColor(system))
                            .frame(width: 7, height: 7)
                        Text(displaySystem(system))
                        Text("\(Int((value * 100).rounded()))%")
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                    .font(.caption2.bold())
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .background(
                        selectedSystem == system ? .white.opacity(0.10) : .clear,
                        in: Capsule()
                    )
                }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 1)
        }
    }

    private var inspector: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                franceStateCard
                selectedRegionCard
                hierarchyCard
                truthCard
            }
            .padding(20)
        }
        .background(.ultraThinMaterial)
        .overlay(alignment: .leading) {
            Rectangle().fill(.white.opacity(0.07)).frame(width: 1)
        }
    }

    private var franceStateCard: some View {
        let p = store.envelope.physiology
        return panel("ÉTAT FRANCE", symbol: "waveform.path.ecg") {
            Text(regimeLabel(p.regime ?? "—"))
                .font(.system(size: 30, weight: .bold, design: .rounded))
            metric("Tension nationale", p.strain ?? 0)
            metric("Vigilance", p.vigilance ?? 0)
            metric("Capteurs", p.sensorHealth ?? 0)
            HStack {
                Text(displaySystem(selectedSystem))
                Spacer()
                Text("\(Int(((p.systems[selectedSystem] ?? 0) * 100).rounded()))%")
                    .monospacedDigit()
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    private var selectedRegionCard: some View {
        guard let region = selectedRegion else {
            return AnyView(panel("RÉGION", symbol: "map") {
                Text("Sélectionnez un organe territorial.")
                    .foregroundStyle(.secondary)
            })
        }

        return AnyView(panel("RÉGION", symbol: "map.fill") {
            Text(region.name)
                .font(.title2.bold())
            Text(region.population.formatted() + " habitants dans le référentiel chargé")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                stat("\(region.departments)", "départements")
                stat("\(region.epcis)", "EPCI")
                stat("\(region.communes)", "communes")
            }

            Divider()

            Text("Pression territoriale spécifique")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(region.localPressure ?? "UNRESOLVED")
                .font(.caption.bold())
                .foregroundStyle(.orange)

            Text("Aucun signal national n’est imputé automatiquement à cette région.")
                .font(.caption2)
                .foregroundStyle(.secondary)
        })
    }

    private var hierarchyCard: some View {
        guard let code = selectedRegionCode,
              let region = selectedRegion else {
            return AnyView(EmptyView())
        }
        let departments = store.departments[code] ?? []

        return AnyView(panel("ÉCOSYSTÈME DISTRIBUÉ", symbol: "point.3.filled.connected.trianglepath.dotted") {
            hierarchyLine("France", "corps")
            hierarchyLine(region.name, "organe")
            if departments.isEmpty {
                Text("Chargement des départements…")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(departments) { department in
                    hierarchyLine(department.nom, "sous-organe")
                }
            }
            hierarchyLine("\(region.epcis) EPCI", "tissus fonctionnels")
            hierarchyLine("\(region.communes) communes", "cellules")
        })
    }

    private var truthCard: some View {
        panel("TRUTH / STRUCTURE RÉELLE", symbol: "checkmark.shield") {
            Label("COG 2026 / API de l’État", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Label("Exceptions territoriales conservées", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Label("Pas de classement des régions", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Label("Signal national ≠ signal régional", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)

            if let error = store.lastError {
                Text(error)
                    .font(.caption2)
                    .foregroundStyle(.orange)
                    .textSelection(.enabled)
            }
        }
    }

    private var selectedRegion: FranceRegion? {
        guard let selectedRegionCode else { return nil }
        return store.envelope.topology.regions.first { $0.code == selectedRegionCode }
    }

    @ViewBuilder
    private func regionHitTarget(_ region: FranceRegion, size: CGSize) -> some View {
        let point = position(for: region.code, size: size)
        let share = region.populationShare ?? 0.02
        let diameter = CGFloat(26 + min(42, sqrt(max(share, 0)) * 95))

        Button {
            selectedRegionCode = region.code
        } label: {
            Circle()
                .fill(.clear)
                .frame(width: diameter + 18, height: diameter + 18)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .position(point)
        .help(region.name)
    }

    private func drawFrance(
        context: inout GraphicsContext,
        size: CGSize,
        date: Date
    ) {
        let p = store.envelope.physiology
        let pulseRate = max(0.5, Double(p.heartRateVisual ?? 60) / 60.0)
        let time = date.timeIntervalSinceReferenceDate
        let pulse = 0.5 + 0.5 * sin(time * pulseRate * .pi * 2)
        let center = CGPoint(x: size.width * 0.50, y: size.height * 0.50)
        let systemValue = p.systems[selectedSystem] ?? 0

        // National core.
        let coreRadius = CGFloat(32 + 8 * pulse + 16 * systemValue)
        context.drawLayer { layer in
            layer.addFilter(.shadow(color: systemColor(selectedSystem).opacity(0.75), radius: 20))
            layer.fill(
                Path(ellipseIn: CGRect(
                    x: center.x - coreRadius,
                    y: center.y - coreRadius,
                    width: coreRadius * 2,
                    height: coreRadius * 2
                )),
                with: .color(systemColor(selectedSystem).opacity(0.55))
            )
        }

        for region in store.envelope.topology.regions {
            let point = position(for: region.code, size: size)
            let share = region.populationShare ?? 0.02
            let radius = CGFloat(10 + min(22, sqrt(max(share, 0)) * 48))
            let selected = region.code == selectedRegionCode

            // Circulation France -> region.
            var vessel = Path()
            vessel.move(to: center)
            let dx = point.x - center.x
            let dy = point.y - center.y
            let bend = CGFloat(sin(time * 0.22 + Double(abs(region.code.hashValue % 7))) * 14)
            vessel.addCurve(
                to: point,
                control1: CGPoint(x: center.x + dx * 0.35 - (dy >= 0 ? bend : -bend), y: center.y + dy * 0.35),
                control2: CGPoint(x: center.x + dx * 0.72, y: center.y + dy * 0.72 + (dx >= 0 ? bend : -bend))
            )
            context.stroke(
                vessel,
                with: .color(systemColor(selectedSystem).opacity(selected ? 0.65 : 0.16 + systemValue * 0.22)),
                lineWidth: selected ? 3.2 : 1.0 + systemValue * 2.0
            )

            // Region organ.
            context.drawLayer { layer in
                layer.addFilter(.shadow(
                    color: regionColor(region.code).opacity(selected ? 0.9 : 0.45),
                    radius: selected ? 15 : 7
                ))
                layer.fill(
                    Path(ellipseIn: CGRect(
                        x: point.x - radius,
                        y: point.y - radius,
                        width: radius * 2,
                        height: radius * 2
                    )),
                    with: .color(regionColor(region.code).opacity(selected ? 0.82 : 0.26))
                )
                layer.stroke(
                    Path(ellipseIn: CGRect(
                        x: point.x - radius,
                        y: point.y - radius,
                        width: radius * 2,
                        height: radius * 2
                    )),
                    with: .color(.white.opacity(selected ? 0.48 : 0.13)),
                    lineWidth: selected ? 2 : 1
                )
            }

            // Pulse particle.
            let progress = (time * (0.025 + systemValue * 0.06) + Double(abs(region.code.hashValue % 100)) / 100)
                .truncatingRemainder(dividingBy: 1)
            let dot = CGPoint(
                x: center.x + dx * progress,
                y: center.y + dy * progress
            )
            context.fill(
                Path(ellipseIn: CGRect(x: dot.x - 2, y: dot.y - 2, width: 4, height: 4)),
                with: .color(.white.opacity(0.55))
            )

            context.draw(
                Text(shortName(region.name))
                    .font(.caption2.bold())
                    .foregroundStyle(.white.opacity(selected ? 0.95 : 0.58)),
                at: CGPoint(x: point.x, y: point.y + radius + 12)
            )
        }

        context.draw(
            Text("FRANCE")
                .font(.caption.bold())
                .foregroundStyle(.white.opacity(0.82)),
            at: CGPoint(x: center.x, y: center.y + coreRadius + 16)
        )
    }

    private func position(for code: String, size: CGSize) -> CGPoint {
        let normalized = metroPositions[code] ?? overseasPositions[code] ?? CGPoint(x: 0.5, y: 0.5)
        return CGPoint(x: normalized.x * size.width, y: normalized.y * size.height)
    }

    private func shortName(_ name: String) -> String {
        switch name {
        case "Bourgogne-Franche-Comté": return "BFC"
        case "Auvergne-Rhône-Alpes": return "AURA"
        case "Provence-Alpes-Côte d'Azur": return "PACA"
        case "Centre-Val de Loire": return "CENTRE"
        case "Nouvelle-Aquitaine": return "N-AQUITAINE"
        case "Pays de la Loire": return "PDL"
        case "Hauts-de-France": return "HDF"
        case "Île-de-France": return "IDF"
        default: return name.uppercased()
        }
    }

    private func regionColor(_ code: String) -> Color {
        if code == selectedRegionCode {
            return systemColor(selectedSystem)
        }
        return Color.cyan.opacity(0.72)
    }

    private func systemColor(_ system: String) -> Color {
        switch system {
        case "macro": return .cyan
        case "budget": return .orange
        case "energy": return .blue
        case "finance": return .purple
        case "logistics": return .mint
        case "climate": return .teal
        case "health": return .pink
        case "geopolitics": return .indigo
        default: return .white
        }
    }

    private func displaySystem(_ system: String) -> String {
        switch system {
        case "macro": return "MACRO"
        case "budget": return "BUDGET"
        case "energy": return "ÉNERGIE"
        case "finance": return "FINANCE"
        case "logistics": return "LOGISTIQUE"
        case "climate": return "CLIMAT"
        case "health": return "SANTÉ"
        case "geopolitics": return "GÉOPOL."
        default: return system.uppercased()
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

    @ViewBuilder
    private func panel<Content: View>(
        _ title: String,
        symbol: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 11) {
            Label(title, systemImage: symbol)
                .font(.caption.bold())
                .tracking(1.1)
                .foregroundStyle(.secondary)
            content()
        }
        .padding(15)
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
                        .fill(LinearGradient(colors:[.cyan,.orange],startPoint:.leading,endPoint:.trailing))
                        .frame(width: max(2, proxy.size.width * min(max(value,0),1)))
                }
            }
            .frame(height: 6)
        }
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value).font(.headline.monospacedDigit())
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .padding(8)
        .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 10))
    }

    private func hierarchyLine(_ name: String, _ role: String) -> some View {
        HStack {
            Circle().fill(.cyan.opacity(0.55)).frame(width: 6, height: 6)
            Text(name).lineLimit(1)
            Spacer()
            Text(role).font(.caption2).foregroundStyle(.secondary)
        }
        .font(.caption)
    }
}
