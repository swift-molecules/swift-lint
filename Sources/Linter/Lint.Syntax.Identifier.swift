extension Lint.Syntax {

  public enum Identifier {}
}

extension Lint.Syntax.Identifier {

  @inlinable
  public static func unescaped(_ text: Swift.String) -> Swift.String {
    guard text.count >= 2, text.hasPrefix("`"), text.hasSuffix("`") else { return text }
    return Swift.String(text.dropFirst().dropLast())
  }
}
