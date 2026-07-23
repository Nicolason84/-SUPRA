import XCTest
@testable import SUPRAAST

final class DiscoveryTests: XCTestCase {
    func testDiscoversDeclarations() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("discovery.swift")
        try "struct Alpha {} enum Beta {}".write(to: url, atomically: true, encoding: .utf8)
        let parsed = try ASTParser.parse(fileAt: url)
        let visitor = DiscoveryVisitor()
        visitor.walk(parsed.tree)
        XCTAssertEqual(visitor.declarationNames, ["Alpha", "Beta"])
    }
}
