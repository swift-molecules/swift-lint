extension Array where Element == Lint.Rule.Configuration {

  @inlinable
  public func excluding(rules excluded: Set<Lint.Rule.ID>) -> [Lint.Rule.Configuration] {
    self.filter { !excluded.contains($0.rule.id) }
  }
}
