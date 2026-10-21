public import SwiftSyntax

extension Lint.Visibility {

    @inlinable
    public static func declared(in modifiers: DeclModifierListSyntax) -> Lint.Visibility? {
        for modifier in modifiers {
            switch modifier.name.tokenKind {
            case .keyword(.public), .keyword(.open):
                return .public

            case .keyword(.package):
                return .package

            case .keyword(.internal):
                return .internal

            case .keyword(.fileprivate):
                return .fileprivate

            case .keyword(.private):
                return .private

            default:
                continue
            }
        }
        return nil
    }

    @inlinable
    public static func effective(of node: Syntax) -> Lint.Visibility {
        guard let modifiers = modifiers(of: node) else {
            return enclosingDeclaration(of: node).map(effective(of:)) ?? .internal
        }
        if node.is(ExtensionDeclSyntax.self) {
            return declared(in: modifiers) ?? .public
        }
        let container = enclosingDeclaration(of: node)
        let own = declared(in: modifiers) ?? defaultVisibility(in: container)
        return container.map { Swift::min(own, effective(of: $0)) } ?? own
    }

    @usableFromInline
    static func enclosingDeclaration(of node: Syntax) -> Syntax? {
        var cursor = node.parent
        while let candidate = cursor {
            if modifiers(of: candidate) != nil { return candidate }
            cursor = candidate.parent
        }
        return nil
    }

    @usableFromInline
    static func defaultVisibility(in container: Syntax?) -> Lint.Visibility {
        if let decl = container?.as(ExtensionDeclSyntax.self) {
            declared(in: decl.modifiers) ?? .internal
        } else if let decl = container?.as(ProtocolDeclSyntax.self) {
            declared(in: decl.modifiers) ?? .internal
        } else {
            .internal
        }
    }

    @usableFromInline
    static func modifiers(of node: Syntax) -> DeclModifierListSyntax? {
        if let decl = node.as(StructDeclSyntax.self) { return decl.modifiers }
        if let decl = node.as(ClassDeclSyntax.self) { return decl.modifiers }
        if let decl = node.as(EnumDeclSyntax.self) { return decl.modifiers }
        if let decl = node.as(ActorDeclSyntax.self) { return decl.modifiers }
        if let decl = node.as(ExtensionDeclSyntax.self) { return decl.modifiers }
        if let decl = node.as(ProtocolDeclSyntax.self) { return decl.modifiers }
        if let decl = node.as(FunctionDeclSyntax.self) { return decl.modifiers }
        if let decl = node.as(InitializerDeclSyntax.self) { return decl.modifiers }
        if let decl = node.as(SubscriptDeclSyntax.self) { return decl.modifiers }
        if let decl = node.as(VariableDeclSyntax.self) { return decl.modifiers }
        if let decl = node.as(TypeAliasDeclSyntax.self) { return decl.modifiers }
        if let decl = node.as(AssociatedTypeDeclSyntax.self) { return decl.modifiers }
        return nil
    }
}
