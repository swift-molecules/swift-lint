public import SwiftSyntax

extension Lint.Source {

  public struct Parsed: ~Copyable, Sendable {

    public let file: Source.File

    public let path: Lint.Source.Path

    public let tree: SourceFileSyntax

    public let converter: SourceLocationConverter

    public let types: Swift.Set<Swift.String>

    @inlinable
    public init(
      file: Source.File,
      path: Lint.Source.Path,
      tree: SourceFileSyntax,
      converter: SourceLocationConverter,
      types: Swift.Set<Swift.String> = []
    ) {
      self.file = file
      self.path = path
      self.tree = tree
      self.converter = converter
      self.types = types
    }
  }
}
