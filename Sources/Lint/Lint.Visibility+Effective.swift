public import SwiftSyntax

extension Lint.Visibility {

  @inlinable
  public static func declared(in modifiers: DeclModifierListSyntax) -> Lint.Visibility? {
    for modifier in modifiers {
      switch modifier.name.tokenKind {
      case .keyword(.public), .keyword(.open):
        return .public

      case .keyword(.package):
        return .package

      case .keyword(.internal):
        return .internal

      case .keyword(.fileprivate):
        return .fileprivate

      case .keyword(.private):
        return .private

      default:
        continue
      }
    }
    return nil
  }

  @inlinable
  public static func effective(of node: Syntax) -> Lint.Visibility {
    var minimum: Lint.Visibility?
    var cursor: Syntax? = node
    while let candidate = cursor {
      if let modifiers = modifiers(of: candidate),
        let declared = declared(in: modifiers)
      {
        minimum = minimum.map { Swift.min($0, declared) } ?? declared
      }
      cursor = candidate.parent
    }
    return minimum ?? .internal
  }

  @usableFromInline
  static func modifiers(of node: Syntax) -> DeclModifierListSyntax? {
    if let decl = node.as(StructDeclSyntax.self) { return decl.modifiers }
    if let decl = node.as(ClassDeclSyntax.self) { return decl.modifiers }
    if let decl = node.as(EnumDeclSyntax.self) { return decl.modifiers }
    if let decl = node.as(ActorDeclSyntax.self) { return decl.modifiers }
    if let decl = node.as(ExtensionDeclSyntax.self) { return decl.modifiers }
    if let decl = node.as(ProtocolDeclSyntax.self) { return decl.modifiers }
    if let decl = node.as(FunctionDeclSyntax.self) { return decl.modifiers }
    if let decl = node.as(InitializerDeclSyntax.self) { return decl.modifiers }
    if let decl = node.as(SubscriptDeclSyntax.self) { return decl.modifiers }
    if let decl = node.as(VariableDeclSyntax.self) { return decl.modifiers }
    if let decl = node.as(TypeAliasDeclSyntax.self) { return decl.modifiers }
    if let decl = node.as(AssociatedTypeDeclSyntax.self) { return decl.modifiers }
    return nil
  }
}
