import SwiftSyntax

public final class DiscoveryVisitor: SyntaxVisitor {
    public private(set) var declarationNames: [String] = []

    public init() {
        super.init(viewMode: .sourceAccurate)
    }

    public override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        declarationNames.append(node.name.text)
        return .visitChildren
    }

    public override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        declarationNames.append(node.name.text)
        return .visitChildren
    }

    public override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        declarationNames.append(node.name.text)
        return .visitChildren
    }

    public override func visit(_ node: ActorDeclSyntax) -> SyntaxVisitorContinueKind {
        declarationNames.append(node.name.text)
        return .visitChildren
    }

    public override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        declarationNames.append(node.name.text)
        return .visitChildren
    }
}
