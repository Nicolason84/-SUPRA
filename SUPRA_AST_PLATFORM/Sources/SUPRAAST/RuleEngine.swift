import Foundation

public struct RefactoringRule: Codable, Equatable, Sendable {
    public let declaration: String
    public let destination: String
}

public struct RuleSet: Codable, Equatable, Sendable {
    public let rules: [RefactoringRule]
}

public enum RuleEngine {
    public static func loadBundledRules() throws -> RuleSet {
        guard let url = Bundle.module.url(forResource: "Rules", withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile)
        }
        return try JSONDecoder().decode(RuleSet.self, from: Data(contentsOf: url))
    }
}
