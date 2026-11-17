import Lint_Test_Support
import SwiftParser
import SwiftSyntax
import Testing

enum `Lint.Rule.Control Tests` {}

extension `Lint.Rule.Control Tests` {
    @Suite
    struct Test {
        @Suite struct Unit {}
    }
}

extension `Lint.Rule.Control Tests`.Test.Unit {
    @Test
    func `a control's index holds its source, its sibling files and its package facts`() {
        let control = Lint.Rule.Control(
            id: "fixture",
            source: "import Alpha",
            path: "Package.swift",
            expectation: .clean,
            license: .text("Apache"),
            files: ["Sources/Example/File.swift": "import Beta"],
            documents: ["README.md"],
            packages: ["example-app"]
        )
        let index = control.index(tree: Parser.parse(source: control.source)) { Parser.parse(source: $0) }
        #expect(index.imports(under: "").map(\.path) == ["Package.swift", "Sources/Example/File.swift"])
        #expect(index.imports(under: "Sources").map(\.import.module) == ["Beta"])
        #expect(index.license == .text("Apache"))
        #expect(index.documents == ["README.md"])
        #expect(index.packages == ["example-app"])
    }
}
