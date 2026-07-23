import Foundation

public enum ASTValidation {
    public static func isValid(fileAt url: URL) -> Bool {
        (try? ASTParser.parse(fileAt: url).isValid) ?? false
    }
}
