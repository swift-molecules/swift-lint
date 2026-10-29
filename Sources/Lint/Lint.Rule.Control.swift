extension Lint.Rule {
    public struct Control: Hashable, Sendable {
        public let id: ID
        public let source: Swift::String
        public let path: Lint.Source.Path
        public let expectation: Expectation
        public let applicability: Lint.Rule.Observation.Applicability
        public let license: Lint.Source.Index.License
        /// Sibling package files, by package-relative path, whose package facts the control's
        /// source is observed with: a rule that reads the manifest and the sources together
        /// is controlled by a manifest `source` plus the source files here.
        public let files: [Swift::String: Swift::String]

        @inlinable
        public init(
            id: ID,
            source: Swift::String,
            path: Lint.Source.Path,
            expectation: Expectation,
            applicability: Lint.Rule.Observation.Applicability = .applicable,
            license: Lint.Source.Index.License = .unread,
            files: [Swift::String: Swift::String] = [:]
        ) {
            self.id = id
            self.source = source
            self.path = path
            self.expectation = expectation
            self.applicability = applicability
            self.license = license
            self.files = files
        }
    }
}
