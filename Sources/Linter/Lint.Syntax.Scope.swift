public import SwiftSyntax

extension Lint.Syntax {

  public enum Scope {}
}

extension Lint.Syntax.Scope {

  @inlinable
  public static func isTopLevel(_ node: some SyntaxProtocol) -> Swift.Bool {
    var current: Syntax? = Syntax(node).parent
    while let ancestor = current {
      if ancestor.is(SourceFileSyntax.self) {
        return true
      }
      if ancestor.is(StructDeclSyntax.self)
        || ancestor.is(ClassDeclSyntax.self)
        || ancestor.is(EnumDeclSyntax.self)
        || ancestor.is(ActorDeclSyntax.self)
        || ancestor.is(ProtocolDeclSyntax.self)
        || ancestor.is(ExtensionDeclSyntax.self)
        || ancestor.is(FunctionDeclSyntax.self)
        || ancestor.is(InitializerDeclSyntax.self)
        || ancestor.is(DeinitializerDeclSyntax.self)
        || ancestor.is(SubscriptDeclSyntax.self)
        || ancestor.is(AccessorDeclSyntax.self)
        || ancestor.is(AccessorBlockSyntax.self)
        || ancestor.is(ClosureExprSyntax.self)
      {
        return false
      }
      current = ancestor.parent
    }
    return false
  }
}
