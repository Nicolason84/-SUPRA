import Foundation

public enum ASTWriter {
    public static func write(_ parsed: ParsedAST, to url: URL) throws {
        guard parsed.isValid else { throw CocoaError(.fileWriteInvalidFileName) }
        try parsed.tree.description.write(to: url, atomically: true, encoding: .utf8)
    }
}
