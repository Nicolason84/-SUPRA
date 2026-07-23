import XCTest
@testable import SUPRAAST

final class DeclarationGraphTests: XCTestCase {
    func testGraphStoresNodesAndHierarchy() throws {
        let child = DeclarationGraph.Node(name: "Child", kind: "struct", parent: "Root")
        let graph = DeclarationGraph(
            source: "ContentView.swift",
            nodes: [DeclarationGraph.Node(name: "Root", kind: "struct", children: ["Child"]), child]
        )
        XCTAssertEqual(graph.nodes.first?.children, ["Child"])
        XCTAssertEqual(graph.nodes.last?.parent, "Root")
    }
}
