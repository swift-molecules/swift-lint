extension Lint.Rule {

  public struct Configuration: Sendable {

    public let rule: Lint.Rule

    public let mode: Mode

    public let severity: Diagnostic.Severity?

    @inlinable
    public init(
      rule: Lint.Rule,
      mode: Mode,
      severity: Diagnostic.Severity? = nil
    ) {
      self.rule = rule
      self.mode = mode
      self.severity = severity
    }
  }
}

extension Lint.Rule.Configuration {

  @inlinable
  public static func enable(
    _ rule: Lint.Rule,
    severity: Diagnostic.Severity? = nil,
    paths: Lint.Filter? = nil
  ) -> Self {
    let stored = paths.map(rule.filtered(toPaths:)) ?? rule
    return Self(rule: stored, mode: .enabled, severity: severity)
  }

  @inlinable
  public static func disable(_ rule: Lint.Rule) -> Self {
    Self(rule: rule, mode: .disabled, severity: nil)
  }

  @inlinable
  public static func override(
    _ rule: Lint.Rule,
    severity: Diagnostic.Severity
  ) -> Self {
    Self(rule: rule, mode: .enabled, severity: severity)
  }
}
