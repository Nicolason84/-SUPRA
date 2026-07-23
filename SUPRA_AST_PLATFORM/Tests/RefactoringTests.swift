import XCTest
@testable import SUPRAAST

final class RefactoringTests: XCTestCase {
    func testFindsDeclarationForRefactoring() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("refactoring.swift")
        try "/// Documentation\nstruct MoveMe {}".write(to: url, atomically: true, encoding: .utf8)
        let parsed = try ASTParser.parse(fileAt: url)
        let declaration = RefactoringEngine.declaration(named: "MoveMe", in: parsed.tree)
        XCTAssertTrue(declaration?.contains("MoveMe") == true)
        XCTAssertTrue(declaration?.contains("Documentation") == true)
    }
}
