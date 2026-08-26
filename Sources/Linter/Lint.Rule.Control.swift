extension Lint.Rule {
  public struct Control: Hashable, Sendable {
    public let id: ID
    public let source: Swift.String
    public let path: Lint.Source.Path
    public let expectation: Expectation
    public let applicability: Lint.Rule.Observation.Applicability

    @inlinable
    public init(
      id: ID,
      source: Swift.String,
      path: Lint.Source.Path,
      expectation: Expectation,
      applicability: Lint.Rule.Observation.Applicability = .applicable
    ) {
      self.id = id
      self.source = source
      self.path = path
      self.expectation = expectation
      self.applicability = applicability
    }
  }
}
