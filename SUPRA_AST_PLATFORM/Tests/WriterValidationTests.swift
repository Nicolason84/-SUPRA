import XCTest
@testable import SUPRAAST

final class WriterValidationTests: XCTestCase {
    func testWritesAndValidatesAST() throws {
        let input = FileManager.default.temporaryDirectory.appendingPathComponent("writer-input.swift")
        let output = FileManager.default.temporaryDirectory.appendingPathComponent("writer-output.swift")
        try "struct Written {}".write(to: input, atomically: true, encoding: .utf8)
        let parsed = try ASTParser.parse(fileAt: input)
        try ASTWriter.write(parsed, to: output)
        XCTAssertTrue(ASTValidation.isValid(fileAt: output))
    }
}
