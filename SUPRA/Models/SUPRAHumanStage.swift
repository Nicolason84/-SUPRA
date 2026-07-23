enum SUPRAHumanStage: String, CaseIterable, Identifiable {
    case observe = "Observer"
    case understand = "Comprendre"
    case decide = "Décider"
    case act = "Agir"
    case learn = "Apprendre"
    var id: String { rawValue }
    var symbol: String {
        switch self {
        case .observe: return "eye.fill"
        case .understand: return "brain.head.profile"
        case .decide: return "arrow.triangle.branch"
        case .act: return "bolt.fill"
        case .learn: return "sparkles"
        }
    }
}
