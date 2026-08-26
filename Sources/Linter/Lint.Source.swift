extension Lint {

  public enum Source {}
}

extension Lint.Source {

  public typealias Path = Tagged<Lint.Source, Swift.String>
}
