internal import SwiftSyntax

extension Lint.Rule {

    public static let `sketch try optional` = Lint.Rule(
        id: "sketch_try_optional",
        default: .warning,
        observe: Lint.Rule.measured { (source: borrowing Lint.Source.Parsed, severity) in
            final class Visitor: SyntaxVisitor {
                var hits: [SourceLocation] = []
                let converter: SourceLocationConverter
                init(converter: SourceLocationConverter) {
                    self.converter = converter
                    super.init(viewMode: .sourceAccurate)
                }
                override func visit(_ node: TryExprSyntax) -> SyntaxVisitorContinueKind {
                    if node.questionOrExclamationMark?.tokenKind == .postfixQuestionMark {
                        hits.append(node.startLocation(converter: converter))
                    }
                    return .visitChildren
                }
            }
            let visitor = Visitor(converter: source.converter)
            visitor.walk(source.tree)
            return visitor.hits.map { swiftLocation in
                Diagnostic.Record(
                    location: Source.Location(
                        fileID: source.file.fileID,
                        filePath: source.file.filePath,
                        line: swiftLocation.line,
                        column: swiftLocation.column
                    ),
                    severity: severity,
                    identifier: "sketch_try_optional",
                    message: "`try?` swallows typed-throws errors"
                )
            }
        }
    )

    public static let `sketch noop` = Lint.Rule(
        id: "sketch_noop",
        default: .warning,
        observe: Lint.Rule.measured { (_: borrowing Lint.Source.Parsed, _) in [] }
    )
}
