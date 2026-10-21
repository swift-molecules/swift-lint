extension Lint.Rule {

    public struct Suppression: Sendable, Equatable {
        @usableFromInline
        internal let _next: Bool

        @usableFromInline
        internal let _line: Bool

        @usableFromInline
        internal init(next: Bool, line: Bool) {
            self._next = next
            self._line = line
        }
    }
}

extension Lint.Rule.Suppression {

    public static let none = Self(next: false, line: false)

    public static let next = Self(next: true, line: false)

    public static let line = Self(next: false, line: true)

    public static let both = Self(next: true, line: true)

    public func sanctions(_ directive: Directive) -> Bool {
        switch directive {
        case .next:
            _next

        case .line:
            _line
        }
    }
}
