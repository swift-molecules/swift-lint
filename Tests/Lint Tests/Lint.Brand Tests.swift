import Byte
import Lint_Test_Support
import SwiftParser
import SwiftSyntax
import Testing

extension Lint.Brand {
  @Suite
  struct Test {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
  }
}

extension Lint.Brand.Test {

  static func parsed(
    _ text: Swift.String,
    types: Swift.Set<Swift.String>
  ) -> Lint.Source.Parsed {
    let tree = Parser.parse(source: text)
    let converter = SourceLocationConverter(fileName: "Test.swift", tree: tree)
    var manager = Source.Manager()
    let id = manager.register(
      fileID: "TestModule/Test.swift",
      filePath: "Test.swift",
      content: text.utf8.map(Byte.init)
    )
    return Lint.Source.Parsed(
      file: manager.file(for: id),
      path: "Sources/Test/Test.swift",
      tree: tree,
      converter: converter,
      types: types
    )
  }
}

extension Lint.Brand.Test.Unit {
  @Test
  func `top-level struct name is recognised`() {
    let tree = Parser.parse(source: "public struct Cardinal { public let rawValue: UInt }")
    #expect(Lint.Brand.types(in: tree).contains("Cardinal"))
  }

  @Test
  func `top-level namespace enum name is recognised`() {
    let tree = Parser.parse(source: "public enum Cyclic {}")
    #expect(Lint.Brand.types(in: tree).contains("Cyclic"))
  }

  @Test
  func `top-level protocol and class and actor names are recognised`() {
    let names = Lint.Brand.types(
      in: Parser.parse(source: "protocol P {}\nclass C {}\nactor A {}")
    )
    #expect(names.isSuperset(of: ["P", "C", "A"]))
  }

  @Test
  func `owned is true when the run declares a guarded brand`() {
    let source = Lint.Brand.Test.parsed("let x = c.rawValue", types: ["Cardinal"])

    let ownedByVocabulary = Lint.Brand.owned(Lint.Brand.vocabulary, in: source)
    let ownedByCardinal = Lint.Brand.owned(["Cardinal"], in: source)
    #expect(ownedByVocabulary)
    #expect(ownedByCardinal)
  }

  @Test
  func `owned is false when the run declares no guarded brand`() {
    let source = Lint.Brand.Test.parsed(
      "let x = c.rawValue",
      types: ["SomeConsumerType"]
    )
    let owned = Lint.Brand.owned(Lint.Brand.vocabulary, in: source)
    #expect(!owned)
  }

  @Test
  func `vocabulary carries the five brand owners`() {
    #expect(
      Lint.Brand.vocabulary
        == ["Cardinal", "Ordinal", "Cyclic", "Affine", "Carrier"]
    )
  }
}

extension Lint.Brand.Test.`Edge Case` {
  @Test
  func `nested type named like a brand is NOT a top-level declaration`() {

    let tree = Parser.parse(source: "enum Consumer { struct Cardinal {} }")
    #expect(!Lint.Brand.types(in: tree).contains("Cardinal"))
    #expect(Lint.Brand.types(in: tree).contains("Consumer"))
  }

  @Test
  func `unstamped parsed source is never owned`() {

    let source = Lint.Brand.Test.parsed("let x = c.rawValue", types: [])
    let owned = Lint.Brand.owned(Lint.Brand.vocabulary, in: source)
    #expect(!owned)
  }
}
