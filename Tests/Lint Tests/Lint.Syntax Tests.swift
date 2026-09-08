import Lint_Test_Support
import SwiftParser
import SwiftSyntax
import Testing

extension Lint.Syntax {
  @Suite
  struct Test {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite struct Identifier {}
    @Suite struct `If Config` {}
    @Suite struct Scope {}
  }
}

extension Lint.Syntax.Test.Identifier {
  @Test
  func `Matched pair of backticks is stripped`() {
    #expect(Lint.Syntax.Identifier.unescaped("`Protocol`") == "Protocol")
  }

  @Test
  func `Text with no backticks is returned unchanged`() {
    #expect(Lint.Syntax.Identifier.unescaped("Protocol") == "Protocol")
  }

  @Test
  func `One-sided leading backtick is returned unchanged`() {
    #expect(Lint.Syntax.Identifier.unescaped("`Protocol") == "`Protocol")
  }

  @Test
  func `One-sided trailing backtick is returned unchanged`() {
    #expect(Lint.Syntax.Identifier.unescaped("Protocol`") == "Protocol`")
  }

  @Test
  func `Single backtick character is returned unchanged`() {
    #expect(Lint.Syntax.Identifier.unescaped("`") == "`")
  }
}

extension Lint.Syntax.Test.`If Config` {
  @Test
  func `Nested if config inside if config is flattened all the way down`() {
    let source = """
      #if os(Linux)
      #if arch(x86_64)
      let a = 1
      #endif
      #endif
      let b = 2
      """
    let tree = Parser.parse(source: source)
    let flattened = Lint.Syntax.Conditional.statements(tree.statements)
    #expect(flattened.count == 2)
  }

  @Test
  func `Member position if config is spliced into the member list`() {
    let source = """
      struct Foo {
          #if os(Linux)
          func f() {}
          #endif
          var x: Int = 0
      }
      """
    let tree = Parser.parse(source: source)
    guard
      let structDecl = findFirstNode(in: Syntax(tree), as: { $0.as(StructDeclSyntax.self) })
    else {
      Issue.record("expected a StructDeclSyntax")
      return
    }
    let members = Lint.Syntax.Conditional.members(structDecl.memberBlock)
    #expect(members.count == 2)
  }

  @Test
  func `Non if config members are kept as-is`() {
    let source = """
      struct Foo {
          var x: Int = 0
          var y: Int = 0
      }
      """
    let tree = Parser.parse(source: source)
    guard
      let structDecl = findFirstNode(in: Syntax(tree), as: { $0.as(StructDeclSyntax.self) })
    else {
      Issue.record("expected a StructDeclSyntax")
      return
    }
    let members = Lint.Syntax.Conditional.members(structDecl.memberBlock)
    #expect(members.count == 2)
  }
}

extension Lint.Syntax.Test.Scope {
  @Test
  func `Type declared at file scope is top level`() {
    let source = "struct Foo {}"
    let tree = Parser.parse(source: source)
    guard
      let structDecl = findFirstNode(in: Syntax(tree), as: { $0.as(StructDeclSyntax.self) })
    else {
      Issue.record("expected a StructDeclSyntax")
      return
    }
    #expect(Lint.Syntax.Scope.isTopLevel(structDecl))
  }

  @Test
  func `Type nested inside a function body is not top level`() {
    let source = """
      func f() {
          struct Foo {}
      }
      """
    let tree = Parser.parse(source: source)
    guard
      let structDecl = findFirstNode(in: Syntax(tree), as: { $0.as(StructDeclSyntax.self) })
    else {
      Issue.record("expected a StructDeclSyntax")
      return
    }
    #expect(!Lint.Syntax.Scope.isTopLevel(structDecl))
  }

  @Test
  func `Type nested inside a file scope if config is still top level`() {
    let source = """
      #if os(Linux)
      struct Foo {}
      #endif
      """
    let tree = Parser.parse(source: source)
    guard
      let structDecl = findFirstNode(in: Syntax(tree), as: { $0.as(StructDeclSyntax.self) })
    else {
      Issue.record("expected a StructDeclSyntax")
      return
    }
    #expect(Lint.Syntax.Scope.isTopLevel(structDecl))
  }

  @Test
  func `Type nested inside an extension body is not top level`() {
    let source = """
      extension Outer {
          struct Foo {}
      }
      """
    let tree = Parser.parse(source: source)
    guard
      let structDecl = findFirstNode(in: Syntax(tree), as: { $0.as(StructDeclSyntax.self) })
    else {
      Issue.record("expected a StructDeclSyntax")
      return
    }
    #expect(!Lint.Syntax.Scope.isTopLevel(structDecl))
  }

  @Test
  func `Type nested inside a closure body is not top level`() {
    let source = """
      let f = {
          struct Foo {}
      }
      """
    let tree = Parser.parse(source: source)
    guard
      let structDecl = findFirstNode(in: Syntax(tree), as: { $0.as(StructDeclSyntax.self) })
    else {
      Issue.record("expected a StructDeclSyntax")
      return
    }
    #expect(!Lint.Syntax.Scope.isTopLevel(structDecl))
  }
}

private func findFirstNode<T: SyntaxProtocol>(
  in node: Syntax,
  as cast: (Syntax) -> T?
) -> T? {
  if let matched = cast(node) {
    return matched
  }
  for child in node.children(viewMode: .sourceAccurate) {
    if let found = findFirstNode(in: child, as: cast) {
      return found
    }
  }
  return nil
}
