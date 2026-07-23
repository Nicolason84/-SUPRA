import SwiftSyntax

public final class DependencyVisitor: SyntaxVisitor {
    public private(set) var dependencies: [DependencyGraph.Edge] = []
    private var scope: [String] = []

    public init() {
        super.init(viewMode: .sourceAccurate)
    }

    public override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        scope.append(node.name.text)
        return .visitChildren
    }

    public override func visitPost(_ node: StructDeclSyntax) { _ = scope.popLast() }

    public override func visit(_ node: IdentifierTypeSyntax) -> SyntaxVisitorContinueKind {
        if let source = scope.last, source != node.name.text {
            dependencies.append(.init(source: source, target: node.name.text))
        }
        return .visitChildren
    }
}
