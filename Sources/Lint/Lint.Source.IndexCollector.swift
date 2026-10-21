public import SwiftSyntax

extension Lint.Source {

    internal final class IndexCollector: SyntaxVisitor {

        var index = Lint.Source.Index()

        private func qualifiedName(_ name: Swift::String, _ node: Syntax) -> Swift::String {
            var components = [name]
            var current = node.parent
            while let candidate = current {
                if let decl = candidate.as(StructDeclSyntax.self) {
                    components.insert(decl.name.text, at: 0)
                } else if let decl = candidate.as(EnumDeclSyntax.self) {
                    components.insert(decl.name.text, at: 0)
                } else if let decl = candidate.as(ClassDeclSyntax.self) {
                    components.insert(decl.name.text, at: 0)
                } else if let decl = candidate.as(ActorDeclSyntax.self) {
                    components.insert(decl.name.text, at: 0)
                } else if let decl = candidate.as(ExtensionDeclSyntax.self) {
                    components.insert(Lint.Source.Index.spelling(of: decl.extendedType), at: 0)
                    break
                }
                current = candidate.parent
            }
            return components.joined(separator: ".")
        }

        private func record(
            _ node: Syntax,
            name: TokenSyntax,
            generics: GenericParameterClauseSyntax?,
            inheritance: InheritanceClauseSyntax?
        ) {
            let qualified = qualifiedName(name.text, node)
            let hasValueGeneric =
                generics?.parameters.contains { $0.specifier?.tokenKind == .keyword(.let) } ?? false
            if hasValueGeneric {
                index.valueGenericTypes.insert(qualified)
                index.valueGenericTypes.insert(name.text)
            }
            recordConformances(of: qualified, inheritance)
            recordConformances(of: name.text, inheritance)
        }

        private func recordConformances(of type: Swift::String, _ clause: InheritanceClauseSyntax?) {
            guard let clause else { return }
            let leaves = clause.inheritedTypes.map {
                Lint.Source.Index.leaf(of: Lint.Source.Index.spelling(of: $0.type))
            }
            index.conformances[type, default: []].formUnion(leaves)
        }

        override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
            record(Syntax(node), name: node.name, generics: node.genericParameterClause, inheritance: node.inheritanceClause)
            return .visitChildren
        }

        override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
            record(Syntax(node), name: node.name, generics: node.genericParameterClause, inheritance: node.inheritanceClause)
            return .visitChildren
        }

        override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
            record(Syntax(node), name: node.name, generics: node.genericParameterClause, inheritance: node.inheritanceClause)
            return .visitChildren
        }

        override func visit(_ node: ActorDeclSyntax) -> SyntaxVisitorContinueKind {
            record(Syntax(node), name: node.name, generics: node.genericParameterClause, inheritance: node.inheritanceClause)
            return .visitChildren
        }

        override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
            let type = Lint.Source.Index.spelling(of: node.extendedType)
            recordConformances(of: type, node.inheritanceClause)
            recordConformances(of: Lint.Source.Index.leaf(of: type), node.inheritanceClause)
            return .visitChildren
        }

        override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
            let names = node.memberBlock.members.compactMap {
                $0.decl.as(AssociatedTypeDeclSyntax.self)?.name.text
            }
            index.associatedTypes[node.name.text, default: []].formUnion(names)
            let members = node.memberBlock.members.flatMap { member -> [Swift::String] in
                if let variable = member.decl.as(VariableDeclSyntax.self) {
                    return variable.bindings.compactMap { $0.pattern.as(IdentifierPatternSyntax.self)?.identifier.text }
                }
                if let function = member.decl.as(FunctionDeclSyntax.self) { return [function.name.text] }
                if let subscriptDecl = member.decl.as(SubscriptDeclSyntax.self) { return [subscriptDecl.subscriptKeyword.text] }
                return []
            }
            index.requirements[node.name.text, default: []].formUnion(members)
            recordConformances(of: node.name.text, node.inheritanceClause)
            return .visitChildren
        }
    }
}
