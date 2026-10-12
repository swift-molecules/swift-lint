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
