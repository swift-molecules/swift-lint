extension Lint {

  public struct Filter: Sendable, Hashable {

    public let included: [Prefix]

    public let excluded: [Prefix]

    @inlinable
    public init(included: [Prefix] = [], excluded: [Prefix] = []) {
      self.included = included
      self.excluded = excluded
    }
  }
}

extension Lint.Filter {

  public typealias Prefix = Tagged<Lint.Filter, Swift.String>

  public static let all: Lint.Filter = Lint.Filter()

  @inlinable
  public static func including(_ paths: [Prefix]) -> Lint.Filter {
    Lint.Filter(included: paths)
  }

  @inlinable
  public static func excluding(_ paths: [Prefix]) -> Lint.Filter {
    Lint.Filter(excluded: paths)
  }

  @inlinable
  public func matches(sourcePath: Lint.Source.Path) -> Swift.Bool {
    let pathString = sourcePath.underlying
    if !included.isEmpty {
      var anyIncluded = false
      for prefix in included where pathString.hasPrefix(prefix.underlying) {
        anyIncluded = true
        break
      }
      if !anyIncluded { return false }
    }
    for prefix in excluded where pathString.hasPrefix(prefix.underlying) {
      return false
    }
    return true
  }
}
