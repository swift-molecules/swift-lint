public import SwiftSyntax

extension Lint.Source {

    internal final class ImportCollector: SyntaxVisitor {

        var imports: [Lint.Source.Index.Import] = []

        private let converter: SourceLocationConverter

        init(tree: SourceFileSyntax) {
            self.converter = SourceLocationConverter(fileName: "", tree: tree)
            super.init(viewMode: .sourceAccurate)
        }

        override func visit(_ node: ImportDeclSyntax) -> SyntaxVisitorContinueKind {
            let module = node.path.map(\.name.text).joined(separator: ".")
            var clauses: [Swift::Set<Swift::String>] = []
            var current = node.parent
            while let candidate = current {
                if let clause = candidate.as(IfConfigClauseSyntax.self) {
                    clauses.insert(Self.identifiers(of: clause), at: 0)
                }
                current = candidate.parent
            }
            let line = converter.location(for: node.positionAfterSkippingLeadingTrivia).line
            imports.append(.init(module: module, clauses: clauses, line: line))
            return .skipChildren
        }

        private static func identifiers(of clause: IfConfigClauseSyntax) -> Swift::Set<Swift::String> {
            guard clause.poundKeyword.tokenKind == .poundIf, let condition = clause.condition else {
                return []
            }
            let collector = IdentifierCollector(viewMode: .sourceAccurate)
            collector.walk(condition)
            return collector.negated ? [] : collector.identifiers
        }
    }
}

extension Lint.Source.ImportCollector {

    fileprivate final class IdentifierCollector: SyntaxVisitor {

        var identifiers: Swift::Set<Swift::String> = []

        var negated = false

        override func visit(_ node: DeclReferenceExprSyntax) -> SyntaxVisitorContinueKind {
            identifiers.insert(node.baseName.text)
            return .skipChildren
        }

        override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
            .skipChildren
        }

        override func visit(_ node: PrefixOperatorExprSyntax) -> SyntaxVisitorContinueKind {
            if node.operator.text == "!" { negated = true }
            return .visitChildren
        }
    }
}
