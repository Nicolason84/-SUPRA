enum SUPRAStructureMode: String, CaseIterable, Identifiable {
    case hydrogen = "Hydrogen"
    case atomium = "Atomium"
    case arbo = "Arbo"
    case orbital = "Orbital"
    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .hydrogen: return "circle.hexagongrid.fill"
        case .atomium: return "atom"
        case .arbo: return "point.3.connected.trianglepath.dotted"
        case .orbital: return "circle.dotted.and.circle"
        }
    }
    var subtitle: String {
        switch self {
        case .hydrogen: return "Une intention · une prochaine action"
        case .atomium: return "Acteurs, modules et relations"
        case .arbo: return "Hiérarchie, lineage et dépendances"
        case .orbital: return "Missions parallèles et convergence"
        }
    }
}
