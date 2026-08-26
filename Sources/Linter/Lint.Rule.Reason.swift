extension Lint.Rule {

  public enum Reason: Sendable, Equatable {
    case missingSemanticContext
    case unsupportedSourceShape(Swift.String)
    case repairUnavailable
    case ambiguousRepair(Swift.String)
    case other(code: Swift.String, detail: Swift.String)
  }
}
