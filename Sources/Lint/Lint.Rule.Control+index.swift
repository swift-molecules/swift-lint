public import SwiftSyntax

extension Lint.Rule.Control {
    /// The index a rule observes this control with: the facts of the control's source, given parsed as `tree`, and of
    /// each sibling file in `files`, parsed by `parse`, with the control's license, documents and nested package
    /// folders. A linter run and a rule's tests both evaluate a control with this index, so a fact a control gains
    /// reaches both.
    public func index(tree: SourceFileSyntax, parse: (Swift::String) -> SourceFileSyntax) -> Lint.Source.Index {
        var index = Lint.Source.Index.collect(from: tree, path: path.underlying)
        for (path, source) in files {
            index.merge(.collect(from: parse(source), path: path))
        }
        index.license = license
        index.documents = documents
        index.packages = packages
        return index
    }
}
