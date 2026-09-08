extension Lint.Rule.Observation {
  public enum Applicability: Sendable, Hashable {
    case applicable
    case inapplicable
  }
}

extension Lint.Rule.Observation.Applicability {
  @inlinable
  public var isApplicable: Swift.Bool { self == .applicable }
}
