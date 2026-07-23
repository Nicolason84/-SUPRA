import XCTest
@testable import SUPRAAST

final class ParserTests: XCTestCase {
    func testContentViewParses() throws {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let contentView = root.appendingPathComponent("SUPRA/ContentView.swift")
        let parsed = try ASTParser.parse(fileAt: contentView)
        XCTAssertTrue(parsed.isValid, "ContentView.swift must parse as a valid Swift AST")
        XCTAssertFalse(parsed.tree.statements.isEmpty)
    }
}
