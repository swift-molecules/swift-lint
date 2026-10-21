extension Lint.Configuration {

    public struct Rules: Sendable {
        @usableFromInline
        internal let _config: Lint.Configuration

        @inlinable
        public init(_config: Lint.Configuration) {
            self._config = _config
        }
    }
}

extension Lint.Configuration.Rules {

    @inlinable
    public var entries: [Lint.Rule.Configuration] {
        _config._ruleEntries
    }

    @inlinable
    public var disabled: Set<Lint.Rule.ID> {
        _config._disabledRules
    }

    @inlinable
    public var effective: Effective {
        Effective(_config: _config)
    }
}
