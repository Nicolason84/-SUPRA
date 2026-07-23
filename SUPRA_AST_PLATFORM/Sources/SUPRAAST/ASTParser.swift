import Foundation
import SwiftParser
import SwiftSyntax

public struct ParsedAST {
    public let sourceURL: URL
    public let tree: SourceFileSyntax

    public var isValid: Bool { !tree.hasError }
}

public enum ASTParser {
    public static func parse(fileAt url: URL) throws -> ParsedAST {
        let source = try String(contentsOf: url, encoding: .utf8)
        let tree = Parser.parse(source: source)
        return ParsedAST(sourceURL: url, tree: tree)
    }
}
