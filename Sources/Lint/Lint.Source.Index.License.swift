extension Lint.Source.Index {

  public enum License: Sendable, Hashable {

    case unread

    case absent

    case text(Swift::String)
  }
}
