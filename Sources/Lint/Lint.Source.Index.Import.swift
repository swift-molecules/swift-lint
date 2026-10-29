extension Lint.Source.Index {

    /// One `import` declaration and the `#if` clauses enclosing it, outermost first.
    public struct Import: Sendable, Hashable {

        public var module: Swift::String

        public var clauses: [Clause]

        public var line: Swift::Int

        @inlinable
        public init(module: Swift::String, clauses: [Clause], line: Swift::Int) {
            self.module = module
            self.clauses = clauses
            self.line = line
        }
    }
}

extension Lint.Source.Index.Import {

    /// Whether the import compiles only when one of `allowed` is on, judged over the clause
    /// identifiers that are in `among`: a conjunction (`#if A && B`) guards when it names one of
    /// `allowed`; any other condition (`#if A || B`) only when every identifier it names is.
    @inlinable
    public func isGuarded(
        by allowed: Swift::Set<Swift::String>,
        among names: Swift::Set<Swift::String>
    ) -> Swift::Bool {
        clauses.contains { clause in
            let named = clause.identifiers.intersection(names)
            guard !named.isEmpty else { return false }
            return clause.isConjunction ? !named.isDisjoint(with: allowed) : named.isSubset(of: allowed)
        }
    }

    /// The identifiers in `names` that the innermost clause naming any of them names; empty
    /// when no clause does.
    @inlinable
    public func guards(among names: Swift::Set<Swift::String>) -> Swift::Set<Swift::String> {
        clauses.last { !$0.identifiers.isDisjoint(with: names) }?.identifiers.intersection(names) ?? []
    }
}
