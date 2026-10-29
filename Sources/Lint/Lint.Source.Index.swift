public import SwiftSyntax

extension Lint.Source {

    public struct Index: Sendable, Equatable {

        public var valueGenericTypes: Swift::Set<Swift::String>

        public var associatedTypes: [Swift::String: Swift::Set<Swift::String>]

        public var conformances: [Swift::String: Swift::Set<Swift::String>]

        public var requirements: [Swift::String: Swift::Set<Swift::String>]

        public var license: License

        /// The `import` declarations of every package file, keyed by its package-relative path.
        public var imports: [Swift::String: [Import]]

        @inlinable
        public init(
            valueGenericTypes: Swift::Set<Swift::String> = [],
            associatedTypes: [Swift::String: Swift::Set<Swift::String>] = [:],
            conformances: [Swift::String: Swift::Set<Swift::String>] = [:],
            requirements: [Swift::String: Swift::Set<Swift::String>] = [:],
            license: License = .unread,
            imports: [Swift::String: [Import]] = [:]
        ) {
            self.valueGenericTypes = valueGenericTypes
            self.associatedTypes = associatedTypes
            self.conformances = conformances
            self.requirements = requirements
            self.license = license
            self.imports = imports
        }
    }
}

extension Lint.Source.Index {

    public static func collect(from tree: SourceFileSyntax) -> Self {
        let collector = Lint.Source.IndexCollector(viewMode: .sourceAccurate)
        collector.walk(tree)
        return collector.index
    }

    /// The facts of `tree`, plus its imports recorded under `path`.
    public static func collect(from tree: SourceFileSyntax, path: Swift::String) -> Self {
        var index = collect(from: tree)
        let collector = Lint.Source.ImportCollector(tree: tree)
        collector.walk(tree)
        index.imports[path] = collector.imports
        return index
    }

    /// The imports of every file under `directory`, a package-relative path without a trailing
    /// separator; the empty path is the package root.
    public func imports(under directory: Swift::String) -> [(path: Swift::String, import: Import)] {
        let prefix = directory.isEmpty ? "" : directory + "/"
        return imports.keys.sorted().filter { $0.hasPrefix(prefix) }.flatMap { path in
            (imports[path] ?? []).map { (path, $0) }
        }
    }

    public mutating func merge(_ other: Self) {
        valueGenericTypes.formUnion(other.valueGenericTypes)
        associatedTypes.merge(other.associatedTypes) { $0.union($1) }
        conformances.merge(other.conformances) { $0.union($1) }
        requirements.merge(other.requirements) { $0.union($1) }
        if license == .unread { license = other.license }
        imports.merge(other.imports) { $0 + $1 }
    }

    public func protocols(of type: Swift::String) -> Swift::Set<Swift::String> {
        conformances[type] ?? conformances[Self.leaf(of: type)] ?? []
    }

    public func isValueGeneric(_ type: Swift::String) -> Swift::Bool {
        valueGenericTypes.contains(type) || valueGenericTypes.contains(Self.leaf(of: type))
    }

    public func witnessesAssociatedType(
        named name: Swift::String,
        on type: Swift::String
    ) -> Swift::Bool {
        reachableProtocols(of: type).contains { associatedTypes[$0]?.contains(name) ?? false }
    }

    public func witnessesRequirement(
        named name: Swift::String,
        on type: Swift::String
    ) -> Swift::Bool {
        reachableProtocols(of: type).contains { requirements[$0]?.contains(name) ?? false }
    }

    public func reachableProtocols(of type: Swift::String) -> Swift::Set<Swift::String> {
        var pending = Swift::Array(protocols(of: type))
        var seen: Swift::Set<Swift::String> = []
        while let next = pending.popLast() {
            guard seen.insert(next).inserted else { continue }
            pending.append(contentsOf: conformances[next] ?? [])
        }
        return seen
    }

    @usableFromInline
    internal static func leaf(of type: Swift::String) -> Swift::String {
        type.split(separator: ".").last.map(Swift::String.init) ?? type
    }

    @usableFromInline
    internal static func spelling(of type: TypeSyntax) -> Swift::String {
        if let identifier = type.as(IdentifierTypeSyntax.self) {
            return identifier.name.text
        }
        if let member = type.as(MemberTypeSyntax.self) {
            return spelling(of: member.baseType) + "." + member.name.text
        }
        if let attributed = type.as(AttributedTypeSyntax.self) {
            return spelling(of: attributed.baseType)
        }
        return type.trimmedDescription
    }
}
