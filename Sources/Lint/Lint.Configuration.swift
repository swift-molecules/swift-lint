public import Ownership
public import Standard_Library_Extensions

extension Lint {

  public struct Configuration: Sendable {

    @usableFromInline
    internal let _parent: Ownership.Immutable<Lint.Configuration>?

    @usableFromInline
    internal let _ruleEntries: [Lint.Rule.Configuration]

    public let excluded: [Lint.Filter.Prefix]

    @usableFromInline
    internal let _disabledRules: Set<Lint.Rule.ID>

    @inlinable
    public init(
      inheriting parent: Self? = nil,
      excluded: [Lint.Filter.Prefix] = [],
      disabled: Set<Lint.Rule.ID> = [],
      @Array<Lint.Rule.Configuration>.Builder rules: () -> [Lint.Rule.Configuration]
    ) {
      self._parent = parent.map(Ownership.Immutable.init)
      self._ruleEntries = rules()
      self.excluded = excluded
      self._disabledRules = disabled
    }
  }
}

extension Lint.Configuration {

  @inlinable
  public var parent: Lint.Configuration? {
    _parent.map(\.value)
  }

  public static let empty: Lint.Configuration = Lint.Configuration { [] }

  @inlinable
  public var rules: Rules { Rules(_config: self) }
}
