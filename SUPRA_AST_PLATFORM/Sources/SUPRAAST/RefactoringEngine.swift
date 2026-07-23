import SwiftSyntax

public enum RefactoringEngine {
    public static func declaration(named name: String, in tree: SourceFileSyntax) -> String? {
        let visitor = DeclarationLookupVisitor(name: name)
        visitor.walk(tree)
        return visitor.result
    }
}

private final class DeclarationLookupVisitor: SyntaxVisitor {
    let name: String
    var result: String?

    init(name: String) {
        self.name = name
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        if node.name.text == name { result = node.description }
        return .visitChildren
    }
}
