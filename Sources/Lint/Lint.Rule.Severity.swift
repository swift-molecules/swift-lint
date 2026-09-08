extension Lint.Rule {

  public struct Severity: Sendable {

    public let `default`: Diagnostic.Severity

    @inlinable
    public init(default severity: Diagnostic.Severity) {
      self.default = severity
    }
  }
}
