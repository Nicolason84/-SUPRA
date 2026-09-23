import SwiftUI
import AppKit
import Foundation
import CAnnoNicoContracts

private enum SUPRAHostProjectionPaths {
    static let home = URL(
        fileURLWithPath: "/Users/nicolasalonso",
        isDirectory: true
    )
}

struct SUPRAPatrimonyEntity: Identifiable {
    let id: String
    let name: String
    let status: String
    let category: String
    let sourcePath: String?
}

struct SUPRAPatrimonySnapshot {
    let observedAt: Date
    let total: Int
    let theories: Int
    let intellectualAssets: Int
    let softwareAssets: Int
    let businessAssets: Int
    let creativeAssets: Int
    let legalIPAssets: Int
    let authenticated: Int
    let partial: Int
    let unknown: Int
    let capabilities: Int
    let memoryObjects: Int
    let labsCanonStatus: String
    let labsRule: String
    let labsNextPriority: String
    let products: [String: Int]
    let foundationalEntities: [SUPRAPatrimonyEntity]
}

enum SUPRAPatrimonyLoader {
    static func load() -> SUPRAPatrimonySnapshot {
        let home = SUPRAHostProjectionPaths.home
        let patrimony = home.appendingPathComponent(
            "NOVA_DEV/NOVA_ERA_PATRIMONY_QUERY_INDEX_V1",
            isDirectory: true
        )
        let query = dictionary(
            at: patrimony.appendingPathComponent("QUERY_INDEX.json")
        ) ?? [:]
        let entityCounts = query["entity_counts"] as? [String: Any] ?? [:]
        let statusCounts = query["status_counts"] as? [String: Any] ?? [:]

        let capabilityRegistry = dictionary(
            at: home.appendingPathComponent(
                "NOVA_OS/SUPRA_FACTORY_V1/REGISTRIES/CAPABILITY_REGISTRY.json"
            )
        )
        let capabilities = capabilityRegistry?["capabilities"] as? [Any] ?? []

        let memoryIndex = dictionary(
            at: home.appendingPathComponent(
                "NOVA_LABS/04_MEMORY_CORE/STATE/memory_index.json"
            )
        ) ?? [:]

        let labsCanon = dictionary(
            at: home.appendingPathComponent("NOVA_LABS/00_CANON/CANON_BOOT.json")
        ) ?? [:]
        let productSummary = dictionary(
            at: home.appendingPathComponent(
                "NOVA_LABS/10_ENVIRONMENT/product_registry/PRODUCT_REGISTRY_SUMMARY.json"
            )
        ) ?? [:]
        let rawProducts = productSummary["products"] as? [String: Any] ?? [:]
        var products: [String: Int] = [:]
        for (key, value) in rawProducts {
            products[key] = int(value)
        }

        let entities = entityArray(
            at: patrimony.appendingPathComponent("ENTITY_INDEX.json")
        )
        let foundationCategories = Set(["ARCHITECTURE", "KNOWLEDGE", "HISTORY"])
        let foundational = entities
            .filter { foundationCategories.contains($0.category) }
            .prefix(12)
            .map { $0 }

        return SUPRAPatrimonySnapshot(
            observedAt: Date(),
            total: int(entityCounts["total"]),
            theories: int(entityCounts["theories"]),
            intellectualAssets: int(entityCounts["intellectual_assets"]),
            softwareAssets: int(entityCounts["software_assets"]),
            businessAssets: int(entityCounts["business_assets"]),
            creativeAssets: int(entityCounts["creative_assets"]),
            legalIPAssets: int(entityCounts["legal_ip_assets"]),
            authenticated: int(statusCounts["AUTHENTICATED"]),
            partial: int(statusCounts["PARTIAL"]),
            unknown: int(statusCounts["UNKNOWN"]),
            capabilities: capabilities.count,
            memoryObjects: memoryIndex.count,
            labsCanonStatus: labsCanon["status"] as? String ?? "UNKNOWN",
            labsRule: labsCanon["rule"] as? String ?? "UNKNOWN",
            labsNextPriority: labsCanon["next_priority"] as? String ?? "UNKNOWN",
            products: products,
            foundationalEntities: foundational
        )
    }

    private static func dictionary(at url: URL) -> [String: Any]? {
        guard let data = try? Data(contentsOf: url),
              let object = try? JSONSerialization.jsonObject(with: data),
              let dictionary = object as? [String: Any]
        else { return nil }
        return dictionary
    }

    private static func entityArray(at url: URL) -> [SUPRAPatrimonyEntity] {
        guard let data = try? Data(contentsOf: url),
              let object = try? JSONSerialization.jsonObject(with: data),
              let rows = object as? [[String: Any]]
        else { return [] }

        return rows.compactMap { row in
            guard let id = row["entity_id"] as? String,
                  let name = row["canonical_name"] as? String
            else { return nil }

            return SUPRAPatrimonyEntity(
                id: id,
                name: name,
                status: row["evidence_status"] as? String ?? "UNKNOWN",
                category: row["category"] as? String ?? "UNKNOWN",
                sourcePath: (row["source_paths"] as? [String])?.first
            )
        }
    }
    private static func int(_ value: Any?) -> Int {
        if let value = value as? Int { return value }
        if let value = value as? NSNumber { return value.intValue }
        if let value = value as? String { return Int(value) ?? 0 }
        return 0
    }
}

private struct SUPRAProjectionMetric: View {
    let value: String
    let label: String
    let symbol: String

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2.bold().monospacedDigit())
                .lineLimit(2)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 110, alignment: .topLeading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
    }
}

private struct SUPRAProjectionHero: View {
    let eyebrow: String
    let title: String
    let subtitle: String
    let symbol: String
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            Image(systemName: symbol)
                .font(.system(size: 38, weight: .semibold))
                .frame(width: 78, height: 78)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22))
            VStack(alignment: .leading, spacing: 7) {
                Text(eyebrow)
                    .font(.caption.weight(.black))
                    .tracking(1.4)
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                Text(subtitle)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(22)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 26))
    }
}

struct SUPRAMemoryProjectionView: View {
    @State private var snapshot = SUPRAPatrimonyLoader.load()
    private let integration = SUPRACAnnoNicoIntegration.snapshot()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                SUPRAProjectionHero(
                    eyebrow: "EXECUTIVE MEMORY",
                    title: "La mémoire est le kernel.",
                    subtitle: "Puchero fusionne et relie. CAnnoNico gouverne la vérité. Les Twins projettent. Les missions retournent leurs preuves.",
                    symbol: "brain.head.profile"
                )
                HStack(spacing: 12) {
                    SUPRAProjectionMetric(
                        value: snapshot.memoryObjects.formatted(),
                        label: "LABS memory objects",
                        symbol: "memorychip.fill"
                    )
                    SUPRAProjectionMetric(
                        value: snapshot.total.formatted(),
                        label: "Patrimony entities",
                        symbol: "books.vertical.fill"
                    )
                    SUPRAProjectionMetric(
                        value: integration.references.filter { $0.state == .recovered }.count.formatted(),
                        label: "Recovered CAnnoNico references",
                        symbol: "link.circle.fill"
                    )
                    SUPRAProjectionMetric(
                        value: snapshot.authenticated.formatted(),
                        label: "Authenticated evidence",
                        symbol: "checkmark.seal.fill"
                    )
                }

                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 260), spacing: 14)],
                    spacing: 14
                ) {
                    ForEach(integration.references, id: \.id) { reference in
                        VStack(alignment: .leading, spacing: 9) {
                            HStack {
                                Text(reference.id)
                                    .font(.headline)
                                Spacer()
                                Text(reference.state.rawValue.uppercased())
                                    .font(.caption2.weight(.heavy))
                                    .foregroundStyle(
                                        reference.state == .recovered ? .green : .orange
                                    )
                            }
                            Text(reference.role)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                            if let path = reference.path {
                                Text(path)
                                    .font(.caption.monospaced())
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                            Text(reference.outputs.joined(separator: " · "))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, minHeight: 145, alignment: .topLeading)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
                    }
                }

                circulationCard
            }
            .padding(26)
            .frame(maxWidth: 1500, alignment: .leading)
        }
        .task { snapshot = SUPRAPatrimonyLoader.load() }
    }

    private var circulationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Memory circulation")
                .font(.title3.bold())
            Text("CAPTURE → NORMALIZE → VALIDATE → CANONICALIZE → MERGE → PERSIST → RECALL → DECIDE → RESULT → LEARN → MEMORY RETURN")
                .font(.system(.body, design: .monospaced).weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
            Text("No private truth store. No silent overwrite. Contradictions and supersession remain explicit.")
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}
struct SUPRALibraryProjectionView: View {
    @State private var snapshot = SUPRAPatrimonyLoader.load()

    private var productTotal: Int {
        snapshot.products.values.reduce(0, +)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                SUPRAProjectionHero(
                    eyebrow: "LIBRARY / PATRIMONY",
                    title: "Un musée vivant qui sait d’où vient chaque chose.",
                    subtitle: "Theory → method → technique → module → engine → capability → product → commercial proof → learning → next version.",
                    symbol: "building.columns.fill"
                )

                HStack(spacing: 12) {
                    SUPRAProjectionMetric(
                        value: snapshot.total.formatted(),
                        label: "Indexed entities",
                        symbol: "square.grid.3x3.fill"
                    )
                    SUPRAProjectionMetric(
                        value: snapshot.theories.formatted(),
                        label: "Theory / foundational assets",
                        symbol: "text.book.closed.fill"
                    )
                    SUPRAProjectionMetric(
                        value: snapshot.capabilities.formatted(),
                        label: "Capabilities",
                        symbol: "bolt.fill"
                    )
                    SUPRAProjectionMetric(
                        value: productTotal.formatted(),
                        label: "LABS product signals",
                        symbol: "shippingbox.fill"
                    )
                }

                collectionGrid
                foundationSection
                evidenceSection
                Button {
                    NSWorkspace.shared.open(
                        SUPRAHostProjectionPaths.home
                            .appendingPathComponent("NOVA_DEV/NOVA_ERA_PATRIMONY_QUERY_INDEX_V1")
                    )
                } label: {
                    Label("Open canonical Patrimony Query Index", systemImage: "folder.fill")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(26)
            .frame(maxWidth: 1500, alignment: .leading)
        }
        .task { snapshot = SUPRAPatrimonyLoader.load() }
    }

    private var collectionGrid: some View {
        let items: [(String, Int, String)] = [
            ("THEORY · CONSTITUTIONS · LAWS · METHODS", snapshot.theories, "text.book.closed.fill"),
            ("INTELLECTUAL ASSETS", snapshot.intellectualAssets, "brain.fill"),
            ("SOFTWARE · APPS", snapshot.softwareAssets, "app.fill"),
            ("BUSINESS · PRODUCTS", snapshot.businessAssets, "briefcase.fill"),
            ("CREATIVE · MEDIA", snapshot.creativeAssets, "play.rectangle.fill"),
            ("LEGAL · IP", snapshot.legalIPAssets, "seal.fill"),
            ("MODULES · ENGINES · CAPABILITIES", snapshot.capabilities, "gearshape.2.fill"),
            ("EVIDENCE · PROVENANCE", snapshot.authenticated, "checkmark.seal.fill")
        ]
        return LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 275), spacing: 14)],
            spacing: 14
        ) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(spacing: 12) {
                    Image(systemName: item.2)
                        .foregroundStyle(.secondary)
                    Text(item.0)
                        .font(.callout.weight(.semibold))
                    Spacer()
                    Text(item.1.formatted())
                        .font(.headline.monospacedDigit())
                }
                .padding(16)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 17))
            }
        }
    }

    private var foundationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Fundamental theory / constitutional lineage", systemImage: "scroll.fill")
                    .font(.title3.bold())
                Spacer()
                Text("SOURCE-LINKED")
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(.green)
            }

            ForEach(snapshot.foundationalEntities) { entity in
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entity.name)
                            .font(.callout.weight(.semibold))
                        Text("\(entity.category) · \(entity.status)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if let source = entity.sourcePath {
                        Button {
                            NSWorkspace.shared.open(URL(fileURLWithPath: source))
                        } label: {
                            Image(systemName: "arrow.up.right.square")
                        }
                        .buttonStyle(.plain)
                        .help(source)
                    }
                }
                Divider()
            }

            Text("This section is a projection of recovered sources. It does not promote an old theory merely because a file exists.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    private var evidenceSection: some View {
        HStack(spacing: 12) {
            SUPRAProjectionMetric(
                value: snapshot.authenticated.formatted(),
                label: "AUTHENTICATED",
                symbol: "checkmark.circle.fill"
            )
            SUPRAProjectionMetric(
                value: snapshot.partial.formatted(),
                label: "PARTIAL",
                symbol: "circle.lefthalf.filled"
            )
            SUPRAProjectionMetric(
                value: snapshot.unknown.formatted(),
                label: "UNKNOWN",
                symbol: "questionmark.circle.fill"
            )
        }
    }
}

struct SUPRALabsProjectionView: View {
    @State private var snapshot = SUPRAPatrimonyLoader.load()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                SUPRAProjectionHero(
                    eyebrow: "NOVA LABS",
                    title: "Forge, distille, prouve, transmet.",
                    subtitle: "LABS expérimente et valide. Les produits restent des enfants séparés. Le canon gouverne.",
                    symbol: "flask.fill"
                )
                HStack(spacing: 12) {
                    SUPRAProjectionMetric(
                        value: snapshot.labsCanonStatus,
                        label: "CANON_BOOT",
                        symbol: "checkmark.shield.fill"
                    )
                    SUPRAProjectionMetric(
                        value: snapshot.memoryObjects.formatted(),
                        label: "Memory Core objects",
                        symbol: "memorychip.fill"
                    )
                    SUPRAProjectionMetric(
                        value: snapshot.capabilities.formatted(),
                        label: "Reusable capabilities",
                        symbol: "puzzlepiece.extension.fill"
                    )
                    SUPRAProjectionMetric(
                        value: snapshot.labsNextPriority,
                        label: "Next canon priority",
                        symbol: "arrow.forward.circle.fill"
                    )
                }

                VStack(alignment: .leading, spacing: 10) {
                    Label("Canonical LABS law", systemImage: "scroll.fill")
                        .font(.title3.bold())
                    Text(snapshot.labsRule)
                        .font(.headline)
                    Text("Develop once · validate once · reuse everywhere. Product final → technique minimale nécessaire, jamais l’inverse.")
                        .foregroundStyle(.secondary)
                }
                .padding(20)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))

                productSection

                HStack(spacing: 12) {
                    Button {
                        NSWorkspace.shared.open(
                            SUPRAHostProjectionPaths.home
                                .appendingPathComponent("NOVA_LABS")
                        )
                    } label: {
                        Label("Open NOVA LABS", systemImage: "folder.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    Button {
                        NSWorkspace.shared.open(
                            SUPRAHostProjectionPaths.home
                                .appendingPathComponent("NOVA_LABS/00_CANON")
                        )
                    } label: {
                        Label("Open Canon", systemImage: "checkmark.seal.fill")
                    }
                    .buttonStyle(.bordered)

                    Button {
                        NSWorkspace.shared.open(
                            SUPRAHostProjectionPaths.home
                                .appendingPathComponent("NOVA_LABS/10_ENVIRONMENT/product_registry")
                        )
                    } label: {
                        Label("Open Product Registry", systemImage: "shippingbox.fill")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(26)
            .frame(maxWidth: 1500, alignment: .leading)
        }
        .task { snapshot = SUPRAPatrimonyLoader.load() }
    }

    private var productSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Child products")
                    .font(.title3.bold())
                Spacer()
                Text("DO NOT MERGE INTO LABS")
                    .font(.caption2.weight(.heavy))
                    .foregroundStyle(.orange)
            }

            ForEach(snapshot.products.keys.sorted(), id: \.self) { key in
                HStack {
                    Text(key.replacingOccurrences(of: "_", with: " "))
                        .font(.callout.weight(.semibold))
                    Spacer()
                    Text((snapshot.products[key] ?? 0).formatted())
                        .font(.headline.monospacedDigit())
                }
                Divider()
            }

            Text("A product may consume LABS capabilities. It does not become LABS, and LABS does not become the product.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
}