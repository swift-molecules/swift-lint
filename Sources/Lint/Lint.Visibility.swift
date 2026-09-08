extension Lint {

  public enum Visibility: Swift.String, Sendable, Hashable, Codable, Comparable, CaseIterable {
    case `public`
    case `package`
    case `internal`
    case `fileprivate`
    case `private`
  }
}

extension Lint.Visibility {

  @inlinable
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.ordinal < rhs.ordinal
  }

  @inlinable
  public var ordinal: Swift.Int {
    switch self {
    case .public: return 4
    case .package: return 3
    case .internal: return 2
    case .fileprivate: return 1
    case .private: return 0
    }
  }

  @inlinable
  public var token: Swift.String {
    switch self {
    case .public: "public"
    case .package: "package"
    case .internal: "internal"
    case .fileprivate: "fileprivate"
    case .private: "private"
    }
  }
}
