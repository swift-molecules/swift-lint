import Lint_Test_Support
import SwiftParser
import SwiftSyntax
import Testing

extension Lint.Source.Index {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }

    fileprivate static func of(_ files: Swift::String...) -> Self {
        var index = Self()
        for file in files { index.merge(.collect(from: Parser.parse(source: file))) }
        return index
    }
}

extension Lint.Source.Index.Test.Unit {
    @Test
    func `value generic types are known by simple and qualified name across files`() {
        let index = Lint.Source.Index.of(
            "extension Bitset { public struct Static<let wordCount: Int> {} }",
            "extension Bitset.Static { subscript(index: Int) -> Bool { false } }"
        )
        #expect(index.isValueGeneric("Bitset.Static"))
        #expect(index.isValueGeneric("Static"))
        #expect(!index.isValueGeneric("Bitset"))
    }

    @Test
    func `an associated type witnessed through a conformance in another file is found`() {
        let index = Lint.Source.Index.of(
            "public protocol EffectWithHandler { associatedtype HandlerKey }",
            "extension Effect { public struct Exit: Effect.`Protocol`, EffectWithHandler {} }",
            "extension Effect.Exit { public typealias HandlerKey = Handler.Key }"
        )
        #expect(index.witnessesAssociatedType(named: "HandlerKey", on: "Effect.Exit"))
        #expect(!index.witnessesAssociatedType(named: "Other", on: "Effect.Exit"))
    }
}

extension Lint.Source.Index.Test.`Edge Case` {
    @Test
    func `associated types are inherited through protocol refinement and extension conformances`() {
        let index = Lint.Source.Index.of(
            "public protocol Keyed { associatedtype Key }",
            "public protocol Refined: Keyed {}",
            "public struct Sample {}",
            "extension Sample: @retroactive Refined {}"
        )
        #expect(index.witnessesAssociatedType(named: "Key", on: "Sample"))
    }

    @Test
    func `a type without conformances witnesses nothing`() {
        let index = Lint.Source.Index.of(
            "public protocol Keyed { associatedtype Key }",
            "public struct Sample {}"
        )
        #expect(!index.witnessesAssociatedType(named: "Key", on: "Sample"))
    }
}

extension Lint.Source.Index.Test.Unit {
    @Test
    func `a member that witnesses a protocol requirement is found`() {
        let index = Lint.Source.Index.of(
            "public protocol _OptionalProtocol<Wrapped> { associatedtype Wrapped; var _wrapped: Wrapped? { get } }",
            "extension Optional: _OptionalProtocol { public var _wrapped: Wrapped? { self } }"
        )
        #expect(index.witnessesRequirement(named: "_wrapped", on: "Optional"))
        #expect(!index.witnessesRequirement(named: "_backing", on: "Optional"))
    }
}

extension Lint.Source.Index.Test.Unit {
    @Test
    func `a read license survives a merge with files that carry none`() {
        var index = Lint.Source.Index(license: .text("Apache License"))
        index.merge(.collect(from: Parser.parse(source: "struct A {}")))
        #expect(index.license == .text("Apache License"))
        var empty = Lint.Source.Index()
        empty.merge(Lint.Source.Index(license: .absent))
        #expect(empty.license == .absent)
    }
}

extension Lint.Source.Index.Test.Unit {
    @Test
    func `an import records the identifiers of each enclosing if clause`() {
        let index = Lint.Source.Index.collect(
            from: Parser.parse(source: "#if Parser && os(Linux)\n#if Coder\nimport Map\n#endif\n#endif\nimport Span"),
            path: "Sources/Owner/exports.swift"
        )
        let imports = index.imports(under: "Sources/Owner").map(\.import)
        #expect(imports.map(\.module) == ["Map", "Span"])
        #expect(imports[0].clauses.map(\.identifiers) == [["Parser"], ["Coder"]])
        #expect(imports[0].guards(among: ["Parser", "Coder"]) == ["Coder"])
        #expect(!imports[1].isGuarded(by: ["Parser"], among: ["Parser"]))
        #expect(index.imports(under: "Sources/Other").isEmpty)
    }
}

extension Lint.Source.Index.Test.`Edge Case` {
    @Test
    func `an else branch or a negated condition guards nothing`() {
        let index = Lint.Source.Index.collect(
            from: Parser.parse(source: "#if Parser\n#else\nimport Map\n#endif\n#if !Coder\nimport Span\n#endif"),
            path: "Sources/Owner/exports.swift"
        )
        let imports = index.imports(under: "").map(\.import)
        #expect(imports.allSatisfy { !$0.isGuarded(by: ["Parser", "Coder"], among: ["Parser", "Coder"]) })
    }

    @Test
    func `canImport names a module, not a trait`() {
        let index = Lint.Source.Index.collect(
            from: Parser.parse(source: "#if canImport(Parser)\nimport Parser\n#endif"),
            path: "Sources/Owner/exports.swift"
        )
        #expect(index.imports(under: "Sources")[0].import.isGuarded(by: ["Parser"], among: ["Parser"]) == false)
    }
}

extension Lint.Source.Index.Test.`Edge Case` {
    @Test
    func `a conjunction guards on any one identifier, a disjunction only on all`() {
        let index = Lint.Source.Index.collect(
            from: Parser.parse(source: "#if Parser && Coder\nimport Map\n#endif\n#if Parser || Coder\nimport Span\n#endif"),
            path: "Package.swift"
        )
        let imports = index.imports(under: "").map(\.import)
        let names: Swift::Set<Swift::String> = ["Parser", "Coder"]
        #expect(imports[0].isGuarded(by: ["Parser"], among: names))
        #expect(!imports[1].isGuarded(by: ["Parser"], among: names))
        #expect(imports[1].isGuarded(by: names, among: names))
    }
}
