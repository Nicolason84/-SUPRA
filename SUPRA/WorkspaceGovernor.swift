import Foundation
import Combine

enum GovernanceIssueType: String, Codable, CaseIterable, Identifiable {
    case duplicate, orphan, outdated, conflicting
    case abandonedProject = "abandoned_project"
    case obsoleteElement = "obsolete_element"
    case nonCanonical = "non_canonical"
    case versionMismatch = "version_mismatch"
    case circularDependency = "circular_dependency"
    case missingSource = "missing_source"
    case staleReference = "stale_reference"
    case oversized = "oversized"

    var id: String { rawValue }
}

enum GovernanceSeverity: String, Codable, CaseIterable, Identifiable {
    case info, warning, critical

    var id: String { rawValue }

    var rank: Int {
        switch self {
        case .critical: return 3
        case .warning: return 2
        case .info: return 1
        }
    }
}

struct GovernanceIssue: Identifiable, Codable, Equatable {
    let id: String
    let type: GovernanceIssueType
    let severity: GovernanceSeverity
    let objectId: String
    let objectName: String
    let description: String
    let recommendation: String?
    let relatedIds: [String]
    let detectedAt: String

    static func == (lhs: GovernanceIssue, rhs: GovernanceIssue) -> Bool {
        lhs.id == rhs.id
    }
}

@MainActor
final class WorkspaceGovernor: ObservableObject {
    @Published var issues: [GovernanceIssue] = []
    @Published var lastScanDate: Date?

    func scan(_ objects: [CAnnoNicoObject]) {
        issues = []

        detectDuplicates(objects)
        detectOrphans(objects)
        detectOutdated(objects)
        detectAbandonedProjects(objects)
        detectNonCanonical(objects)
        detectOversized(objects)

        lastScanDate = Date()
    }

    private func detectDuplicates(_ objects: [CAnnoNicoObject]) {
        let byName = Dictionary(grouping: objects, by: { $0.name.lowercased() })
        for (name, group) in byName where group.count > 1 {
            let paths = group.compactMap { $0.path }
            guard paths.count > 1 else { continue }
            let ids = group.map(\.id)
            issues.append(GovernanceIssue(
                id: "dup_\(name)_\(ids.count)",
                type: .duplicate,
                severity: paths.count > 3 ? .critical : .warning,
                objectId: ids[0],
                objectName: name,
                description: "\(ids.count) doublons de '\(name)'",
                recommendation: "Fusionner ou archiver les copies redondantes",
                relatedIds: Array(ids.dropFirst()),
                detectedAt: ISO8601DateFormatter().string(from: Date())
            ))
        }
    }

    private func detectOrphans(_ objects: [CAnnoNicoObject]) {
        let allIds = Set(objects.map(\.id))
        let referencedIds = Set(objects.compactMap { $0.lineage?.parentId })
        let orphans = referencedIds.subtracting(allIds)
        for orphanId in orphans {
            let orphanObjects = objects.filter { $0.lineage?.parentId == orphanId }
            for obj in orphanObjects {
                issues.append(GovernanceIssue(
                    id: "orphan_\(obj.id)",
                    type: .orphan,
                    severity: .warning,
                    objectId: obj.id,
                    objectName: obj.name,
                    description: "'\(obj.name)' référence un parent inexistant: \(orphanId)",
                    recommendation: "Supprimer la référence orpheline ou restaurer le parent",
                    relatedIds: [orphanId],
                    detectedAt: ISO8601DateFormatter().string(from: Date())
                ))
            }
        }
    }

    private func detectOutdated(_ objects: [CAnnoNicoObject]) {
        let threeMonthsAgo = Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()
        for obj in objects {
            guard let modifiedStr = obj.modified,
                  let modified = ISO8601DateFormatter().date(from: modifiedStr)
            else { continue }
            if modified < threeMonthsAgo {
                issues.append(GovernanceIssue(
                    id: "outdated_\(obj.id)",
                    type: .outdated,
                    severity: .info,
                    objectId: obj.id,
                    objectName: obj.name,
                    description: "'\(obj.name)' non modifié depuis 3+ mois",
                    recommendation: "Vérifier si l'objet est toujours pertinent",
                    relatedIds: [],
                    detectedAt: ISO8601DateFormatter().string(from: Date())
                ))
            }
        }
    }

    private func detectAbandonedProjects(_ objects: [CAnnoNicoObject]) {
        let byProject = Dictionary(grouping: objects, by: { $0.project ?? "unknown" })
        for (project, objs) in byProject {
            let allOld = objs.allSatisfy { obj in
                guard let mod = obj.modified,
                      let date = ISO8601DateFormatter().date(from: mod)
                else { return false }
                return date < Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()
            }
            if allOld && objs.count > 5 {
                issues.append(GovernanceIssue(
                    id: "abandoned_\(project)",
                    type: .abandonedProject,
                    severity: .warning,
                    objectId: objs[0].id,
                    objectName: project,
                    description: "Projet '\(project)' inactif depuis 6+ mois (\(objs.count) objets)",
                    recommendation: "Archiver le projet ou le marquer comme legacy",
                    relatedIds: objs.map(\.id),
                    detectedAt: ISO8601DateFormatter().string(from: Date())
                ))
            }
        }
    }

    private func detectNonCanonical(_ objects: [CAnnoNicoObject]) {
        let nonCanonical = objects.filter { !$0.id.contains(":") }
        for obj in nonCanonical {
            issues.append(GovernanceIssue(
                id: "noncanonical_\(obj.id)",
                type: .nonCanonical,
                severity: .info,
                objectId: obj.id,
                objectName: obj.name,
                description: "'\(obj.name)' n'utilise pas l'identifiant canonique",
                recommendation: "Appliquer le format canonique source:type:id",
                relatedIds: [],
                detectedAt: ISO8601DateFormatter().string(from: Date())
            ))
        }
    }

    private func detectOversized(_ objects: [CAnnoNicoObject]) {
        for obj in objects {
            if let sizeStr = obj.metadata["size"],
               let size = Int(sizeStr),
               size > 10_000_000 {
                issues.append(GovernanceIssue(
                    id: "oversized_\(obj.id)",
                    type: .oversized,
                    severity: .info,
                    objectId: obj.id,
                    objectName: obj.name,
                    description: "'\(obj.name)' dépasse 10MB (\(size) bytes)",
                    recommendation: "Vérifier si un allègement est possible",
                    relatedIds: [],
                    detectedAt: ISO8601DateFormatter().string(from: Date())
                ))
            }
        }
    }

    func issuesBySeverity() -> [GovernanceSeverity: [GovernanceIssue]] {
        Dictionary(grouping: issues, by: { $0.severity })
    }

    func issuesByType() -> [GovernanceIssueType: [GovernanceIssue]] {
        Dictionary(grouping: issues, by: { $0.type })
    }

    func clear() {
        issues = []
        lastScanDate = nil
    }
}
