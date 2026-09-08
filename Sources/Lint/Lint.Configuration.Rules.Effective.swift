extension Lint.Configuration.Rules {

  public struct Effective: Sendable {
    @usableFromInline
    internal let _config: Lint.Configuration

    @inlinable
    public init(_config: Lint.Configuration) {
      self._config = _config
    }
  }
}

extension Lint.Configuration.Rules.Effective {

  @inlinable
  public var entries: [Lint.Rule.Configuration] {
    var raw: [Lint.Rule.Configuration] = []
    if let parent = _config.parent {
      raw.append(contentsOf: parent.rules.effective.entries)
    }
    raw.append(contentsOf: _config._ruleEntries)
    var byID: [Lint.Rule.ID: Lint.Rule.Configuration] = [:]
    var order: [Lint.Rule.ID] = []
    for entry in raw {
      let id = entry.rule.id
      if byID[id] == nil { order.append(id) }
      byID[id] = entry
    }
    let disabledIDs = self.disabled
    return order.compactMap { id in
      guard let entry = byID[id], entry.mode == .enabled else { return nil }
      if disabledIDs.contains(id) { return nil }
      return entry
    }
  }

  @inlinable
  public var disabled: Set<Lint.Rule.ID> {
    var ids: Set<Lint.Rule.ID> = []
    if let parent = _config.parent {
      for id in parent.rules.effective.disabled {
        ids.insert(id)
      }
    }
    for id in _config._disabledRules {
      ids.insert(id)
    }
    return ids
  }
}
