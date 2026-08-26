# Linter

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Foundation-free abstractions for building a Swift linter — the rule witness value, the typed rule identifier, the layered configuration value, and the parsed-source bundle a rule consumes.

---

## Quick Start

A rule is *data*, not a protocol conformance: a `Lint.Rule` value pairs a typed identifier with a pure `findings` closure that walks a parsed syntax tree and emits `Diagnostic.Record` values at a severity the engine threads in. Rule packs publish rules as static members, so call sites read as natural English.

```swift
import Linter
import SwiftSyntax

extension Lint.Rule {
    public static let `try optional` = Lint.Rule(
        id: "try optional",
        default: .warning,
        suppression: .next,
        findings: { (source: borrowing Lint.Source.Parsed, severity) in
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
            return visitor.hits.map { location in
                Diagnostic.Record(
                    location: Source.Location(
                        fileID: source.file.fileID,
                        filePath: source.file.filePath,
                        line: location.line,
                        column: location.column
                    ),
                    severity: severity,
                    identifier: "try optional",
                    message: "`try?` swallows typed-throws errors"
                )
            }
        }
    )
}
```

Activate rules in a layered configuration. The rules block is a plain `Array.Builder`, so it is declarative and control-flow-friendly; `configuration.rules.effective` flattens a parent chain with later layers overriding earlier ones per rule ID:

```swift
import Linter

let configuration = Lint.Configuration(
    excluded: ["Tests/Fixtures", ".build"]
) {
    .enable(.`try optional`, severity: .error)
}
```

Three properties hold at compile time, not at runtime: the rule identifier is a `Tagged<Lint.Rule, String>` (mixing it with another tagged identifier is a type error); the finding shape is the ecosystem-wide `Diagnostic.Record` (the linter introduces no parallel finding type); and the visitor consumes a `Lint.Source.Parsed` bundle that carries file identity, AST, and a position-to-(line, column) converter as a single value.

---

## Inline Suppression Policy

Every rule carries one `Lint.Rule.Suppression` policy. Existing declarations default to `.none`; a rule opts in explicitly with `.next`, `.line`, or `.both`. The directive shape is typed, so an engine can ask `rule.suppression.sanctions(.next)` without matching rule IDs or directive strings.

`filtered(toPaths:)`, `with(default:)`, and `pinned(to:)` preserve the policy. `combining` never derives permissions from child rules: its composite policy defaults independently to `.none` and can be declared explicitly when the composite itself sanctions a shape.

This package owns the portable declaration only. Scanning source comments and consulting the policy before eliding findings remain responsibilities of the `swift-linter` engine.

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-molecules/swift-linter.git", branch: "main")
]
```

```swift
.target(
    name: "YourRulePack",
    dependencies: [
        .product(name: "Linter", package: "swift-linter"),
    ]
)
```

`Linter` re-exports `Source`, `Diagnostic`, `Tagged`, `Tagged_Standard_Library_Integration`, and `Standard_Library_Extensions`, so consumers reach `Source.Location`, `Diagnostic.Record`, and `Tagged` without importing them separately.

---

## Architecture

Two library products. Concrete rules, filesystem walking, and reporting are L3 concerns and live in `swift-linter` (the orchestrating binary) and `swift-linter-rules` (the canonical rule pack).

| Product | Target | Purpose |
|---------|--------|---------|
| `Linter` | `Sources/Linter/` | The `Lint` namespace: `Lint.Rule` (the witness value) and its `Lint.Rule.ID`, `Lint.Rule.Severity`, `Lint.Rule.Configuration`, and `Lint.Rule.Bundle`; `Lint.Configuration` with its `rules` view and `effective` chain resolution; `Lint.Finding`, `Lint.Filter`, `Lint.Source.Parsed`, and `Lint.Visibility`. |
| `Linter Test Support` | `Tests/Support/` | Re-exports the main target plus sketch rules that exercise the witness shape for test consumers. |

Foundation-free.

---

## Platform Support

| Platform | Status |
|----------|--------|
| macOS 26 | Full support |
| Linux | Full support |
| Windows | Full support |
| iOS / tvOS / watchOS / visionOS | Supported |

---

## Community

<!-- BEGIN: discussion -->
<!-- Discussion thread created at publication. -->
<!-- END: discussion -->

---

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
