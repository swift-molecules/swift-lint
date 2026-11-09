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

    public typealias Prefix = Tagged<Lint.Filter, Swift::String>

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
    public func matches(sourcePath: Lint.Source.Path) -> Swift::Bool {
        let path = sourcePath.underlying
        if !included.isEmpty, !included.contains(where: { Self.contains(path, under: $0) }) {
            return false
        }
        return !excluded.contains { Self.contains(path, under: $0) }
    }

    @usableFromInline
    internal static func contains(_ path: Swift::String, under prefix: Prefix) -> Swift::Bool {
        let directory = prefix.underlying
        guard !directory.isEmpty, !directory.hasSuffix("/") else { return path.hasPrefix(directory) }
        return path == directory || path.hasPrefix(directory + "/")
    }
}
