extension Lint.Rule.Repair {

  public enum Edit: Sendable, Equatable {
    case rewrite(path: Lint.Source.Path, contents: Swift.String)
    case create(path: Lint.Source.Path, contents: Swift.String)
    case move(from: Lint.Source.Path, to: Lint.Source.Path)
    case delete(path: Lint.Source.Path)
  }
}
