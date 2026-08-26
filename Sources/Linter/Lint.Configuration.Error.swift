extension Lint.Configuration {

  public enum Error: Swift.Error, Hashable, Sendable {
    case fileNotReadable(path: Swift.String)
    case malformed(path: Swift.String, reason: Swift.String)
    case unknownRuleID(Lint.Rule.ID, path: Swift.String)
  }
}
