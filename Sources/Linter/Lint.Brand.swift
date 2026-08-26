public import SwiftSyntax

extension Lint {

  public enum Brand {}
}

extension Lint.Brand {

  public static let vocabulary: Swift.Set<Swift.String> = [
    "Cardinal",
    "Ordinal",
    "Cyclic",
    "Affine",
    "Carrier",
  ]

  public static func types(in tree: SourceFileSyntax) -> Swift.Set<Swift.String> {
    var names: Swift.Set<Swift.String> = []
    for statement in tree.statements {
      let item = statement.item
      if let decl = item.as(StructDeclSyntax.self) {
        names.insert(decl.name.text)
      } else if let decl = item.as(EnumDeclSyntax.self) {
        names.insert(decl.name.text)
      } else if let decl = item.as(ProtocolDeclSyntax.self) {
        names.insert(decl.name.text)
      } else if let decl = item.as(ClassDeclSyntax.self) {
        names.insert(decl.name.text)
      } else if let decl = item.as(ActorDeclSyntax.self) {
        names.insert(decl.name.text)
      }
    }
    return names
  }

  public static func owned(
    _ brands: Swift.Set<Swift.String>,
    in source: borrowing Lint.Source.Parsed
  ) -> Swift.Bool {
    !brands.isDisjoint(with: source.types)
  }
}
