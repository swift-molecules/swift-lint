extension Lint.Rule {

  public struct Observation: Sendable, Equatable {

    public let findings: [Diagnostic.Record]

    public let coverage: Coverage

    public let applicability: Applicability

    @inlinable
    public init(
      findings: [Diagnostic.Record],
      coverage: Coverage,
      applicability: Applicability = .applicable
    ) {
      self.findings = findings
      self.coverage = coverage
      self.applicability = applicability
    }
  }
}
