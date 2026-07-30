import Foundation
import SwiftUI

struct SUPRAExecutiveModel: Codable {
    let schema: String
    let generatedAt: String
    let mode: String
    let memoryFirst: Bool
    let backendRewritten: Bool
    let swiftuiRole: String
    let system: SUPRASystem
    let metrics: SUPRAMetrics
    let sections: [SUPRASection]
    let projects: [SUPRARecord]
    let capabilities: [SUPRARecord]
    let products: [SUPRARecord]
    let sources: [SUPRASource]
    let alerts: [SUPRAAlert]

    enum CodingKeys: String, CodingKey {
        case schema
        case generatedAt = "generated_at"
        case mode
        case memoryFirst = "memory_first"
        case backendRewritten = "backend_rewritten"
        case swiftuiRole = "swiftui_role"
        case system
        case metrics
        case sections
        case projects
        case capabilities
        case products
        case sources
        case alerts
    }

    static let fallback = SUPRAExecutiveModel(
        schema: "SUPRA_EXECUTIVE_UI_MODEL_V1",
        generatedAt: "",
        mode: "RECOVERY",
        memoryFirst: true,
        backendRewritten: false,
        swiftuiRole: "FACADE_ONLY",
        system: SUPRASystem(
            name: "SUPRA",
            subtitle: "Executive Operating System",
            status: "DEGRADED",
            canonicalSource: nil,
            runtimeSource: nil,
            atlasSource: nil
        ),
        metrics: SUPRAMetrics(
            projects: 0,
            capabilities: 0,
            products: 0,
            uiModules: 0,
            memoryObjects: 0,
            resources: 0,
            sourcesFound: 0,
            sourcesMissing: 0
        ),
        sections: [
            SUPRASection(
                id: "executive",
                title: "Executive",
                systemImage: "crown",
                subtitle: "Recovery mode",
                count: 0,
                status: "DEGRADED"
            )
        ],
        projects: [],
        capabilities: [],
        products: [],
        sources: [],
        alerts: []
    )

    func withAlert(
        title: String,
        detail: String
    ) -> SUPRAExecutiveModel {
        SUPRAExecutiveModel(
            schema: schema,
            generatedAt: generatedAt,
            mode: mode,
            memoryFirst: memoryFirst,
            backendRewritten: backendRewritten,
            swiftuiRole: swiftuiRole,
            system: system,
            metrics: metrics,
            sections: sections,
            projects: projects,
            capabilities: capabilities,
            products: products,
            sources: sources,
            alerts: alerts + [
                SUPRAAlert(
                    id: UUID().uuidString,
                    severity: "FAILED",
                    title: title,
                    detail: detail
                )
            ]
        )
    }
}


// SUPRA_PRODUCTS_SEMANTIC_V4_BEGIN
private struct SUPRASemanticProjectsFeed: Decodable {
    let projects: [SUPRASemanticProject]
}

private struct SUPRASemanticProject: Decodable {
    let projectID: String
    let name: String
    let classification: String
    let paths: [String]
    let capabilities: [String]
    let observationCount: Int
    enum CodingKeys: String, CodingKey {
        case projectID = "project_id"
        case name, classification, paths, capabilities
        case observationCount = "observation_count"
    }
}

private struct SUPRASemanticProductsFeed: Decodable {
    let products: [SUPRASemanticProduct]
    let capabilityOpportunities: [SUPRAFacadeCandidate]

    enum CodingKeys: String, CodingKey {
        case products
        case capabilityOpportunities = "capability_opportunities"
    }
}

private struct SUPRASemanticProduct: Decodable {
    let id: String
    let name: String
    let classification: String
    let identityAuthority: String
    let path: String?
    let score: Double
    let evidenceCount: Int
    let launchedProductProven: Bool
    let goal: String?

    enum CodingKeys: String, CodingKey {
        case id, name, classification, path, score, goal
        case identityAuthority = "identity_authority"
        case evidenceCount = "evidence_count"
        case launchedProductProven = "launched_product_proven"
    }
}

private struct SUPRAFacadeCandidate: Decodable {
    let candidateID: String
    let name: String
    let status: String
    let declaredAction: String
    let declaredRank: Int
    let matchedReconciledProjectCount: Int
    let maturityScoreDeclared: Double
    let notALaunchedProduct: Bool

    enum CodingKeys: String, CodingKey {
        case candidateID = "candidate_id"
        case name, status
        case declaredAction = "declared_action"
        case declaredRank = "declared_rank"
        case matchedReconciledProjectCount = "matched_reconciled_project_count"
        case maturityScoreDeclared = "maturity_score_declared"
        case notALaunchedProduct = "not_a_launched_product"
    }
}

private struct SUPRASemanticFacadeConnection {
    let model: SUPRAExecutiveModel
    let opportunities: [SUPRARecord]
}

private enum SUPRASemanticFeedError: LocalizedError {
    case zeroProducts
    case invalidOpportunities(Int)
    case unprovenLaunch
    var errorDescription: String? {
        switch self {
        case .zeroProducts: return "Le registre sémantique Products est vide."
        case .invalidOpportunities(let count): return "Opportunités: \(count), attendu: 20."
        case .unprovenLaunch: return "Un produit non prouvé a été marqué comme lancé."
        }
    }
}

private extension SUPRAExecutiveModel {
    func connectingSemanticProductFeeds() throws -> SUPRASemanticFacadeConnection {
        let root = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("NOVA_OS/SUPRA_STREAM_RECONCILIATION_V1/CURRENT", isDirectory: true)
        let url = root.appendingPathComponent("04_PRODUCTS_SEMANTIC_V4.json")
        let projectsURL = root.appendingPathComponent("02_PROJECTS_RECONCILED_FEED.json")
        let decoder = JSONDecoder()
        let feed = try decoder.decode(
            SUPRASemanticProductsFeed.self,
            from: Data(contentsOf: url, options: [.mappedIfSafe])
        )
        let projectsFeed = try decoder.decode(
            SUPRASemanticProjectsFeed.self,
            from: Data(contentsOf: projectsURL, options: [.mappedIfSafe])
        )
        guard projectsFeed.projects.count == 3200 else {
            throw NSError(domain: "SUPRAProjects", code: 3200, userInfo: [NSLocalizedDescriptionKey: "Flux Projects refusé: \(projectsFeed.projects.count), attendu: 3200."])
        }
        guard !feed.products.isEmpty else { throw SUPRASemanticFeedError.zeroProducts }
        guard feed.capabilityOpportunities.count == 20 else {
            throw SUPRASemanticFeedError.invalidOpportunities(feed.capabilityOpportunities.count)
        }
        guard feed.products.allSatisfy({ !$0.launchedProductProven }) else {
            throw SUPRASemanticFeedError.unprovenLaunch
        }

        let connectedProjects = projectsFeed.projects.map { item in
            SUPRARecord(
                id: item.projectID,
                name: item.name,
                status: item.classification,
                path: item.paths.first,
                score: nil,
                detail: "\(item.capabilities.count) capacités · \(item.observationCount) observations"
            )
        }
        let productRecords = feed.products.map { item in
            SUPRARecord(
                id: item.id,
                name: item.name,
                status: item.classification,
                path: item.path,
                score: item.score,
                detail: item.goal ?? "\(item.evidenceCount) preuves · autorité: \(item.identityAuthority)"
            )
        }
        let opportunityRecords = feed.capabilityOpportunities.map { item in
            SUPRARecord(
                id: item.candidateID,
                name: item.name,
                status: "MONETIZABLE_CAPABILITY",
                path: nil,
                score: item.maturityScoreDeclared,
                detail: "\(item.declaredAction) · rang déclaré \(item.declaredRank) · \(item.matchedReconciledProjectCount) projets liés"
            )
        }
        let connectedMetrics = SUPRAMetrics(
            projects: connectedProjects.count,
            capabilities: metrics.capabilities,
            products: productRecords.count,
            uiModules: metrics.uiModules,
            memoryObjects: metrics.memoryObjects,
            resources: metrics.resources,
            sourcesFound: metrics.sourcesFound,
            sourcesMissing: max(0, metrics.sourcesMissing - 1)
        )
        let connectedSections = sections.map { section in
            SUPRASection(
                id: section.id,
                title: section.title,
                systemImage: section.systemImage,
                subtitle: section.subtitle,
                count: section.id == "products" ? productRecords.count : (section.id == "projects" ? connectedProjects.count : section.count),
                status: section.status
            )
        }
        let connectedSources = sources.map { source in
            guard source.name == "PRODUCT_REGISTRY" else { return source }
            return SUPRASource(
                name: source.name,
                path: url.path,
                status: "CONNECTED",
                authority: "RECONCILED_EVIDENCE",
                priority: source.priority
            )
        }
        let connectedAlerts = alerts.filter {
            !(($0.title + " " + $0.detail).uppercased().contains("PRODUCT_REGISTRY"))
        }
        let connectedModel = SUPRAExecutiveModel(
            schema: schema,
            generatedAt: generatedAt,
            mode: mode,
            memoryFirst: memoryFirst,
            backendRewritten: backendRewritten,
            swiftuiRole: swiftuiRole,
            system: system,
            metrics: connectedMetrics,
            sections: connectedSections,
            projects: connectedProjects,
            capabilities: capabilities,
            products: productRecords,
            sources: connectedSources,
            alerts: connectedAlerts
        )
        return SUPRASemanticFacadeConnection(model: connectedModel, opportunities: opportunityRecords)
    }
}
// SUPRA_PRODUCTS_SEMANTIC_V4_END
