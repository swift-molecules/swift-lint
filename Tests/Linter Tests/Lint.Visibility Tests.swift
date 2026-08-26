import Linter_Test_Support
import SwiftParser
import SwiftSyntax
import Testing

extension Lint.Visibility {
  @Suite
  struct Test {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite struct Effective {}
  }
}

extension Lint.Visibility.Test.Unit {
  @Test
  func `Comparable orders narrower visibility lower`() {
    #expect(Lint.Visibility.private < .fileprivate)
    #expect(Lint.Visibility.fileprivate < .internal)
    #expect(Lint.Visibility.internal < .package)
    #expect(Lint.Visibility.package < .public)
  }

  @Test
  func `min over chain yields narrowest`() {
    let chain: [Lint.Visibility] = [.public, .package, .fileprivate, .internal]
    let narrowest = chain.min()
    #expect(narrowest == .fileprivate)
  }

  @Test
  func `Raw value identifies cases stably`() {
    #expect(Lint.Visibility.public.rawValue == "public")
    #expect(Lint.Visibility.package.rawValue == "package")
    #expect(Lint.Visibility.internal.rawValue == "internal")
    #expect(Lint.Visibility.fileprivate.rawValue == "fileprivate")
    #expect(Lint.Visibility.private.rawValue == "private")
  }
}

extension Lint.Visibility.Test.Effective {
  @Test
  func `Bare struct field defaults to internal`() {
    let source = """
      struct Header {
          var field: Int
      }
      """
    let visibility = firstDeclVisibility(in: source, named: "field")
    #expect(visibility == .internal)
  }

  @Test
  func `Public struct public field is public`() {
    let source = """
      public struct Header {
          public var field: Int
      }
      """
    let visibility = firstDeclVisibility(in: source, named: "field")
    #expect(visibility == .public)
  }

  @Test
  func `Fileprivate struct internal-by-default field is fileprivate`() {
    let source = """
      fileprivate struct Header {
          var field: Int
      }
      """
    let visibility = firstDeclVisibility(in: source, named: "field")
    #expect(visibility == .fileprivate)
  }

  @Test
  func `Private struct public-marked field is private (minimum wins)`() {
    let source = """
      private struct Header {
          public var field: Int
      }
      """
    let visibility = firstDeclVisibility(in: source, named: "field")
    #expect(visibility == .private)
  }

  @Test
  func `Open class collapses to public`() {
    let source = """
      open class Widget {
          open var field: Int = 0
      }
      """
    let visibility = firstDeclVisibility(in: source, named: "field")
    #expect(visibility == .public)
  }

  @Test
  func `Package declaration remains package visible`() {
    let source = "package func helper() {}"
    let visibility = firstDeclVisibility(in: source, named: "helper")
    #expect(visibility == .package)
  }

  @Test
  func `Extension fileprivate covers contained func`() {
    let source = """
      struct Header {}
      fileprivate extension Header {
          func helper() {}
      }
      """
    let visibility = firstDeclVisibility(in: source, named: "helper")
    #expect(visibility == .fileprivate)
  }

  @Test
  func `Nested public struct inside private struct is private`() {
    let source = """
      private struct Outer {
          public struct Inner {
              public var field: Int = 0
          }
      }
      """
    let visibility = firstDeclVisibility(in: source, named: "field")
    #expect(visibility == .private)
  }

  @Test
  func `Top-level fileprivate function is fileprivate`() {
    let source = """
      fileprivate func helper() {}
      """
    let visibility = firstDeclVisibility(in: source, named: "helper")
    #expect(visibility == .fileprivate)
  }
}

private func firstDeclVisibility(
  in source: Swift.String,
  named name: Swift.String
) -> Lint.Visibility? {
  let tree = Parser.parse(source: source)
  return findNamedDecl(in: Syntax(tree), name: name).map { Lint.Visibility.effective(of: $0) }
}

private func findNamedDecl(in node: Syntax, name: Swift.String) -> Syntax? {
  if let function = node.as(FunctionDeclSyntax.self), function.name.text == name {
    return Syntax(function)
  }
  if let variable = node.as(VariableDeclSyntax.self) {
    for binding in variable.bindings {
      if let identifier = binding.pattern.as(IdentifierPatternSyntax.self),
        identifier.identifier.text == name
      {
        return Syntax(variable)
      }
    }
  }
  for child in node.children(viewMode: .sourceAccurate) {
    if let found = findNamedDecl(in: child, name: name) {
      return found
    }
  }
  return nil
}
