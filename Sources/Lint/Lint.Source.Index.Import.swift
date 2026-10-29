extension Lint.Source.Index {

    /// One `import` declaration and the `#if` clauses enclosing it, outermost first.
    ///
    /// Each clause contributes the bare identifiers its condition names (`#if Parser && Coder`
    /// gives `["Parser", "Coder"]`). A clause the import is reached through without its
    /// condition holding — an `#elseif` or `#else` branch, or a negated condition — contributes
    /// the empty set: it guarantees nothing about which identifiers are on. Calls such as
    /// `canImport(X)` or `os(Linux)` are not identifiers and contribute nothing.
    public struct Import: Sendable, Hashable {

        public var module: Swift::String

        public var clauses: [Swift::Set<Swift::String>]

        public var line: Swift::Int

        @inlinable
        public init(module: Swift::String, clauses: [Swift::Set<Swift::String>], line: Swift::Int) {
            self.module = module
            self.clauses = clauses
            self.line = line
        }
    }
}

extension Lint.Source.Index.Import {

    /// Whether some enclosing clause names one of `identifiers`, so the import compiles only
    /// when at least one of them is on.
    @inlinable
    public func isGuarded(by identifiers: Swift::Set<Swift::String>) -> Swift::Bool {
        clauses.contains { !$0.isDisjoint(with: identifiers) }
    }

    /// The identifiers of the innermost enclosing clause that names any of `identifiers`,
    /// restricted to them; empty when no clause does.
    @inlinable
    public func guards(among identifiers: Swift::Set<Swift::String>) -> Swift::Set<Swift::String> {
        clauses.last { !$0.isDisjoint(with: identifiers) }?.intersection(identifiers) ?? []
    }
}
