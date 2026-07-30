import Foundation
import Combine

@MainActor
final class KnowledgeStatistics: ObservableObject {
    @Published var stats: KnowledgeGraphStatistics?
    @Published var isComputing = false

    func compute(from graph: KnowledgeGraph) -> KnowledgeGraphStatistics {
        isComputing = true

        let objects = graph.objects
        let relations = graph.relations

        var sourceBreakdown: [String: Int] = [:]
        for obj in objects {
            sourceBreakdown[obj.source, default: 0] += 1
        }

        var typeBreakdown: [String: Int] = [:]
        for obj in objects {
            typeBreakdown[obj.type.rawValue, default: 0] += 1
        }

        var authorityDist: [String: Int] = ["high (≥0.8)": 0, "medium (0.5–0.8)": 0, "low (<0.5)": 0]
        for obj in objects {
            if obj.authority >= 0.8 { authorityDist["high (≥0.8)"]! += 1 }
            else if obj.authority >= 0.5 { authorityDist["medium (0.5–0.8)"]! += 1 }
            else { authorityDist["low (<0.5)"]! += 1 }
        }

        var topProjects: [String: Int] = [:]
        for obj in objects {
            if let proj = obj.project {
                topProjects[proj, default: 0] += 1
            }
        }

        let activeCount = objects.filter { $0.status == "active" }.count
        let totalCount = objects.count
        let healthScore = totalCount > 0 ? Double(activeCount) / Double(totalCount) * 10.0 : 0

        stats = KnowledgeGraphStatistics(
            totalObjects: objects.count,
            totalRelations: relations.count,
            sourceBreakdown: sourceBreakdown,
            typeBreakdown: typeBreakdown,
            authorityDistribution: authorityDist,
            topProjects: topProjects.sorted(by: { $0.value > $1.value }).prefix(10).reduce(into: [:]) { $0[$1.key] = $1.value },
            healthScore: healthScore
        )

        isComputing = false
        return stats!
    }
}
