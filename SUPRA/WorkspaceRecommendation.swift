import Foundation
import Combine

enum RecommendationAction: String, Codable, CaseIterable, Identifiable {
    case merge, archive, deduplicate, reorganize, canonicalize
    case cleanup, purge, freeze, split, move, rename, delete, review

    var id: String { rawValue }
}

enum RecommendationPriority: String, Codable, CaseIterable, Identifiable {
    case critical, high, medium, low

    var id: String { rawValue }

    var rank: Int {
        switch self {
        case .critical: return 4
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        }
    }
}

struct WorkspaceRecommendation: Identifiable, Codable, Equatable {
    let id: String
    let action: RecommendationAction
    let priority: RecommendationPriority
    let title: String
    let description: String
    let rationale: String
    let impact: String
    let risk: String
    let objects: [String]
    let requiresApproval: Bool
    let createdAt: String

    static func == (lhs: WorkspaceRecommendation, rhs: WorkspaceRecommendation) -> Bool {
        lhs.id == rhs.id
    }
}

@MainActor
final class WorkspaceRecommendationEngine: ObservableObject {
    @Published var recommendations: [WorkspaceRecommendation] = []
    @Published var isComputing = false

    func generate(from issues: [GovernanceIssue], objects: [CAnnoNicoObject]) {
        isComputing = true
        recommendations = []

        let byType = Dictionary(grouping: issues, by: { $0.type })

        for (type, group) in byType {
            switch type {
            case .duplicate:
                recommendations.append(duplicateRecommendation(group))
            case .orphan:
                recommendations.append(orphanRecommendation(group))
            case .abandonedProject:
                recommendations.append(abandonedRecommendation(group))
            case .outdated:
                recommendations.append(outdatedRecommendation(group))
            case .nonCanonical:
                recommendations.append(canonicalizeRecommendation(group))
            case .oversized:
                recommendations.append(oversizedRecommendation(group))
            default:
                break
            }
        }

        isComputing = false
    }

    private func duplicateRecommendation(_ issues: [GovernanceIssue]) -> WorkspaceRecommendation {
        WorkspaceRecommendation(
            id: "rec_merge_\(issues.count)",
            action: .merge,
            priority: issues.contains(where: { $0.severity == .critical }) ? .critical : .high,
            title: "Fusionner \(issues.count) groupes de doublons",
            description: "\(issues.count) groupes d'objets dupliqués détectés",
            rationale: "Les doublons fragmentent la connaissance et augmentent la charge cognitive",
            impact: "Réduction du nombre d'objets, unification des références",
            risk: "Perte potentielle de variations intentionnelles",
            objects: issues.flatMap { $0.relatedIds + [$0.objectId] },
            requiresApproval: true,
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
    }

    private func orphanRecommendation(_ issues: [GovernanceIssue]) -> WorkspaceRecommendation {
        WorkspaceRecommendation(
            id: "rec_orphan_\(issues.count)",
            action: .cleanup,
            priority: .medium,
            title: "Résoudre \(issues.count) références orphelines",
            description: "\(issues.count) objets référencent des parents inexistants",
            rationale: "Les orphelins créent des trous dans le graphe de connaissance",
            impact: "Graphe de connaissance cohérent",
            risk: "Faible — les objets restent accessibles individuellement",
            objects: issues.map(\.objectId),
            requiresApproval: false,
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
    }

    private func abandonedRecommendation(_ issues: [GovernanceIssue]) -> WorkspaceRecommendation {
        WorkspaceRecommendation(
            id: "rec_archive_\(issues.count)",
            action: .archive,
            priority: .low,
            title: "Archiver \(issues.count) projets inactifs",
            description: "\(issues.count) projets sans activité depuis 6+ mois",
            rationale: "Les projets inactifs consomment de l'espace sans valeur ajoutée",
            impact: "Espace libéré, workspace simplifié",
            risk: "Les projets peuvent être réactivés — l'archive est réversible",
            objects: issues.map(\.objectId),
            requiresApproval: true,
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
    }

    private func outdatedRecommendation(_ issues: [GovernanceIssue]) -> WorkspaceRecommendation {
        WorkspaceRecommendation(
            id: "rec_outdated_\(issues.count)",
            action: .review,
            priority: .low,
            title: "Réviser \(issues.count) éléments obsolètes",
            description: "\(issues.count) objets non modifiés depuis 3+ mois",
            rationale: "Certains éléments peuvent ne plus être pertinents",
            impact: "Meilleure pertinence du contexte",
            risk: "Minime — simple révision",
            objects: issues.map(\.objectId),
            requiresApproval: false,
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
    }

    private func canonicalizeRecommendation(_ issues: [GovernanceIssue]) -> WorkspaceRecommendation {
        WorkspaceRecommendation(
            id: "rec_canon_\(issues.count)",
            action: .canonicalize,
            priority: .medium,
            title: "Canoniser \(issues.count) objets",
            description: "\(issues.count) objets sans identifiant canonique",
            rationale: "Le format canonique est requis pour l'interopérabilité",
            impact: "Objets interopérables avec le Knowledge Graph",
            risk: "Faible — les identifiants changent, redirection nécessaire",
            objects: issues.map(\.objectId),
            requiresApproval: true,
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
    }

    private func oversizedRecommendation(_ issues: [GovernanceIssue]) -> WorkspaceRecommendation {
        WorkspaceRecommendation(
            id: "rec_oversized_\(issues.count)",
            action: .cleanup,
            priority: .low,
            title: "Vérifier \(issues.count) fichiers volumineux",
            description: "\(issues.count) fichiers dépassent 10 MB",
            rationale: "Les fichiers volumineux ralentissent l'indexation",
            impact: "Performance d'indexation améliorée",
            risk: "Faible — simple vérification",
            objects: issues.map(\.objectId),
            requiresApproval: false,
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
    }

    func clear() {
        recommendations = []
    }
}

extension RecommendationAction {
    var label: String {
        switch self {
        case .merge: return "Fusionner"
        case .archive: return "Archiver"
        case .deduplicate: return "Dédupliquer"
        case .reorganize: return "Réorganiser"
        case .canonicalize: return "Canoniser"
        case .cleanup: return "Nettoyer"
        case .purge: return "Purger"
        case .freeze: return "Geler"
        case .split: return "Diviser"
        case .move: return "Déplacer"
        case .rename: return "Renommer"
        case .delete: return "Supprimer"
        case .review: return "Réviser"
        }
    }
}
