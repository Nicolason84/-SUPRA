import XCTest
@testable import SUPRAAST

final class DependencyTests: XCTestCase {
    func testFindsTypeDependency() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("dependency.swift")
        try "struct Alpha { let beta: Beta }; struct Beta {}".write(to: url, atomically: true, encoding: .utf8)
        let parsed = try ASTParser.parse(fileAt: url)
        let visitor = DependencyVisitor()
        visitor.walk(parsed.tree)
        XCTAssertTrue(visitor.dependencies.contains(.init(source: "Alpha", target: "Beta")))
    }
}
