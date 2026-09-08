extension Lint.Rule.Control {
  public enum Expectation: Hashable, Sendable {
    case clean
    case findings(Swift.Int)

    @inlinable
    public var count: Swift.Int {
      switch self {
      case .clean: 0
      case .findings(let count): count
      }
    }
  }
}
