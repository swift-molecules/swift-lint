extension Lint.Rule {

  public enum Coverage: Sendable, Equatable {
    case measured
    case unmeasured(Reason)
  }
}
