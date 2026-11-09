extension Lint.Rule.Repair {

    public enum Edit: Sendable, Equatable {
        case rewrite(path: Lint.Source.Path, contents: Swift::String)
        case create(path: Lint.Source.Path, contents: Swift::String)
        case move(from: Lint.Source.Path, to: Lint.Source.Path)
        case delete(path: Lint.Source.Path)
    }
}

extension Lint.Rule.Repair.Edit {

    public var paths: [Lint.Source.Path] {
        switch self {
        case .rewrite(let path, _), .create(let path, _), .delete(let path):
            [path]
        case .move(let source, let destination):
            [source, destination]
        }
    }
}
