public import SwiftSyntax

extension Lint.Syntax {
  public enum Conditional {}
}

extension Lint.Syntax.Conditional {

  @inlinable
  public static func statements(
    _ list: CodeBlockItemListSyntax
  ) -> [CodeBlockItemSyntax] {
    var result: [CodeBlockItemSyntax] = []
    for item in list {
      guard case .decl(let decl) = item.item,
        let ifConfig = decl.as(IfConfigDeclSyntax.self)
      else {
        result.append(item)
        continue
      }
      for clause in ifConfig.clauses {
        guard let elements = clause.elements?.as(CodeBlockItemListSyntax.self) else {
          continue
        }
        result.append(contentsOf: statements(elements))
      }
    }
    return result
  }

  @inlinable
  public static func members(
    _ block: MemberBlockSyntax
  ) -> [MemberBlockItemSyntax] {
    members(block.members)
  }

  @inlinable
  public static func members(
    _ list: MemberBlockItemListSyntax
  ) -> [MemberBlockItemSyntax] {
    var result: [MemberBlockItemSyntax] = []
    for item in list {
      guard let ifConfig = item.decl.as(IfConfigDeclSyntax.self) else {
        result.append(item)
        continue
      }
      for clause in ifConfig.clauses {
        guard let elements = clause.elements?.as(MemberBlockItemListSyntax.self) else {
          continue
        }
        result.append(contentsOf: members(elements))
      }
    }
    return result
  }
}
