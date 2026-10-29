extension Lint.Source.Index.Import {

    /// One enclosing `#if` clause: the bare identifiers its condition names
    /// (`#if Parser && Coder` gives `["Parser", "Coder"]`), and whether they are joined by `&&`
    /// alone.
    ///
    /// A clause the import is reached through without its condition holding — an `#elseif` or
    /// `#else` branch, or a negated condition — names nothing: it guarantees nothing about which
    /// identifiers are on. Calls such as `canImport(X)` or `os(Linux)` are not identifiers and
    /// contribute nothing.
    public struct Clause: Sendable, Hashable {

        public var identifiers: Swift::Set<Swift::String>

        public var isConjunction: Swift::Bool

        @inlinable
        public init(identifiers: Swift::Set<Swift::String>, isConjunction: Swift::Bool) {
            self.identifiers = identifiers
            self.isConjunction = isConjunction
        }
    }
}
